{
  pkgs,
  isDesktop ? false,  # Add the parameter with default value
  ...
}: {
  home.packages = with pkgs; ([
    # archives
    zip
    xz
    unzip
    p7zip
    
    ncdu # disk usage
    cloc

    openssl

    # creative
    inkscape
    gimp3

    prusa-slicer

    # pcb stuff
    kicad

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
    pulseaudio
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
  ] 
  # Desktop-only packages
  ++ pkgs.lib.optionals isDesktop [
    vcv-rack
    freecad

    # (blender.override {
    #   cudaSupport = true;
    # })

    cudaPackages.cudatoolkit
  ]);

  # allow fontconfig to discover fonts and configurations installed through home.packages
  # Install fonts at system-level, not user-level
  fonts.fontconfig.enable = false;
}
