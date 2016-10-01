
export TERM="vt100"
export VISUAL="nvim"
export EDITOR="nvim"

alias ls='ls --color=auto --human-readable --group-directories-first'
#
# http://misc.flogisoft.com/bash/tip_colors_and_formatting
# https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
# see also 'dircolors'
# echo "\e[...mTest String\e[0m"
LS_COLORS=$LS_COLORS:'ex=1;38;5;40:di=1;38;5;05:ln=1;38;5;226:ow=1;38;5;196:' ; export LS_COLORS

setopt nobeep


export HISTFILE=$HOME/.zsh_history
export SAVEHIST=10000
export HISTSIZE=10000
export HISTFILESIZE=10000

setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY





export LANG=en_CA.UTF-8


setopt PROMPT_SUBST

PROMPT=$'%F{003}┌─%f%(!.%F{001}%n%f.%F{002}%n%f)@%F{004}%m%f:%{$fg_bold[white]%}%~%{$reset_color%}\n%F{003}└─%f$ '

#function mode-coloring {
    #if [[ "$KEYMAP" == "vicmd" ]]; then
        #PROMPT=$'%F{005}┌─%f%(!.%F{001}%n%f.%F{002}%n%f)@%F{004}%m%f:%{$fg_bold[white]%}%~%{$reset_color%}\n%F{005}└─%f$ '
    #else
        #PROMPT=$'%F{003}┌─%f%(!.%F{001}%n%f.%F{002}%n%f)@%F{004}%m%f:%{$fg_bold[white]%}%~%{$reset_color%}\n%F{003}└─%f$ '
    #fi

    #zle reset-prompt
#}



##bindkey -v

#ctrlz () {
  #if [[ $#BUFFER -eq 0 ]]; then
    #fg
    #zle redisplay
  #else
    #zle push-input
  #fi
#}
#zle -N ctrlz
#zle -N zle-line-input mode-coloring
#zle -N zle-keymap-select mode-coloring
#bindkey '^Z' ctrlz
#bindkey -v
#export KEYTIMEOUT=1

#bindkey '^[[A' history-substring-search-up
#bindkey '^[[B' history-substring-search-down


#source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND=''
#export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND=''
#export HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS=''
#source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
