#!/bin/bash
# Keyboard Shortcuts Cheat Sheet
# Quick reference for terminal command center hotkeys

# Colors
BLUE=$(tput setaf 4)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
GRAY=$(tput setaf 240)
BOLD=$(tput bold)
RESET=$(tput sgr0)

k() { echo "${YELLOW}$1${RESET} $2"; }  # key + description

clear
echo "${BOLD}${BLUE}══ KEYBOARD SHORTCUTS ══${RESET}"
echo ""

echo "${BOLD}${GREEN}Panels${RESET}"
k "Opt+1" "Cheat sheet (left)"
k "Opt+2" "Todo this-week (left)"
k "Opt+7" "Neovim (center)"
k "Opt+9" "Claude (right)"
k "Opt+0" "Terminal (right)"
k "Opt+f" "Focus mode"
k "Opt+=" "Reset layout"
k "Opt+q" "Quit session"
echo ""

echo "${BOLD}${GREEN}tmux${RESET}"
k "Ctrl+b o" "Cycle panes"
k "Ctrl+b z" "Zoom pane"
k "Ctrl+b d" "Detach session"
k "Ctrl+b r" "Reload config"
k "Ctrl+b 1" "Main window"
k "Ctrl+b 2" "Shell window"
k "Ctrl+b c"   "New window"
k "Ctrl+b n/p" "Next/prev window"
k "Ctrl+b |/-" "Split v/h"
k "Ctrl+b x" "Kill pane"
echo ""

echo "${BOLD}${GREEN}Vim - Move${RESET}"
k "gg / G"   "Top / bottom"
k "Ctrl+d/u" "Half page down/up"
k "zz"       "Center cursor"
k "w / b"    "Next / prev word"
k "0 / \$"   "Line start / end"
k "{"" / }"  "Prev / next block"
k "%"        "Jump to bracket"
k "*"        "Search word under cursor"
echo ""

echo "${BOLD}${GREEN}Vim - Edit${RESET}"
k "dd"  "Delete line"
k "yy"  "Copy line"
k "p/P" "Paste after/before"
k "u"   "Undo"
k "C-r" "Redo"
k "o/O" "New line below/above"
k "A"   "Append end of line"
k "ciw" "Change inner word"
k "di\"" "Delete inside quotes"
k "r"   "Replace character"
echo ""

echo "${BOLD}${GREEN}Vim - Search${RESET}"
k "/" "Search forward"
k "?" "Search backward"
k "n/N" "Next / prev match"
k ":%s/old/new/g" "Replace all"
echo ""

echo "${BOLD}${GREEN}Vim - Visual${RESET}"
k "v"    "Visual mode"
k "V"    "Visual line"
k "C-v"  "Visual block"
k "> / <" "Indent / dedent"
k "gc"   "Toggle comment (visual)"
k "gcc"  "Toggle comment (line)"
k "gcap" "Toggle comment (paragraph)"
echo ""

echo "${BOLD}${GREEN}LazyVim - Files${RESET}"
k "Spc ff"  "Find files"
k "Spc fg"  "Find git files"
k "Spc fr"  "Recent files"
k "Spc fb"  "Browse buffers"
k "Spc e"   "File explorer"
k "Spc /"   "Grep project"
k "Spc sg"  "Grep project (alt)"
k "Spc sw"  "Grep word under cursor"
echo ""

echo "${BOLD}${GREEN}LazyVim - Git${RESET}"
k "]h / [h"   "Next/prev git hunk"
k "Spc gg"    "LazyGit"
k "Spc gb"    "Git blame line"
k "Spc gd"    "Git diff (hunks)"
k "Spc gs"    "Git status"
k "Spc ghp"   "Preview hunk inline"
k "Spc ghs"   "Stage hunk"
k "Spc ghr"   "Reset hunk"
echo ""

echo "${BOLD}${GREEN}LazyVim - LSP${RESET}"
k "gd"      "Go to definition"
k "gr"      "Go to references"
k "gI"      "Go to implementation"
k "gy"      "Go to type definition"
k "K"       "Hover docs"
k "Ctrl+o"  "Jump back (after gd etc.)"
k "Ctrl+i"  "Jump forward"
k "Spc ca"  "Code actions"
k "Spc cr"  "Rename symbol"
k "]d/[d"   "Next/prev diagnostic"
echo ""

echo "${BOLD}${GREEN}LazyVim - Folds${RESET}"
k "za"    "Toggle fold"
k "zM"    "Close all folds"
k "zR"    "Open all folds"
k "zj/zk" "Next/prev fold"
echo ""

echo "${BOLD}${GREEN}LazyVim - Buffers${RESET}"
k "Shift+h/l" "Prev/next buffer"
k "Spc bd"    "Delete buffer"
echo ""

echo "${BOLD}${GREEN}Sessions${RESET}"
k "mux"               "Session for current dir"
k "mux <path>"        "Session for any dir"
k "mux <name>"        "Attach existing session"
k "muxl"              "List sessions"
echo ""

echo "${BOLD}${GREEN}Multi-Repo${RESET}"
k "Ctrl+b 1" "Main window (editor + claude)"
k "Ctrl+b 2" "Shell window (secondary repo)"
echo ""

echo "${GRAY}───────────────────────${RESET}"
echo "${GRAY}Spc = Space, Opt = Option${RESET}"
echo "${GRAY}Press Opt+1 to hide${RESET}"

# Keep pane alive until Option+1 kills it
read -r </dev/tty
