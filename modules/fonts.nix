{ pkgs, ... }:
{
  # all fonts are linked to /nix/var/nix/profiles/system/sw/share/X11/fonts
  fonts = {
    # use fonts specified by user rather than default ones
    fontDir.enable = true;

    packages = with pkgs; [
      # icon fonts
      material-design-icons
      font-awesome

      nerd-fonts.symbols-only
      nerd-fonts.iosevka
      nerd-fonts.hack

      julia-mono
      dejavu_fonts
      google-fonts
    ];
  };
}
