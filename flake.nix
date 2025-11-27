{
  description = "Single-file NixOS config (Tommy)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
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
            time.timeZone = "America/New_York";
            i18n.defaultLocale = "en_US.UTF-8";

            nix.settings.experimental-features = [ "nix-command" "flakes" ];

            # Bootloader (UEFI)
            boot.loader.systemd-boot.enable = true;
            boot.loader.efi.canTouchEfiVariables = true;
            boot.loader.grub.enable = false;

            networking.networkmanager.enable = true;

            # GNOME Desktop
            services.xserver.enable = true;
            services.xserver.layout = "us";
            services.xserver.displayManager.gdm.enable = true;
            services.xserver.desktopManager.gnome.enable = true;

            # Audio (PipeWire)
            hardware.pulseaudio.enable = false;
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
              neovim
              ghostty
              vscode-fhs
              brave
              sublime

              # Node.js LTS
              nodejs_22

              # Claude Code CLI
              claude-code

              # Hyprland ecosystem
              hyprland
              hyprpaper
              hyprpicker
              hyprcursor
              waybar
              rofi
              wl-clipboard
              grim
              slurp
              swaynotificationcenter
              blueman
              networkmanagerapplet

              # 1Password
              _1password-cli
              _1password-gui

              # Camera utilities
              v4l-utils
              cheese

              # Audio control
              pavucontrol

              # Icons
              papirus-icon-theme

              # Custom shorthand: nix-rebuild
              (pkgs.writeShellScriptBin "nix-rebuild" ''
                sudo nixos-rebuild switch --flake /etc/nixos#my-host
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
              extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
            };

            security.sudo.enable = true;
            security.sudo.wheelNeedsPassword = true;

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

              programs.home-manager.enable = true;

              # Shell
              programs.zsh = {
                enable = true;
                oh-my-zsh.enable = true;
                initExtra = ''
                  # Run fastfetch on terminal open
                  fastfetch
                '';
              };

              # Starship prompt
              programs.starship = {
                enable = true;
                enableZshIntegration = true;
                settings = {
                  # Prompt format
                  format = "$username$hostname$directory$git_branch$git_status$nodejs$python$rust$golang$docker_context$cmd_duration$line_break$character";

                  # Add newline between prompts
                  add_newline = true;

                  # Character (prompt symbol)
                  character = {
                    success_symbol = "[❯](bold green)";
                    error_symbol = "[❯](bold red)";
                    vimcmd_symbol = "[❮](bold green)";
                  };

                  # Directory
                  directory = {
                    truncation_length = 3;
                    truncate_to_repo = true;
                    style = "bold cyan";
                    format = "[$path]($style)[$read_only]($read_only_style) ";
                  };

                  # Git branch
                  git_branch = {
                    symbol = " ";
                    style = "bold purple";
                    format = "on [$symbol$branch]($style) ";
                  };

                  # Git status
                  git_status = {
                    style = "bold red";
                    conflicted = "🏳 ";
                    ahead = "⇡\${count} ";
                    behind = "⇣\${count} ";
                    diverged = "⇕⇡\${ahead_count}⇣\${behind_count} ";
                    untracked = "? ";
                    stashed = "$ ";
                    modified = "! ";
                    staged = "+ ";
                    renamed = "» ";
                    deleted = "✘ ";
                  };

                  # Command duration
                  cmd_duration = {
                    min_time = 500;
                    style = "bold yellow";
                    format = "took [$duration]($style) ";
                  };

                  # Programming languages
                  nodejs = {
                    symbol = " ";
                    style = "bold green";
                    format = "via [$symbol($version )]($style)";
                  };

                  python = {
                    symbol = " ";
                    style = "bold yellow";
                    format = "via [$symbol$pyenv_prefix($version )]($style)";
                  };

                  rust = {
                    symbol = " ";
                    style = "bold red";
                    format = "via [$symbol($version )]($style)";
                  };

                  golang = {
                    symbol = " ";
                    style = "bold cyan";
                    format = "via [$symbol($version )]($style)";
                  };

                  docker_context = {
                    symbol = " ";
                    style = "bold blue";
                    format = "via [$symbol$context]($style) ";
                  };

                  # Username (only show when SSH)
                  username = {
                    style_user = "bold yellow";
                    style_root = "bold red";
                    format = "[$user]($style)@";
                    show_always = false;
                  };

                  # Hostname (only show when SSH)
                  hostname = {
                    ssh_only = true;
                    style = "bold green";
                    format = "[$hostname]($style) in ";
                  };
                };
              };

              # Cursor theme
              home.pointerCursor = {
                gtk.enable = true;
                x11.enable = true;
                package = pkgs.bibata-cursors;
                name = "Bibata-Modern-Classic";
                size = 24;
              };

              # User packages
              home.packages = with pkgs; [
                jq
                ripgrep
                ghostty
                fastfetch
                jujutsu
              ];

              # Jujutsu config
              home.file.".jjconfig.toml".text = ''
                [ui]
                editor = "true"

                [user]
                name = "boobie"
                email = "vessel.fins_4b@icloud.com"
              '';

              # Ghostty config
              home.file.".config/ghostty/config".text = ''
                font-family = "JetBrains Mono"
                font-size = 12
              '';

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
              home.file.".config/rofi/custom.rasi".text = ''
                * {
                  bg: rgba(28, 28, 35, 0.92);
                  bg-selected: rgba(60, 120, 240, 0.85);
                  fg: #e8e8e8;
                  fg-dim: #888888;

                  background-color: transparent;
                  text-color: @fg;

                  margin: 0;
                  padding: 0;
                  spacing: 0;
                }

                window {
                  location: north;
                  y-offset: 200;
                  width: 640;
                  border-radius: 12px;
                  background-color: @bg;
                  transparency: "real";
                }

                mainbox {
                  padding: 0;
                }

                inputbar {
                  background-color: transparent;
                  padding: 16px 20px;
                  spacing: 0;
                  border: 0px 0px 1px 0px;
                  border-color: rgba(255, 255, 255, 0.1);
                  children: [entry];
                }

                prompt {
                  enabled: false;
                }

                entry {
                  placeholder: "Spotlight Search";
                  placeholder-color: @fg-dim;
                  font: "JetBrainsMono Nerd Font 13";
                  text-color: @fg;
                }

                message {
                  padding: 12px;
                  border-color: rgba(255, 255, 255, 0.1);
                  background-color: transparent;
                }

                textbox {
                  text-color: @fg-dim;
                }

                listview {
                  background-color: transparent;
                  padding: 4px 0px 8px 0px;
                  lines: 8;
                  columns: 1;
                  fixed-height: false;
                  scrollbar: false;
                }

                element {
                  padding: 8px 20px;
                  spacing: 14px;
                  border-radius: 0px;
                }

                element normal normal {
                  background-color: transparent;
                  text-color: @fg;
                }

                element selected {
                  background-color: @bg-selected;
                  text-color: #ffffff;
                }

                element-icon {
                  size: 32px;
                  vertical-align: 0.5;
                  background-color: transparent;
                }

                element-text {
                  text-color: inherit;
                  vertical-align: 0.5;
                }
              '';

              # SwayNC config
              home.file.".config/swaync/config.json".text = ''
                {
                  "positionX": "right",
                  "positionY": "top",
                  "control-center-margin-top": 10,
                  "control-center-margin-bottom": 10,
                  "control-center-margin-right": 10,
                  "control-center-margin-left": 10,
                  "control-center-width": 400,
                  "control-center-height": 600,
                  "notification-window-width": 400,
                  "timeout": 5,
                  "timeout-low": 3,
                  "timeout-critical": 0,
                  "fit-to-screen": true,
                  "keyboard-shortcuts": true,
                  "image-visibility": "when-available",
                  "transition-time": 200,
                  "hide-on-clear": false,
                  "hide-on-action": true,
                  "script-fail-notify": true,
                  "widgets": [
                    "title",
                    "dnd",
                    "volume",
                    "backlight",
                    "mpris",
                    "notifications"
                  ],
                  "widget-config": {
                    "title": {
                      "text": "Notifications",
                      "clear-all-button": true,
                      "button-text": "Clear All"
                    },
                    "dnd": {
                      "text": "Do Not Disturb"
                    },
                    "volume": {
                      "label": "󰕾"
                    },
                    "backlight": {
                      "label": "󰃠"
                    },
                    "mpris": {
                      "image-size": 96,
                      "image-radius": 8
                    }
                  }
                }
              '';

              # SwayNC style
              home.file.".config/swaync/style.css".text = ''
                * {
                  font-family: "JetBrainsMono Nerd Font";
                  font-size: 11pt;
                }

                .control-center {
                  background: rgba(30, 30, 46, 0.95);
                  border: 2px solid #89b4fa;
                  border-radius: 16px;
                  padding: 12px;
                }

                .control-center .widget-title {
                  background: transparent;
                  color: #cdd6f4;
                  font-size: 14pt;
                  font-weight: bold;
                  margin-bottom: 8px;
                }

                .control-center .widget-title button {
                  background: #89b4fa;
                  color: #11111b;
                  border-radius: 8px;
                  padding: 4px 12px;
                  border: none;
                }

                .control-center .widget-title button:hover {
                  background: #b4befe;
                }

                .control-center .widget-dnd {
                  background: #181825;
                  border-radius: 8px;
                  padding: 8px;
                  margin: 8px 0;
                }

                .control-center .widget-dnd label {
                  color: #cdd6f4;
                }

                .notification {
                  background: rgba(24, 24, 37, 0.95);
                  border: 2px solid #313244;
                  border-radius: 12px;
                  padding: 12px;
                  margin: 8px 0;
                }

                .notification.critical {
                  border-color: #f38ba8;
                }

                .notification .notification-content {
                  color: #cdd6f4;
                }

                .notification .notification-content .summary {
                  color: #89b4fa;
                  font-weight: bold;
                  font-size: 12pt;
                }

                .notification .notification-content .body {
                  color: #a6adc8;
                  margin-top: 4px;
                }

                .notification .notification-action {
                  background: #313244;
                  color: #cdd6f4;
                  border-radius: 6px;
                  border: none;
                  padding: 4px 8px;
                  margin: 4px;
                }

                .notification .notification-action:hover {
                  background: #45475a;
                }

                .notification .close-button {
                  background: transparent;
                  color: #f38ba8;
                  border: none;
                  font-size: 14pt;
                }

                .notification .close-button:hover {
                  background: rgba(243, 139, 168, 0.2);
                  border-radius: 50%;
                }

                .control-center .notification {
                  background: #181825;
                  border: 1px solid #313244;
                }

                .control-center .notification:hover {
                  border-color: #89b4fa;
                }

                .widget-mpris {
                  background: #181825;
                  border-radius: 8px;
                  padding: 12px;
                  margin: 8px 0;
                }

                .widget-mpris .widget-mpris-player {
                  color: #cdd6f4;
                }

                .widget-mpris .widget-mpris-title {
                  color: #89b4fa;
                  font-weight: bold;
                }

                .widget-mpris .widget-mpris-subtitle {
                  color: #a6adc8;
                }

                .widget-mpris button {
                  background: #313244;
                  color: #cdd6f4;
                  border: none;
                  border-radius: 6px;
                  padding: 4px 8px;
                }

                .widget-mpris button:hover {
                  background: #45475a;
                }

                .widget-volume,
                .widget-backlight {
                  background: #181825;
                  border-radius: 8px;
                  padding: 12px;
                  margin: 8px 0;
                }

                .widget-volume label,
                .widget-backlight label {
                  color: #89b4fa;
                  font-size: 14pt;
                  margin-right: 8px;
                }

                .widget-volume scale,
                .widget-backlight scale {
                  min-width: 200px;
                }

                .widget-volume trough,
                .widget-backlight trough {
                  background: #313244;
                  border-radius: 4px;
                  min-height: 8px;
                }

                .widget-volume highlight,
                .widget-backlight highlight {
                  background: #89b4fa;
                  border-radius: 4px;
                }

                .widget-volume slider,
                .widget-backlight slider {
                  background: #cdd6f4;
                  border-radius: 50%;
                  min-width: 16px;
                  min-height: 16px;
                }
              '';

              # Hyprpaper config
              home.file.".config/hypr/hyprpaper.conf".text = ''
                preload = /home/tommypickles/Pictures/color_mountains.jpg
                wallpaper = ,/home/tommypickles/Pictures/color_mountains.jpg
              '';

              # Hyprland monitors config
              home.file.".config/hypr/monitors.conf".text = ''
                # External monitor (DP-2) with 2.0 scaling
                monitor=DP-2,preferred,auto,2.0

                # Laptop display (eDP-1) with 1.0 scaling
                monitor=eDP-1,preferred,auto,1.0

                # Workspace bindings
                workspace=1,monitor:eDP-1
                workspace=2,monitor:DP-2
                workspace=3,monitor:DP-2
                workspace=4,monitor:DP-2
                workspace=5,monitor:DP-2
                workspace=6,monitor:DP-2
              '';

              # Hyprland config
              home.file.".config/hypr/hyprland.conf".text = ''
                # Source monitor configuration
                source = ~/.config/hypr/monitors.conf

                # Autostart
                exec-once = waybar
                exec-once = hyprpaper
                exec-once = ghostty
                exec-once = swaync

                env = NIXOS_OZONE_WL,1
                env = XCURSOR_SIZE,24
                env = XCURSOR_THEME,Bibata-Modern-Classic
                env = WLR_NO_HARDWARE_CURSORS,1

                input {
                  kb_layout = us
                  follow_mouse = 1
                  touchpad {
                    natural_scroll = true
                  }
                }

                general {
                  gaps_in = 6
                  gaps_out = 12
                  border_size = 2
                  layout = dwindle
                }

                decoration {
                  rounding = 8

                  blur {
                    enabled = true
                    size = 8
                    passes = 2
                    new_optimizations = true
                  }

                  shadow {
                    enabled = true
                    range = 20
                    render_power = 3
                  }
                }

                animations {
                  enabled = yes
                  bezier = myBezier, 0.05, 0.9, 0.1, 1.05

                  animation = windows, 1, 7, myBezier
                  animation = windowsOut, 1, 7, default, popin 80%
                  animation = border, 1, 10, default
                  animation = fade, 1, 7, default
                  animation = workspaces, 1, 6, default
                }

                # Keybind helpers:
                # SUPER = main mod key (usually "logo" key)

                $mainMod = SUPER

                # App launchers
                bind = $mainMod, RETURN, exec, ghostty
                bind = $mainMod, SPACE, exec, rofi -show drun
                bind = $mainMod, B, exec, brave
                bind = $mainMod, N, exec, swaync-client -t -sw

                # Window switching (Alt+Tab)
                bind = ALT, TAB, cyclenext,
                bind = ALT, TAB, bringactivetotop,

                # Window management
                bind = $mainMod, Q, killactive,
                bind = $mainMod, F, fullscreen,
                bind = $mainMod, E, exec, brave
                bind = $mainMod, W, exec, vscode-fhs

                # Focus movement
                bind = $mainMod, H, movefocus, l
                bind = $mainMod, L, movefocus, r
                bind = $mainMod, K, movefocus, u
                bind = $mainMod, J, movefocus, d

                # Move windows
                bind = $mainMod SHIFT, H, movewindow, l
                bind = $mainMod SHIFT, L, movewindow, r
                bind = $mainMod SHIFT, K, movewindow, u
                bind = $mainMod SHIFT, J, movewindow, d

                # Workspaces
                bind = $mainMod, 1, workspace, 1
                bind = $mainMod, 2, workspace, 2
                bind = $mainMod, 3, workspace, 3
                bind = $mainMod, 4, workspace, 4
                bind = $mainMod, 5, workspace, 5
                bind = $mainMod, 6, workspace, 6

                bind = $mainMod SHIFT, 1, movetoworkspace, 1
                bind = $mainMod SHIFT, 2, movetoworkspace, 2
                bind = $mainMod SHIFT, 3, movetoworkspace, 3
                bind = $mainMod SHIFT, 4, movetoworkspace, 4
                bind = $mainMod SHIFT, 5, movetoworkspace, 5
                bind = $mainMod SHIFT, 6, movetoworkspace, 6

                # Move workspace to current monitor
                bind = $mainMod SHIFT, M, moveworkspacetomonitor, current current

                # Screenshots
                bind = , PRINT, exec, grim ~/Pictures/screenshot-$(date +%Y-%m-%d_%H-%M-%S).png
                bind = SHIFT, PRINT, exec, grim -g "$(slurp)" ~/Pictures/screenshot-$(date +%Y-%m-%d_%H-%M-%S).png

                # Reload / exit Hyprland
                bind = $mainMod, C, exec, hyprctl reload
                bind = $mainMod SHIFT, C, exit,

                misc {
                  disable_hyprland_logo = true
                }
              '';

              # Waybar config
              home.file.".config/waybar/config".text = ''
                {
                  "layer": "top",
                  "position": "top",
                  "height": 32,
                  "margin-top": 4,
                  "margin-left": 8,
                  "margin-right": 8,
                  "modules-left": ["hyprland/workspaces", "hyprland/window", "custom/git", "custom/docker"],
                  "modules-center": [],
                  "modules-right": ["cpu", "memory", "pulseaudio", "network", "battery", "clock", "tray"],

                  "hyprland/workspaces": {
                    "format": "{name}",
                    "on-click": "hyprctl dispatch workspace {name}",
                    "on-scroll-up": "hyprctl dispatch workspace e+1",
                    "on-scroll-down": "hyprctl dispatch workspace e-1",
                    "sort-by-number": true
                  },

                  "hyprland/window": {
                    "format": "{title}",
                    "max-length": 60,
                    "separate-outputs": false
                  },

                  "clock": {
                    "format": "{:%a %b %d  %H:%M}",
                    "tooltip": true,
                    "tooltip-format": "{:%Y-%m-%d %H:%M:%S}"
                  },

                  "cpu": {
                    "format": " {usage}%",
                    "tooltip": true
                  },

                  "memory": {
                    "format": " {used:0.1f}G",
                    "tooltip": true
                  },

                  "pulseaudio": {
                    "format": "{icon} {volume}%",
                    "format-muted": " muted",
                    "format-icons": {
                      "default": ["", "", ""]
                    },
                    "on-click": "pavucontrol",
                    "on-click-right": "pactl set-default-sink $(pactl list short sinks | grep -v $(pactl get-default-sink) | head -n1 | cut -f2)",
                    "tooltip-format": "{desc}"
                  },

                  "network": {
                    "format-wifi": " {essid}",
                    "format-ethernet": " {ifname}",
                    "format-disconnected": " offline",
                    "tooltip": true
                  },

                  "battery": {
                    "format": "{capacity}%",
                    "format-charging": " {capacity}%",
                    "interval": 30,
                    "tooltip": true
                  },

                  "tray": {
                    "icon-size": 16,
                    "spacing": 8
                  },

                  "custom/git": {
                    "format": " {}",
                    "exec": "git -C ~ rev-parse --abbrev-ref HEAD 2>/dev/null || echo",
                    "interval": 5,
                    "on-click": "ghostty -e lazygit",
                    "tooltip": false
                  },

                  "custom/docker": {
                    "format": " {}",
                    "exec": "docker ps -q 2>/dev/null | wc -l || echo 0",
                    "interval": 10,
                    "tooltip": false
                  }
                }
              '';

              # Waybar style
              home.file.".config/waybar/style.css".text = ''
                * {
                  font-family: "JetBrainsMono Nerd Font", monospace;
                  font-size: 11pt;
                  border: none;
                  min-height: 0;
                }

                window#waybar {
                  background: rgba(10, 10, 18, 0.85);
                  border-radius: 16px;
                  margin: 0px 0px;
                  padding: 4px 10px;
                  color: #cdd6f4;
                  border: 1px solid rgba(137, 180, 250, 0.4);
                }

                #workspaces {
                  border-radius: 999px;
                  background: rgba(24, 24, 37, 0.9);
                  margin: 0 8px 0 0;
                  padding: 2px 4px;
                }

                #workspaces button {
                  padding: 2px 10px;
                  color: #7f849c;
                  border-radius: 999px;
                  background: transparent;
                }

                #workspaces button.active {
                  color: #11111b;
                  background: linear-gradient(135deg, #89b4fa, #b4befe);
                  font-weight: bold;
                }

                #workspaces button:hover {
                  background: rgba(137, 180, 250, 0.25);
                  color: #cdd6f4;
                }

                #window {
                  padding: 0 14px;
                  margin: 0 6px;
                  color: #a6adc8;
                }

                #custom-git,
                #custom-docker {
                  padding: 2px 10px;
                  margin: 0 6px;
                  color: #a6adc8;
                }

                #clock,
                #cpu,
                #memory,
                #network,
                #pulseaudio,
                #battery,
                #tray {
                  padding: 2px 10px;
                  margin: 0 3px;
                  border-radius: 999px;
                  background: rgba(24, 24, 37, 0.92);
                }

                #cpu {
                  color: #f9e2af;
                }

                #memory {
                  color: #fab387;
                }

                #network {
                  color: #89dceb;
                }

                #pulseaudio {
                  color: #a6e3a1;
                }

                #battery {
                  color: #f38ba8;
                }

                #battery.critical {
                  background: rgba(248, 77, 77, 0.35);
                  color: #f9e2af;
                }

                #clock {
                  color: #cba6f7;
                }

                #tray {
                  background: rgba(30, 30, 46, 0.95);
                }

                #custom-git {
                  color: #f5c2e7;
                }

                #custom-docker {
                  color: #89dceb;
                }
              '';

              xdg.enable = true;
            };

            # Hyprland module (from nixpkgs)
            programs.hyprland = {
              enable = true;
              xwayland.enable = true;
              # nvidiaPatches = true;
            };

            environment.sessionVariables = {
              NIXOS_OZONE_WL = "1";
            };
          })
        ];
      };
    };
}

