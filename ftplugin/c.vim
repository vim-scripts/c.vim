" Vim filetype plugin file
"
"   Language :  C / C++
"     Plugin :  c.vim (version 5.0)
" Maintainer :  Fritz Mehner <mehner@fh-swf.de>
"   Revision :  $Id: c.vim,v 1.17 2007/11/15 20:10:30 mehner Exp $
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
"if exists("loaded_alternateFile")
" map  <buffer>  <silent>  <S-F2>       <C-C>:A<CR>
"imap  <buffer>  <silent>  <S-F2>  <C-C><C-C>:A<CR>
"endif
"
"
" ---------- KEY MAPPINGS : MENU ENTRIES -------------------------------------
"
" ---------- comments menu  ------------------------------------------------
"

 noremap    <buffer>  <silent>  <Leader>cl    <Esc>:call C_LineEndComment()<CR>
inoremap    <buffer>  <silent>  <Leader>cl    <Esc>:call C_LineEndComment()<CR>a
vnoremap    <buffer>  <silent>  <Leader>cl    <Esc>:call C_MultiLineEndComments()<CR>
 noremap    <buffer>  <silent>  <Leader>cj    <Esc>:call C_AdjustLineEndComm("a")<CR>
vnoremap    <buffer>  <silent>  <Leader>cj    <Esc>:call C_AdjustLineEndComm("v")<CR>
inoremap    <buffer>  <silent>  <Leader>cj    <Esc>:call C_AdjustLineEndComm("a")<CR>a
 noremap    <buffer>  <silent>  <Leader>cs    <Esc>:call C_GetLineEndCommCol()<CR>
 noremap    <buffer>  <silent>  <Leader>c*    <Esc>:call C_CodeComment("a","yes")<CR><Esc>:nohlsearch<CR>j
vnoremap    <buffer>  <silent>  <Leader>c*    <Esc>:call C_CodeComment("v","yes")<CR><Esc>:nohlsearch<CR>j
 noremap    <buffer>  <silent>  <Leader>c/    <Esc>:call C_CodeComment("a","no")<CR><Esc>:nohlsearch<CR>j
vnoremap    <buffer>  <silent>  <Leader>c/    <Esc>:call C_CodeComment("v","no")<CR><Esc>:nohlsearch<CR>j
 noremap    <buffer>  <silent>  <Leader>co    <Esc>:call C_CommentCode("a")<CR><Esc>:nohlsearch<CR>
vnoremap    <buffer>  <silent>  <Leader>co    <Esc>:call C_CommentCode("v")<CR><Esc>:nohlsearch<CR>

 noremap    <buffer>  <silent>  <Leader>cfr   <Esc>:call C_InsertTemplate("comment.frame")<CR>
 noremap    <buffer>  <silent>  <Leader>cfu   <Esc>:call C_InsertTemplate("comment.function")<CR>
 noremap    <buffer>  <silent>  <Leader>cme   <Esc>:call C_InsertTemplate("comment.method")<CR>
 noremap    <buffer>  <silent>  <Leader>ccl   <Esc>:call C_InsertTemplate("comment.class")<CR>

inoremap    <buffer>  <silent>  <Leader>cfr   <Esc>:call C_InsertTemplate("comment.frame")<CR>
inoremap    <buffer>  <silent>  <Leader>cfu   <Esc>:call C_InsertTemplate("comment.function")<CR>
inoremap    <buffer>  <silent>  <Leader>cme   <Esc>:call C_InsertTemplate("comment.method")<CR>
inoremap    <buffer>  <silent>  <Leader>ccl   <Esc>:call C_InsertTemplate("comment.class")<CR>

 noremap    <buffer>  <silent>  <Leader>cd    a<C-R>=C_InsertDate()<CR>
inoremap    <buffer>  <silent>  <Leader>cd     <C-R>=C_InsertDate()<CR>
 noremap    <buffer>  <silent>  <Leader>ct    a<C-R>=C_InsertDateTime()<CR>
inoremap    <buffer>  <silent>  <Leader>ct     <C-R>=C_InsertDateTime()<CR>
"
" ---------- statements menu  ------------------------------------------------
"
 noremap    <buffer>  <silent>  <Leader>sd    <Esc>:call C_InsertTemplate("statements.do-while")<CR>
vnoremap    <buffer>  <silent>  <Leader>sd    <Esc>:call C_InsertTemplate("statements.do-while", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>sd    <Esc>:call C_InsertTemplate("statements.do-while")<CR>

 noremap    <buffer>  <silent>  <Leader>sf    <Esc>:call C_InsertTemplate("statements.for")<CR>
inoremap    <buffer>  <silent>  <Leader>sf    <Esc>:call C_InsertTemplate("statements.for")<CR>

 noremap    <buffer>  <silent>  <Leader>sfo   <Esc>:call C_InsertTemplate("statements.for-block")<CR>
vnoremap    <buffer>  <silent>  <Leader>sfo   <Esc>:call C_InsertTemplate("statements.for-block", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>sfo   <Esc>:call C_InsertTemplate("statements.for-block")<CR>

 noremap    <buffer>  <silent>  <Leader>si    <Esc>:call C_InsertTemplate("statements.if")<CR>
inoremap    <buffer>  <silent>  <Leader>si    <Esc>:call C_InsertTemplate("statements.if")<CR>

 noremap    <buffer>  <silent>  <Leader>sif   <Esc>:call C_InsertTemplate("statements.if-block")<CR>
vnoremap    <buffer>  <silent>  <Leader>sif   <Esc>:call C_InsertTemplate("statements.if-block", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>sif   <Esc>:call C_InsertTemplate("statements.if-block")<CR>

 noremap    <buffer>  <silent>  <Leader>sie   <Esc>:call C_InsertTemplate("statements.if-else")<CR>
vnoremap    <buffer>  <silent>  <Leader>sie   <Esc>:call C_InsertTemplate("statements.if-else", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>sie   <Esc>:call C_InsertTemplate("statements.if-else")<CR>

 noremap    <buffer>  <silent>  <Leader>sife  <Esc>:call C_InsertTemplate("statements.if-block-else")<CR>
vnoremap    <buffer>  <silent>  <Leader>sife  <Esc>:call C_InsertTemplate("statements.if-block-else", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>sife  <Esc>:call C_InsertTemplate("statements.if-block-else")<CR>

 noremap    <buffer>  <silent>  <Leader>sw    <Esc>:call C_InsertTemplate("statements.while")<CR>
inoremap    <buffer>  <silent>  <Leader>sw    <Esc>:call C_InsertTemplate("statements.while")<CR>

 noremap    <buffer>  <silent>  <Leader>swh   <Esc>:call C_InsertTemplate("statements.while-block")<CR>
vnoremap    <buffer>  <silent>  <Leader>swh   <Esc>:call C_InsertTemplate("statements.while-block", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>swh   <Esc>:call C_InsertTemplate("statements.while-block")<CR>

 noremap    <buffer>  <silent>  <Leader>ss    <Esc>:call C_InsertTemplate("statements.switch")<CR>
vnoremap    <buffer>  <silent>  <Leader>ss    <Esc>:call C_InsertTemplate("statements.switch", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>ss    <Esc>:call C_InsertTemplate("statements.switch")<CR>

 noremap    <buffer>  <silent>  <Leader>sc    <Esc>:call C_InsertTemplate("statements.case")<CR>
inoremap    <buffer>  <silent>  <Leader>sc    <Esc>:call C_InsertTemplate("statements.case")<CR>

 noremap    <buffer>  <silent>  <Leader>s{    <Esc>:call C_InsertTemplate("statements.block")<CR>
vnoremap    <buffer>  <silent>  <Leader>s{    <Esc>:call C_InsertTemplate("statements.block", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>s{    <Esc>:call C_InsertTemplate("statements.block")<CR>
"
" ---------- preprocessor menu  ----------------------------------------------
"
inoremap    <buffer>  <silent>  <Leader>p<   <Esc><Esc>o#include<Tab><><Left>
inoremap    <buffer>  <silent>  <Leader>p"   <Esc><Esc>o#include<Tab>""<Left>
inoremap    <buffer>  <silent>  <Leader>pd   <Esc><Esc>:call C_InsertTemplate("preprocessor.define")<CR>
inoremap    <buffer>  <silent>  <Leader>pu   <Esc><Esc>:call C_InsertTemplate("preprocessor.undefine")<CR>
"
 noremap    <buffer>  <silent>  <Leader>p<   <Esc><Esc>o#include<Tab><><Left>
 noremap    <buffer>  <silent>  <Leader>p"   <Esc><Esc>o#include<Tab>""<Left>
 noremap    <buffer>  <silent>  <Leader>pd   <Esc><Esc>:call C_InsertTemplate("preprocessor.define")<CR>
 noremap    <buffer>  <silent>  <Leader>pu   <Esc><Esc>:call C_InsertTemplate("preprocessor.undefine")<CR>

 noremap    <buffer>  <silent>  <Leader>pie  <Esc><Esc>:call C_InsertTemplate("preprocessor.if-else-endif")<CR>
 noremap    <buffer>  <silent>  <Leader>pid  <Esc><Esc>:call C_InsertTemplate("preprocessor.ifdef-else-endif")<CR>
 noremap    <buffer>  <silent>  <Leader>pin  <Esc><Esc>:call C_InsertTemplate("preprocessor.ifndef-else-endif")<CR>
 noremap    <buffer>  <silent>  <Leader>pind <Esc><Esc>:call C_InsertTemplate("preprocessor.ifndef-def-endif")<CR>
 noremap    <buffer>  <silent>  <Leader>pi0  <Esc><Esc>:call C_PPIf0("a")<CR>2ji

vnoremap    <buffer>  <silent>  <Leader>pie  <Esc><Esc>:call C_InsertTemplate("preprocessor.if-else-endif", "v")<CR>
vnoremap    <buffer>  <silent>  <Leader>pid  <Esc><Esc>:call C_InsertTemplate("preprocessor.ifdef-else-endif", "v")<CR>
vnoremap    <buffer>  <silent>  <Leader>pin  <Esc><Esc>:call C_InsertTemplate("preprocessor.ifndef-else-endif", "v")<CR>
vnoremap    <buffer>  <silent>  <Leader>pind <Esc><Esc>:call C_InsertTemplate("preprocessor.ifndef-def-endif", "v")<CR>
vnoremap    <buffer>  <silent>  <Leader>pi0  <Esc><Esc>:call C_PPIf0("v")<CR>
                                     
inoremap    <buffer>  <silent>  <Leader>pie  <Esc><Esc>:call C_InsertTemplate("preprocessor.if-else-endif")<CR>
inoremap    <buffer>  <silent>  <Leader>pid  <Esc><Esc>:call C_InsertTemplate("preprocessor.ifdef-else-endif")<CR>
inoremap    <buffer>  <silent>  <Leader>pin  <Esc><Esc>:call C_InsertTemplate("preprocessor.ifndef-else-endif")<CR>
inoremap    <buffer>  <silent>  <Leader>pind <Esc><Esc>:call C_InsertTemplate("preprocessor.ifndef-def-endif")<CR>
inoremap    <buffer>  <silent>  <Leader>pi0  <Esc><Esc>:call C_PPIf0("a")<CR>2ji

 noremap    <buffer>  <silent>  <Leader>pr0  <Esc><Esc>:call C_PPIf0Remove()<CR>
"
" ---------- idioms menu  ----------------------------------------------------
"
 noremap    <buffer>  <silent>  <Leader>if    <Esc>:call C_InsertTemplate("idioms.function")<CR>
vnoremap    <buffer>  <silent>  <Leader>if    <Esc>:call C_InsertTemplate("idioms.function", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>if    <Esc>:call C_InsertTemplate("idioms.function")<CR>
 noremap    <buffer>  <silent>  <Leader>isf   <Esc>:call C_InsertTemplate("idioms.function-static")<CR>
vnoremap    <buffer>  <silent>  <Leader>isf   <Esc>:call C_InsertTemplate("idioms.function-static", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>isf   <Esc>:call C_InsertTemplate("idioms.function-static")<CR>
 noremap    <buffer>  <silent>  <Leader>im    <Esc>:call C_InsertTemplate("idioms.main")<CR>
vnoremap    <buffer>  <silent>  <Leader>im    <Esc>:call C_InsertTemplate("idioms.main", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>im    <Esc>:call C_InsertTemplate("idioms.main")<CR>
"
 noremap    <buffer>  <silent>  <Leader>i0    <Esc>:call C_CodeFor("up"  , "a")<CR>a
vnoremap    <buffer>  <silent>  <Leader>i0    <Esc>:call C_CodeFor("up"  , "v")<CR>
inoremap    <buffer>  <silent>  <Leader>i0    <Esc>:call C_CodeFor("up"  , "a")<CR>a
 noremap    <buffer>  <silent>  <Leader>in    <Esc>:call C_CodeFor("down", "a")<CR>a
vnoremap    <buffer>  <silent>  <Leader>in    <Esc>:call C_CodeFor("down", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>in    <Esc>:call C_CodeFor("down", "a")<CR>a
"
 noremap    <buffer>  <silent>  <Leader>ie    <Esc>:call C_InsertTemplate("idioms.enum")<CR>
vnoremap    <buffer>  <silent>  <Leader>ie    <Esc>:call C_InsertTemplate("idioms.enum"  , "v")<CR>
inoremap    <buffer>  <silent>  <Leader>ie    <Esc>:call C_InsertTemplate("idioms.enum")<CR>
 noremap    <buffer>  <silent>  <Leader>is    <Esc>:call C_InsertTemplate("idioms.struct")<CR>
vnoremap    <buffer>  <silent>  <Leader>is    <Esc>:call C_InsertTemplate("idioms.struct", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>is    <Esc>:call C_InsertTemplate("idioms.struct")<CR>
 noremap    <buffer>  <silent>  <Leader>iu    <Esc>:call C_InsertTemplate("idioms.union")<CR>
vnoremap    <buffer>  <silent>  <Leader>iu    <Esc>:call C_InsertTemplate("idioms.union" , "v")<CR>
inoremap    <buffer>  <silent>  <Leader>iu    <Esc>:call C_InsertTemplate("idioms.union")<CR>
"
 noremap    <buffer>  <silent>  <Leader>ip    <Esc><Esc>oprintf("\n");<Esc>2F"a
inoremap    <buffer>  <silent>  <Leader>ip    printf("\n");<Esc>2F"a
 noremap    <buffer>  <silent>  <Leader>isc    <Esc><Esc>oscanf("", & );<Esc>F"i
inoremap    <buffer>  <silent>  <Leader>isc    scanf("", & );<Esc>F"i
"
 noremap    <buffer>  <silent>  <Leader>ica    <Esc>:call C_InsertTemplate("idioms.calloc")
inoremap    <buffer>  <silent>  <Leader>ica    <Esc>:call C_InsertTemplate("idioms.calloc")
 noremap    <buffer>  <silent>  <Leader>ima    <Esc>:call C_InsertTemplate("idioms.malloc")<CR>
inoremap    <buffer>  <silent>  <Leader>ima    <Esc>:call C_InsertTemplate("idioms.malloc")<CR>
"
 noremap    <buffer>  <silent>  <Leader>isi    isizeof()<Left>
vnoremap    <buffer>  <silent>  <Leader>isi    ssizeof()<Esc>P
inoremap    <buffer>  <silent>  <Leader>isi    sizeof()<Left>
 noremap    <buffer>  <silent>  <Leader>ias    <Esc><Esc>oassert();<Left><Left>
vnoremap    <buffer>  <silent>  <Leader>ias    sassert();<Esc>F(p
inoremap    <buffer>  <silent>  <Leader>ias    assert();<Left><Left>
"
 noremap    <buffer>  <silent>  <Leader>ii    <Esc>:call C_InsertTemplate("idioms.open-input-file")<CR>
inoremap    <buffer>  <silent>  <Leader>ii    <Esc>:call C_InsertTemplate("idioms.open-input-file")<CR>
 noremap    <buffer>  <silent>  <Leader>io    <Esc>:call C_InsertTemplate("idioms.open-output-file")<CR>
inoremap    <buffer>  <silent>  <Leader>io    <Esc>:call C_InsertTemplate("idioms.open-output-file")<CR>
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
 noremap    <buffer>  <silent>  <Leader>+m    <Esc>:call C_InsertTemplate("cpp.method-implementation")<CR>
inoremap    <buffer>  <silent>  <Leader>+m    <Esc>:call C_InsertTemplate("cpp.method-implementation")<CR>
 noremap    <buffer>  <silent>  <Leader>+c    <Esc>:call C_InsertTemplate("cpp.class")<CR>
inoremap    <buffer>  <silent>  <Leader>+c    <Esc>:call C_InsertTemplate("cpp.class")<CR>
 noremap    <buffer>  <silent>  <Leader>+cn   <Esc>:call C_InsertTemplate("cpp.class-using-new")<CR>
inoremap    <buffer>  <silent>  <Leader>+cn   <Esc>:call C_InsertTemplate("cpp.class-using-new")<CR>

 noremap    <buffer>  <silent>  <Leader>+tm   <Esc>:call C_InsertTemplate("cpp.template-method-implementation")<CR>
inoremap    <buffer>  <silent>  <Leader>+tm   <Esc>:call C_InsertTemplate("cpp.template-method-implementation")<CR>
 noremap    <buffer>  <silent>  <Leader>+tc   <Esc>:call C_InsertTemplate("cpp.template-class")<CR>
inoremap    <buffer>  <silent>  <Leader>+tc   <Esc>:call C_InsertTemplate("cpp.template-class")<CR>
 noremap    <buffer>  <silent>  <Leader>+tcn  <Esc>:call C_InsertTemplate("cpp.template-class-using-new")<CR>
inoremap    <buffer>  <silent>  <Leader>+tcn  <Esc>:call C_InsertTemplate("cpp.template-class-using-new")<CR>

 noremap    <buffer>  <silent>  <Leader>+tf   <Esc>:call C_InsertTemplate("cpp.template-function")<CR>
inoremap    <buffer>  <silent>  <Leader>+tf   <Esc>:call C_InsertTemplate("cpp.template-function")<CR>

 noremap    <buffer>  <silent>  <Leader>+ec   <Esc>:call C_InsertTemplate("cpp.error-class")<CR>
inoremap    <buffer>  <silent>  <Leader>+ec   <Esc>:call C_InsertTemplate("cpp.error-class")<CR>

 noremap    <buffer>  <silent>  <Leader>+tr   <Esc>:call C_InsertTemplate("cpp.try-catch")<CR>
vnoremap    <buffer>  <silent>  <Leader>+tr   <Esc>:call C_InsertTemplate("cpp.try-catch", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>+tr   <Esc>:call C_InsertTemplate("cpp.try-catch")<CR>

 noremap    <buffer>  <silent>  <Leader>+ca   <Esc>:call C_InsertTemplate("cpp.catch")<CR>
vnoremap    <buffer>  <silent>  <Leader>+ca   <Esc>:call C_InsertTemplate("cpp.catch", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>+ca   <Esc>:call C_InsertTemplate("cpp.catch")<CR>

 noremap    <buffer>  <silent>  <Leader>+c.   <Esc>:call C_InsertTemplate("cpp.catch-points")<CR>
vnoremap    <buffer>  <silent>  <Leader>+c.   <Esc>:call C_InsertTemplate("cpp.catch-points", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>+c.   <Esc>:call C_InsertTemplate("cpp.catch-points")<CR>
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
 map    <buffer>  <silent>  <Leader>rt    <C-C>:call C_RebuildTemplates()<CR>
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
