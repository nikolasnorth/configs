#!/usr/bin/env bash

set -euo pipefail

usage() {
    echo "Usage: ./install.sh [--personal]"
    echo "  no argument  Link shared configuration"
    echo "  --personal   Also link personal shell and Claude configuration"
}

PERSONAL=0
case "$#" in
    0) ;;
    1)
        case "$1" in
            --personal) PERSONAL=1 ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                usage >&2
                exit 1
                ;;
        esac
        ;;
    *)
        usage >&2
        exit 1
        ;;
esac

CONFIGS_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

next_backup_path() {
    local target="$1"
    local backup="${target}.backup"
    local suffix=1

    while [ -e "$backup" ] || [ -L "$backup" ]; do
        backup="${target}.backup.${suffix}"
        suffix=$((suffix + 1))
    done

    printf '%s\n' "$backup"
}

link_config() {
    local source="$1"
    local target="$2"
    local backup

    if [ ! -e "$source" ] && [ ! -L "$source" ]; then
        echo "Missing source: $source" >&2
        return 1
    fi

    mkdir -p "$(dirname "$target")"

    if [ -L "$target" ]; then
        if [ "$(readlink "$target")" = "$source" ]; then
            echo "Already linked: $target"
            return
        fi
        unlink "$target"
    elif [ -e "$target" ]; then
        backup="$(next_backup_path "$target")"
        mv "$target" "$backup"
        echo "Backed up: $target -> $backup"
    fi

    ln -s "$source" "$target"
    echo "Linked: $target -> $source"
}

echo "Linking shared configs from $CONFIGS_DIR"

link_config "$CONFIGS_DIR/nvim/init.lua" "$HOME/.config/nvim/init.lua"
link_config "$CONFIGS_DIR/bat/config" "$HOME/.config/bat/config"
link_config "$CONFIGS_DIR/git/.gitconfig" "$HOME/.config/git/config"
link_config "$CONFIGS_DIR/herdr/config.toml" "$HOME/.config/herdr/config.toml"
link_config "$CONFIGS_DIR/hunk/config.toml" "$HOME/.config/hunk/config.toml"
link_config "$CONFIGS_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
link_config "$CONFIGS_DIR/tmux/scripts" "$HOME/.config/tmux/scripts"

# Environment-specific overlays can own these entry points instead.
if [ "$PERSONAL" -eq 1 ]; then
    link_config "$CONFIGS_DIR/zsh/.zshrc" "$HOME/.zshrc"
    link_config "$CONFIGS_DIR/claude/settings.json" "$HOME/.claude/settings.json"
    link_config "$CONFIGS_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
fi

if [ "$OS" = "Darwin" ]; then
    link_config "$CONFIGS_DIR/ghostty/config" "$HOME/.config/ghostty/config"
fi

echo "Done. Install applications and command-line dependencies separately."
