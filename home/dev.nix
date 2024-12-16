{
  pkgs,
  ...
}: {
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
    nodePackages.prettier

    kubectl
    kubectx
    k9s
    kind
    tilt
    ctlptl

    postgresql

    rustup
    probe-rs

    python3
    
    go-task
    sops

    elixir

    pipenv
  ];
}
