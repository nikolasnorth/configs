#!/bin/bash

set -e

CONFIGS_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing configs from $CONFIGS_DIR"

# Install Homebrew if needed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install tools
echo "Installing tools..."
brew install fzf neovim tmux

# Create symlinks
echo "Creating symlinks..."
ln -sf "$CONFIGS_DIR/zsh/.zshrc" ~/.zshrc
ln -sf "$CONFIGS_DIR/tmux/.tmux.conf" ~/.tmux.conf

echo ""
echo "Done! Symlinks created:"
echo "  ~/.zshrc -> $CONFIGS_DIR/zsh/.zshrc"
echo "  ~/.tmux.conf -> $CONFIGS_DIR/tmux/.tmux.conf"
echo ""
echo "To apply changes, run: source ~/.zshrc"
echo ""
echo "NOTE: iTerm theme must be imported manually:"
echo "  iTerm2 > Settings > Profiles > Colors > Color Presets > Import"
echo "  Then select: $CONFIGS_DIR/iterm/gruvbox-dark.itermcolors"
