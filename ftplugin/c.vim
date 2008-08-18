" Vim filetype plugin file
"
"   Language :  C / C++
"     Plugin :  c.vim (version 5.2)
" Maintainer :  Fritz Mehner <mehner@fh-swf.de>
"   Revision :  $Id: c.vim,v 1.27 2008/08/07 14:57:48 mehner Exp $
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
 map  <buffer>  <silent>  <A-F9>       :call C_Compile()<CR>:redraw<CR>:call C_HlMessage()<CR>
imap  <buffer>  <silent>  <A-F9>  <C-C>:call C_Compile()<CR>:redraw<CR>:call C_HlMessage()<CR>
"
 map  <buffer>  <silent>    <F9>       :call C_Link()<CR>:redraw<CR>:call C_HlMessage()<CR>
imap  <buffer>  <silent>    <F9>  <C-C>:call C_Link()<CR>:redraw<CR>:call C_HlMessage()<CR>
"
" <C-C> seems to be essential here:
 map  <buffer>  <silent>  <C-F9>       :call C_Run()<CR>
imap  <buffer>  <silent>  <C-F9>  <C-C>:call C_Run()<CR>
"
 map  <buffer>  <silent>  <S-F9>       :call C_Arguments()<CR>
imap  <buffer>  <silent>  <S-F9>  <C-C>:call C_Arguments()<CR>
"
" alternate file plugin
"
" ---------- KEY MAPPINGS : MENU ENTRIES -------------------------------------
"
" ---------- comments menu  ------------------------------------------------
"
 noremap    <buffer>  <silent>  <Leader>cl         :call C_LineEndComment()<CR>
inoremap    <buffer>  <silent>  <Leader>cl    <Esc>:call C_LineEndComment()<CR>a
vnoremap    <buffer>  <silent>  <Leader>cl    <Esc>:call C_MultiLineEndComments()<CR>
 noremap    <buffer>  <silent>  <Leader>cj         :call C_AdjustLineEndComm("a")<CR>
vnoremap    <buffer>  <silent>  <Leader>cj    <Esc>:call C_AdjustLineEndComm("v")<CR>
inoremap    <buffer>  <silent>  <Leader>cj    <Esc>:call C_AdjustLineEndComm("a")<CR>a
 noremap    <buffer>  <silent>  <Leader>cs         :call C_GetLineEndCommCol()<CR>

 noremap    <buffer>  <silent>  <Leader>c*         :call C_CodeComment("a","yes")<CR>:nohlsearch<CR>j
vnoremap    <buffer>  <silent>  <Leader>c*    <Esc>:call C_CodeComment("v","yes")<CR>:nohlsearch<CR>j
 noremap    <buffer>  <silent>  <Leader>c/         :call C_CodeComment("a","no")<CR>:nohlsearch<CR>j
vnoremap    <buffer>  <silent>  <Leader>c/    <Esc>:call C_CodeComment("v","no")<CR>:nohlsearch<CR>j

 noremap    <buffer>  <silent>  <Leader>cc         :call C_CodeComment("a","no")<CR>:nohlsearch<CR>j
vnoremap    <buffer>  <silent>  <Leader>cc    <Esc>:call C_CodeComment("v","no")<CR>:nohlsearch<CR>j
 noremap    <buffer>  <silent>  <Leader>co         :call C_CommentCode("a")<CR>:nohlsearch<CR>
vnoremap    <buffer>  <silent>  <Leader>co    <Esc>:call C_CommentCode("v")<CR>:nohlsearch<CR>

 noremap    <buffer>  <silent>  <Leader>cfr        :call C_InsertTemplate("comment.frame")<CR>
 noremap    <buffer>  <silent>  <Leader>cfu        :call C_InsertTemplate("comment.function")<CR>
 noremap    <buffer>  <silent>  <Leader>cme        :call C_InsertTemplate("comment.method")<CR>
 noremap    <buffer>  <silent>  <Leader>ccl        :call C_InsertTemplate("comment.class")<CR>

inoremap    <buffer>  <silent>  <Leader>cfr   <Esc>:call C_InsertTemplate("comment.frame")<CR>
inoremap    <buffer>  <silent>  <Leader>cfu   <Esc>:call C_InsertTemplate("comment.function")<CR>
inoremap    <buffer>  <silent>  <Leader>cme   <Esc>:call C_InsertTemplate("comment.method")<CR>
inoremap    <buffer>  <silent>  <Leader>ccl   <Esc>:call C_InsertTemplate("comment.class")<CR>

 noremap    <buffer>  <silent>  <Leader>cd    a<C-R>=C_InsertDateAndTime('d')<CR>
inoremap    <buffer>  <silent>  <Leader>cd     <C-R>=C_InsertDateAndTime('d')<CR>
 noremap    <buffer>  <silent>  <Leader>ct    a<C-R>=C_InsertDateAndTime('dt')<CR>
inoremap    <buffer>  <silent>  <Leader>ct     <C-R>=C_InsertDateAndTime('dt')<CR>
"
" ---------- statements menu  ------------------------------------------------
"
 noremap    <buffer>  <silent>  <Leader>sd         :call C_InsertTemplate("statements.do-while")<CR>
vnoremap    <buffer>  <silent>  <Leader>sd    <Esc>:call C_InsertTemplate("statements.do-while", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>sd    <Esc>:call C_InsertTemplate("statements.do-while")<CR>

 noremap    <buffer>  <silent>  <Leader>sf         :call C_InsertTemplate("statements.for")<CR>
inoremap    <buffer>  <silent>  <Leader>sf    <Esc>:call C_InsertTemplate("statements.for")<CR>

 noremap    <buffer>  <silent>  <Leader>sfo        :call C_InsertTemplate("statements.for-block")<CR>
vnoremap    <buffer>  <silent>  <Leader>sfo   <Esc>:call C_InsertTemplate("statements.for-block", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>sfo   <Esc>:call C_InsertTemplate("statements.for-block")<CR>

 noremap    <buffer>  <silent>  <Leader>si         :call C_InsertTemplate("statements.if")<CR>
inoremap    <buffer>  <silent>  <Leader>si    <Esc>:call C_InsertTemplate("statements.if")<CR>

 noremap    <buffer>  <silent>  <Leader>sif        :call C_InsertTemplate("statements.if-block")<CR>
vnoremap    <buffer>  <silent>  <Leader>sif   <Esc>:call C_InsertTemplate("statements.if-block", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>sif   <Esc>:call C_InsertTemplate("statements.if-block")<CR>

 noremap    <buffer>  <silent>  <Leader>sie        :call C_InsertTemplate("statements.if-else")<CR>
vnoremap    <buffer>  <silent>  <Leader>sie   <Esc>:call C_InsertTemplate("statements.if-else", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>sie   <Esc>:call C_InsertTemplate("statements.if-else")<CR>

 noremap    <buffer>  <silent>  <Leader>sife       :call C_InsertTemplate("statements.if-block-else")<CR>
vnoremap    <buffer>  <silent>  <Leader>sife  <Esc>:call C_InsertTemplate("statements.if-block-else", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>sife  <Esc>:call C_InsertTemplate("statements.if-block-else")<CR>

 noremap    <buffer>  <silent>  <Leader>sw         :call C_InsertTemplate("statements.while")<CR>
inoremap    <buffer>  <silent>  <Leader>sw    <Esc>:call C_InsertTemplate("statements.while")<CR>

 noremap    <buffer>  <silent>  <Leader>swh        :call C_InsertTemplate("statements.while-block")<CR>
vnoremap    <buffer>  <silent>  <Leader>swh   <Esc>:call C_InsertTemplate("statements.while-block", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>swh   <Esc>:call C_InsertTemplate("statements.while-block")<CR>

 noremap    <buffer>  <silent>  <Leader>ss         :call C_InsertTemplate("statements.switch")<CR>
vnoremap    <buffer>  <silent>  <Leader>ss    <Esc>:call C_InsertTemplate("statements.switch", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>ss    <Esc>:call C_InsertTemplate("statements.switch")<CR>

 noremap    <buffer>  <silent>  <Leader>sc         :call C_InsertTemplate("statements.case")<CR>
inoremap    <buffer>  <silent>  <Leader>sc    <Esc>:call C_InsertTemplate("statements.case")<CR>

 noremap    <buffer>  <silent>  <Leader>s{         :call C_InsertTemplate("statements.block")<CR>
vnoremap    <buffer>  <silent>  <Leader>s{    <Esc>:call C_InsertTemplate("statements.block", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>s{    <Esc>:call C_InsertTemplate("statements.block")<CR>
"
" ---------- preprocessor menu  ----------------------------------------------
"
 noremap    <buffer>  <silent>  <Leader>p<        :call C_InsertTemplate("preprocessor.include-global")<CR>
 noremap    <buffer>  <silent>  <Leader>p"        :call C_InsertTemplate("preprocessor.include-local")<CR>
 noremap    <buffer>  <silent>  <Leader>pd        :call C_InsertTemplate("preprocessor.define")<CR>
 noremap    <buffer>  <silent>  <Leader>pu        :call C_InsertTemplate("preprocessor.undefine")<CR>
"
inoremap    <buffer>  <silent>  <Leader>p<   <Esc>:call C_InsertTemplate("preprocessor.include-global")<CR>
inoremap    <buffer>  <silent>  <Leader>p"   <Esc>:call C_InsertTemplate("preprocessor.include-local")<CR>
inoremap    <buffer>  <silent>  <Leader>pd   <Esc>:call C_InsertTemplate("preprocessor.define")<CR>
inoremap    <buffer>  <silent>  <Leader>pu   <Esc>:call C_InsertTemplate("preprocessor.undefine")<CR>

 noremap    <buffer>  <silent>  <Leader>pie       :call C_InsertTemplate("preprocessor.if-else-endif")<CR>
 noremap    <buffer>  <silent>  <Leader>pid       :call C_InsertTemplate("preprocessor.ifdef-else-endif")<CR>
 noremap    <buffer>  <silent>  <Leader>pin       :call C_InsertTemplate("preprocessor.ifndef-else-endif")<CR>
 noremap    <buffer>  <silent>  <Leader>pind      :call C_InsertTemplate("preprocessor.ifndef-def-endif")<CR>

vnoremap    <buffer>  <silent>  <Leader>pie  <Esc>:call C_InsertTemplate("preprocessor.if-else-endif", "v")<CR>
vnoremap    <buffer>  <silent>  <Leader>pid  <Esc>:call C_InsertTemplate("preprocessor.ifdef-else-endif", "v")<CR>
vnoremap    <buffer>  <silent>  <Leader>pin  <Esc>:call C_InsertTemplate("preprocessor.ifndef-else-endif", "v")<CR>
vnoremap    <buffer>  <silent>  <Leader>pind <Esc>:call C_InsertTemplate("preprocessor.ifndef-def-endif", "v")<CR>
                                     
inoremap    <buffer>  <silent>  <Leader>pie  <Esc>:call C_InsertTemplate("preprocessor.if-else-endif")<CR>
inoremap    <buffer>  <silent>  <Leader>pid  <Esc>:call C_InsertTemplate("preprocessor.ifdef-else-endif")<CR>
inoremap    <buffer>  <silent>  <Leader>pin  <Esc>:call C_InsertTemplate("preprocessor.ifndef-else-endif")<CR>
inoremap    <buffer>  <silent>  <Leader>pind <Esc>:call C_InsertTemplate("preprocessor.ifndef-def-endif")<CR>

 noremap    <buffer>  <silent>  <Leader>pi0       :call C_PPIf0("a")<CR>2ji
inoremap    <buffer>  <silent>  <Leader>pi0  <Esc>:call C_PPIf0("a")<CR>2ji
vnoremap    <buffer>  <silent>  <Leader>pi0  <Esc>:call C_PPIf0("v")<CR>

 noremap    <buffer>  <silent>  <Leader>pr0       :call C_PPIf0Remove()<CR>
inoremap    <buffer>  <silent>  <Leader>pr0  <Esc>:call C_PPIf0Remove()<CR>
"
 noremap    <buffer>  <silent>  <Leader>pe        :call C_InsertTemplate("preprocessor.error")<CR>
 noremap    <buffer>  <silent>  <Leader>pl        :call C_InsertTemplate("preprocessor.line")<CR>
 noremap    <buffer>  <silent>  <Leader>pp        :call C_InsertTemplate("preprocessor.pragma")<CR>
"
inoremap    <buffer>  <silent>  <Leader>pe   <Esc>:call C_InsertTemplate("preprocessor.error")<CR>
inoremap    <buffer>  <silent>  <Leader>pl   <Esc>:call C_InsertTemplate("preprocessor.line")<CR>
inoremap    <buffer>  <silent>  <Leader>pp   <Esc>:call C_InsertTemplate("preprocessor.pragma")<CR>
"
" ---------- idioms menu  ----------------------------------------------------
"
 noremap    <buffer>  <silent>  <Leader>if         :call C_InsertTemplate("idioms.function")<CR>
vnoremap    <buffer>  <silent>  <Leader>if    <Esc>:call C_InsertTemplate("idioms.function", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>if    <Esc>:call C_InsertTemplate("idioms.function")<CR>
 noremap    <buffer>  <silent>  <Leader>isf        :call C_InsertTemplate("idioms.function-static")<CR>
vnoremap    <buffer>  <silent>  <Leader>isf   <Esc>:call C_InsertTemplate("idioms.function-static", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>isf   <Esc>:call C_InsertTemplate("idioms.function-static")<CR>
 noremap    <buffer>  <silent>  <Leader>im         :call C_InsertTemplate("idioms.main")<CR>
vnoremap    <buffer>  <silent>  <Leader>im    <Esc>:call C_InsertTemplate("idioms.main", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>im    <Esc>:call C_InsertTemplate("idioms.main")<CR>
"
 noremap    <buffer>  <silent>  <Leader>i0         :call C_CodeFor("up"  , "a")<CR>a
vnoremap    <buffer>  <silent>  <Leader>i0    <Esc>:call C_CodeFor("up"  , "v")<CR>
inoremap    <buffer>  <silent>  <Leader>i0    <Esc>:call C_CodeFor("up"  , "a")<CR>a
 noremap    <buffer>  <silent>  <Leader>in         :call C_CodeFor("down", "a")<CR>a
vnoremap    <buffer>  <silent>  <Leader>in    <Esc>:call C_CodeFor("down", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>in    <Esc>:call C_CodeFor("down", "a")<CR>a
"
 noremap    <buffer>  <silent>  <Leader>ie         :call C_InsertTemplate("idioms.enum")<CR>
vnoremap    <buffer>  <silent>  <Leader>ie    <Esc>:call C_InsertTemplate("idioms.enum"  , "v")<CR>
inoremap    <buffer>  <silent>  <Leader>ie    <Esc>:call C_InsertTemplate("idioms.enum")<CR>
 noremap    <buffer>  <silent>  <Leader>is         :call C_InsertTemplate("idioms.struct")<CR>
vnoremap    <buffer>  <silent>  <Leader>is    <Esc>:call C_InsertTemplate("idioms.struct", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>is    <Esc>:call C_InsertTemplate("idioms.struct")<CR>
 noremap    <buffer>  <silent>  <Leader>iu         :call C_InsertTemplate("idioms.union")<CR>
vnoremap    <buffer>  <silent>  <Leader>iu    <Esc>:call C_InsertTemplate("idioms.union" , "v")<CR>
inoremap    <buffer>  <silent>  <Leader>iu    <Esc>:call C_InsertTemplate("idioms.union")<CR>
"
 noremap    <buffer>  <silent>  <Leader>ip         :call C_InsertTemplate("idioms.printf")<CR>
inoremap    <buffer>  <silent>  <Leader>ip    <Esc>:call C_InsertTemplate("idioms.printf")<CR>
 noremap    <buffer>  <silent>  <Leader>isc        :call C_InsertTemplate("idioms.scanf")<CR>
inoremap    <buffer>  <silent>  <Leader>isc   <Esc>:call C_InsertTemplate("idioms.scanf")<CR>
"
 noremap    <buffer>  <silent>  <Leader>ica        :call C_InsertTemplate("idioms.calloc")
inoremap    <buffer>  <silent>  <Leader>ica   <Esc>:call C_InsertTemplate("idioms.calloc")
 noremap    <buffer>  <silent>  <Leader>ima        :call C_InsertTemplate("idioms.malloc")<CR>
inoremap    <buffer>  <silent>  <Leader>ima   <Esc>:call C_InsertTemplate("idioms.malloc")<CR>
"
 noremap    <buffer>  <silent>  <Leader>isi        :call C_InsertTemplate("idioms.sizeof")<CR>
inoremap    <buffer>  <silent>  <Leader>isi   <Esc>:call C_InsertTemplate("idioms.sizeof")<CR>
vnoremap    <buffer>  <silent>  <Leader>isi   <Esc>:call C_InsertTemplate("idioms.sizeof", "v")<CR>

 noremap    <buffer>  <silent>  <Leader>ias        :call C_InsertTemplate("idioms.assert")<CR>
vnoremap    <buffer>  <silent>  <Leader>ias   <Esc>:call C_InsertTemplate("idioms.assert", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>ias   <Esc>:call C_InsertTemplate("idioms.assert")<CR>
"
 noremap    <buffer>  <silent>  <Leader>ii         :call C_InsertTemplate("idioms.open-input-file")<CR>
inoremap    <buffer>  <silent>  <Leader>ii    <Esc>:call C_InsertTemplate("idioms.open-input-file")<CR>
vnoremap    <buffer>  <silent>  <Leader>ii    <Esc>:call C_InsertTemplate("idioms.open-input-file", "v")<CR>
 noremap    <buffer>  <silent>  <Leader>io         :call C_InsertTemplate("idioms.open-output-file")<CR>
inoremap    <buffer>  <silent>  <Leader>io    <Esc>:call C_InsertTemplate("idioms.open-output-file")<CR>
vnoremap    <buffer>  <silent>  <Leader>io    <Esc>:call C_InsertTemplate("idioms.open-output-file", "v")<CR>
"
" ---------- snippet menu ----------------------------------------------------
"
 noremap    <buffer>  <silent>  <Leader>nr         :call C_CodeSnippet("r")<CR>
 noremap    <buffer>  <silent>  <Leader>nw         :call C_CodeSnippet("w")<CR>
vnoremap    <buffer>  <silent>  <Leader>nw    <Esc>:call C_CodeSnippet("wv")<CR>
 noremap    <buffer>  <silent>  <Leader>ne         :call C_CodeSnippet("e")<CR>
"
 noremap    <buffer>  <silent>  <Leader>np         :call C_ProtoPick("n")<CR>
vnoremap    <buffer>  <silent>  <Leader>np    <Esc>:call C_ProtoPick("v")<CR>
 noremap    <buffer>  <silent>  <Leader>ni         :call C_ProtoInsert()<CR>
 noremap    <buffer>  <silent>  <Leader>nc         :call C_ProtoClear()<CR>
 noremap    <buffer>  <silent>  <Leader>ns         :call C_ProtoShow()<CR>
"
 noremap    <buffer>  <silent>  <Leader>ntl        :call C_EditTemplates("local")<CR>
 noremap    <buffer>  <silent>  <Leader>ntg        :call C_EditTemplates("global")<CR>
 noremap    <buffer>  <silent>  <Leader>ntr        :call C_RebuildTemplates()<CR>
"
" ---------- C++ menu ----------------------------------------------------
"
 noremap    <buffer>  <silent>  <Leader>+c         :call C_InsertTemplate("cpp.class-definition")<CR>
inoremap    <buffer>  <silent>  <Leader>+c    <Esc>:call C_InsertTemplate("cpp.class-definition")<CR>
 noremap    <buffer>  <silent>  <Leader>+cn        :call C_InsertTemplate("cpp.class-using-new-definition")<CR>
inoremap    <buffer>  <silent>  <Leader>+cn   <Esc>:call C_InsertTemplate("cpp.class-using-new-definition")<CR>

 noremap    <buffer>  <silent>  <Leader>+ci        :call C_InsertTemplate("cpp.class-implementation")<CR>
inoremap    <buffer>  <silent>  <Leader>+ci   <Esc>:call C_InsertTemplate("cpp.class-implementation")<CR>
 noremap    <buffer>  <silent>  <Leader>+cni       :call C_InsertTemplate("cpp.class-using-new-implementation")<CR>
inoremap    <buffer>  <silent>  <Leader>+cni  <Esc>:call C_InsertTemplate("cpp.class-using-new-implementation")<CR>

 noremap    <buffer>  <silent>  <Leader>+mi        :call C_InsertTemplate("cpp.method-implementation")<CR>
inoremap    <buffer>  <silent>  <Leader>+mi   <Esc>:call C_InsertTemplate("cpp.method-implementation")<CR>
 noremap    <buffer>  <silent>  <Leader>+ai        :call C_InsertTemplate("cpp.accessor-implementation")<CR>
inoremap    <buffer>  <silent>  <Leader>+ai   <Esc>:call C_InsertTemplate("cpp.accessor-implementation")<CR>

 noremap    <buffer>  <silent>  <Leader>+tc        :call C_InsertTemplate("cpp.template-class-definition")<CR>
inoremap    <buffer>  <silent>  <Leader>+tc   <Esc>:call C_InsertTemplate("cpp.template-class-definition")<CR>
 noremap    <buffer>  <silent>  <Leader>+tcn       :call C_InsertTemplate("cpp.template-class-using-new-definition")<CR>
inoremap    <buffer>  <silent>  <Leader>+tcn  <Esc>:call C_InsertTemplate("cpp.template-class-using-new-definition")<CR>

 noremap    <buffer>  <silent>  <Leader>+tci       :call C_InsertTemplate("cpp.template-class-implementation")<CR>
inoremap    <buffer>  <silent>  <Leader>+tci  <Esc>:call C_InsertTemplate("cpp.template-class-implementation")<CR>
 noremap    <buffer>  <silent>  <Leader>+tcni      :call C_InsertTemplate("cpp.template-class-using-new-implementation")<CR>
inoremap    <buffer>  <silent>  <Leader>+tcni <Esc>:call C_InsertTemplate("cpp.template-class-using-new-implementation")<CR>

 noremap    <buffer>  <silent>  <Leader>+tmi       :call C_InsertTemplate("cpp.template-method-implementation")<CR>
inoremap    <buffer>  <silent>  <Leader>+tmi  <Esc>:call C_InsertTemplate("cpp.template-method-implementation")<CR>
 noremap    <buffer>  <silent>  <Leader>+tai       :call C_InsertTemplate("cpp.template-accessor-implementation")<CR>
inoremap    <buffer>  <silent>  <Leader>+tai  <Esc>:call C_InsertTemplate("cpp.template-accessor-implementation")<CR>

 noremap    <buffer>  <silent>  <Leader>+tf        :call C_InsertTemplate("cpp.template-function")<CR>
inoremap    <buffer>  <silent>  <Leader>+tf   <Esc>:call C_InsertTemplate("cpp.template-function")<CR>

 noremap    <buffer>  <silent>  <Leader>+ec        :call C_InsertTemplate("cpp.error-class")<CR>
inoremap    <buffer>  <silent>  <Leader>+ec   <Esc>:call C_InsertTemplate("cpp.error-class")<CR>

 noremap    <buffer>  <silent>  <Leader>+tr        :call C_InsertTemplate("cpp.try-catch")<CR>
vnoremap    <buffer>  <silent>  <Leader>+tr   <Esc>:call C_InsertTemplate("cpp.try-catch", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>+tr   <Esc>:call C_InsertTemplate("cpp.try-catch")<CR>

 noremap    <buffer>  <silent>  <Leader>+ca        :call C_InsertTemplate("cpp.catch")<CR>
vnoremap    <buffer>  <silent>  <Leader>+ca   <Esc>:call C_InsertTemplate("cpp.catch", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>+ca   <Esc>:call C_InsertTemplate("cpp.catch")<CR>

 noremap    <buffer>  <silent>  <Leader>+c.        :call C_InsertTemplate("cpp.catch-points")<CR>
vnoremap    <buffer>  <silent>  <Leader>+c.   <Esc>:call C_InsertTemplate("cpp.catch-points", "v")<CR>
inoremap    <buffer>  <silent>  <Leader>+c.   <Esc>:call C_InsertTemplate("cpp.catch-points")<CR>
"
" ---------- run menu --------------------------------------------------------
"
 map    <buffer>  <silent>  <Leader>rc         :call C_Compile()<CR>:redraw<CR>:call C_HlMessage()<CR>
 map    <buffer>  <silent>  <Leader>rl         :call C_Link()<CR>:redraw<CR>:call C_HlMessage()<CR>
 map    <buffer>  <silent>  <Leader>rr         :call C_Run()<CR>
 map    <buffer>  <silent>  <Leader>ra         :call C_Arguments()<CR>
 map    <buffer>  <silent>  <Leader>rm         :call C_Make()<CR>
 map    <buffer>  <silent>  <Leader>rg         :call C_MakeArguments()<CR>
 map    <buffer>  <silent>  <Leader>rp         :call C_SplintCheck()<CR>:redraw<CR>:call C_HlMessage()<CR>
 map    <buffer>  <silent>  <Leader>ri         :call C_SplintArguments()<CR>
 map    <buffer>  <silent>  <Leader>rd         :call C_Indent("a")<CR>:redraw<CR>:call C_HlMessage()<CR>
 map    <buffer>  <silent>  <Leader>rh         :call C_Hardcopy("n")<CR>
 map    <buffer>  <silent>  <Leader>rs         :call C_Settings()<CR>
"
vmap    <buffer>  <silent>  <Leader>rd    <C-C>:call C_Indent("v")<CR>:redraw<CR>:call C_HlMessage()<CR>
vmap    <buffer>  <silent>  <Leader>rh    <C-C>:call C_Hardcopy("v")<CR>
"
imap    <buffer>  <silent>  <Leader>rc    <C-C>:call C_Compile()<CR>:redraw<CR>:call C_HlMessage()<CR>
imap    <buffer>  <silent>  <Leader>rl    <C-C>:call C_Link()<CR>:redraw<CR>:call C_HlMessage()<CR>
imap    <buffer>  <silent>  <Leader>rr    <C-C>:call C_Run()<CR>
imap    <buffer>  <silent>  <Leader>ra    <C-C>:call C_Arguments()<CR>
imap    <buffer>  <silent>  <Leader>rm    <C-C>:call C_Make()<CR>
imap    <buffer>  <silent>  <Leader>rg    <C-C>:call C_MakeArguments()<CR>
imap    <buffer>  <silent>  <Leader>rp    <C-C>:call C_SplintCheck()<CR>:redraw<CR>:call C_HlMessage()<CR>
imap    <buffer>  <silent>  <Leader>ri    <C-C>:call C_SplintArguments()<CR>
imap    <buffer>  <silent>  <Leader>rd    <C-C>:call C_Indent("a")<CR>:redraw<CR>:call C_HlMessage()<CR>
imap    <buffer>  <silent>  <Leader>rh    <C-C>:call C_Hardcopy("n")<CR>
imap    <buffer>  <silent>  <Leader>rs    <C-C>:call C_Settings()<CR>
 if has("unix")
   map    <buffer>  <silent>  <Leader>rx         :call C_XtermSize()<CR>
  imap    <buffer>  <silent>  <Leader>rx    <C-C>:call C_XtermSize()<CR>
 endif
 map    <buffer>  <silent>  <Leader>ro         :call C_Toggle_Gvim_Xterm()<CR>
imap    <buffer>  <silent>  <Leader>ro    <C-C>:call C_Toggle_Gvim_Xterm()<CR>
"
" Abraxas CodeCheck (R)
"
if executable("check") 
  map    <buffer>  <silent>  <Leader>rk         :call C_CodeCheck()<CR>:redraw<CR>:call C_HlMessage()<CR>
  map    <buffer>  <silent>  <Leader>re         :call C_CodeCheckArguments()<CR>
 imap    <buffer>  <silent>  <Leader>rk    <C-C>:call C_CodeCheck()<CR>:redraw<CR>:call C_HlMessage()<CR>
 imap    <buffer>  <silent>  <Leader>re    <C-C>:call C_CodeCheckArguments()<CR>
endif
" ---------- plugin help -----------------------------------------------------
"
 map    <buffer>  <silent>  <Leader>h         :call C_HelpCsupport()<CR>
imap    <buffer>  <silent>  <Leader>h    <C-C>:call C_HelpCsupport()<CR>
"
