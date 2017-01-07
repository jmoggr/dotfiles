
# disable signal generated from ctrl-q, the keybinding is recycled in vim
stty -ixon

export VISUAL="vim"
export EDITOR="vim"
alias ls='ls --color=auto --human-readable --group-directories-first'
#
# http://misc.flogisoft.com/bash/tip_colors_and_formatting
# https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
# see also 'dircolors'
LS_COLORS=$LS_COLORS:'ex=1;38;5;40:di=1;38;5;05:ln=1;38;5;226:ow=1;38;5;196:' ; export LS_COLORS

setopt nobeep

alias ls='ls --color=auto --human-readable --group-directories-first'

export HISTFILE=$HOME/.zsh_history
export SAVEHIST=100000
export HISTSIZE=100000
export HISTFILESIZE=100000

# Write the history file in the ":start:elapsed;command" format.
setopt EXTENDED_HISTORY

# do not display line previously found while searching history
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY

# search through history starting at cursor 
# http://unix.stackexchange.com/questions/97843/how-can-i-search-history-with-what-is-already-entered-at-the-prompt-in-zsh
bindkey "^j" history-beginning-search-backward
bindkey "^k" history-beginning-search-forward

bindkey "^a" vi-beginning-of-line
bindkey "^e" end-of-line

bindkey "^r" history-incremental-pattern-search-backward

bindkey '^n' history-incremental-search-backward
bindkey '^p' history-incremental-search-forward

./.config/base16-shell/scripts/base16-default-dark.sh

setopt PROMPT_SUBST

# use vi keybindings and modes in the line editor
bindkey -v

# When changing to cmd mode for vi editing we want to update the prompt to show
# that we are in cmd mode. However redrawing the prompt only redraws one line,
# so this updating would visually break multiline prompts. However if the first
# line is static, we can print that prompt line statically and only update the
# second line dynamically.

# Print the first line of prompt before the actual prompt is displayed. This
# line is static
#http://superuser.com/questions/974908/multiline-rprompt-in-zsh
precmd() {
    # TODO: find out what print -P does
    print -P $'%F{016}┌─%f%(!.%F{001}%n%f.%F{002}%n%f)@%F{004}%m%f:%{$fg_bold[white]%}%~%{$reset_color%}'
}

# Set the second line of prompt, this is the actual prompt
PROMPT=$'%F{016}└─%f$ '

# use vi keybindings and enable vi modes

# display whether or not the prompt is in normal (cmd) mode
#https://dougblack.io/words/zsh-vi-mode.html
function zle-line-init zle-keymap-select {
    VIM_PROMPT="%F{049}[NORMAL]%{$reset_color%}"
    RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}"
    zle reset-prompt
}

# event hooks to change vi mode indicator
zle -N zle-line-init
zle -N zle-keymap-select

# Removes delay when escaping viins with the esc key, but breaks multikey
# escape sequences
#export KEYTIMEOUT=1

# use 'df' to exit vi insert mode
# http://superuser.com/questions/351499/how-to-switch-comfortably-to-vi-command-mode-on-the-zsh-command-line
bindkey -M viins 'df' vi-cmd-mode



ctrlz () {
  if [[ $#BUFFER -eq 0 ]]; then
    fg
    zle redisplay
  else
    zle push-input
  fi
}
zle -N ctrlz
bindkey '^Z' ctrlz

#source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
