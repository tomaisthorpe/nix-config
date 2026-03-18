{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    gnupg
    rustup
    ripgrep
    devenv
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
      export LIBRARY_PATH="$(brew --prefix)/lib:$LIBRARY_PATH"
      export PKG_CONFIG_PATH="$(brew --prefix)/lib/pkgconfig:$PKG_CONFIG_PATH"
      export LIBRARY_PATH="/opt/homebrew/opt/libiconv/lib:$LIBRARY_PATH"
      export PKG_CONFIG_PATH="/opt/homebrew/opt/libiconv/lib/pkgconfig:$PKG_CONFIG_PATH"
      export LDFLAGS="-L/opt/homebrew/opt/libiconv/lib"
      export PATH="$HOME/.local/bin:$PATH"

gcb() {
  local repo=$1
  local name=''${2:-$(basename "$repo" .git)}
  git clone --bare "$repo" ~/dev/"$name"
}

gwa() {
  git worktree add "$1" "''${2:-origin/$1}"
}

gwcd() {
  local root=$(git worktree list | head -1 | awk '{print $1}')
  cd "$root/$1"
}
      '';
  };
}
