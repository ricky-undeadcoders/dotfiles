#!/usr/bin/env bash
# Read stdin, copy to clipboard, open if it looks like a URL.
# Used by tmux DoubleClick/TripleClick bindings.

set -euo pipefail

selection="$(cat)"

printf '%s' "$selection" | pbcopy

trimmed="$(printf '%s' "$selection" | tr -d '[:space:]')"

if [[ "$trimmed" =~ ^(https?|ftp)://[^[:space:]]+$ ]] \
   || [[ "$trimmed" =~ ^www\.[^[:space:]]+\.[^[:space:]]+$ ]]; then
  url="$trimmed"
  [[ "$url" =~ ^www\. ]] && url="https://$url"
  open "$url" >/dev/null 2>&1 &
fi
