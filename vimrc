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
	let g:solarized_hitrail=1
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

if exists("+relativenumber")
	set relativenumber
endif

filetype plugin on
filetype indent on

runtime macros/matchit.vim

" write selection to X clipboard
vnoremap <Leader>cc :w !xclip -selection c<cr><cr>

" show line length guides
nnoremap <Leader>co :set colorcolumn=72,80<cr>

" syntastic settings -- only check manually (:SyntasticCheck)
let g:syntastic_mode_map = {'mode': 'passive', 'active_filetypes': [], 'passive_filetypes': []}
let g:syntastic_always_populate_loc_list=1
nnoremap <Leader>sc :SyntasticCheck<cr>
nnoremap <Leader>su :sign unplace *<cr>

" command mode: ctrl-d for pathname of current buffer
cnoremap <C-D> <C-R>=expand("%:p:h") . "/" <CR>

" I like to use these shortcuts for moving among buffers
nnoremap gb :bn<cr>
nnoremap gB :bp<cr>
nnoremap <Leader>ab :ls<cr>:buffer 

" moving among windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
" (this overwrites <C-l> for redraw, but I use :redraw[!] anyhow)
nnoremap <C-l> <C-w>l

" easier than <C-w>s
nnoremap <C-w><C-s> <C-w>s

" Used to use MiniBufExplr but haven't in ages; its stuff was here

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

" Open diffs in tabs for each file that differs between HEAD and the supplied
" target (default: current merge base with master)
function Gbdiff(...)
	if a:0 > 0
		let l:base = a:1
	else
		let l:base = substitute(system("git merge-base HEAD master"), '[^0-9a-f]\+$', '', '')
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
		if !filereadable(getline("."))
			if isdirectory(getline("."))
				" directory differs (must be a submodule?)
				normal Idiff k
			else
				" File does not exist here: show file from base
				let l:f = getline(".")
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
			call system("git show " . shellescape(l:base . ":" . getline(".")))
			if v:shell_error
				" File does not exist in target branch: just show file
				normal gf
				normal gT
				normal I++ k
			else
				normal gf
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
nnoremap <Leader>bd :call Gbdiff()<cr>

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

" Add phpunit tags for php files
au FileType php setlocal tags+=~/Dropbox/phpunit/tags

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
