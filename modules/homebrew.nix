{
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
      "k6"
      "k9s"
      "lazygit"
      "libiconv"
      "nvm"
      "pinentry-mac"
      "pipx"
      "podman"
      "protobuf"
      "pyenv"
      "qemu"
      "taskwarrior-tui"
      "tfenv"
      "tilt"
      "yq"
      "zig"
    ];

    casks = [
      "aerospace"
      "ghostty"
      "slack"
      "spotify"
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
