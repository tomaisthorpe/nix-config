{ lib, pkgs, ... }:
{

  imports = [
    ./i3
    ./browsers.nix
    ./dev.nix
    ./git.nix
    ./misc.nix
    ./terminal.nix
  ];

  # Linux-specific X resources
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 96;
  };
}
