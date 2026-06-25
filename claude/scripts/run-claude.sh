#!/bin/bash
# Claude wrapper - tags own pane before launching
tmux set-option -p @panel claude
claude "$@"
# Keep the pane alive after claude exits - drop into a shell instead of
# letting the pane close. @panel tag persists, so M-9 still toggles/kills it.
exec "${SHELL:-zsh}" -l
