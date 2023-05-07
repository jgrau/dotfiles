" Basics {
  set nocompatible " No vi compatility
  let mapleader = "\<Space>"
" }

" General {
  filetype plugin indent on                   " required!
  filetype indent on
  filetype on

  set smartindent
  set tabstop=2
  set shiftwidth=2
  set expandtab
  set timeoutlen=1000 ttimeoutlen=0 " do not wait for esc key combination

  "folding settings
  set foldmethod=indent " fold based on indent
  set foldnestmax=10    " deepest fold is 10 levels
  set nofoldenable      " dont fold by default
  set foldlevelstart=0

  " No needs for backups, I have Git for that
  set noswapfile
  set nobackup
  set nowritebackup

  set list " Highlight trailings, stolen from @teoljungberg
  set listchars=tab:>-,trail:.,extends:>,precedes:<

  " Open quickfix window when text is added to it
  augroup vimrc
    autocmd User AsyncRunStart call asyncrun#quickfix_toggle(8, 1)
  augroup END
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
    set ignorecase " Case insensitive search
    set smartcase " Case sensitive when uppercase is present
    set incsearch " Search as you type
    set nohlsearch " Highlight search matches

    let g:ag_prg="ag --follow --vimgrep"
  " }