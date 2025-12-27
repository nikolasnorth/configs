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
brew install --cask ghostty

# Create symlinks
echo "Creating symlinks..."
ln -sf "$CONFIGS_DIR/zsh/.zshrc" ~/.zshrc
ln -sf "$CONFIGS_DIR/tmux/.tmux.conf" ~/.tmux.conf
mkdir -p ~/.config/ghostty
ln -sf "$CONFIGS_DIR/ghostty/config" ~/.config/ghostty/config

# Add git config include (if not already present)
if ! grep -q "path = ~/code/configs/git/.gitconfig" ~/.gitconfig 2>/dev/null; then
    echo "" >> ~/.gitconfig
    echo "[include]" >> ~/.gitconfig
    echo "	path = ~/code/configs/git/.gitconfig" >> ~/.gitconfig
fi

echo ""
echo "Done!"
echo ""
echo "Symlinks created:"
echo "  ~/.zshrc -> $CONFIGS_DIR/zsh/.zshrc"
echo "  ~/.tmux.conf -> $CONFIGS_DIR/tmux/.tmux.conf"
echo "  ~/.config/ghostty/config -> $CONFIGS_DIR/ghostty/config"
echo ""
echo "Git config included from: $CONFIGS_DIR/git/.gitconfig"
echo ""
echo "To apply changes, run: source ~/.zshrc"
