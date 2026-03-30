# Terminal Command Center — Dotfiles

A tmux + neovim + Claude Code setup for keyboard-driven development, themed with [cyberdream](https://github.com/scottmckendry/cyberdream.nvim).

## Layout

```
┌──────────┬──────────────────────────────┬──────────────────┐
│          │                              │                  │
│  Cheat   │                              │     Claude       │
│  (Opt+1) │      Neovim (center)         │     (Opt+9)      │
│          │                              │                  │
│  Todo    │      [Main coding area]      ├──────────────────┤
│  (Opt+2) │                              │    Terminal      │
│          │                              │    (Opt+0)       │
└──────────┴──────────────────────────────┴──────────────────┘

Status bar (top): session | directory | git branch | CPU | MEM | BAT | date/time
```

## Keybindings

### Panel toggles

| Key | Action |
|-----|--------|
| `Opt+1` | Toggle cheat sheet (left) |
| `Opt+2` | Toggle todo (left) |
| `Opt+7` | Toggle neovim (center) |
| `Opt+9` | Toggle Claude (right) |
| `Opt+0` | Toggle terminal (right) |
| `Opt+f` | Focus mode (close left sidebar) |
| `Opt+=` | Reset layout |
| `Opt+q` | Quit session |

### tmux

| Key | Action |
|-----|--------|
| `Ctrl+b o` | Cycle panes |
| `Ctrl+b z` | Zoom pane |
| `Ctrl+b d` | Detach session |
| `Ctrl+b r` | Reload tmux config |
| `Ctrl+b 1` | Main window (editor + claude) |
| `Ctrl+b 2` | Shell window |
| `Ctrl+b n/p` | Next/prev window |
| `Ctrl+b \|/-` | Split vertical/horizontal |

The cheat sheet panel (`Opt+1`) has a full reference including vim, LazyVim, LSP, git, and fold keybindings.

## Setup

### 1. Clone

```bash
git clone https://github.com/ricky-undeadcoders/dotfiles ~/code/dotfiles
cd ~/code/dotfiles
```

### 2. Machine setup (new computer only)

```bash
./setup.sh
```

Installs Homebrew, CLI tools, and desktop apps. Edit the lists at the top of `setup.sh` to customize. Safe to re-run — skips anything already installed.

### 3. Dotfiles install

```bash
./install.sh
```

This will:
- Create symlinks for tmux, neovim, ghostty, and scripts
- Configure `.zshrc` to source aliases, functions, and PATH setup
- Scaffold `~/.dotfiles-private/` for secrets and company-specific config
- Install neovim plugins headless

Idempotent — run it anytime to sync changes.

### 4. Terminal setup

**Ghostty** (recommended): Works out of the box — `Opt+N` bindings work via the `macos-option-as-alt = true` config.

**iTerm2** (alternative): Set **Profiles → Keys → Left Option key** to `Esc+` to enable `Opt+N` bindings.

### 5. Private config

The installer creates `~/.dotfiles-private/` with example files:

```bash
cd ~/.dotfiles-private
cp tokens.zsh.example tokens.zsh
cp aliases.zsh.example aliases.zsh
```

**Tokens** are loaded via [1Password CLI](https://developer.1password.com/docs/cli/):

```bash
# Store a token
op item create --category=api_credential --title="My Token" --vault="Developer Tokens"

# Reference it in tokens.zsh
export MY_TOKEN=$(op read "op://Developer Tokens/My Token/credential")
```

**Company-specific aliases** (project shortcuts, internal tool wrappers) go in `aliases.zsh`.

These files are sourced automatically by `.zshrc` but never committed to the public repo.

### 6. Create your first session

```bash
mnew my-project ~/code/my-repo
```

This generates a tmuxinator template at `~/.tmuxinator/my-project.yml` and launches the session. For existing sessions:

```bash
mux my-project
```

## Theming

Everything uses the [cyberdream](https://github.com/scottmckendry/cyberdream.nvim) color palette:

| Tool | Config location |
|------|----------------|
| Neovim | `nvim/lua/plugins/colorscheme.lua` |
| Ghostty | `ghostty/config` + `ghostty/themes/ricky` |
| tmux | `tmux/tmux.conf` (status bar + borders) |
| Lazygit | `~/.config/lazygit/config.yml` |
| K9s | `~/.config/k9s/skins/cyberdream.yml` |

The tmux status bar shows: session name, current directory, git branch, CPU%, MEM%, battery%, and date/time — all in cyberdream colors.

## Multi-Repo Workflows

Each tmuxinator session has two windows:

- **Window 1 (main)**: editor + Claude pane for the primary repo
- **Window 2 (shell)**: free terminal for secondary repos

Switch between windows with `Ctrl+b 1` / `Ctrl+b 2` or `Ctrl+b n/p`.

## Structure

```
dotfiles/
├── setup.sh                    # Machine setup (brew formulae + casks)
├── install.sh                  # Dotfiles sync (symlinks + shell config + nvim plugins)
├── ghostty/
│   ├── config                  → ~/.config/ghostty/config
│   └── themes/ricky            → ~/.config/ghostty/themes/
├── tmux/
│   └── tmux.conf               → ~/.tmux.conf
├── nvim/                       → ~/.config/nvim/
│   ├── init.lua
│   └── lua/
│       ├── config/
│       └── plugins/            # cyberdream, neo-tree, lsp, telescope, etc.
├── claude/
│   └── scripts/                → ~/.claude/scripts/
│       ├── toggle-panel.sh     # Panel toggle system
│       ├── cheat-sheet.sh      # Keyboard shortcut reference
│       ├── tmux-cpu.sh         # Status bar: CPU usage
│       ├── tmux-mem.sh         # Status bar: memory usage
│       ├── tmux-bat.sh         # Status bar: battery level
│       └── ...
├── tmuxinator/
│   └── example.yml             # Parameterized template for mnew
├── zsh/
│   ├── aliases.zsh             # Shell aliases
│   ├── functions.zsh           # Shell functions (git, terraform, etc.)
│   └── path.zsh                # PATH, nvm, uv, gcloud init
└── private-template/
    ├── tokens.zsh.example      # 1Password token loading template
    └── aliases.zsh.example     # Company-specific aliases template
```

## What's Not Here

Secrets and company-specific config live in `~/.dotfiles-private/` (never committed):

- **Tokens/credentials** — loaded via 1Password CLI (`op read`)
- **Company-specific aliases** — project shortcuts, internal tool wrappers
- **Project-specific tmuxinator templates** — sessions with org-specific paths

See `private-template/` for examples of what goes there.

## Manual Installs

These aren't available via Homebrew and need manual setup:

- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) (`brew install awscli`)
