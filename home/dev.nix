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
    krew
    k9s
    kind
    tilt
    ctlptl

    postgresql

    go

    rustup
    probe-rs
    openocd

    python3

    go-task
    sops

    elixir

    pipenv
    ripgrep

    zed-editor
    code-cursor

    yaak

    devenv
    asdf-vm
    mise
    micromamba
    flyctl

    (ollama.overrideAttrs (oldAttrs: {
      enableCuda = true;
    }))
  ];

  home.sessionPath = [
    "/home/tom/.cargo/bin"
  ];
}
