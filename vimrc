" auto-install vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  "autocmd VimEnter * PlugInstall
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/autoload/plugged')

Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-markdown', { 'for': 'markdown' }
Plug 'tpope/vim-rails'
Plug 'tpope/vim-bundler'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-abolish'
Plug 'justinmk/vim-sneak'

if exists('g:vscode')
  " Plug 'machakann/vim-highlightedyank'
else
  Plug 'nelstrom/vim-textobj-rubyblock'
  Plug 'sheerun/vim-polyglot'
  Plug 'tpope/vim-dispatch'
  Plug 'tpope/vim-sleuth'
  Plug 'tpope/vim-endwise'
  Plug 'scrooloose/nerdtree'
  Plug 'itchyny/lightline.vim'
  Plug 'altercation/vim-colors-solarized'
  Plug 'kana/vim-textobj-user'
  Plug 'AndrewRadev/splitjoin.vim'
  Plug 'christoomey/vim-tmux-navigator'
  Plug 'mileszs/ack.vim'
  Plug 'skywind3000/asyncrun.vim'
  Plug 'janko-m/vim-test'
  Plug 'benmills/vimux'
  Plug 'w0rp/ale'
  Plug 'sbdchd/neoformat'
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
  Plug 'junegunn/fzf.vim'
  Plug 'jparise/vim-graphql'
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'b4b4r07/vim-hcl'
  Plug 'fatih/vim-hclfmt'
endif

call plug#end()

" Automatically install missing plugins on startup
autocmd VimEnter *
  \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall --sync | q
  \| endif
  
" Load general settings and mappings
source $HOME/.config/nvim/settings.vim
source $HOME/.config/nvim/mappings.vim

if exists('g:vscode')
  source $HOME/.config/nvim/settings-vscode.vim
  source $HOME/.config/nvim/mappings-vscode.vim
else
  source $HOME/.config/nvim/mappings-not-vscode.vim
  source $HOME/.config/nvim/plugin-config-not-vscode.vim
endif
