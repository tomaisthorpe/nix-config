{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    gnupg
  ];

  programs.zsh = {
    enable = true;
    history.size = 10000;

    oh-my-zsh = { 
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };

    shellAliases = {
      j = "z";
      gap = "git add --patch .";
    };
  };
}
