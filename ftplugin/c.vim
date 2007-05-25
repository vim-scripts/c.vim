" Vim filetype plugin file
"
"   Language :  C / C++
"     Plugin :  c.vim (version 4.6)
" Maintainer :  Fritz Mehner <mehner@fh-swf.de>
"   Revision :  $Id: c.vim,v 1.13 2007/05/24 18:14:18 mehner Exp $
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
" ---------- Commands -------------------------------------------
"
command! -nargs=1 	CSetBraceOnNewLine 	call C_SetBraceOnNewLine (<f-args>)
command! -nargs=1 	CSetCComments      	call C_SetCComments      (<f-args>)
command! -nargs=1 	CSetCCommentsToggle	call C_SetCCommentsToggle(<f-args>)
command! -nargs=? 	CSetClassName      	call C_SetClassName      (<f-args>)
"
" ---------- F-key mappings  ------------------------------------
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
"
" ---------- KEY MAPPINGS : MENU ENTRIES -------------------------------------
"
" ---------- comments menu  ------------------------------------------------
"
 noremap    <buffer>  <silent>  <Leader>cj    <Esc>:call C_AdjustLineEndComm("a")<CR>
vnoremap    <buffer>  <silent>  <Leader>cj    <Esc>:call C_AdjustLineEndComm("v")<CR>

 noremap    <buffer>  <silent>  <Leader>cl    <Esc>:call C_LineEndComment()<CR>a
vnoremap    <buffer>  <silent>  <Leader>cl    <Esc>:call C_MultiLineEndComments()<CR>a
 noremap    <buffer>  <silent>  <Leader>cn    <Esc>:call C_LineEndComment("// ")<CR>A
vnoremap    <buffer>  <silent>  <Leader>cn    <Esc>:call C_MultiLineEndComments("// ")<CR>A
 noremap    <buffer>  <silent>  <Leader>cs    <Esc>:call C_GetLineEndCommCol()<CR>
 noremap    <buffer>  <silent>  <Leader>ci    <Esc>o/*<CR>/<Esc>kA<Space>
vnoremap    <buffer>  <silent>  <Leader>ci    <Esc>:call C_CodeComment("v","yes")<CR><Esc>:nohlsearch<CR>
 noremap    <buffer>  <silent>  <Leader>c*    <Esc>:call C_CodeComment("a","yes")<CR><Esc>:nohlsearch<CR>j
vnoremap    <buffer>  <silent>  <Leader>c*    <Esc>:call C_CodeComment("v","yes")<CR><Esc>:nohlsearch<CR>j
 noremap    <buffer>  <silent>  <Leader>c\    <Esc>:call C_CodeComment("a","no")<CR><Esc>:nohlsearch<CR>j
vnoremap    <buffer>  <silent>  <Leader>c\    <Esc>:call C_CodeComment("v","no")<CR><Esc>:nohlsearch<CR>j
 noremap    <buffer>  <silent>  <Leader>co    <Esc>:call C_CommentCode("a")<CR><Esc>:nohlsearch<CR>
vnoremap    <buffer>  <silent>  <Leader>co    <Esc>:call C_CommentCode("v")<CR><Esc>:nohlsearch<CR>
 noremap    <buffer>  <silent>  <Leader>cfr   <Esc>:call C_CommentTemplates("frame")<CR>
 noremap    <buffer>  <silent>  <Leader>cfu   <Esc>:call C_CommentTemplates("function")<CR>
 noremap    <buffer>  <silent>  <Leader>cme   <Esc>:call C_CommentTemplates("method")<CR>
 noremap    <buffer>  <silent>  <Leader>ccl   <Esc>:call C_CommentTemplates("class")<CR>
 noremap    <buffer>  <silent>  <Leader>cd    a<C-R>=strftime("%x")<CR>
 noremap    <buffer>  <silent>  <Leader>ct    a<C-R>=strftime("%x %X %Z")<CR>
 noremap    <buffer>  <silent>  <Leader>cy    <Esc>:call C_Toggle_C_Cpp()<CR>

inoremap    <buffer>  <silent>  <Leader>cl    <Esc>:call C_LineEndComment()<CR>a
inoremap    <buffer>  <silent>  <Leader>cj    <Esc>:call C_AdjustLineEndComm("a")<CR>a
inoremap    <buffer>  <silent>  <Leader>cfr   <Esc>:call C_CommentTemplates("frame")<CR>
inoremap    <buffer>  <silent>  <Leader>cfu   <Esc>:call C_CommentTemplates("function")<CR>
inoremap    <buffer>  <silent>  <Leader>cme   <Esc>:call C_CommentTemplates("method")<CR>
inoremap    <buffer>  <silent>  <Leader>ccl   <Esc>:call C_CommentTemplates("class")<CR>
inoremap    <buffer>  <silent>  <Leader>cd    <C-R>=strftime("%x")<CR>
inoremap    <buffer>  <silent>  <Leader>ct    <C-R>=strftime("%x %X %Z")<CR>
"
" ---------- statements menu  ------------------------------------------------
"
 noremap    <buffer>  <silent>  <Leader>sd    <Esc>:call C_DoWhile("a")<CR><Esc>f(la
vnoremap    <buffer>  <silent>  <Leader>sd    <Esc>:call C_DoWhile("v")<CR><Esc>f(la
inoremap    <buffer>  <silent>  <Leader>sd    <Esc>:call C_DoWhile("a")<CR><Esc>f(la

 noremap    <buffer>  <silent>  <Leader>sf    <Esc>:call C_Stat("a","for ( ; ; )")<Esc>f;i
vnoremap    <buffer>  <silent>  <Leader>sf    <Esc>:call C_Stat("v","for ( ; ; )")<Esc>f;i
inoremap    <buffer>  <silent>  <Leader>sf    <Esc>:call C_Stat("a","for ( ; ; )")<Esc>f;i

 noremap    <buffer>  <silent>  <Leader>sfo   <Esc>:call C_StatBlock("a","for ( ; ; )")<Esc>f;i
vnoremap    <buffer>  <silent>  <Leader>sfo   <Esc>:call C_StatBlock("v","for ( ; ; )")<Esc>f;i
inoremap    <buffer>  <silent>  <Leader>sfo   <Esc>:call C_StatBlock("a","for ( ; ; )")<Esc>f;i

 noremap    <buffer>  <silent>  <Leader>si    <Esc>:call C_Stat("a","if (  )")<Esc>f(la
vnoremap    <buffer>  <silent>  <Leader>si    <Esc>:call C_Stat("v","if (  )")<Esc>f(la
inoremap    <buffer>  <silent>  <Leader>si    <Esc>:call C_Stat("a","if (  )")<Esc>f(la

 noremap    <buffer>  <silent>  <Leader>sif   <Esc>:call C_StatBlock("a","if (  )")<Esc>f(la
vnoremap    <buffer>  <silent>  <Leader>sif   <Esc>:call C_StatBlock("v","if (  )")<Esc>f(la
inoremap    <buffer>  <silent>  <Leader>sif   <Esc>:call C_StatBlock("a","if (  )")<Esc>f(la

 noremap    <buffer>  <silent>  <Leader>sie   <Esc>:call C_IfElse("a")<Esc>f(la
vnoremap    <buffer>  <silent>  <Leader>sie   <Esc>:call C_IfElse("v")<Esc>f(la
inoremap    <buffer>  <silent>  <Leader>sie   <Esc>:call C_IfElse("a")<Esc>f(la

 noremap    <buffer>  <silent>  <Leader>sife  <Esc>:call C_IfBlockElse("a")<Esc>f(la
vnoremap    <buffer>  <silent>  <Leader>sife  <Esc>:call C_IfBlockElse("v")<Esc>f(la
inoremap    <buffer>  <silent>  <Leader>sife  <Esc>:call C_IfBlockElse("a")<Esc>f(la

 noremap    <buffer>  <silent>  <Leader>sw    <Esc>:call C_Stat("a","while (  )")<Esc>f(la
vnoremap    <buffer>  <silent>  <Leader>sw    <Esc>:call C_Stat("v","while (  )")<Esc>f(la
inoremap    <buffer>  <silent>  <Leader>sw    <Esc>:call C_Stat("a","while (  )")<Esc>f(la

 noremap    <buffer>  <silent>  <Leader>swh   <Esc>:call C_StatBlock("a","while (  )")<Esc>f(la
vnoremap    <buffer>  <silent>  <Leader>swh   <Esc>:call C_StatBlock("v","while (  )")<Esc>f(la
inoremap    <buffer>  <silent>  <Leader>swh   <Esc>:call C_StatBlock("a","while (  )")<Esc>f(la

 noremap    <buffer>  <silent>  <Leader>ss    <Esc>:call C_CodeSwitch()<Esc>f(la
vnoremap    <buffer>  <silent>  <Leader>ss    <Esc>:call C_CodeSwitchVisual()<Esc>f(la
inoremap    <buffer>  <silent>  <Leader>ss    <Esc>:call C_CodeSwitch()<Esc>f(la

 noremap    <buffer>  <silent>  <Leader>sc    <Esc>ocase 0:<Tab><CR>break;<CR><Esc>2kf0s
vnoremap    <buffer>  <silent>  <Leader>sc    <Esc>:call C_CodeCaseVisual()<Esc>
inoremap    <buffer>  <silent>  <Leader>sc    <Esc>ocase 0:<Tab><CR>break;<CR><Esc>2kf0s

 noremap    <buffer>  <silent>  <Leader>s{    <Esc>:call C_Block("a")<CR>o
vnoremap    <buffer>  <silent>  <Leader>s{    <Esc>:call C_Block("v")<CR>
inoremap    <buffer>  <silent>  <Leader>s{    <Esc>:call C_Block("a")<CR>o


"
" ---------- preprocessor menu  ----------------------------------------------
"
inoremap    <buffer>  <silent>  <Leader>p<   <Esc><Esc>o#include<Tab><><Left>
inoremap    <buffer>  <silent>  <Leader>p"   <Esc><Esc>o#include<Tab>""<Left>
inoremap    <buffer>  <silent>  <Leader>pd   <Esc><Esc>:call C_PPDefine()<CR>f<Tab>a
inoremap    <buffer>  <silent>  <Leader>pu   <Esc><Esc>:call C_PPUndef()<CR>f<Tab>a
"
 noremap    <buffer>  <silent>  <Leader>p<   <Esc><Esc>o#include<Tab><><Left>
 noremap    <buffer>  <silent>  <Leader>p"   <Esc><Esc>o#include<Tab>""<Left>
 noremap    <buffer>  <silent>  <Leader>pd   <Esc><Esc>:call C_PPDefine()<CR>f<Tab>a
 noremap    <buffer>  <silent>  <Leader>pu   <Esc><Esc>:call C_PPUndef()<CR>f<Tab>a

 noremap    <buffer>  <silent>  <Leader>pie  <Esc><Esc>:call C_PPIfElse("if"    ,"a+")<CR>
 noremap    <buffer>  <silent>  <Leader>pid  <Esc><Esc>:call C_PPIfElse("ifdef" ,"a+")<CR>
 noremap    <buffer>  <silent>  <Leader>pin  <Esc><Esc>:call C_PPIfElse("ifndef","a+")<CR>
 noremap    <buffer>  <silent>  <Leader>pind <Esc><Esc>:call C_PPifndef (         "a" )<CR>2ji
 noremap    <buffer>  <silent>  <Leader>pi0  <Esc><Esc>:call C_PPIf0("a")<CR>2ji

vnoremap    <buffer>  <silent>  <Leader>pie  <Esc><Esc>:call C_PPIfElse("if"    ,"v+")<CR>
vnoremap    <buffer>  <silent>  <Leader>pid  <Esc><Esc>:call C_PPIfElse("ifdef" ,"v+")<CR>
vnoremap    <buffer>  <silent>  <Leader>pin  <Esc><Esc>:call C_PPIfElse("ifndef","v+")<CR>
vnoremap    <buffer>  <silent>  <Leader>pind <Esc><Esc>:call C_PPifndef (         "v" )<CR>
vnoremap    <buffer>  <silent>  <Leader>pi0  <Esc><Esc>:call C_PPIf0("v")<CR>
                                     
inoremap    <buffer>  <silent>  <Leader>pie  <Esc><Esc>:call C_PPIfElse("if"    ,"a+")<CR>A
inoremap    <buffer>  <silent>  <Leader>pid  <Esc><Esc>:call C_PPIfElse("ifdef" ,"a+")<CR>A
inoremap    <buffer>  <silent>  <Leader>pin  <Esc><Esc>:call C_PPIfElse("ifndef","a+")<CR>A
inoremap    <buffer>  <silent>  <Leader>pind <Esc><Esc>:call C_PPifndef (         "a" )<CR>2ji
inoremap    <buffer>  <silent>  <Leader>pi0  <Esc><Esc>:call C_PPIf0("a")<CR>2ji

 noremap    <buffer>  <silent>  <Leader>pr0  <Esc><Esc>:call C_PPIf0Remove()<CR>
"
" ---------- idioms menu  ----------------------------------------------------
"
 noremap    <buffer>  <silent>  <Leader>if    <Esc>:call C_CodeFunction("a")<CR>
vnoremap    <buffer>  <silent>  <Leader>if    <Esc>:call C_CodeFunction("v")<CR>
inoremap    <buffer>  <silent>  <Leader>if    <Esc>:call C_CodeFunction("a")<CR>
 noremap    <buffer>  <silent>  <Leader>isf   <Esc>:call C_CodeFunction("sa")<CR>w
vnoremap    <buffer>  <silent>  <Leader>isf   <Esc>:call C_CodeFunction("sv")<CR>w
inoremap    <buffer>  <silent>  <Leader>isf   <Esc>:call C_CodeFunction("sa")<CR>w
 noremap    <buffer>  <silent>  <Leader>im    <Esc>:call C_CodeMain("a")<CR>3jA
vnoremap    <buffer>  <silent>  <Leader>im    <Esc>:call C_CodeMain("v")<CR>
inoremap    <buffer>  <silent>  <Leader>im    <Esc>:call C_CodeMain("a")<CR>3jA
"
 noremap    <buffer>  <silent>  <Leader>i0    <Esc>:call C_CodeFor("up"  , "a")<CR>a
vnoremap    <buffer>  <silent>  <Leader>i0    <Esc>:call C_CodeFor("up"  , "v")<CR>
inoremap    <buffer>  <silent>  <Leader>i0    <Esc>:call C_CodeFor("up"  , "a")<CR>a
 noremap    <buffer>  <silent>  <Leader>in    <Esc>:call C_CodeFor("down", "a")<CR>a
vnoremap    <buffer>  <silent>  <Leader>in    <Esc>:call C_CodeFor("down", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>in    <Esc>:call C_CodeFor("down", "a")<CR>a
"
 noremap    <buffer>  <silent>  <Leader>ie    <Esc>:call C_EST("enum")<CR>o
inoremap    <buffer>  <silent>  <Leader>ie    <Esc>:call C_EST("enum")<CR>o
 noremap    <buffer>  <silent>  <Leader>is    <Esc>:call C_EST("struct")<CR>o
inoremap    <buffer>  <silent>  <Leader>is    <Esc>:call C_EST("struct")<CR>o
 noremap    <buffer>  <silent>  <Leader>iu    <Esc>:call C_EST("union")<CR>o
inoremap    <buffer>  <silent>  <Leader>iu    <Esc>:call C_EST("union")<CR>o
"
 noremap    <buffer>  <silent>  <Leader>ip    <Esc><Esc>oprintf("\n");<Esc>2F"a
inoremap    <buffer>  <silent>  <Leader>ip    printf("\n");<Esc>2F"a
 noremap    <buffer>  <silent>  <Leader>isc    <Esc><Esc>oscanf("", & );<Esc>F"i
inoremap    <buffer>  <silent>  <Leader>isc    scanf("", & );<Esc>F"i
"
 noremap    <buffer>  <silent>  <Leader>ica    <Esc>:call C_CodeMalloc("c")<CR>i
inoremap    <buffer>  <silent>  <Leader>ica    <Esc>:call C_CodeMalloc("c")<CR>i
 noremap    <buffer>  <silent>  <Leader>ima    <Esc>:call C_CodeMalloc("m")<CR>i
inoremap    <buffer>  <silent>  <Leader>ima    <Esc>:call C_CodeMalloc("m")<CR>i
"
 noremap    <buffer>  <silent>  <Leader>isi    isizeof()<Left>
vnoremap    <buffer>  <silent>  <Leader>isi    ssizeof()<Esc>P
inoremap    <buffer>  <silent>  <Leader>isi    sizeof()<Left>
 noremap    <buffer>  <silent>  <Leader>ias    <Esc><Esc>oassert();<Left><Left>
vnoremap    <buffer>  <silent>  <Leader>ias    sassert();<Esc>F(p
inoremap    <buffer>  <silent>  <Leader>ias    assert();<Left><Left>
"
 noremap    <buffer>  <silent>  <Leader>ii    <Esc>:call C_CodeFopen("input")<CR>jf"a
inoremap    <buffer>  <silent>  <Leader>ii    <Esc>:call C_CodeFopen("input")<CR>jf"a
 noremap    <buffer>  <silent>  <Leader>io    <Esc>:call C_CodeFopen("output")<CR>jf"a
inoremap    <buffer>  <silent>  <Leader>io    <Esc>:call C_CodeFopen("output")<CR>jf"a
"
" ---------- snippet menu ----------------------------------------------------
"
 noremap    <buffer>  <silent>  <Leader>nr    <Esc>:call C_CodeSnippet("r")<CR>
 noremap    <buffer>  <silent>  <Leader>nw    <Esc>:call C_CodeSnippet("w")<CR>
vnoremap    <buffer>  <silent>  <Leader>nw    <Esc>:call C_CodeSnippet("wv")<CR>
 noremap    <buffer>  <silent>  <Leader>ne    <Esc>:call C_CodeSnippet("e")<CR>
"
 noremap    <buffer>  <silent>  <Leader>np    <Esc>:call C_ProtoPick("n")<CR>
vnoremap    <buffer>  <silent>  <Leader>np    <Esc>:call C_ProtoPick("v")<CR>
 noremap    <buffer>  <silent>  <Leader>ni    <Esc>:call C_ProtoInsert()<CR>
 noremap    <buffer>  <silent>  <Leader>nc    <Esc>:call C_ProtoClear()<CR>
 noremap    <buffer>  <silent>  <Leader>ns    <Esc>:call C_ProtoShow()<CR>
"
" ---------- C++ menu ----------------------------------------------------
"
 noremap    <buffer>  <silent>  <Leader>+m    <Esc>:call C_CodeMethod()<CR>
inoremap    <buffer>  <silent>  <Leader>+m    <Esc>:call C_CodeMethod()<CR>
 noremap    <buffer>  <silent>  <Leader>+c    <Esc>:call C_CommentTemplates("CppClass")<CR>
inoremap    <buffer>  <silent>  <Leader>+c    <Esc>:call C_CommentTemplates("CppClass")<CR>
 noremap    <buffer>  <silent>  <Leader>+cn   <Esc>:call C_CommentTemplates("CppClassUsingNew")<CR>
inoremap    <buffer>  <silent>  <Leader>+cn   <Esc>:call C_CommentTemplates("CppClassUsingNew")<CR>
 noremap    <buffer>  <silent>  <Leader>+ec   <Esc>:call C_CommentTemplates("CppErrorClass")<CR>
inoremap    <buffer>  <silent>  <Leader>+ec   <Esc>:call C_CommentTemplates("CppErrorClass")<CR>
 noremap    <buffer>  <silent>  <Leader>+t    <Esc>:call C_CommentTemplates("CppTemplateClass")<CR>
inoremap    <buffer>  <silent>  <Leader>+t    <Esc>:call C_CommentTemplates("CppTemplateClass")<CR>
 noremap    <buffer>  <silent>  <Leader>+tn   <Esc>:call C_CommentTemplates("CppTemplateClassUsingNew")<CR>
inoremap    <buffer>  <silent>  <Leader>+tn   <Esc>:call C_CommentTemplates("CppTemplateClassUsingNew")<CR>
 noremap    <buffer>  <silent>  <Leader>+tf   <Esc>:call C_CodeTemplateFunct()<CR>
inoremap    <buffer>  <silent>  <Leader>+tf   <Esc>:call C_CodeTemplateFunct()<CR>

 noremap    <buffer>  <silent>  <Leader>+tr   <Esc>:call C_CodeTryCatch("a")<CR>o
vnoremap    <buffer>  <silent>  <Leader>+tr   <Esc>:call C_CodeTryCatch("v")<CR>f(fci
inoremap    <buffer>  <silent>  <Leader>+tr   <Esc>:call C_CodeTryCatch("a")<CR>o

 noremap    <buffer>  <silent>  <Leader>+ca   <Esc>:call C_CodeCatch("a"," const &ExceptObj ")<CR>f(fci
vnoremap    <buffer>  <silent>  <Leader>+ca   <Esc>:call C_CodeCatch("v"," const &ExceptObj ")<CR>f(fci
inoremap    <buffer>  <silent>  <Leader>+ca   <Esc>:call C_CodeCatch("a"," const &ExceptObj ")<CR>f(fci

 noremap    <buffer>  <silent>  <Leader>+c.   <Esc>:call C_CodeCatch("a","...")<CR>
vnoremap    <buffer>  <silent>  <Leader>+c.   <Esc>:call C_CodeCatch("v","...")<CR>
inoremap    <buffer>  <silent>  <Leader>+c.   <Esc>:call C_CodeCatch("a","...")<CR>
"
"
" ---------- run menu --------------------------------------------------------
"
 map    <buffer>  <silent>  <Leader>rc    <C-C>:call C_Compile()<CR>:redraw<CR>:call C_HlMessage()<CR>
 map    <buffer>  <silent>  <Leader>rl    <C-C>:call C_Link()<CR>:redraw<CR>:call C_HlMessage()<CR>
 map    <buffer>  <silent>  <Leader>rr    <C-C>:call C_Run()<CR>
 map    <buffer>  <silent>  <Leader>ra    <C-C>:call C_Arguments()<CR>
 map    <buffer>  <silent>  <Leader>rm    <C-C>:call C_Make()<CR>
 map    <buffer>  <silent>  <Leader>rg    <C-C>:call C_MakeArguments()<CR>
 map    <buffer>  <silent>  <Leader>rp    <C-C>:call C_SplintCheck()<CR>:redraw<CR>:call C_HlMessage()<CR>
 map    <buffer>  <silent>  <Leader>ri    <C-C>:call C_SplintArguments()<CR>
 map    <buffer>  <silent>  <Leader>rd    <C-C>:call C_Indent("a")<CR>:redraw<CR>:call C_HlMessage()<CR>
vmap    <buffer>  <silent>  <Leader>rd    <C-C>:call C_Indent("v")<CR>:redraw<CR>:call C_HlMessage()<CR>
 map    <buffer>  <silent>  <Leader>rh    <C-C>:call C_Hardcopy("n")<CR>
vmap    <buffer>  <silent>  <Leader>rh    <C-C>:call C_Hardcopy("v")<CR>
 map    <buffer>  <silent>  <Leader>rs    <C-C>:call C_Settings()<CR>
 if	has("unix")
	 map    <buffer>  <silent>  <Leader>rx    <C-C>:call C_XtermSize()<CR>
 endif
 map    <buffer>  <silent>  <Leader>ro    <C-C>:call C_Toggle_Gvim_Xterm()<CR>
"
" Abraxas CodeCheck (R)
"
if executable("check") 
	map    <buffer>  <silent>  <Leader>rk    <C-C>:call C_CodeCheck()<CR>:redraw<CR>:call C_HlMessage()<CR>
	map    <buffer>  <silent>  <Leader>re    <C-C>:call C_CodeCheckArguments()<CR>
endif
" ---------- plugin help -----------------------------------------------------
"
 map    <buffer>  <silent>  <Leader>h    <Esc>:call C_HelpCsupport()<CR>
"
