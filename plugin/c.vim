"###############################################################################################
"
"     Filename:  c.vim
"
"  Description:  Write C/C++ programs by inserting complete statements, idioms and comments. 
"                Compile, link and run one-file-programs without a makefile.
"                
"                Code and comments should have a professional appearance and should be
"                easy to write and maintain. 
"                Programs with a consistent style are easier to read and understand.
"                The standardization of comments makes it possible to automate the search
"                for information and the generation of documents from the source code.
"
" GVIM Version:  6.0+
"
"       Author:  Dr.-Ing. Fritz Mehner 
"                Fachhochschule Südwestfalen, 58644 Iserlohn, Germany
"
"        Email:  mehner@fh-swf.de
"
"        Usage:  (1.0) Configure  c.vim  (section Configuration below).
"                (2.1) Load  c.vim  manually into VIM with the 'so' command:
"                        :so ~/<any directory>/c.vim
"                      or better
"                (2.2) Load c.vim on startup (VIM version 6.0 and higher) :
"                      move this file to the directory ~/.vim/plugin/
"                
"                c.vim inserts an additional menu entry into the Tools-menu for
"                loading/unloading this C support.
"
"         Note:  The register z is used in many places.
"
" Style Guides:  Some ideas are taken from the following documents (recommended!):
"
"                1. Recommended C Style and Coding Standards (Indian Hill Style Guide)
"                    www.doc.ic.ac.uk/lab/secondyear/cstyle/cstyle.html
"                2. Programming in C++, Ellemtel Telecommunication Systems Laboratories
"                    www.it.bton.ac.uk/burks/burks/language/cpp/cppstyle/ellhome.htm
"                3. C++ Coding Standard, Todd Hoff
"                    www.possibility.com/Cpp/CppCodingStandard.html
"
let s:C_Version = "2.6"              " version number of this script; do not change
"     Revision:  02.07.2002
"      Created:  04.11.2000
"###############################################################################################
"
"  Configuration  (Use my configuration as an example)
"
"-------------------------------------------------------------------------------------
"
let s:C_AuthorName      = "Dr.-Ing. Fritz Mehner"
let s:C_AuthorRef       = "Mn"
"
"  The following entries do not appear if the strings are empty.
"
let s:C_Email           = "mehner@fh-swf.de"
let s:C_Company         = "Fachhochschule Südwestfalen, Iserlohn"
let s:C_Project         = ""
let s:C_Compiler        = "GNU C/C++"
"
"  Copyright information
"  ---------------------
"  If the code has been developed over a period of years, each year must be stated.
"  If C_CopyrightHolder is empty the copyright notice will not appear.
"  If C_CopyrightHolder is not empty and C_CopyrightYears is empty, 
"  the current year will be inserted.
"
let s:C_CopyrightHolder = ""
let s:C_CopyrightYears  = ""
"
"###############################################################################################
"
"  Global Variables : Compiler, Options, Libraries, ...
"
let s:C_CExtension    = "c"             " C file extension; everything else is C++
let s:C_CCompiler     = "gcc"           " the C   compiler
let s:C_CplusCompiler = "g++"           " the C++ compiler
let s:C_CFlags        = "-Wall -g -c"   " compiler flags: compile
let s:C_LFlags        = "-Wall -g"      " compiler flags: link
let s:C_Libs          = "-lm"           " libraries to use
"
let s:C_Pager         = "less"          " pager
"
let s:C_ShowMenues    = "yes"           " show menues immediately after loading this file (yes/no)
"
"
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
"
"----- some variables for internal use ----------------------------------------
"
let s:C_CmdLineArgs  = ""           " command line arguments for Run-run; initially empty
let s:C_ClassName    = ""           " remember class name ; initially empty
"
"------------------------------------------------------------------------------
"  C : C_InitC
"  Initialization of C support menus
"------------------------------------------------------------------------------
"
function! C_InitC ()
	"
	"===============================================================================================
	"----- Menu : Key Mappings ---------------------------------------------------------------------
	"===============================================================================================
	"  The following key mappings are for convenience only. 
	"  Comment out the mappings if you dislike them.
	"  If enabled, there may be conflicts with predefined key bindings of your window manager.
	"-------------------------------------------------------------------------------------
	"  Alt-F9    write buffer and compile
	"  F9        compile and link
	"  Ctrl-F9   run executable
	"
	map  <A-F9>  :w<CR><Esc>:call C_Compile()<CR><C-C>:cwin<CR>
	map  <F9>    :call C_Link()<CR><C-C>:cwin<CR>
	map  <C-F9>  :call C_Run(0)<CR><C-C>:cwin<CR>
	map  <S-F9>  :make<CR>
	"
	"===============================================================================================
	"----- Menu : C-Comments -----------------------------------------------------------------------
	"===============================================================================================
	"
	amenu  &Comments.&Line\ End\ Comment        <Esc><Esc>A<Tab><Tab><Tab>// 
	amenu  &Comments.&Frame\ Comment            <Esc><Esc>:call C_CommentFrame()       <CR>jA
	amenu  &Comments.F&unction\ Description     <Esc><Esc>:call C_CommentFunction()    <CR>:/Name<CR>A
	amenu  &Comments.&Main\ Description         <Esc><Esc>:call C_CommentMain()        <CR>:/Description<CR>A
	amenu  &Comments.-SEP1-                     :
	amenu  &Comments.M&ethod\ Comment           <Esc><Esc>:call C_CommentMethod()<CR>:/Method<CR>A
	amenu  &Comments.Cl&ass\ Comment            <Esc><Esc>:call C_CommentClass()<CR>:/Description<CR>A
	amenu  &Comments.Clea&r\ Class\ Name        <Esc><Esc>:call C_CommentClearClassNmae()<CR>i
	amenu  &Comments.-SEP2-                     :
	amenu  &Comments.File\ &Prologue            <Esc><Esc>:call C_CommentFilePrologue()<CR>:/Description<CR>A
	amenu  &Comments.-SEP3-                     :
		"
		"----- Submenu : H-Comments : file sections  -------------------------------------------------------------
		"
		amenu  &Comments.&H-File\ Sections.&Header\ File\ Includes    
					\<Esc><Esc>:call C_CommentSection("HEADER FILE INCLUDES")<CR>0i
		amenu  &Comments.&H-File\ Sections.Exported\ &Macros          
					\<Esc><Esc>:call C_CommentSection("EXPORTED MACROS")<CR>0i
		amenu  &Comments.&H-File\ Sections.Exported\ &Data\ Types     
					\<Esc><Esc>:call C_CommentSection("EXPORTED DATA TYPES")<CR>0i
		amenu  &Comments.&H-File\ Sections.Exported\ &Type\ Def\.     
					\<Esc><Esc>:call C_CommentSection("EXPORTED TYPE DEFINITIONS")<CR>0i
		amenu  &Comments.&H-File\ Sections.Exported\ &Variables       
					\<Esc><Esc>:call C_CommentSection("EXPORTED VARIABLES")<CR>0i
		amenu  &Comments.&H-File\ Sections.Exported\ &Funct\.\ Decl\. 
					\<Esc><Esc>:call C_CommentSection("EXPORTED FUNCTION DECLARATIONS")<CR>0i
		amenu  &Comments.&H-File\ Sections.-SEP4-                     :
		amenu  &Comments.&H-File\ Sections.Exported\ &Class\ Def\.    
					\<Esc><Esc>:call C_CommentSection("EXPORTED CLASS DEFINITIONS")<CR>0i
		amenu  &Comments.&H-File\ Sections.-SEP5-                     :
		amenu  &Comments.&H-File\ Sections.&All\ Sections,\ C         
					\<Esc><Esc>:call C_Comment_H_SectionAll1()<CR>0i
		amenu  &Comments.&H-File\ Sections.All\ &Sections,\ C++       
					\<Esc><Esc>:call C_Comment_H_SectionAll2()<CR>0i
		"
		"----- Submenu : C-Comments : file sections  -------------------------------------------------------------
		"
		amenu  &Comments.&C-File\ Sections.&Header\ File\ Includes  
					\<Esc><Esc>:call C_CommentSection("HEADER FILE INCLUDES")<CR>0i
		amenu  &Comments.&C-File\ Sections.Local\ &Macros           
					\<Esc><Esc>:call C_CommentSection("MACROS  -  LOCAL TO THIS SOURCE FILE")<CR>0i
		amenu  &Comments.&C-File\ Sections.Local\ &Data\ Types      
					\<Esc><Esc>:call C_CommentSection("DATA TYPES  -  LOCAL TO THIS SOURCE FILE")<CR>0i
		amenu  &Comments.&C-File\ Sections.Local\ &Type\ Def\.      
					\<Esc><Esc>:call C_CommentSection("TYPE DEFINITIONS  -  LOCAL TO THIS SOURCE FILE")<CR>0i
		amenu  &Comments.&C-File\ Sections.Local\ &Variables        
					\<Esc><Esc>:call C_CommentSection("VARIABLES  -  LOCAL TO THIS SOURCE FILE")<CR>0i
		amenu  &Comments.&C-File\ Sections.Local\ P&rototypes       
					\<Esc><Esc>:call C_CommentSection("PROTOTYPES  -  LOCAL TO THIS SOURCE FILE")<CR>0i
		amenu  &Comments.&C-File\ Sections.&Exp\.\ Function\ Def\.  
					\<Esc><Esc>:call C_CommentSection("FUNCTION DEFINITIONS  -  EXPORTED FUNCTIONS")<CR>0i
		amenu  &Comments.&C-File\ Sections.&Local\ Function\ Def\.  
					\<Esc><Esc>:call C_CommentSection("FUNCTION DEFINITIONS  -  LOCAL TO THIS SOURCE FILE")<CR>0i
		amenu  &Comments.&C-File\ Sections.-SEP6-                   :
		amenu  &Comments.&C-File\ Sections.Local\ &Class\ Def\.     
					\<Esc><Esc>:call C_CommentSection("CLASS DEFINITIONS  -  LOCAL TO THIS SOURCE FILE")<CR>0i
		amenu  &Comments.&C-File\ Sections.E&xp\.\ Class\ Impl\.    
					\<Esc><Esc>:call C_CommentSection("CLASS IMPLEMENTATIONS  -  EXPORTED CLASSES")<CR>0i
		amenu  &Comments.&C-File\ Sections.Local\ Class\ Im&pl\.    
					\<Esc><Esc>:call C_CommentSection("CLASS IMPLEMENTATIONS  -  LOCAL CLASSES")<CR>0i
		amenu  &Comments.&C-File\ Sections.-SEP7-                   :
		amenu  &Comments.&C-File\ Sections.&All\ Sections,\ C       
					\<Esc><Esc>:call C_Comment_C_SectionAll1()<CR>0i
		amenu  &Comments.&C-File\ Sections.All\ &Sections,\ C++     
					\<Esc><Esc>:call C_Comment_C_SectionAll2()<CR>0i
		"
		amenu  &Comments.-SEP8-                        :
		"
		"----- Submenu : C-Comments : keyword comments  ----------------------------------------------------------
		"
		amenu  &Comments.&KEYWORD+Comm\..\/\/\ \:&BUG\:          <Esc><Esc>$<Esc>:call C_CommentClassified("BUG")     <CR>kgJA
		amenu  &Comments.&KEYWORD+Comm\..\/\/\ \:&COMPILER\:     <Esc><Esc>$<Esc>:call C_CommentClassified("COMPILER")<CR>kgJA
		amenu  &Comments.&KEYWORD+Comm\..\/\/\ \:&TODO\:         <Esc><Esc>$<Esc>:call C_CommentClassified("TODO")    <CR>kgJA
		amenu  &Comments.&KEYWORD+Comm\..\/\/\ \:T&RICKY\:       <Esc><Esc>$<Esc>:call C_CommentClassified("TRICKY")  <CR>kgJA
		amenu  &Comments.&KEYWORD+Comm\..\/\/\ \:&WARNING\:      <Esc><Esc>$<Esc>:call C_CommentClassified("WARNING") <CR>kgJA
		amenu  &Comments.&KEYWORD+Comm\..\/\/\ \:&new\ keyword\: <Esc><Esc>$<Esc>:call C_CommentClassified("")        <CR>kgJf:a
		"
		"----- Submenu : C-Comments : keyword comments  ----------------------------------------------------------
		"
		amenu  &Comments.spec&ial\ Comm\..\/\/\ &EMPTY                  <Esc><Esc>A<Tab>// EMPTY
		amenu  &Comments.spec&ial\ Comm\..\/\/\ FALL\ TH&ROUGH          <Esc><Esc>A<Tab>// FALL THROUGH
		amenu  &Comments.spec&ial\ Comm\..\/\/\ &IMPL\.\ TYPE\ CONV     <Esc><Esc>A<Tab>// IMPLICIT TYPE CONVERSION
		amenu  &Comments.spec&ial\ Comm\..\/\/\ &NOT\ REACHED           <Esc><Esc>A<Tab>// NOT REACHED
		amenu  &Comments.spec&ial\ Comm\..\/\/\ TO\ &BE\ IMPL\.         <Esc><Esc>A<Tab>// REMAINS TO BE IMPLEMENTED
		"
	amenu  &Comments.-SEP9-                     :
	amenu  &Comments.&Date                      <Esc><Esc>:let @z=strftime("%x")     <CR>"zpa
	amenu  &Comments.Date\ &Time                <Esc><Esc>:let @z=strftime("%x - %X")<CR>"zpa
	amenu  &Comments.-SEP10-                    :
	vmenu  &Comments.code&->comment             <Esc><Esc>:'<,'>s/^/\/\//<CR><Esc>:nohlsearch<CR>
	vmenu  &Comments.c&omment->code             <Esc><Esc>:'<,'>s/^\/\///<CR><Esc>:nohlsearch<CR>
	"
	"
	"===============================================================================================
	"----- Menu : C-Statements ---------------------------------------------------------------------
	"===============================================================================================
	"
	imenu  C-St&atements.&if\ \{\ \}                 <Esc>:let @z="if (  )\n{\n\t\n}\n"                 <CR>"z]p<Esc>f(la
	imenu  C-St&atements.if\ \{\ \}\ &else\ \{\ \}   <Esc>:let @z="if (  )\n{\n\t\n}\nelse\n{\n\t\n}\n" <CR>"z]p<Esc>f(la
	imenu  C-St&atements.e&lse\ \{\ \}               <Esc>:let @z="else\n{\n\t\n}\n"                    <CR>"z]p<Esc>4<<2ja
	imenu  C-St&atements.&for                        <Esc>:let @z="for ( ; ;  )\n"                      <CR>"z]p<Esc>f;i
	imenu  C-St&atements.f&or\ \{\ \}                <Esc>:let @z="for ( ; ;  )\n{\n\t\n}\n"            <CR>"z]p<Esc>f;i
	imenu  C-St&atements.&while\ \{\ \}              <Esc>:let @z="while (  )\n{\n\t\n}\n"              <CR>"z]p<Esc>f(la
	imenu  C-St&atements.&do\ \{\ \}\ while          <Esc>:call C_DoWhile()           <CR>"z]p<Esc>:/while <CR>f(la
	imenu  C-St&atements.&switch                     <Esc>:call C_CodeSwitch()        <CR>"z]p<Esc>f(la
	imenu  C-St&atements.&case                       <Esc>:call C_CodeCase()          <CR>"z]p<Esc>f:i
	imenu  C-St&atements.&\{\ \}                     <Esc>:let @z="{\n\t\n}\n"        <CR>"z]p<Esc>jA
	imenu  C-St&atements.-SEP1-                      :
	imenu  C-St&atements.#include\ &\<\.\.\.\>       <Esc>:let @z="#include\t<.h>"    <CR>"zp<Esc>F.i
	imenu  C-St&atements.#include\ \"\.\.\.\"        <Esc>:let @z="#include\t\".h\""  <CR>"zp<Esc>F.i
	imenu  C-St&atements.&#define                    <Esc>:let @z="#define\t\t\t\t// "<CR>"zp<Esc>4F<Tab>a
	imenu  C-St&atements.#if\.\.#else\.\.#endif      <Esc>:call C_PPIfElse('if')      <CR>ji
	imenu  C-St&atements.#ifdef\.\.#else\.\.#endif   <Esc>:call C_PPIfElse('ifdef')   <CR>ji
	imenu  C-St&atements.#ifndef\.\.#else\.\.#endif  <Esc>:call C_PPIfElse('ifndef')  <CR>ji
	imenu  C-St&atements.#ifndef\.\.#def\.\.#endif   <Esc>:call C_PPIfDef()           <CR>2ji
	"
	"===============================================================================================
	"----- Menu : C-Idioms -------------------------------------------------------------------------
	"===============================================================================================
	"
	imenu  C-&Idioms.&function                            <Esc>:call C_CodeFunction()<CR>
	imenu  C-&Idioms.&main                                <Esc>:call C_CodeMain()<CR>3jA
	imenu  C-&Idioms.-SEP1-                               :
	imenu  C-&Idioms.for\ (\ i=&0;\ \ \ i<n;\ \ i\+=1\ )  for ( i=0; i<n; i+=1 )<Esc>0fni
	imenu  C-&Idioms.for\ (\ i=n&-1;\ i>=0;\ i\-=1\ )     for ( i=n-1; i>=0; i-=1 )<Esc>0fni
	imenu  C-&Idioms.for\ (\ i=&1;\ \ \ i<=n;\ i\+=1\ )   for ( i=1; i<=n; i+=1 )<Esc>0fni
	imenu  C-&Idioms.for\ (\ i=&n;\ \ \ i>=1;\ i\-=1\ )   for ( i=n; i>=1; i-=1 )<Esc>0fni
	imenu  C-&Idioms.-SEP2-                           :
	imenu  C-&Idioms.&enum\+typedef                       <Esc>:call C_EST("enum")<CR>2jA
	imenu  C-&Idioms.&struct\+typedef                     <Esc>:call C_EST("struct")<CR>2jA
	imenu  C-&Idioms.&union\+typedef                      <Esc>:call C_EST("union")<CR>2jA
	imenu  C-&Idioms.-SEP3-                               :
	imenu  C-&Idioms.&printf                              printf ("\n");<Esc>F\i
	imenu  C-&Idioms.s&canf                               scanf ("", & );<Esc>F"i
		"
		"----- Submenu : C-Idioms: standard library -------------------------------------------------------
		"
		imenu  C-&Idioms.&#include\ Std\.Lib\..\<&assert\.h\>   <Esc>o#include	<assert.h>
		imenu  C-&Idioms.&#include\ Std\.Lib\..\<&ctype\.h\>    <Esc>o#include	<ctype.h>
		imenu  C-&Idioms.&#include\ Std\.Lib\..\<&errno\.h\>    <Esc>o#include	<errno.h>
		imenu  C-&Idioms.&#include\ Std\.Lib\..\<&float\.h\>    <Esc>o#include	<float.h>
		imenu  C-&Idioms.&#include\ Std\.Lib\..\<&limits\.h\>   <Esc>o#include	<limits.h>
		imenu  C-&Idioms.&#include\ Std\.Lib\..\<l&ocale\.h\>   <Esc>o#include	<locale.h>
		imenu  C-&Idioms.&#include\ Std\.Lib\..\<&math\.h\>     <Esc>o#include	<math.h>
		imenu  C-&Idioms.&#include\ Std\.Lib\..\<set&jmp\.h\>   <Esc>o#include	<setjmp.h>
		imenu  C-&Idioms.&#include\ Std\.Lib\..\<s&ignal\.h\>   <Esc>o#include	<signal.h>
		imenu  C-&Idioms.&#include\ Std\.Lib\..\<stdar&g\.h\>   <Esc>o#include	<stdarg.h>
		imenu  C-&Idioms.&#include\ Std\.Lib\..\<st&ddef\.h\>   <Esc>o#include	<stddef.h>
		imenu  C-&Idioms.&#include\ Std\.Lib\..\<&stdio\.h\>    <Esc>o#include	<stdio.h>
		imenu  C-&Idioms.&#include\ Std\.Lib\..\<stdli&b\.h\>   <Esc>o#include	<stdlib.h>
		imenu  C-&Idioms.&#include\ Std\.Lib\..\<st&ring\.h\>   <Esc>o#include	<string.h>
		imenu  C-&Idioms.&#include\ Std\.Lib\..\<&time\.h\>     <Esc>o#include	<time.h>
		"
	imenu  C-&Idioms.-SEP4-                     :
	imenu  C-&Idioms.p=m&alloc\(\ \)            <Esc>:call C_CodeMalloc()<CR>f(la
	imenu  C-&Idioms.open\ &input\ file         <Esc>:call C_CodeFopenRead()<CR>jf"a
	imenu  C-&Idioms.open\ &output\ file        <Esc>:call C_CodeFopenWrite()<CR>jf"a

	"===============================================================================================
	"----- Menu : C++ ------------------------------------------------------------------------------
	"===============================================================================================
	"
	imenu  C&++.c&in                            cin<Tab>>> ;<Esc>i
	imenu  C&++.cout\ &variable                 cout<Tab><<  << endl;<Esc>2F<hi
	imenu  C&++.cout\ &string                   cout<Tab><< "\n";<Esc>F\i
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
		imenu  C&++.output\ mani&pulators.\<\<\ set&iosflag\(\ \)    << setiosflags() <ESC>F)i
		imenu  C&++.output\ mani&pulators.\<\<\ &resetiosflag\(\ \)  << resetiosflags() <ESC>F)i
		imenu  C&++.output\ mani&pulators.\<\<\ set&precision\(\ \)  << setprecision() <ESC>F)i
		imenu  C&++.output\ mani&pulators.\<\<\ set&w\(\ \)          << setw() <ESC>F)i
		imenu  C&++.output\ mani&pulators.&#include\ \<iomanip\.h\>  <Esc>:let @z="#include\t<iomanip.h>" <CR>"z]p<Esc>a
		"
		"----- Submenu : C++ : ios flag bits  -------------------------------------------------------------
		"
		imenu  C&++.ios\ fla&gbits.ios::&skipws         ios::skipws<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::&left           ios::left<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::&right          ios::right<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::&internal       ios::internal<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::&boolalpha      ios::boolalpha<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::&dec            ios::dec<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::&hex            ios::hex<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::&oct            ios::oct<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::s&cientific     ios::scientific<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::&fixed          ios::fixed<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::sho&wbase       ios::showbase<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::show&pos        ios::showpos<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::&uppercase      ios::uppercase<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::&adjustfield    ios::adjustfield<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::bas&efield      ios::basefield<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::floa&tfield     ios::floatfield<Esc>a
		imenu  C&++.ios\ fla&gbits.ios::u&nitbuf        ios::unitbuf<Esc>a
		"
	imenu  C&++.c&err\ string                 cerr<Tab><< "\n";<Esc>F\i
	imenu  C&++.&#include\ \<iostream\.h\>    <Esc>:let @z="#include\t<iostream.h>" <CR>"z]p<Esc>a
	imenu  C&++.-SEP2-                        :
	imenu  C&++.&method\ implementaton        <Esc>:call C_CodeMethod()<CR>
	imenu  C&++.&class                        <Esc>:call C_CodeClass()<CR>
	imenu  C&++.class\ using\ &new            <Esc>:call C_CodeClassNew()<CR>
	imenu  C&++.err&or\ class                 <Esc>:call C_CodeErrorClass()<CR>3jf"a
	imenu  C&++.-SEP3-                        :
	imenu  C&++.&template\ class              <Esc>:call C_CodeTemplateClass()<CR>
	imenu  C&++.template\ class\ using\ ne&w  <Esc>:call C_CodeTemplateClassNew()<CR>
	imenu  C&++.template\ &function           <Esc>:call C_CodeTemplateFunct()<CR>
	imenu  C&++.-SEP4-                        :
	imenu  C&++.friend\ operator\ <<          <Esc>:call C_CodeOutputOperator()<CR>3jf.a
	imenu  C&++.friend\ operator\ >>          <Esc>:call C_CodeInputOperator()<CR>3jf.a
	imenu  C&++.-SEP5-                        :
	imenu  C&++.tr&y\ \.\.\ catch             <Esc>:call C_CodeTryCatch()<CR>4j2f a
	imenu  C&++.c&atch                        <Esc>:call C_CodeCatch()<CR>2f a
	imenu  C&++.catch\(\.\.\.\)               <Esc>:let @z="catch (...)\n{\n\t\n}"<CR>"z]p<Esc>2ja
	imenu  C&++.-SEP6-                        :
	imenu  C&++.open\ input\ file             <Esc>:call C_CodeIfstream()<CR>f"a
	imenu  C&++.open\ output\ file            <Esc>:call C_CodeOfstream()<CR>f"a
	imenu  C&++.-SEP7-                        :
	imenu  C&++.&using\ namespace             using namespace ;<Esc>$i
	imenu  C&++.namespace                     <Esc>:let @z="namespace \n{\n\n}" <CR>"z]p<Esc>A
	imenu  C&++.-SEP8-                        :
		"
		"----- Submenu : RTTI  ----------------------------------------------------------------------------
		"
		imenu  C&++.&RTTI.&typeid               typeid()<Esc>F(a
		imenu  C&++.&RTTI.&static_cast          static_cast<>()<Esc>F<a
		imenu  C&++.&RTTI.&const_cast           const_cast<>()<Esc>F<a
		imenu  C&++.&RTTI.&reinterpret_cast     reinterpret_cast<>()<Esc>F<a
		imenu  C&++.&RTTI.&dynamic_cast         dynamic_cast<>()<Esc>F<a
	imenu  C&++.e&xtern\ \"C\"\ \{\ \}        <Esc>:call C_CodeExternC()<CR>2jf.i
	"
	"===============================================================================================
	"----- Menu : run  -----------------------------------------------------------------------------
	"===============================================================================================
	"
	amenu  C-&Run.save\ and\ &compile\ \ \<Alt\>\<F9\>  <C-C>:w<CR><Esc>:call C_Compile()<CR><C-C>:cwin<CR>
	amenu  C-&Run.&link\ \ \<F9\>                       <C-C>:call C_Link()<CR><C-C>:cwin<CR>
	amenu  C-&Run.&run\ \ \<Ctrl\>\<F9\>                <C-C>:call C_Run(0)<CR><C-C>:cwin<CR>
	amenu  C-&Run.run\ with\ &pager                     <C-C>:call C_Run(1)<CR><C-C>:cwin<CR>
	amenu  C-&Run.command\ line\ &arguments             <C-C>:call C_Arguments()<CR>
	amenu  C-&Run.&make\ \ \<Shift\>\<F9\>              <C-C>:make<CR>
	imenu  C-&Run.-SEP1-                                :
	amenu  C-&Run.a&bout\ C/C++-Support                 <C-C>:call C_Version()<CR>
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
function! C_CommentFrame ()
  let @z=   "//----------------------------------------------------------------------\n"
  let @z=@z."//  \n"
  let @z=@z."//----------------------------------------------------------------------\n"
  put z
endfunction
"
"------------------------------------------------------------------------------
"  C-Comments : function
"------------------------------------------------------------------------------
function! C_CommentFunction ()
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
  let @z= @z."//#   Author:  ".s:C_AuthorName."\n"
  let @z= @z."//#  Created:  ".strftime("%x")."\n"
  let @z= @z."//# Revision:  none\n"
  let @z= @z."//#=====================================================================================\n"
  put z
endfunction
"
"------------------------------------------------------------------------------
"  C-Comments : main
"------------------------------------------------------------------------------
function! C_CommentMain ()
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
  let @z= @z."//#   Author:  ".s:C_AuthorName."\n"
  let @z= @z."//#  Created:  ".strftime("%x")."\n"
  let @z= @z."//# Revision:  none\n"
  let @z= @z."//#=====================================================================================\n"
  put z
endfunction
"
"------------------------------------------------------------------------------
"  C-Comments : file prologue
"------------------------------------------------------------------------------
function! C_CommentFilePrologue ()

    let @z=      "//#====================================================================================="
    let @z= @z."\n//#"
    let @z= @z."\n//#       Filename:  ".expand("%:t")
    let @z= @z."\n//#"
    let @z= @z."\n//#    Description:  "
    let @z= @z."\n//#"
"    let @z= @z."\n//#          Usage:  ./".expand("%:t:r").".e "
"    let @z= @z."\n//#"
    let @z= @z."\n//#        Version:  1.0"
    let @z= @z."\n//#        Created:  ".strftime("%x")
    let @z= @z."\n//#       Revision:  none"
  if(s:C_Compiler!="")
    let @z= @z."\n//#       Compiler:  ".s:C_Compiler
  endif
    let @z= @z."\n//#"
    let @z= @z."\n//#         Author:  ".s:C_AuthorName
  if(s:C_AuthorRef!="")
    let @z= @z."  (".s:C_AuthorRef.")"
  endif
  if(s:C_Company!="")
    let @z= @z."\n//#        Company:  ".s:C_Company
  endif
  if(s:C_Email!="")
    let @z= @z."\n//#          Email:  ".s:C_Email
  endif
  if(s:C_CopyrightHolder!="")
    let @z= @z.  "\n//#      Copyright:  ".s:C_CopyrightHolder
    if(s:C_CopyrightYears=="")
      let @z= @z. " , ". strftime("%Y")
    else
      let @z= @z. " , ". s:C_CopyrightYears
    endif
  endif
  if(s:C_Project!="")
    let @z= @z."\n//#"
    let @z= @z."\n//#        Project:  ".s:C_Project
  endif
    let @z= @z."\n//#"
    let @z= @z."\n//#=====================================================================================\n\n"

    put! z
endfunction
"
"------------------------------------------------------------------------------
"  C-Comments : classified comments
"------------------------------------------------------------------------------
function! C_CommentClassified (class)
  	put = '	// :'.a:class.':'.strftime(\"%x\").':'.s:C_AuthorRef.': '
endfunction
"
"------------------------------------------------------------------------------
"  C-Comments : Section Comments
"------------------------------------------------------------------------------
"
function! C_CommentSection (keyword)
  let @z=   "// #####   ".a:keyword."   "
	let	n = 74-strlen(a:keyword)
	while n>0
		let @z = @z."#"
		let	n = n-1
	endwhile
  let @z= @z."\n\n"
  put z | +1
endfunction
"
"------------------------------------------------------------------------------
"  C-Comments : Section Comments
"------------------------------------------------------------------------------
"
function! C_Comment_C_SectionAll1 ()
	call C_CommentSection("HEADER FILE INCLUDES")
  call C_CommentSection("MACROS  -  LOCAL TO THIS SOURCE FILE")
  call C_CommentSection("DATA TYPES  -  LOCAL TO THIS SOURCE FILE")
  call C_CommentSection("TYPE DEFINITIONS  -  LOCAL TO THIS SOURCE FILE")
  call C_CommentSection("VARIABLES  -  LOCAL TO THIS SOURCE FILE")
  call C_CommentSection("PROTOTYPES  -  LOCAL TO THIS SOURCE FILE")
	call C_CommentSection("FUNCTION DEFINITIONS  -  EXPORTED FUNCTIONS")
	call C_CommentSection("FUNCTION DEFINITIONS  -  LOCAL TO THIS SOURCE FILE")
endfunction
"
function! C_Comment_C_SectionAll2 ()
	call C_Comment_C_SectionAll1()
	call C_CommentSection("CLASS DEFINITIONS  -  LOCAL TO THIS SOURCE FILE")
	call C_CommentSection("CLASS IMPLEMENTATIONS  -  EXPORTED CLASSES")
	call C_CommentSection("CLASS IMPLEMENTATIONS  -  LOCAL CLASSES")
endfunction
"
function! C_Comment_H_SectionAll1 ()
	call C_CommentSection("HEADER FILE INCLUDES")
  call C_CommentSection("EXPORTED MACROS")
  call C_CommentSection("EXPORTED DATA TYPES")
  call C_CommentSection("EXPORTED TYPE DEFINITIONS")
  call C_CommentSection("EXPORTED VARIABLES") 
  call C_CommentSection("EXPORTED FUNCTION DECLARATIONS")
endfunction
"
function! C_Comment_H_SectionAll2 ()
	call C_Comment_H_SectionAll1()
	call C_CommentSection("EXPORTED CLASS DEFINITIONS")
endfunction
"
"=====================================================================================
"----- Menu : Statements -----------------------------------------------------------
"=====================================================================================
"
"------------------------------------------------------------------------------
"  Statements : do-while
"------------------------------------------------------------------------------
"
function! C_DoWhile ()
	let @z=    "do\n{\n\t\n}\nwhile (  );"
  let @z= @z."\t\t\t\t// -----  end do-while  -----\n"
endfunction
"
"------------------------------------------------------------------------------
"  Statements : switch
"  Statements : case
"------------------------------------------------------------------------------
"
let s:C_CaseStatement = "\tcase :\t\n\t\tbreak;\n\n"
"
function! C_CodeSwitch ()
  let @z= "switch (  )\n{\n\n"
	
	let loopcount=4                   " default number of cases
	while loopcount>0
    let @z= @z.s:C_CaseStatement
	  let loopcount=loopcount-1
	endwhile
	
	let @z= @z."\tdefault:\t\n\t\tbreak;\n}"
  let @z= @z."\t\t\t\t// -----  end switch  -----\n"
endfunction
"
function! C_CodeCase ()
    let @z= s:C_CaseStatement
endfunction
"
"------------------------------------------------------------------------------
"  Statements : #if .. #else .. #endif 
"  Statements : #ifdef .. #else .. #endif 
"  Statements : #ifndef .. #else .. #endif 
"------------------------------------------------------------------------------
function! C_PPIfElse (keyword)
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
function! C_PPIfDef ()
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
function! C_CodeFor (counter)
  let @z=    "for ( ".a:counter."=0; ".a:counter."<n; ".a:counter."++ )\n"
  put z
	endfunction
"
"------------------------------------------------------------------------------
"  C-Idioms : function
"------------------------------------------------------------------------------
function! C_CodeFunction ()
	let	identifier=inputdialog("function name", "f" )
	if identifier != ""
		let @z=    "void\n".identifier."\t(  )\n{\n\treturn ;\n}"
		let @z= @z."\t\t\t\t// ----------  end of function ".identifier."  ----------"
		put z
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C-Idioms : main
"------------------------------------------------------------------------------
function! C_CodeMain ()
  let @z=    "int\nmain ( int argc, char *argv[] )\n{\n\t\n"
	let @z= @z."\treturn 0;\n}"
  let @z= @z."\t\t\t\t// ----------  end of function main  ----------"
  put z
	endfunction
"
"------------------------------------------------------------------------------
"  C++ : class comment
"------------------------------------------------------------------------------
function! C_CommentClass ()
  let @z=   "//#=====================================================================================\n"
  let @z=@z."//#       Class:  ".s:C_ClassName."\n"
  let @z=@z."//#\n"
  let @z=@z."//# Description:  \n"
  let @z=@z."//#\n"
  let @z=@z."//#      Author:  ".s:C_AuthorName."\n"
  let @z=@z."//#     Created:  ".strftime("%x")."\n"
  let @z=@z."//#    Revision:  none\n"
  let @z=@z."//#=====================================================================================\n"
  put z
endfunction
"
"------------------------------------------------------------------------------
"  C++ : method comment
"------------------------------------------------------------------------------
function! C_CommentMethod ()
  let @z=   "//--------------------------------------------------------------------------------------\n"
  let @z=@z."//       Class:  ".s:C_ClassName."\n"
  let @z=@z."//      Method:  \n"
  let @z=@z."// Description:  \n"
  let @z=@z."//--------------------------------------------------------------------------------------\n"
  put z
endfunction
"
function! C_CommentClearClassNmae ()
	let	s:C_ClassName=""
endfunction
"
"------------------------------------------------------------------------------
"  C++ : method
"------------------------------------------------------------------------------
function! C_CodeMethod()
	let	identifier=inputdialog("method name", s:C_ClassName."::" )
	if identifier != ""
		let @z=    "void\n".identifier."\t(  )\n{\n\n\n\treturn ;\n}"
		let @z= @z."\t\t\t\t// ----------  end of method ".identifier."  ----------"
		put z
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C++ : class
"------------------------------------------------------------------------------
function! C_CodeClass()
	let	s:C_ClassName=inputdialog("name of class", "Cls" )
	if s:C_ClassName != ""
		let @z=    "class ".s:C_ClassName
		let @z= @z."\n{\n\n\tpublic:\n\n"
		let @z= @z."\t\t// ====================  LIFECYCLE   =========================================\n\n"
		let @z= @z."\t\t".s:C_ClassName." ();\t// constructor\n\n"	
		let @z= @z."\t\t// Use compiler-generated copy constructor, assignment operator and destructor\n\n"	
		let @z= @z."\t\t// ====================  OPERATORS   =========================================\n\n"
		let @z= @z."\t\t// ====================  OPERATIONS  =========================================\n\n"
		let @z= @z."\t\t// ====================  ACCESS      =========================================\n\n"
		let @z= @z."\t\t// ====================  INQUIRY     =========================================\n\n"
		let @z= @z."\t\t// ====================  NESTED ERROR CLASSES  ===============================\n\n\n"
		let @z= @z."\tprotected:\n\n"
		let @z= @z."\tprivate:\n\n"
		let @z= @z."\n};\t\t\t// ----------  end of class  ".s:C_ClassName."  ----------\n"
		let @z= @z."\n\n".s:C_ClassName."::".s:C_ClassName." ()\n{\n}"
		let @z= @z."\t\t\t\t// ----------  end of method ".s:C_ClassName."::".s:C_ClassName."  (constructor)  ----------\n"
		put z
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C++ : class using the new operator
"------------------------------------------------------------------------------
function! C_CodeClassNew ()
	let	s:C_ClassName=inputdialog("name of class using new", "ClsN" )
	if s:C_ClassName != ""
		let	tabs = ""
		let	n = (strlen(s:C_ClassName)-1)/2				" number of extra tabs 
		while n>0
			let tabs = tabs."\t"
			let	n = n-1
		endwhile
		let @z=    "class ".s:C_ClassName
		let @z= @z."\n{\n\n\tpublic:\n\n"
		let @z= @z."\t\t// ====================  LIFECYCLE   =========================================\n\n"
		let @z= @z."\t\t".s:C_ClassName." ();\t\t\t\t\t\t\t".tabs."// constructor\n"	
		let @z= @z."\t\t".s:C_ClassName." (const ".s:C_ClassName." &obj);\t// copy constructor\n"	
		let @z= @z."\t\t~".s:C_ClassName." (); \t\t\t\t\t\t".tabs."// destructor\n\n"
		let @z= @z."\t\t// ====================  OPERATORS   =========================================\n\n"
		let @z= @z."\t\tconst ".s:C_ClassName."& operator = (const ".s:C_ClassName." &obj);"
		let @z= @z."\t\t// assignemnt operator\n\n"
		let @z= @z."\t\t// ====================  OPERATIONS  =========================================\n\n"
		let @z= @z."\t\t// ====================  ACCESS      =========================================\n\n"
		let @z= @z."\t\t// ====================  INQUIRY     =========================================\n\n"
		let @z= @z."\t\t// ====================  NESTED ERROR CLASSES  ===============================\n\n\n"
		let @z= @z."\tprotected:\n\n"
		let @z= @z."\tprivate:\n\n"
		let @z= @z."\n};\t\t\t// ----------  end of class  ".s:C_ClassName."  ----------\n"


		let @z= @z."\n\n".s:C_ClassName."::".s:C_ClassName." ()\n{\n}"
		let @z= @z."\t\t\t\t// ----------  end of method ".s:C_ClassName."::".s:C_ClassName."  (constructor)  ----------\n"

		let @z= @z."\n\n".s:C_ClassName."::".s:C_ClassName." (const ".s:C_ClassName." &obj)\n{\n}"
		let @z= @z."\t\t\t\t// ----------  end of method ".s:C_ClassName."::".s:C_ClassName."  (copy constructor)  ----------\n"
	
		let @z= @z."\n\n".s:C_ClassName."::~".s:C_ClassName." ()\n{\n}"
		let @z= @z."\t\t\t\t// ----------  end of method ".s:C_ClassName."::~".s:C_ClassName."  (destructor)  ----------\n"
		
		let @z= @z."\n\nconst ".s:C_ClassName."&\n".s:C_ClassName."::operator = (const ".s:C_ClassName." &obj)"
		let @z= @z."\n{\n\tif(this!=&obj)\n\t{\n\n\t}\n\treturn *this;\n}"	
		let @z= @z."\t\t\t\t// ----------  end of method ".s:C_ClassName."::operator =  (assignment operator)  ----------\n"
		put z
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C++ : simple error class
"------------------------------------------------------------------------------
function! C_CodeErrorClass()
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
function! C_CodeTemplateClass ()
	let	classname=inputdialog("name of template class", "TCls" )
	if classname != ""
		let @z=    "template < class T >\nclass ".classname
		let @z= @z."\n{\n\n\tpublic:\n\n"
		let @z= @z."\t\t// ====================  LIFECYCLE   =========================================\n\n"
		let @z= @z."\t\t".classname." (); \t// constructor\n\n"	
		let @z= @z."\t\t// Use compiler-generated copy constructor, assignment operator and destructor\n\n"	
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
function! C_CodeTemplateClassNew ()
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
		let @z= @z."\t\t// assignment operator\n\n"
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
		let @z= @z."\t\t\t\t// ----------  end of assignment operator of template class ".classname."  ----------\n"
		put z
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C++ : template function
"------------------------------------------------------------------------------
function! C_CodeTemplateFunct ()
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
function! C_EST (su)
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
function! C_CodeMalloc ()
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
function! C_CodeFopenRead ()
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
function! C_CodeFopenWrite ()
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
function! C_CodeIfstream ()
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
function! C_CodeOfstream ()
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
function! C_CodeExternC()
	let @z=    "extern \"C\"\n{\n\t#include\t\".h\"\n}"
	put z
endfunction
"
"------------------------------------------------------------------------------
"  C++ : output operator
"------------------------------------------------------------------------------
function! C_CodeOutputOperator ()
	let	identifier=inputdialog("class name", s:C_ClassName )
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
function! C_CodeInputOperator ()
	let	identifier=inputdialog("class name", s:C_ClassName )
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
function! C_CodeTryCatch ()
  let @z=    "try\n{\n\t\n}\n"
  let @z= @z."catch (const  &ExceptObj)\t\t// handle exception: \n{\n\t\n}\n"
  let @z= @z."catch (...)\t\t\t// handle exception: unspezified\n{\n\t\n}"
	put z
endfunction
"
"------------------------------------------------------------------------------
"  C++ : catch
"------------------------------------------------------------------------------
function! C_CodeCatch ()
  let @z=    "catch (const  &ExceptObj)\t\t// handle exception: \n{\n\t\n}\n"
	put z
endfunction
""------------------------------------------------------------------------------
"  run : C_Compile
"------------------------------------------------------------------------------
"  The standard make program 'make' called by vim is set to the C or C++ compiler
"  and reset after the compilation  (set makeprg=... ).
"  The errorfile created by the compiler will now be read by gvim and
"  the commands cl, cp, cn, ... can be used.
"
"
"------------------------------------------------------------------------------
function! C_Compile ()

	let	Sou		= expand("%")								" name of the file in the current buffer
	let	Obj		= expand("%:r").".o"				" name of the object
	let	Ext		= expand("%:e")							" file extension

	" update : write source file if necessary
	exe	":update"
	
	" compilation if object does not exist or object exists and is older then the source	
	if !filereadable(Obj) || (filereadable(Obj) && (getftime(Obj) < getftime(Sou)))
		
		if Ext == s:C_CExtension
			exe		"set makeprg=".s:C_CCompiler
		else
			exe		"set makeprg=".s:C_CplusCompiler
		endif

		" COMPILATION
		exe		"make ".s:C_CFlags." ".Sou." -o ".Obj		
		
		exe		"set makeprg=make"
	endif
	
endfunction
"
"------------------------------------------------------------------------------
"  run : C_Link
"------------------------------------------------------------------------------
"  The standard make program which is used by gvim is set to the compiler
"  (for linking) and reset after linking.
"
"  calls: C_Compile
"------------------------------------------------------------------------------
function! C_Link ()

	call	C_Compile()

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
	
		if Ext == s:C_CExtension
			exe		"set makeprg=".s:C_CCompiler
		else
			exe		"set makeprg=".s:C_CplusCompiler
		endif
		exe		"make ".s:C_LFlags." ".s:C_Libs." -o ".Exe." ".Obj
		exe		"set makeprg=make"

	endif

endfunction
"
"------------------------------------------------------------------------------
"  run : 	C_Run
"
"  calls: C_Link
"------------------------------------------------------------------------------
function! C_Run (arg1)

	let	Sou		= expand("%")										" name of the source file
	let	Obj		= expand("%:r").".o"						" name of the object file
	let	Exe		= expand("%:r").".e"						" name of the executable

	call	C_Link()													" compile+link the file in the current buffer
	
	" exe exists and is newer then the object, the object is newer then the source
	" this prevents an old executable from running in the case of compilation or link errors
	
	if filereadable(Exe) && getftime(Exe) >= getftime(Obj) && getftime(Obj) >= getftime(Sou)
		if a:arg1==0
			exe		"!./".Exe." ".s:C_CmdLineArgs
		else
			exe		"!./".Exe." ".s:C_CmdLineArgs." | ".s:C_Pager
		endif
	endif
	
endfunction
"
"------------------------------------------------------------------------------
"  run : Arguments
"------------------------------------------------------------------------------
function! C_Arguments ()
	let	s:C_CmdLineArgs= inputdialog("command line arguments",s:C_CmdLineArgs)
endfunction
"
"
"------------------------------------------------------------------------------
"  run : about
"------------------------------------------------------------------------------
function! C_Version ()
	let dummy=confirm("C/C++-Support, Version ".s:C_Version."\nDr. Fritz Mehner\nmehner@fh-swf.de", "ok" )
endfunction
"
"------------------------------------------------------------------------------
"  c : C_CreateUnLoadMenuEntries
"	 Create the load/unload entry in the GVIM tool menu, depending on 
"	 which script is already loaded.
"  Author: M.Faulstich
"------------------------------------------------------------------------------
"
let s:C_Active = -1									" state variable controlling the C-menus
"
function! C_CreateUnLoadMenuEntries ()
"
	" C is now active and was former inactive -> 
	" Insert Tools.Unload and remove Tools.Load Menu
	if  s:C_Active == 1
		aunmenu Tools.Load\ C\ Support
		amenu   &Tools.Unload\ C\ Support  	<C-C>:call C_Handle()<CR>
	else
		" C is now inactive and was former active or in initial state -1 
		if s:C_Active == 0
			" Remove Tools.Unload if C was former inactive
			aunmenu Tools.Unload\ C\ Support
		else
			" Set initial state C_Active=-1 to inactive state C_Active=0
			" This protects from removing Tools.Unload during initialization after
			" loading this script
			let s:C_Active = 0
			" Insert Tools.Load
		endif
		amenu &Tools.Load\ C\ Support <C-C>:call C_Handle()<CR>
	endif
	"
"
endfunction
"
"------------------------------------------------------------------------------
"  C : C_Handle
"  Loads or unloads C support menus.
"  Author: M.Faulstich
"------------------------------------------------------------------------------
function! C_Handle ()
	if s:C_Active == 0
		:call C_InitC()
		let s:C_Active = 1
	else
		aunmenu Comments
		aunmenu C-Statements
		aunmenu C-Idioms
		aunmenu C++
		aunmenu C-Run
		let s:C_Active = 0
	endif
	
	call C_CreateUnLoadMenuEntries ()
endfunction
"
"------------------------------------------------------------------------------
" 
call C_CreateUnLoadMenuEntries()			" create the menu entry in the GVIM tool menu
if s:C_ShowMenues == "yes"
	call C_Handle()											" load the menus
endif
"=====================================================================================

