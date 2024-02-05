{pkgs, ...}: {
  # all fonts are linked to /nix/var/nix/profiles/system/sw/share/X11/fonts
  fonts = {
    # use fonts specified by user rather than default ones
    fontDir.enable = true;

    packages = with pkgs; [
      # icon fonts
      material-design-icons
      font-awesome

      # nerdfonts
      # https://github.com/NixOS/nixpkgs/blob/nixos-23.11/pkgs/data/fonts/nerdfonts/shas.nix
      (nerdfonts.override {
        fonts = [
          # symbols icon only
          "NerdFontsSymbolsOnly"
          # Characters
          "Hack"
          "Iosevka"
        ];
      })
      julia-mono
      dejavu_fonts
    ];
  };
}