"###############################################################################################
"
"     Filename:  c.vim
"
"  Description:  Statements oriented editing of C/C++ programs        (VIM Version 6.0+)
"
"                - insertion of comments, statements and idioms
"                - compile/link/run support for one-file projects (without a makefile)
"
"                Code and comments should have a professional appearance and should be
"                easy to write and maintain. 
"                A consistent layout improves portability and reduces errors.
"                The standardization of comments makes it possible to automate the search
"                for information and the generation of documents from source code.
"
"       Author:  Dr.-Ing. Fritz Mehner - FH Südwestfalen, Iserlohn
"        Email:  mehner@fh-swf.de
"
"        Usage:  (1.0) Configure  c.vim  (section Configuration below).
"                (2.1) Load  c.vim  manually into VIM with the 'so' command:
"                        :so ~/<any directory>/c.vim
"                      or better
"                (2.2) Load c.vim on startup (VIM version 6.0 and higher) :
"                      move this file to the directory ~/.vim/plugin/
"                c.vim inserts an additional menu entry into the Tools-menu for
"                loading/unloading the C support.
"
"         Hint:  The register z is used in many places.
"
" Style Guides:  Some ideas are taken from the following documents (recommended!):
"                1. Recommended C Style and Coding Standards (Indian Hill Style Guide)
"                    www.doc.ic.ac.uk/lab/secondyear/cstyle/cstyle.html
"                2. Programming in C++, Ellemtel Telecommunication Systems Laboratories
"                    www.it.bton.ac.uk/burks/burks/language/cpp/cppstyle/ellhome.htm
"                3. C++ Coding Standard, Todd Hoff
"                    www.possibility.com/Cpp/CppCodingStandard.html
"
let s:CVIM_Version = "2.0"              " version number of this script; do not change
"     Revision:  13.02.2002
"      Created:  04.11.2000
"###############################################################################################
"
"               Configuration     (Use my configuration as an example)
"
"-------------------------------------------------------------------------------------
"
let s:CVIM_AuthorName      = "Dr.-Ing. Fritz Mehner"
let s:CVIM_AuthorRef       = "Mn"
"
" The following entries do not appear if the strings are empty.
"
let s:CVIM_Email           = "mehner@fh-swf.de"
let s:CVIM_Company         = "FH Südwestfalen, Iserlohn"
let s:CVIM_Project         = ""
let s:CVIM_Compiler        = "GNU C/C++"
"
" Copyright: If the code has been developed over a period of years, each year must be stated.
"            If CVIM_CopyrightYears is empty, the current year will be inserted.
"            The year(s) do not appear if CVIM_CopyrightHolder is empty.
"
let s:CVIM_CopyrightHolder = ""
let s:CVIM_CopyrightYears  = ""
"
"###############################################################################################
"
"               Global Variables : Compiler, Options, Libraries, ...
"
"-------------------------------------------------------------------------------------
"
let s:CVIM_CExtension      = "c"                    " C file extension; everything else is C++
let s:CVIM_CCompiler       = "gcc"                  " the C   compiler
let s:CVIM_CplusCompiler   = "g++"                  " the C++ compiler
let s:CVIM_CFlags          = "-Wall -g -c"          " compiler flags: compile
let s:CVIM_LFlags          = "-Wall -g"             " compiler flags: link
let s:CVIM_Libs            = "-lm"                  " libraries to use
"
let s:CVIM_Pager           = "less"                 " pager
"
let s:CVIM_CmdLineArgs     = ""                     " command line arguments for Run-run;
"                                                   " initially empty
"###############################################################################################
"
"  ... finally
"
"  Johann Wolfgang von Goethe (1749-1832), the greatest of the german men of letters,
"  about LINUX, Vim/gVim and other great tools (Ok, almost.) :
"
"  "Ein Mann, der recht zu wirken denkt,        "Who on efficient work is bent, 
"   Muß auf das beste Werkzeug halten."          Must choose the fittest instrument." 
"                                             
"  Faust, Teil 1, Vorspiel auf dem Theater      Faust, Part 1, Prologue for the Theatre 
"
"###############################################################################################
"------------------------------------------------------------------------------
"  C : CVIM_InitC
"  Initialization of C support menus 
"------------------------------------------------------------------------------
"
function! CVIM_InitC ()
"
"===============================================================================================
"----- Menu : Key Mappings ---------------------------------------------------------------------
"===============================================================================================
"  This is for convenience only. Comment out the following maps if you dislike them.
"  If enabled, there may be conflicts with predefined key bindings of your window manager.
"-------------------------------------------------------------------------------------
"  Alt-F9    write buffer and compile
"  F9        compile and link
"  Ctrl-F9   run executable
"
map  <A-F9>  :w<CR><Esc>:call CVIM_Compile()<CR><C-C>:cwin<CR>
map  <F9>    :call CVIM_Link()<CR><C-C>:cwin<CR>
map  <C-F9>  :call CVIM_Run(0)<CR><C-C>:cwin<CR>
"
"===============================================================================================
"----- Menu : C-Comments -----------------------------------------------------------------------
"===============================================================================================
"  MENU ENTRY
" -----------------
"  Line End Comment
"  Frame Comment
"  Function Description                       (grep searchable with "^//#" )
"  Main Description                           (grep searchable with "^//#" )
"  File Prologue                              (grep searchable with "^//#" )
"  Section Macros
"  Section Global Declarations
"  Section Type Definitions / Enumarations
"  Section Functions
"  Comments with keywords                     (grep searchable with "// :" )
"  comment out a highlighted block of code
"  uncomment   a highlighted block of code
"  Date+Time
"  Date
"===============================================================================================
"
	amenu  C-&Comments.&Line\ End\ Comment              <Esc><Esc>A<Tab><Tab><Tab>// 
	amenu  C-&Comments.&Frame\ Comment                  <Esc><Esc>:call CVIM_CommentFrame()       <CR>jA
	amenu  C-&Comments.F&unction\ Description           <Esc><Esc>:call CVIM_CommentFunction()    <CR>:/Name<CR>A
	amenu  C-&Comments.&Main\ Description               <Esc><Esc>:call CVIM_CommentMain()        <CR>:/Description<CR>A
	amenu  C-&Comments.File\ &Prologue                  <Esc><Esc>:call CVIM_CommentFilePrologue()<CR>:/Description<CR>A
	amenu  C-&Comments.-SEP1-                           :
		"
		"----- Submenu : C++ : file sections  -------------------------------------------------------------
		"
		amenu  C-&Comments.C-File\ &Sections.\ &Header\ File\ Includes    <Esc><Esc>:call CVIM_CommentSection("HEADER FILE INCLUDES")  <CR>2ji
		amenu  C-&Comments.C-File\ &Sections.\ &Macros                    <Esc><Esc>:call CVIM_CommentSection("MACROS")                <CR>2ji
		amenu  C-&Comments.C-File\ &Sections.\ M&acros\ with\ Arguments   <Esc><Esc>:call CVIM_CommentSection("MACROS WITH ARGUMENTS") <CR>2ji
		amenu  C-&Comments.C-File\ &Sections.\ &Type\ Definitions         <Esc><Esc>:call CVIM_CommentSection("TYPE DEFINITIONS")      <CR>2ji
		amenu  C-&Comments.C-File\ &Sections.\ &Enumerations              <Esc><Esc>:call CVIM_CommentSection("ENUMERATIONS")          <CR>2ji
		amenu  C-&Comments.C-File\ &Sections.\ E&xtern\ Data              <Esc><Esc>:call CVIM_CommentSection("EXTERN DATA")           <CR>2ji
		amenu  C-&Comments.C-File\ &Sections.\ &Non-static\ Global\ Data  <Esc><Esc>:call CVIM_CommentSection("NON-STATIC GLOBAL DATA")<CR>2ji
		amenu  C-&Comments.C-File\ &Sections.\ &Static\ Global\ Data      <Esc><Esc>:call CVIM_CommentSection("STATIC GLOBAL DATA")    <CR>2ji
		amenu  C-&Comments.C-File\ &Sections.\ &Local\ Prototypes         <Esc><Esc>:call CVIM_CommentSection("LOCAL PROTOTYPES")      <CR>2ji
		amenu  C-&Comments.C-File\ &Sections.\ &Functions                 <Esc><Esc>:call CVIM_CommentSection("FUNCTIONS")             <CR>2ji
		"
		"----- Submenu : C++ : keyword comments  ----------------------------------------------------------
		"
		amenu  C-&Comments.\/\/\ \:&KEYWORD\:.&BUG          <Esc><Esc>$<Esc>:call CVIM_CommentClassified("BUG")     <CR>kJA
		amenu  C-&Comments.\/\/\ \:&KEYWORD\:.&COMPILER     <Esc><Esc>$<Esc>:call CVIM_CommentClassified("COMPILER")<CR>kJA
		amenu  C-&Comments.\/\/\ \:&KEYWORD\:.&TODO         <Esc><Esc>$<Esc>:call CVIM_CommentClassified("TODO")    <CR>kJA
		amenu  C-&Comments.\/\/\ \:&KEYWORD\:.T&RICKY       <Esc><Esc>$<Esc>:call CVIM_CommentClassified("TRICKY")  <CR>kJA
		amenu  C-&Comments.\/\/\ \:&KEYWORD\:.&WARNING      <Esc><Esc>$<Esc>:call CVIM_CommentClassified("WARNING") <CR>kJA
		amenu  C-&Comments.\/\/\ \:&KEYWORD\:.&new\ keyword <Esc><Esc>$<Esc>:call CVIM_CommentClassified("")        <CR>kJf:a
		"
	amenu  C-&Comments.-SEP2-                           :
	vmenu  C-&Comments.&code->comment                   <Esc><Esc>:'<,'>s/^/\/\//<CR>
	vmenu  C-&Comments.c&omment->code                   <Esc><Esc>:'<,'>s/^\/\///<CR>
	amenu  C-&Comments.-SEP3-                           :
	amenu  C-&Comments.&Date                            <Esc><Esc>:let @z=strftime("%x")<CR>"zpa
	amenu  C-&Comments.Date\ &Time                      <Esc><Esc>:let @z=strftime("%x - %X")<CR>"zpa
	"                                                 
	"===============================================================================================
	"----- Menu : C-Statements ---------------------------------------------------------------------
	"===============================================================================================
	"  MENU ENTRY
	" -----------------
	"  if{}
	"  if{}else{}
	"  else{}
	"  for
	"  for{}
	"  while{}
	"  do{}while
	"  switch
	"  case
	"  #include <...>
	"  #include "..."
	"  #define
	"  #ifndef..#def..#endif
	"  #ifdef..#endif
	"===============================================================================================
	"
	imenu  C-St&atements.&if\ \{\ \}                 <Esc>:let @z="if (  )\n{\n\t\n}\n"                 <CR>"z]p<Esc>f(la
	imenu  C-St&atements.if\ \{\ \}\ &else\ \{\ \}   <Esc>:let @z="if (  )\n{\n\t\n}\nelse\n{\n\t\n}\n" <CR>"z]p<Esc>f(la
	imenu  C-St&atements.e&lse\ \{\ \}               <Esc>:let @z="else\n{\n\t\n}\n"                    <CR>"z]p<Esc>4<<2ja
	imenu  C-St&atements.&for                        <Esc>:let @z="for ( ; ;  )\n"                      <CR>"z]p<Esc>f;i
	imenu  C-St&atements.f&or\ \{\ \}                <Esc>:let @z="for ( ; ;  )\n{\n\t\n}\n"            <CR>"z]p<Esc>f;i
	imenu  C-St&atements.&while\ \{\ \}              <Esc>:let @z="while (  )\n{\n\t\n}\n"              <CR>"z]p<Esc>f(la
	imenu  C-St&atements.&do\ \{\ \}\ while          <Esc>:call CVIM_DoWhile()                          <CR>"z]p<Esc>:/while <CR>f(la
	imenu  C-St&atements.&switch                     <Esc>:call CVIM_CodeSwitch()                       <CR>"z]p<Esc>f(la
	imenu  C-St&atements.&case                       <Esc>:call CVIM_CodeCase()                         <CR>"z]p<Esc>f:i
	imenu  C-St&atements.-SEP1-                      :
	imenu  C-St&atements.#include\ &\<\.\.\.\>       <Esc>:let @z="#include\t<.h>"       <CR>"zp<Esc>F.i
	imenu  C-St&atements.#include\ \"\.\.\.\"        <Esc>:let @z="#include\t\".h\""     <CR>"zp<Esc>F.i
	imenu  C-St&atements.&#define                    <Esc>:let @z="#define\t\t\t\t// "   <CR>"zp<Esc>4F<Tab>a
	imenu  C-St&atements.#if\.\.#else\.\.#endif      <Esc>:call CVIM_PPIfElse('if')      <CR>ji
	imenu  C-St&atements.#ifdef\.\.#else\.\.#endif   <Esc>:call CVIM_PPIfElse('ifdef')   <CR>ji
	imenu  C-St&atements.#ifndef\.\.#else\.\.#endif  <Esc>:call CVIM_PPIfElse('ifndef')  <CR>ji
	imenu  C-St&atements.#ifndef\.\.#def\.\.#endif   <Esc>:call CVIM_PPIfDef()           <CR>2ji
	"
	"===============================================================================================
	"----- Menu : C-Idioms -------------------------------------------------------------------------
	"===============================================================================================
	"  MENU ENTRY
	" -----------------
	"  function
	"  main
	"  enum+typedef
	"  struct+typedef
	"  union+typedef
	"  for( i=0; i<n; i++ )
	"  for( i=n-1; i>0; i-- )
	"  p=malloc( )
	"  printf
	"  scanf
	"  #include <stdio.h>
	"  open input file
	"  open output file
	"===============================================================================================
	"
	imenu  C-&Idioms.&function                        <Esc>:call CVIM_CodeFunction()<CR>
	imenu  C-&Idioms.&main                            <Esc>:call CVIM_CodeMain()    <CR>3jA
	imenu  C-&Idioms.&enum\+typedef                   <Esc>:call CVIM_EST("enum")   <CR>2jA
	imenu  C-&Idioms.&struct\+typedef                 <Esc>:call CVIM_EST("struct") <CR>2jA
	imenu  C-&Idioms.&union\+typedef                  <Esc>:call CVIM_EST("union")  <CR>2jA
	imenu  C-&Idioms.for\(i=&0\;i<n\;i\+\+\)          for ( i=0; i<n; i++ )<Esc>0fni
	imenu  C-&Idioms.for\(i=&n-1\;i>=0\;i\-\-\)       for ( i=n-1; i>=0; i-- )<Esc>0fni
	imenu  C-&Idioms.p=m&alloc\(\ \)                  <Esc>:call CVIM_CodeMalloc()  <CR>f(la
	imenu  C-&Idioms.-SEP1-                           :
	imenu  C-&Idioms.&printf                          printf ("\n");<Esc>F"i
	imenu  C-&Idioms.s&canf                           scanf ("", & );<Esc>F"i
	imenu  C-&Idioms.&#include\ \<stdio\.h\>          <Esc>:let @z="#include\t<stdio.h>"  <CR>"zp<Esc>$a
	imenu  C-&Idioms.-SEP2-                           :
	imenu  C-&Idioms.open\ &input\ file               <Esc>:call CVIM_CodeFopenRead()  <CR>jf"a
	imenu  C-&Idioms.open\ &output\ file              <Esc>:call CVIM_CodeFopenWrite() <CR>jf"a

	"===============================================================================================
	"----- Menu : C++ ------------------------------------------------------------------------------
	"===============================================================================================
	"  MENU ENTRY
	" -----------------
	"  cout variable
	"  cout string
	"  cin
	"  cerr
	"  #include <iostream.h>
	"  class
	"  class using new
	"  template function
	"  template class
	"  friend operator <<
	"  friend operator >>
	"  try .. catch
	"  catch(   )
	"  catch(...)
	"  open input file
	"  open output file
	"  using namespace
	"  namespace
	"===============================================================================================
	"
	imenu  C&++.cout\ &variable               cout<Tab><< "\n" << ;<Esc>i
	imenu  C&++.cout\ &string                 cout<Tab><< "\n";<Esc>hi
	imenu  C&++.c&in                          cin<Tab>>> ;<Esc>i
		"
		"----- Submenu : C++ : output manipulators  -------------------------------------------------------
		"
		imenu  C&++.output\ mani&pulators.\<\<\ &endl                << endl <Esc>a
		imenu  C&++.output\ mani&pulators.\<\<\ &flush               << flush <Esc>a
		imenu  C&++.output\ mani&pulators.\<\<\ &dec                 << dec <Esc>a
		imenu  C&++.output\ mani&pulators.\<\<\ &hex                 << hex <Esc>a
		imenu  C&++.output\ mani&pulators.\<\<\ &oct                 << oct <Esc>a
		imenu  C&++.output\ mani&pulators.\<\<\ set&base\(\ \)       << setbase() <ESC>F)i
		imenu  C&++.output\ mani&pulators.\<\<\ setfi&ll\(\ \)       << setfill() <ESC>F)i
		imenu  C&++.output\ mani&pulators.\<\<\ set&iosflag\(\ \)    << setiosflag() <ESC>F)i
		imenu  C&++.output\ mani&pulators.\<\<\ &resetiosflag\(\ \)  << resetiosflag() <ESC>F)i
		imenu  C&++.output\ mani&pulators.\<\<\ set&precision\(\ \)  << setprecision() <ESC>F)i
		imenu  C&++.output\ mani&pulators.\<\<\ set&w\(\ \)          << setw() <ESC>F)i
		imenu  C&++.output\ mani&pulators.&#include\ \<iomanip\.h\>  <Esc>:let @z="#include\t<iomanip.h>" <CR>"z]p<Esc>a
		"
		"----- Submenu : C++ : ios flag bits  -------------------------------------------------------------
		"
		imenu  C&++.ios\ fla&gbits.ios::&skipws              ios::skipws<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::&left                ios::left<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::&right               ios::right<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::&internal            ios::internal<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::&boolalpha           ios::boolalpha<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::&dec                 ios::dec<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::&hex                 ios::hex<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::&oct                 ios::oct<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::s&cientific          ios::scientific<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::&fixed               ios::fixed<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::sho&wbase            ios::showbase<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::show&pos             ios::showpos<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::&uppercase           ios::uppercase<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::&adjustfield         ios::adjustfield<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::bas&efield           ios::basefield<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::floa&tfield          ios::floatfield<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::u&nitbuf             ios::unitbuf<Esc>a
		"
	imenu  C&++.c&err                         cerr<Tab><< "\n";<Esc>hi
	imenu  C&++.&#include\ \<iostream\.h\>    <Esc>:let @z="#include\t<iostream.h>" <CR>"z]p<Esc>a
	imenu  C&++.-SEP1-                        :
	imenu  C&++.&class                        <Esc>:call CVIM_CodeClass()           <CR>
	imenu  C&++.class\ using\ &new            <Esc>:call CVIM_CodeClassNew()        <CR>
	imenu  C&++.err&or\ class                 <Esc>:call CVIM_CodeErrorClass()      <CR>3jf"a
	imenu  C&++.-SEP2-                        :
	imenu  C&++.&template\ class              <Esc>:call CVIM_CodeTemplateClass()   <CR>
	imenu  C&++.template\ class\ using\ ne&w  <Esc>:call CVIM_CodeTemplateClassNew()<CR>
	imenu  C&++.template\ &function           <Esc>:call CVIM_CodeTemplateFunct()   <CR>
	imenu  C&++.-SEP3-                        :
	imenu  C&++.friend\ operator\ <<          <Esc>:call CVIM_CodeOutputOperator()  <CR>3jf.a
	imenu  C&++.friend\ operator\ >>          <Esc>:call CVIM_CodeInputOperator()   <CR>3jf.a
	imenu  C&++.-SEP4-                        :
	imenu  C&++.tr&y\ \.\.\ catch             <Esc>:call CVIM_CodeTryCatch()        <CR>4j2f a
	imenu  C&++.c&atch                        <Esc>:call CVIM_CodeCatch()           <CR>2f a
	imenu  C&++.catch\(\.\.\.\)               <Esc>:let @z="catch (...)\n{\n\t\n}"  <CR>"z]p<Esc>2ja
	imenu  C&++.-SEP5-                        :
	imenu  C&++.open\ input\ file             <Esc>:call CVIM_CodeIfstream()        <CR>f"a
	imenu  C&++.open\ output\ file            <Esc>:call CVIM_CodeOfstream()        <CR>f"a
	imenu  C&++.-SEP6-                        :
	imenu  C&++.&using\ namespace             using namespace ;<Esc>$i
	imenu  C&++.na&mespace                    <Esc>:let @z="namespace \n{\n\n}"     <CR>"z]p<Esc>A
	imenu  C&++.-SEP7-                        :
		"
		"----- Submenu : RTTI  ----------------------------------------------------------------------------
		"
		imenu  C&++.&RTTI.&typeid               typeid()<Esc>F(a
		imenu  C&++.&RTTI.&static_cast          static_cast<>()<Esc>F<a
		imenu  C&++.&RTTI.&const_cast           const_cast<>()<Esc>F<a
		imenu  C&++.&RTTI.&reinterpret_cast     reinterpret_cast<>()<Esc>F<a
		imenu  C&++.&RTTI.&dynamic_cast         dynamic_cast<>()<Esc>F<a
	imenu  C&++.e&xtern\ \"C\"\ \{\ \}        <Esc>:call CVIM_CodeExternC()         <CR>2jf.i
	"
	"===============================================================================================
	"----- Menu : run  -----------------------------------------------------------------------------
	"===============================================================================================
	"
	"  MENU ENTRY
	" -----------------
	"  save buffer to file and compile the file
	"  link the object file; compile if the object does not exist or is older then the source
	"  run the executable; compile and link if the executable does not exist
	"    or is older then the object source
	"  run with pager
	"  read command line arguments for the run command
	"
	"===============================================================================================
	"
	" compile and open the error window in case of errors
	amenu  C-&Run.save\ and\ &compile\ \ \<Alt\>\<F9\>  <C-C>:w<CR><Esc>:call CVIM_Compile()<CR><C-C>:cwin<CR>
	"
	amenu  C-&Run.&link\ \ \<F9\>                       <C-C>:call CVIM_Link()<CR><C-C>:cwin<CR>
	amenu  C-&Run.&run\ \ \<Ctrl\>\<F9\>                <C-C>:call CVIM_Run(0)<CR><C-C>:cwin<CR>
	amenu  C-&Run.run\ with\ &pager                     <C-C>:call CVIM_Run(1)<CR><C-C>:cwin<CR>
	amenu  C-&Run.command\ line\ &arguments             <C-C>:call CVIM_Arguments()<CR>
	imenu  C-&Run.-SEP1-                                :
	amenu  C-&Run.a&bout\ C/C++-Support                 <C-C>:call CVIM_Version()<CR>
	"
endfunction
"
"===============================================================================================
"----- Menu Functions --------------------------------------------------------------------------
"===============================================================================================
"
"------------------------------------------------------------------------------
"  C-Comments : frame comment
"------------------------------------------------------------------------------
function! CVIM_CommentFrame ()
  let @z=   "//----------------------------------------------------------------------\n"
  let @z=@z."//  \n"
  let @z=@z."//----------------------------------------------------------------------\n"
  put z
endfunction
"
"------------------------------------------------------------------------------
"  C-Comments : function
"------------------------------------------------------------------------------
function! CVIM_CommentFunction ()
  let @z=    "//#===  FUNCTION  ======================================================================\n"
  let @z= @z."//#\n"
  let @z= @z."//#        Name:  \n"
  let @z= @z."//#\n"
  let @z= @z."//# Description:  \n"
  let @z= @z."//#\n"
  let @z= @z."//#- PARAMETER -------------------------------------------------------------------------\n"
  let @z= @z."//#     Mode   Type             Name            Description\n"
  let @z= @z."//#-------------------------------------------------------------------------------------\n"
  let @z= @z."//#       in:  \n"
  let @z= @z."//#   in-out:  \n"
  let @z= @z."//#      out:  \n"
  let @z= @z."//#   return:  \n"
  let @z= @z."//#-------------------------------------------------------------------------------------\n"
  let @z= @z."//#   Author:  ".s:CVIM_AuthorName."\n"
  let @z= @z."//#     Date:  ".strftime("%x - %X")."\n"
  let @z= @z."//# Revision:  \n"
  let @z= @z."//#=====================================================================================\n"
  put z
endfunction
"
"------------------------------------------------------------------------------
"  C-Comments : main
"------------------------------------------------------------------------------
function! CVIM_CommentMain ()
  let @z=    "//#===  FUNCTION  MAIN =================================================================\n"
  let @z= @z."//#\n"
  let @z= @z."//# Description:  \n"
  let @z= @z."//#\n"
  let @z= @z."//#\n"
  let @z= @z."//#- PARAMETER -------------------------------------------------------------------------\n"
  let @z= @z."//#     Mode   Type            Name            Description\n"
  let @z= @z."//#-------------------------------------------------------------------------------------\n"
  let @z= @z."//#       in:  int             argc            number of command line arguments\n"
  let @z= @z."//#       in:  char*           argv[]          pointers to command line arguments\n"
  let @z= @z."//#       in:  char*           argv[0]         name of the command\n"
  let @z= @z."//#   return:  int             ---             return code\n"
  let @z= @z."//#-------------------------------------------------------------------------------------\n"
  let @z= @z."//#   Author:  ".s:CVIM_AuthorName."\n"
  let @z= @z."//#     Date:  ".strftime("%d.%m.%Y - %X")."\n"
  let @z= @z."//# Revision:  \n"
  let @z= @z."//#=====================================================================================\n"
  put z
endfunction
"
"------------------------------------------------------------------------------
"  C-Comments : file prologue
"------------------------------------------------------------------------------
function! CVIM_CommentFilePrologue ()

    let @z=      "//#====================================================================================="
    let @z= @z."\n//#"
    let @z= @z."\n//#       Filename:\t".expand("%:t")
    let @z= @z."\n//#    Description:\t"
    let @z= @z."\n//#"
    let @z= @z."\n//#          Usage:\t./".expand("%:t:r").".e "
    let @z= @z."\n//#"
    let @z= @z."\n//#        Version:\t1.0"
    let @z= @z."\n//#        Created:\t".strftime("%x")
    let @z= @z."\n//#       Revision:\t"
  if(s:CVIM_Compiler!="")
    let @z= @z."\n//#       Compiler:\t".s:CVIM_Compiler
  endif
    let @z= @z."\n//#"
    let @z= @z."\n//#         Author:\t".s:CVIM_AuthorName
  if(s:CVIM_AuthorRef!="")
    let @z= @z."  (".s:CVIM_AuthorRef.")"
  endif
  if(s:CVIM_Company!="")
    let @z= @z."\n//#        Company:\t".s:CVIM_Company
  endif
  if(s:CVIM_Email!="")
    let @z= @z."\n//#          Email:\t".s:CVIM_Email
  endif
  if(s:CVIM_CopyrightHolder!="")
    let @z= @z.  "\n//#      Copyright:\t".s:CVIM_CopyrightHolder
    if(s:CVIM_CopyrightYears=="")
      let @z= @z. " , ". strftime("%Y")
    else
      let @z= @z. " , ". s:CVIM_CopyrightYears
    endif
  endif
  if(s:CVIM_Project!="")
    let @z= @z."\n//#"
    let @z= @z."\n//#        Project:\t".s:CVIM_Project
  endif
    let @z= @z."\n//#"
    let @z= @z."\n//#=====================================================================================\n\n"

    put! z
endfunction
"
"------------------------------------------------------------------------------
"  C-Comments : classified comments
"------------------------------------------------------------------------------
function! CVIM_CommentClassified (class)
  	put = '// :'.a:class.':'.strftime(\"%x\").':'.s:CVIM_AuthorRef.': '
endfunction
"
"------------------------------------------------------------------------------
"  C-Comments : Section Comments
"------------------------------------------------------------------------------
"
function! CVIM_CommentSection (keyword)
  let @z=   "// #####   ".a:keyword."   "
	let	n = 74-strlen(a:keyword)
	while n>0
		let @z = @z."#"
		let	n = n-1
	endwhile
  let @z= @z."\n\n\n"
  put z
endfunction
"
"
"=====================================================================================
"----- Menu : Statements -----------------------------------------------------------
"=====================================================================================
"
"------------------------------------------------------------------------------
"  Statements : do-while
"------------------------------------------------------------------------------
"
function! CVIM_DoWhile ()
	let @z=    "do\n{\n\t\n}\nwhile (  );"
  let @z= @z."\t\t\t\t// -----  end do-while  -----\n"
endfunction
"
"------------------------------------------------------------------------------
"  Statements : switch
"  Statements : case
"------------------------------------------------------------------------------
"
let s:CVIM_CaseStatement = "\tcase :\t\n\t\tbreak;\n\n"
"
function! CVIM_CodeSwitch ()
  let @z= "switch (  )\n{\n\n"
	
	let loopcount=4                   " default number of cases
	while loopcount>0
    let @z= @z.s:CVIM_CaseStatement
	  let loopcount=loopcount-1
	endwhile
	
	let @z= @z."\tdefault:\t\n\t\tbreak;\n}"
  let @z= @z."\t\t\t\t// -----  end switch  -----\n"
endfunction
"
function! CVIM_CodeCase ()
    let @z= s:CVIM_CaseStatement
endfunction
"
"------------------------------------------------------------------------------
"  Statements : #if .. #else .. #endif 
"  Statements : #ifdef .. #else .. #endif 
"  Statements : #ifndef .. #else .. #endif 
"------------------------------------------------------------------------------
function! CVIM_PPIfElse (keyword)
	let defaultcond	= "CONDITION"
	let	identifier=inputdialog("(uppercase) condition for #".a:keyword, defaultcond )
	if identifier != ""
		let @z=    "#".a:keyword."  ".identifier."\n\n\n"
		let @z= @z."#else      // ----- #".a:keyword." ".identifier."  -----\n\n\n"
		let @z= @z."#endif     // ----- #".a:keyword." ".identifier."  -----\n"
		put z
	endif
endfunction
"
"------------------------------------------------------------------------------
"  Statements : #ifndef .. #define .. #endif 
"------------------------------------------------------------------------------
function! CVIM_PPIfDef ()
	" use filename without path (:t) and extension (:r) :
	let defaultcond	= toupper(expand("%:t:r"))."_INC"
	let	identifier=inputdialog("(uppercase) condition for #ifndef", defaultcond )
	if identifier != ""
		let @z=    "#ifndef  ".identifier."\n"
		let @z= @z."#define  ".identifier."\n\n\n"
		let @z= @z."#endif   // ----- #ifndef ".identifier."  -----\n"
		put z
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C-Idioms : for( i=0; i<n; i++ )
"------------------------------------------------------------------------------
function! CVIM_CodeFor (counter)
  let @z=    "for ( ".a:counter."=0; ".a:counter."<n; ".a:counter."++ )\n"
  put z
	endfunction
"
"------------------------------------------------------------------------------
"  C-Idioms : function
"------------------------------------------------------------------------------
function! CVIM_CodeFunction ()
	let	identifier=inputdialog("function name", "f" )
	if identifier != ""
		let @z=    "void\n".identifier."\t(  )\n{\n\n\n\treturn ;\n}"
		let @z= @z."\t\t\t\t// ----------  end of function ".identifier."  ----------"
		put z
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C-Idioms : main
"------------------------------------------------------------------------------
function! CVIM_CodeMain ()
  let @z=    "int\nmain ( int argc, char *argv[] )\n{\n\t\n"
"	let @z= @z."\n//\tprintf(\"\\n\\tprogram %s\\n\", argv[0] );"
"	let @z= @z."\n//\tcout << \"\\n\\tprogram \" << argv[0] << endl;"
	let @z= @z."\n\n\treturn 0;\n}"
  let @z= @z."\t\t\t\t// ----------  end of function main  ----------"
  put z
	endfunction
"
"------------------------------------------------------------------------------
"  C++ : class
"------------------------------------------------------------------------------
function! CVIM_CodeClass()
	let	classname=inputdialog("name of class", "Cls" )
	if classname != ""
		let @z=    "class ".classname
		let @z= @z."\n{\n\n\tpublic:\n\n"
		let @z= @z."\t\t// ====================  LIFECYCLE   =========================================\n\n"
		let @z= @z."\t\t".classname." ();\t// constructor\n\n"	
		let @z= @z."\t\t// Use compiler-generated copy constructor, assignement operator and destructor\n\n"	
		let @z= @z."\t\t// ====================  OPERATORS   =========================================\n\n"
		let @z= @z."\t\t// ====================  OPERATIONS  =========================================\n\n"
		let @z= @z."\t\t// ====================  ACCESS      =========================================\n\n"
		let @z= @z."\t\t// ====================  INQUIRY     =========================================\n\n"
		let @z= @z."\t\t// ====================  NESTED ERROR CLASSES  ===============================\n\n\n"
		let @z= @z."\tprotected:\n\n"
		let @z= @z."\tprivate:\n\n"
		let @z= @z."\n};\t\t\t// ----------  end of class  ".classname."  ----------\n"
		let @z= @z."\n\n".classname."::".classname." ()\n{\n}"
		let @z= @z."\t\t\t\t// ----------  end of constructor of class ".classname."  ----------\n"
		put z
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C++ : class using the new operator
"------------------------------------------------------------------------------
function! CVIM_CodeClassNew ()
	let	classname=inputdialog("name of class using new", "ClsN" )
	if classname != ""
		let	tabs = ""
		let	n = (strlen(classname)-1)/2				" number of extra tabs 
		while n>0
			let tabs = tabs."\t"
			let	n = n-1
		endwhile
		let @z=    "class ".classname
		let @z= @z."\n{\n\n\tpublic:\n\n"
		let @z= @z."\t\t// ====================  LIFECYCLE   =========================================\n\n"
		let @z= @z."\t\t".classname." ();\t\t\t\t\t\t\t".tabs."// constructor\n"	
		let @z= @z."\t\t".classname." (const ".classname." &obj);\t// copy constructor\n"	
		let @z= @z."\t\t~".classname." (); \t\t\t\t\t\t".tabs."// destructor\n\n"
		let @z= @z."\t\t// ====================  OPERATORS   =========================================\n\n"
		let @z= @z."\t\tconst ".classname."& operator = (const ".classname." &obj);"
		let @z= @z."\t\t// assignement operator\n\n"
		let @z= @z."\t\t// ====================  OPERATIONS  =========================================\n\n"
		let @z= @z."\t\t// ====================  ACCESS      =========================================\n\n"
		let @z= @z."\t\t// ====================  INQUIRY     =========================================\n\n"
		let @z= @z."\t\t// ====================  NESTED ERROR CLASSES  ===============================\n\n\n"
		let @z= @z."\tprotected:\n\n"
		let @z= @z."\tprivate:\n\n"
		let @z= @z."\n};\t\t\t// ----------  end of class  ".classname."  ----------\n"


		let @z= @z."\n\n".classname."::".classname." ()\n{\n}"
		let @z= @z."\t\t\t\t// ----------  end of constructor of class ".classname."  ----------\n"

		let @z= @z."\n\n".classname."::".classname." (const ".classname." &obj)\n{\n}"
		let @z= @z."\t\t\t\t// ----------  end of copy constructor of class ".classname."  ----------\n"
	
		let @z= @z."\n\n".classname."::~".classname." ()\n{\n}"
		let @z= @z."\t\t\t\t// ----------  end of destructor of class ".classname."  ----------\n"
		
		let @z= @z."\n\nconst ".classname."&\n".classname."::operator = (const ".classname." &obj)"
		let @z= @z."\n{\n\tif(this!=&obj)\n\t{\n\n\t}\n\treturn *this;\n}"	
		let @z= @z."\t\t\t\t// ----------  end of assignement operator of class ".classname."  ----------\n"
		put z
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C++ : simple error class
"------------------------------------------------------------------------------
function! CVIM_CodeErrorClass()
	let	classname=inputdialog("name of error class", "Error" )
	if classname != ""
		let @z=    "class ".classname
		let @z= @z."\n{\n\tprotected:\tchar  *message;"
		let @z= @z."\n\tpublic:\t\t\t".classname." (char *msg)   { message=msg; }"
		let @z= @z."\n\t\t\t\t\t\t\tvirtual const char* what () const throw ()   { return message; }"
		let @z= @z."\n};\t\t\t// ----------  end of class  ".classname."  ----------\n"
		put z
	endif
endfunction
"
"
"------------------------------------------------------------------------------
"  C++ : template class
"------------------------------------------------------------------------------
function! CVIM_CodeTemplateClass ()
	let	classname=inputdialog("name of template class", "TCls" )
	if classname != ""
		let @z=    "template < class T >\nclass ".classname
		let @z= @z."\n{\n\n\tpublic:\n\n"
		let @z= @z."\t\t// ====================  LIFECYCLE   =========================================\n\n"
		let @z= @z."\t\t".classname." (); \t// constructor\n\n"	
		let @z= @z."\t\t// Use compiler-generated copy constructor, assignement operator and destructor\n\n"	
		let @z= @z."\t\t// ====================  OPERATORS   =========================================\n\n"
		let @z= @z."\t\t// ====================  OPERATIONS  =========================================\n\n"
		let @z= @z."\t\t// ====================  ACCESS      =========================================\n\n"
		let @z= @z."\t\t// ====================  INQUIRY     =========================================\n\n"
		let @z= @z."\t\t// ====================  NESTED ERROR CLASSES  ===============================\n\n\n"
		let @z= @z."\tprotected:\n\n"
		let @z= @z."\tprivate:\n\n"
		let @z= @z."\n};\t\t\t// ----------  end of template class  ".classname."  ----------\n"
		
		let @z= @z."\n\ntemplate < class T >"
		let @z= @z."\n".classname." < T >:: ".classname." ()\n{\n}"
		let @z= @z."\t\t\t\t// ----------  end of constructor of template class ".classname."  ----------\n"
		
		put z
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C++ : template class using the new operator
"------------------------------------------------------------------------------
function! CVIM_CodeTemplateClassNew ()
	let	classname=inputdialog("name of template class using new", "TClsN" )
	if classname != ""
		let	tabs = ""
		let	n = (strlen(classname)-1)/2				" number of extra tabs 
		while n>0
			let tabs = tabs."\t"
			let	n = n-1
		endwhile
		let @z=    "template < class T >\nclass ".classname
		let @z= @z."\n{\n\n\tpublic:\n\n"
		let @z= @z."\t\t// ====================  LIFECYCLE   =========================================\n\n"
		let @z= @z."\t\t".classname." ();\t\t\t\t\t\t\t".tabs."// constructor\n"	
		let @z= @z."\t\t".classname." (const ".classname." &obj);\t// copy constructor\n"	
		let @z= @z."\t\t~".classname." (); \t\t\t\t\t\t".tabs."// destructor\n\n"
		let @z= @z."\t\t// ====================  OPERATORS   =========================================\n\n"
		let @z= @z."\t\tconst ".classname."& operator = (const ".classname." &obj);"
		let @z= @z."\t\t// assignement operator\n\n"
		let @z= @z."\t\t// ====================  OPERATIONS  =========================================\n\n"
		let @z= @z."\t\t// ====================  ACCESS      =========================================\n\n"
		let @z= @z."\t\t// ====================  INQUIRY     =========================================\n\n"
		let @z= @z."\t\t// ====================  NESTED ERROR CLASSES  ===============================\n\n\n"
		let @z= @z."\tprotected:\n\n"
		let @z= @z."\tprivate:\n\n"
		let @z= @z."\n};\t\t\t// ----------  end of template class  ".classname."  ----------\n"

		let @z= @z."\n\ntemplate < class T >"
		let @z= @z."\n".classname."< T >::".classname." ()\n{\n}"	
		let @z= @z."\t\t\t\t// ----------  end of constructor of template class ".classname."  ----------\n"


		let @z= @z."\n\ntemplate < class T >"
		let @z= @z."\n".classname."< T >::".classname." (const ".classname." &obj)\n{\n}"
		let @z= @z."\t\t\t\t// ----------  end of copy constructor of template class ".classname."  ----------\n"
		
		let @z= @z."\n\ntemplate < class T >"
		let @z= @z."\n".classname."< T >::~".classname." ()\n{\n}"
		let @z= @z."\t\t\t\t// ----------  end of destructor of template class ".classname."  ----------\n"
		
		let @z= @z."\n\ntemplate < class T >"
		let @z= @z."\nconst ".classname."< T >& ".classname."< T >::operator = (const ".classname." &obj)"
		let @z= @z."\n{\n\tif(this!=&obj)\n\t{\n\n\t}\n\treturn *this;\n}"	
		let @z= @z."\t\t\t\t// ----------  end of assignement operator of template class ".classname."  ----------\n"
		put z
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C++ : template function
"------------------------------------------------------------------------------
function! CVIM_CodeTemplateFunct ()
	let	identifier=inputdialog("template function name", "f" )
	if identifier != ""
		let @z=    "template <class T> void\n".identifier."\t( T param )\n{\n\n\n\treturn ;\n}"
		let @z= @z."\t\t\t\t// ----------  end of template function ".identifier."  ----------"
		put z
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C-Idioms : enum struct union
"------------------------------------------------------------------------------
function! CVIM_EST (su)
	let name= strpart( a:su, 0, 1 )												" first character of argument
	let	name= inputdialog("(lowercase) ".a:su." name", name )
	if name != ""
"		let	typename	= substitute(name,".*", '\u\0', "" )	" first character to uppercase
		let	typename	= name
		let @z=    a:su." ".name."\n{\n\t\n};"
		let @z= @z."\t\t\t\t// ----------  end of ".a:su." ".name."  ----------\n\n"
		let @z= @z."typedef ".a:su." ".name." ".typename.";\n\n"
		put z
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C-Idioms : malloc
"------------------------------------------------------------------------------
function! CVIM_CodeMalloc ()
	let	pointername= inputdialog("pointer name", "p")
	if pointername != ""
		let @z=    pointername."\t= malloc (  );"
		let @z= @z."\n\nif (".pointername."==NULL)\n{"
		let @z= @z."\n\tfprintf (stderr, \"\\n ** dynamic memory allocation failed ** exit **\\n\" );"
		let @z= @z."\n\texit(3);\n}"
		let @z= @z."\n\nfree (".pointername.");\n\n"
		put z
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C-Idioms : open file for reading
"------------------------------------------------------------------------------
function! CVIM_CodeFopenRead ()
	let	filepointer=inputdialog("input-file pointer", "infile")
	if filepointer != ""
		let filename=filepointer."_file_name"
		let @z=    "FILE\t*".filepointer.";\t\t\t\t\t\t\t\t\t// input-file pointer\n"
		let @z= @z."char\t*".filename." = \"\";\t\t// input-file name\n\n"
		let @z= @z.filepointer."\t= fopen ( ".filename.", \"r\" );\n"
		let @z= @z."if (".filepointer." == NULL)\n{\n"
		let @z= @z."\tfprintf (stderr, \" ** cannot open input file %s ** exit **\\n\", ".filename." );\n"
		let @z= @z."\texit (1);\n}\n\n\n"
		let @z= @z."fclose ( ".filepointer." );\t\t\t\t\t\t\t// close input file\n"
		put z
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C-Idioms : open file for writing
"------------------------------------------------------------------------------
function! CVIM_CodeFopenWrite ()
	let	filepointer=inputdialog("output-file pointer", "outfile")
	if filepointer != ""
		let filename=filepointer."_file_name"
		let @z=    "FILE\t*".filepointer.";\t\t\t\t\t\t\t\t\t// output-file pointer\n"
		let @z= @z."char\t*".filename." = \"\";\t// output-file name\n\n"
		let @z= @z.filepointer."\t= fopen ( ".filename.", \"w\" );\n"
		let @z= @z."if (".filepointer." == NULL)\n{\n"
		let @z= @z."\tfprintf (stderr, \" ** cannot open output file %s ** exit **\\n\", ".filename." );\n"
		let @z= @z."\texit (2);\n}\n\n\n"
		let @z= @z."fclose ( ".filepointer." );\t\t\t\t\t\t\t// close output file\n"
		put z
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C++ : open file for reading
"------------------------------------------------------------------------------
function! CVIM_CodeIfstream ()
	let	ifstreamobject=inputdialog("ifstream object", "ifs" )
	if ifstreamobject != ""
		let filename=ifstreamobject."_file_name"
		let @z=    "char *".filename." = \"\";\t\t// input file name\n"
		let @z= @z."ifstream\t".ifstreamobject.";\t\t\t\t\t\t\t// create ifstream object\n\n"
		let @z= @z.ifstreamobject.".open(".filename.");\t\t// open ifstream\n"
		let @z= @z."if (!".ifstreamobject.")\n{\n"
		let @z= @z."\tcerr << \"\\nERROR : failed to open input file \" << ".filename." << \" --- exit program\\n\";\n"
		let @z= @z."\texit (1);\n}\n\n\n"
		let @z= @z.ifstreamobject.".close();\t\t// close ifstream\n"
		put z
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C++ : open file for writing
"------------------------------------------------------------------------------
function! CVIM_CodeOfstream ()
	let	ofstreamobject=inputdialog("ofstream object", "ofs" )
	if ofstreamobject != ""
		let filename=ofstreamobject."_file_name"
		let @z=    "char *".filename." = \"\";\t\t// output file name\n"
		let @z= @z."ofstream\t".ofstreamobject.";\t\t\t\t\t\t\t// create ofstream object\n\n"
		let @z= @z.ofstreamobject.".open(".filename.");\t\t// open ofstream\n"
		let @z= @z."if (!".ofstreamobject.")\n{\n"
		let @z= @z."\tcerr << \"\\nERROR : failed to open output file \" << ".filename." << \" --- exit program\\n\";\n"
		let @z= @z."\texit (2);\n}\n\n\n"
		let @z= @z.ofstreamobject.".close();\t\t// close ofstream\n"
		put z
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C++ : extern "C"
"------------------------------------------------------------------------------
function! CVIM_CodeExternC()
	let @z=    "extern \"C\"\n{\n\t#include\t\".h\"\n}"
	put z
endfunction
"
"------------------------------------------------------------------------------
"  C++ : output operator
"------------------------------------------------------------------------------
function! CVIM_CodeOutputOperator ()
	let	identifier=inputdialog("class name", "" )
	if identifier != ""
		let @z=    "friend ostream &\noperator << (ostream & os, const ".identifier." & obj )\n"
		let @z= @z."{\n\tos << obj. ;\n\treturn os;\n}"
		let @z= @z."\t\t\t\t// ----------  class ".identifier." : end of friend function operator <<  ----------"
		put z
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C++ : input operator
"------------------------------------------------------------------------------
function! CVIM_CodeInputOperator ()
	let	identifier=inputdialog("class name", "" )
	if identifier != ""
		let @z=    "friend istream &\noperator >> (istream & is, ".identifier." & obj )"
		let @z= @z."\n{\n\tis >> obj. ;\n\treturn is;\n}"
		let @z= @z."\t\t\t\t// ----------  class ".identifier." : end of friend function operator >>  ----------"
		put z
	endif
endfunction
"
"
"------------------------------------------------------------------------------
"  C++ : try catch
"------------------------------------------------------------------------------
function! CVIM_CodeTryCatch ()
  let @z=    "try\n{\n\t\n}\n"
  let @z= @z."catch (const  &ExceptObj)\t\t// handle exception: \n{\n\t\n}\n"
  let @z= @z."catch (...)\t\t\t// handle exception: unspezified\n{\n\t\n}"
	put z
endfunction
"
"------------------------------------------------------------------------------
"  C++ : catch
"------------------------------------------------------------------------------
function! CVIM_CodeCatch ()
  let @z=    "catch (const  &ExceptObj)\t\t// handle exception: \n{\n\t\n}\n"
	put z
endfunction
""------------------------------------------------------------------------------
"  run : CVIM_Compile
"------------------------------------------------------------------------------
"  The standard make program 'make' called by vim is set to the C or C++ compiler
"  and reset after the compilation  (set makeprg=... ).
"  The errorfile created by the compiler will now be read by gvim and
"  the commands cl, cp, cn, ... can be used.
"
"
"------------------------------------------------------------------------------
function! CVIM_Compile ()

	let	Sou		= expand("%")								" name of the file in the current buffer
	let	Obj		= expand("%:r").".o"				" name of the object
	let	Ext		= expand("%:e")							" file extension

	" update : write source file if necessary
	exe	":update"
	
	" compilation if object does not exist or object exists and is older then the source	
	if !filereadable(Obj) || (filereadable(Obj) && (getftime(Obj) < getftime(Sou)))
		
		if Ext == s:CVIM_CExtension
			exe		"set makeprg=".s:CVIM_CCompiler
		else
			exe		"set makeprg=".s:CVIM_CplusCompiler
		endif

		" COMPILATION
		exe		"make ".s:CVIM_CFlags." ".Sou." -o ".Obj		
		
		exe		"set makeprg=make"
	endif
	
endfunction
"
"------------------------------------------------------------------------------
"  run : CVIM_Link
"------------------------------------------------------------------------------
"  The standard make program which is used by gvim is set to the compiler
"  (for linking) and reset after linking.
"------------------------------------------------------------------------------
function! CVIM_Link ()

	call	CVIM_Compile()

	let	Sou		= expand("%")								" name of the file in the current buffer
	let	Obj		= expand("%:r").".o"				" name of the object file
	let	Exe		= expand("%:r").".e"				" name of the executable
	let	Ext		= expand("%:e")							" file extension
	
	" no linkage if:
	"   executable exists
	"   object exists
	"   source exists
	"   executable newer then object
	"   object newer then source
	
	if    filereadable(Exe) &&
      \ filereadable(Obj) &&
      \ filereadable(Sou) &&
      \ (getftime(Exe) >= getftime(Obj)) &&
      \ (getftime(Obj) >= getftime(Sou))
		return
	endif
	
	" linkage if:
	"   object exists
	"   source exists
	"   object newer then source
	
	if filereadable(Obj) && (getftime(Obj) >= getftime(Sou))
	
		if Ext == s:CVIM_CExtension
			exe		"set makeprg=".s:CVIM_CCompiler
		else
			exe		"set makeprg=".s:CVIM_CplusCompiler
		endif
		exe		"make ".s:CVIM_LFlags." ".s:CVIM_Libs." -o ".Exe." ".Obj
		exe		"set makeprg=make"

	endif

endfunction
"
"------------------------------------------------------------------------------
"  run : CVIM_Run
"------------------------------------------------------------------------------
function! CVIM_Run (arg1)

	let	Sou		= expand("%")										" name of the source file
	let	Obj		= expand("%:r").".o"						" name of the object file
	let	Exe		= expand("%:r").".e"						" name of the executable

	call	CVIM_Link()													" compile+link the file in the current buffer
	
	" exe exists and is newer then the object, the object is newer then the source
	" this prevents an old executable from running in the case of compilation or link errors
	
	if filereadable(Exe) && getftime(Exe) >= getftime(Obj) && getftime(Obj) >= getftime(Sou)
		if a:arg1==0
			exe		"!./".Exe." ".s:CVIM_CmdLineArgs
		else
			exe		"!./".Exe." ".s:CVIM_CmdLineArgs." | ".s:CVIM_Pager
		endif
	endif
	
endfunction
"
"------------------------------------------------------------------------------
"  run : Arguments
"------------------------------------------------------------------------------
function! CVIM_Arguments ()
	let	s:CVIM_CmdLineArgs= inputdialog("command line arguments",s:CVIM_CmdLineArgs)
endfunction
"
"
"------------------------------------------------------------------------------
"  run : about
"------------------------------------------------------------------------------
function! CVIM_Version ()
	let dummy=confirm("C/C++-Support, Version ".s:CVIM_Version."\nDr. Fritz Mehner\nmehner@fh-swf.de", "ok" )
endfunction
"
"------------------------------------------------------------------------------
"  c : CVIM_CreateUnLoadMenuEntries
"	 Create the load/unload entry in the GVIM tool menu, depending on 
"	 which script is already loaded.
"  Author: M.Faulstich
"------------------------------------------------------------------------------
"
let s:CVIM_Active = -1									" state variable controlling the C-menus
"
function! CVIM_CreateUnLoadMenuEntries ()
"
	" C is now active and was former inactive -> 
	" Insert Tools.Unload and remove Tools.Load Menu
	if  s:CVIM_Active == 1
		aunmenu Tools.Load\ C\ Support
		amenu   &Tools.Unload\ C\ Support  	<C-C>:call CVIM_HandleC()<CR>
	else
		" C is now inactive and was former active or in initial state -1 
		if s:CVIM_Active == 0
			" Remove Tools.Unload if C was former inactive
			aunmenu Tools.Unload\ C\ Support
		else
			" Set initial state CVIM_Active=-1 to inactive state CVIM_Active=0
			" This protects from removing Tools.Unload during initialization after
			" loading this script
			let s:CVIM_Active = 0
			" Insert Tools.Load
		endif
		amenu &Tools.Load\ C\ Support <C-C>:call CVIM_HandleC()<CR>
	endif
	"
"
endfunction
"
"------------------------------------------------------------------------------
"  C : CVIM_HandleC
"  Loads or unloads C support menus.
"  Author: M.Faulstich
"------------------------------------------------------------------------------
function! CVIM_HandleC ()
	if s:CVIM_Active == 0
		:call CVIM_InitC()
		let s:CVIM_Active = 1
	else
		aunmenu C-Comments
		aunmenu C-Statements
		aunmenu C-Idioms
		aunmenu C++
		aunmenu C-Run
		let s:CVIM_Active = 0
	endif
	
	call CVIM_CreateUnLoadMenuEntries ()
endfunction
"
"------------------------------------------------------------------------------
" 
call CVIM_CreateUnLoadMenuEntries()			" create the menu entry in the GVIM tool menu
call CVIM_HandleC()											" load the menus
"=====================================================================================

