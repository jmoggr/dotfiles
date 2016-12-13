
export TERM="rxvt-unicode-256color"
export VISUAL="emacsclient -t"
export EDITOR="emacsclient -t"

alias ls='ls --color=auto --human-readable --group-directories-first'
#
# http://misc.flogisoft.com/bash/tip_colors_and_formatting
# https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
# see also 'dircolors'
LS_COLORS=$LS_COLORS:'ex=1;38;5;40:di=1;38;5;05:ln=1;38;5;226:ow=1;38;5;196:' ; export LS_COLORS

setopt nobeep
alias edit='emacsclient -t'

alias ls='ls --color=auto --human-readable --group-directories-first'

export HISTFILE=$HOME/.zsh_history
export SAVEHIST=10000
export HISTSIZE=10000
export HISTFILESIZE=10000

# Write the history file in the ":start:elapsed;command" format.
setopt EXTENDED_HISTORY

# do not display line previously found while searching history
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY

# search through history starting at cursor 
# http://unix.stackexchange.com/questions/97843/how-can-i-search-history-with-what-is-already-entered-at-the-prompt-in-zsh
# autoload -U history-search-encd
# zle -N history-beginning-search-backward-end history-search-end
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

setopt PROMPT_SUBST

PROMPT=$'%F{016}┌─%f%(!.%F{001}%n%f.%F{002}%n%f)@%F{004}%m%f:%{$fg_bold[white]%}%~%{$reset_color%}\n%F{016}└─%f$ '

./.config/base16-shell/scripts/base16-default-dark.sh

#BASE16_SHELL=$HOME/.config/base16-shell/
#[ -n "$PS1" ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"
#function mode-coloring {
    #if [[ "$KEYMAP" == "vicmd" ]]; then
        #PROMPT=$'%F{005}┌─%f%(!.%F{001}%n%f.%F{002}%n%f)@%F{004}%m%f:%{$fg_bold[white]%}%~%{$reset_color%}\n%F{005}└─%f$ '
    #else
        #PROMPT=$'%F{003}┌─%f%(!.%F{001}%n%f.%F{002}%n%f)@%F{004}%m%f:%{$fg_bold[white]%}%~%{$reset_color%}\n%F{003}└─%f$ '
    #fi

    #zle reset-prompt
#}



##bindkey -v

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

#zle -N zle-line-input mode-coloring
#zle -N zle-keymap-select mode-coloring
#bindkey '^Z' ctrlz
#bindkey -v
#export KEYTIMEOUT=1

#source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND=''
#export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND=''
#export HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS=''
#source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
