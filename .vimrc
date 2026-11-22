" --- Plugin Management (vim-plug) ---
call plug#begin('~/.vim/plugged')
  " Theme & Status bar
  Plug 'joshdick/onedark.vim'
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'

  " LSP (Lightweight & Powerful)
  Plug 'prabirshrestha/vim-lsp'
  Plug 'mattn/vim-lsp-settings'
  Plug 'prabirshrestha/asyncomplete.vim'
  Plug 'prabirshrestha/asyncomplete-lsp.vim'

  " Filer & Icons
  Plug 'lambdalisue/fern.vim'
  Plug 'lambdalisue/fern-git-status.vim'
  Plug 'lambdalisue/nerdfont.vim'

  " Fuzzy Finder
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
call plug#end()

" --- Basic Settings ---
set number                " Show line numbers
set cursorline            " Highlight current line
set termguicolors         " Enable True Color
set clipboard=unnamed     " Sync with OS clipboard
set ignorecase smartcase  " Intelligent case sensitivity
set mouse=a               " Enable mouse support (Crucial for Warp)
set updatetime=100        " Faster LSP response

" --- Theme ---
syntax on
colorscheme onedark
let g:airline_theme='onedark'

" Force pure black background
highlight Normal guibg=#000000 ctermbg=Black
highlight NonText guibg=#000000 ctermbg=Black
highlight EndOfBuffer guibg=#000000 ctermbg=Black

" Make sidebar/gutter black (seamless look)
highlight LineNr guibg=#000000 ctermbg=Black
highlight SignColumn guibg=#000000 ctermbg=Black
highlight FoldColumn guibg=#000000 ctermbg=Black
highlight VertSplit guibg=#000000 ctermbg=Black guifg=#333333

" Force black background in Fern
autocmd FileType fern highlight Normal guibg=#000000 ctermbg=Black | highlight NonText guibg=#000000 ctermbg=Black

" --- Keymappings (Mac Style) ---
let mapleader = "\<Space>"

" File Operations
nnoremap <Leader>w :w<CR>
nnoremap <Leader>q :q<CR>
nnoremap <Leader>Q :q!<CR>

" Filer & Finder
nnoremap <silent> <Leader>e :Fern . -drawer -toggle<CR>
nnoremap <silent> <Leader>f :Files<CR>
nnoremap <silent> <C-p>     :Files<CR>
nnoremap <silent> <Leader>/ :Rg<CR>

" Mac/Emacs style navigation in Insert mode
inoremap <C-f> <Right>
inoremap <C-b> <Left>
inoremap <C-n> <Down>
inoremap <C-p> <Up>
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-d> <Del>

" Quick Escape
inoremap jk <Esc>

" Clear search highlight with double Esc
nnoremap <Esc><Esc> :nohlsearch<CR>

" --- LSP Settings ---
function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> <f2> <plug>(lsp-rename)
    nmap <buffer> K <plug>(lsp-hover)
endfunction

augroup lsp_install
    au!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" Tab completion behavior
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"

" Fern
augroup my-fern-hijack
  autocmd!
  autocmd StdinReadPre * let s:std_in=1
  autocmd VimEnter * ++nested
        \ if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
        \   execute 'Fern ' . argv()[0] . ' -drawer' |
        \   execute 'bd 1' |
        \ endif
augroup END

" Biome
let g:lsp_format_sync_timeout = 1000
autocmd BufWritePre *.js,*.jsx,*.ts,*.tsx,*.json call execute('LspDocumentFormatSync')
