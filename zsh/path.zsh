# PATH and tool initialization
# Sourced from ~/.zshrc

# Default editor
export EDITOR="nvim"
export VISUAL="nvim"

# History — shared across all tmux sessions in real-time
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # share between sessions live
setopt INC_APPEND_HISTORY     # write immediately, not on exit
setopt HIST_IGNORE_DUPS       # skip consecutive duplicates
setopt HIST_IGNORE_SPACE      # skip commands starting with space

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

# Google Cloud SDK
if [ -f "$HOME/run/google-cloud-sdk/path.zsh.inc" ]; then
    source "$HOME/run/google-cloud-sdk/path.zsh.inc"
fi
if [ -f "$HOME/run/google-cloud-sdk/completion.zsh.inc" ]; then
    source "$HOME/run/google-cloud-sdk/completion.zsh.inc"
fi
