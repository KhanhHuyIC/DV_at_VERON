
call plug#begin('~/.vim/plugged')
Plug 'vhda/verilog_systemverilog.vim'
Plug 'morhetz/gruvbox'
call plug#end()

syntax on
filetype plugin indent on
"N MANAGEMENT ===
call plug#begin('~/.vim/plugged')
"
"" " UI Improvements
Plug 'vim-airline/vim-airline'             " Status bar
Plug 'vim-airline/vim-airline-themes'       " Themes for airline
"Plug 'morhetz/gruvbox'                      " Gruvbox color scheme

" File Explorer & Navigation
Plug 'preservim/nerdtree'                   " File explorer
Plug 'junegunn/fzf'                         " Fuzzy finder
Plug 'junegunn/fzf.vim'
"
" " Code Editing Enhancements
Plug 'jiangmiao/auto-pairs'                 " Auto-close brackets/quotes
Plug 'tpope/vim-commentary'                 " Comment toggling
Plug 'sheerun/vim-polyglot'                 " Syntax highlighting for many language
Plug 'neoclide/coc.nvim', {'branch': 'release'}  " Auto-completion & LSP
" support
"
" " Git Integration
Plug 'tpope/vim-fugitive'                   " Git commands inside Vim
"
" call plug#end()
"
" " === GENERAL SETTINGS ===
syntax enable
set number            " Show line numbers
set norelativenumber    " Relative line numbers
set tabstop=4        " Set tab width to 4 spaces
set shiftwidth=4      " Auto-indent width
set expandtab         " Convert tabs to spaces
set autoindent       " Auto-indent new lines
set cursorline        " Highlight the current line
set scrolloff=5       " Keep 5 lines visible when scrolling
set ttyfast
set mouse=a
"
" " === UI CUSTOMIZATION ===
set background=dark
colorscheme gruvbox
let g:airline_powerline_fonts = 1  " Enable powerline fonts
"
" " === KEYBINDINGS ===
nnoremap <C-n> :NERDTreeToggle<CR>  " Toggle NERDTree with Ctrl+n
nnoremap <C-p> :Files<CR>           " Open FZF file search with Ctrl+p
nnoremap <C-b> :Buffers<CR>         " Switch between buffers
nnoremap <C-c> :w<CR>               " Save file with Ctrl+c
nnoremap <C-q> :q!<CR>              " Quit without saving

" === PLUGIN CONFIGURATIONS ===
" Auto-pairs settings
let g:AutoPairsFlyMode = 1

" NERDTree settings
let g:NERDTreeShowHidden=1

" CoC.nvim (Auto-completion) settings
"let g:coc_global_extensions = ['coc-json', 'coc-tsserver', 'coc-python',
"'coc-clangd']

" Git commands inside Vim
nnoremap <leader>gs :Git status<CR>
nnoremap <leader>gc :Git commit<CR>
nnoremap <leader>gp :Git push<CR>

"N MANAGEMENT ===
call plug#begin('~/.vim/plugged')

" Language Support
Plug 'vhda/verilog_systemverilog.vim'

" Theme
Plug 'morhetz/gruvbox'

" UI Improvements
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" File Explorer & Navigation
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

" Code Editing Enhancements
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-commentary'
Plug 'sheerun/vim-polyglot'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Git Integration
Plug 'tpope/vim-fugitive'

call plug#end()

" === GENERAL SETTINGS ===
syntax enable
filetype plugin indent on
set nu
set norelativenumber
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set cursorline
set scrolloff=5
set mouse=a

" === UI CUSTOMIZATION ===
set background=dark
colorscheme gruvbox
let g:airline_powerline_fonts = 1

" === KEYBINDINGS ===
nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <C-p> :Files<CR>
nnoremap <C-b> :Buffers<CR>
nnoremap <C-c> :w<CR>
nnoremap <C-q> :q!<CR>

" === PLUGIN CONFIGURATIONS ===
let g:AutoPairsFlyMode = 1
let g:NERDTreeShowHidden=1

" Optional: Enable CoC extensions
" let g:coc_global_extensions = ['coc-json', 'coc-tsserver', 'coc-python',
"'coc-clangd']

" Git mappings
nnoremap <leader>gs :Git status<CR>
nnoremap <leader>gc :Git commit<CR>
nnoremap <leader>gp :Git push<CR>

