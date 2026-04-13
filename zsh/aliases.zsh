# Shell Aliases
# Sourced from ~/.zshrc

# General
alias ll='ls -lah'
alias c='printf "\033[2J\033[3J\033[H"'
alias md='glow -w $COLUMNS'
alias ssht='ssh -t'

# Docker
alias dc='docker compose'
alias dexec='docker exec -it'
alias dockerrma='docker rm -f $(docker ps -qa)'

# Kubernetes
alias k='kubectl'
alias tf='terraform'

# Git
alias gb='git branch -vv'
alias nb='new-branch'
alias gr='git-root'
alias gitblame='git blame -w -C -C -C'
alias delbranch='git branch -vv | grep ": gone]" | awk "{print \$1}" | xargs -I {} bash -c "git branch -D {}"'
alias verbranch='git branch -vv -l "$(git branch --show-current)"'

# Claude
alias cl='claude'
alias clh='cd ~/code/claude && claude'
alias clr='claude --resume'
alias clhr='clh --resume'

# tmuxinator
alias muxl='tmuxinator list'
alias muxs='tmuxinator stop'
