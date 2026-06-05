{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    gnupg
    rustup
    ripgrep
    devenv
  ];

  programs.starship = {
    enable = true;
    settings = {
      directory.truncation_length = 2;
    };
  };

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


      export PYENV_ROOT="$HOME/.pyenv"
      [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
      eval "$(pyenv init - zsh)"

      export WORK_DIR="$HOME/work"
      export REPOS_DIR="$WORK_DIR/repos"

      _wt_find_root() {
        local dir="$PWD"
        while [[ "$dir" != "/" ]]; do
          [[ "$(dirname "$dir")" == "$WORK_DIR/worktrees" ]] && echo "$dir" && return 0
          dir="$(dirname "$dir")"
        done
        return 1
      }

      wt() {
        [[ $# -ne 1 ]] && { echo "Usage: wt <branch>"; return 1; }
        local branch="$1"
        local src
        src=$(git rev-parse --show-toplevel 2>/dev/null)
        if [[ -z "$src" ]]; then
          [[ -d "$REPOS_DIR" ]] || { echo "Not in a git repo and \$REPOS_DIR not found ($REPOS_DIR)"; return 1; }
          src=$(find "$REPOS_DIR" -mindepth 1 -maxdepth 1 -type d | fzf --prompt="repo> ") || return 1
          [[ -n "$src" ]] || return 1
        fi
        local repo dst
        repo=$(basename "$src")
        dst="$WORK_DIR/worktrees/''${branch//\//-}/$repo"
        mkdir -p "$(dirname "$dst")"
        git -C "$src" fetch --quiet origin
        git -C "$src" worktree add --no-track -b "$branch" "$dst" "origin/main" 2>/dev/null \
          || git -C "$src" worktree add "$dst" "$branch" 2>/dev/null \
          || { echo "Failed to create worktree"; return 1; }
        echo "Worktree ready: $dst"
        cd "$dst"
      }

      wtrm() {
        [[ $# -ne 1 ]] && { echo "Usage: wtrm <branch>"; return 1; }
        local branch="$1"
        local repo
        repo=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)") || { echo "Not in a git repo"; return 1; }
        local wt_dir="$WORK_DIR/worktrees/''${branch//\//-}"
        git worktree remove "$wt_dir/$repo" --force && echo "Removed $wt_dir/$repo" || echo "Failed"
        rmdir "$wt_dir" 2>/dev/null
      }

      wts() {
        local wt_base="$WORK_DIR/worktrees"
        [[ -d "$wt_base" ]] || { echo "No worktrees found."; return 0; }
        for wt_dir in "$wt_base"/*/; do
          echo "━━ $(basename "$wt_dir") ━━"
          for repo_dir in "$wt_dir"/*/; do
            [[ -d "$repo_dir/.git" ]] || [[ -f "$repo_dir/.git" ]] || continue
            local branch dirty=""
            branch=$(git -C "$repo_dir" branch --show-current 2>/dev/null)
            git -C "$repo_dir" diff --quiet 2>/dev/null || dirty=" ●"
            git -C "$repo_dir" diff --cached --quiet 2>/dev/null || dirty+=" ◆"
            echo "  $(basename "$repo_dir")  [$branch]$dirty"
          done
          echo
        done
      }

      wcd() {
        local wt_base="$WORK_DIR/worktrees"
        [[ -d "$wt_base" ]] || { echo "No worktrees found."; return 1; }
        local target
        target=$(find "$wt_base" -mindepth 2 -maxdepth 2 -type d | fzf --query="''${1:-}")
        [[ -n "$target" ]] && cd "$target"
      }

      gw() {
        [[ $# -lt 1 ]] && { echo "Usage: gw <command> [args...]"; return 1; }
        local wt_root
        wt_root=$(_wt_find_root) || { echo "Not inside a worktree ($WORK_DIR/worktrees/<branch>/...)"; return 1; }
        for repo_dir in "$wt_root"/*/; do
          [[ -d "$repo_dir/.git" ]] || [[ -f "$repo_dir/.git" ]] || continue
          echo "── $(basename "$repo_dir") ──"
          (cd "$repo_dir" && "$@")
          echo
        done
      }

      wthelp() {
        echo "wt <branch>        create a worktree for the current repo and cd into it (fzf-picks from \$REPOS_DIR if not in a repo)"
        echo "wtrm <branch>      remove the worktree for the current repo on that branch"
        echo "wts                list all worktree sets with branch and dirty status"
        echo "wcd [query]        fzf-pick a worktree to cd into"
        echo "gw <cmd> [args]    run a command in every repo in the current worktree set"
      }
    '';
  };
}
