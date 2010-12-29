syntax on
color desert

set wrap
set hidden
set nonu
set incsearch
set showcmd
set laststatus=2
set hls
set ruler
set backspace=start,indent,eol
set updatecount=50
set history=500
set diffopt=filler,vertical
set wildmenu

set noexpandtab
au FileType python setlocal expandtab
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

" helper shortcut--prep filenames w/spaces for filtering to xargs, etc.; 'quote space'
vmap \qs :s/^\s*//<cr>gv:s/ /\\ /g<cr>:nohls<cr>


" folding

let php_folding=1
au FileType php setlocal foldmethod=syntax
let g:xml_syntax_folding=1
au FileType xml setlocal foldmethod=syntax
au FileType javascript setlocal foldmethod=marker


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


