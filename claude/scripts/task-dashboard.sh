#!/bin/bash
# Task Dashboard - Quick Task Overview
# Shows GitHub issues assigned to you

# Colors - using tput for better compatibility
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
GRAY=$(tput setaf 240)
BOLD=$(tput bold)
RESET=$(tput sgr0)

clear
echo "${BOLD}${BLUE}═══ WORK TASKS ═══${RESET}"
echo ""

# Check if gh is available
if ! command -v gh &> /dev/null; then
    echo "${GRAY}gh CLI not found${RESET}"
    echo ""
    echo "${GRAY}────────────────${RESET}"
    echo "${GRAY}$(date '+%H:%M')${RESET}"
    exit 0
fi

# Show assigned issues (quick, doesn't require agent)
echo "${BOLD}Assigned Issues:${RESET}"
gh issue list --assignee=@me --limit 5 2>/dev/null | head -n 10 || echo "${GRAY}None${RESET}"

echo ""
echo "${BOLD}Recent Activity:${RESET}"
gh issue list --assignee=@me --state=all --limit 3 2>/dev/null | head -n 8 || echo "${GRAY}None${RESET}"

echo ""
echo "${GRAY}────────────────${RESET}"
echo "${GRAY}Use work-manager${RESET}"
echo "${GRAY}agent for priorities${RESET}"
echo ""
echo "${GRAY}$(date '+%H:%M')${RESET}"
