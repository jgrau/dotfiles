" Basics {
  set nocompatible " No vi compatility
  let mapleader = "\<Space>"
" }

" Plugins {
  call plug#begin('~/.vim/plugged')

  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-markdown', { 'for': 'markdown' }
  Plug 'tpope/vim-haml', { 'for': 'haml' }
  Plug 'tpope/vim-rails'
  Plug 'tpope/vim-cucumber'
  Plug 'tpope/vim-bundler'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-repeat'
  Plug 'tpope/vim-unimpaired'
  Plug 'tpope/vim-abolish'
  " Plug 'tpope/vim-sleuth'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-endwise'
  Plug 'tpope/vim-dispatch'
  Plug 'tpope/vim-ragtag'
  Plug 'tpope/vim-sensible'
  Plug 'vim-ruby/vim-ruby', { 'for': 'ruby' }
  Plug 'rodjek/vim-puppet', { 'for': 'puppet' }
  Plug 'scrooloose/nerdtree'
  Plug 'scrooloose/syntastic', { 'for': ['ruby', 'javascript', 'css'] }
  Plug 'rizzatti/funcoo.vim'
  Plug 'rizzatti/dash.vim'
  Plug 'pangloss/vim-javascript'
  Plug 'kchmck/vim-coffee-script'
  Plug 'mileszs/ack.vim'
  Plug 'bling/vim-airline'
  Plug 'altercation/vim-colors-solarized'
  Plug 'nelstrom/vim-textobj-rubyblock'
  Plug 'kana/vim-textobj-user'
  Plug 'godlygeek/tabular'
  Plug 'kien/ctrlp.vim'
  Plug 'sunaku/vim-ruby-minitest'
  Plug 'vim-scripts/taglist.vim'
  Plug 'majutsushi/tagbar'
  Plug 'AndrewRadev/splitjoin.vim'
  Plug 'othree/html5.vim'
  Plug 'christoomey/vim-tmux-navigator'
  Plug 'dkprice/vim-easygrep'
  Plug 'rking/ag.vim'
  Plug 'terryma/vim-expand-region'
  Plug 'gregsexton/gitv'
  Plug 'janko-m/vim-test'
  Plug 'benmills/vimux'
  Plug 'ervandew/supertab'
  Plug 'benekastah/neomake'
  Plug 'Shougo/unite.vim'
  Plug 'Quramy/vison', { 'for': 'json' }

  filetype plugin indent on                   " required!
  call plug#end()
" }

" General {
  filetype indent on
  filetype on
  set smartindent
  set tabstop=2
  set shiftwidth=2
  set expandtab

  "folding settings
  set foldmethod=indent " fold based on indent
  set foldnestmax=10    " deepest fold is 10 levels
  set nofoldenable      " dont fold by default
  set foldlevelstart=0

  " No needs for backups, I have Git for that
  set noswapfile
  set nobackup
  set nowritebackup

  " Remove whitespace on save
  autocmd BufWritePre * :%s/\s\+$//e

  " Run Neomake on save
  autocmd! BufWritePost * Neomake

  set list " Highlight trailings, stolen from @teoljungberg
  set listchars=tab:>-,trail:.,extends:>,precedes:<

  set tags=.git/tags " Use commit hook tags, see ~/.git_template
" }

  set ruler " Enable cursor position
  set showcmd  " Show incomplete CMDS at the bottom
  set autoread " Auto read when file is changed
  set hidden " Hide buffers, rather than close them
  set showmatch " Show matching of: () [] {}
  set matchpairs+=<:> " Match <> (HTML)
  set number  " always show line numbers"

  " Searching {
    set wildignore+=vendor/bundle/**
    set wildignore+=bin/**
    set wildignore+=log/**
    set wildignore+=*/tmp/*,*.so,*.swp,*.zip
    set wildignore+=.git/**
    set ignorecase " Case insensitive search
    set smartcase " Case sensitive when uppercase is present
    set incsearch " Search as you type
    set nohlsearch " Highlight search matches
  " }

  set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P

  " Vim UI {
    if &t_Co > 2 || has("gui_running")
      syntax on " switch syntax highlighting on, when the terminal has colors
      colorscheme solarized " GUI Colorscheme
      set background=dark
      set guifont=Menlo\ Regular\ for\ Powerline:h12
      let g:solarized_visibility = "high"
      let g:solarized_contrast = "high"
    endif
  " }

  " GVim {
    if has("gui_running")
      colorscheme solarized " GUI Colorscheme
      set background=dark
      set guifont=Menlo\ Regular\ for\ Powerline:h12
      " set lines=999 columns=9999 " Start full screen

      let g:solarized_visibility = "high"
      let g:solarized_contrast = "high"

      " GVIm options {
        set guioptions-=m " Remove menu bar
        set guioptions-=T " Remove toolbar with icons
        set guioptions-=r " Remove scrollbars (http://vimdoc.sourceforge.net/htmldoc/options.html#%27guioptions%27)
        set guioptions-=l
        set guioptions-=L
      " }

      " Title {
        if has('title')
          set titlestring=
          set titlestring+=%f\                                              " file name
          set titlestring+=%h%m%r%w                                         " flags
          set titlestring+=\ -\ %{v:progname}                               " program name
          set titlestring+=\ -\ %{substitute(getcwd(),\ $HOME,\ '~',\ '')}  " working directory
        endif
      " }
    endif
  " }

  " MVIM {
    if has("gui_macvim")
      set guifont=Menlo\ Regular\ for\ Powerline:h12
      set transparency=5
    endif
  " }
" }

" Key Mapping {
  " Press i to enter insert mode, and ii to exit.
  map <C-J> <C-W>j
  map <C-K> <C-W>k
  map <C-L> <C-W>l
  map <C-H> <C-W>h
  map <C-K> <C-W>k

  " Move lines
  nnoremap ∆ :m .+1<CR>==
  nnoremap ˚ :m .-2<CR>==
  inoremap ∆ <Esc>:m .+1<CR>==gi
  inoremap ˚ <Esc>:m .-2<CR>==gi
  vnoremap ∆ :m '>+1<CR>gv=gv
  vnoremap ˚ :m '<-2<CR>gv=gv

  nnoremap <A-j> :m .+1<CR>==
  nnoremap <A-k> :m .-2<CR>==
  inoremap <A-j> <Esc>:m .+1<CR>==gi
  inoremap <A-k> <Esc>:m .-2<CR>==gi
  vnoremap <A-j> :m '>+1<CR>gv=gv
  vnoremap <A-k> :m '<-2<CR>gv=gv

  " Quickly edit/reload the vimrc file
  nmap <silent> <leader>ev :e $MYVIMRC<CR>
  nmap <silent> <leader>sv :so $MYVIMRC<CR>

  " Quick yanking to the end of the line
  nmap Y y$

  " Key mappings
  :noremap ,d :bd<CR>
  cmap w!! w !sudo tee %
  map ,c :cd %:p:h<CR>

  " Ruby 1.8 -> 1.9 Hash syntax
  map <Leader>s :%s/:\([^ ]*\)\(\s*\)=>/\1:/g<CR>

  " Quicksave
  nnoremap <Leader>w :w<CR>
" }


" Plugins {
  " NerdTree {
    let NERDTreeChDirMode = 1
    let NERDTreeWinSize=20
    let NERDTreeQuitOnOpen=1
    let NERDTreeHijackNetrw=1

    :noremap <Leader>n :NERDTreeToggle<CR>
  " }

  " Fugitive {
    map <Leader>gc :Gcommit
    map <Leader>gs :Gstatus<CR>
  " }

  " Surround {
    let b:surround_{char2nr('=')} = "<%= \r %>"
    let b:surround_{char2nr('-')} = "<% \r %>"
  " }

  " Syntastic {
    let g:syntastic_ruby_checkers = ['mri', 'rubocop']
    let g:syntastic_javascript_checkers = ['standard']
    let g:syntastic_coffee_coffeelint_args="-f .coffeelint.json"
    let g:syntastic_mode_map = { 'passive_filetypes': ['ruby'] }
    let g:syntastic_always_populate_loc_list = 1
  " }

  " Neomake {
    let g:neomake_verbose = 0
    let g:neomake_ruby_enabled_makers = ['rubocop']
    let g:neomake_javascript_enabled_makers = []
  " }

  " Airline {
    let g:airline_powerline_fonts = 1
  " }

  " Tabular {
    if exists(":Tabularize")
      nmap <Leader>a= :Tabularize /=<CR>
      vmap <Leader>a= :Tabularize /=<CR>
      nmap <Leader>a: :Tabularize /:\zs<CR>
      vmap <Leader>a: :Tabularize /:\zs<CR>

      " Align ruby symbol hashes on the hash marker
      AddTabularPattern! rbshash /\s\?\w\+:[^:]/l0l0
      AddTabularPattern! rbhash /^[^=]*\zs=>

      " Mappings for ruby hash rocket and symbol hashes
      " nnoremap <silent> <Leader>ahr :Tabularize rbhash<CR>
      " vnoremap <silent> <Leader>ahr :Tabularize rbhash<CR>
      " nnoremap <silent> <Leader>ahs  :Tabularize rbshash<CR>
      " vnoremap <silent> <Leader>ahs  :Tabularize rbshash<CR>
    endif
  " }

  " Rails testing {
    " Test runner {
      " map <leader>R :wa<CR>:.Rrunner<CR>
      " map <leader>r :wa<CR>:Rrunner<CR>
    " }

    " Vroom {
      " let g:vroom_use_spring = 1
      " let g:vroom_use_dispatch = 1
      " let g:vroom_clear_screen = 0
      " let g:vroom_use_colors = 1
      " let g:vroom_use_vimux = 1
      " let g:vroom_use_binstubs = 1
      " let g:vroom_write_all  = 0
    " }
    "
    " Thoughbot rspec.vim {
      " let g:rspec_command = "Dispatch rspec {spec}"
      " let g:rspec_command = 'call Send_to_Tmux("rspec {spec}\n")'
      " map <Leader>r :call RunCurrentSpecFile()<CR>
      " map <Leader>R :call RunNearestSpec()<CR>
      " map <Leader>l :call RunLastSpec()<CR>
      " map <Leader>a :call RunAllSpecs()<CR>
    " }
    "
    " Turbux {
      let g:no_turbux_mappings = 1
      " map <leader>r <Plug>SendTestToTmux
      " map <leader>R <Plug>SendFocusedTestToTmux
    " }

    " Vim-test {
    let g:test#strategy = 'vimux' " basic make dispatch vimux tslime terminal iterm
    let VimuxUseNearest = 1
    let g:VimuxHeight = "25"
    let g:VimuxOrientation = "h"
    nmap <silent> <leader>R :TestNearest<CR>
    nmap <silent> <leader>r :TestFile<CR>
    nmap <silent> <leader>a :TestSuite<CR>
    nmap <silent> <leader>l :TestLast<CR>
    nmap <silent> <leader>g :TestVisit<CR>
    " }
  " }

  " Ctrlp
  let g:ctrlp_map = '<Leader>t'
  let g:ctrlp_cmd = 'CtrlP'
  let g:ctrlp_custom_ignore = {
        \ 'dir':  'vendor/cache',
        \ 'file': '\v\.(exe|so|dll)$',
        \ 'link': 'some_bad_symbolic_links',
        \ }

  " Ctrlp + ctags
  nnoremap <leader>y :CtrlPTag<cr>

  " ctags + tagbar
  noremap <silent> <Leader>b :TagbarToggle<CR>

  " Ruby block told me to
  runtime macros/matchit.vim

  " Expand region
  vmap v <Plug>(expand_region_expand)
  vmap <C-v> <Plug>(expand_region_shrink)

  " Ragtag
  inoremap <M-o> <Esc>o
  inoremap <C-j> <Down>
  let g:ragtag_global_maps = 1
" }

" Functions {
" Rename current file, thanks Gary Bernhardt via Ben Orenstein
  function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
      exec ':saveas ' . new_name
      exec ':silent !rm ' . old_name
      redraw!
    endif
  endfunction
  map <leader>mv :call RenameFile()<cr>

  " Copy current buffer path relative to root of VIM session to system clipboard
  nnoremap <Leader>ip :let @*=expand("%")<cr>:echo "Copied file path to clipboard"<cr>

  " Copy current filename to system clipboard
  nnoremap <Leader>if :let @*=expand("%:t")<cr>:echo "Copied file name to clipboard"<cr>

  " Copy current buffer path without filename to system clipboard
  nnoremap <Leader>id :let @*=expand("%:h")<cr>:echo "Copied file directory to clipboard"<cr>
" }
" NeoVIM

if has('nvim')
  let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
  " Hack to get C-h working in neovim
  nmap <BS> <C-W>h
  tnoremap <Esc> <C-\><C-n>
endif
