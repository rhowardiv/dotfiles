syntax on
color desert
color solarized
let g:solarized_hitrail=1

set wrap
set hidden
set nonu
set incsearch
set showcmd

set laststatus=2
" default status line with current git branch name added via fugitive
set statusline=%<%f\ %{fugitive#statusline()}\ %h%m%r%=%-14.(%l,%c%V%)\ %P

set hls
set ruler
set backspace=start,indent,eol
set updatecount=50
set history=500
set diffopt=filler,vertical
set wildmenu

set noexpandtab
au FileType python setlocal expandtab
au FileType haskell setlocal expandtab
set shiftwidth=4
set tabstop=4
set shiftround
set autoindent
set scrolloff=3
set formatoptions=tcroq

filetype plugin on
filetype indent on

" don't syntax highlight large files
au FileType php if getfsize(expand("%")) > 92000 | syntax clear | endif

" command mode: ctrl-d for pathname of current buffer
cmap <C-D> <C-R>=expand("%:p:h") . "/" <CR>

" I like to use these shortcuts for moving among buffers
nmap gb :bn<cr>
nmap gB :bp<cr>

" quicker shortcut for toggling MiniBufExplorer
nmap <Leader>bb <Plug>TMiniBufExplorer

" Handy shortcut for a happy scratch buffer
function HappyBuffer()
	let l:happy = "^_^"

	if bufexists(l:happy)
		let l:n = bufnr(l:happy)
		execute ":buffer " . l:n
		return
	endif

	execute ":e " . l:happy
	execute ":setlocal buftype=nofile"
	execute ":setlocal bufhidden=hide"
	execute ":setlocal noswapfile"
	execute ":setlocal nobuflisted"
	execute ":set filetype=diff"
endfunction
nmap gs :call HappyBuffer()<cr>

" ack in scratch buffer...
" for term in " register
nmap <Leader>a" gsGo<cr>++ term search: """:r!ack "<cr>{
" for "this" (under cursor)
nmap <Leader>at yiwgsGo<cr>++ term search: """:r!ack "<cr>{
" for word under cursor (enforce word boundaries)
nmap <Leader>aw yiwgsGo<cr>++ word search: """:r!ack '\b"\b'<cr>{
" for something you'll type out
nmap <Leader>as gsGo<cr>++ arbitrary term search::r!ack ''<left>

" "resolve conflicts"
nmap <Leader>rc /<<<<<<<\\|=======\\|>>>>>>><cr>

" blame someone for code I'm looking at
" Only works if you're at least 10 lines into the file (otherwise just use
" :!git blame '%' | head). Could fix with sed but, meh.
nmap <Leader>bs :call setreg('l', line('.'))<cr>:!git blame '%' \| tail -n +$(echo $((<C-R>l-10))) \| head -n 20<cr>

" Open diffs in tabs for each file that differs between the branch you're on
" and the supplied target (default: current merge base with master)
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
	set filetype=diff
	execute "normal iFiles that differ from base " . l:base_pretty . ":\<esc>"
	execute "r!git diff --name-only " . l:base
	while line(".") > 1
		if !filereadable(getline("."))
			" File does not exist in this branch
			execute "normal I--\<esc>k"
		else
			call system("git show " . shellescape(l:base . ":" . getline(".")))
			if v:shell_error
				" File does not exist in target branch
				execute "normal I++\<esc>k"
			else
				execute "normal \<C-w>gf"
				execute "CMiniBufExplorer"
				execute "Gdiff " . l:base
				execute "normal \<cr>gTk"
			endif
		endif
	endwhile
	execute "normal ICommits since base " . l:base_pretty . ":\<cr>" . system("git log --oneline " . l:base . "..HEAD | tac") . "\<cr>\<esc>0j"
endfunction
nmap <Leader>bd :call Gbdiff()<cr>

" folding

let php_folding=1
au FileType php setlocal foldmethod=syntax
let g:xml_syntax_folding=1
au FileType xml setlocal foldmethod=syntax
au FileType javascript setlocal foldmethod=marker
set foldlevelstart=1

" RedDot

" sensible default filetype
au BufRead,BufNewFile *.rdtp setfiletype php
" decode and re-encode freshly exported Red Dot templates
nmap \rd :e ++enc=ucs-2le<cr>:set fenc=latin1<cr>


