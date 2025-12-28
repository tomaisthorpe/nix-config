{
  lib,
  pkgs,
  ...
}:
{
  programs.kitty = {
    enable = true;
    # kitty has catppuccin theme built-in,
    # all the built-in themes are packaged into an extra package named `kitty-themes`
    # and it's installed by home-manager if `theme` is specified.
    themeFile = "Catppuccin-Macchiato";
    font = {
      name = "Hack Nerd Font";
      size = 9;
    };

    settings = {
      enable_audio_bell = false;
      tab_bar_edge = "top"; # tab bar on top
      tab_bar_min_tabs = "0";
    };

    # Open new windows/tabs in same directory as current window
    extraConfig = ''
      map ctrl+shift+enter new_os_window_with_cwd
      map ctrl+shift+t new_tab_with_cwd
    '';
  };

  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';

    shellAliases = {
      j = "z";
      gap = "git add --patch .";
    };
  };

  # Similar to autojump and fasd
  programs.zoxide.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.tmux = {
    enable = true;
    shortcut = "a";
    shell = "${pkgs.zsh}/bin/zsh";

    plugins = with pkgs; [
      tmuxPlugins.sensible
      { 
        plugin = tmuxPlugins.catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor 'mocha'
          set -g @catppuccin_window_status_style "rounded"
          set -g @catppuccin_window_current_text " #W"
          set -g @catppuccin_window_text " #W"
        '';
      }
      tmuxPlugins.session-wizard
      tmuxPlugins.resurrect
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = "set -g @continuum-restore 'on'";
      }
    ];

    mouse = true;

    extraConfig = ''
      set -g status-right ""
      set -g default-terminal "tmux-256color"
      set -g default-command "/bin/zsh"

      bind -r "<" swap-window -d -t -1
      bind -r ">" swap-window -d -t +1
    '';
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;

    defaultOptions = [
      "--height 40%"
      "--border"
      "--cycle"
    ];

    # Ctrl-T (file search)
    fileWidgetOptions = [
      "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
      "--preview-window 'right:50%:hidden'"
      "--bind 'ctrl-/:toggle-preview'"
      "--bind 'ctrl-u:preview-up,ctrl-d:preview-down'"
    ];

    # Ctrl-R (history search)
    historyWidgetOptions = [
      "--preview 'echo {}'"
      "--preview-window 'down:3:hidden:wrap'"
      "--bind 'ctrl-/:toggle-preview'"
    ];

    # Alt-C (cd to directory)
    changeDirWidgetOptions = [
      "--preview 'ls -la {}'"
      "--preview-window 'right:50%:hidden'"
      "--bind 'ctrl-/:toggle-preview'"
    ];
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin Mocha";
    };
  };
}
