# PATH and tool initialization
# Sourced from ~/.zshrc

# Default editor
export EDITOR="nvim"
export VISUAL="nvim"

# Personal bin
export PATH="$HOME/bin:$PATH"

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# uv (Python version + package manager)
# Install python:  uv python install 3.12
# Create venv:     uv venv --python 3.12
# Fast pip:        uv pip install -r requirements.txt
eval "$(uv generate-shell-completion zsh 2>/dev/null)"

# fzf — Ctrl+R (history), Ctrl+T (files), Alt+C (cd dir)
command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)

# Google Cloud SDK
if [ -f "$HOME/run/google-cloud-sdk/path.zsh.inc" ]; then
    source "$HOME/run/google-cloud-sdk/path.zsh.inc"
fi
if [ -f "$HOME/run/google-cloud-sdk/completion.zsh.inc" ]; then
    source "$HOME/run/google-cloud-sdk/completion.zsh.inc"
fi
