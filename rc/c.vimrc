
"-------------------------------------------------------------------------------
" c.vim
"-------------------------------------------------------------------------------

let g:C_AuthorName      = ""
let g:C_AuthorRef       = ""
let g:C_Email           = ""
let g:C_Company         = ""
let g:C_Project         = ""
let g:C_CopyrightHolder = ""

let g:C_CExtension      = "c"                    " C file extension; everything else is C++
let g:C_CCompiler       = "gcc"                  " the C   compiler
let g:C_CplusCompiler   = "g++"                  " the C++ compiler
let g:C_CFlags          = "-Wall -g -O0 -c"      " compiler flags: compile, don't optimize
let g:C_LFlags          = "-Wall -g -O0"         " compiler flags: link   , don't optimize
let g:C_Libs            = "-lm"                  " libraries to use


let g:C_Dictionary_File =                         $HOME."/.vim/wordlists/c-c++-keywords.list"
let g:C_Dictionary_File = g:C_Dictionary_File.",".$HOME."/.vim/wordlists/k+r.list"
let g:C_Dictionary_File = g:C_Dictionary_File.",".$HOME."/.vim/wordlists/stl_index.list"
let g:C_Dictionary_File = g:C_Dictionary_File.",".$HOME."/.vim/wordlists/german.list"

" ----------  Insert header into new C/C++-files  ----------
if has("autocmd")
	autocmd BufNewFile  *.\(c\|cc\|cpp\|C\)  call C_CommentTemplates('cheader')
	autocmd BufNewFile  *.\(h\|hpp\)         call C_CommentTemplates('hheader')
endif " has("autocmd")

