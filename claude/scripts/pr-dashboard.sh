#!/bin/bash
# PR Dashboard - Quick PR Overview
# Shows PRs assigned to you and review requests

# Colors - using tput for better compatibility
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
GRAY=$(tput setaf 240)
BOLD=$(tput bold)
RESET=$(tput sgr0)

clear
echo "${BOLD}${BLUE}═══ PR QUEUE ═══${RESET}"
echo ""

# Check if gh is available
if ! command -v gh &> /dev/null; then
    echo "${GRAY}gh CLI not found${RESET}"
    echo ""
    echo "${GRAY}────────────────${RESET}"
    echo "${GRAY}$(date '+%H:%M')${RESET}"
    exit 0
fi

# Show review requests (quick, doesn't require agent)
echo "${BOLD}Review Requests:${RESET}"
gh search prs --review-requested=@me --state=open --limit 5 2>/dev/null | head -n 10 || echo "${GRAY}None${RESET}"

echo ""
echo "${BOLD}Your Open PRs:${RESET}"
gh pr list --author=@me --limit 5 2>/dev/null | head -n 10 || echo "${GRAY}None${RESET}"

echo ""
echo "${GRAY}────────────────${RESET}"
echo "${GRAY}Use pr-batch-review${RESET}"
echo "${GRAY}agent for full analysis${RESET}"
echo ""
echo "${GRAY}$(date '+%H:%M')${RESET}"
