#!/bin/bash

set -e

CONFIGS_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

echo "Installing configs from $CONFIGS_DIR"
echo "Detected OS: $OS"

# Install tools (macOS only)
if [ "$OS" = "Darwin" ]; then
    # Install Homebrew if needed
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    # Install packages via Homebrew
    echo "Installing tools..."
    brew install fd fzf neovim tmux zsh
    brew install --cask ghostty
fi

# Create symlinks (both macOS and Linux)
echo "Creating symlinks..."
ln -sf "$CONFIGS_DIR/zsh/.zshrc" ~/.zshrc
ln -sf "$CONFIGS_DIR/tmux/.tmux.conf" ~/.tmux.conf
mkdir -p ~/.config/nvim
ln -sf "$CONFIGS_DIR/nvim/init.lua" ~/.config/nvim/init.lua

# Ghostty config (macOS only)
if [ "$OS" = "Darwin" ]; then
    mkdir -p ~/.config/ghostty
    ln -sf "$CONFIGS_DIR/ghostty/config" ~/.config/ghostty/config
fi

# Add git config include (if not already present)
if ! grep -q "path = $CONFIGS_DIR/git/.gitconfig" ~/.gitconfig 2>/dev/null; then
    echo "" >> ~/.gitconfig
    echo "[include]" >> ~/.gitconfig
    echo "	path = $CONFIGS_DIR/git/.gitconfig" >> ~/.gitconfig
fi

# macOS-specific settings
if [ "$OS" = "Darwin" ]; then
    # Faster key repeat rate (requires logout, macOS loads these at login)
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
fi

echo ""
echo "Done!"
echo ""
echo "Symlinks created:"
echo "  ~/.zshrc -> $CONFIGS_DIR/zsh/.zshrc"
echo "  ~/.tmux.conf -> $CONFIGS_DIR/tmux/.tmux.conf"
echo "  ~/.config/nvim/init.lua -> $CONFIGS_DIR/nvim/init.lua"
if [ "$OS" = "Darwin" ]; then
    echo "  ~/.config/ghostty/config -> $CONFIGS_DIR/ghostty/config"
fi
echo ""
echo "Git config included from:"
echo "  $CONFIGS_DIR/git/.gitconfig"
echo ""
echo "To apply changes, run: source ~/.zshrc"
if [ "$OS" = "Darwin" ]; then
    echo ""
    echo "NOTE: Log out and back in for key repeat settings to take effect."
fi
