" Vim filetype plugin file
"
" Language   :  C / C++
" Plugin     :  c.vim
" Maintainer :  Fritz Mehner <mehner@fh-swf.de>
" Last Change:  Jul 31 2003 
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
" Shift-F9   run make
"
 map  <buffer>  <A-F9>       :call C_Compile()<CR><CR>
imap  <buffer>  <A-F9>  <Esc>:call C_Compile()<CR><CR>
 map  <buffer>    <F9>       :call C_Link()<CR><CR>
imap  <buffer>    <F9>  <Esc>:call C_Link()<CR><CR>
 map  <buffer>  <C-F9>       :call C_Run(0)<CR><CR>
imap  <buffer>  <C-F9>  <Esc>:call C_Run(0)<CR><CR>
 map  <buffer>  <S-F9>       :call C_Make()<CR>
imap  <buffer>  <S-F9>  <Esc>:call C_Make()<CR>


