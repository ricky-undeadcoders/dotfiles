# Shell Functions
# Sourced from ~/.zshrc

# Git: reset to default branch, prune, clean up merged branches
gitr () {
    branch=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
    echo "git fetch -p"
    git fetch -p
    echo "git checkout $branch"
    git checkout $branch
    echo "git pull origin $branch"
    git pull origin $branch
    echo "Cleaning up merged branches..."
    git branch -vv | grep ": gone]" | awk '{print $1}' | xargs -I {} bash -c "git branch -D {}"
}

# Git: create a new branch with your prefix
new-branch () {
    if [ -z "$1" ]; then
        echo "Usage: new-branch <branch-suffix>"
        return 1
    fi
    git checkout -b rwhitaker/$1
}

# Git: cd to repo root
git-root () {
    git rev-parse --show-toplevel
}

cdgr () {
    cd $(git-root)
}

# Git: quick PR workflow
create-pr () {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: create-pr <branch-suffix> <commit-message>"
        return 1
    fi
    cdgr
    gitr
    git diff && git status
    echo -n "Would you like to continue? "
    read CONFIRM
    if [[ "$CONFIRM" != [yY] ]]; then
        echo "Aborted."
        return 1
    fi
    new-branch $1
    git add -A && git status
    git commit -m $2
    git push -u origin rwhitaker/$1 --no-verify
    gh pr create --web
}

# Temp directory management
temp-dir () {
    mkdir ~/tmp/$1-$(date +%Y%m%d)
    cd ~/tmp/$1-$(date +%Y%m%d)
}

rm-temp-dir () {
    CURRENT_DIR=$(pwd)
    DIR_NAME=$(basename "$CURRENT_DIR")
    cd .. || { echo "Failed to cd .."; return 1; }
    PARENT_DIR=$(pwd)
    TMP_DIR="$HOME/tmp"

    if [[ "$PARENT_DIR" != "$TMP_DIR" ]]; then
        echo "Error: Not inside $TMP_DIR. Aborting."
        return 1
    fi

    if [ -n "$(ls -A "$DIR_NAME")" ]; then
        echo -n "Directory '$DIR_NAME' is not empty. Delete? (y/N): "
        read CONFIRM
        if [[ "$CONFIRM" != [yY] ]]; then
            cd $DIR_NAME
            echo "Aborted."
            return 1
        fi
    fi

    rm -rf "$DIR_NAME"
    echo "Removed '$DIR_NAME'."
}

# Go: format + lint + tidy
gf () {
    echo "gofmt -w ."
    gofmt -w .
    echo "golangci-lint run -v"
    golangci-lint run -v
    echo "go mod tidy"
    go mod tidy
}

# Terraform: nuke state and reinit
tfreinit () {
    rm -rf .terraform*
    terraform init
    terraform plan
}

# Print date before running a command
d () {
    date && $@
}

# Switch system python version (via uv)
# Usage: pyuse 3.12
pyuse () {
    local ver="${1:?Usage: pyuse <version> (e.g. pyuse 3.12)}"
    local py_dir=$(find ~/.local/share/uv/python -maxdepth 1 -name "cpython-${ver}*" -type d 2>/dev/null | sort -V | tail -1)

    if [ -z "$py_dir" ]; then
        echo "Installing Python $ver via uv..."
        uv python install "$ver"
        py_dir=$(find ~/.local/share/uv/python -maxdepth 1 -name "cpython-${ver}*" -type d 2>/dev/null | sort -V | tail -1)
    fi

    if [ -z "$py_dir" ]; then
        echo "Error: failed to install Python $ver" >&2
        return 1
    fi

    mkdir -p ~/bin
    ln -sf "$py_dir/bin/python${ver}" ~/bin/python3
    ln -sf ~/bin/python3 ~/bin/python
    ln -sf "$py_dir/bin/pip${ver}" ~/bin/pip3
    ln -sf ~/bin/pip3 ~/bin/pip
    echo "${ver}" > ~/.python-version
    echo "System python: $(~/bin/python3 --version)"
}

MUX_PROJECTS_FILE="${MUX_PROJECTS_FILE:-$HOME/.mux_projects}"

# Record dir as MRU (newest top, deduped)
_mux_record () {
    local dir="$1"
    [ -z "$dir" ] && return
    local tmp
    tmp="$(mktemp)" || return
    {
        printf '%s\n' "$dir"
        [ -f "$MUX_PROJECTS_FILE" ] && grep -vxF "$dir" "$MUX_PROJECTS_FILE"
    } > "$tmp" && mv "$tmp" "$MUX_PROJECTS_FILE"
}

# Workspace launcher
# Usage:
#   mux                  → create/attach session for current directory
#   mux ~/code/my-repo   → create/attach session for that directory
#   mux my-session       → attach to existing tmux session by name
#   muxr [target]        → same as mux, but claude window runs `claude --resume`
#   muxp                 → fzf picker over saved projects, cd + mux
mux () {
    local claude_cmd="${MUX_CLAUDE_CMD:-claude}"
    local target="${1:-.}"

    # If arg matches an existing tmux session (and isn't a directory), attach
    if [ "$target" != "." ] && [ ! -d "$target" ] && tmux has-session -t "=$target" 2>/dev/null; then
        if [ -n "$TMUX" ]; then
            tmux switch-client -t "=$target"
        else
            tmux attach-session -t "=$target"
        fi
        return
    fi

    # Resolve to absolute path
    local dir
    dir="$(cd "$target" 2>/dev/null && pwd)" || {
        echo "Error: '$target' is not a directory or existing session" >&2
        return 1
    }

    # Derive session name from directory basename
    local name="$(basename "$dir")"
    name="${name//./-}"
    name="${name// /-}"

    # Attach if session already exists; otherwise create detached then attach/switch
    if ! tmux has-session -t "=$name" 2>/dev/null; then
        tmux new-session -d -s "$name" -c "$dir" -n shell
        tmux new-window -t "$name:" -c "$dir" -n claude "$claude_cmd"
        tmux select-window -t "$name:1"
    fi

    _mux_record "$dir"

    if [ -n "$TMUX" ]; then
        tmux switch-client -t "=$name"
    else
        tmux attach-session -t "=$name"
    fi
}

muxr () {
    MUX_CLAUDE_CMD="claude --resume" mux "$@"
}

muxp () {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "fzf not installed. Run: brew install fzf" >&2
        return 1
    fi
    if [ ! -s "$MUX_PROJECTS_FILE" ]; then
        echo "No projects yet. Run 'mux' in a directory first." >&2
        return 1
    fi

    local dir
    dir="$(grep -v '^$' "$MUX_PROJECTS_FILE" | fzf --prompt='mux> ' --height=40% --reverse)"
    [ -z "$dir" ] && return 0

    if [ ! -d "$dir" ]; then
        echo "Dir gone: $dir" >&2
        return 1
    fi

    cd "$dir" && mux
}
