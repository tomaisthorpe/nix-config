{
  pkgs,
  ...
}:
{
  imports = [
    ./packages.nix
  ];

  programs = {
    neovim = {
      enable = true;

      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };

  # Just using normal nvim config
  home.file.".config/nvim" = {
    source = ./config;
    recursive = true;
  };
}
