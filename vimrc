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

" command mode: ctrl-d for pathname of current buffer
cmap <C-D> <C-R>=expand("%:p:h") . "/" <CR>

" I like to use these shortcuts for moving among buffers
nmap gb :bn<cr>
nmap gB :bp<cr>

" Handy shortcut for a scratch buffer named "^_^"
nmap gs :e ^_^<cr>:setlocal buftype=nofile<cr>:setlocal bufhidden=hide<cr>:setlocal noswapfile<cr>:set filetype=diff<cr>

" ack in scratch buffer...
" for term in " register
nmap <Leader>a" gsGo<cr>term search: """:r!ack "<cr>{
" for "this" (under cursor)
nmap <Leader>at yiwgsGo<cr>term search: """:r!ack "<cr>{
" for word under cursor (enforce word boundaries)
nmap <Leader>aw yiwgsGo<cr>word search: """:r!ack '\b"\b'<cr>{
" for something you'll type out
nmap <Leader>as gsGo<cr>arbitrary term search::r!ack ''<left>


" find file; use "fack" if it exists
if executable("fack")
	nmap <Leader>ff gsGo<cr>filesearch::r!fack ''<left>
else
	nmap <Leader>ff gsGo<cr>filesearch::r!find . -not -wholename '*/.svn/*' -not -wholename '*.swp' -name '**' \|cut -c3-<left><left><left><left><left><left><left><left><left><left><left><left>
endif


" "resolve conflicts"
nmap <Leader>rc /<<<<<<<\\|=======\\|>>>>>>><cr>

" blame someone for code I'm looking at
" Only works if you're at least 10 lines into the file (otherwise just use
" :!git blame '%' | head). Could fix with sed but, meh.
nmap <Leader>bs :call setreg('l', line('.'))<cr>:!git blame '%' \| tail -n +$(echo $((<C-R>l-10))) \| head -n 20<cr>

" Open diffs in tabs for each file that differs between the branch you're on
" and the supplied branch (default: master)
function Gbdiff(...)
	if a:1
		let l:target_branch = a:1
	else
		let l:target_branch = "master"
	endif

	e _branch_diff_
	setlocal buftype=nofile
	setlocal bufhidden=hide
	setlocal noswapfile
	set filetype=diff
	silent exec 'r!git diff --name-only master'
	while line(".") > 1
		if !filereadable(getline("."))
			" File does not exist in this branch
			execute "normal I--\<esc>k"
		else
			call system("git show " . shellescape(l:target_branch . ":" . getline(".")))
			if v:shell_error
				" File does not exist in target branch
				execute "normal I++\<esc>k"
			else
				execute "normal \<C-w>gf"
				execute "CMiniBufExplorer"
				execute "Gdiff " . l:target_branch
				execute "normal \<CR>gTk"
			endif
		endif
	endwhile
endfunction
nmap <Leader>bd :call Gbdiff("master")<cr>

" folding

let php_folding=1
au FileType php setlocal foldmethod=syntax
let g:xml_syntax_folding=1
au FileType xml setlocal foldmethod=syntax
au FileType javascript setlocal foldmethod=marker
set foldlevelstart=1

" linting

au BufWritePost *.php !php -l '%'
" pylint can be very slow... background it
"au BufWritePost *.py !pylint '%' >> ~/loglint &
" allowing stdout to console for nodelint seems to cause persistent drawing problems
" when using screen. :^(
"au BufWritePost *.js !node ~/bin/nodelint.js/nodelint.js '%' >> ~/loglint
"au BufWritePost *.css !node ~/bin/nodelint.js/nodelint.js '%' >> ~/loglint
" add jslinting to any buffer
nmap \aj :au BufWritePost <buffer> !node ~/bin/nodelint.js/nodelint.js '%' >> ~/loglint<cr>
" windows/cygwin
"au BufWritePost *.js !cscript "C:\cygwin\home\rhoward\bin\jslint.js" < '%'
"au BufWritePost *.css !cscript "C:\cygwin\home\rhoward\bin\jslint.js" < '%'


" RedDot

" sensible default filetype
au BufRead,BufNewFile *.rdtp setfiletype php
" decode and re-encode freshly exported Red Dot templates
nmap \rd :e ++enc=ucs-2le<cr>:set fenc=latin1<cr>


