### go
# Set custom GOPATH (originally defaulted to: `$HOME/go/`.
# This new path is the location of the homebrew installation of go.
# GOPATH is the root workspace and contains the following folders:
#	- src/ location of Go source code
#	- pkg/ location of compiled package code
# 	- bin/ location of compiled executable programs build by Go
export GOPATH=/opt/homebrew/opt/go
# Add it to the default PATH to make running binaries easier.
export PATH=$PATH:$GOPATH/bin

### java
export JAVA_HOME=~/Library/Java/JavaVirtualMachines/graalvm-jdk-21+35.1/Contents/Home
export PATH=$PATH:$JAVA_HOME
export PATH=~/Library/Java/JavaVirtualMachines/graalvm-jdk-21+35.1/Contents/Home/bin:$PATH

### aliases

alias ll="ls -la"
alias gits="git status"

### customize prompt

# load version control info
autoload -Uz vcs_info

# separate each command by a newline
NEWLINE=$'\n'

# hook before command executes
precmd() {
	vcs_info
	print -rP "${NEWLINE}%B%~%b ${vcs_info_msg_0_}"
}

# format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git:*' formats 'on %U%b%u'
setopt PROMPT_SUBST

# override the default prompt
PROMPT='nikolas %F{046}→%f '

# zsh auto-suggestions
# mkdir -p ~/.zsh/zsh-autosuggestions/ && git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.zsh/zsh-autosuggestions/
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# enable coloured output
export CLICOLOR=1

