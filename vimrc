scriptencoding utf-8
" Vundle
filetype off
set runtimepath+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

" This is a dependency for mxw/vim-jsx
" (I also use it on its own merits)
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'

Plugin 'leafgarland/typescript-vim'
Plugin 'rhowardiv/nginx-vim-syntax'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-markdown'

Plugin 'vim-python/python-syntax'
Plugin 'w0rp/ale'
let g:python_highlight_all = 1

call vundle#end()
filetype plugin on
filetype indent on

let g:mapleader=' '
runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()
if has('syntax')
	syntax on
	nnoremap <Leader>ss :syntax sync fromstart<cr>
	if &t_Co == 8
		" sorry, I don't believe you
		set t_Co=16
	endif
	set background=dark
	color solarized
	nnoremap <Leader>sd :set background=dark<cr>
	nnoremap <Leader>sl :set background=light<cr>

	set incsearch
	set hlsearch
	set cursorline
endif

set wrap
set hidden
set nonumber
set showcmd
set modeline

set laststatus=2
" default status line with current git branch name added via fugitive
set statusline=%<%f\ %{fugitive#statusline()}\ %h%m%r%=%-14.(%l,%c%V%)\ %P
set ruler
set backspace=start,indent,eol
set updatecount=25
set history=10000
set diffopt=filler,vertical
nnoremap <Leader>do :diffoff!<cr>
nnoremap <Leader>du :diffup<cr>
set wildmenu
set noesckeys
" Debian based distros set 'nomodeline' by default
set modeline

set tabstop=4
set shiftround
set autoindent
set scrolloff=3
set formatoptions=tcroq
set listchars=eol:¬,tab:▷\ ,trail:♢,extends:▶,precedes:◀,nbsp:♢
set nolist
set nojoinspaces

" suppress .netrwhist
let g:netrw_dirhistmax=0

if exists('+relativenumber')
	set number
	set relativenumber
endif

runtime macros/matchit.vim

" I'm not that good at typing ':'
nnoremap <Leader>; :

" Shell eval current line / selection
nnoremap <Leader>el :.w !source /dev/stdin &<cr>
vnoremap <Leader>el :'<,'>w !source /dev/stdin &<cr>

" X clipboard: put it or save from some common registers (0,",/)
nnoremap <Leader>p :r! xclip -o -sel c<cr>
nnoremap <Leader>P :-1r! xclip -o -sel c<cr>
nnoremap <Leader>0 :call system('xclip -sel c', @0)<cr>
nnoremap <Leader>" :call system('xclip -sel c', @")<cr>
nnoremap <Leader>/ :call system('xclip -sel c', @/)<cr>

" line length guides
function MyColorCols()
	if &colorcolumn ==? '72,80'
		set colorcolumn=44,52
	elseif &colorcolumn ==? '44,52'
		set colorcolumn=
	else
		set colorcolumn=72,80
	endif
endfunction
nnoremap <Leader>co :call MyColorCols()<cr>
nnoremap <Leader>7 :set tw=72<cr>
nnoremap <Leader>5 :set tw=56<cr>

" command mode: ctrl-d for pathname of current buffer
cnoremap <C-D> <C-R>=expand("%:p:h") . "/" <CR>

" I like to use these shortcuts for moving among buffers
nnoremap gb :bn<cr>
nnoremap gB :bp<cr>
nnoremap <Leader>b :ls<cr>:buffer 
" Don't show fugitive buffers in buffer list
augroup vimrc
	autocmd BufReadPost fugitive://* set nobuflisted
augroup END

" moving among windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
" (this overwrites <C-l> for redraw, but I use :redraw[!] anyhow)
nnoremap <C-l> <C-w>l

" easier than <C-w>s
nnoremap <C-w><C-s> <C-w>s

" Handy shortcut for a happy scratch buffer
function HappyBuffer()
	let l:happy = '^_^'

	if bufexists(l:happy)
		let l:n = bufnr(l:happy)
		execute ':buffer ' . l:n
		return
	endif

	execute ':e ' . l:happy
	setlocal buftype=nofile
	setlocal bufhidden=hide
	setlocal noswapfile
	setlocal nobuflisted
	set filetype=diff
endfunction
nnoremap gs :call HappyBuffer()<cr>

" grep with ack
set grepprg=ack
" grep for the current word
" The parens are there because <C-r><C-w> considers the previously typed
" characters and omits them when they match the beginning of word!
nnoremap <Leader>* :grep '\b(<C-r><C-w>)\b'<cr>
" grep for the current word (no boundary enforcement)
nnoremap <Leader>g* :grep '<C-r><C-w>'<cr>

" Don't let ctrl-p use a different pwd
let g:ctrlp_working_path_mode = 0
" Filter out pyc files
set wildignore+=*.pyc

" "resolve conflicts"
nnoremap <Leader>rc /<<<<<<<\\|=======\\|>>>>>>><cr>
" "resolve right"
nnoremap <Leader>rr dnddkndd
" "resolve left"
nnoremap <Leader>rl ddkndndd

" Sometimes it's nice to have random things, for tests and whatnot
" "random word append"
nnoremap <Leader>ra :execute "normal a" . system("echo -n $(grep -v \\' /usr/share/dict/words \| shuf -n 1)")<cr>
" "random word insert"
nnoremap <Leader>ri :execute "normal i" . system("echo -n $(grep -v \\' /usr/share/dict/words \| shuf -n 1)")<cr>

" Open thesaurus on a word
nnoremap <Leader>th :call system("xdg-open http://www.thesaurus.com/browse/<C-r><C-w>")<cr>

" Open diffs in tabs for each file that differs between working copy and the
" supplied target (default: current merge base with master)
command! -nargs=? Gtdiff call s:Gtdiff(<q-args>)
function! s:Gtdiff(...)
	if empty(a:000) || a:1 ==? ''
		let l:base = substitute(system('git merge-base HEAD master'), '[^0-9a-f]\+$', '', '')
		echom a:1
	else
		let l:base = a:1
	endif
	let l:base_pretty = '(' . substitute(system('git show --oneline ' . l:base . ' | head -n1'), '[^0-9a-f]\+$', '', '') . ')'
	e _branch_diff_
	" filereadable etc below depend on me being in the root repo dir
	" this affects only the current window
	" but I still set it back afterward, below
	let l:workingdir=getcwd()
	Glcd .
	setlocal buftype=nofile
	setlocal bufhidden=hide
	setlocal noswapfile
	setlocal textwidth=0
	set filetype=diff
	execute 'normal iFiles that differ from base ' . l:base_pretty . ":\<esc>"
	execute 'r!git diff --name-only ' . l:base
	while line('.') > 1
		let l:f = getline('.')
		if !filereadable(l:f)
			if isdirectory(l:f)
				" directory differs (must be a submodule?)
				execute 'normal Idiff k'
			else
				" File does not exist here: show file from base
				" Need to pretend I'm editing something to get fugitive commands.
				" Hrm. Probably a better way.
				tabedit foo_098q2h3f98basd908hawef
				execute 'Gedit ' . l:base . ':' . l:f
				bdelete foo_098q2h3f98basd908hawef
				" Should look different so I don't miss the fact that it's
				" deleted!
				syntax clear
				execute 'lcd ' . l:workingdir
				execute 'normal gT'
				execute 'normal I-- k'
			endif
		else
			call system('git rev-parse ' . shellescape(l:base . ':' . l:f))
			if v:shell_error
				" File does not exist in target branch: just show file
				execute 'normal ^v$hgf'
				execute 'lcd ' . l:workingdir
				execute 'normal gT'
				execute 'normal I++ k'
			else
				execute 'normal ^v$hgf'
				execute 'Gdiff ' . l:base
				execute 'lcd ' . l:workingdir
				execute 'normal gTk'
			endif
		endif
	endwhile
	execute 'normal ICommits since base ' . l:base_pretty . ":\<cr>" . system('git log --oneline ' . l:base . '..HEAD | tac') . "\<cr>\<esc>0j"
	execute 'normal Go'
	execute 'read !git diff --shortstat ' . l:base . '..HEAD'
	execute 'normal Go'
	execute 'silent read !git log -p ' . l:base . '..HEAD'
	execute 'normal gg'
	execute 'lcd ' . l:workingdir
endfunction
nnoremap <Leader>gt :Gtdiff<cr>

nnoremap <Leader>gb :Gblame<cr>
nnoremap <Leader>gc :Gcommit<cr>
nnoremap <Leader>gd :Gdiff<cr>
nnoremap <Leader>ge :Gedit<cr>
nnoremap <Leader>gl :Glog<cr>
nnoremap <Leader>grd :Gread<cr>
nnoremap <Leader>grm :Gremove<cr>
nnoremap <Leader>gs :Gstat<cr>
nnoremap <Leader>gw :Gwrite<cr>
nnoremap <Leader>gv :Gitv<cr>
nnoremap <Leader>gf :Gitv!<cr>

" lint inline JS ("Tag Lint", "Tag Prettier")
nnoremap <Leader>tl vitVoj:w !eslint --stdin<cr>
nnoremap <Leader>tp vitVoj:!prettier --stdin<cr><C-O>

" puppet
" navigate tags containing "::"
augroup vimrc
	autocmd FileType puppet setlocal isk+=:
augroup END

" isort
" nnoremap <Leader>is :Isort<cr>
" Lately I can't get past 'No isort python module detected'
" But this works too
nnoremap <Leader>is :!isort %<cr>

" tagbar
nnoremap <Leader>tb :Tagbar<cr>

" hoogle
nnoremap <Leader>hh :Hoogle<cr>
nnoremap <Leader>hi :HoogleInfo<cr>
nnoremap <Leader>hc :HoogleClose<cr>

" ALE
let g:ale_lint_on_enter = 0
" mypy --ignore-missing imports
" stifles errors for libraries (eg boto3) not yet in typeshed
let g:ale_python_mypy_options = '--ignore-missing-imports'
nnoremap <silent> <Leader>ll :ALELint<cr>
if filereadable('etc/pylintrc')
	let g:ale_python_flake8_options='--config=etc/pep8.cfg'
endif

" column view
nnoremap <Leader>c3 <C-w>o:set noscrollbind
			\ nocursorbind<cr>:vs<cr>:vs<cr>gg:set
			\ scrollbind<cr>2<C-w>wgg<C-f>:set
			\ scrollbind<cr>3<C-w>wgg<C-f><C-f>:set
			\ scrollbind<cr>2<C-w>w<C-o>
nnoremap <Leader>c2 <C-w>o:set noscrollbind
			\ nocursorbind<cr>:vs<cr>gg:set
			\ scrollbind<cr>2<C-w>wgg<C-f>:set
			\ scrollbind<cr><C-o>
