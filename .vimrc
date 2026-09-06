"""""""""""""
"  Plugins  "
"""""""""""""
" plugins
""" vimplug
call plug#begin()
" The default plugin directory will be as follows:
"   - Vim (Linux/macOS): '~/.vim/plugged'
"   - Vim (Windows): '~/vimfiles/plugged'
"   - Neovim (Linux/macOS/Windows): stdpath('data') . '/plugged'
" You can specify a custom plugin directory by passing it as the argument
"   - e.g. `call plug#begin('~/.vim/plugged')`
"   - Avoid using standard Vim directory names like 'plugin'

" Make sure you use single quotes

"" common plugins
Plug 'preservim/nerdtree' |
            \ Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'ycm-core/YouCompleteMe'
Plug 'lervag/vimtex'
Plug 'slint-ui/vim-slint'
Plug 'wellle/context.vim'
Plug 'catppuccin/vim', { 'as': 'catppuccin' }
Plug 'cpiger/vim-qt'
Plug 'ryanoasis/vim-devicons'
Plug 'https://tpope.io/vim/fugitive.git'
Plug 'catppuccin/vim', { 'as': 'catppuccin' }
Plug 'vim-airline/vim-airline'
Plug 'preservim/tagbar'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'mbbill/undotree'

"" disabled plugins
"Plug 'github/copilot.vim'
"Plug 'prabirshrestha/vim-lsp'
"Plug 'prabirshrestha/asyncomplete.vim'
"Plug 'dedzago/latex-img-paste.vim'
"Plug 'tpope/vim-surround'
"Plug 'tpope/vim-repeat'
"Plug 'tpope/vim-commentary'
"Plug 'jiangmiao/auto-pairs'

"" snips
Plug 'sirver/ultisnips'
Plug 'honza/vim-snippets'
""" settings
let g:UltiSnipsExpandTrigger = '<f2>'
let g:UltiSnipsJumpForwardTrigger = '<f2>'
let g:UltiSnipsJumpBackwardTrigger = '<f3>'

" Initialize plugin system
" - Automatically executes `filetype plugin indent on` and `syntax enable`.
call plug#end()

""""""""""""
"  vimtex  "
""""""""""""
"" settings
let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
" Or with a generic interface:
"let g:vimtex_view_general_viewer = 'okular'
"let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'
let g:vimtex_quickfix_mode=0
set conceallevel=1
let g:tex_conceal='abdmg'
let g:vimtex_syntax_conceal = {
\ 'spacing': 0,
\}
let g:vimtex_compiler_method = 'latexmk'
let g:vimtex_compiler_latexmk = {
            \ 'aux_dir' : '',
            \ 'out_dir' : '',
            \ 'callback' : 1,
            \ 'continuous' : 1,
            \ 'executable' : 'latexmk',
            \ 'hooks' : [],
            \ 'options' : [
            \   '-verbose',
            \   '-file-line-error',
            \   '-synctex=1',
            \   '-interaction=nonstopmode',
            \ ],
            \}
"let g:vimtex_compiler_tectonic = {
"        \ 'out_dir' : '',
"        \ 'hooks' : [],
"        \ 'options' : [
"        \   '--keep-logs',
"        \   '--synctex',
"        \   '-Z shell-escape',
"        \ ],
"        \}
nnoremap <localleader>lc :w<cr>:VimtexCompile<cr>
nnoremap <localleader>lv :VimtexView<cr>
"autocmd FileType tex,latex nnoremap <silent> <leader>p :call mdip#LatexClipboardImage()<CR>
" there are some defaults for image directory and image name, you can change them
" let g:mdip_imgdir = 'img'
"let g:mdip_imgname = 'images'

"" latex image paste
function! PasteImage()
    " Check if clipboard has an image
    let l:types = system('wl-paste --list-types')
    if l:types =~ 'image/png'
        " Generate file path
        let l:file = 'img/img_' . strftime('%s') . '.png'
        " Save clipboard image
        call system("wl-paste -t image/png > " . shellescape(l:file))
        " Insert LaTeX code
        execute "normal! o\\begin{figure}"
        execute "normal! o  \\centering"
        execute "normal! o  \\includegraphics[width=0.8\\linewidth]{" . l:file . "}"
        execute "normal! o  \\caption{}"
        execute "normal! o  \\label{fig:}"
        execute "normal! o\\end{figure}"
        "let l:file = 'img/img_' . strftime('%s') . '.png'

        "call append(line('.'), [
        "    \ '\begin{figure}',
        "    \ '\centering',
        "    \ '\includegraphics[width=0.8\linewidth]{' . l:file . '}',
        "    \ '\caption{}',
        "    \ '\label{fig:}',
        "    \ '\end{figure}'
        "    \ ])

        "" Reindent the inserted block
        "execute (line('.')+1) . ',' . (line('.')+6) . 'normal! ='
    else
        echo "No image in clipboard"
    endif
endfunction
""""""""""""""
"  Autosave  "
""""""""""""""

let g:autosave_updatetime = 1000
augroup AutoSaveFiletypes
    autocmd!
    autocmd FileType tex call AutoSaveStart()
    autocmd FileType tex autocmd BufUnload <buffer> call timer_stop(get(b:, 'autosave_timer', -1))

augroup END

function! AutoSave(timer_id) abort
    if &modified && &buftype ==# ''
        silent update
    endif
endfunction

function! AutoSaveStart() abort
    if get(b:, 'autosave_timer', -1) == -1
        let b:autosave_timer = timer_start(
            \ g:autosave_updatetime,
            \ 'AutoSave',
            \ {'repeat': -1}
            \ )
    endif
endfunction
"""""""""""""""""""""""
"  Autofolding vimrc  "
"""""""""""""""""""""""
"" Autofolding .vimrc
" see http://vimcasts.org/episodes/writing-a-custom-fold-expression/
""" defines a foldlevel for each line of code
function! VimFolds(lnum)
  let s:thisline = getline(a:lnum)
  if match(s:thisline, '^"" ') >= 0
    return '>2'
  endif
  if match(s:thisline, '^""" ') >= 0
    return '>3'
  endif
  let s:two_following_lines = 0
  if line(a:lnum) + 2 <= line('$')
    let s:line_1_after = getline(a:lnum+1)
    let s:line_2_after = getline(a:lnum+2)
    let s:two_following_lines = 1
  endif
  if !s:two_following_lines
      return '='
  endif
  else
    if (match(s:thisline, '^"""""') >= 0) &&
       \ (match(s:line_1_after, '^"  ') >= 0) &&
       \ (match(s:line_2_after, '^""""') >= 0)
      return '>1'
    else
      return '='
    endif
  endif
endfunction

""" defines a foldtext
function! VimFoldText()
  " handle special case of normal comment first
  let s:info = '('.string(v:foldend-v:foldstart).' l)'
  if v:foldlevel == 1
    let s:line = ' ◇ '.getline(v:foldstart+1)[3:-2]
  elseif v:foldlevel == 2
    let s:line = '   ●  '.getline(v:foldstart)[3:]
  elseif v:foldlevel == 3
    let s:line = '     ▪ '.getline(v:foldstart)[4:]
  endif
  if strwidth(s:line) > 80 - len(s:info) - 3
    return s:line[:79-len(s:info)-3+len(s:line)-strwidth(s:line)].'...'.s:info
  else
    return s:line.repeat(' ', 80 - strwidth(s:line) - len(s:info)).s:info
  endif
endfunction

""" set foldsettings automatically for vim files
augroup fold_vimrc
  autocmd!
  autocmd FileType vim
                   \ setlocal foldmethod=expr |
                   \ setlocal foldexpr=VimFolds(v:lnum) |
                   \ setlocal foldtext=VimFoldText() |
                   \ setlocal foldlevel=0
     "              \ set foldcolumn=2 foldminlines=2
augroup END

"""""""""""""""""""""""""""
"  Autofolding lua files  "
"""""""""""""""""""""""""""

""" defines a foldlevel for each line of code
function! LuaFolds(lnum)
    let s:thisline = getline(a:lnum)
    if match(s:thisline, '^\s*---- ') >= 0
        return '>2'
    endif
    if match(s:thisline, '^\s*------ ') >= 0
        return '>3'
    endif
    let s:two_following_lines = 0
    if line(a:lnum) + 2 <= line('$')
        let s:line_1_after = getline(a:lnum+1)
        let s:line_2_after = getline(a:lnum+2)
        let s:two_following_lines = 1
    endif
    if !s:two_following_lines
        return '='
    endif
    else
      if match(s:thisline, '^--------\+$') >= 0 &&
         \ match(s:line_1_after, '^--.\+--\s*$') >= 0 &&
         \ match(s:line_2_after, '^--------\+$') >= 0
        return '>1'
      else
        return '='
    endif
  endif
endfunction

""" defines a foldtext
function! LuaFoldText()
    let s:info = '('.(v:foldend-v:foldstart).' l)'

    if v:foldlevel == 1
        let s:line = ' ◇ '..getline(v:foldstart+1)[3:-3]
    elseif v:foldlevel == 2
        let s:line = '   ● '.substitute(getline(v:foldstart), '^\s*----\s*', '', '')
    elseif v:foldlevel == 3
        let s:line = '     ▪ '.substitute(getline(v:foldstart), '^\s*------\s*', '', '')
    endif
    if strwidth(s:line) > 80 - len(s:info) - 3
        return s:line[:79-len(s:info)-3+len(s:line)-strwidth(s:line)].'...'.s:info
    else
        return s:line.repeat(' ', 80-strwidth(s:line)-len(s:info)).s:info
    endif
endfunction

""" set foldsettings automatically for lua files
augroup fold_lua
    autocmd!
    autocmd FileType lua
                \ setlocal foldmethod=expr |
                \ setlocal foldexpr=LuaFolds(v:lnum) |
                \ setlocal foldtext=LuaFoldText() |
                \ setlocal foldlevel=0
augroup END

"""""""""
"  YCM  "
"""""""""
""" settings
let g:ycm_clangd_uses_ycmd_caching = 0
let g:ycm_clangd_binary_path = exepath("clangd")
"let g:ycm_clangd_args = [ 'project_root_files': ['Makefile', '.git'] ]
"""  lsp
let g:ycm_language_server = [
    \ {
    \   'name': 'rust',
    \   'filetypes': ['rust'],
    \   'cmdline': ['rust-analyzer'],
    \   'project_root_files': ['Cargo.toml', '.git'],
    \   'initialization_options': {
    \       'cargo': {'buildScripts': {'enable': v:true}},
    \       'procMacro': {'enable': v:true}
    \   },
    \   'env': {'RUST_BACKTRACE': '1'},
    \ },
    \ {
    \   'name': 'slint',
    \   'filetypes': ['slint'],
    \   'cmdline': ['slint-lsp'],
    \   'project_root_files': ['.git'],
    \   'initialization_options': {},
    \ },
    \ {
    \   'name': 'texlab',
    \   'filetypes': ['tex', 'bib'],
    \   'cmdline': ['texlab'],
    \   'project_root_files': ['main.tex', '.git'],
    \   'initialization_options': {},
    \ },
    \ {
    \   'name': 'slangd',
    \   'filetypes' :['shaderslang'],
    \   'cmdline': ['slangd'],
    \   'project_root_files': ['.git'],
    \   'initialization_options': {},
    \ },
\ ]

""" stuff commented out
"if executable('rust-analyzer')
"    au User lsp_setup call lsp#register_server({
"        \ 'name': 'rust-analyzer',
"        \ 'cmd': {server_info -> ['rust-analyzer']},
"        \ 'allowlist': ['rust'],
"        \ })
"endif
"
"function! s:on_lsp_buffer_enabled() abort
"    setlocal omnifunc=lsp#complete
"    setlocal signcolumn=yes
"    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
"    nmap <buffer> gd <plug>(lsp-definition)
"    nmap <buffer> gs <plug>(lsp-document-symbol-search)
"    nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
"    nmap <buffer> gr <plug>(lsp-references)
"    nmap <buffer> gi <plug>(lsp-implementation)
"    nmap <buffer> gt <plug>(lsp-type-definition)
"    nmap <buffer> <leader>rn <plug>(lsp-rename)
"    nmap <buffer> [g <plug>(lsp-previous-diagnostic)
"    nmap <buffer> ]g <plug>(lsp-next-diagnostic)
"    nmap <buffer> K <plug>(lsp-hover)
"    nnoremap <buffer> <expr><c-f> lsp#scroll(+4)
"    nnoremap <buffer> <expr><c-d> lsp#scroll(-4)
"
"    let g:lsp_format_sync_timeout = 1000
"    autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
"
"    " refer to doc to add more commands
"endfunction
"
"augroup lsp_install
"    au!
"    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
"    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
"augroup END
"
"inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
"inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
"inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"
"
""" more stuff
" " allow modifying the completeopt variable, or it will
" " be overridden all the time
"let g:asyncomplete_auto_completeopt = 0
"
"set completeopt=menuone,noinsert,noselect,preview
"
"autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

"let g:lightline = {'colorscheme': 'catppuccin_frappe'}
"let g:airline_theme = 'catppuccin_mocha'

""""""""""""""""""""""
"  General settings  "
""""""""""""""""""""""
syntax enable
set termguicolors
set shell=/bin/zsh
colorscheme habamax
"set statusline+=%{FugitiveStatusline()}

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set encoding=utf8
set cinoptions=l1
set completeopt=menu,menuone,noselect
set encoding=UTF-8

set number
set cursorline
set mouse=a
filetype indent on
set wildmenu
set wildoptions=pum,fuzzy
set wildmode=longest:full,full
set wildignorecase
set lazyredraw
set showmatch
set ignorecase
set smartcase
set hlsearch
set nomodeline
set colorcolumn=80

set incsearch
set foldenable
set foldlevelstart=10
nnoremap <space> za
set foldmethod=syntax
set backup
set backupdir=~/.vim-tmp
set backupskip=/tmp/*,/private/tmp/*
set directory=~/.vim-tmp
set writebackup

set undofile
set undodir=~/.vim-tmp/undo

""""""""""""""
"  mappings  "
""""""""""""""
"source ~/.config/vim/extras.vim
let mapleader="\\"
let maplocalleader=","

nnoremap j gj
nnoremap k gk
nnoremap <Up> gk
nnoremap <Down> gj

nnoremap <leader>p :call PasteImage()<CR>
nmap <F8> :TagbarToggle<CR>
nnoremap <F5> :UndotreeToggle<CR>

nnoremap s i<CR><ESC>

"" tab management
nnoremap <leader>t :tabnew<CR>
nnoremap <leader>h :tabp<CR>
nnoremap <leader>l :tabN<CR>
nnoremap <leader>ev :vsp $MYVIMRC<CR>
nnoremap <leader>ez :vsp ~/.zshrc<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>

"" YCM
nnoremap <leader>jd :YcmCompleter GoToDefinition<CR>
nnoremap <leader>ju :YcmCompleter GoToCallers<CR>
nnoremap <leader>jr :YcmCompleter GoToReferences<CR>
nmap <leader>jf <Plug>(YCMFindSymbolInWorkspace)
nnoremap <Leader>jk :lprevious<CR>zz
nnoremap <Leader>jj :lnext<CR>zz
nnoremap <leader>jt :YcmCompleter GetType<CR>
nnoremap <leader>jo :YcmCompleter GetDoc<CR>
nnoremap <leader>jx :YcmCompleter FixIt<CR>

"" fzf.vim
nnoremap <C-p> :Files<CR>
nnoremap <leader>f :Rg<Space>
nnoremap <leader>b :Buffers<CR>

"" disabled ones
"nnoremap <C-k> <C-w>k
"nnoremap <C-j> <C-w>j
"nnoremap <C-h> <C-w>h
"nnoremap <C-l> <C-w>l

""""""""""""""
"  nerdtree  "
""""""""""""""
"" startup
"autocmd StdinReadPre * let s:std_in=1
"autocmd VimEnter *
"  \ if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") |
"  \   execute 'NERDTree' argv()[0] |
"  \   wincmd p |
"  \   enew |
"  \ else |
"  \   NERDTree |
"  \   wincmd p |
"  \ endif
" Start NERDTree and put the cursor back in the other window.
"autocmd VimEnter * NERDTree | wincmd p

autocmd StdinReadPre * let s:std_in=1
"autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
"            \ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif

" Start NERDTree. If a file is specified, move the cursor to its window.
"autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if !&diff | NERDTree | if argc() > 0 || exists("s:std_in") | wincmd p | endif

" Start NERDTree when Vim is started without file arguments.
"autocmd StdinReadPre * let s:std_in=1
"autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif

"
" Exit Vim if NERDTree is the only window remaining in the only tab.
"autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" Exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | call feedkeys(":quit\<CR>:\<BS>") | endif

" Close the tab if NERDTree is the only window remaining in it.
"autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" Close the tab if NERDTree is the only window remaining in it.
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | call feedkeys(":quit\<CR>:\<BS>") | endif

" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
                        \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif

" Open the existing NERDTree on each new tab.
autocmd BufWinEnter * if getcmdwintype() == '' | silent NERDTreeMirror | endif

"" auto resize
function! SetNerdTreeWidth()
  let l:width = max([15, float2nr(&columns * 0.15)])
  let g:NERDTreeWinSize = l:width
  " Resize existing NERDTree window if open
  if exists("t:NERDTreeBufName")
    let l:curwin = winnr()

    for l:w in range(1, winnr('$'))
      if getbufvar(winbufnr(l:w), '&filetype') ==# 'nerdtree'
        execute l:w . 'wincmd w'
        execute 'vertical resize ' . l:width
        break
      endif
    endfor

    execute l:curwin . 'wincmd w'
  endif
endfunction

augroup NerdTreeResize
  autocmd!
  autocmd VimEnter,VimResized * call SetNerdTreeWidth()
augroup END

"" settings
let NERDTreeShowHidden=1
let g:NERDTreeChDirMode = 2

"""""""""""""""""""""
"  bottom terminal  "
"""""""""""""""""""""
autocmd TerminalOpen * setlocal nonumber norelativenumber
let g:bottom_term_buf = -1

"function! ToggleBottomTerminal()
"  if bufexists(g:bottom_term_buf)
"    if bufwinnr(g:bottom_term_buf) != -1
"      execute bufwinnr(g:bottom_term_buf) . 'hide'
"      return
"    endif
"
"    belowright 14split
"    execute 'buffer ' . g:bottom_term_buf
"    call feedkeys("i")
"    return
"  endif
"
"  belowright 14split
"  term ++curwin
"  let g:bottom_term_buf = bufnr('%')
"  "startinsert
"endfunction
function! ToggleBottomTerminal()
  " Hide terminal if visible
  if bufexists(g:bottom_term_buf)
    if bufwinnr(g:bottom_term_buf) != -1
      execute bufwinnr(g:bottom_term_buf) . 'hide'
      return
    endif

    botright 14split
    execute 'buffer ' . g:bottom_term_buf
    let l:termwin = win_getid()

    for w in range(1, winnr('$'))
        if getbufvar(winbufnr(w), '&filetype') == 'nerdtree'
            execute w . 'wincmd w'
            wincmd H
            call SetNerdTreeWidth()
            break
        endif
    endfor

    call win_gotoid(l:termwin)
    "startinsert
    call feedkeys("i")
    return
  endif

  botright 14split
  term ++curwin
  let g:bottom_term_buf = bufnr('%')
  let l:termwin = win_getid()

  for w in range(1, winnr('$'))
      if getbufvar(winbufnr(w), '&filetype') == 'nerdtree'
          execute w . 'wincmd w'
          wincmd H
          call SetNerdTreeWidth()
          break
      endif
  endfor

  call win_gotoid(l:termwin)
  "startinsert
  "call feedkeys("i")
endfunction

nnoremap <leader>tt :call ToggleBottomTerminal()<CR>
tnoremap <leader>tt <C-\><C-n>:call ToggleBottomTerminal()<CR>
tnoremap jk <C-\><C-n>
