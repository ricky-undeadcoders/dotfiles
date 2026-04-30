#!/bin/bash
# Claude wrapper - tags own pane before launching
tmux set-option -p @panel claude
claude "$@"
