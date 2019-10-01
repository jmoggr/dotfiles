execute pathogen#infect()

" COLORS
"

let base16colorspace=256
"colorscheme base16-default-dark
colorscheme base16-default-dark

"http://vim.wikia.com/wiki/Identify_the_syntax_highlighting_group_used_at_the_cursor
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>


" OPTIONS

" disable .netrwhist file
let g:netrw_dirhistmax = 0

"let g:syntastic_mode_map = { 'mode': 'passive' }
"let b:syntastic_c_cflags = "-DVERSION=\"kl\" -I/usr/include/freetype2 -pedantic -Wall -x c -fsyntax-only -std=gnu99"
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*
"
let g:syntastic_python_checkers = ['mypy']
let g:syntastic_python_mypy_args = '-s'
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" GitGutter styling to use · instead of +/-
let g:gitgutter_sign_added = '∙'
let g:gitgutter_sign_modified = '∙'
let g:gitgutter_sign_removed = '∙'
let g:gitgutter_sign_modified_removed = '∙'

syntax on
filetype plugin indent on

" The width of a TAB is set to 4.  Still it is a \t. It is just that Vim will
" interpret it to be having a width of 4.
set tabstop=4
set list
set listchars=tab:»\ ,extends:›,precedes:‹,nbsp:·,trail:· "

set linebreak

set encoding=utf-8
set fileformats=unix,dos,mac

"set showmatch 
"set matchtime=2

" overridden by statusline
set ruler

set smartcase
set ignorecase

" keep cursor this many lines away from top/bottom
set scrolloff=15

" Indents will have a width of 4
set shiftwidth=4   

" Sets the number of columns for a TAB
set softtabstop=4  

" Expand TABs to spaces
set expandtab      

set sidescrolloff=3

"don't bother me when a fiel changes
set autoread

" Copy indent from current line when starting a new line 
set autoindent

" Smarter autoindenting based on syntax, autoindent should be on
set smartindent

" comments wrap at textwidth
set formatoptions+=c

" gq formats comments
"set formatoptions+=q

" non comments don't wrap
set formatoptions-=t

" comment leaders are not inserted after O/o commands
set formatoptions-=o

" width of line before wrapping occurs
set textwidth=80


" show the current line number on the cursror line
"set number
set nonumber
"
" show line numbers relative to the cursor in the left margin
"set relativenumber

" highlight cursor line
set cursorline

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

inoremap <C-S-P> <ESC>"*pi
nnoremap <C-S-P> "*p
vnoremap <C-S-P> "*p

"yanking to primary clipboar
vnoremap <C-Y> "*y

vnoremap <C-S-Y> "*y

" buffer movement
nmap <C-J> :bn<CR>
nmap <C-K> :bp<CR>


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

" https://stackoverflow.com/a/21434697
let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes': [],'passive_filetypes': [] }
nnoremap <C-w>E :SyntasticCheck<CR> :SyntasticToggleMode<CR>

" AUTOCMDS
augroup vimrc_autocmds
    autocmd!
    "autocmd BufEnter * highlight OverLength ctermbg=18
    "autocmd BufEnter * execute 'match OverLength /.\%>' . &textwidth . 'v.*/'

    "autocmd VimEnter * highlight OverLength ctermbg=18
    "autocmd VimEnter * execute 'match OverLength /.\%>' . &textwidth . 'v.*/'

    autocmd FileType yaml setlocal shiftwidth=2 tabstop=2 expandtab

    autocmd VimEnter * call AutoSaveWinView()

    autocmd BufLeave * call AutoSaveWinView()
    autocmd BufEnter * call AutoRestoreWinView()

    "http://vim.wikia.com/wiki/Automatically_set_screen_title
    autocmd BufEnter * let &titlestring = hostname() . '@' . $USER . ':' . $PWD . ' -- ' . "vim (" . expand("%:t") . ")"

    autocmd CursorHold * call AutoSaveWinView()
augroup END


" Save current view settings on a per-window, per-buffer basis.
function AutoSaveWinView()
    if !exists("g:SavedBufView")
        let g:SavedBufView = {}
    endif

    let g:SavedBufView[bufnr("%")] = winsaveview()

    let buf = bufnr("%")
    "echom "save " . bufnr("%") . "; line: " . g:SavedBufView[buf].lnum . "; top: " . g:SavedBufView[buf].topline 
endfunction

" Restore current view settings.
function AutoRestoreWinView()
    let buf = bufnr("%")
    if exists("g:SavedBufView") && has_key(g:SavedBufView, buf)

        "echom "restore " . bufnr("%") . "; line: " . g:SavedBufView[buf].lnum . "; top: " . g:SavedBufView[buf].topline 
        call winrestview(g:SavedBufView[buf])
    endif
endfunction



set updatetime=1000
set showtabline=0
nnoremap <C-e> :call ToggleFullscreen()<CR>        

let g:minWinCol = 142

function Inittoggle()
    let g:pastColumns = &columns

    " initialize our fullscreen tab with a vertical split
    tabedit %
    execute "normal! \<C-w>\<C-v>"

    if (&columns < g:minWinCol)
        " if the current window is not big enough to be fullscreen, switch back
        " to the minscreen tab
        tabp
    endif
endfunction

autocmd VimEnter * :call Inittoggle()
autocmd VimResized * :call ToggleFullscreen()

" the minimum number of columns in a vim window (desktop window/terminal, not vim
" window) for that window to be classified as fullscreen

set switchbuf=useopen

function HelloWorld()
    echom "hello"
endfunction

function ToggleFullscreen()
    let currentBuffer = bufnr('%')
    let win = winsaveview()

    " when the desktop window is resized by the window manager, the window is reflowed
    " before the vim resize event is fired. this means that a vim window that
    " has been squashed now has lnum == topline. There appears no way to save
    " the window state before this occurs, see the workaround at the end of the
    " function. If the vim window is not resized then we save it so that our
    " position can be restored after we change tabs

    if win.lnum != win.topline
        call AutoSaveWinView()
    endif

    " if the terminal/desktop window got bigger
    if &columns > g:minWinCol && g:pastColumns <= g:minWinCol
        let nextTabPage = tabpagenr() + 1

        " check if the next tab page would wrap to the first tab page
        if (nextTabPage > tabpagenr('$'))
            let nextTabPage = 1
        endif

        " if the current buffer is visible in the next tab
        if (index(tabpagebuflist(nextTabPage), currentBuffer) >= 0)
            " move to the next tab and focus the window of the current
            " buffer, this  preserves the previous fullscreen layout. Here sbuffer should always
            " focus a window instead of splitting because switchbuf=useopen
            " has been set and we have alreayd confirmed that the buffer is
            " visilbe in a window.
            tabn
            execute 'sbuffer ' . currentBuffer
        else
            " move to the next tab and focus use the current buffer in
            " whichever window was focussed last
            tabn
            execute 'buffer ' . currentBuffer
        endif

        execute "normal! \<C-w>="

    " if the terminal/desktop window got smaller
    elseif &columns <= g:minWinCol && g:pastColumns > g:minWinCol
        let currentBuffer = bufnr('%')

        " move to the previous (minscreen) tab
        tabp
        execute 'buffer ' . currentBuffer
    endif

    call AutoRestoreWinView()

    let g:pastColumns = &columns
endfunction

