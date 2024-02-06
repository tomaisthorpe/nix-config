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
    nodePackages.typescript
    nodePackages.typescript-language-server

    tree-sitter
    nodePackages.prettier
  ];
}
