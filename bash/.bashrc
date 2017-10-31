# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto --human-readable --group-directories-first'
alias edit='emacsclient -t'
PS1='[\u@\h \W]\$ '

export EDITOR="emacsclient -c"
source /opt/context/tex/setuptex > /dev/null 2>&1


# http://misc.flogisoft.com/bash/tip_colors_and_formatting
# https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
# see also 'dircolors'
# echo "\e[...mTest String\e[0m"
LS_COLORS=$LS_COLORS:'ex=1;38;5;40:di=1;38;5;05:ln=1;38;5;226:ow=1;38;5;196:' ; export LS_COLORS

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
