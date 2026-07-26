# configs

Personal dotfiles for macOS and Linux.

## What's Included

| Config | Description |
|--------|-------------|
| `zsh/.zshrc` | Zsh with fzf, eza, and zoxide |
| `tmux/.tmux.conf` | tmux with vim keys, prefix `Ctrl+Space` |
| `nvim/init.lua` | Neovim with treesitter, LSP, completion, and fuzzy finding |
| `ghostty/config` | Ghostty terminal (macOS only) |
| `bat/config` | bat with gruvbox theme |
| `git/.gitconfig` | Shared git settings |
| `claude/settings.json` | Claude Code settings |
| `claude/CLAUDE.md` | Claude Code instructions (Conventional Commits) |
| `herdr/config.toml` | Herdr terminal workspace manager |

## Install

```bash
git clone https://github.com/nikolasnorth/configs.git ~/code/configs
cd ~/code/configs
./install.sh              # shared configuration
./install.sh --personal   # shared plus personal configuration
```

The setup script only backs up conflicting files and creates configuration
symlinks. It does not install applications, plugins, packages, or command-line
dependencies.

On a work machine, run `~/code/Nnorth/install.sh` afterward to add the private
work overlay.

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
| which-key.nvim | Shows leader keybindings |
| Comment.nvim | Toggle comments (`gcc`) |
| nvim-autopairs | Auto-close brackets, quotes |
| lualine.nvim | Status line |
| nvim-lspconfig / nvim-jdtls | Language server support |
| blink.cmp | Completion |
| render-markdown.nvim | Markdown rendering |
| catppuccin | Theme |

## Theme

- Ghostty and Neovim: Catppuccin Mocha
- Herdr: Catppuccin Mocha accent
- bat: Gruvbox Dark
- tmux: Custom dark status bar
