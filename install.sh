#!/usr/bin/env bash
# Terminal Command Center - Dotfiles Installer
# Idempotent: safe to run multiple times.
# Sets up symlinks, shell config, neovim plugins, and private config scaffold.
#
# For machine setup (brew installs), run ./setup.sh first.
#
# Usage:
#   ./install.sh

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
# Symlinks
# ----------------------------------------
header "Creating symlinks"

make_symlink() {
    local src="$1"
    local dst="$2"

    if [ -L "$dst" ]; then
        existing=$(readlink "$dst")
        if [ "$existing" = "$src" ]; then
            info "$dst -> already correct"
            return
        else
            warn "$dst -> points to $existing (expected $src) — removing old symlink"
            rm "$dst"
        fi
    fi

    if [ -e "$dst" ]; then
        warn "$dst exists and is not a symlink — backing up to ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi

    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    info "$dst -> $src"
}

make_symlink "$DOTFILES/tmux/tmux.conf"         "$HOME/.tmux.conf"
make_symlink "$DOTFILES/nvim"                    "$HOME/.config/nvim"
make_symlink "$DOTFILES/claude/scripts"          "$HOME/.claude/scripts"
make_symlink "$DOTFILES/ghostty/config"          "$HOME/.config/ghostty/config"
make_symlink "$DOTFILES/ghostty/themes"          "$HOME/.config/ghostty/themes"

# ----------------------------------------
# Make scripts executable
# ----------------------------------------
header "Making scripts executable"

chmod +x "$DOTFILES/claude/scripts/"*.sh 2>/dev/null && info "Shell scripts marked executable" || true
chmod +x "$DOTFILES/claude/scripts/"*.py 2>/dev/null && info "Python scripts marked executable" || true
chmod +x "$DOTFILES/setup.sh"
chmod +x "$DOTFILES/install.sh"

# ----------------------------------------
# Shell configuration
# ----------------------------------------
header "Configuring shell"

ZSHRC="$HOME/.zshrc"
MARKER="# --- Terminal Command Center ---"

if grep -qF "$MARKER" "$ZSHRC" 2>/dev/null; then
    info ".zshrc already configured"
else
    cat >> "$ZSHRC" << 'ZSHRC_BLOCK'

# --- Terminal Command Center ---
# Completion system (must be before anything that registers completions)
fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
autoload -Uz compinit
compinit

# PATH and tool init
[ -f ~/code/dotfiles/zsh/path.zsh ] && source ~/code/dotfiles/zsh/path.zsh

# Aliases and functions
[ -f ~/code/dotfiles/zsh/aliases.zsh ] && source ~/code/dotfiles/zsh/aliases.zsh
[ -f ~/code/dotfiles/zsh/functions.zsh ] && source ~/code/dotfiles/zsh/functions.zsh

# Private config (tokens, company-specific — not in public repo)
[ -f ~/.dotfiles-private/tokens.zsh ] && source ~/.dotfiles-private/tokens.zsh
[ -f ~/.dotfiles-private/aliases.zsh ] && source ~/.dotfiles-private/aliases.zsh

# Cowsay greeting
fortune | cowsay
# --- End Terminal Command Center ---
ZSHRC_BLOCK
    info "Added Terminal Command Center block to .zshrc"
fi

# ----------------------------------------
# Private config scaffold
# ----------------------------------------
header "Private config"

PRIVATE_DIR="$HOME/.dotfiles-private"
if [ -d "$PRIVATE_DIR" ]; then
    info "~/.dotfiles-private/ already exists"
else
    mkdir -p "$PRIVATE_DIR"
    cp "$DOTFILES/private-template/tokens.zsh.example" "$PRIVATE_DIR/"
    cp "$DOTFILES/private-template/aliases.zsh.example" "$PRIVATE_DIR/"
    info "Created ~/.dotfiles-private/ with example files"
    warn "Copy .example files and fill in your 1Password references"
fi

# ----------------------------------------
# Neovim plugins
# ----------------------------------------
header "Neovim plugins"

LAZY_LOCKFILE="$HOME/.config/nvim/lazy-lock.json"
if [ -f "$LAZY_LOCKFILE" ]; then
    info "LazyVim plugins already installed (lazy-lock.json exists)"
else
    echo "  Running nvim headless to install LazyVim plugins..."
    nvim --headless "+Lazy! sync" +qa 2>/dev/null && info "LazyVim plugins installed" || warn "nvim plugin install may need a manual run: nvim"
fi

# ----------------------------------------
# Done
# ----------------------------------------
header "Done"

echo ""
echo "${BOLD}Next steps:${RESET}"
echo "  1. Reload shell: ${BOLD}source ~/.zshrc${RESET}"
echo "  2. Set up private config: ${BOLD}cd ~/.dotfiles-private && cp tokens.zsh.example tokens.zsh${RESET}"
echo "  3. Sign into 1Password CLI: ${BOLD}op signin${RESET}"
echo "  4. Create your first session: ${BOLD}mux ~/code/my-repo${RESET}"
echo ""
