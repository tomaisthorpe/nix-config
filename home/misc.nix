{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # creative
    blender
    inkscape

    spotify

    # pcb stuff
    kicad

    # messaging
    telegram-desktop
    discord

    # devtools
    ripgrep

    # notes
    obsidian

    # misc
    flameshot
    pavucontrol
    pulsemixer

    prusa-slicer

    vlc

    zoom-us

    # games
    openttd-jgrpp
  ];

  # allow fontconfig to discover fonts and configurations installed through home.packages
  # Install fonts at system-level, not user-level
  fonts.fontconfig.enable = false;
}
