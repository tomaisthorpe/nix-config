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

  home.packages = with pkgs; [
    fzf
  ];
}
