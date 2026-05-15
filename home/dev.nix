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

    tree-sitter
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

    yaak

    devenv
    flyctl
    lazygit
  ];

  home.sessionPath = [
    "/home/tom/.cargo/bin"
  ];
}
