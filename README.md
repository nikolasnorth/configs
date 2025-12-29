# configs

Personal dotfiles for macOS and Linux.

## What's Included

| Config | Description |
|--------|-------------|
| `zsh/.zshrc` | Zsh with fzf integration |
| `tmux/.tmux.conf` | tmux with vim keys, prefix `Ctrl+Space` |
| `nvim/init.lua` | Neovim with treesitter, gitsigns, lualine |
| `ghostty/config` | Ghostty terminal (macOS only) |
| `bat/config` | bat with gruvbox theme |
| `git/.gitconfig` | Shared git settings |
| `claude/settings.json` | Claude Code settings |

## Install

```bash
git clone https://github.com/nikolas/configs.git ~/code/configs
cd ~/code/configs
./install.sh --home   # personal machine (includes Claude Code)
./install.sh --work   # work machine
```

**macOS:** Automatically installs Homebrew, then installs tools via brew.

**Linux:** Requires Homebrew to be installed first:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```
Then run `./install.sh` to install tools via brew.

## Key Bindings

**tmux** (prefix: `Ctrl+Space`)
- `h/j/k/l` - navigate panes
- `|` - split horizontal
- `-` - split vertical
- `r` - reload config

**nvim** (leader: `Space`)
- `Space ff` - find files
- `Space fg` - live grep
- `Space fb` - find buffers
- `Space fr` - recent files
- `Space gb` - git blame line
- `Space gp` - preview git changes

## Neovim Plugins

| Plugin | Purpose |
|--------|---------|
| lazy.nvim | Plugin manager |
| nvim-treesitter | Syntax highlighting |
| gitsigns.nvim | Git gutter signs, blame |
| fzf-lua | Fuzzy finder |
| Comment.nvim | Toggle comments (`gcc`) |
| nvim-autopairs | Auto-close brackets, quotes |
| lualine.nvim | Status line |
| gruvbox-material | Theme |

## Theme

Gruvbox Material Dark across all tools:
- Terminal: Ghostty built-in theme
- Neovim: `sainnhe/gruvbox-material`
- tmux: Custom status bar colors
