runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()
if has("syntax")
	syntax on
	nnoremap <Leader>ss :syntax sync fromstart<cr>
	" color desert
	set t_Co=16
	color solarized
	" why do I have to explictly source this?
	so ~/.vim/autoload/togglebg.vim
	" use the correct solarized scheme
	if exists(":ToggleBG") " not vi
		ToggleBG
	endif
	let g:solarized_hitrail=1

	set incsearch
	set hls
	set cursorline

	" don't syntax highlight large files
	au FileType php if getfsize(expand("%")) > 92000 | syntax clear | endif

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
set updatecount=50
set history=500
set diffopt=filler,vertical
set wildmenu

set tabstop=4
set shiftround
set autoindent
set scrolloff=3
set formatoptions=tcroq

filetype plugin on
filetype indent on

runtime macros/matchit.vim

" write selection to X clipboard
vnoremap <Leader>cc :w !xclip -selection c<cr><cr>

" syntastic settings -- only check manually (:SyntasticCheck)
let g:syntastic_mode_map = {'mode': 'passive', 'active_filetypes': [], 'passive_filetypes': []}
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

" Lazily load and toggle the MiniBufExplr plugin
nnoremap <Leader>bb :call LazyMiniBufExpl()<cr>
let g:miniBufExplorerMoreThanOne=0
function LazyMiniBufExpl()
	if !exists(":TMiniBufExplorer")
		execute ":source ~/.vim/minibufexpl/minibufexpl.vim"
	endif
	execute ":TMiniBufExplorer"
endfunction


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
nnoremap gs :call HappyBuffer()<cr>

" ack in scratch buffer...
" for term in " register
nnoremap <Leader>a" gsGo<cr>++ term search: """:r!ack "<cr>{
" for "this" (under cursor)
nnoremap <Leader>at yiwgsGo<cr>++ term search: """:r!ack "<cr>{
" for word under cursor (enforce word boundaries)
nnoremap <Leader>aw yiwgsGo<cr>++ word search: """:r!ack '\b"\b'<cr>{
" for something you'll type out
nnoremap <Leader>as gsGo<cr>++ arbitrary term search::r!ack ''<left>

" traditional grepping with ack
set grepprg=ack

" Don't let ctrl-p use a different pwd
let g:ctrlp_working_path_mode = 0

" send the current word to ctrl-p
" ctrl-p already uses <insert> after <C-P> for this, but meh
nnoremap <Leader>ff <C-P><insert>

" "resolve conflicts"
nnoremap <Leader>rc /<<<<<<<\\|=======\\|>>>>>>><cr>
" "resolve right"
nnoremap <Leader>rr dnddkndd
" "resolve left"
nnoremap <Leader>rl ddkndndd

" blame someone for code I'm looking at
" Only works if you're at least 10 lines into the file (otherwise just use
" :!git blame '%' | head). Could fix with sed but, meh.
nnoremap <Leader>bs :call setreg('l', line('.'))<cr>:!git blame '%' \| tail -n +$(echo $((<C-R>l-10))) \| head -n 20<cr>

" Open diffs in tabs for each file that differs between the branch you're on
" and the supplied target (default: current merge base with master)
" if exists(":Gcommit")
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
				" File does not exist in this branch
				execute "normal I-- \<esc>k"
			else
				call system("git show " . shellescape(l:base . ":" . getline(".")))
				if v:shell_error
					" File does not exist in target branch
					execute "normal I++ \<esc>k"
				else
					execute "normal \<C-w>gf"
					if (exists(":CMiniBufExplorer"))
						execute "CMiniBufExplorer"
					endif
					execute "Gdiff " . l:base
					execute "normal \<cr>gTk"
				endif
			endif
		endwhile
		execute "normal ICommits since base " . l:base_pretty . ":\<cr>" . system("git log --oneline " . l:base . "..HEAD | tac") . "\<cr>\<esc>0j"
	endfunction
	nnoremap <Leader>bd :call Gbdiff()<cr>
" endif

" folding
if has("folding") " not vi
	let php_folding=1
	au FileType php setlocal foldmethod=syntax
	let g:xml_syntax_folding=1
	au FileType xml setlocal foldmethod=syntax
	au FileType javascript setlocal foldmethod=marker
	set foldlevelstart=2
endif

" linting
function PHPlint(file)
	let l:lint = system("php -l " . a:file)
	if v:shell_error != 0
		echohl WarningMsg | echo l:lint | echohl None
	endif
endfunction
au BufWritePost *.php call PHPlint(expand("%"))
let g:php_cs_fixer_path = "~/bin/php-cs-fixer"
let g:php_cs_fixer_fixers_list = "indentation,linefeed,trailing_spaces,unused_use,visibility,short_tag,braces,include,php_closing_tag,extra_empty_lines,psr0,controls_spaces,elseif,eof_ending,default,magento,sf20,sf21"
