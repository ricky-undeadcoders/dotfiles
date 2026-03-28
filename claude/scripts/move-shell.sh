#!/bin/bash
# move-shell.sh - Cycle the terminal pane through 3 positions
# Positions: right → bottom → left → right ...
# Bound to Opt+3

get_pane() {
    tmux list-panes -F "#{pane_id} #{@panel}" 2>/dev/null | awk -v t="$1" '$2==t {print $1; exit}'
}

TERM_PANE=$(get_pane "terminal")
EDITOR=$(get_pane "editor")
CLAUDE=$(get_pane "claude")
FIRST=$(tmux list-panes -F "#{pane_id}" | head -1)

# Get current position (default: right)
POS=$(tmux show-option -gqv @shell_pos 2>/dev/null)
[ -z "$POS" ] && POS="right"

# If no terminal pane exists, create in current position
# If terminal pane exists, cycle to next position
if [ -n "$TERM_PANE" ]; then
    tmux kill-pane -t "$TERM_PANE" 2>/dev/null
    case "$POS" in
        "right")  POS="bottom" ;;
        "bottom") POS="left" ;;
        "left")   POS="right" ;;
        *)        POS="right" ;;
    esac
fi

# Recalculate references after kill (pane IDs may shift)
EDITOR=$(get_pane "editor")
CLAUDE=$(get_pane "claude")
FIRST=$(tmux list-panes -F "#{pane_id}" | head -1)

case "$POS" in
    "right")
        if [ -n "$CLAUDE" ]; then
            NEW=$(tmux split-window -v -t "$CLAUDE" -P -F "#{pane_id}" "zsh")
        else
            NEW=$(tmux split-window -h -t "${EDITOR:-$FIRST}" -p 40 -P -F "#{pane_id}" "zsh")
        fi
        ;;
    "bottom")
        # Full-width horizontal split at the bottom
        NEW=$(tmux split-window -v -f -t "$FIRST" -p 30 -P -F "#{pane_id}" "zsh")
        ;;
    "left")
        # Full-height vertical split on the left
        NEW=$(tmux split-window -h -b -f -t "$FIRST" -p 30 -P -F "#{pane_id}" "zsh")
        ;;
esac

if [ -n "$NEW" ]; then
    tmux set-option -t "$NEW" -p @panel terminal 2>/dev/null
    tmux select-pane -T terminal -t "$NEW" 2>/dev/null
fi

tmux set-option -g @shell_pos "$POS" 2>/dev/null

# Return focus to editor if open
[ -n "$EDITOR" ] && tmux select-pane -t "$EDITOR" 2>/dev/null || true

exit 0
