"
"===============================================================================
"==========  example gvimrc from the distribution  ==============================
"===============================================================================
"
runtime gvimrc_example.vim
"
"
"===============================================================================
"==========  CUSTOMIZATION (gvimrc)  ===========================================
"===============================================================================
"
"-------------------------------------------------------------------------------
" Moving cursor to other windows
" 
" shift down   : change window focus to lower one (cyclic)
" shift up     : change window focus to upper one (cyclic)
" shift left   : change window focus to one on left
" shift right  : change window focus to one on right
"-------------------------------------------------------------------------------
"
nmap <s-down>   <c-w>w
nmap <s-up>     <c-w>W
nmap <s-left>   <c-w>h
nmap <s-right>  <c-w>l
"
"
"-------------------------------------------------------------------------------
"  some additional hot keys
"-------------------------------------------------------------------------------
"   S-F3  -  call gvim file browser
"-------------------------------------------------------------------------------
"
 map  <silent> <s-F3>       :silent browse confirm e<CR>
imap  <silent> <s-F3>  <Esc>:silent browse confirm e<CR>
"
"
"-------------------------------------------------------------------------------
" toggle insert mode <--> 'normal mode with the <RightMouse>-key
"-------------------------------------------------------------------------------
"
nmap	<RightMouse> <Insert>
imap	<RightMouse> <ESC>
"
