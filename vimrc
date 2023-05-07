" auto-install vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  "autocmd VimEnter * PlugInstall
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

function! Cond(cond, ...)
  let opts = get(a:000, 0, {})
  return a:cond ? opts : extend(opts, { 'on': [], 'for': [] })
endfunction

call plug#begin('~/.config/nvim/autoload/plugged')

Plug 'AndrewRadev/switch.vim'
Plug 'justinmk/vim-sneak'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'

" Not activated for vscode
Plug 'tpope/vim-bundler', Cond(!exists('g:vscode'))
Plug 'tpope/vim-markdown', Cond(!exists('g:vscode'), { 'for': 'markdown' })
Plug 'tpope/vim-rails', Cond(!exists('g:vscode'))
Plug 'AndrewRadev/splitjoin.vim', Cond(!exists('g:vscode'))
Plug 'altercation/vim-colors-solarized', Cond(!exists('g:vscode'))
Plug 'b4b4r07/vim-hcl', Cond(!exists('g:vscode'))
Plug 'benmills/vimux', Cond(!exists('g:vscode'))
Plug 'christoomey/vim-tmux-navigator', Cond(!exists('g:vscode'))
Plug 'fatih/vim-hclfmt', Cond(!exists('g:vscode'))
Plug 'itchyny/lightline.vim', Cond(!exists('g:vscode'))
Plug 'janko-m/vim-test', Cond(!exists('g:vscode'))
Plug 'jparise/vim-graphql', Cond(!exists('g:vscode'))
Plug 'junegunn/fzf', Cond(!exists('g:vscode'), { 'dir': '~/.fzf', 'do': './install --all' })
Plug 'junegunn/fzf.vim', Cond(!exists('g:vscode'))
Plug 'mileszs/ack.vim', Cond(!exists('g:vscode'))
Plug 'neoclide/coc.nvim', Cond(!exists('g:vscode'), {'branch': 'release'})
Plug 'sbdchd/neoformat', Cond(!exists('g:vscode'))
Plug 'scrooloose/nerdtree', Cond(!exists('g:vscode'))
Plug 'sheerun/vim-polyglot', Cond(!exists('g:vscode'))
Plug 'skywind3000/asyncrun.vim', Cond(!exists('g:vscode'))
Plug 'tpope/vim-commentary', Cond(!exists('g:vscode'))
Plug 'tpope/vim-dispatch', Cond(!exists('g:vscode'))
Plug 'tpope/vim-sleuth', Cond(!exists('g:vscode'))
Plug 'w0rp/ale', Cond(!exists('g:vscode'))
Plug 'adelarsq/vim-matchit', Cond(!exists('g:vscode'))
Plug 'kana/vim-textobj-user', Cond(!exists('g:vscode'))
Plug 'nelstrom/vim-textobj-rubyblock', Cond(!exists('g:vscode'))

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
  source $HOME/.config/nvim/settings-not-vscode.vim
  source $HOME/.config/nvim/mappings-not-vscode.vim
  source $HOME/.config/nvim/plugin-config-not-vscode.vim
endif
