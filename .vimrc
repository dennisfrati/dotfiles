" .vimrc by Dennis Frati
set nocompatible

function! GitBranch()
	return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
endfunction

function! StatusLineGit()
	let l:branchname = GitBranch()
	return strlen(l:branchname) > 0?'  ('.l:branchname.') ':''
endfunction

function! StslineMode()
    let l:modes = {
        \ 'n': 'NORMAL', 'i': 'INSERT', 'c': 'COMMAND',
        \ 'v': 'VISUAL', 'V': 'V-LINE', "\<C-v>": 'V-BLOCK',
        \ 'R': 'REPLACE', 's': 'SELECT', 't': 'TERM', '!': 'SHELL'
    \ }
    return get(l:modes, mode(), mode())
endfunction

set encoding=utf-8
set number
set noshowmode
filetype on
filetype plugin on
filetype indent on
syntax on
set background=dark

hi User9 ctermbg=black ctermfg=red cterm=bold
hi User8 ctermbg=white ctermfg=black
hi User7 ctermbg=red ctermfg=white cterm=bold
hi User6 ctermbg=black ctermfg=white

hi Normal       ctermbg=NONE ctermfg=15
hi LineNr       ctermbg=NONE ctermfg=240
hi CursorLine   ctermbg=236 cterm=NONE
hi CursorLineNr ctermbg=236 ctermfg=3

hi Pmenu        ctermbg=236 ctermfg=15
hi PmenuSel     ctermbg=1   ctermfg=11
hi PmenuSbar    ctermbg=240
hi PmenuThumb   ctermbg=1

hi Comment      ctermfg=242
hi Constant     ctermfg=1
hi String       ctermfg=3
hi Number       ctermfg=1
hi Function     ctermfg=11
hi Statement    ctermfg=1   cterm=bold
hi Type         ctermfg=3
hi Identifier   ctermfg=15
hi PreProc      ctermfg=9
hi Special      ctermfg=11

hi Visual       ctermbg=52  ctermfg=15

hi Search       ctermbg=3   ctermfg=0
hi IncSearch    ctermbg=11  ctermfg=0

hi StatusLine   ctermbg=236 ctermfg=1
hi StatusLineNC ctermbg=235 ctermfg=240

hi Error        ctermbg=1   ctermfg=15
hi ErrorMsg     ctermbg=1   ctermfg=15
hi WarningMsg   ctermfg=11

hi DiffAdd      ctermbg=22  ctermfg=15
hi DiffChange   ctermbg=236 ctermfg=11
hi DiffDelete   ctermbg=52  ctermfg=1
hi DiffText     ctermbg=3   ctermfg=0

hi VertSplit    ctermbg=236 ctermfg=240

set updatetime=300
set signcolumn=auto
set ignorecase
set showmatch
set hlsearch
set wildmenu
set wildmode=list:longest
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx
set laststatus=2
set statusline=
set statusline+=%9*
set statusline+=%{StatusLineGit()}
set statusline+=%7*
set statusline+=\ %{StslineMode()}
set statusline+=\ %6*
set statusline+=\ %F
set statusline+=\ %r
set statusline+=\%m
set statusline+=%=
set statusline+=%8*
set statusline+=\ %y
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\ [%{&fileformat}]
set statusline+=\ %p%%
set statusline+=\ %l:%c
set statusline+=\ 

if filereadable($HOME . '/.vim/startscreen.vim')
    source $HOME/.vim/startscreen.vim
endif

nnoremap <F4> :split<CR>:resize 10<CR>:terminal<CR>

nnoremap <F5> :vsplit<CR>:terminal<CR>

tnoremap <Esc> <C-\><C-n>

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

call plug#begin('~/.vim/plugged')
	Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nmap <leader>f <Plug>(coc-format)
