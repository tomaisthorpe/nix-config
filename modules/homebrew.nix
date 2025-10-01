{
  pkgs,
  ...
}:
{
  homebrew = {
    enable = true;
    brews = [
      "lazygit"
      "pinentry-mac"
    ];

    taps = [
      "nikitabobko/tap"
    ];

    casks = [
      "spotify"
      "ghostty"
      "slack"
      "aerospace"
    ];
  };

  fonts.packages = with pkgs; [
    # icon fonts
    material-design-icons
    font-awesome

    nerd-fonts.symbols-only
    nerd-fonts.iosevka
    nerd-fonts.hack

    julia-mono
    dejavu_fonts
  ];
}
