# source pre-config if exists (for stuff that must be at top)
[[ -f ~/.zshrc.pre ]] && source ~/.zshrc.pre

# alias
alias ll='ls -la'
alias gits='git status'
alias gitau='git add -u'
alias gitc='git commit'

# customize prompt
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
setopt PROMPT_SUBST
PROMPT='%F{green}%n%f %F{blue}%~%f${vcs_info_msg_0_} | '

# better globbing
setopt EXTENDED_GLOB

# share previous commands across sessions
HISTSIZE=5000        # in-memory history
SAVEHIST=10000       # saved-to-disk history
HISTFILE=~/.zsh_history
setopt APPEND_HISTORY # don't overwrite history, append instead
setopt SHARE_HISTORY  # enable

# inline suggestions based on history
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward

# use neovim as default editor
export EDITOR="nvim"
export VISUAL="nvim"

# fzf - fuzzy finder
eval "$(fzf --zsh)"
source ~/.config/fzf-git.sh/fzf-git.sh

# use fd with fzf
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_DEFAULT_OPTS="--bind=ctrl-j:down,ctrl-k:up"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# fd for fzf path completion
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# fd for fzf directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# add ~/.local/bin to PATH (used by Claude Code native install)
export PATH="$HOME/.local/bin:$PATH"

# source local config if exists (for machine-specific stuff)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
