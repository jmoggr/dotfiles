execute pathogen#infect()

" COLORS

let base16colorspace=256
colorscheme base16-default-dark

" OPTIONS

" disable .netrwhist file
let g:netrw_dirhistmax = 0

let g:syntastic_mode_map = { 'mode': 'passive' }
"let b:syntastic_c_cflags = "-DVERSION=\"kl\" -I/usr/include/freetype2 -pedantic -Wall -x c -fsyntax-only -std=gnu99"

syntax on
filetype plugin indent on

" The width of a TAB is set to 4.  Still it is a \t. It is just that Vim will
" interpret it to be having a width of 4.
set tabstop=4       

" Indents will have a width of 4
set shiftwidth=4   

" Sets the number of columns for a TAB
set softtabstop=4  

" Expand TABs to spaces
set expandtab      

" Copy indent from current line when starting a new line 
set autoindent

" Smarter autoindenting based on syntax, autoindent should be on
set smartindent

" comments wrap at textwidth
set formatoptions+=c

" non comments don't wrap
set formatoptions-=t

" comment leaders are not inserted after O/o commands
set formatoptions-=o

" width of line before wrapping occurs
set textwidth=80

" show line numbers relative to the cursor in the left margin
set relativenumber

" map ; to : in all modes to aviod having to press shift to enter commands
map ; :

" save current buffer after certain commands, prevents having to run :w before a
" number of commands
set autowriteall

" Every wrapped line will continue visually indented 
set breakindent

" String to put at the start of lines that have been wrapped
let &showbreak=" ↳ "

" MAPPING

" set the key combination of df to act as an escape
inoremap df <Esc>

" remap vertical movement keys so they move along each visual line in wrapped
" lines as 
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk

" pasting from primary clipboard
inoremap <C-P> <ESC>"*pi
nnoremap <C-P> "*p
vnoremap <C-P> "*p

" pasting from secondary clipboar
inoremap <C-S-P> <ESC>"+pi
nnoremap <C-S-P> "+p
vnoremap <C-S-P> "+p

"yanking to primary clipboar
vnoremap <C-Y> "*y 

" yanking to secondary clipboar
vnoremap <C-S-Y> "+y 

" buffer movement
nmap <C-J> :bn<CR>
nmap <C-K> :bp<CR>

"autocmd VimResized * exe "normal \<c-w>="

" PLUGINS


" see ~/.vim/plugins/bclose.vim
" normally the terminal would catch a signal from CTRL-q, this can be disabled
" by stty -ixon
nnoremap <C-Q> :Kwbd<CR>

" syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0


" AUTOCMDS

augroup vimrc_autocmds
    autocmd!
    autocmd BufEnter * highlight OverLength ctermbg=18
    autocmd BufEnter * execute 'match OverLength /.\%>' . &textwidth . 'v.*/'

    autocmd VimEnter * highlight OverLength ctermbg=18
    autocmd VimEnter * execute 'match OverLength /.\%>' . &textwidth . 'v.*/'
augroup END

