call plug#begin('~/.vim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'scrooloose/nerdtree'
Plug 'sheerun/vim-polyglot'
Plug 'kien/rainbow_parentheses.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'yggdroot/indentline'
Plug 'gmoe/vim-espresso'
Plug 'jamshedvesuna/vim-markdown-preview'
Plug 'tpope/vim-fugitive'
Plug 'valloric/vim-indent-guides'
Plug 'sheerun/vim-polyglot'
Plug 'sainnhe/everforest'
Plug 'joshdick/onedark.vim'
Plug 'dracula/vim'
Plug 'prettier/vim-prettier'
Plug 'rstacruz/vim-closer'
"Plug 'tpope/vim-surround'
"Plug 'wakatime/vim-wakatime'
"Plug 'wfxr/minimap.vim'
""Plug 'tmhedberg/simpylfold'
Plug 'terryma/vim-multiple-cursors'
Plug 'connorholyday/vim-snazzy'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'ryanoasis/vim-devicons'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'jiangmiao/auto-pairs'
"Plug 'ludovicchabant/vim-gutentags'
"Plug 'kristijanhusak/vim-js-file-import', {'do': 'npm install'}
call plug#end()


" snazzy
let g:SnazzyTransparent = 1

"airline
let g:airline_theme='base16_snazzy'

"INDENTLINE
let g:indentLine_char = '┊'
set list lcs=tab:\┊\ 

" vim
syntax on
set number
set relativenumber
set tabstop=2
set shiftwidth=2
set autoindent
set cursorline
set smartindent
set expandtab
"set background=dark
"set cursorcolumn
"set foldmethod=manual
set clipboard=unnamed
colorscheme snazzy
set wildmode=longest,list,full
set wildmenu
set mouse=a

" nerdtree
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap nn :NERDTreeFocus<CR>
nnoremap <C-r> :NERDTreeRefreshRoot<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

"prettier
nnoremap <C-s> :Prettier<CR> \| :w<CR>
nnoremap ss :Prettier<CR> \| :w<CR>

" Type jj to exit insert mode quickly.
inoremap jj <Esc>

" fzf
" " Ctrl+P: cari file di direktori
silent! nmap <C-P> :Files<CR>

" Ctrl+G: cari file di repository
silent! namp <C-G> :GFiles<CR>

" Ctrl+F: cari file berdasarkan string/regex
silent! nmap <C-f> :Rg!

" vim-airline
let g:airline#extensions#tabline#enabled = 1
nnoremap <C-h> :bprevious<CR>
nnoremap <C-l> :bnext<CR>
nnoremap <C-k> :bfirst<CR>
nnoremap <C-j> :blast<CR>
nnoremap <C-d> :bdelete<CR>

" minimap
let g:minimap_width = 10
let g:minimap_auto_start = 0
let g:minimap_auto_start_win_enter = 1

set nobackup
set nowritebackup

" Start NERDTree and leave the cursor in it.
" autocmd VimEnter * NERDTree

inoremap <silent><expr> <TAB>
  \ coc#pum#visible() ? coc#pum#next(1):
  \ CheckBackspace() ? "\<Tab>" :
  \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
    noremap <silent><expr> <c-space> coc#refresh()
  else
    inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" " Use `:CocDiagnostics` to get all diagnostics of current buffer in location
" list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')
