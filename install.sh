#!/bin/bash

set -e

# Parse arguments
MODE=""
for arg in "$@"; do
    case $arg in
        --home) MODE="home" ;;
        --work) MODE="work" ;;
    esac
done

if [ -z "$MODE" ]; then
    echo "Usage: ./install.sh --home | --work"
    echo "  --home  Install all tools including personal ones (Claude Code)"
    echo "  --work  Install shared tools only"
    exit 1
fi

CONFIGS_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

echo "Installing configs from $CONFIGS_DIR (mode: $MODE)"
echo "Detected OS: $OS"

# Install Homebrew (macOS only)
if [ "$OS" = "Darwin" ]; then
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# Install tools via Homebrew (if available)
if command -v brew &> /dev/null; then
    echo "Installing tools..."
    brew install bat fd fzf git-delta neovim ripgrep tmux zsh

    # macOS-only casks
    if [ "$OS" = "Darwin" ]; then
        brew install --cask ghostty raycast
    fi

    # Home-only tools
    if [ "$MODE" = "home" ]; then
        curl -fsSL https://claude.ai/install.sh | bash
    fi
else
    echo "Homebrew not found. Please install prerequisites manually (see TODO.md)"
fi

# Clone fzf-git.sh (if not already present)
if [ ! -d ~/.config/fzf-git.sh ]; then
    echo "Cloning fzf-git.sh..."
    git clone https://github.com/junegunn/fzf-git.sh.git ~/.config/fzf-git.sh
fi

# Back up existing config files if they're real files (not symlinks)
if [ -f ~/.zshrc ] && [ ! -L ~/.zshrc ]; then
    cp ~/.zshrc ~/.zshrc.backup
    echo "Backed up existing ~/.zshrc to ~/.zshrc.backup"
fi

# Create symlinks (both macOS and Linux)
echo "Creating symlinks..."
ln -sf "$CONFIGS_DIR/zsh/.zshrc" ~/.zshrc
ln -sf "$CONFIGS_DIR/tmux/.tmux.conf" ~/.tmux.conf
mkdir -p ~/.config/nvim
ln -sf "$CONFIGS_DIR/nvim/init.lua" ~/.config/nvim/init.lua
mkdir -p ~/.config/bat
ln -sf "$CONFIGS_DIR/bat/config" ~/.config/bat/config
mkdir -p ~/.claude
ln -sf "$CONFIGS_DIR/claude/settings.json" ~/.claude/settings.json

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

# Firefox profile setup (macOS only)
if [ "$OS" = "Darwin" ]; then
    FIREFOX_PROFILE=~/.mozilla/firefox/profiles/nikolas
    FIREFOX_BIN="/Applications/Firefox.app/Contents/MacOS/firefox"

    # Create Firefox profile if it doesn't exist
    if [ ! -d "$FIREFOX_PROFILE" ]; then
        echo "Creating Firefox profile..."
        "$FIREFOX_BIN" -CreateProfile "nikolas $FIREFOX_PROFILE"
    fi

    # Try to download latest userChrome.css, fall back to local copy
    CHROME_URL="https://raw.githubusercontent.com/jonhoo/configs/master/gui/.mozilla/firefox/chrome/userChrome.css"
    mkdir -p "$FIREFOX_PROFILE/chrome"
    if curl -fsSL "$CHROME_URL" -o "$CONFIGS_DIR/firefox/userChrome.css" 2>/dev/null; then
        echo "Downloaded latest userChrome.css"
    else
        echo "Download failed, using local copy"
    fi
    ln -sf "$CONFIGS_DIR/firefox/userChrome.css" "$FIREFOX_PROFILE/chrome/userChrome.css"
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
    echo ""
    echo "Firefox setup:"
    echo "  1. Open Firefox and go to about:profiles"
    echo "  2. Set 'nikolas' as the default profile"
    echo "  3. Go to about:config and set:"
    echo "     toolkit.legacyUserProfileCustomizations.stylesheets = true"
    echo "  4. Install extensions:"
    echo "     - Vimium C: https://addons.mozilla.org/en-US/firefox/addon/vimium-c/"
    echo "     - Dark Reader: https://addons.mozilla.org/en-US/firefox/addon/darkreader/"
    echo "     - uBlock Origin: https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/"
    echo "     - Gruvbox Material Theme: https://addons.mozilla.org/en-US/firefox/addon/gruvbox-material-theme/"
    echo ""
    echo "Raycast: Open Raycast to complete setup"
fi
