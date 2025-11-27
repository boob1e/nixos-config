# Starship Prompt Presets
# Import desired preset in flake.nix: programs.starship.settings = (import ./starship-presets.nix).minimal;

{
  # Current: Developer-focused with language indicators
  developer = {
    format = "$username$hostname$directory$git_branch$git_status$nodejs$python$rust$golang$docker_context$cmd_duration$line_break$character";
    add_newline = true;

    character = {
      success_symbol = "[❯](bold green)";
      error_symbol = "[❯](bold red)";
      vimcmd_symbol = "[❮](bold green)";
    };

    directory = {
      truncation_length = 3;
      truncate_to_repo = true;
      style = "bold cyan";
      format = "[$path]($style)[$read_only]($read_only_style) ";
    };

    git_branch = {
      symbol = " ";
      style = "bold purple";
      format = "on [$symbol$branch]($style) ";
    };

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

    cmd_duration = {
      min_time = 500;
      style = "bold yellow";
      format = "took [$duration]($style) ";
    };

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

    username = {
      style_user = "bold yellow";
      style_root = "bold red";
      format = "[$user]($style)@";
      show_always = false;
    };

    hostname = {
      ssh_only = true;
      style = "bold green";
      format = "[$hostname]($style) in ";
    };
  };

  # Minimal: Clean and fast
  minimal = {
    format = "$directory$git_branch$character";
    add_newline = true;

    character = {
      success_symbol = "[➜](bold green)";
      error_symbol = "[✗](bold red)";
    };

    directory = {
      truncation_length = 2;
      style = "bold cyan";
      format = "[$path]($style) ";
    };

    git_branch = {
      symbol = "";
      style = "bold purple";
      format = "[$symbol $branch]($style) ";
    };
  };

  # Powerline: Classic powerline style
  powerline = {
    format = "[┌─](bold blue)$directory$git_branch$git_status$line_break[└─](bold blue)$character";
    add_newline = true;

    character = {
      success_symbol = "[▶](bold green)";
      error_symbol = "[▶](bold red)";
    };

    directory = {
      style = "bg:blue fg:black";
      format = "[ $path ]($style)";
    };

    git_branch = {
      symbol = "";
      style = "bg:purple fg:black";
      format = "[ $symbol $branch ]($style)";
    };

    git_status = {
      style = "bg:red fg:black";
      format = "[ $all_status$ahead_behind ]($style)";
    };
  };

  # Compact: Single line, essential info only
  compact = {
    format = "$directory$git_branch$character";
    add_newline = false;

    character = {
      success_symbol = "[❯](bold green)";
      error_symbol = "[❯](bold red)";
    };

    directory = {
      truncation_length = 1;
      style = "cyan";
      format = "[$path]($style) ";
    };

    git_branch = {
      symbol = "";
      style = "purple";
      format = "[$symbol$branch]($style) ";
    };
  };

  # Rich: Everything including time and status
  rich = {
    format = "$username$hostname$directory$git_branch$git_status$nodejs$python$rust$golang$docker_context$kubernetes$aws$gcloud$cmd_duration$time$line_break$character";
    add_newline = true;

    character = {
      success_symbol = "[❯](bold green)";
      error_symbol = "[❯](bold red)";
    };

    directory = {
      truncation_length = 5;
      style = "bold cyan";
      format = "[$path]($style) ";
    };

    git_branch = {
      symbol = " ";
      style = "bold purple";
      format = "on [$symbol$branch]($style) ";
    };

    git_status = {
      style = "bold red";
      format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style) ";
    };

    time = {
      disabled = false;
      style = "bold white";
      format = "at [$time]($style) ";
      time_format = "%T";
    };

    cmd_duration = {
      min_time = 100;
      style = "bold yellow";
      format = "took [$duration]($style) ";
    };

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

    kubernetes = {
      symbol = "☸ ";
      style = "bold blue";
      format = "on [$symbol$context]($style) ";
      disabled = false;
    };

    aws = {
      symbol = " ";
      style = "bold yellow";
      format = "on [$symbol($profile )]($style)";
    };

    gcloud = {
      symbol = "☁️ ";
      style = "bold blue";
      format = "on [$symbol$account(@$domain)]($style) ";
    };

    username = {
      style_user = "bold yellow";
      style_root = "bold red";
      format = "[$user]($style)@";
      show_always = true;
    };

    hostname = {
      ssh_only = false;
      style = "bold green";
      format = "[$hostname]($style) in ";
    };
  };
}
