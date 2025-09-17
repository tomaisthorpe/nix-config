{ lib, pkgs, ... }:
{
  imports = [
    ./i3
  ];

  # Linux-specific X resources
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 96;
  };
}
