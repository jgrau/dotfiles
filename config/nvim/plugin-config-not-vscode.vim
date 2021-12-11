" Plugins {
  " NerdTree {
    let NERDTreeChDirMode = 1
    let NERDTreeWinSize=20
    let NERDTreeQuitOnOpen=1
    let NERDTreeHijackNetrw=1

    :noremap <Leader>n :NERDTreeToggle<CR>
  " }

  " Ale {
    " let g:ale_enabled = 1
    let g:ale_fixers = {}
    let g:ale_fixers.ruby = ['prettier']
    let g:ale_fixers.javascript = ['eslint']
    let g:ale_fixers.elixir = []
    let g:ale_fixers.sh = ['shfmt']
    let g:ale_fix_on_save = 0
    let g:ale_linters = { 'ruby': ['ruby', 'rubocop'], 'javascript': ['eslint'], 'elixir': [] }
    " let g:ale_lint_on_text_changed = 'normal' " or 'never'
    let g:ale_lint_on_enter = 1
    let g:ale_lint_delay = 1000
    let g:ale_linters_explicit = 1
    let g:ale_echo_msg_error_str = 'E'
    let g:ale_echo_msg_warning_str = 'W'
    let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
    " let g:ale_open_list = 1
    " let g:ale_keep_list_window_open = 1
    " let g:ale_sign_column_always = 1
    " let g:ale_echo_cursor = 0
  " }

  " Neoformat {
    let g:neoformat_ruby_rubocop_daemon = {
          \ 'exe': 'rubocop-daemon-wrapper',
          \ 'args': ['--auto-correct-all', '--stdin', '"%:p"', '2>/dev/null', '|', 'sed "1,/^====================$/d"'],
          \ 'stdin': 1,
          \ 'stderr': 1
          \ }

    let g:neoformat_enabled_ruby = ['rubocop_daemon']
    let g:neoformat_enabled_javascript = ['prettier']
    let g:neoformat_enabled_elixir = []
    let g:neoformat_only_msg_on_error = 1
    let g:neoformat_verbose = 0

    augroup fmt
      autocmd!
      autocmd BufWritePre * undojoin | Neoformat
    augroup END
  " }

  " Vim-test {
    let g:test#strategy = 'vimux' " basic make dispatch vimux tslime neoterm vimshell vtr vimproc asyncrun terminal iterm
    let g:VimuxUseNearest = 1
    let g:VimuxHeight = "25"
    let g:VimuxOrientation = "h"
    nmap <silent> <leader>R :TestNearest<CR>
    nmap <silent> <leader>r :TestFile<CR>
    nmap <silent> <leader>a :TestSuite<CR>
    nmap <silent> <leader>l :TestLast<CR>
    nmap <silent> <leader>g :TestVisit<CR>
  " }

  " fzf
  " nmap ; :Buffers<CR>
  nmap <Leader>t :Files<CR>

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
