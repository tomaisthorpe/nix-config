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
    theme = "Catppuccin-Macchiato";
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
  };

  # Similar to autojump and fasd
  programs.zoxide.enable = true;

  home.packages = with pkgs; [
    fzf
  ];
}
