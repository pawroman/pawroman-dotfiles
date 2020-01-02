" Set default encoding
set enc=utf8

" Show line numbers
set nu
set foldcolumn=1    " Adds extra margin on the left

" Use Unix as standard file type
set ffs=unix,dos,mac

" Auto indent, smart indent, wrap lines
set ai
set si
set wrap

" 1 tab = 4 spaces
set shiftwidth=4
set tabstop=4

" Use spaces instead of tabs
set expandtab
set smarttab

" Syntax and filetype
syntax enable
filetype plugin on
filetype indent on

" Status line - always show
set laststatus=2
set statusline=\ %F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ L:\ %l\ C:\ %c

" How many lines of history to remember
set history=500

" Auto read when a file is changed from outside
set autoread

" :W for sudo save
command W w !sudo tee % > /dev/null

" UI
" 7 Lines to cursor
set so=7

set wildmenu
set wildignore=*.o,*~,*.pyc,*/.git

set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Search
set ignorecase
set smartcase
set hlsearch
set incsearch

" Redraw macros lazily
set lazyredraw

" Show matching brackets
set showmatch

" No bells
set noerrorbells
set novisualbell

