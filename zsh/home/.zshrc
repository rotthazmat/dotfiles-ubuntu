# ~/.zshrc: executed by zsh for interactive shells

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=2000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Enable colors
autoload -U colors && colors

# Enable completion system
autoload -Uz compinit
compinit

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# enable color support of ls and also add handy aliases
if [[ -x /usr/bin/dircolors ]]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Alias definitions
if [[ -f ~/.zsh_aliases ]]; then
    . ~/.zsh_aliases
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# ps1 implementations
if [[ -f ~/.zsh-custom-data/functions.sh ]]; then
  . ~/.zsh-custom-data/functions.sh

  build_prompt() {
    PROMPT=$'\n  %F{75}%~%f'
    # PROMPT+="$(user_name_ps1)"
    # PROMPT+="$(computer_name_ps1)"
    # PROMPT+="$(battery_ps1)"
    # PROMPT+="$(date_ps1)"
    # PROMPT+="$(time_ps1)"
    # PROMPT+="$(datetime_ps1)"
    PROMPT+="$(node_ps1)"
    PROMPT+="$(php_ps1)"
    PROMPT+="$(python_ps1)"
    PROMPT+="$(mc_spigot_ps1)"
    PROMPT+="$(git_ps1)"
    PROMPT+=$'\n%F{221}$%f '
  }

  precmd() { build_prompt }
fi
# ps1 implementations end

# fnm
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --shell zsh)"
. "$HOME/.cargo/env"

PATH=~/.console-ninja/.bin:$PATH
# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH
export PATH="/usr/local/bin:$PATH"

export JAVA_HOME=/opt/jdk-21.0.4
export PATH=$PATH:$JAVA_HOME/bin

export GRADLE_HOME=/opt/gradle-8.11.1
export PATH=$PATH:$GRADLE_HOME/bin

export MAVEN_HOME=/opt/apache-maven-3.9.9
export PATH=$PATH:$MAVEN_HOME/bin
