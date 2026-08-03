{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    gnupg
    rustup
    ripgrep
    devenv
    vit
    postgresql
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

      # files symlinked from the source repo into every new worktree, since a
      # worktree only gets git-tracked files by default (fixes local Claude
      # permissions / .env not carrying over)
      WT_CARRY_FILES=(".claude/settings.local.json" ".envrc" ".env")

      # sentinel branch name representing your primary $REPOS_DIR checkouts
      # (e.g. main), shown in the picker alongside real worktrees
      WT_PRIMARY_LABEL="[primary]"

      _wt_resolve_path() {
        local repo="$1" branch="$2"
        if [[ "$branch" == "$WT_PRIMARY_LABEL" ]]; then
          echo "$REPOS_DIR/$repo"
        else
          echo "$WORK_DIR/worktrees/$repo/$branch"
        fi
      }

      # one tmux session per (repo, branch) worktree
      _wt_session_name() { echo "wt-$1-$2"; }

      _wt_carry_files() {
        local src="$1" dst="$2" f
        for f in "''${WT_CARRY_FILES[@]}"; do
          [[ -e "$src/$f" ]] || continue
          [[ -e "$dst/$f" ]] && continue
          mkdir -p "$(dirname "$dst/$f")"
          ln -s "$src/$f" "$dst/$f"
        done
      }

      _wt_default_branch() {
        local src="$1" ref
        ref=$(git -C "$src" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)
        ref="''${ref#origin/}"
        echo "''${ref:-main}"
      }

      _wt_gh_pr_branch() {
        local src="$1" number="$2"
        (cd "$src" && gh pr view "$number" --json headRefName -q .headRefName 2>/dev/null)
      }

      # open the branch's PR in the browser, or the "create PR" page if none exists yet
      _wt_pr_open() {
        local src="$1" branch="$2"
        if (cd "$src" && gh pr view "$branch" --web >/dev/null 2>&1); then
          echo "Opened PR for $branch"
        else
          echo "No PR for $branch yet -- opening new PR page"
          (cd "$src" && gh pr create --web --head "$branch")
        fi
      }

      # outputs "<status>\t<author-login>" for the branch's PR, or nothing if none
      _wt_pr_status() {
        local src="$1" branch="$2"
        (cd "$src" && gh pr list --head "$branch" --state all --limit 1 \
          --json state,isDraft,reviewDecision,author \
          -q 'if length == 0 then empty else
                .[0] | (if .state=="MERGED" then "merged"
                        elif .state=="CLOSED" then "closed"
                        elif .isDraft then "draft"
                        elif .reviewDecision=="APPROVED" then "approved"
                        elif .reviewDecision=="CHANGES_REQUESTED" then "changes"
                        else "open" end) + "\t" + .author.login
              end') 2>/dev/null
      }

      _wt_create() {
        local src="$1" branch="$2"
        local repo dst base
        repo=$(basename "$src")
        dst="$WORK_DIR/worktrees/$repo/''${branch//\//-}"
        mkdir -p "$(dirname "$dst")"
        base=$(_wt_default_branch "$src")
        if ! git -C "$src" fetch --quiet origin; then
          echo "Warning: fetch failed, branch/base refs may be stale" >&2
        fi

        if git -C "$src" show-ref --verify --quiet "refs/heads/$branch"; then
          # local branch already exists (e.g. recreating a removed worktree) -- reuse as-is
          git -C "$src" worktree add "$dst" "$branch" || { echo "Failed to create worktree"; return 1; }
          echo "Worktree ready: $dst (existing local branch)"
        elif git -C "$src" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
          # branch already exists on the remote -- track it instead of
          # branching fresh off base, or you'd silently lose its commits
          git -C "$src" worktree add -b "$branch" --track "$dst" "origin/$branch" || { echo "Failed to create worktree"; return 1; }
          echo "Worktree ready: $dst (tracking origin/$branch)"
        else
          git -C "$src" worktree add --no-track -b "$branch" "$dst" "origin/$base" || { echo "Failed to create worktree"; return 1; }
          echo "Worktree ready: $dst (branched from origin/$base)"
        fi
        _wt_carry_files "$src" "$dst"
      }

      # open (or attach to) a tmux session for one (repo, branch) worktree --
      # one window per program, so vim and the agent never share a window
      # and switching between them never kills either's state
      _wt_open() {
        local repo="$1" branch="$2" wt_path="$3" prog="$4"
        local session window dead
        session=$(_wt_session_name "$repo" "$branch")
        window="$prog"

        if ! tmux has-session -t "$session" 2>/dev/null; then
          tmux new-session -d -s "$session" -n "$window" -c "$wt_path" "$prog"
          # otherwise tmux kills the whole session the moment this program
          # exits (it's the only window), so "resuming" later just recreates it
          tmux set-window-option -t "''${session}:''${window}" remain-on-exit on
        elif ! tmux list-windows -t "$session" -F '#W' 2>/dev/null | grep -qx "$window"; then
          tmux new-window -t "$session" -n "$window" -c "$wt_path" "$prog"
          tmux set-window-option -t "''${session}:''${window}" remain-on-exit on
        else
          # window already exists for this exact program -- only respawn if
          # it died (remain-on-exit) since you quit it; otherwise just reattach
          dead=$(tmux list-panes -t "''${session}:''${window}" -F '#{pane_dead}' 2>/dev/null | head -1)
          [[ "$dead" == "1" ]] && tmux respawn-window -k -t "''${session}:''${window}" -c "$wt_path" "$prog"
        fi

        if [[ -n "$TMUX" ]]; then
          tmux switch-client -t "''${session}:''${window}"
        else
          tmux attach -t "''${session}:''${window}"
        fi
      }

      wt() {
        _wt_menu
      }

      wcd() {
        local wt_base="$WORK_DIR/worktrees"
        [[ -d "$wt_base" ]] || { echo "No worktrees found."; return 1; }
        local target
        target=$(find "$wt_base" -mindepth 2 -maxdepth 2 -type d | fzf --query="''${1:-}")
        [[ -n "$target" ]] && cd "$target"
      }

      # --- interactive picker ---

      _wt_menu_emit_row() {
        local repo="$1" branch="$2" checkout_dir="$3" pr_status="$4" dirty marker session display
        dirty=""
        git -C "$checkout_dir" diff --quiet 2>/dev/null || dirty+="●"
        git -C "$checkout_dir" diff --cached --quiet 2>/dev/null || dirty+="◆"
        marker=""
        session=$(_wt_session_name "$repo" "$branch")
        tmux has-session -t "$session" 2>/dev/null && marker="[tmux]"
        # fixed-width columns for display; real repo/branch travel as
        # separate hidden fields so padding never corrupts the actual values
        display=$(printf '%-16.16s %-22.22s %-4s %-22.22s %s' "$repo" "$branch" "$dirty" "$pr_status" "$marker")
        printf '%s\t%s\t%s\n' "$display" "$repo" "$branch"
      }

      _wt_menu_rows() {
        local wt_base="$WORK_DIR/worktrees"
        local repo_dir repo branch_dir branch tmpdir me raw pr_state pr_author pr_status

        [[ -d "$REPOS_DIR" ]] || return 0
        tmpdir=$(mktemp -d)

        # fetch every branch's PR status (and who I am) in parallel first --
        # one gh call per branch, run concurrently, or this takes several
        # seconds serially
        gh api user -q .login > "$tmpdir/__me" 2>/dev/null &
        for repo_dir in "$REPOS_DIR"/*/; do
          { [[ -d "$repo_dir/.git" ]] || [[ -f "$repo_dir/.git" ]]; } || continue
          repo=$(basename "$repo_dir")
          [[ -d "$wt_base/$repo" ]] || continue
          for branch_dir in "$wt_base/$repo"/*/; do
            { [[ -d "$branch_dir/.git" ]] || [[ -f "$branch_dir/.git" ]]; } || continue
            branch=$(basename "$branch_dir")
            _wt_pr_status "$repo_dir" "$branch" > "$tmpdir/''${repo}__''${branch}" &
          done
        done
        wait
        me=$(<"$tmpdir/__me")

        for repo_dir in "$REPOS_DIR"/*/; do
          { [[ -d "$repo_dir/.git" ]] || [[ -f "$repo_dir/.git" ]]; } || continue
          repo=$(basename "$repo_dir")

          _wt_menu_emit_row "$repo" "$WT_PRIMARY_LABEL" "$repo_dir" ""

          [[ -d "$wt_base/$repo" ]] || continue
          for branch_dir in "$wt_base/$repo"/*/; do
            { [[ -d "$branch_dir/.git" ]] || [[ -f "$branch_dir/.git" ]]; } || continue
            branch=$(basename "$branch_dir")
            raw=$(<"$tmpdir/''${repo}__''${branch}")
            pr_status=""
            if [[ -n "$raw" ]]; then
              IFS=$'\t' read -r pr_state pr_author <<< "$raw"
              if [[ -n "$me" && "$pr_author" != "$me" ]]; then
                pr_status="$pr_state ($pr_author)"
              else
                pr_status="$pr_state"
              fi
            fi
            _wt_menu_emit_row "$repo" "$branch" "$branch_dir" "$pr_status"
          done
        done
        rm -rf "$tmpdir"
      }

      _wt_menu_new() {
        [[ -d "$REPOS_DIR" ]] || { echo "\$REPOS_DIR not found ($REPOS_DIR)"; return 1; }
        local src repo branch result query selection pr_number resolved
        src=$(find "$REPOS_DIR" -mindepth 1 -maxdepth 1 -type d | fzf --prompt="repo> ") || return
        [[ -n "$src" ]] || return
        repo=$(basename "$src")
        git -C "$src" fetch --quiet origin
        # pick an existing local/remote branch, type a new name, or enter a PR number
        # (alt-enter forces your typed text even if it fuzzy-matches something else)
        result=$( { git -C "$src" branch --format='%(refname:short)'
                    git -C "$src" branch -r --format='%(refname:short)' | grep -v '/HEAD$' | sed 's#^origin/##'
                  } | sort -u | fzf --prompt="branch (existing, new, or PR #; alt-enter=exact)> " \
                        --print-query --bind 'alt-enter:print-query')
        query=$(printf '%s\n' "$result" | sed -n 1p)
        selection=$(printf '%s\n' "$result" | sed -n 2p)
        branch="''${selection:-$query}"
        [[ -n "$branch" ]] || return

        if [[ "$branch" =~ ^[0-9]+$ ]]; then
          pr_number="$branch"
          resolved=$(_wt_gh_pr_branch "$src" "$pr_number")
          [[ -n "$resolved" ]] || { echo "Could not find PR #$pr_number"; return 1; }
          # fetch the PR's commits directly via GitHub's pull ref -- works
          # for same-repo and fork PRs alike, unlike fetching by branch name
          git -C "$src" fetch --quiet origin "+refs/pull/$pr_number/head:$resolved"
          echo "PR #$pr_number -> $resolved"
          branch="$resolved"
        fi

        _wt_create "$src" "$branch" || return
        _wt_open "$repo" "''${branch//\//-}" "$WORK_DIR/worktrees/$repo/''${branch//\//-}" vim
      }

      _wt_menu_rm() {
        local repo="$1" branch="$2" wt_path="$3" session
        read -q "REPLY?Remove ''${repo}/''${branch}? [y/N] "
        echo
        [[ "$REPLY" == [Yy] ]] || return
        session=$(_wt_session_name "$repo" "$branch")
        tmux kill-session -t "$session" 2>/dev/null
        git -C "$wt_path" worktree remove "$wt_path" --force && echo "Removed $wt_path" || echo "Failed to remove $wt_path"
        rmdir "$WORK_DIR/worktrees/$repo" 2>/dev/null
      }

      _wt_menu() {
        local rows result key line
        rows=$(_wt_menu_rows)
        result=$(printf '%s\n' "$rows" | fzf \
          --delimiter=$'\t' --with-nth=1 \
          --header="enter: vim   ctrl-a: agent   ctrl-g: lazygit   ctrl-o: open PR   ctrl-n: new worktree   ctrl-d: remove" \
          --expect=ctrl-a,ctrl-g,ctrl-o,ctrl-n,ctrl-d)
        key=$(printf '%s\n' "$result" | sed -n 1p)
        line=$(printf '%s\n' "$result" | sed -n 2p)

        [[ "$key" == "ctrl-n" ]] && { _wt_menu_new; return; }
        [[ -n "$line" ]] || return

        local display repo branch wt_path
        IFS=$'\t' read -r display repo branch <<< "$line"
        wt_path=$(_wt_resolve_path "$repo" "$branch")

        if [[ "$branch" == "$WT_PRIMARY_LABEL" ]] && [[ "$key" == "ctrl-o" || "$key" == "ctrl-d" ]]; then
          echo "$key isn't available on $WT_PRIMARY_LABEL checkouts"
          _wt_menu
          return
        fi

        case "$key" in
          ctrl-a) _wt_open "$repo" "$branch" "$wt_path" claude ;;
          ctrl-g) _wt_open "$repo" "$branch" "$wt_path" lazygit ;;
          ctrl-o) _wt_pr_open "$wt_path" "$branch"; _wt_menu ;;
          ctrl-d) _wt_menu_rm "$repo" "$branch" "$wt_path"; _wt_menu ;;
          *)      _wt_open "$repo" "$branch" "$wt_path" vim ;;
        esac
      }

      wthelp() {
        echo "wt                  interactive picker: enter=vim, ctrl-a=agent, ctrl-g=lazygit, ctrl-o=open PR, ctrl-n=new, ctrl-d=remove"
        echo "wcd [query]         fzf-pick a worktree to cd into"
        echo
        echo "ctrl-n's branch prompt also accepts a bare PR number to check that PR out"
        echo "layout: \$WORK_DIR/worktrees/<repo>/<branch>"
        echo "new worktrees auto-symlink: ''${WT_CARRY_FILES[*]}"
      }
    '';
  };
}
