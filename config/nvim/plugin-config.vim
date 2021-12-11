  " Fugitive {
    map <Leader>gc :Gcommit
    map <Leader>gs :Gstatus<CR>
  " }

  " Surround {
    let b:surround_{char2nr('=')} = "<%= \r %>"
    let b:surround_{char2nr('-')} = "<% \r %>"
  " }

  " Ruby block told me to
  runtime macros/matchit.vim

  " Expand region
  vmap v <Plug>(expand_region_expand)
  vmap <C-v> <Plug>(expand_region_shrink)
