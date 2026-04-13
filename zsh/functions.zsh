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

# Workspace launcher
# Usage:
#   mux                  → create/attach session for current directory
#   mux ~/code/my-repo   → create/attach session for that directory
#   mux my-project       → attach to existing session by name
mux () {
    local TEMPLATE="$HOME/code/dotfiles/tmuxinator/example.yml"
    local target="${1:-.}"

    # If arg matches an existing tmuxinator session by name, just start it
    if [ "$target" != "." ] && [ -f "$HOME/.tmuxinator/${target}.yml" ] && [ ! -d "$target" ]; then
        cd "$(grep '^root:' "$HOME/.tmuxinator/${target}.yml" | awk '{print $2}')" 2>/dev/null
        tmuxinator start "$target"
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

    # If tmuxinator config already exists, just start it
    local yml="$HOME/.tmuxinator/${name}.yml"
    if [ -f "$yml" ]; then
        cd "$dir"
        tmuxinator start "$name"
        return
    fi

    # Generate config from template
    if [ ! -f "$TEMPLATE" ]; then
        echo "Error: template not found at $TEMPLATE" >&2
        return 1
    fi

    mkdir -p "$HOME/.tmuxinator"

    sed \
        -e "s|<%= @settings\[\"name\"\] %>|${name}|g" \
        -e "s|<%= @settings\[\"root\"\] %>|${dir}|g" \
        "$TEMPLATE" > "$yml"

    echo "Created session: $name ($dir)"
    cd "$dir"
    tmuxinator start "$name"
}
