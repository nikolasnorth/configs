# alias
alias ll='ls -la'
alias gits='git status'
alias gitau='git add -u'
alias gitc='git commit'

# customize prompt
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
PROMPT="%F{green}%n%f %F{blue}%~%f${vcs_info_msg_0_} | "

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
