#!/usr/bin/env bash
# mux-new - Generate a tmuxinator session from the generic template and launch it
# Usage: mnew <session-name> <path>

set -euo pipefail

USAGE="Usage: mnew <session-name> <path>
  Example: mnew my-project ~/code/some-repo"

if [ $# -ne 2 ]; then
    echo "$USAGE" >&2
    exit 1
fi

SESSION_NAME="$1"
SESSION_PATH="$(cd "$2" 2>/dev/null && pwd)" || {
    echo "Error: path '$2' does not exist" >&2
    exit 1
}

TEMPLATE="$HOME/code/dotfiles/tmuxinator/example.yml"
OUTPUT="$HOME/.tmuxinator/${SESSION_NAME}.yml"

if [ ! -f "$TEMPLATE" ]; then
    echo "Error: template not found at $TEMPLATE" >&2
    exit 1
fi

if [ -f "$OUTPUT" ]; then
    echo "Session '$SESSION_NAME' already exists at $OUTPUT"
    echo -n "Overwrite? [y/N] "
    read -r answer
    [[ "$answer" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
fi

# Generate YAML from template (substitute name and root)
sed \
    -e "s|<%= @settings\[\"name\"\] %>|${SESSION_NAME}|g" \
    -e "s|<%= @settings\[\"root\"\] %>|${SESSION_PATH}|g" \
    "$TEMPLATE" > "$OUTPUT"

echo "Created: $OUTPUT"
echo "Launching: mux ${SESSION_NAME}"
tmuxinator start "$SESSION_NAME"
