" Better Navigation
nnoremap <silent> <C-j> :call VSCodeNotify('workbench.action.navigateDown')<CR>
xnoremap <silent> <C-j> :call VSCodeNotify('workbench.action.navigateDown')<CR>
nnoremap <silent> <C-k> :call VSCodeNotify('workbench.action.navigateUp')<CR>
xnoremap <silent> <C-k> :call VSCodeNotify('workbench.action.navigateUp')<CR>
nnoremap <silent> <C-h> :call VSCodeNotify('workbench.action.navigateLeft')<CR>
xnoremap <silent> <C-h> :call VSCodeNotify('workbench.action.navigateLeft')<CR>
nnoremap <silent> <C-l> :call VSCodeNotify('workbench.action.navigateRight')<CR>
xnoremap <silent> <C-l> :call VSCodeNotify('workbench.action.navigateRight')<CR>

nnoremap gr <Cmd>call VSCodeNotify('editor.action.goToReferences')<CR>

" Bind C-/ to vscode commentary since calling from vscode produces double comments due to multiple cursors
xnoremap <expr> <C-/> <SID>vscodeCommentary()
nnoremap <expr> <C-/> <SID>vscodeCommentary() . '_'

nnoremap <silent> <C-w>_ :<C-u>call VSCodeNotify('workbench.action.toggleEditorWidths')<CR>

xnoremap <silent> <C-P> :<C-u>call <SID>openVSCodeCommandsInVisualMode()<CR>

xmap gc  <Plug>VSCodeCommentary
nmap gc  <Plug>VSCodeCommentary
omap gc  <Plug>VSCodeCommentary
nmap gcc <Plug>VSCodeCommentaryLine

nmap <Leader>r :call VSCodeNotify('extension.runFileOnRspec')<CR>
nmap <Leader>R :call VSCodeNotify('extension.runLineOnRspec')<CR>
nmap <Leader>l :call VSCodeNotify('extension.runOnLastSpec')<CR>
nmap <Leader>o :call VSCodeNotify('extension.runOpenSpec')<CR>
nmap <Leader>a :call VSCodeNotify('extension.runAllFilesOnRspec')<CR>
" nmap <Leader>r :call VSCodeNotify('test-explorer.run-file')<CR>
" nmap <Leader>R :call VSCodeNotify('test-explorer.run-test-at-cursor')<CR>
" nmap <Leader>l :call VSCodeNotify('test-explorer.rerun')<CR>
" nmap <Leader>o :call VSCodeNotify('extension.runOpenSpec')<CR>
nmap <Leader>a :call VSCodeNotify('test-explorer.run-all')<CR>

nmap <Leader>e :call VSCodeNotify('editor.action.formatDocument')<CR>

" nmap <Leader>t :call VSCodeNotify('workbench.action.quickOpen')<CR>
" nmap <Leader>p :call VSCodeNotify('workbench.action.showCommands')<CR>
nmap <Leader>w :call VSCodeNotify('workbench.action.files.save')<CR>
" nmap <Leader>q :call VSCodeNotify('workbench.action.closeActiveEditor')<CR>
nmap <Leader>q :call VSCodeNotify('workbench.action.closeEditorsInGroup')<CR>

nnoremap z= <Cmd>call VSCodeNotify('keyboard-quickfix.openQuickFix')<CR>