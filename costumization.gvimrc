"
"===============================================================================
"==========  CUSTOMIZATION (gvimrc)  ===========================================
"===============================================================================
"
set tabstop=2
set shiftwidth=2
set autowrite
"
"-------------------------------------------------------------------------------
"  some hot keys
"-------------------------------------------------------------------------------
"
"   F2 - update file without confirmation
"   F3 - file open dialog
"   F6 - list all errors           
"   F7 - display previous error
"   F8 - display next error   
"-------------------------------------------------------------------------------
"
map <F2>  :update<CR>
map <F3>  :browse confirm e<CR>
map <F6>  :copen<CR>
map <F7>  :cp<CR>
map <F8>  :cn<CR>
"
"-------------------------------------------------------------------------------
" use a font with clearly distinguishable brackets : ()[]{}
"-------------------------------------------------------------------------------
" 
"set guifont=-b&h-lucidatypewriter-medium-r-normal-*-*-140-*-*-m-*-iso10646-1
"
"-------------------------------------------------------------------------------
" toggle insert mode <--> 'normal mode with the <RightMouse>-key
"-------------------------------------------------------------------------------
"
nmap	<RightMouse> <Insert>
imap	<RightMouse> <ESC>
"
"-------------------------------------------------------------------------------
" use of dictionaries
" 
" dictionary : List of file names that are used to lookup words
"              for keyword completion commands.
"   complete : Search the files defined by the 'dictionary' option.
"-------------------------------------------------------------------------------
"
set dictionary=~/.vim/word.list
set complete+=k
"
"-------------------------------------------------------------------------------
" filename completion
" 
"   wildmenu : Command-line completion operates in an enhanced 	mode.
" wildignore : A file that matches with one of these
"              patterns is ignored when completing file or directory names.
"-------------------------------------------------------------------------------
" 
set wildmenu
set wildignore=*.bak,*.o,*.e,*~

