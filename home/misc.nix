{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # creative
    inkscape
    pureref

    (blender.override {
      cudaSupport = true;
    })

    prusa-slicer

    # pcb stuff
    kicad
    freecad

    # messaging
    telegram-desktop
    discord
    signal-desktop

    # devtools
    ripgrep

    # notes
    obsidian

    # misc
    flameshot
    pavucontrol
    pulsemixer
    spotify

    kdePackages.okular
    vlc

    zoom-us

    # games
    openttd-jgrpp

    appimage-run
    geeqie
    inotify-tools
  ];

  # allow fontconfig to discover fonts and configurations installed through home.packages
  # Install fonts at system-level, not user-level
  fonts.fontconfig.enable = false;
}
