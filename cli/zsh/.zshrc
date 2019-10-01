
# disable signal generated from ctrl-q, the keybinding is recycled in vim
stty -ixon

#remove duplicate values from PATH for all path interfaces
typeset -U PATH path

export VISUAL="vim"
export EDITOR="vim"

alias ls='ls --color=auto --human-readable --group-directories-first'
alias history_grep=' cat $HISTFILE | cut -d";" -f2- | grep --color --ignore-case --perl-regexp '
alias mpv='mpv --video-unscaled --hwdec=cuda'
alias tree='tree --dirsfirst'

#
# http://misc.flogisoft.com/bash/tip_colors_and_formatting
# https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
# see also 'dircolors'
LS_COLORS=$LS_COLORS:'ex=1;38;5;40:di=1;38;5;05:ln=1;38;5;226:ow=1;38;5;196:' ; export LS_COLORS

# https://askubuntu.com/questions/54145/how-to-fix-strange-backspace-behaviour-with-urxvt-zsh
# backspace and term colors
TERM=xterm-256color

setopt nobeep

alias ls='ls --color=auto --human-readable --group-directories-first'

export HISTFILE=$HOME/.zsh_history
export SAVEHIST=1000000
export HISTSIZE=1000000
export HISTFILESIZE=1000000

# Write the history file in the ":start:elapsed;command" format.
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_SPACE

# do not display line previously found while searching history
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY

bindkey -e

# search through history starting at cursor 
# http://unix.stackexchange.com/questions/97843/how-can-i-search-history-with-what-is-already-entered-at-the-prompt-in-zsh
# bindkey "^j" history-beginning-search-backward
# bindkey "^k" history-beginning-search-forward
bindkey "${terminfo[knp]}" history-beginning-search-backward
bindkey "${terminfo[kpp]}" history-beginning-search-forward

bindkey "^a" vi-beginning-of-line
bindkey "^e" end-of-line

bindkey "^r" history-incremental-pattern-search-backward

bindkey '^n' history-incremental-search-backward
bindkey '^p' history-incremental-search-forward


# base16 scripts don't support linux console (tty)
if [ "${TERM%%-*}" != 'linux' ]; then
    source ~/.config/base16-default-dark.sh
fi

setopt PROMPT_SUBST

# use vi keybindings and modes in the line editor
#bindkey -v

# When changing to cmd mode for vi editing we want to update the prompt to show
# that we are in cmd mode. However redrawing the prompt only redraws one line,
# so this updating would visually break multiline prompts. However if the first
# line is static, we can print that prompt line statically and only update the
# second line dynamically.

# https://unix.stackexchange.com/a/9607
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    machine_name=$'%F{226}%m%f'
else
    machine_name=$'%F{241}%m%f'
fi

if [ "$EUID" -ne 0 ]; then
    user_name='%F{241}%n%f'
else
    user_name='%F{226}%n%f'
fi

prompt_top='%F{016}┌─%f'$user_name'@'$machine_name':%~'

# Print the first line of prompt before the actual prompt is displayed. This
# line is static
# http://superuser.com/questions/974908/multiline-rprompt-in-zsh
precmd() {
    printf '\n'

    t="0.00"
    if [ $timer ]; then
        t2=$(print -P "%D{%s%2.}")
        diff=$((t2 - timer))
        float diff=$diff
        t=$(printf "%.2f" $((diff/100.0)))
        unset timer
    fi

    RPROMPT="%(?..%F{196}%?%f )%F{103}$t%f $user_name%F{241}@%f$machine_name"

    # print $timer
    # use the zsh print builtin, -P prints to the input of the coprocess,
    # allowing exapnsion of prompt string
    print -P "%F{004}%~%f"
}

# sets the name of the window after a command is entered
preexec() {
    timer=$(print -P "%D{%s%2.}")

    echo -ne "\033]0;'"${USER}@${HOST}:${PWD} -- $1"'\007" 
}

# Set the second line of prompt, this is the actual prompt
if [ "$EUID" -ne 0 ]; then
    PROMPT='%F{040} %f'
else
    PROMPT='%F{016}└─%f# '
fi


# use vi keybindings and enable vi modes

# display whether or not the prompt is in normal (cmd) mode
#https://dougblack.io/words/zsh-vi-mode.html
function zle-line-init zle-keymap-select {
    # TODO: figure out why the rprompt is not displayed on the first prompt of
    # a new terminal
    #VIM_PROMPT="%F{049}[NORMAL]%{$reset_color%}"
    #RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}"
    #zle reset-prompt
}

# event hooks to change vi mode indicator
#zle -N zle-line-init
#zle -N zle-keymap-select

# Removes delay when escaping viins with the esc key, but breaks multikey
# escape sequences
#export KEYTIMEOUT=1

# use 'df' to exit vi insert mode
# http://superuser.com/questions/351499/how-to-switch-comfortably-to-vi-command-mode-on-the-zsh-command-line
#bindkey -M viins 'df' vi-cmd-mode



ctrlz () {
    # if [[ $#BUFFER -eq 0 ]] && [[ "$(jobs | wc -l)" -ne 0 ]]; then
    zle push-input
    zle redisplay
    fg
  # else
  # fi
}

ctrle () {
    zle push-input
    # echo 1 >> /home/jason/ctrle.txt
    # fg 2>&1 > /dev/null
}

zle -N ctrlz
# zle -N ctrle
bindkey '^Z' ctrlz
# bindkey '^E' ctrle

#source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
