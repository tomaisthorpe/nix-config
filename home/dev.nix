{
  pkgs,
  ...
}:
let
  yaakWithDmaBufWorkaround = pkgs.yaak.overrideAttrs (_oldAttrs: {
    postFixup = ''
      wrapProgram $out/bin/yaak-app \
        --inherit-argv0 \
        --set-default __NV_DISABLE_EXPLICIT_SYNC 1 \
        --set-default WEBKIT_DISABLE_DMABUF_RENDERER 1
    '';
  });
in
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

    yaakWithDmaBufWorkaround

    devenv
    flyctl
    lazygit
  ];

  home.sessionPath = [
    "/home/tom/.cargo/bin"
  ];
}
