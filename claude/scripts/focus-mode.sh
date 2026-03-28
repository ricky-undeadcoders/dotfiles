#!/bin/bash
# Focus Mode - Close left sidebar only (cheat/todo)
# Leaves editor, claude, and terminal untouched

for title in "cheat" "todo"; do
    PANE_ID=$(tmux list-panes -F "#{pane_id} #{@panel}" 2>/dev/null | awk -v t="$title" '$2==t {print $1}')
    [ -n "$PANE_ID" ] && tmux kill-pane -t "$PANE_ID" 2>/dev/null || true
done
