{
  description = "Single-file NixOS config (Tommy)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs = { self, nixpkgs, home-manager, zen-browser, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./hardware-configuration.nix

          home-manager.nixosModules.home-manager

          ({ config, pkgs, ... }: {

            # -----------------------------
            # System Configuration
            # -----------------------------

            nixpkgs.config.allowUnfree = true;
            networking.hostName = "my-host";
            networking.hosts = {
              "192.168.1.101" = [ "umbrel.local" ];
            };
            time.timeZone = "America/New_York";
            i18n.defaultLocale = "en_US.UTF-8";

            nix.settings.experimental-features = [ "nix-command" "flakes" ];

            # Bootloader (UEFI)
            boot.loader.systemd-boot.enable = true;
            boot.loader.efi.canTouchEfiVariables = true;
            boot.loader.grub.enable = false;

            # Linux Zen Kernel - better desktop performance/latency
            boot.kernelPackages = pkgs.linuxPackages_zen;

            # Kernel parameters for NVIDIA power management and suspend/resume
            boot.kernelParams = [
              # Preserve video memory allocations across suspend/resume to prevent freeze
              "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
              # Temporary file path for NVIDIA suspend/resume
              "nvidia.NVreg_TemporaryFilePath=/var/tmp"
            ];

            networking.networkmanager.enable = true;

            # GNOME Desktop
            services.xserver.enable = true;
            services.xserver.xkb.layout = "us";
            services.xserver.displayManager.gdm.enable = true;
            services.xserver.displayManager.gdm.wayland = true;
            services.xserver.desktopManager.gnome.enable = true;

            # NVIDIA Prime Offload Configuration
            # Intel GPU for desktop rendering, NVIDIA available on-demand
            services.xserver.videoDrivers = [ "nvidia" ];

            hardware.nvidia = {
              modesetting.enable = true;
              open = false;
              nvidiaSettings = true;
              package = config.boot.kernelPackages.nvidiaPackages.stable;

              prime = {
                offload = {
                  enable = true;
                  enableOffloadCmd = true;
                };
                intelBusId = "PCI:0:2:0";
                nvidiaBusId = "PCI:1:0:0";
              };
            };

            # NVIDIA clock limits for better power management
            systemd.services.nvidia-clocks = {
              description = "Set NVIDIA GPU clock limits";
              wantedBy = [ "multi-user.target" ];
              after = [ "systemd-modules-load.service" ];
              path = [ config.boot.kernelPackages.nvidiaPackages.stable ];
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
              };
              script = ''
                nvidia-smi -pm 1
                nvidia-smi -lgc 1000,2100
                nvidia-smi -lmc 810,5001
              '';
            };

            # NVIDIA sleep/resume hooks to prevent display freeze
            systemd.services.nvidia-resume = {
              description = "NVIDIA GPU resume from suspend";
              after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
              wantedBy = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
              path = [ config.boot.kernelPackages.nvidiaPackages.stable ];
              serviceConfig = {
                Type = "oneshot";
              };
              script = ''
                # Re-apply clock limits after resume
                nvidia-smi -pm 1
                nvidia-smi -lgc 1000,2100
                nvidia-smi -lmc 810,5001
              '';
            };

            # Systemd sleep configuration
            systemd.sleep.extraConfig = ''
              HibernateDelaySec=30m
            '';

            # Audio (PipeWire)
            services.pulseaudio.enable = false;
            services.pipewire = {
              enable = true;
              alsa.enable = true;
              alsa.support32Bit = true;
              pulse.enable = true;
              wireplumber.enable = true;
            };

            # Fonts
            fonts.fontconfig.enable = true;
            fonts.packages = with pkgs; [
              jetbrains-mono
              nerd-fonts.jetbrains-mono
            ];

            # System-wide packages
            environment.systemPackages = with pkgs; [
              git
              curl
              wget
              gnumake
              nushell
              ghostty
              brave
              zen-browser.packages."${system}".default
              sublime
              zed-editor
	            obsidian
              gitkraken

              # GNOME packages
              gnome-tweaks
              gnomeExtensions.dash-to-dock

              # Node.js LTS
              nodejs_22

              # Go
              go

              # GCC Compiler
              gcc

              # GPG
              gnupg

              # Signal Desktop
              signal-desktop

              # SimpleX Chat
              simplex-chat-desktop

              # NVIDIA packages
              config.boot.kernelPackages.nvidiaPackages.stable  # nvidia-smi, nvidia-settings
              nvidia-vaapi-driver  # Hardware video acceleration

              # Claude Code CLI
              claude-code

              # Hyprland ecosystem
              hyprland
              hyprpaper
              hyprpicker
              hyprlock
              waybar
              rofi
              wl-clipboard
              grim
              slurp
              blueman
              networkmanagerapplet
              mako

              # 1Password
              _1password-cli
              _1password-gui

              # Camera utilities
              v4l-utils
              cheese

              # Audio control
              pwvucontrol

              # Icons
              papirus-icon-theme

              # File sharing
              localsend

              # Custom shorthand: nix-rebuild
              (pkgs.writeShellScriptBin "nix-rebuild" ''
                sudo nixos-rebuild switch --flake /etc/nixos#my-host
              '')

              # Rofi power menu
              (pkgs.writeShellScriptBin "rofi-power-menu" ''
                chosen=$(echo -e "󰐥 Shutdown\n󰜉 Reboot\n󰍃 Logout\n󰒲 Suspend\n󰤄 Lock" | rofi -dmenu -i -p "Power Menu")
                case "$chosen" in
                  "󰐥 Shutdown") systemctl poweroff ;;
                  "󰜉 Reboot") systemctl reboot ;;
                  "󰍃 Logout") hyprctl dispatch exit ;;
                  "󰒲 Suspend") systemctl suspend ;;
                  "󰤄 Lock") hyprlock ;;
                esac
              '')

              # Rofi battery menu
              (pkgs.writeShellScriptBin "rofi-battery-menu" ''
                battery_info=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null || upower -i /org/freedesktop/UPower/devices/battery_BAT1 2>/dev/null)

                if [ -z "$battery_info" ]; then
                  echo "No battery found" | rofi -dmenu -p "Battery"
                  exit
                fi

                percentage=$(echo "$battery_info" | grep percentage | awk '{print $2}')
                state=$(echo "$battery_info" | grep state | awk '{print $2}')
                time_to=$(echo "$battery_info" | grep "time to" | cut -d: -f2- | xargs)

                menu="Battery: $percentage\n"
                menu+="Status: $state\n"
                [ -n "$time_to" ] && menu+="Time: $time_to\n"

                echo -e "$menu" | rofi -dmenu -p "Battery Info"
              '')
            ];

            # XDG Portals (needed for screensharing, file pickers, camera, etc.)
            xdg.portal = {
              enable = true;
              extraPortals = [
                pkgs.xdg-desktop-portal-hyprland
                pkgs.xdg-desktop-portal-gtk
              ];
              wlr.enable = true;
            };

            # User
            users.users.tommypickles = {
              isNormalUser = true;
              shell = pkgs.zsh;
              extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
            };

            security.sudo.enable = true;
            security.sudo.wheelNeedsPassword = true;

            # Enable zsh system-wide
            programs.zsh.enable = true;

            system.stateVersion = "24.11";

            # -----------------------------
            # Home-Manager (User Config)
            # -----------------------------

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.tommypickles = { pkgs, ... }: {
              home.username = "tommypickles";
              home.homeDirectory = "/home/tommypickles";
              home.stateVersion = "24.11";
              home.enableNixpkgsReleaseCheck = false;

              programs.home-manager.enable = true;

              # Shell
              programs.zsh = {
                enable = true;
                oh-my-zsh.enable = true;
                initContent = ''
                  # Run fastfetch on terminal open
                  fastfetch
                '';
              };

              # VSCode
              programs.vscode = {
                enable = true;
                package = pkgs.vscode;
                extensions = with pkgs.vscode-extensions; [
                  catppuccin.catppuccin-vsc
                  enkia.tokyo-night
                  golang.go
                ];
                userSettings = {
                  "editor.fontFamily" = "'JetBrainsMono Nerd Font', monospace";
                  "editor.fontSize" = 14;
                };
              };

              # Starship prompt
              programs.starship = {
                enable = true;
                enableZshIntegration = true;
                settings = (import ./starship-presets.nix).developer;
              };

              # Neovim with LSP servers and tools for NvChad
              programs.neovim = {
                enable = true;
                defaultEditor = true;
                viAlias = true;
                vimAlias = true;
                extraPackages = with pkgs; [
                  # LSP servers
                  gopls
                  lua-language-server
                  nil
                  vscode-langservers-extracted  # html, css, json, eslint

                  # Telescope dependencies
                  ripgrep
                  fd
                ];
              };

              # User packages
              home.packages = with pkgs; [
                jq
                ghostty
                fastfetch
                jujutsu
              ];

              # Simple cursor theme (replaces Hyprland logo cursor)
              home.pointerCursor = {
                gtk.enable = true;
                x11.enable = true;
                package = pkgs.adwaita-icon-theme;
                name = "Adwaita";
                size = 24;
              };

              # Brave browser policies for extensions
              home.file.".config/BraveSoftware/Brave-Browser/Managed Preferences".text = builtins.toJSON {
                ExtensionInstallForcelist = [
                  "faghfoppoimhmffaephmideccaidpagj"  # Tab Sorter
                  "ldgfbffkinooeloadekpmfoklnobpien"  # Raindrop
                ];
              };

              # Jujutsu config
              home.file.".jjconfig.toml".text = ''
                [ui]
                editor = "nvim"
                pager = "cat"

                [user]
                name = "boobie"
                email = "vessel.fins_4b@icloud.com"
              '';

              # Ghostty config
              home.file.".config/ghostty/config".text = builtins.readFile ./ghostty-config;

              # Rofi config
              home.file.".config/rofi/config.rasi".text = ''
                configuration {
                  modi: "drun,run,window";
                  show-icons: true;
                  icon-theme: "Papirus-Dark";
                  display-drun: " Apps";
                  display-run: " Run";
                  display-window: " Windows";
                  drun-display-format: "{name}";
                  font: "JetBrainsMono Nerd Font 11";
                }

                @theme "custom"
              '';

              # Rofi theme - macOS Spotlight inspired
              home.file.".config/rofi/custom.rasi".text = builtins.readFile ./rofi-theme.rasi;

              # Hyprpaper config
              home.file.".config/hypr/hyprpaper.conf".text = ''
                preload = /home/tommypickles/Pictures/color_mountains.jpg
                wallpaper = ,/home/tommypickles/Pictures/color_mountains.jpg
              '';

              # Hyprlock config
              home.file.".config/hypr/hyprlock.conf".text = builtins.readFile ./hyprlock.conf;

              # Hyprland monitors config
              home.file.".config/hypr/monitors.conf".text = builtins.readFile ./monitors.conf;

              # Hyprland config
              home.file.".config/hypr/hyprland.conf".text = builtins.readFile ./hyprland.conf;

              # Waybar config
              home.file.".config/waybar/config".text = builtins.readFile ./waybar-config.json;

              # Waybar style
              home.file.".config/waybar/style.css".text = builtins.readFile ./waybar-style.css;

              xdg.enable = true;

              # NvChad setup - clone NvChad if it doesn't exist
              home.activation.installNvChad = ''
                if [ ! -d "$HOME/.config/nvim" ]; then
                  ${pkgs.git}/bin/git clone https://github.com/NvChad/starter "$HOME/.config/nvim"
                  echo "NvChad installed to ~/.config/nvim"
                fi
              '';
            };

            # Hyprland module (from nixpkgs)
            # NVIDIA patches are automatically applied when hardware.nvidia is configured
            programs.hyprland = {
              enable = true;
              xwayland.enable = true;
            };

            environment.sessionVariables = {
              NIXOS_OZONE_WL = "1";
            };
          })
        ];
      };
    };
}

