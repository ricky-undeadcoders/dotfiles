#!/bin/bash
# Panel Toggle Script v2
# Layout:
#   [editor (top-left)] [claude (top-right)]
#   [cheat/todo (bot-left)] [terminal (bottom, full-width)]

PANEL_NAME="$1"
SESSION=$(tmux display-message -p '#{session_name}')

# Retag any panes that lost their @panel tag (e.g. race condition on session start)
while IFS= read -r line; do
    pid=$(echo "$line" | awk '{print $1}')
    cmd=$(echo "$line" | awk '{print $2}')
    tag=$(echo "$line" | awk '{print $3}')
    if [ -z "$tag" ]; then
        case "$cmd" in
            nvim)   tmux set-option -t "$pid" -p @panel editor 2>/dev/null ;;
            claude) tmux set-option -t "$pid" -p @panel claude 2>/dev/null ;;
        esac
    fi
done < <(tmux list-panes -s -t "$SESSION" -F "#{pane_id} #{pane_current_command} #{@panel}" 2>/dev/null)

# Get pane ID by @panel user option, scoped to current session
get_pane() {
    local name="$1"
    local pane

    # Primary: check @panel user option across session panes
    pane=$(tmux list-panes -s -t "$SESSION" -F "#{pane_id} #{@panel}" 2>/dev/null | awk -v t="$name" '$2==t {print $1; exit}')

    # Fallback: for editor/claude, find by running command and auto-tag
    if [ -z "$pane" ]; then
        case "$name" in
            "editor") pane=$(tmux list-panes -s -t "$SESSION" -F "#{pane_id} #{pane_current_command}" 2>/dev/null | awk '$2=="nvim" {print $1; exit}') ;;
            "claude") pane=$(tmux list-panes -s -t "$SESSION" -F "#{pane_id} #{pane_current_command}" 2>/dev/null | awk '$2=="claude" {print $1; exit}') ;;
        esac
        [ -n "$pane" ] && tmux set-option -t "$pane" -p @panel "$name" 2>/dev/null
    fi

    echo "$pane"
}

# Create a pane and tag it - no stdout (would leak into active pane via run-shell)
NEW_PANE=""
create_pane() {
    local cmd="$1"; shift
    NEW_PANE=$(tmux split-window "$@" -P -F "#{pane_id}" "$cmd" 2>/dev/null) || true
    [ -z "$NEW_PANE" ] && return 0
    tmux set-option -t "$NEW_PANE" -p @panel "$PANEL_NAME" 2>/dev/null || true
    tmux select-pane -T "$PANEL_NAME" -t "$NEW_PANE" 2>/dev/null || true
    tmux refresh-client 2>/dev/null || true
}

case "$PANEL_NAME" in
    "cheat")    PANEL_CMD="$HOME/.claude/scripts/cheat-sheet.sh" ;;
    "todo")     PANEL_CMD="$HOME/.claude/scripts/run-todo.sh" ;;
    "claude")   PANEL_CMD="$HOME/.claude/scripts/run-claude.sh" ;;
    "terminal") PANEL_CMD="zsh" ;;
    "editor")   PANEL_CMD="$HOME/.claude/scripts/run-nvim.sh" ;;
    *)          exit 0 ;;
esac

# If pane already exists, kill it
EXISTING=$(get_pane "$PANEL_NAME")
if [ -n "$EXISTING" ]; then
    tmux kill-pane -t "$EXISTING"
    exit 0
fi

case "$PANEL_NAME" in

    "terminal")
        # Right column - below claude if open, otherwise full right panel
        CLAUDE=$(get_pane "claude")
        if [ -n "$CLAUDE" ]; then
            # Stack below claude in the right column
            create_pane "$PANEL_CMD" -v -t "$CLAUDE"
        else
            # No claude - take the full right panel
            EDITOR=$(get_pane "editor")
            REF="${EDITOR:-$(tmux list-panes -F '#{pane_id}' | head -1)}"
            create_pane "$PANEL_CMD" -h -p 40 -t "$REF"
        fi
        ;;

    "cheat"|"todo")
        # Far left, full height - always splits before everything else
        if [ "$PANEL_NAME" = "cheat" ]; then
            OTHER=$(get_pane "todo")
        else
            OTHER=$(get_pane "cheat")
        fi

        if [ -n "$OTHER" ]; then
            # Stack vertically with the other left panel
            if [ "$PANEL_NAME" = "todo" ]; then
                create_pane "$PANEL_CMD" -v -t "$OTHER"
            else
                create_pane "$PANEL_CMD" -v -b -t "$OTHER"
            fi
        else
            # No other left panel - create full-height far left column
            create_pane "$PANEL_CMD" -h -b -l 45
        fi
        ;;

    "editor")
        # Top-left - to the left of claude in the top row
        CLAUDE=$(get_pane "claude")
        if [ -n "$CLAUDE" ]; then
            create_pane "$PANEL_CMD" -h -b -t "$CLAUDE"
        else
            # No claude - full-width top (split above terminal if it exists)
            TERMINAL=$(get_pane "terminal")
            if [ -n "$TERMINAL" ]; then
                create_pane "$PANEL_CMD" -v -b -t "$TERMINAL"
            else
                create_pane "$PANEL_CMD" -h
            fi
        fi
        ;;

    "claude")
        # Top-right - to the right of editor in the top row
        EDITOR=$(get_pane "editor")
        if [ -n "$EDITOR" ]; then
            create_pane "$PANEL_CMD" -h -t "$EDITOR"
        else
            TERMINAL=$(get_pane "terminal")
            if [ -n "$TERMINAL" ]; then
                create_pane "$PANEL_CMD" -v -b -t "$TERMINAL"
            else
                create_pane "$PANEL_CMD" -h
            fi
        fi
        ;;

esac

# Return focus to editor if open
EDITOR=$(get_pane "editor")
[ -n "$EDITOR" ] && tmux select-pane -t "$EDITOR" 2>/dev/null || true

exit 0
