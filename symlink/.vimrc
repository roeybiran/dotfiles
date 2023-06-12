" show syntax highlighting
syntax on
" https://github.com/sickill/vim-monokai
" syntax enable
colorscheme monokai

" show line numbers
set number

" disable compatible mode
set nocompatible

" disable unsaved buffer prompt
set hidden

" unnamed register defaults to system pasteboard
set clipboard=unnamed

" also increment letters
set nrformats+=alpha

" smart case searching
set ignorecase smartcase

" highlight line containing the cursor
set cursorline

" modal cursors
" Terminal
let &t_SI.="\e[5 q" "SI = INSERT mode
let &t_SR.="\e[4 q" "SR = REPLACE mode
let &t_EI.="\e[1 q" "EI = NORMAL mode (ELSE)

" iTerm2
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_SR = "\<Esc>]50;CursorShape=2\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"
