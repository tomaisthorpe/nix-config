{ config, pkgs, isDesktop ? false, ... }:
{
  imports = [
    ./editors
    ./i3

    ./terminal.nix
    ./browsers.nix
    ./git.nix
    ./dev.nix
    ./misc.nix
  ];

  home.username = "tom";
  home.homeDirectory = "/home/tom";

  # Set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 96;
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
