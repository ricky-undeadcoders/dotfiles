#!/usr/bin/env bash
# Run AFTER 1Password app + CLI + SSH agent set up, public dotfiles cloned + setup.sh run.

set -euo pipefail

ACCOUNT="my.1password.com"
VAULT="Private"

echo "=== Restoring claude-global (CLAUDE.md, git-workflow.md, hooks, .md guides) ==="
op document get "claude-global-migration" \
  --vault "$VAULT" --account "$ACCOUNT" \
  --output /tmp/claude-global.tgz
mkdir -p ~/.claude
tar xzf /tmp/claude-global.tgz -C ~/.claude
rm /tmp/claude-global.tgz

echo "=== Restoring dotfiles-private (claude/agents) ==="
op document get "dotfiles-private-migration" \
  --vault "$VAULT" --account "$ACCOUNT" \
  --output /tmp/dotfiles-private.tgz
mkdir -p ~/code
tar xzf /tmp/dotfiles-private.tgz -C ~/code
rm /tmp/dotfiles-private.tgz
(cd ~/code/dotfiles-private && ./install.sh)

echo "=== Restoring dotfiles-private live (aliases.zsh, tokens.zsh, skills/) ==="
op document get "dotfiles-private-live-migration" \
  --vault "$VAULT" --account "$ACCOUNT" \
  --output /tmp/dotfiles-private-live.tgz
tar xzf /tmp/dotfiles-private-live.tgz -C ~
rm /tmp/dotfiles-private-live.tgz

echo "=== Linking skills globally so Claude discovers them outside repo CWD ==="
mkdir -p ~/.claude/skills
for skill in ~/.dotfiles-private/skills/*/*/; do
  name=$(basename "$skill")
  ln -sfn "$skill" "$HOME/.claude/skills/$name"
done

echo "=== Installing caveman Claude Code plugin ==="
claude plugin marketplace add JuliusBrussee/caveman
claude plugin install caveman@caveman

echo "=== Restoring notes ==="
op document get "notes-migration" \
  --vault "$VAULT" --account "$ACCOUNT" \
  --output /tmp/notes.tgz
tar xzf /tmp/notes.tgz -C ~
rm /tmp/notes.tgz

echo "=== Restoring oci-talk (~/code/oci-talk) ==="
op document get "oci-talk-migration" \
  --vault "$VAULT" --account "$ACCOUNT" \
  --output /tmp/oci-talk.tgz
mkdir -p ~/code
tar xzf /tmp/oci-talk.tgz -C ~/code
rm /tmp/oci-talk.tgz

echo "=== Restoring todolist local.env ==="
mkdir -p ~/var/todolist
op document get "todolist-local-env" \
  --vault "$VAULT" --account "$ACCOUNT" \
  --output ~/var/todolist/local.env
chmod 600 ~/var/todolist/local.env
