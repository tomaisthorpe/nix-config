{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    gnupg
    rustup
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

    initContent = ''
      export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    '';
  };
}
