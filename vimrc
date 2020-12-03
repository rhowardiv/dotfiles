scriptencoding utf-8
" Vundle
filetype off
set runtimepath+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

" This is a dependency for mxw/vim-jsx
" (I also use it on its own merits)
Plugin 'pangloss/vim-javascript'

" This is a dependency for inkarkat/vim-SpellCheck
Plugin 'inkarkat/vim-ingo-library'

Plugin 'andreshazard/vim-freemarker'  " template lang in OFBiz
Plugin 'chrisbra/Colorizer'
Plugin 'elzr/vim-json'
Plugin 'ianks/vim-tsx'
Plugin 'inkarkat/vim-SpellCheck'
Plugin 'leafgarland/typescript-vim'
Plugin 'mxw/vim-jsx'
Plugin 'rhowardiv/nginx-vim-syntax'
Plugin 'rhowardiv/pgsql.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-markdown'
Plugin 'tpope/vim-rhubarb'
Plugin 'tpope/vim-vinegar'
Plugin 'fatih/vim-go'
Plugin 'vim-python/python-syntax'
Plugin 'w0rp/ale'
Plugin 'Yggdroot/indentLine'
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
    let s:allow_light = 0
    if s:allow_light && strftime('%H') >? '05' && strftime('%H') <? '18'
        set background=light
    else
        set background=dark
    endif
    color solarized
    nnoremap <Leader>sd :set background=dark<cr>
    nnoremap <Leader>sl :set background=light<cr>
    nnoremap <Leader>sh :echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')<cr>

    set incsearch
    set hlsearch
    set cursorline
    let g:sql_type_default = 'pgsql'
    let g:indentLine_enabled=0
endif

set wrap
set hidden
set nonumber
set showcmd
set modeline

set laststatus=2
set cmdheight=2
" default status line with current git branch name added via fugitive
set statusline=%<%f\ %{fugitive#statusline()}\ %h%m%r%=%y\ %-19.(%l,%c%V\\x%B%)\ %P
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

" Try to 'open' (xdg-open) current line / selection
nnoremap <silent> <Leader>gf :execute '!nohup xdg-open ' fnameescape(getline('.'))<cr><cr>
vnoremap <silent> <Leader>gf :<C-W>execute '!nohup xdg-open ' fnameescape(GetVisualSelection())<cr><cr>gv

" X clipboard: put it or save from some common registers (0,",/)
nnoremap <Leader>p :r! xclip -o -sel c<cr>
nnoremap <Leader>P :-1r! xclip -o -sel c<cr>
nnoremap <Leader>0 :call system('xclip -sel c', @0)<cr>
nnoremap <Leader>" :call system('xclip -sel c', @")<cr>
nnoremap <Leader>/ :call system('xclip -sel c', @/)<cr>

" line length guides
function MyColorCols()
    if &colorcolumn ==? '68,78,88'
        set colorcolumn=44,52,56
    elseif &colorcolumn ==? '44,52,56'
        set colorcolumn=
    else
        set colorcolumn=68,78,88
    endif
endfunction
nnoremap <Leader>co :call MyColorCols()<cr>
nnoremap <Leader>8 :set tw=88<cr>
nnoremap <Leader>7 :set tw=68<cr>
nnoremap <Leader>5 :set tw=56<cr>
nnoremap <Leader>4 :set tw=44<cr>

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

" equalize on resize
augroup windowage
    autocmd VimResized * wincmd =
augroup END

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

" Toggle distraction-free mode
function DistractionFreeToggle()
    let g:distraction_free_mode = get(g:, 'distraction_free_mode', 0)
    if g:distraction_free_mode == 0
        let g:distraction_free_mode = 1
        set laststatus=1
        set nonumber
        set norelativenumber
        set cmdheight=1
        set noruler
    else
        let g:distraction_free_mode = 0
        set laststatus=2
        set number
        set relativenumber
        set cmdheight=2
        set ruler
    endif
endfunction
nnoremap <silent> <Leader>df :call DistractionFreeToggle()<cr>

" grep with ag (apt install silversearcher-ag)
set grepprg=ag
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
nnoremap <Leader>rc /^<<<<<<<\\|^=======\\|^>>>>>>><cr>
" "resolve right"
nnoremap <Leader>rr dnddkndd
" "resolve left"
nnoremap <Leader>rl ddkndndd

" Sometimes it's nice to have random things, for tests and whatnot
" "random word append"
nnoremap <Leader>ra :execute "normal a" . system("echo -n $(grep -v \\' /usr/share/dict/words \| shuf -n 1)")<cr>
" "random word insert"
nnoremap <Leader>ri :execute "normal i" . system("echo -n $(grep -v \\' /usr/share/dict/words \| shuf -n 1)")<cr>

" Grab a timestamp
nnoremap <silent> <Leader>dt :r! date<cr>

" Open thesaurus on a word
nnoremap <Leader>th :call system("xdg-open http://www.thesaurus.com/browse/<C-r><C-w>")<cr>

" Open diffs in tabs for each file that differs between working copy and the
" supplied target (default: current merge base with main branch)
command! -nargs=? Gtdiff call s:Gtdiff(<q-args>)
function! s:Gtdiff(...)
    if empty(a:000) || a:1 ==? ''
        let l:merge_base = system('git merge-base HEAD develop')
        if v:shell_error
            let l:merge_base = system('git merge-base HEAD trunk')
            if v:shell_error
                let l:merge_base = system('git merge-base HEAD master')
            endif
        endif
        let l:base = substitute(l:merge_base, '[^0-9a-f]\+$', '', '')
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
                execute 'Gedit ' . l:base . ':' . fnameescape(l:f)
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
                set diffopt+=iwhite
                execute 'Gdiff ' . l:base
                execute 'lcd ' . l:workingdir
                execute 'normal '
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

augroup gitcommit
    autocmd FileType gitcommit set spell spelllang=en_us spellcapcheck=
    autocmd FileType gitcommit setlocal colorcolumn=50,72
augroup END

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
let g:ale_python_mypy_options = '--ignore-missing-imports --incremental --follow-imports=silent'
nnoremap <silent> <Leader>ll :ALELint<cr>
if filereadable('etc/pylintrc')
    let g:ale_python_flake8_change_directory=0
    let g:ale_python_flake8_options='--config=etc/pep8.cfg'
    let g:ale_python_pylint_options='--load-plugins pylint_ext --rcfile etc/pylintrc'
    else
    let g:ale_python_flake8_options='--ignore=W503,E203 --max-line-length=88'
endif
" disable jshint -- conflicts with prettier...
let g:ale_linters = {
\   'javascript': ['eslint', 'flow', 'jscs', 'standard', 'xo'],
\   'text': ['alex', 'proselint', 'write-good'],
\}
" 
let g:ale_fixers = {}
" goimports does gofmt + import cleanup
let g:ale_fixers['go'] = ['goimports']
let g:ale_fixers['javascript'] = ['prettier']
let g:ale_fixers['markdown'] = ['prettier']
let g:ale_fixers['python'] = ['black', 'isort']
let g:ale_fixers['sh'] = ['shfmt']
nnoremap <silent> <Leader>lf :ALEFix<cr>

" go
let g:gofmt_command = 'goimports'
nnoremap <Leader>go :GoDef<cr>

if executable('sqlfmt')
    augroup sqlformat
    au FileType sql setl formatprg=sqlfmt
    augroup END
" SQL formatter: https://github.com/darold/pgFormatter
elseif filereadable('/usr/local/bin/pg_format')
    augroup sqlformat
    au FileType sql setl formatprg=/usr/local/bin/pg_format\ \-B\ -s\ 2\ -
    augroup END
endif

" column view
nnoremap <Leader>c3 <C-w>o:set noscrollbind
            \ nocursorbind<cr>:vs<cr>:vs<cr>gg:set linebreak
            \ scrollbind<cr>2<C-w>wgg<C-f>:set linebreak
            \ scrollbind<cr>3<C-w>wgg<C-f><C-f>:set linebreak
            \ scrollbind<cr>2<C-w>w<C-o>
nnoremap <Leader>c2 <C-w>o:set noscrollbind
            \ nocursorbind<cr>:vs<cr>gg:set linebreak
            \ scrollbind<cr>2<C-w>wgg<C-f>:set linebreak
            \ scrollbind<cr><C-o>

" nice, stolen from https://stackoverflow.com/a/6271254
" and linted
function! GetVisualSelection()
    let [l:line_start, l:column_start] = getpos("'<")[1:2]
    let [l:line_end, l:column_end] = getpos("'>")[1:2]
    let l:lines = getline(l:line_start, l:line_end)
    if len(l:lines) == 0
        return ''
    endif
    let l:lines[-1] = l:lines[-1][: l:column_end - (&selection ==? 'inclusive' ? 1 : 2)]
    let l:lines[0] = l:lines[0][l:column_start - 1:]
    return join(l:lines, "\n")
endfunction

" quick fix a spelling error
" my left pinkie is not really up to the 1-z maneuver
nnoremap <Leader>z= 1z=

" used a lot in code archaelogy
nnoremap <Leader>cj :colder<cr>
nnoremap <Leader>ck :cnewer<cr>

" set up persistent undo
if has('persistent_undo')
    let s:myUndoDir = expand('$HOME/.vimundo')
    if !isdirectory(s:myUndoDir)
    call mkdir(s:myUndoDir, 'p')
    endif
    execute 'set undodir=' . s:myUndoDir
    set undofile
endif

" always nowrap in quickfix list
autocmd! QuickfixCmdPost * set nowrap
