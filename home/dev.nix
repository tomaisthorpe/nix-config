{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    cmake
    gnumake

    gcc
    llvmPackages.clang-unwrapped

    # Javascript
    nodePackages.nodejs
    nodePackages.yarn
    # nodePackages.typescript
    # nodePackages.typescript-language-server

    tree-sitter
    # nodePackages.prettier
    nixfmt

    kubectl
    kubectx
    krew
    k9s
    kind
    tilt
    ctlptl

    postgresql

    go

    rustup
    probe-rs-tools
    openocd

    python3

    go-task
    sops

    elixir

    pipenv
    ripgrep

    code-cursor

    yaak

    devenv
    flyctl
    lazygit
  ];

  home.sessionPath = [
    "/home/tom/.cargo/bin"
  ];
}
