{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # creative
    # inkscape

    # (blender.override {
    #   cudaSupport = true;
    # })

    vcv-rack

    prusa-slicer

    # pcb stuff
    kicad
    freecad

    # messaging
    telegram-desktop
    discord
    signal-desktop

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
