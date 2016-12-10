execute pathogen#infect()
"colorscheme base16-oceanicnext
colorscheme base16-default-dark

" set the key combination of df to act as an escape
inoremap df <Esc>

syntax on
filetype plugin indent on

set tabstop=4       " The width of a TAB is set to 4.
                    " Still it is a \t. It is just that
                    " Vim will interpret it to be having
                    " a width of 4.

set shiftwidth=4    " Indents will have a width of 4

set softtabstop=4   " Sets the number of columns for a TAB

set expandtab       " Expand TABs to spaces

set relativenumber

set autoindent
set smartindent

if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
endif

" map ; to : in all modes to aviod having to press shift to enter commands
map ; :

" save current buffer after a variety of commands, ensures not having to alway
" write :w . autowrite all covers more commands than just autowrite
set autowriteall

set breakindent
let &showbreak=" ↳ "

" remap vertical movement keys so they move along each visual line in wrapped
" lines
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk
