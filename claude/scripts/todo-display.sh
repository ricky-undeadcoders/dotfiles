#!/bin/bash
# Todo Display - Shows This Week's Todo Items with Colors
# Displays filtered todo list for this-week only, preserving Click colors

# Colors - using tput for the header
BLUE=$(tput setaf 4)
GRAY=$(tput setaf 240)
BOLD=$(tput bold)
RESET=$(tput sgr0)

clear
echo "${BOLD}${BLUE}═══ TODO LIST THIS-WEEK ═══${RESET}"
echo ""

# Use PTY wrapper to preserve Click colors from todo command
if [ -f "$HOME/.claude/scripts/run-with-color.py" ]; then
    "$HOME/.claude/scripts/run-with-color.py" zsh -c "source ~/.zshrc 2>/dev/null && todo this-week" 2>/dev/null || \
    echo "${GRAY}Error running todo command${RESET}"
else
    # Fallback without colors if wrapper not available
    zsh -c "source ~/.zshrc 2>/dev/null && todo this-week" 2>/dev/null || \
    echo "${GRAY}No todos this week${RESET}"
fi

echo ""
echo "${GRAY}────────────────${RESET}"
echo "${GRAY}$(date '+%H:%M')${RESET}"
