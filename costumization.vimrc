"
"===============================================================================
"==========  CUSTOMIZATION (vimrc)  ============================================
"===============================================================================
"
set tabstop=2
set shiftwidth=2
set autowrite
set incsearch
set visualbell
set nowrap
"
"-------------------------------------------------------------------------------
" After entering a buffer, the working directory is changed to the directory
" where the file in the current buffer comes from.
"-------------------------------------------------------------------------------
if has("autocmd")
	autocmd BufEnter * :lcd %:p:h
endif " has("autocmd")
"
