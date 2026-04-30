#!/usr/bin/env bash
# Terminal Command Center - Machine Setup
# Run once on a new computer to install all dependencies.
# Safe to re-run — skips anything already installed.
#
# Usage:
#   ./setup.sh

set -euo pipefail

# ========================================
# What gets installed (edit these lists)
# ========================================

FORMULAE=(
    # Core
    git gh jq yq wget htop watch coreutils lazygit

    # Terminal
    tmux tmuxinator neovim glow ripgrep fd

    # Languages
    go node deno uv

    # Kubernetes & Infrastructure
    kubernetes-cli kubectx k9s jsonnet-bundler go-jsonnet kompose

    # Cloud CLIs
    azure-cli

    # IaC
    terraform packer

    # Containers
    dive

    # Data
    duckdb fx

    # Argo
    argo

    # Linting & Security
    shellcheck actionlint golangci-lint trufflehog zizmor
    markdownlint-cli2 prettier

    # Fun
    fortune cowsay
)

CASKS=(
    1password 1password-cli
    claude-code
    docker
    firefox
    font-jetbrains-mono-nerd-font
    ghostty
    maccy
    rectangle
    slack
    spotify
    tailscale
    zoom
)

# ========================================
# Helpers
# ========================================

BOLD=$(tput bold 2>/dev/null || true)
GREEN=$(tput setaf 2 2>/dev/null || true)
YELLOW=$(tput setaf 3 2>/dev/null || true)
RED=$(tput setaf 1 2>/dev/null || true)
RESET=$(tput sgr0 2>/dev/null || true)

info()  { echo "${GREEN}[ok]${RESET}    $*"; }
warn()  { echo "${YELLOW}[warn]${RESET}  $*"; }
err()   { echo "${RED}[error]${RESET} $*"; }
header(){ echo ""; echo "${BOLD}$*${RESET}"; }

# ----------------------------------------
# Homebrew
# ----------------------------------------
if ! command -v brew &>/dev/null; then
    header "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

header "Installing brew formulae"

for pkg in "${FORMULAE[@]}"; do
    if brew list "$pkg" &>/dev/null; then
        info "$pkg"
    else
        echo "  Installing $pkg..."
        brew install "$pkg" || warn "$pkg failed to install"
        info "$pkg installed"
    fi
done

header "Installing brew casks"

for cask in "${CASKS[@]}"; do
    if brew list --cask "$cask" &>/dev/null; then
        info "$cask"
    else
        echo "  Installing $cask..."
        brew install --cask "$cask" || warn "$cask failed (may already exist outside Homebrew)"
    fi
done

# ----------------------------------------
# Todolist (personal tool — gitlab.com/ricky-undeadcoders/tools)
# ----------------------------------------
header "Installing todolist"

TOOLS_DIR="$HOME/code/tools"
if [ -d "$TOOLS_DIR/.git" ]; then
    info "tools repo already cloned at $TOOLS_DIR"
else
    git clone https://gitlab.com/ricky-undeadcoders/tools.git "$TOOLS_DIR"
    info "Cloned tools repo"
fi

# local.env must exist before the deployment script runs (it reads from it).
LOCAL_ENV="$HOME/var/todolist/local.env"
if [ ! -f "$LOCAL_ENV" ]; then
    warn "$LOCAL_ENV missing — restore from 1Password before running todolist deploy:"
    warn "  op document get 'todolist-local-env' --vault Private --account my.1password.com --output $LOCAL_ENV"
    warn "Skipping todolist venv deployment."
elif compgen -G "$HOME/srv/todolist*-venv" > /dev/null; then
    info "todolist venv already deployed"
else
    (cd "$TOOLS_DIR/deployment_scripts" && bash todolist-venv-deployment.sh)
    info "todolist venv deployed"
fi

# ----------------------------------------
# Done
# ----------------------------------------
header "Machine setup complete"

echo ""
echo "${BOLD}Next steps:${RESET}"
echo "  1. Run dotfiles installer: ${BOLD}./install.sh${RESET}"
echo ""
echo "${BOLD}Manual installs (not in Homebrew):${RESET}"
echo "  - Google Cloud SDK: https://cloud.google.com/sdk/docs/install"
echo "  - AWS CLI: brew install awscli"
echo ""
