" Vim filetype plugin file
"
" Language   :  C / C++
" Plugin     :  c.vim
" Maintainer :  Fritz Mehner <mehner@fh-swf.de>
" Last Change:  12.12.2005
"
" This will enable keyword completion for C and C++
" using Vim's dictionary feature |i_CTRL-X_CTRL-K|.
" -----------------------------------------------------------------
"
" Only do this when not done yet for this buffer
" 
if exists("b:did_C_ftplugin")
  finish
endif
let b:did_C_ftplugin = 1
"
" ---------- C/C++ dictionary -----------------------------------
" 
if exists("g:C_Dictionary_File")
    silent! exec 'setlocal dictionary+='.g:C_Dictionary_File
endif    
"
" ---------- Key mappings  -------------------------------------
"
"   Alt-F9   write buffer and compile
"       F9   compile and link
"  Ctrl-F9   run executable
" Shift-F9   command line arguments
"
 map  <buffer>  <silent>  <A-F9>       <C-C>:call C_Compile()<CR>:redraw<CR>:call C_HlMessage()<CR>
imap  <buffer>  <silent>  <A-F9>  <C-C><C-C>:call C_Compile()<CR>:redraw<CR>:call C_HlMessage()<CR>
"
 map  <buffer>  <silent>    <F9>       <C-C>:call C_Link()<CR>:redraw<CR>:call C_HlMessage()<CR>
imap  <buffer>  <silent>    <F9>  <C-C><C-C>:call C_Link()<CR>:redraw<CR>:call C_HlMessage()<CR>
"
" <C-C> seems to be essential here:
 map  <buffer>  <silent>  <C-F9>       <C-C>:call C_Run()<CR>
imap  <buffer>  <silent>  <C-F9>  <C-C><C-C>:call C_Run()<CR>
"
 map  <buffer>  <silent>  <S-F9>       <C-C>:call C_Arguments()<CR>
imap  <buffer>  <silent>  <S-F9>  <C-C><C-C>:call C_Arguments()<CR>
"
" alternate file plugin
"
if exists("loaded_alternateFile")
 map  <buffer>  <silent>  <S-F2>       <C-C>:A<CR>
imap  <buffer>  <silent>  <S-F2>  <C-C><C-C>:A<CR>
endif

"
