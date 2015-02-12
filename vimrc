let g:mapleader=" "
runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()
if has("syntax")
	syntax on
	nnoremap <Leader>ss :syntax sync fromstart<cr>
	if &t_Co == 8
		" sorry, I don't believe you
		set t_Co=16
	endif
	set background=dark
	color solarized

	set incsearch
	set hls
	set cursorline

	" indent "case" statements
	let g:PHP_vintage_case_default_indent = 1

	" No longer needed now that I've stopped the performance-hogging PHP
	" syntax folding!
	" don't syntax highlight large files
	" au FileType php if getfsize(expand("%")) > 92000 | syntax clear | endif

endif

set wrap
set hidden
set nonu
set showcmd

set laststatus=2
" default status line with current git branch name added via fugitive
set statusline=%<%f\ %{fugitive#statusline()}\ %h%m%r%=%-14.(%l,%c%V%)\ %P
set ruler
set backspace=start,indent,eol
set updatecount=25
set history=1000
set diffopt=filler,vertical
set wildmenu
set noesckeys

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

if exists("+relativenumber")
	set relativenumber
endif

filetype plugin on
filetype indent on

runtime macros/matchit.vim

" I'm not that good at typing ':'
nnoremap <Leader>; :

" X clipboard: put it or save from some common registers (0,",/)
nnoremap <Leader>p :r! xclip -o -sel c<cr>
nnoremap <Leader>P :-1r! xclip -o -sel c<cr>
nnoremap <Leader>0 :call system('xclip -sel c', @0)<cr>
nnoremap <Leader>" :call system('xclip -sel c', @")<cr>
nnoremap <Leader>/ :call system('xclip -sel c', @/)<cr>

" show line length guides
nnoremap <Leader>co :set colorcolumn=72,80<cr>

" syntastic settings -- only check manually (:SyntasticCheck)
let g:syntastic_mode_map = {'mode': 'passive', 'active_filetypes': [], 'passive_filetypes': []}
let g:syntastic_always_populate_loc_list=1
nnoremap <Leader>sc :SyntasticCheck<cr>
nnoremap <Leader>su :sign unplace *<cr>
" checkers
let g:syntastic_sh_checkers = ["shellcheck"]

" command mode: ctrl-d for pathname of current buffer
cnoremap <C-D> <C-R>=expand("%:p:h") . "/" <CR>

" I like to use these shortcuts for moving among buffers
nnoremap gb :bn<cr>
nnoremap gB :bp<cr>
nnoremap <Leader>b :ls<cr>:buffer 

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
	let l:happy = "^_^"

	if bufexists(l:happy)
		let l:n = bufnr(l:happy)
		execute ":buffer " . l:n
		return
	endif

	execute ":e " . l:happy
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

" send the current word to ctrl-p
" ctrl-p already uses <insert> after <C-P> for this, but meh
" nnoremap <Leader>ff <C-P><insert>

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

" Open diffs in tabs for each file that differs between HEAD and the supplied
" target (default: current merge base with master)
command! -nargs=? Gtdiff call s:Gtdiff(<q-args>)
function! s:Gtdiff(...)
	if empty(a:000) || a:1 == ""
		let l:base = substitute(system("git merge-base HEAD master"), '[^0-9a-f]\+$', '', '')
		echom a:1
	else
		let l:base = a:1
		echom "woooooooooooo"
	endif
	let l:base_pretty = "(" . substitute(system("git show --oneline " . l:base . " | head -n1"), '[^0-9a-f]\+$', '', '') . ")"
	e _branch_diff_
	setlocal buftype=nofile
	setlocal bufhidden=hide
	setlocal noswapfile
	setlocal textwidth=0
	set filetype=diff
	execute "normal iFiles that differ from base " . l:base_pretty . ":\<esc>"
	execute "r!git diff --name-only " . l:base
	while line(".") > 1
		let l:f = getline(".")
		if !filereadable(l:f)
			if isdirectory(l:f)
				" directory differs (must be a submodule?)
				normal Idiff k
			else
				" File does not exist here: show file from base
				" Need to pretend I'm editing something to get fugitive commands.
				" Hrm. Probably a better way.
				tabedit foo_098q2h3f98basd908hawef
				execute "Gedit " . l:base . ":" . l:f
				bdelete foo_098q2h3f98basd908hawef
				" Should look different so I don't miss the fact that it's
				" deleted!
				syntax clear
				normal gT
				normal I-- k
			endif
		else
			call system("git rev-parse " . shellescape(l:base . ":" . l:f))
			if v:shell_error
				" File does not exist in target branch: just show file
				normal ^v$hgf
				normal gT
				normal I++ k
			else
				normal ^v$hgf
				execute "Gdiff " . l:base
				normal gTk
			endif
		endif
	endwhile
	execute "normal ICommits since base " . l:base_pretty . ":\<cr>" . system("git log --oneline " . l:base . "..HEAD | tac") . "\<cr>\<esc>0j"
	normal Go
	execute "read !git diff --shortstat " . l:base . "..HEAD"
	normal Go
	execute "silent read !git log -p " . l:base . "..HEAD"
	normal gg
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

" folding
if has("folding") " not vi
	set foldlevelstart=2
	" let php_folding=1 CAUSED PERFORMANCE PROBLEMS
	" I think I like this simple folding better anyway!
	au FileType php set foldmethod=indent
	au FileType php set foldnestmax=2
	au FileType php set foldlevel=2
	let g:xml_syntax_folding=1
	au FileType xml set foldmethod=syntax
	au FileType xml execute "normal zR"
	au FileType javascript set foldmethod=marker
	au FileType javascript execute "normal zR"
endif

" Keep track of the namespace for each PHP buffer.
function PhpSetBufferNamespace()
	if !exists("b:php_namespace")
		let l:save_cursor = getpos('.')
		let l:found_namespace = search('\v^namespace .+;', 'cw')
		if !l:found_namespace
			let b:php_namespace = ''
		else
			normal 0w
			let b:php_namespace = substitute(expand('<cWORD>'), ';', '', '')
		endif
		call setpos('.', save_cursor)
	endif
endfunction
autocmd FileType php call PhpSetBufferNamespace()

" Better includes for php.
" Should be psr-0 and underscore-as-directory-separator compliant.
" Special cased for Ayi code in /classes/.
let g:in_ayi = (getcwd() =~ '\v[Aa][Yy][Ii]$')
function PhpFindInclude(fname)
	if a:fname =~ '^\'
		let l:fname = substitute(a:fname, '^\', '', '')
	else
		let l:fname = b:php_namespace . '\' . a:fname
	endif
	if g:in_ayi == 1
		let l:fname = 'classes/' . substitute(l:fname, '\\\|_', '/', "g") . '.php'
		let l:fname = substitute(l:fname, '/Ayi/', '', '')
	else
		let l:fname = substitute(l:fname, '\', '/', "g") . '.php'
	endif
	" echom l:fname
	return l:fname
endfunction
autocmd FileType php setlocal include=\\v(^use\ \\zs\\\\?[A-Za-z0-9\\\\]\\ze;)\|new\ \\zs\\\\?[A-Z][a-zA-Z0-9\\\\]*\\ze\|\\zs\\\\?[A-Z][a-zA-Z0-9\\\\]*\\ze::
autocmd FileType php setlocal includeexpr=PhpFindInclude(v:fname)

" Now that I've done all that let's NOT use it for autocomplete!
autocmd FileType php set complete-=i
" But for fun let's try it with class names and gf
autocmd FileType php set isfname+=\\

" linting
function PhpLint(file)
	let l:lint = system("php -l " . a:file)
	if v:shell_error != 0
		echohl WarningMsg | echo l:lint | echohl None
	endif
endfunction
au BufWritePost *.php call PhpLint(expand("%"))
let g:php_cs_fixer_path = "~/bin/php-cs-fixer"
let g:php_cs_fixer_fixers_list = "indentation,linefeed,trailing_spaces,unused_use,visibility,short_tag,braces,include,php_closing_tag,extra_empty_lines,psr0,controls_spaces,elseif,eof_ending,default,magento,sf20,sf21"

" puppet
" navigate tags containing "::"
autocmd FileType puppet setlocal isk+=:

" jedi python stuff
let g:jedi#use_tabs_not_buffers = 0
let g:jedi#squelch_py_warning = 1
let g:jedi#rename_command = "<Leader>re"
let g:jedi#completions_enabled = 0
let g:jedi#show_call_signatures = "2"
