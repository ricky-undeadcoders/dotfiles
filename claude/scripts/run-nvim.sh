#!/bin/bash
# Neovim wrapper - tags own pane before launching
tmux set-option -p @panel editor
nvim "$@"
