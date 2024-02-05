{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    rofi
    polybar

    dunst # notification daemon
    i3lock # i3 screen locker
    xautolock # lock after time
    xsel # clipboard manager

    acpi # battery info
    arandr # xrandr gui
    xbindkeys # bind keys to commmands
    xorg.xbacklight # backlight control
    scrot # screen capture tool used by i3 block lock
    alsa-utils # amixer/alsamixer/etc
    playerctl # media player control
  ];
}