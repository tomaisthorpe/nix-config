{
  config,
  pkgs,
  ...
}:
{
  homebrew = {
    enable = true;
    brews = [
      "buf"
      "ctlptl"
      "deno"
      "dive"
      "flyctl"
      "gh"
      "git-lfs"
      "go"
      "graphviz"
      "helm"
      "k9s"
      "lazygit"
      "libiconv"
      "nvm"
      "pinentry-mac"
      "pipx"
      "protobuf"
      "pyenv"
      "qemu"
      "tfenv"
      "tilt"
      "yq"
    ];

    casks = [
      "docker/tap/sbx"
      "ghostty"
      "slack"
      "spotify"
    ];

    taps = builtins.attrNames config.nix-homebrew.taps;
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
