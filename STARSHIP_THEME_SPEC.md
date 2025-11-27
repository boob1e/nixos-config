# Starship Theme Specification

A guide for creating custom starship prompt themes in NixOS configuration.

## Table of Contents
- [Quick Start](#quick-start)
- [Theme Structure](#theme-structure)
- [Available Modules](#available-modules)
- [Styling Guide](#styling-guide)
- [Symbol Reference](#symbol-reference)
- [Creating New Themes](#creating-new-themes)

---

## Quick Start

### Using Existing Presets

In `flake.nix`, set your starship configuration:

```nix
programs.starship = {
  enable = true;
  enableZshIntegration = true;
  settings = (import ./starship-presets.nix).PRESET_NAME;
};
```

Available presets: `developer`, `minimal`, `powerline`, `compact`, `rich`

### Creating a New Theme

1. Open `starship-presets.nix`
2. Add a new attribute following the template below
3. Reference it in `flake.nix`
4. Run `nix-rebuild`

---

## Theme Structure

Every starship theme is a Nix attribute set with the following structure:

```nix
themeName = {
  # Prompt format string - defines order of modules
  format = "$module1$module2$character";

  # Global settings
  add_newline = true;  # Add blank line between prompts

  # Module configurations
  module_name = {
    # Module-specific settings
  };
};
```

### Format String Variables

The `format` string controls what appears and in what order:

| Variable | Description |
|----------|-------------|
| `$username` | Current username |
| `$hostname` | Machine hostname |
| `$directory` | Current directory |
| `$git_branch` | Git branch name |
| `$git_status` | Git working tree status |
| `$git_commit` | Git commit hash |
| `$git_state` | Git state (rebase, merge, etc.) |
| `$package` | Package version (package.json, Cargo.toml, etc.) |
| `$nodejs` | Node.js version |
| `$python` | Python version |
| `$rust` | Rust version |
| `$golang` | Go version |
| `$java` | Java version |
| `$ruby` | Ruby version |
| `$php` | PHP version |
| `$docker_context` | Docker context |
| `$kubernetes` | Kubernetes context |
| `$aws` | AWS profile |
| `$gcloud` | Google Cloud config |
| `$azure` | Azure subscription |
| `$cmd_duration` | Command execution time |
| `$time` | Current time |
| `$jobs` | Background jobs |
| `$battery` | Battery level |
| `$memory_usage` | Memory usage |
| `$character` | Prompt character (usually last) |
| `$line_break` | Newline |

---

## Available Modules

### Core Modules

#### character
The prompt symbol that changes based on success/failure.

```nix
character = {
  success_symbol = "[❯](bold green)";    # Command succeeded
  error_symbol = "[❯](bold red)";        # Command failed
  vimcmd_symbol = "[❮](bold green)";     # Vim normal mode
};
```

**Common Symbols:** `❯` `➜` `▶` `λ` `$` `%` `→` `⟫`

#### directory
Current working directory display.

```nix
directory = {
  truncation_length = 3;           # Max parent folders to show
  truncate_to_repo = true;         # Stop at git repo root
  fish_style_pwd_dir_length = 0;   # Short dir names (0 = disabled)
  style = "bold cyan";             # Color and formatting
  format = "[$path]($style) ";     # Display format
  read_only = " 󰌾";               # Read-only indicator
  home_symbol = "~";               # Home directory symbol
};
```

**Truncation Examples:**
- `0` = No truncation: `/very/long/path/to/project`
- `1` = Keep one parent: `project`
- `3` = Keep three parents: `path/to/project`

#### git_branch
Git branch indicator.

```nix
git_branch = {
  symbol = " ";                    # Icon before branch name
  style = "bold purple";           # Color
  format = "on [$symbol$branch]($style) ";
  truncation_length = 20;          # Max branch name length
  truncation_symbol = "…";         # Truncation indicator
  only_attached = false;           # Show detached HEAD
};
```

**Common Git Symbols:** ` ` `` `` `` `⎇` `±`

#### git_status
Git working tree status.

```nix
git_status = {
  style = "bold red";
  conflicted = "🏳 ";               # Merge conflicts
  ahead = "⇡\${count} ";           # Commits ahead of remote
  behind = "⇣\${count} ";          # Commits behind remote
  diverged = "⇕⇡\${ahead_count}⇣\${behind_count} ";
  untracked = "? ";                # Untracked files
  stashed = "$ ";                  # Stashed changes
  modified = "! ";                 # Modified files
  staged = "+ ";                   # Staged changes
  renamed = "» ";                  # Renamed files
  deleted = "✘ ";                  # Deleted files
  format = "([$all_status$ahead_behind]($style)) ";
};
```

**Status Symbols:** `✔` `✘` `!` `?` `+` `⇡` `⇣` `±` `×` `●` `✚`

### Programming Language Modules

Each language module follows this pattern:

```nix
LANGUAGE = {
  symbol = "ICON ";               # Language icon
  style = "bold COLOR";           # Color theme
  format = "via [$symbol($version )]($style)";
  detect_extensions = ["ext"];    # File extensions to detect
  detect_files = ["file"];        # Specific files to detect
  detect_folders = ["folder"];    # Folder names to detect
};
```

#### nodejs
```nix
nodejs = {
  symbol = " ";                    # or 󰎙
  style = "bold green";
  format = "via [$symbol($version )]($style)";
};
```

#### python
```nix
python = {
  symbol = " ";                    # or 🐍
  style = "bold yellow";
  format = "via [$symbol$pyenv_prefix($version )]($style)";
  pyenv_prefix = "pyenv ";         # Prefix for pyenv versions
};
```

#### rust
```nix
rust = {
  symbol = " ";                    # or 🦀
  style = "bold red";
  format = "via [$symbol($version )]($style)";
};
```

#### golang
```nix
golang = {
  symbol = " ";                    # or 󰟓
  style = "bold cyan";
  format = "via [$symbol($version )]($style)";
};
```

**Other Languages:** `java`, `ruby`, `php`, `elixir`, `nim`, `crystal`, `kotlin`, `swift`

### Infrastructure Modules

#### docker_context
```nix
docker_context = {
  symbol = " ";                    # or 🐳
  style = "bold blue";
  format = "via [$symbol$context]($style) ";
  only_with_files = true;          # Only show in Docker projects
};
```

#### kubernetes
```nix
kubernetes = {
  symbol = "☸ ";                   # or 󱃾
  style = "bold blue";
  format = "on [$symbol$context( \\($namespace\\))]($style) ";
  disabled = false;
};
```

#### aws
```nix
aws = {
  symbol = " ";                    # or ☁️
  style = "bold yellow";
  format = "on [$symbol($profile )(\\($region\\) )]($style)";
};
```

### System Modules

#### cmd_duration
Show command execution time.

```nix
cmd_duration = {
  min_time = 500;                  # Minimum ms to display
  style = "bold yellow";
  format = "took [$duration]($style) ";
  show_milliseconds = false;
  show_notifications = false;
};
```

#### time
Current time display.

```nix
time = {
  disabled = false;
  style = "bold white";
  format = "at [$time]($style) ";
  time_format = "%T";              # 24-hour: HH:MM:SS
  # time_format = "%r";            # 12-hour: HH:MM:SS AM/PM
  utc_time_offset = "local";
};
```

**Time Format Codes:**
- `%H` = Hour (24h)
- `%I` = Hour (12h)
- `%M` = Minute
- `%S` = Second
- `%p` = AM/PM
- `%T` = HH:MM:SS
- `%r` = 12-hour time

#### username & hostname
```nix
username = {
  style_user = "bold yellow";
  style_root = "bold red";
  format = "[$user]($style)@";
  show_always = false;             # Only show when SSH
};

hostname = {
  ssh_only = true;                 # Only show on SSH connections
  style = "bold green";
  format = "[$hostname]($style) in ";
  trim_at = ".";                   # Remove domain suffix
};
```

#### battery
```nix
battery = {
  full_symbol = " ";
  charging_symbol = " ";
  discharging_symbol = " ";
  format = "[$symbol$percentage]($style) ";
  display = [
    {
      threshold = 10;
      style = "bold red";
    }
    {
      threshold = 30;
      style = "bold yellow";
    }
  ];
};
```

#### memory_usage
```nix
memory_usage = {
  disabled = false;
  threshold = 75;                  # Only show above 75% usage
  symbol = "󰍛 ";
  style = "bold dimmed white";
  format = "via $symbol[$ram( | $swap)]($style) ";
};
```

---

## Styling Guide

### Color Names

**Basic Colors:**
- `black`, `red`, `green`, `yellow`, `blue`, `purple`, `cyan`, `white`

**Bright Colors:**
- `bright-black`, `bright-red`, `bright-green`, `bright-yellow`
- `bright-blue`, `bright-purple`, `bright-cyan`, `bright-white`

**RGB/Hex Colors:**
- `"#FF5733"` (hex)
- `"rgb(255, 87, 51)"` (rgb)

### Style Modifiers

Combine with colors: `"bold green"`, `"italic blue"`, `"underline yellow"`

- `bold` - Bold text
- `italic` - Italic text
- `underline` - Underlined text
- `dimmed` - Dimmed/faint text
- `inverted` - Swap foreground/background
- `blink` - Blinking text (not widely supported)
- `hidden` - Hidden text

**Examples:**
```nix
style = "bold green";
style = "italic bright-blue";
style = "bold underline #FF5733";
style = "bg:blue fg:black";      # Background blue, text black
```

### Format Strings

Format strings use `[$variable]($style)` syntax:

```nix
format = "[$symbol$version]($style) ";
#         ^       ^         ^
#         |       |         style applied here
#         |       variable
#         literal text
```

**Conditional Display:**
```nix
format = "[$symbol($version )]($style)";
#                  ^         ^
#                  only shown if version exists
```

---

## Symbol Reference

### Nerd Font Icons

Common icons for themes (requires Nerd Font):

**Git & Version Control:**
- ` ` `` `` `` (git branch)
- `󰊢` (commit)
- `±` `⎇` (alternative branch symbols)

**Languages:**
- ` ` (Node.js)
- ` ` (Python)
- ` ` (Rust)
- ` ` (Go)
- ` ` (Java)
- ` ` (Ruby)
- ` ` (PHP)

**Infrastructure:**
- ` ` `🐳` (Docker)
- `☸` `󱃾` (Kubernetes)
- ` ` (AWS)
- `☁️` (Cloud)

**System:**
- ` ` (folder)
- `󰉋` (file)
- ` ` (terminal)
- `󰍛` (memory)
- ` ` (battery)

**Arrows & Symbols:**
- `❯` `➜` `▶` `→` `⟫` (prompt arrows)
- `⇡` `⇣` (git ahead/behind)
- `✔` `✘` `!` `?` (status symbols)

### Finding More Icons

- [Nerd Fonts Cheat Sheet](https://www.nerdfonts.com/cheat-sheet)
- Search for icons by name
- Copy icon directly into config

---

## Creating New Themes

### Theme Creation Checklist

1. **Define Purpose**
   - [ ] Minimal/Fast or Rich/Detailed?
   - [ ] Single-line or multi-line?
   - [ ] Which modules are essential?

2. **Choose Color Scheme**
   - [ ] Primary color (directories, paths)
   - [ ] Secondary color (git, language info)
   - [ ] Accent color (prompts, highlights)
   - [ ] Error color (failures, warnings)

3. **Select Symbols**
   - [ ] Prompt character
   - [ ] Git symbol
   - [ ] Language symbols
   - [ ] Directory symbol (optional)

4. **Build Format String**
   - [ ] Start with essentials: `$directory$character`
   - [ ] Add git: `$directory$git_branch$git_status$character`
   - [ ] Add languages as needed
   - [ ] Add line breaks if multi-line

5. **Configure Modules**
   - [ ] Set truncation lengths
   - [ ] Choose status symbols
   - [ ] Define display conditions

6. **Test**
   - [ ] Apply config with `nix-rebuild`
   - [ ] Test in git repo
   - [ ] Test with different languages
   - [ ] Test error states

### Theme Template

```nix
my_theme = {
  # Global settings
  format = "$directory$git_branch$character";
  add_newline = true;

  # Prompt symbol
  character = {
    success_symbol = "[SYMBOL](bold COLOR)";
    error_symbol = "[SYMBOL](bold COLOR)";
  };

  # Directory
  directory = {
    truncation_length = 3;
    style = "bold COLOR";
    format = "[$path]($style) ";
  };

  # Git branch
  git_branch = {
    symbol = "SYMBOL ";
    style = "bold COLOR";
    format = "on [$symbol$branch]($style) ";
  };

  # Add more modules as needed...
};
```

### Example: Creating a "Cyberpunk" Theme

```nix
cyberpunk = {
  format = "$username$directory$git_branch$git_status$nodejs$rust$docker_context$line_break$character";
  add_newline = true;

  character = {
    success_symbol = "[⟫](bold #00ff9f)";
    error_symbol = "[⟫](bold #ff0055)";
  };

  username = {
    style_user = "bold #ff00ff";
    format = "[$user]($style)@";
    show_always = true;
  };

  directory = {
    truncation_length = 2;
    style = "bold #00d9ff";
    format = "[$path]($style) ";
  };

  git_branch = {
    symbol = " ";
    style = "bold #ff00ff";
    format = "[$symbol$branch]($style) ";
  };

  git_status = {
    style = "bold #ff0055";
    ahead = "↑\${count} ";
    behind = "↓\${count} ";
    diverged = "↕ ";
    modified = "● ";
    staged = "✚ ";
  };

  nodejs = {
    symbol = "󰎙 ";
    style = "bold #00ff9f";
    format = "[$symbol($version )]($style)";
  };

  rust = {
    symbol = " ";
    style = "bold #ff6600";
    format = "[$symbol($version )]($style)";
  };

  docker_context = {
    symbol = " ";
    style = "bold #00d9ff";
    format = "[$symbol$context]($style) ";
  };
};
```

### Adding Theme to starship-presets.nix

1. Open `starship-presets.nix`
2. Add your theme:

```nix
{
  developer = { ... };
  minimal = { ... };

  # Add your new theme here
  my_theme = {
    # Your configuration
  };
}
```

3. Use in `flake.nix`:

```nix
programs.starship.settings = (import ./starship-presets.nix).my_theme;
```

---

## Theme Design Tips

### Performance
- Fewer modules = faster prompt
- Avoid `time` module if not needed
- Use `disabled = true` for unused modules
- Consider `truncation_length` for long paths

### Readability
- High contrast for text visibility
- Consistent symbol usage
- Logical information grouping
- Don't overload with too many modules

### Visual Balance
- Single-line for simplicity
- Multi-line for detail (use `$line_break`)
- Group related info (git together, languages together)
- Use spacing effectively: `" "` in format strings

### Context Awareness
- `ssh_only` for username/hostname
- `show_always = false` for non-essential info
- Use thresholds for battery, memory
- Language detection via file extensions

---

## Common Patterns

### Two-Line Prompt
```nix
format = "$all$line_break$character";
```

### Info on Right Side
```nix
right_format = "$cmd_duration$time";
```

### Minimal Git
```nix
format = "$directory$git_branch$character";
```

### Full Developer Setup
```nix
format = "$username$hostname$directory$git_branch$git_status$nodejs$python$rust$golang$docker_context$kubernetes$cmd_duration$line_break$character";
```

### Compact Single-Line
```nix
format = "$directory$git_branch$character";
add_newline = false;
```

---

## Resources

- [Starship Documentation](https://starship.rs/config/)
- [Nerd Fonts](https://www.nerdfonts.com/)
- [Color Picker](https://www.color-hex.com/)
- [Starship Presets](https://starship.rs/presets/)

---

## Quick Reference

### Module Priority (Most Common)
1. `character` - Always include
2. `directory` - Essential for navigation
3. `git_branch` - Essential for dev work
4. `git_status` - Useful for git state
5. Language modules - As needed
6. `cmd_duration` - Performance monitoring
7. Infrastructure (docker, k8s) - Context dependent
8. `time` - Optional

### Typical Format Orders

**Minimal:**
```
$directory$git_branch$character
```

**Standard:**
```
$directory$git_branch$git_status$character
```

**Developer:**
```
$directory$git_branch$git_status$LANGUAGES$cmd_duration$line_break$character
```

**Full:**
```
$username$hostname$directory$git_branch$git_status$LANGUAGES$INFRA$cmd_duration$time$line_break$character
```

Replace `$LANGUAGES` and `$INFRA` with specific modules as needed.
