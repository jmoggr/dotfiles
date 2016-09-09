execute pathogen#infect()
execute pathogen#helptags()

syntax enable

"autocmd! BufWritePost * Neomake!
"function! Synctex()
    "" remove 'silent' for debugging
     "execute "silent !zathura __synctex_forward " . line('.') . ":" . col('.') . ":" . bufname('%') . " " . g:syncpdf
 "endfunction
"map <C-enter> :call Synctex()<cr>

let g:airline_powerline_fonts = 1			"user powerline  fonts for airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_tabs = 0

let vim_markdown_preview_toggle=0
let vim_markdown_preview_use_xdg_open=1
let vim_markdown_preview_temp_file=1
let vim_markdown_preview_github=1
let vim_markdown_preview_browswer="firefox"

let g:sql_type_default = 'pgsql'

set background=dark
colorscheme base16-default
 
set laststatus=2 	    "enable status line even with only one window
set wildmenu
set cursorline

set relativenumber      "show relative line numbers to cursors position
set number              "show the actual line number on cursor position

set showcmd 	        "Shows the command you are currently typing in the bottom right corner
set autowriteall        "auto write when changing buffers, creating or deleteing something

set foldenable          "enable code folding 
set foldmethod=syntax   "fold on syntax blocks
set foldnestmax=1       "only fold the outermost blocks
set foldlevelstart=99    "start folding at the outermost blocks

set hlsearch            "Highlight search results
set smartcase           "ignore case unless you type in a capital letter
set incsearch           "start searching as soon as you start typing

hi Normal          ctermfg=252 ctermbg=none
set hidden
set autoindent 	"

"turns tabs into spaces
set expandtab
set shiftwidth=4
"number of spaces in tab when edditing
set softtabstop=4
"number of visual spaces per TAB
set tabstop=4

set mouse=a

set backspace=2

set autoread

set scrolloff=5

"set showmatch "show matching bracket

inoremap jj <Esc>
vnoremap jj <Esc>

nmap ; :

noremap - _
noremap _ -

noremap + =
noremap = +

set wrap 
set linebreak
set nolist
let &showbreak = '↳ ' 
set breakindent
"
"leader + space clears search highlighting
nnoremap <leader><space> :nohlsearch<CR>

nnoremap j gj
nnoremap k gk

iabbrev <// </<C-X><C-O>

nnoremap <space> za     "space toggles code folding

"controls for window and buffer movement
nnoremap <C-h> <C-W>h           
nnoremap <C-l> <C-W>l           
nnoremap <C-n> :enew<CR>        
nnoremap <C-k> :bprevious<CR>   
nnoremap <C-j> :bnext<CR>       
nnoremap <C-q> :Kwbd<CR>        

nnoremap <C-f> :call ToggleFullscreen()<CR>        

filetype plugin indent on

function Inittoggle()
    let g:pastColumns = &columns
endfunction

autocmd FileType yaml setlocal shiftwidth=2 tabstop=2 expandtab
autocmd VimEnter * :call Inittoggle()


function ToggleFullscreen()
    if &columns > 137 && g:pastColumns <= 137
        if tabpagenr("$") != 1
            tabn
            execute "normal! \<C-w>="
        else
            tabedit %
        endif
    elseif &columns <= 137 && g:pastColumns > 137
        if tabpagenr("$") != 1
            tabp
        else
            tabedit %
        endif
    endif

    let g:pastColumns = &columns
endfunction


"autocmd VimResized * :call ToggleFullscreen()

autocmd FileType gitcommit set tw=72
