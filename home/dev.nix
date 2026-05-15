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
    nodejs
    yarn
    # typescript
    # typescript-language-server

    tree-sitter
    # prettier
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
    opencode

    yaak

    devenv
    flyctl
    lazygit
  ];

  home.sessionPath = [
    "/home/tom/.cargo/bin"
  ];
}
