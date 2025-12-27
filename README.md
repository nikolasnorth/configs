# configs

Personal dotfiles for macOS and Linux. Gruvbox Material Dark theme everywhere.

## What's Included

| Config | Description |
|--------|-------------|
| `zsh/.zshrc` | Zsh with fzf integration |
| `tmux/.tmux.conf` | tmux with vim keys, prefix `Ctrl+Space` |
| `nvim/init.lua` | Neovim with lazy.nvim, treesitter, lualine |
| `ghostty/config` | Ghostty terminal (macOS only) |
| `git/.gitconfig` | Shared git settings |

## Install

```bash
git clone https://github.com/nikolas/configs.git ~/code/configs
cd ~/code/configs
./install.sh
```

**macOS:** Installs tools via Homebrew, creates symlinks, sets key repeat.

**Linux:** Creates symlinks only. Install prerequisites first:
- zsh, tmux, neovim, fzf, git

## Key Bindings

**tmux** (prefix: `Ctrl+Space`)
- `h/j/k/l` - navigate panes
- `|` - split horizontal
- `-` - split vertical
- `r` - reload config

## Theme

Gruvbox Material Dark across all tools:
- Terminal: Ghostty built-in theme
- Neovim: `sainnhe/gruvbox-material`
- tmux: Custom status bar colors
