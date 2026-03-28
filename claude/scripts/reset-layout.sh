#!/bin/bash
# Reset all open panels to their original sizing

get_pane() {
    local name="$1"
    local pane

    pane=$(tmux list-panes -a -F "#{pane_id} #{@panel}" 2>/dev/null | awk -v t="$name" '$2==t {print $1; exit}')

    if [ -z "$pane" ]; then
        case "$name" in
            "editor") pane=$(tmux list-panes -a -F "#{pane_id} #{pane_current_command}" 2>/dev/null | awk '$2=="nvim" {print $1; exit}') ;;
            "claude") pane=$(tmux list-panes -a -F "#{pane_id} #{pane_current_command}" 2>/dev/null | awk '$2=="claude" {print $1; exit}') ;;
        esac
        [ -n "$pane" ] && tmux set-option -t "$pane" -p @panel "$name" 2>/dev/null
    fi

    echo "$pane"
}

WIN_WIDTH=$(tmux display-message -p "#{window_width}")
WIN_HEIGHT=$(tmux display-message -p "#{window_height}")

CHEAT=$(get_pane "cheat")
TODO=$(get_pane "todo")
CLAUDE=$(get_pane "claude")
TERMINAL=$(get_pane "terminal")

# Resize left column (cheat/todo) to 45 cols
[ -n "$CHEAT" ] && tmux resize-pane -t "$CHEAT" -x 45 2>/dev/null || true
[ -n "$TODO"  ] && tmux resize-pane -t "$TODO"  -x 45 2>/dev/null || true

# If both left panels open, equalize their heights
if [ -n "$CHEAT" ] && [ -n "$TODO" ]; then
    HALF_H=$(( WIN_HEIGHT / 2 ))
    tmux resize-pane -t "$CHEAT" -y "$HALF_H" 2>/dev/null || true
fi

# Right column: claude gets 40% of window width
if [ -n "$CLAUDE" ]; then
    RIGHT_W=$(( WIN_WIDTH * 40 / 100 ))
    tmux resize-pane -t "$CLAUDE" -x "$RIGHT_W" 2>/dev/null || true
fi

# If claude + terminal both open, split right column evenly
if [ -n "$CLAUDE" ] && [ -n "$TERMINAL" ]; then
    HALF_H=$(( WIN_HEIGHT / 2 ))
    tmux resize-pane -t "$CLAUDE"   -y "$HALF_H" 2>/dev/null || true
    tmux resize-pane -t "$TERMINAL" -y "$HALF_H" 2>/dev/null || true
fi

exit 0
