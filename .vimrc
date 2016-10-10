execute pathogen#infect()

syntax on
filetype plugin indent on
set laststatus=2
"
set modeline
set nowritebackup
set autoindent
set ignorecase
set sm
set sw=4
set tabstop=4
set expandtab
set hlsearch
set incsearch
set smartcase
"
iab teh the
"helptags ~/.vim/doc
let g:task_paper_date_format = "%Y-%m-%d %H:%M"
"
let g:solarized_termtrans=1
let g:solarized_termcolors=256
colorscheme solarized
set background=dark
set t_ti= t_te=
let mapleader = "\<Space>"
nnoremap <Leader>o :CtrlP<CR>
:vmap <C-Up> <Plug>(expand_region_expand)
:vmap <C-Down>J <Plug>(expand_region_shrink)
"
let g:gitgutter_highlight_lines = 1
let g:gitgutter_sign_column_always = 1
set updatetime=750
let g:airline_theme = 'solarized'
let g:syntastic_check_on_open = 1
"
set runtimepath^=~/.vim/bundle/ctrlp.vim
"
"set clipboard=unnamed
" http://www.drbunsen.org/the-text-triumvirate/
" Yank text to the OS X clipboard
" noremap <leader>y "*y
" noremap <leader>yy "*Y
"
" " Preserve indentation while pasting text from the OS X clipboard
" noremap <leader>p :set paste<CR>:put  *<CR>:set nopaste<CR>
"
:nmap <Leader>l :setlocal number!<CR>
:nmap <Leader>p :set paste!<CR>
:nmap <Leader>h :nohlsearch<CR>
:nnoremap j gj
:nnoremap k gk

:nmap <Leader>n :NERDTreeToggle<CR>

" settings for ctrl-p
":let g:ctrlp_map = '<Leader>t'
:let g:ctrlp_match_window_bottom = 0
:let g:ctrlp_match_window_reversed = 0
":let g:ctrlp_custom_ignore = '\v\~$|\.(o|swp|pyc|wav|mp3|ogg|blend)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])|__init__\.py'
":let g:ctrlp_working_path_mode = 0
":let g:ctrlp_dotfiles = 0
":let g:ctrlp_switch_buffer = 0

" settings for vim-oblique
let g:oblique#incsearch_highlight_all = 1

" settings for vim-session
let g:session_autosave = 'yes'
let g:session_autoload = 'yes'
