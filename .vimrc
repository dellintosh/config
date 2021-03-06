" Author: John Anderson (sontek@gmail.com)

" Don't load plugins if we aren't in Vim7
if version < 700
	set noloadplugins
endif

"" Skip this file unless we have +eval
if 1

""" Settings
set nocompatible						" Don't be compatible with vi

""" Pathogen stuff!
filetype off
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

set guifont=Inconsolata:h18
set guioptions-=T

function! Tabstyle_tabs()
	" Using 4 column tabs
	set softtabstop=2
	set shiftwidth=2
	set tabstop=2
	set expandtab
	autocmd User Rails set softtabstop=2
	autocmd User Rails set shiftwidth=2
	autocmd User Rails set tabstop=2
	autocmd User Rails set expandtab
endfunction

function! Tabstyle_spaces()
	" Use 2 spaces
	set softtabstop=2
	set shiftwidth=2
	set tabstop=2
	set expandtab
endfunction

call Tabstyle_spaces()

" Indenting
" *******************************************************************
 set ai " Automatically set the indent of a new line (local to buffer)
 set si " smartindent  (local to buffer)


" " Scrollbars
" ******************************************************************
 set sidescrolloff=2
 set numberwidth=4


" " Windows
" *********************************************************************
 set equalalways " Multiple windows, when created, are equal in size
 set splitbelow splitright

 "Vertical split then hop to new buffer
 :noremap ,v :vsp^M^W^W<cr>
 :noremap ,h :split^M^W^W<cr>


 " Cursor highlights
" ***********************************************************
 set cursorline
 "set cursorcolumn


"""" Movement
" work more logically with wrapped lines
noremap j gj
noremap k gk

set nowrap

"""" Searching and Patterns
set ignorecase							" search is case insensitive
set smartcase							" search case sensitive if caps on
set incsearch							" show best match so far
set hlsearch							" Highlight matches to the search

"""" Display
set lazyredraw							" Don't repaint when scripts are running
set scrolloff=5							" Keep 3 lines below and above the cursor
set ruler								" line numbers and column the cursor is on
set number								" Show line numbering
set numberwidth=1						" Use 1 col + 1 space for numbers
"colorscheme tango						" Use tango colors
colorscheme ir_black					" Use the ir_black theme from http://blog.infinitered.com/entries/show/8%3C%7B%7D%3E
set background=light                    " I use light background

" tab labels show the filename without path(tail)
set guitablabel=%N/\ %t\ %M

""" Windows
if exists(":tab")						" Try to move to other windows if changing buf
	set switchbuf=useopen,usetab
else									" Try other windows & tabs if available
		set switchbuf=useopen
endif

"""" Messages, Info, Status
set shortmess+=a						" Use [+] [RO] [w] for modified, read-only, modified
set showcmd								" Display what command is waiting for an operator
set ruler								" Show pos below the win if there's no status line
set laststatus=2						" Always show statusline, even if only 1 window
set report=0							" Notify me whenever any lines have changed
set confirm								" Y-N-C prompt if closing with unsaved changes
set vb t_vb=							" Disable visual bell!  I hate that flashing.
set novisualbell

"match LongLineWarning '\%120v.*' " Error format when a line is longer than 120

"""" Editing
set backspace=2							" Backspace over anything! (Super backspace!)
set showmatch							" Briefly jump to the previous matching paren
set matchtime=2							" For .2 seconds
"set formatoptions-=tc					" I can format for myself, thank you very much
set tabstop=2							" Tab stop of 4
set shiftwidth=2						" sw 4 spaces (used on auto indent)
set softtabstop=2						" 4 spaces as a tab for bs/del
set textwidth=72

set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<

" we don't want to edit these type of files
set wildignore=*.o,*.obj,*.bak,*.exe,*.pyc,*.swp

"""" Coding
set history=100							" 100 Lines of history
set showfulltag							" Show more information while completing tags
filetype plugin on                      " Enable filetype plugins
filetype plugin indent on               " Let filetype plugins indent for me
syntax on                               " Turn on syntax highlighting

" Customize Leader
let mapleader = ","

" set up tags
set tags=tags;\
set tags=$HOME/.vim/tags/python.ctags

"python << EOF
"import os
"import sys
"import vim
"for p in sys.path:
"    if os.path.isdir(p):
"        vim.command(r"set path+=%s" % (p.replace(" ", r"\ ")))
"EOF


map <silent><C-Left> <C-T>
map <silent><C-Right> <C-]>

" Mappings
" ********************************************************************
" Professor VIM says '87% of users prefer jj over esc', jj abrams disagrees
imap jj <Esc>

" Cursor Movement
" *************************************************************
" " Make cursor move by visual lines instead of file lines (when wrapping)
" map <up> gk
" map k gk
" imap <up> <C-o>gk
" map <down> gj
" map j gj
" imap <down> <C-o>gj
" map E ge

set sessionoptions=blank,buffers,curdir,folds,help,resize,tabpages,winsize

""""" Folding
set foldmethod=indent					" By default, use syntax to determine folds
set foldlevelstart=99					" All folds open by default

"""" Command Line
set wildmenu                            " Autocomplete features in the status bar

"""" Autocommands
if has("autocmd")
augroup vimrcEx
au!
	" In plain-text files and svn commit buffers, wrap automatically at 78 chars
	au FileType text,svn setlocal tw=78 fo+=t

	" In all files, try to jump back to the last spot cursor was in before exiting
	au BufReadPost *
		\ if line("'\"") > 0 && line("'\"") <= line("$") |
		\   exe "normal g`\"" |
		\ endif

	" Use :make to check a script with perl
	au FileType perl set makeprg=perl\ -c\ %\ $* errorformat=%f:%l:%m

	" Use :make to compile c, even without a makefile
	au FileType c,cpp if glob('Makefile') == "" | let &mp="gcc -o %< %" | endif

	" Switch to the directory of the current file, unless it's a help file.
	au BufEnter * if &ft != 'help' | silent! cd %:p:h | endif

	" Insert Vim-version as X-Editor in mail headers
	au FileType mail sil 1  | call search("^$")
				 \ | sil put! ='X-Editor: Vim-' . Version()

	" smart indenting for python
	au FileType python set smartindent cinwords=if,elif,else,for,class,while,try,except,finally,def

	" allows us to run :make and get syntax errors for our python scripts
	au FileType python set makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
	" setup file type for code snippets
	au FileType python if &ft !~ 'django' | setlocal filetype=python.django_tempate.django_model | endif
	au FileType python set expandtab
  au FileType python set softtabstop=4
  au FileType python set shiftwidth=4
  au FileType python set tabstop=4

	" kill calltip window if we move cursor or leave insert mode
	au CursorMovedI * if pumvisible() == 0|pclose|endif
	au InsertLeave * if pumvisible() == 0|pclose|endif

    " Support LodgeNet Files
    au BufNewFile,BufRead,FileType *.inc set filetype=php
    au BufNewFile,BufRead,FileType *.install set filetype=php
    au BufNewFile,BufRead,FileType *.test set filetype=php
    au BufNewFile,BufRead,FileType *.unit set filetype=php
    au BufNewFile,BufRead,FileType *.module set filetype=php
    au BufNewFile,BufRead,FileType *.feature set filetype=cucumber
  au FileType php set softtabstop=2
  au FileType php set shiftwidth=2
  au FileType php set tabstop=2


	augroup END
endif

"""" Key Mappings
" bind ctrl+space for omnicompletion
inoremap <expr> <C-Space> pumvisible() \|\| &omnifunc == '' ?
			\ "\<lt>C-n>" :
			\ "\<lt>C-x>\<lt>C-o><c-r>=pumvisible() ?" .
			\ "\"\\<lt>c-n>\\<lt>c-p>\\<lt>c-n>\" :" .
			\ "\" \\<lt>bs>\\<lt>C-n>\"\<CR>"
imap <C-@> <C-Space>

" Toggle the tag list bar
nmap <F4> :TlistToggle<CR>

" tab navigation (next tab) with alt left / alt right
nnoremap  <a-right>  gt
nnoremap  <a-left>   gT

" Ctrl + Arrows - Move around quickly
nnoremap  <c-up>     {
nnoremap  <c-down>   }
nnoremap  <c-right>  El
nnoremap  <c-down>   Bh

" Shift + Arrows - Visually Select text
nnoremap  <s-up>     Vk
nnoremap  <s-down>   Vj
nnoremap  <s-right>  vl
nnoremap  <s-left>   vh

if &diff
" easily handle diffing
   vnoremap < :diffget<CR>
   vnoremap > :diffput<CR>
else
" visual shifting (builtin-repeat)
   vnoremap < <gv
   vnoremap > >gv
endif

" Extra functionality for some existing commands:
" <C-6> switches back to the alternate file and the correct column in the line.
nnoremap <C-6> <C-6>`"

" CTRL-g shows filename and buffer number, too.
nnoremap <C-g> 2<C-g>

" Arg!  I hate hitting q: instead of :q
nnoremap q: q:iq<esc>

nnoremap :W :w

" <C-l> redraws the screen and removes any search highlighting.
nnoremap <silent> <C-l> :nohl<CR><C-l>

" Q formats paragraphs, instead of entering ex mode
noremap Q gq

" * and # search for next/previous of selected text when used in visual mode
vnoremap * y/<C-R>"<CR>
vnoremap # y?<C-R>"<CR>

" <space> toggles folds opened and closed
nnoremap <space> za

" <space> in visual mode creates a fold over the marked range
vnoremap <space> zf

" allow arrow keys when code completion window is up
inoremap <Down> <C-R>=pumvisible() ? "\<lt>C-N>" : "\<lt>Down>"<CR>

""" Abbreviations
function! EatChar(pat)
  let c = nr2char(getchar(0))
  return (c =~ a:pat) ? '' : c
endfunc

iabbr _t  <C-R>=strftime("%H:%M:%S")<CR><C-R>=EatChar('\s')<CR>
iabbr _d  <C-R>=strftime("%a, %d %b %Y")<CR><C-R>=EatChar('\s')<CR>
iabbr _dt <C-R>=strftime("%a, %d %b %Y %H:%M:%S %z")<CR><C-R>=EatChar('\s')<CR>

endif
" -----------------------------------------------------------------------------
"  " |                              Plug-ins
"  |
"  "
"  -----------------------------------------------------------------------------

" NERDTree
"  ********************************************************************
:noremap <F5> :NERDTreeToggle<CR>
map <leader>r :NERDTreeFind<cr>


let NERDTreeHijackNetrw=1
let NERDTreeQuitOnOpen = 1
let NERDTreeIgnore=['\.pyc$', '\.vim$', '\~$']
let NERDTreeMouseMode=1
let NERDTreeWinSizDTreeWinSize = 30

" PEP8
let g:pep8_map='<leader>8'

" TaskList
map <leader>td <Plug>TaskList


" SnippetsEmu
"  *****************************************************************
"imap <unique> <C-j> <Plug>Jumper
"let g:snip_start_tag = "_\."
"let g:snip_end_tag = "\._"
"let g:snip_elem_delim = ":"
"let g:snip_set_textmate_cp = '1'  " Tab to expand snippets, not automatically.


" fuzzyfinder_textmate
"  ********************************************************
"map ,f :FuzzyFinderTextMate<CR>
"map ,b :FuzzyFinderBuffer<CR>
"let g:fuzzy_ignore = '.o;.obj;.bak;.exe;.pyc;.pyo;.DS_Store;.db'

  " autocomplpop
"  ***************************************************************
" complete option
"set complete=.,w,b,u,t,k
"let g:AutoComplPop_CompleteOption = '.,w,b,u,t,k'
"set complete=.
"let g:AutoComplPop_IgnoreCaseOption = 0
"let g:AutoComplPop_BehaviorKeywordLength = 2

" Docstrings :D
nmap <F3> i""""""<Esc>hhi
imap <F3> """"""<Esc>hhi


nnoremap <silent> <F8> :TlistToggle<CR>
nnoremap <silent> <F9> :w<CR>:!sudo python %<CR>

nnoremap <silent> <F2> :BufExplorer<CR>


"autocmd FileType python compiler pylint

if !exists("autocommands_loaded")
      let autocommands_loaded = 1
        autocmd BufRead,BufNewFile,FileReadPost *.py source ~/.vim/python
    endif

set hidden

if $VIM_CRONTAB == 'true'
  set nobackup
  set nowritebackup
endif

autocmd BufWritePre * :%s/\s\+$//e

" Powerline (https://powerline.readthedocs.org) settings
python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup
set laststatus=2  " Always display the statusline in all windows
set showtabline=2 " Always display the tabline, even if there is only one tab
set noshowmode " Hide the default mode text (e.g. -- INSERT -- below the statusline)
