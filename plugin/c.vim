"###############################################################################################
"
"     Filename:  c.vim
"
"  Description:  Write C/C++ programs by inserting complete statements, idioms and comments. 
"                Compile, link and run one-file-programs without a makefile (simple IDE).
"                
"                Code and comments should have a professional appearance and should be
"                easy to write and maintain. 
"                Programs with a consistent style are easier to read and understand.
"                The standardization of comments makes it possible to automate the search
"                for information and to generate documentation from the source code.
"
" GVIM Version:  6.0+
"
"        Usage:  (1) Configure  c.vim  (Your name, Email, ... / see section Configuration below).
"        
"                (2) Move this file to the directory  $HOME/.vim/plugin/
"                
"                c.vim inserts an additional menu entry into the Tools-menu for
"                loading/unloading the menus of this plugin.
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
let s:C_Version = "3.0"              " version number of this script; do not change
"
"       Author:  Dr.-Ing. Fritz Mehner, FH S¸dwestfalen, 58644 Iserlohn, Germany
"        Email:  mehner@fh-swf.de
"
"     Revision:  26.04.2003
"      Created:  04.11.2000
"      
"    Copyright:  Copyright (C) 2000-2003 Dr.-Ing. Fritz Mehner
"               
"                This program is free software; you can redistribute it and/or modify
"                it under the terms of the GNU General Public License as published by
"                the Free Software Foundation; either version 2 of the License, or
"                (at your option) any later version.
"               
"##########################################################################################
"
"  Configuration  (Use my configuration as an example)
"
"------------------------------------------------------------------------------------------
"   c.vim-variable         value                                           tag
"------------------------------------------------------------------------------------------
let s:C_AuthorName      = ""                                            " |AUTHOR|
let s:C_AuthorRef       = ""                                            " |AUTHORREF|
let s:C_Email           = ""                                            " |EMAIL|
let s:C_Company         = ""                                            " |COMPANY|   
let s:C_Project         = ""                                            " |PROJECT|
let s:C_CopyrightHolder = ""                                            " |COPYRIGHTHOLDER|
"
"  Copyright information. If the code has been developed over a period of years, 
"  each year must be stated. In a template file use a fixed year in the first position :
"  
"    '//    Copyright (C) 1998-|YEAR|  |COPYRIGHTHOLDER|'
"
"
"##########################################################################################
"
"  Global Variables : Compiler, Options, Libraries, ...
"
let s:C_CExtension    = "c"                    " C file extension; everything else is C++
let s:C_CCompiler     = "gcc"                  " the C   compiler
let s:C_CplusCompiler = "g++"                  " the C++ compiler
let s:C_CFlags        = "-Wall -g -O0 -c"      " compiler flags: compile, don't optimize
let s:C_LFlags        = "-Wall -g -O0"         " compiler flags: link   , don't optimize
let s:C_Libs          = "-lm"                  " libraries to use
"
"
" The menu entry 'C-Run -> run with pager' will not appear if the following string is empty 
"
let s:C_Pager         = "less"
"
"                                       
" The menu entries for code snippet support will not appear if the following string is empty 
" (don't forget to create the directory if you want to use it)
"
let s:C_CodeSnippets = $HOME."/.vim/codesnippets-c/"
"
"
" Show C-menues immediately after loading this plugin (yes/no)
" 
let s:C_ShowMenues    = "yes"
"
"
" ---------- C/C++  template files --------------------------------------------------------
"
" Style of the one-line comments when this plugin is loaded:
"
let s:C_Comments  = "yes"
" 
"   yes  :  C-style comments:       /* ... */  
"   
"   no   :  C++-style comments:     //...
"   
" The style can be toggled with menu entry 'Comments -> Comments style ...'.
" The style of the multi-line comments has to be changed in the template files:
"
"  
let s:C_Template_Directory    = $HOME."/.vim/plugin/templates/"
"                           
"                             ----- C template files ---- ( 1. set of templates ) ----
"                             
let s:C_Template_C_File       = "c-file-header"
let s:C_Template_Class        = "c-class-description"
let s:C_Template_Frame        = "c-frame"
let s:C_Template_Function     = "c-function-description"
let s:C_Template_H_File       = "h-file-header"
let s:C_Template_Method       = "c-method-description"
"
"                             ----- C++ template files -- ( 2. set of templates ) ----
"                             ----- If this set is empty the toggle will not appear. -
"  
let s:Cpp_Template_C_File     = "cpp-file-header"
let s:Cpp_Template_Class      = "cpp-class-description"
let s:Cpp_Template_Frame      = "cpp-frame"
let s:Cpp_Template_Function   = "cpp-function-description"
let s:Cpp_Template_H_File     = "hpp-file-header"
let s:Cpp_Template_Method     = "cpp-method-description"
"
" -----------------------------------------------------------------------------------------
"  End of the configuration section  ------------------------------------------------------
" -----------------------------------------------------------------------------------------
"
"###############################################################################################
"###############################################################################################
"
"  ... finally
"
"  Johann Wolfgang von Goethe (1749-1832), the greatest of the german men of letters,
"  about LINUX, Vim/gVim and other great tools (Ok, almost.) :
"
"    Ein Mann, der recht zu wirken denkt,         Who on efficient work is bent, 
"    Muﬂ auf das beste Werkzeug halten.           Must choose the fittest instrument.  
"
"  Faust, Teil 1, Vorspiel auf dem Theater      Faust, Part 1, Prologue for the Theatre 
"
"###############################################################################################
"
"----- some variables for internal use only -----------------------------------
"
let s:C_ExeCmdLineArgs  = ""       " command line arguments for Run-run; initially empty
let s:C_MakeCmdLineArgs = ""       " command line arguments for Run-make; initially empty
let s:C_ClassName       = ""       " remember class name ; initially empty

if s:C_Comments=="yes"
	let s:C_Com1            = '/*'     " C-style : comment start 
	let s:C_Com2            = '*/'     " C-style : comment end
else
	let s:C_Com1            = '//'     " C++style : comment start 
	let s:C_Com2            = ''       " C++style : comment end
endif
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
	"-----------------------------------------------------------------------------------------------
	"   Alt-F9   write buffer and compile
	"       F9   compile and link
	"  Ctrl-F9   run executable
	" Shift-F9   run make
	"
	map  <silent> <A-F9>  :call C_Compile()<CR><CR>
	map  <silent> <F9>    :call C_Link()   <CR><CR>
	map  <silent> <C-F9>  :call C_Run(0)   <CR><CR>
	map  <silent> <S-F9>  :call C_Make()<CR>
	"
  imap <silent>  <A-F9>  <Esc>:call C_Compile()<CR><CR>
  imap <silent>  <F9>    <Esc>:call C_Link()   <CR><CR>
  imap <silent>  <C-F9>  <Esc>:call C_Run(0)   <CR><CR>
  imap <silent>  <S-F9>  <Esc>:call C_Make()<CR>
	"
	"
	"----- The following two maps are only used for the developement of this plugin ----------------
	"
"	  noremap  <F12>       :write<CR><Esc>:so %<CR><Esc>:call C_Handle()<CR><Esc>:call C_Handle()<CR>
"  inoremap  <F12>  <Esc>:write<CR><Esc>:so %<CR><Esc>:call C_Handle()<CR><Esc>:call C_Handle()<CR>
	"
	"===============================================================================================
	"----- Menu : C-Comments -----------------------------------------------------------------------
	"===============================================================================================
	"
	amenu  &Comments.&Line\ End\ Comment\ \/\/         <Esc><Esc>A<Tab><Tab>//<Space>
	amenu  &Comments.L&ine\ End\ Comment\ \/**\/       <Esc><Esc>A<Tab><Tab>/*  */<Esc>2hi
	
	amenu  &Comments.M&ultiline\ Comment\ \/*\ *\ *\/  <Esc><Esc>o/*<CR><CR>/<Esc>:normal =2-<CR>j$a<Space>
	amenu  &Comments.-SEP0-                     :
	amenu  <silent>  &Comments.&Frame\ Block           <Esc><Esc>:call C_CommentTemplates('frame')<CR>
	amenu  <silent>  &Comments.Function\ Descri&ption  <Esc><Esc>:call C_CommentTemplates('function')<CR>
	amenu  &Comments.-SEP1-                     :
	amenu  <silent>  &Comments.&Method\ Description    <Esc><Esc>:call C_CommentTemplates('method')<CR>
	amenu  <silent>  &Comments.Cl&ass\ Description     <Esc><Esc>:call C_CommentTemplates('class')<CR>
	amenu  &Comments.-SEP2-                     :
	amenu  <silent> &Comments.C\/C\+\+-file\ header    <Esc><Esc>:call C_CommentTemplates('cheader')<CR>
	amenu  <silent> &Comments.H-file\ header           <Esc><Esc>:call C_CommentTemplates('hheader')<CR>
	amenu  &Comments.-SEP3-                     :
		"
		"----- Submenu : C-Comments : file sections  -------------------------------------------------------------
		"
		amenu  &Comments.&C\/C\+\+-File\ Sections.&Header\ File\ Includes  
					\<Esc><Esc>:call C_CommentSection("HEADER FILE INCLUDES")<CR>0i
		amenu  &Comments.&C\/C\+\+-File\ Sections.Local\ &Macros           
					\<Esc><Esc>:call C_CommentSection("MACROS  -  LOCAL TO THIS SOURCE FILE")<CR>0i
		amenu  &Comments.&C\/C\+\+-File\ Sections.Local\ &Type\ Def\.      
					\<Esc><Esc>:call C_CommentSection("TYPE DEFINITIONS  -  LOCAL TO THIS SOURCE FILE")<CR>0i
		amenu  &Comments.&C\/C\+\+-File\ Sections.Local\ &Data\ Types      
					\<Esc><Esc>:call C_CommentSection("DATA TYPES  -  LOCAL TO THIS SOURCE FILE")<CR>0i
		amenu  &Comments.&C\/C\+\+-File\ Sections.Local\ &Variables        
					\<Esc><Esc>:call C_CommentSection("VARIABLES  -  LOCAL TO THIS SOURCE FILE")<CR>0i
		amenu  &Comments.&C\/C\+\+-File\ Sections.Local\ &Prototypes       
					\<Esc><Esc>:call C_CommentSection("PROTOTYPES  -  LOCAL TO THIS SOURCE FILE")<CR>0i
		amenu  &Comments.&C\/C\+\+-File\ Sections.&Exp\.\ Function\ Def\.  
					\<Esc><Esc>:call C_CommentSection("FUNCTION DEFINITIONS  -  EXPORTED FUNCTIONS")<CR>0i
		amenu  &Comments.&C\/C\+\+-File\ Sections.&Local\ Function\ Def\.  
					\<Esc><Esc>:call C_CommentSection("FUNCTION DEFINITIONS  -  LOCAL TO THIS SOURCE FILE")<CR>0i
		amenu  &Comments.&C\/C\+\+-File\ Sections.-SEP6-                   :
		amenu  &Comments.&C\/C\+\+-File\ Sections.Local\ &Class\ Def\.     
					\<Esc><Esc>:call C_CommentSection("CLASS DEFINITIONS  -  LOCAL TO THIS SOURCE FILE")<CR>0i
		amenu  &Comments.&C\/C\+\+-File\ Sections.E&xp\.\ Class\ Impl\.    
					\<Esc><Esc>:call C_CommentSection("CLASS IMPLEMENTATIONS  -  EXPORTED CLASSES")<CR>0i
		amenu  &Comments.&C\/C\+\+-File\ Sections.L&ocal\ Class\ Impl\.    
					\<Esc><Esc>:call C_CommentSection("CLASS IMPLEMENTATIONS  -  LOCAL CLASSES")<CR>0i
		amenu  &Comments.&C\/C\+\+-File\ Sections.-SEP7-                   :
		amenu  &Comments.&C\/C\+\+-File\ Sections.&All\ Sections,\ C       
					\<Esc><Esc>:call C_Comment_C_SectionAll1()<CR>0i
		amenu  &Comments.&C\/C\+\+-File\ Sections.All\ &Sections,\ C++     
					\<Esc><Esc>:call C_Comment_C_SectionAll2()<CR>0i
		"
		"
		"----- Submenu : H-Comments : file sections  -------------------------------------------------------------
		"
		amenu  &Comments.&H-File\ Sections.&Header\ File\ Includes    
					\<Esc><Esc>:call C_CommentSection("HEADER FILE INCLUDES")<CR>0i
		amenu  &Comments.&H-File\ Sections.Exported\ &Macros          
					\<Esc><Esc>:call C_CommentSection("EXPORTED MACROS")<CR>0i
		amenu  &Comments.&H-File\ Sections.Exported\ &Type\ Def\.     
					\<Esc><Esc>:call C_CommentSection("EXPORTED TYPE DEFINITIONS")<CR>0i
		amenu  &Comments.&H-File\ Sections.Exported\ &Data\ Types     
					\<Esc><Esc>:call C_CommentSection("EXPORTED DATA TYPES")<CR>0i
		amenu  &Comments.&H-File\ Sections.Exported\ &Variables       
					\<Esc><Esc>:call C_CommentSection("EXPORTED VARIABLES")<CR>0i
		amenu  &Comments.&H-File\ Sections.Exported\ &Funct\.\ Decl\. 
					\<Esc><Esc>:call C_CommentSection("EXPORTED FUNCTION DECLARATIONS")<CR>0i
		amenu  &Comments.&H-File\ Sections.-SEP4-                     :
		amenu  &Comments.&H-File\ Sections.E&xported\ Class\ Def\.    
					\<Esc><Esc>:call C_CommentSection("EXPORTED CLASS DEFINITIONS")<CR>0i
		amenu  &Comments.&H-File\ Sections.-SEP5-                     :
		amenu  &Comments.&H-File\ Sections.&All\ Sections,\ C         
					\<Esc><Esc>:call C_Comment_H_SectionAll1()<CR>0i
		amenu  &Comments.&H-File\ Sections.All\ &Sections,\ C++       
					\<Esc><Esc>:call C_Comment_H_SectionAll2()<CR>0i
"		amenu  &Comments.s&ection\ (no\ name)  					<Esc><Esc>:call C_CommentSection("")<CR>k2f 6r#0ji
		"
		amenu  &Comments.-SEP8-                        :
		"
		"----- Submenu : C-Comments : keyword comments  ----------------------------------------------------------
		"
		amenu  &Comments.&KEYWORD+Comm\..\:&BUG\:          <Esc><Esc>$<Esc>:call C_CommentClassified("BUG")     <CR>kgJ$F:la
		amenu  &Comments.&KEYWORD+Comm\..\:&COMPILER\:     <Esc><Esc>$<Esc>:call C_CommentClassified("COMPILER")<CR>kgJ$F:la
		amenu  &Comments.&KEYWORD+Comm\..\:&TODO\:         <Esc><Esc>$<Esc>:call C_CommentClassified("TODO")    <CR>kgJ$F:la
		amenu  &Comments.&KEYWORD+Comm\..\:T&RICKY\:       <Esc><Esc>$<Esc>:call C_CommentClassified("TRICKY")  <CR>kgJ$F:la
		amenu  &Comments.&KEYWORD+Comm\..\:&WARNING\:      <Esc><Esc>$<Esc>:call C_CommentClassified("WARNING") <CR>kgJ$F:la
		amenu  &Comments.&KEYWORD+Comm\..\:&new\ keyword\: <Esc><Esc>$<Esc>:call C_CommentClassified("")        <CR>kgJf:a
		"
		"----- Submenu : C-Comments : special comments  ----------------------------------------------------------
		"
		amenu  &Comments.&special\ Comm\..&EMPTY                <Esc><Esc>$<Esc>:call C_CommentSpecial("EMPTY")                    <CR>kgJA
		amenu  &Comments.&special\ Comm\..&FALL\ THROUGH        <Esc><Esc>$<Esc>:call C_CommentSpecial("FALL THROUGH")             <CR>kgJA
		amenu  &Comments.&special\ Comm\..&IMPL\.\ TYPE\ CONV   <Esc><Esc>$<Esc>:call C_CommentSpecial("IMPLICIT TYPE CONVERSION") <CR>kgJA
		amenu  &Comments.&special\ Comm\..&NOT\ REACHED\        <Esc><Esc>$<Esc>:call C_CommentSpecial("NOT REACHED")              <CR>kgJA
		amenu  &Comments.&special\ Comm\..&TO\ BE\ IMPL\.       <Esc><Esc>$<Esc>:call C_CommentSpecial("REMAINS TO BE IMPLEMENTED")<CR>kgJA
		amenu  &Comments.&special\ Comm\..-SEP81-                        :
		amenu  &Comments.&special\ Comm\..constant\ type\ is\ &long\ (L)              <Esc><Esc>$<Esc>:call C_CommentSpecial("constant type is long")<CR>kgJA
		amenu  &Comments.&special\ Comm\..constant\ type\ is\ &unsigned\ (U)          <Esc><Esc>$<Esc>:call C_CommentSpecial("constant type is unsigned")<CR>kgJA
		amenu  &Comments.&special\ Comm\..constant\ type\ is\ unsigned\ l&ong\ (UL)   <Esc><Esc>$<Esc>:call C_CommentSpecial("constant type is unsigned long")<CR>kgJA

		"
		amenu  &Comments.-SEP9-                     :
		"
		 menu  &Comments.&Date                      a<C-R>=strftime("%x")<CR>
	  imenu  &Comments.&Date                       <C-R>=strftime("%x")<CR>
		 menu  &Comments.Date\ &Time                a<C-R>=strftime("%x %X %Z")<CR>
	  imenu  &Comments.Date\ &Time                 <C-R>=strftime("%x %X %Z")<CR>
		
		amenu  &Comments.-SEP10-                    :
		vmenu  <silent>  &Comments.code&->comment             <Esc><Esc>:'<,'>s/^/\/\//<CR><Esc>:nohlsearch<CR>
		vmenu  <silent>  &Comments.c&omment->code             <Esc><Esc>:'<,'>s/^\/\///<CR><Esc>:nohlsearch<CR>
		"
	  if			s:Cpp_Template_C_File     != "" || 
					\	s:Cpp_Template_Class      != "" || 
					\	s:Cpp_Template_Frame      != "" || 
					\	s:Cpp_Template_Function   != "" || 
					\	s:Cpp_Template_H_File     != "" || 
					\	s:Cpp_Template_Method     != "" 

			amenu  &Comments.-SEP11-                    :
			amenu  &Comments.&vim\ modeline                               <Esc><Esc>:call C_CommentVimModeline()<CR>
			amenu  &Comments.-SEP12-                    :
		  if s:C_Comments == 'yes' 
				amenu  <silent>  &Comments.Comment\ st&yle\ C\ ->\ C\+\+   <Esc><Esc>:call C_Toggle_C_Cpp()<CR>
			else
				amenu  <silent>  &Comments.Comment\ st&yle\ C\+\+\ ->\ C   <Esc><Esc>:call C_Toggle_C_Cpp()<CR>
			endif
			"
		endif
	"===============================================================================================
	"----- Menu : C-Statements ---------------------------------------------------------------------
	"===============================================================================================
	"
	amenu  C-St&atements.&if                         <Esc><Esc>oif (  )<Esc>F(la
	amenu  C-St&atements.if\ &else                   <Esc><Esc>oif (  )<CR>else<Esc>1kf)hi
	amenu  C-St&atements.i&f\ \{\ \}                 <Esc><Esc>oif (  )<CR>{<CR>}<Esc>2kf(la
	amenu  C-St&atements.if\ \{\ \}\ e&lse\ \{\ \}   <Esc><Esc>oif (  )<CR>{<CR>}<CR>else<CR>{<CR>}<Esc>5kf(la
	amenu  C-St&atements.f&or                        <Esc><Esc>ofor ( ; ;  )<Esc>2F;i
	amenu  C-St&atements.fo&r\ \{\ \}                <Esc><Esc>ofor ( ; ;  )<CR>{<CR>}<Esc>2kf;i
	amenu  C-St&atements.&while\ \{\ \}              <Esc><Esc>owhile (  )<CR>{<CR>}<Esc>2kf(la
	amenu  C-St&atements.w&hile                      <Esc><Esc>owhile (  )<Esc>F(la
	amenu  C-St&atements.&do\ \{\ \}\ while          <Esc><Esc>:call C_DoWhile()<CR><Esc>3jf(la
	amenu  C-St&atements.&switch                     <Esc><Esc>:call C_CodeSwitch()<Esc>f(la
	amenu  C-St&atements.&case                       <Esc><Esc>ocase 0:<Tab><CR>break;<CR><Esc>2kf0s
	amenu  C-St&atements.&\{\ \}                     <Esc><Esc>o{<CR>}<Esc>O
	"
	amenu  C-St&atements.-SEP1-                      :
		"
		"----- Submenu : C-Idioms: standard library -------------------------------------------------------
		"
		amenu  C-St&atements.#include\ S&td\.Lib\..&assert\.h     <Esc><Esc>o#include<Tab><assert.h>
		amenu  C-St&atements.#include\ S&td\.Lib\..&ctype\.h      <Esc><Esc>o#include<Tab><ctype.h><Space>
		amenu  C-St&atements.#include\ S&td\.Lib\..&errno\.h      <Esc><Esc>o#include<Tab><errno.h><Space>
		amenu  C-St&atements.#include\ S&td\.Lib\..&float\.h      <Esc><Esc>o#include<Tab><float.h><Space>
		amenu  C-St&atements.#include\ S&td\.Lib\..&limits\.h     <Esc><Esc>o#include<Tab><limits.h>
		amenu  C-St&atements.#include\ S&td\.Lib\..l&ocale\.h     <Esc><Esc>o#include<Tab><locale.h>
		amenu  C-St&atements.#include\ S&td\.Lib\..&math\.h       <Esc><Esc>o#include<Tab><math.h><Space><Space>
		amenu  C-St&atements.#include\ S&td\.Lib\..set&jmp\.h     <Esc><Esc>o#include<Tab><setjmp.h>
		amenu  C-St&atements.#include\ S&td\.Lib\..s&ignal\.h     <Esc><Esc>o#include<Tab><signal.h>
		amenu  C-St&atements.#include\ S&td\.Lib\..stdar&g\.h     <Esc><Esc>o#include<Tab><stdarg.h>
		amenu  C-St&atements.#include\ S&td\.Lib\..st&ddef\.h     <Esc><Esc>o#include<Tab><stddef.h>
		amenu  C-St&atements.#include\ S&td\.Lib\..&stdio\.h      <Esc><Esc>o#include<Tab><stdio.h><Space>
		amenu  C-St&atements.#include\ S&td\.Lib\..stdli&b\.h     <Esc><Esc>o#include<Tab><stdlib.h>
		amenu  C-St&atements.#include\ S&td\.Lib\..st&ring\.h     <Esc><Esc>o#include<Tab><string.h>
		amenu  C-St&atements.#include\ S&td\.Lib\..&time\.h       <Esc><Esc>o#include<Tab><time.h><Space><Space>
		"
		amenu  C-St&atements.#include\ C&99.&complex\.h           <Esc><Esc>o#include<Tab><complex.h><Space>
		amenu  C-St&atements.#include\ C&99.&fenv\.h              <Esc><Esc>o#include<Tab><fenv.h><Space><Space><Space><Space>
		amenu  C-St&atements.#include\ C&99.&inttypes\.h          <Esc><Esc>o#include<Tab><inttypes.h>
		amenu  C-St&atements.#include\ C&99.is&o646\.h            <Esc><Esc>o#include<Tab><iso646.h><Space><Space>
		amenu  C-St&atements.#include\ C&99.&stdbool\.h           <Esc><Esc>o#include<Tab><stdbool.h><Space>
		amenu  C-St&atements.#include\ C&99.s&tdint\.h            <Esc><Esc>o#include<Tab><stdint.h><Space><Space>
		amenu  C-St&atements.#include\ C&99.tg&math\.h            <Esc><Esc>o#include<Tab><tgmath.h><Space><Space>
		amenu  C-St&atements.#include\ C&99.&wchar\.h             <Esc><Esc>o#include<Tab><wchar.h><Space><Space><Space>
		amenu  C-St&atements.#include\ C&99.wct&ype\.h            <Esc><Esc>o#include<Tab><wctype.h><Space><Space>
		"
	amenu  C-St&atements.-SEP2-                              :
	amenu  C-St&atements.#include\ &\<\.\.\.\>               <Esc><Esc>o#include<Tab><.h><Esc>F.i
	amenu  C-St&atements.#include\ \"&\.\.\.\"               <Esc><Esc>o#include<Tab>".h"<Esc>F.i
	amenu  C-St&atements.&#define                            <Esc><Esc>:call C_PPDefine()<CR>f<Tab>a
	amenu  C-St&atements.#&undef                             <Esc><Esc>:call C_PPUndef()<CR>f<Tab>a
	amenu  C-St&atements.#if\.\.#else\.\.#endif\ \(&1\)      <Esc><Esc>:call C_PPIfElse('if')      <CR>ji
	amenu  C-St&atements.#ifdef\.\.#else\.\.#endif\ \(&2\)   <Esc><Esc>:call C_PPIfElse('ifdef')   <CR>ji
	amenu  C-St&atements.#ifndef\.\.#else\.\.#endif\ \(&3\)  <Esc><Esc>:call C_PPIfElse('ifndef')  <CR>ji
	amenu  C-St&atements.#ifndef\.\.#def\.\.#endif\ \(&4\)   <Esc><Esc>:call C_PPIfDef()           <CR>2ji
	"
	"===============================================================================================
	"----- Menu : C-Idioms -------------------------------------------------------------------------
	"===============================================================================================
	"
	amenu <silent> C-&Idioms.&function                            <Esc><Esc>:call C_CodeFunction()<CR>
	amenu <silent> C-&Idioms.&main                                <Esc><Esc>:call C_CodeMain()<CR>3jA
	amenu          C-&Idioms.-SEP1-                               :
	amenu          C-&Idioms.for\ (\ i=&0;\ \ \ i<n;\ \ i\+=1\ )  <Esc><Esc>ofor ( i=0; i<n; i+=1 )<Esc>0fni
	amenu          C-&Idioms.for\ (\ i=n&-1;\ i>=0;\ i\-=1\ )     <Esc><Esc>ofor ( i=n-1; i>=0; i-=1 )<Esc>0fni
	amenu          C-&Idioms.for\ (\ i=&1;\ \ \ i<=n;\ i\+=1\ )   <Esc><Esc>ofor ( i=1; i<=n; i+=1 )<Esc>0fni
	amenu          C-&Idioms.for\ (\ i=&n;\ \ \ i>=1;\ i\-=1\ )   <Esc><Esc>ofor ( i=n; i>=1; i-=1 )<Esc>0fni
	amenu          C-&Idioms.-SEP2-                           :
	amenu <silent> C-&Idioms.&enum\+typedef                       <Esc><Esc>:call C_EST("enum")<CR>3jo
	amenu <silent> C-&Idioms.&struct\+typedef                     <Esc><Esc>:call C_EST("struct")<CR>3jo
	amenu <silent> C-&Idioms.&union\+typedef                      <Esc><Esc>:call C_EST("union")<CR>3jo
	amenu          C-&Idioms.-SEP3-                               :
	
	 menu          C-&Idioms.&printf                              <Esc><Esc>oprintf ("\n");<Esc>F\i
	 menu          C-&Idioms.s&canf                               <Esc><Esc>oscanf ("", & );<Esc>F"i
  imenu          C-&Idioms.&printf                              printf ("\n");<Esc>F\i
  imenu          C-&Idioms.s&canf                               scanf ("", & );<Esc>F"i
		"
	amenu           C-&Idioms.-SEP4-                                   :
	amenu <silent>  C-&Idioms.p=m&alloc\(\ \)                     <Esc><Esc>:call C_CodeMalloc()<CR>f(la
	amenu <silent>  C-&Idioms.open\ &input\ file                  <Esc><Esc>:call C_CodeFopenRead()<CR>jf"a
	amenu <silent>  C-&Idioms.open\ &output\ file                 <Esc><Esc>:call C_CodeFopenWrite()<CR>jf"a
  if s:C_CodeSnippets != ""
		amenu  C-&Idioms.-SEP5-                                 :
		amenu  <silent> C-&Idioms.read\ code\ snippet\ \(&2\)    <C-C>:call C_CodeSnippet("r")<CR>
		amenu  <silent> C-&Idioms.write\ code\ snippet\ \(&3\)   <C-C>:call C_CodeSnippet("w")<CR>
		vmenu  <silent> C-&Idioms.write\ code\ snippet\ \(&3\)   <C-C>:call C_CodeSnippet("wv")<CR>
		amenu  <silent> C-&Idioms.edit\ code\ snippet\ \(&4\)    <C-C>:call C_CodeSnippet("e")<CR>
	endif
  imenu  C-&Idioms.-SEP6-                      :

	"===============================================================================================
	"----- Menu : C++ ------------------------------------------------------------------------------
	"===============================================================================================
	"
	 menu  C&++.c&in                          <Esc><Esc>ocin<Tab>>> ;<Esc>i
	 menu  C&++.cout\ &variable               <Esc><Esc>ocout<Tab><<  << endl;<Esc>2F<hi
	 menu  C&++.cout\ &string                 <Esc><Esc>ocout<Tab><< "\n";<Esc>F\i
	 menu  C&++.c&err\ string                 <Esc><Esc>ocerr<Tab><< "\n";<Esc>F\i
	"
  imenu  C&++.c&in                          cin<Tab>>> ;<Esc>i
  imenu  C&++.cout\ &variable               cout<Tab><<  << endl;<Esc>2F<hi
  imenu  C&++.cout\ &string                 cout<Tab><< "\n";<Esc>F\i
  imenu  C&++.c&err\ string                 cerr<Tab><< "\n";<Esc>F\i
		"
		"----- Submenu : C++   library  -------------------------------------------------------------------
		"
		amenu	 C&++.#include\ <&alg\.\.\.loc>.&algorithm      <Esc><Esc>o#include<Tab><algorithm><Space>
		amenu	 C&++.#include\ <&alg\.\.\.loc>.&bitset         <Esc><Esc>o#include<Tab><bitset><Space><Space><Space><Space>
		amenu	 C&++.#include\ <&alg\.\.\.loc>.&complex        <Esc><Esc>o#include<Tab><complex><Space><Space><Space>
		amenu	 C&++.#include\ <&alg\.\.\.loc>.&deque          <Esc><Esc>o#include<Tab><deque><Space><Space><Space><Space><Space>
		amenu	 C&++.#include\ <&alg\.\.\.loc>.&exception      <Esc><Esc>o#include<Tab><exception><Space>
		amenu	 C&++.#include\ <&alg\.\.\.loc>.&fstream        <Esc><Esc>o#include<Tab><fstream><Space><Space><Space>
		amenu	 C&++.#include\ <&alg\.\.\.loc>.f&unctional     <Esc><Esc>o#include<Tab><functional>
		amenu	 C&++.#include\ <&alg\.\.\.loc>.iomani&p        <Esc><Esc>o#include<Tab><iomanip><Space><Space><Space>
		amenu	 C&++.#include\ <&alg\.\.\.loc>.&ios            <Esc><Esc>o#include<Tab><ios><Space><Space><Space><Space><Space><Space><Space>
		amenu	 C&++.#include\ <&alg\.\.\.loc>.iosf&wd         <Esc><Esc>o#include<Tab><iosfwd><Space><Space><Space><Space>
		amenu	 C&++.#include\ <&alg\.\.\.loc>.io&stream       <Esc><Esc>o#include<Tab><iostream><Space><Space>
		amenu	 C&++.#include\ <&alg\.\.\.loc>.istrea&m        <Esc><Esc>o#include<Tab><istream><Space><Space><Space>
		amenu	 C&++.#include\ <&alg\.\.\.loc>.iterato&r       <Esc><Esc>o#include<Tab><iterator><Space><Space>
		amenu	 C&++.#include\ <&alg\.\.\.loc>.&limits         <Esc><Esc>o#include<Tab><limits><Space><Space><Space><Space>
		amenu	 C&++.#include\ <&alg\.\.\.loc>.lis&t           <Esc><Esc>o#include<Tab><list><Space><Space><Space><Space><Space><Space>
		amenu	 C&++.#include\ <&alg\.\.\.loc>.l&ocale         <Esc><Esc>o#include<Tab><locale><Space><Space><Space><Space>

		amenu	 C&++.#include\ <&map\.\.\.vec>.&map            <Esc><Esc>o#include<Tab><map><Space><Space><Space><Space><Space><Space><Space>
		amenu	 C&++.#include\ <&map\.\.\.vec>.memor&y         <Esc><Esc>o#include<Tab><memory><Space><Space><Space><Space>
		amenu	 C&++.#include\ <&map\.\.\.vec>.&new            <Esc><Esc>o#include<Tab><new><Space><Space><Space><Space><Space><Space><Space>
		amenu	 C&++.#include\ <&map\.\.\.vec>.numeri&c        <Esc><Esc>o#include<Tab><numeric><Space><Space><Space>
		amenu	 C&++.#include\ <&map\.\.\.vec>.&ostream        <Esc><Esc>o#include<Tab><ostream><Space><Space><Space>
		amenu	 C&++.#include\ <&map\.\.\.vec>.&queue          <Esc><Esc>o#include<Tab><queue><Space><Space><Space><Space><Space>
		amenu	 C&++.#include\ <&map\.\.\.vec>.&set            <Esc><Esc>o#include<Tab><set><Space><Space><Space><Space><Space><Space><Space>
		amenu	 C&++.#include\ <&map\.\.\.vec>.sst&ream        <Esc><Esc>o#include<Tab><sstream><Space><Space><Space>
		amenu	 C&++.#include\ <&map\.\.\.vec>.st&ack          <Esc><Esc>o#include<Tab><stack><Space><Space><Space><Space><Space>
		amenu	 C&++.#include\ <&map\.\.\.vec>.stde&xcept      <Esc><Esc>o#include<Tab><stdexcept><Space>
		amenu	 C&++.#include\ <&map\.\.\.vec>.stream&buf      <Esc><Esc>o#include<Tab><streambuf><Space>
		amenu	 C&++.#include\ <&map\.\.\.vec>.str&ing         <Esc><Esc>o#include<Tab><string><Space><Space><Space><Space>
		amenu	 C&++.#include\ <&map\.\.\.vec>.&typeinfo       <Esc><Esc>o#include<Tab><typeinfo><Space><Space>
		amenu	 C&++.#include\ <&map\.\.\.vec>.&utility        <Esc><Esc>o#include<Tab><utility><Space><Space><Space>
		amenu	 C&++.#include\ <&map\.\.\.vec>.&valarray       <Esc><Esc>o#include<Tab><valarray><Space><Space>
		amenu	 C&++.#include\ <&map\.\.\.vec>.v&ector         <Esc><Esc>o#include<Tab><vector><Space><Space><Space><Space>
		"
		"----- Submenu : C     library  -------------------------------------------------------------------
		"
		amenu  C&++.#include\ <&cass\.\.\.ctim>.c&assert      <Esc><Esc>o#include<Tab><cassert>
		amenu  C&++.#include\ <&cass\.\.\.ctim>.c&ctype       <Esc><Esc>o#include<Tab><cctype><Space>
		amenu  C&++.#include\ <&cass\.\.\.ctim>.c&errno       <Esc><Esc>o#include<Tab><cerrno><Space>
		amenu  C&++.#include\ <&cass\.\.\.ctim>.c&float       <Esc><Esc>o#include<Tab><cfloat><Space>
		amenu  C&++.#include\ <&cass\.\.\.ctim>.c&limits      <Esc><Esc>o#include<Tab><climits>
		amenu  C&++.#include\ <&cass\.\.\.ctim>.cl&ocale      <Esc><Esc>o#include<Tab><clocale>
		amenu  C&++.#include\ <&cass\.\.\.ctim>.c&math        <Esc><Esc>o#include<Tab><cmath><Space><Space>
		amenu  C&++.#include\ <&cass\.\.\.ctim>.cset&jmp      <Esc><Esc>o#include<Tab><csetjmp>
		amenu  C&++.#include\ <&cass\.\.\.ctim>.cs&ignal      <Esc><Esc>o#include<Tab><csignal>
		amenu  C&++.#include\ <&cass\.\.\.ctim>.cstdar&g      <Esc><Esc>o#include<Tab><cstdarg>
		amenu  C&++.#include\ <&cass\.\.\.ctim>.cst&ddef      <Esc><Esc>o#include<Tab><cstddef>
		amenu  C&++.#include\ <&cass\.\.\.ctim>.c&stdio       <Esc><Esc>o#include<Tab><cstdio><Space>
		amenu  C&++.#include\ <&cass\.\.\.ctim>.cstdli&b      <Esc><Esc>o#include<Tab><cstdlib>
		amenu  C&++.#include\ <&cass\.\.\.ctim>.cst&ring      <Esc><Esc>o#include<Tab><cstring>
		amenu  C&++.#include\ <&cass\.\.\.ctim>.c&time        <Esc><Esc>o#include<Tab><ctime><Space><Space>

		"
		"----- Submenu : C++ : output manipulators  -------------------------------------------------------
		"
		 menu  C&++.output\ mani&pulators.\<\<\ &endl                a<< endl<Space>
		 menu  C&++.output\ mani&pulators.\<\<\ &flush               a<< flush<Space>
		 menu  C&++.output\ mani&pulators.\<\<\ &dec                 a<< dec<Space>
		 menu  C&++.output\ mani&pulators.\<\<\ &hex                 a<< hex<Space>
		 menu  C&++.output\ mani&pulators.\<\<\ &oct                 a<< oct<Space>
		 menu  C&++.output\ mani&pulators.\<\<\ set&base\(\ \)       a<< setbase() <ESC>F)i
		 menu  C&++.output\ mani&pulators.\<\<\ setfi&ll\(\ \)       a<< setfill() <ESC>F)i
		 menu  C&++.output\ mani&pulators.\<\<\ set&iosflag\(\ \)    a<< setiosflags() <ESC>F)i
		 menu  C&++.output\ mani&pulators.\<\<\ &resetiosflag\(\ \)  a<< resetiosflags() <ESC>F)i
		 menu  C&++.output\ mani&pulators.\<\<\ set&precision\(\ \)  a<< setprecision() <ESC>F)i
		 menu  C&++.output\ mani&pulators.\<\<\ set&w\(\ \)          a<< setw() <ESC>F)i
		"
	  imenu  C&++.output\ mani&pulators.\<\<\ &endl                << endl<Space>
	  imenu  C&++.output\ mani&pulators.\<\<\ &flush               << flush<Space>
	  imenu  C&++.output\ mani&pulators.\<\<\ &dec                 << dec<Space>
	  imenu  C&++.output\ mani&pulators.\<\<\ &hex                 << hex<Space>
	  imenu  C&++.output\ mani&pulators.\<\<\ &oct                 << oct<Space>
	  imenu  C&++.output\ mani&pulators.\<\<\ set&base\(\ \)       << setbase() <ESC>F)i
	  imenu  C&++.output\ mani&pulators.\<\<\ setfi&ll\(\ \)       << setfill() <ESC>F)i
	  imenu  C&++.output\ mani&pulators.\<\<\ set&iosflag\(\ \)    << setiosflags() <ESC>F)i
	  imenu  C&++.output\ mani&pulators.\<\<\ &resetiosflag\(\ \)  << resetiosflags() <ESC>F)i
	  imenu  C&++.output\ mani&pulators.\<\<\ set&precision\(\ \)  << setprecision() <ESC>F)i
	  imenu  C&++.output\ mani&pulators.\<\<\ set&w\(\ \)          << setw() <ESC>F)i
		"
		"----- Submenu : C++ : ios flag bits  -------------------------------------------------------------
		"
		 menu  C&++.ios\ flag&bits.ios::&skipws         aios::skipws
		 menu  C&++.ios\ flag&bits.ios::&left           aios::left
		 menu  C&++.ios\ flag&bits.ios::&right          aios::right
		 menu  C&++.ios\ flag&bits.ios::&internal       aios::internal
		 menu  C&++.ios\ flag&bits.ios::&boolalpha      aios::boolalpha
		 menu  C&++.ios\ flag&bits.ios::&dec            aios::dec
		 menu  C&++.ios\ flag&bits.ios::&hex            aios::hex
		 menu  C&++.ios\ flag&bits.ios::&oct            aios::oct
		 menu  C&++.ios\ flag&bits.ios::s&cientific     aios::scientific
		 menu  C&++.ios\ flag&bits.ios::&fixed          aios::fixed
		 menu  C&++.ios\ flag&bits.ios::sho&wbase       aios::showbase
		 menu  C&++.ios\ flag&bits.ios::show&pos        aios::showpos
		 menu  C&++.ios\ flag&bits.ios::&uppercase      aios::uppercase
		 menu  C&++.ios\ flag&bits.ios::&adjustfield    aios::adjustfield
		 menu  C&++.ios\ flag&bits.ios::bas&efield      aios::basefield
		 menu  C&++.ios\ flag&bits.ios::floa&tfield     aios::floatfield
		 menu  C&++.ios\ flag&bits.ios::u&nitbuf        aios::unitbuf
		"
	  imenu  C&++.ios\ flag&bits.ios::&skipws         ios::skipws
	  imenu  C&++.ios\ flag&bits.ios::&left           ios::left
	  imenu  C&++.ios\ flag&bits.ios::&right          ios::right
	  imenu  C&++.ios\ flag&bits.ios::&internal       ios::internal
	  imenu  C&++.ios\ flag&bits.ios::&boolalpha      ios::boolalpha
	  imenu  C&++.ios\ flag&bits.ios::&dec            ios::dec
	  imenu  C&++.ios\ flag&bits.ios::&hex            ios::hex
	  imenu  C&++.ios\ flag&bits.ios::&oct            ios::oct
	  imenu  C&++.ios\ flag&bits.ios::s&cientific     ios::scientific
	  imenu  C&++.ios\ flag&bits.ios::&fixed          ios::fixed
	  imenu  C&++.ios\ flag&bits.ios::sho&wbase       ios::showbase
	  imenu  C&++.ios\ flag&bits.ios::show&pos        ios::showpos
	  imenu  C&++.ios\ flag&bits.ios::&uppercase      ios::uppercase
	  imenu  C&++.ios\ flag&bits.ios::&adjustfield    ios::adjustfield
	  imenu  C&++.ios\ flag&bits.ios::bas&efield      ios::basefield
	  imenu  C&++.ios\ flag&bits.ios::floa&tfield     ios::floatfield
	  imenu  C&++.ios\ flag&bits.ios::u&nitbuf        ios::unitbuf
		"
	amenu  <silent> C&++.-SEP2-                        :
	amenu  <silent> C&++.metho&d\ implementaton        <Esc><Esc>:call C_CodeMethod()<CR>
	amenu  <silent> C&++.c&lass                        <Esc><Esc>:call C_CodeClass()<CR>
	amenu  <silent> C&++.class\ using\ &new            <Esc><Esc>:call C_CodeClassNew()<CR>
	amenu  <silent> C&++.err&or\ class                 <Esc><Esc>:call C_CodeErrorClass()<CR>
	amenu  <silent> C&++.-SEP3-                        :
	amenu  <silent> C&++.&template\ class              <Esc><Esc>:call C_CodeTemplateClass()<CR>
	amenu  <silent> C&++.template\ class\ using\ ne&w  <Esc><Esc>:call C_CodeTemplateClassNew()<CR>
	amenu  <silent> C&++.template\ &function           <Esc><Esc>:call C_CodeTemplateFunct()<CR>
	amenu  <silent> C&++.-SEP4-                        :
	amenu  <silent> C&++.friend\ operator\ <<\ \(&1\)  <Esc><Esc>:call C_CodeOutputOperator()<CR>3jf.a
	amenu  <silent> C&++.friend\ operator\ >>\ \(&2\)  <Esc><Esc>:call C_CodeInputOperator()<CR>3jf.a
	amenu  <silent> C&++.-SEP5-                        :
	amenu  <silent> C&++.tr&y\ \.\.\ catch             <Esc><Esc>:call C_CodeTryCatch()<CR>4j2f a
	amenu  <silent> C&++.catc&h                        <Esc><Esc>:call C_CodeCatch()<CR>2f a
	
	 menu  <silent> C&++.catch\(&\.\.\.\)              <Esc><Esc>ocatch (...)<CR>{<CR>}<Esc>O
  imenu  <silent> C&++.catch\(&\.\.\.\)              catch (...)<CR>{<CR>}<Esc>O

	amenu  <silent> C&++.-SEP6-                        :
	amenu  <silent> C&++.open\ input\ file\ \(&3\)     <Esc><Esc>:call C_CodeIfstream()<CR>f"a
	amenu  <silent> C&++.open\ output\ file\ \(&4\)    <Esc><Esc>:call C_CodeOfstream()<CR>f"a
	amenu  <silent> C&++.-SEP7-                        :
	
	 menu  <silent> C&++.&using\ namespace\ std;       <Esc><Esc>ousing namespace std;<CR>
	 menu  <silent> C&++.usin&g\ namespace\ ;          <Esc><Esc>ousing namespace ;<Esc>$i
	 menu  <silent> C&++.namespace\ \{\ \}             <Esc><Esc>onamespace <CR>{<CR>}<CR><Esc>3kA
  imenu  <silent> C&++.&using\ namespace\ std;       using namespace std;<CR>
  imenu  <silent> C&++.usin&g\ namespace\ ;          using namespace ;<Esc>$i
  imenu  <silent> C&++.namespace\ \{\ \}             namespace <CR>{<CR>}<CR><Esc>3kA
	
	amenu  <silent> C&++.-SEP8-                        :
		"
		"----- Submenu : RTTI  ----------------------------------------------------------------------------
		"
		 menu  C&++.&RTTI.&typeid                        atypeid()<Esc>F(a
		 menu  C&++.&RTTI.&static_cast                   astatic_cast<>()<Esc>F<a
		 menu  C&++.&RTTI.&const_cast                    aconst_cast<>()<Esc>F<a
		 menu  C&++.&RTTI.&reinterpret_cast              areinterpret_cast<>()<Esc>F<a
		 menu  C&++.&RTTI.&dynamic_cast                  adynamic_cast<>()<Esc>F<a
		"
	  imenu  C&++.&RTTI.&typeid                        typeid()<Esc>F(a
	  imenu  C&++.&RTTI.&static_cast                   static_cast<>()<Esc>F<a
	  imenu  C&++.&RTTI.&const_cast                    const_cast<>()<Esc>F<a
	  imenu  C&++.&RTTI.&reinterpret_cast              reinterpret_cast<>()<Esc>F<a
	  imenu  C&++.&RTTI.&dynamic_cast                  dynamic_cast<>()<Esc>F<a
	amenu  C&++.e&xtern\ \"C\"\ \{\ \}                 <Esc><Esc>:call C_CodeExternC()<CR>2jf.i
	"
	"===============================================================================================
	"----- Menu : run  -----------------------------------------------------------------------------
	"===============================================================================================
	"
	amenu  <silent>  C-&Run.save\ and\ &compile\ \ \<Alt\>\<F9\>  <C-C>:call C_Compile()<CR><CR>
	amenu  <silent>  C-&Run.&link\ \ \<F9\>                       <C-C>:call C_Link()   <CR><CR>
	amenu  <silent>  C-&Run.&run\ \ \<Ctrl\>\<F9\>                <C-C>:call C_Run(0)   <CR><CR>
  if s:C_Pager != ""
		amenu  <silent>  C-&Run.run\ with\ &pager                   <C-C>:call C_Run(1)<CR><CR>
	endif
	amenu  <silent>  C-&Run.command\ line\ &arguments             <C-C>:call C_Arguments()<CR>
	amenu  <silent>  C-&Run.&make\ \ \<Shift\>\<F9\>              <C-C>:call C_Make()<CR>
	amenu  <silent>  C-&Run.command\ line\ ar&guments\ for\ make  <C-C>:call C_MakeArguments()<CR>
  imenu  <silent>  C-&Run.-SEP1-                                :
	amenu  <silent>  C-&Run.har&dcopy\ buffer\ to\ FILENAME\.ps   <C-C>:call C_Hardcopy("n")<CR>
	vmenu  <silent>  C-&Run.hardcop&y\ highlighted\ part\ to\ FILENAME\.part\.ps  <C-C>:call C_Hardcopy("v")<CR>
  imenu  <silent>  C-&Run.-SEP2-                                :
	amenu  <silent>  C-&Run.&settings                             <C-C>:call C_Settings()<CR>

endfunction
"
"===============================================================================================
"----- Menu Functions --------------------------------------------------------------------------
"===============================================================================================
"
"
"------------------------------------------------------------------------------
"  C-Comments : classified comments
"------------------------------------------------------------------------------
function! C_CommentClassified (class)
  	put = '	'.s:C_Com1.' :'.a:class.':'.strftime(\"%x %X\").':'.s:C_AuthorRef.':  '.s:C_Com2
endfunction
"
"------------------------------------------------------------------------------
"  C-Comments : special comments
"------------------------------------------------------------------------------
function! C_CommentSpecial (special)
  	put = '	'.s:C_Com1.' '.a:special.' '.s:C_Com2
endfunction
"
"------------------------------------------------------------------------------
"  C-Comments : Section Comments
"------------------------------------------------------------------------------
"
function! C_CommentSection (keyword)
	let zz=   s:C_Com1." #####   ".a:keyword."   "
	if s:C_Comments == 'yes' 
		let	n = 71-strlen(a:keyword)
	else
		let	n = 74-strlen(a:keyword)
	endif	
	while n>0
		let zz = zz."#"
		let	n = n-1
	endwhile
	let zz= zz." ".s:C_Com2
	let zz= zz."\n\n"
	put =zz | +1
endfunction
"
"------------------------------------------------------------------------------
"  C-Comments : Section Comments
"------------------------------------------------------------------------------
"
function! C_Comment_C_SectionAll1 ()
	call C_CommentSection("HEADER FILE INCLUDES")
  call C_CommentSection("MACROS  -  LOCAL TO THIS SOURCE FILE")
  call C_CommentSection("TYPE DEFINITIONS  -  LOCAL TO THIS SOURCE FILE")
  call C_CommentSection("DATA TYPES  -  LOCAL TO THIS SOURCE FILE")
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
"------------------------------------------------------------------------------
"  C-Comments : Insert Template Files
"------------------------------------------------------------------------------
function! C_CommentTemplates (arg)

	if s:C_Comments == 'yes' 
		"----------------------------------------------------------------------
		"  C templates
		"----------------------------------------------------------------------
		if a:arg=='frame'
			let templatefile=s:C_Template_Directory.s:C_Template_Frame
		endif

		if a:arg=='function'
			let templatefile=s:C_Template_Directory.s:C_Template_Function
		endif

		if a:arg=='class'
			let templatefile=s:C_Template_Directory.s:C_Template_Class
		endif

		if a:arg=='method'
			let templatefile=s:C_Template_Directory.s:C_Template_Method
		endif

		if a:arg=='cheader'
			let templatefile=s:C_Template_Directory.s:C_Template_C_File
		endif

		if a:arg=='hheader'
			let templatefile=s:C_Template_Directory.s:C_Template_H_File
		endif
		
	else
		"----------------------------------------------------------------------
		"  C++ templates
		"----------------------------------------------------------------------
		if a:arg=='frame'
			let templatefile=s:C_Template_Directory.s:Cpp_Template_Frame
		endif

		if a:arg=='function'
			let templatefile=s:C_Template_Directory.s:Cpp_Template_Function
		endif

		if a:arg=='class'
			let templatefile=s:C_Template_Directory.s:Cpp_Template_Class
		endif

		if a:arg=='method'
			let templatefile=s:C_Template_Directory.s:Cpp_Template_Method
		endif

		if a:arg=='cheader'
			let templatefile=s:C_Template_Directory.s:Cpp_Template_C_File
		endif

		if a:arg=='hheader'
			let templatefile=s:C_Template_Directory.s:Cpp_Template_H_File
		endif
	endif

	if filereadable(templatefile)
		let	length= line("$")
		let	pos1  = line(".")+1
		if  a:arg=='cheader' || a:arg=='hheader'
			:goto 1
			let	pos1  = 1
			silent exe '0read '.templatefile
		else
			silent exe 'read '.templatefile
		endif
		let	length= line("$")-length
		let	pos2  = pos1+length-1
		"----------------------------------------------------------------------
		"  frame blocks will be indented
		"----------------------------------------------------------------------
		if a:arg=='frame'
			let	length	= length-1
			silent exe "normal =".length."+"
			let	length	= length+1
		endif
		"----------------------------------------------------------------------
		"  substitute keywords
		"----------------------------------------------------------------------
		silent! exe pos1.','.pos2.' s/|FILENAME|/'.expand("%:t").'/g'
		" the seperator (#) for the following substitute (s) may not appear 
		" in the date representation
		silent! exe pos1.','.pos2.' s#|DATE|#'.strftime("%x %X %Z").'#g'
		silent! exe pos1.','.pos2.' s/|TIME|/'.strftime("%X").'/g'
		silent! exe pos1.','.pos2.' s/|YEAR|/'.strftime("%Y").'/g'
		silent! exe pos1.','.pos2.' s/|AUTHOR|/'.s:C_AuthorName.'/g'
		silent! exe pos1.','.pos2.' s/|EMAIL|/'.s:C_Email.'/g'
		silent! exe pos1.','.pos2.' s/|AUTHORREF|/'.s:C_AuthorRef.'/g'
		silent! exe pos1.','.pos2.' s/|PROJECT|/'.s:C_Project.'/g'
		silent! exe pos1.','.pos2.' s/|COMPANY|/'.s:C_Company.'/g'
		silent! exe pos1.','.pos2.' s/|COPYRIGHTHOLDER|/'.s:C_CopyrightHolder.'/g'
		"----------------------------------------------------------------------
		"  Position the cursor
		"----------------------------------------------------------------------
		exe ':'.pos1
		normal 0
		let linenumber=search('|CURSOR|')
		if linenumber >=pos1 && linenumber<=pos2
			let pos1=match( getline(linenumber) ,"|CURSOR|")
			if  matchend( getline(linenumber) ,"|CURSOR|") == match( getline(linenumber) ,"$" )
				silent! s/|CURSOR|//
				" this is an append like A
				:startinsert!
			else
				silent  s/|CURSOR|//
				call cursor(linenumber,pos1+1)
				" this is an insert like i
				:startinsert
			endif
		endif

	else
		echohl WarningMsg | echo 'template file '.templatefile.' does not exist or is not readable'| echohl None
	endif
	return
endfunction    " ----------  end of function  C_CommentTemplates  ----------
"
"----------------------------------------------------------------------
"  Toggle comment style
"----------------------------------------------------------------------
function! C_Toggle_C_Cpp ()
	
	if s:C_Comments == 'yes'
		aunmenu           &Comments.Comment\ st&yle\ C\ ->\ C\+\+
		amenu   <silent>  &Comments.Comment\ st&yle\ C\+\+\ ->\ C       <Esc><Esc>:call C_Toggle_C_Cpp()<CR>	
		let	s:C_Comments	= 'no'
		let s:C_Com1            = '//'     " C++style : comment start 
		let s:C_Com2            = ''       " C++style : comment end
	else
		aunmenu          &Comments.Comment\ st&yle\ C\+\+\ ->\ C
		amenu   <silent> &Comments.Comment\ st&yle\ C\ ->\ C\+\+    		<Esc><Esc>:call C_Toggle_C_Cpp()<CR>
		let	s:C_Comments	= 'yes'
		let s:C_Com1            = '/*'     " C-style : comment start 
		let s:C_Com2            = '*/'     " C-style : comment end
	endif
	return
endfunction    " ----------  end of function C_Toggle_C_Cpp  ----------
"
"------------------------------------------------------------------------------
"  C-Comments : vim modeline
"------------------------------------------------------------------------------
function! C_CommentVimModeline ()
  	put = '/* vim: set tabstop='.&tabstop.': set shiftwidth='.&shiftwidth.': */'
endfunction    " ----------  end of function C_CommentVimModeline  ----------
"
"=====================================================================================
"----- Menu : Statements -----------------------------------------------------------
"=====================================================================================
"
"------------------------------------------------------------------------------
"  Statements : do-while
"------------------------------------------------------------------------------
function! C_DoWhile ()
	let zz=    "do\n{\n}\nwhile (  );"
  let zz= zz."\t\t\t\t".s:C_Com1." -----  end do-while  ----- ".s:C_Com2."\n"
	put =zz
	normal  =3+
endfunction
"
"------------------------------------------------------------------------------
"  Statements : switch
"------------------------------------------------------------------------------
"
function! C_CodeSwitch ()
  let zz= "switch (  )\n{\n"
	let zz= zz."case 0:\t\n\t\tbreak;\n\n"
	let zz= zz."case 0:\t\n\t\tbreak;\n\n"
	let zz= zz."case 0:\t\n\t\tbreak;\n\n"
	let zz= zz."case 0:\t\n\t\tbreak;\n\n"
	let zz= zz."default:\t\n\t\tbreak;\n}"
  let zz= zz."\t\t\t\t".s:C_Com1." -----  end switch  ----- ".s:C_Com2."\n"
	put =zz	
	" indent 
	normal  =16+
	" delete case labels
	exe ":.,+12s/0//"
	-11
endfunction
"
"----------------------------------------------------------------------
"  Statements : #define
"----------------------------------------------------------------------
function! C_PPDefine ()
	if s:C_Comments == 'yes' 
		put = \"#define\t\t\t\t\".s:C_Com1.\"  \".s:C_Com2
	else
		put = \"#define\t\t\t\t\".s:C_Com1.\" \"
	endif
	return
endfunction    " ----------  end of function C_PPDefine  ----------
"
"----------------------------------------------------------------------
"  Statements : #undef
"----------------------------------------------------------------------
function! C_PPUndef ()
	if s:C_Comments == 'yes' 
		put = \"#undef\t\t\t\t\".s:C_Com1.\"  \".s:C_Com2
	else
		put = \"#undef\t\t\t\t\".s:C_Com1.\" \"
	endif
	return
endfunction    " ----------  end of function C_PPDefine  ----------
"
"------------------------------------------------------------------------------
"  Statements : #if .. #else .. #endif 
"  Statements : #ifdef .. #else .. #endif 
"  Statements : #ifndef .. #else .. #endif 
"------------------------------------------------------------------------------
function! C_PPIfElse (keyword)
	let identifier = "CONDITION"
	let	identifier = inputdialog("(uppercase) condition for #".a:keyword, identifier )
	if identifier != ""
		let zz=    "#".a:keyword."  ".identifier."\n\n"
		let zz= zz."#else      ".s:C_Com1." ----- #".a:keyword." ".identifier."  ----- ".s:C_Com2."\n\n"
		let zz= zz."#endif     ".s:C_Com1." ----- #".a:keyword." ".identifier."  ----- ".s:C_Com2."\n"
		put =zz
	endif
endfunction
"
"------------------------------------------------------------------------------
"  Statements : #ifndef .. #define .. #endif 
"------------------------------------------------------------------------------
function! C_PPIfDef ()
	" use filename without path (:t) and extension (:r) :
	let identifier = toupper(expand("%:t:r"))."_INC"
	let	identifier = inputdialog("(uppercase) condition for #ifndef", identifier )
	if identifier != ""
		let zz=    "#ifndef  ".identifier."\n"
		let zz= zz."#define  ".identifier."\n\n"
		let zz= zz."#endif   ".s:C_Com1." ----- #ifndef ".identifier."  ----- ".s:C_Com2."\n"
		put =zz
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C-Idioms : function
"------------------------------------------------------------------------------
function! C_CodeFunction ()
	let	identifier=inputdialog("function name", "f" )
	if identifier != ""
		let zz=    "void\n".identifier." (  )\n{\n\treturn ;\n}"
		let zz= zz."\t\t\t\t".s:C_Com1." ----------  end of function ".identifier."  ---------- ".s:C_Com2
		put =zz
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C-Idioms : main
"------------------------------------------------------------------------------
function! C_CodeMain ()
	let zz=    "int\nmain ( int argc, char *argv[] )\n{\n\t\n"
	let zz= zz."\treturn 0;\n}"
	let zz= zz."\t\t\t\t".s:C_Com1." ----------  end of function main  ---------- ".s:C_Com2
	put =zz
endfunction

"------------------------------------------------------------------------------
"  C-Idioms : read / edit code snippet
"------------------------------------------------------------------------------
function! C_CodeSnippet(arg1)
	if isdirectory(s:C_CodeSnippets)
		"
		" read snippet file, put content below current line
		" 
		if a:arg1 == "r"
			let	l:snippetfile=browse(0,"read a code snippet",s:C_CodeSnippets,"")
			if filereadable(l:snippetfile)
				let	length= line("$")
				:execute "read ".l:snippetfile
				let	length= line("$")-length-1
				if length>=0
					silent exe "normal =".length."+"
				endif
			endif
		endif
		"
		" update current buffer / split window / edit snippet file
		" 
		if a:arg1 == "e"
			let	l:snippetfile=browse(0,"edit a code snippet",s:C_CodeSnippets,"")
			if l:snippetfile != ""
				:execute "update! | split | edit ".l:snippetfile
			endif
		endif
		"
		" write whole buffer into snippet file 
		" 
		if a:arg1 == "w"
			let	l:snippetfile=browse(0,"write a code snippet",s:C_CodeSnippets,"")
			if l:snippetfile != ""
				:execute ":write! ".l:snippetfile
			endif
		endif
		"
		" write marked area into snippet file 
		" 
		if a:arg1 == "wv"
			let	l:snippetfile=browse(0,"write a code snippet",s:C_CodeSnippets,"")
			if l:snippetfile != ""
				:execute ":*write! ".l:snippetfile
			endif
		endif

	else
		echo "code snippet directory ".s:C_CodeSnippets." does not exist (please create it)"
	endif
endfunction
"
function! C_CommentClearClassName ()
	let	s:C_ClassName=""
endfunction
"
"------------------------------------------------------------------------------
"  C++ : method
"------------------------------------------------------------------------------
function! C_CodeMethod()
	let	identifier=inputdialog("method name", s:C_ClassName."::" )
	if identifier != ""
		let zz=    "void\n".identifier."\t(  )\n{\n\treturn ;\n}"
		let zz= zz."\t\t\t\t".s:C_Com1." ----------  end of method ".identifier."  ---------- ".s:C_Com2
		put =zz
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C++ : class
"------------------------------------------------------------------------------
function! C_CodeClass()
	let	s:C_ClassName=inputdialog("name of class", "Cls" )
	if s:C_ClassName != ""
		let zz=    "class ".s:C_ClassName
		let zz= zz."\n{\n\n\tpublic:\n\n"
		let zz= zz."\t\t".s:C_Com1." ====================  LIFECYCLE   ========================================= ".s:C_Com2."\n\n"
		let zz= zz."\t\t".s:C_ClassName." ();\t".s:C_Com1." constructor ".s:C_Com2."\n\n"	
		let zz= zz."\t\t".s:C_Com1." Use compiler-generated copy constructor, assignment operator and destructor ".s:C_Com2."\n\n"	
		let zz= zz."\t\t".s:C_Com1." ====================  OPERATORS   ========================================= ".s:C_Com2."\n\n"
		let zz= zz."\t\t".s:C_Com1." ====================  OPERATIONS  ========================================= ".s:C_Com2."\n\n"
		let zz= zz."\t\t".s:C_Com1." ====================  ACCESS      ========================================= ".s:C_Com2."\n\n"
		let zz= zz."\t\t".s:C_Com1." ====================  INQUIRY     ========================================= ".s:C_Com2."\n\n"
		let zz= zz."\t\t".s:C_Com1." ====================  NESTED ERROR CLASSES  =============================== ".s:C_Com2."\n\n\n"
		let zz= zz."\tprotected:\n\n"
		let zz= zz."\tprivate:\n\n"
		let zz= zz."\n};\t\t\t".s:C_Com1." ----------  end of class  ".s:C_ClassName."  ---------- ".s:C_Com2."\n"
		let zz= zz."\n\n".s:C_ClassName."::".s:C_ClassName." ()\n{\n}"
		let zz= zz."\t\t\t\t".s:C_Com1." ----------  end of method ".s:C_ClassName."::".s:C_ClassName."  (constructor)  ---------- ".s:C_Com2."\n"
		put =zz
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
		let zz=    "class ".s:C_ClassName
		let zz= zz."\n{\n\n\tpublic:\n\n"
		let zz= zz."\t\t".s:C_Com1." ====================  LIFECYCLE   ========================================= ".s:C_Com2."\n\n"
		let zz= zz."\t\t".s:C_ClassName." ();\t\t\t\t\t\t\t".tabs."".s:C_Com1." constructor ".s:C_Com2."\n"	
		let zz= zz."\t\t".s:C_ClassName." (const ".s:C_ClassName." &obj);\t".s:C_Com1." copy constructor ".s:C_Com2."\n"	
		let zz= zz."\t\t~".s:C_ClassName." (); \t\t\t\t\t\t".tabs."".s:C_Com1." destructor ".s:C_Com2."\n\n"
		let zz= zz."\t\t".s:C_Com1." ====================  OPERATORS   ========================================= ".s:C_Com2."\n\n"
		let zz= zz."\t\tconst ".s:C_ClassName."& operator = (const ".s:C_ClassName." &obj);"
		let zz= zz."\t\t".s:C_Com1." assignemnt operator ".s:C_Com2."\n\n"
		let zz= zz."\t\t".s:C_Com1." ====================  OPERATIONS  ========================================= ".s:C_Com2."\n\n"
		let zz= zz."\t\t".s:C_Com1." ====================  ACCESS      ========================================= ".s:C_Com2."\n\n"
		let zz= zz."\t\t".s:C_Com1." ====================  INQUIRY     ========================================= ".s:C_Com2."\n\n"
		let zz= zz."\t\t".s:C_Com1." ====================  NESTED ERROR CLASSES  =============================== ".s:C_Com2."\n\n\n"
		let zz= zz."\tprotected:\n\n"
		let zz= zz."\tprivate:\n\n"
		let zz= zz."\n};\t\t\t".s:C_Com1." ----------  end of class  ".s:C_ClassName."  ---------- ".s:C_Com2."\n"


		let zz= zz."\n\n".s:C_ClassName."::".s:C_ClassName." ()\n{\n}"
		let zz= zz."\t\t\t\t".s:C_Com1." ----------  end of method ".s:C_ClassName."::".s:C_ClassName."  (constructor)  ---------- ".s:C_Com2."\n"

		let zz= zz."\n\n".s:C_ClassName."::".s:C_ClassName." (const ".s:C_ClassName." &obj)\n{\n}"
		let zz= zz."\t\t\t\t".s:C_Com1." ----------  end of method ".s:C_ClassName."::".s:C_ClassName."  (copy constructor)  ---------- ".s:C_Com2."\n"
	
		let zz= zz."\n\n".s:C_ClassName."::~".s:C_ClassName." ()\n{\n}"
		let zz= zz."\t\t\t\t".s:C_Com1." ----------  end of method ".s:C_ClassName."::~".s:C_ClassName."  (destructor)  ---------- ".s:C_Com2."\n"
		
		let zz= zz."\n\nconst ".s:C_ClassName."&\n".s:C_ClassName."::operator = (const ".s:C_ClassName." &obj)"
		let zz= zz."\n{\n\tif(this!=&obj)\n\t{\n\n\t}\n\treturn *this;\n}"	
		let zz= zz."\t\t\t\t".s:C_Com1." ----------  end of method ".s:C_ClassName."::operator =  (assignment operator)  ---------- ".s:C_Com2."\n"
		put =zz
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C++ : simple error class
"------------------------------------------------------------------------------
function! C_CodeErrorClass()
	let	classname=inputdialog("name of error class", "Error" )
	if classname != ""
		let zz=    "class ".classname
		let zz= zz."\n{\n\tprotected:\tchar  *message;"
		let zz= zz."\n\tpublic:\t\t\t".classname." (char *msg)   { message=msg; }"
		let zz= zz."\n\t\t\t\t\t\t\tvirtual const char* what () const throw ()   { return message; }"
		let zz= zz."\n};\t\t\t".s:C_Com1." ----------  end of class  ".classname."  ---------- ".s:C_Com2."\n"
		put =zz
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
		let zz=    "template < class T >\nclass ".classname
		let zz= zz."\n{\n\n\tpublic:\n\n"
		let zz= zz."\t\t".s:C_Com1." ====================  LIFECYCLE   ========================================= ".s:C_Com2."\n\n"
		let zz= zz."\t\t".classname." (); \t".s:C_Com1." constructor ".s:C_Com2."\n\n"	
		let zz= zz."\t\t".s:C_Com1." Use compiler-generated copy constructor, assignment operator and destructor ".s:C_Com2."\n\n"	
		let zz= zz."\t\t".s:C_Com1." ====================  OPERATORS   ========================================= ".s:C_Com2."\n\n"
		let zz= zz."\t\t".s:C_Com1." ====================  OPERATIONS  ========================================= ".s:C_Com2."\n\n"
		let zz= zz."\t\t".s:C_Com1." ====================  ACCESS      ========================================= ".s:C_Com2."\n\n"
		let zz= zz."\t\t".s:C_Com1." ====================  INQUIRY     ========================================= ".s:C_Com2."\n\n"
		let zz= zz."\t\t".s:C_Com1." ====================  NESTED ERROR CLASSES  =============================== ".s:C_Com2."\n\n\n"
		let zz= zz."\tprotected:\n\n"
		let zz= zz."\tprivate:\n\n"
		let zz= zz."\n};\t\t\t".s:C_Com1." ----------  end of template class  ".classname."  ---------- ".s:C_Com2."\n"
		
		let zz= zz."\n\ntemplate < class T >"
		let zz= zz."\n".classname." < T >:: ".classname." ()\n{\n}"
		let zz= zz."\t\t\t\t".s:C_Com1." ----------  end of constructor of template class ".classname."  ---------- ".s:C_Com2."\n"
		
		put =zz
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
		let zz=    "template < class T >\nclass ".classname
		let zz= zz."\n{\n\n\tpublic:\n\n"
		let zz= zz."\t\t".s:C_Com1." ====================  LIFECYCLE   ========================================= ".s:C_Com2."\n\n"
		let zz= zz."\t\t".classname." ();\t\t\t\t\t\t\t".tabs."".s:C_Com1." constructor ".s:C_Com2."\n"	
		let zz= zz."\t\t".classname." (const ".classname." &obj);\t".s:C_Com1." copy constructor ".s:C_Com2."\n"	
		let zz= zz."\t\t~".classname." (); \t\t\t\t\t\t".tabs."".s:C_Com1." destructor ".s:C_Com2."\n\n"
		let zz= zz."\t\t".s:C_Com1." ====================  OPERATORS   ========================================= ".s:C_Com2."\n\n"
		let zz= zz."\t\tconst ".classname."& operator = (const ".classname." &obj);"
		let zz= zz."\t\t".s:C_Com1." assignment operator ".s:C_Com2."\n\n"
		let zz= zz."\t\t".s:C_Com1." ====================  OPERATIONS  ========================================= ".s:C_Com2."\n\n"
		let zz= zz."\t\t".s:C_Com1." ====================  ACCESS      ========================================= ".s:C_Com2."\n\n"
		let zz= zz."\t\t".s:C_Com1." ====================  INQUIRY     ========================================= ".s:C_Com2."\n\n"
		let zz= zz."\t\t".s:C_Com1." ====================  NESTED ERROR CLASSES  =============================== ".s:C_Com2."\n\n\n"
		let zz= zz."\tprotected:\n\n"
		let zz= zz."\tprivate:\n\n"
		let zz= zz."\n};\t\t\t".s:C_Com1." ----------  end of template class  ".classname."  ---------- ".s:C_Com2."\n"

		let zz= zz."\n\ntemplate < class T >"
		let zz= zz."\n".classname."< T >::".classname." ()\n{\n}"	
		let zz= zz."\t\t\t\t".s:C_Com1." ----------  end of constructor of template class ".classname."  ---------- ".s:C_Com2."\n"


		let zz= zz."\n\ntemplate < class T >"
		let zz= zz."\n".classname."< T >::".classname." (const ".classname." &obj)\n{\n}"
		let zz= zz."\t\t\t\t".s:C_Com1." ----------  end of copy constructor of template class ".classname."  ---------- ".s:C_Com2."\n"
		
		let zz= zz."\n\ntemplate < class T >"
		let zz= zz."\n".classname."< T >::~".classname." ()\n{\n}"
		let zz= zz."\t\t\t\t".s:C_Com1." ----------  end of destructor of template class ".classname."  ---------- ".s:C_Com2."\n"
		
		let zz= zz."\n\ntemplate < class T >"
		let zz= zz."\nconst ".classname."< T >& ".classname."< T >::operator = (const ".classname." &obj)"
		let zz= zz."\n{\n\tif(this!=&obj)\n\t{\n\n\t}\n\treturn *this;\n}"	
		let zz= zz."\t\t\t\t".s:C_Com1." ----------  end of assignment operator of template class ".classname."  ---------- ".s:C_Com2."\n"
		put =zz
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C++ : template function
"------------------------------------------------------------------------------
function! C_CodeTemplateFunct ()
	let	identifier=inputdialog("template function name", "f" )
	if identifier != ""
		let zz=    "template <class T> void\n".identifier."\t( T param )\n{\n\n\n\treturn ;\n}"
		let zz= zz."\t\t\t\t".s:C_Com1." ----------  end of template function ".identifier."  ---------- ".s:C_Com2
		put =zz
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
		let zz=    "typedef ".a:su." ".name." ".typename.";\n\n"
		let zz= zz.a:su." ".name."\n{\n};"
		let zz= zz."\t\t\t\t".s:C_Com1." ----------  end of ".a:su." ".name."  ---------- ".s:C_Com2."\n\n"
		put =zz
	endif
	normal  =4+
endfunction
"
"------------------------------------------------------------------------------
"  C-Idioms : malloc
"------------------------------------------------------------------------------
function! C_CodeMalloc ()
	let	pointername= inputdialog("pointer name", "p")
	if pointername != ""
		let zz=    pointername."\t= malloc (  );"
		let zz= zz."\n\nif (".pointername."==NULL)\n{"
		let zz= zz."\n\tfprintf (stderr, \"\\n ** dynamic memory allocation failed ** exit **\\n\" );"
		let zz= zz."\n\texit(3);\n}"
		let zz= zz."\n\nfree (".pointername.");\n\n"
		put =zz
		normal  =8+
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
		let zz=    "FILE\t*".filepointer.";\t\t\t\t\t\t\t\t\t".s:C_Com1." input-file pointer ".s:C_Com2."\n"
		let zz= zz."char\t*".filename." = \"\";\t\t".s:C_Com1." input-file name ".s:C_Com2."\n\n"
		let zz= zz.filepointer."\t= fopen ( ".filename.", \"r\" );\n"
		let zz= zz."if (".filepointer." == NULL)\n{\n"
		let zz= zz."\tfprintf (stderr, \" ** cannot open input file %s ** exit **\\n\", ".filename." );\n"
		let zz= zz."\texit (1);\n}\n\n\n"
		let zz= zz."fclose ( ".filepointer." );\t\t\t\t\t\t\t".s:C_Com1." close input file ".s:C_Com2."\n"
		put =zz
		normal =11+
		exe ": menu C-&Idioms.fscanf(".filepointer.",\\ \"\",\\ );    <Esc><Esc>ofscanf( ".filepointer.", \"\", & );<ESC>F\"i"
		exe ":imenu C-&Idioms.fscanf(".filepointer.",\\ \"\",\\ );     fscanf( ".filepointer.", \"\", & );<ESC>F\"i"
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
		let zz=    "FILE\t*".filepointer.";\t\t\t\t\t\t\t\t\t".s:C_Com1." output-file pointer ".s:C_Com2."\n"
		let zz= zz."char\t*".filename." = \"\";\t".s:C_Com1." output-file name ".s:C_Com2."\n\n"
		let zz= zz.filepointer."\t= fopen ( ".filename.", \"w\" );\n"
		let zz= zz."if (".filepointer." == NULL)\n{\n"
		let zz= zz."\tfprintf (stderr, \" ** cannot open output file %s ** exit **\\n\", ".filename." );\n"
		let zz= zz."\texit (2);\n}\n\n\n"
		let zz= zz."fclose ( ".filepointer." );\t\t\t\t\t\t\t".s:C_Com1." close output file ".s:C_Com2."\n"
		put =zz
		normal =11+
		exe ": menu C-&Idioms.fprintf(".filepointer.",\\ \"\\\\n\",\\ );     <Esc><Esc>ofprintf( ".filepointer.", \"\\n\",  );<ESC>F\\i"
		exe ":imenu C-&Idioms.fprintf(".filepointer.",\\ \"\\\\n\",\\ );     fprintf( ".filepointer.", \"\\n\",  );<ESC>F\\i"
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
		let zz=    "char *".filename." = \"\";\t\t".s:C_Com1." input file name ".s:C_Com2."\n"
		let zz= zz."ifstream\t".ifstreamobject.";\t\t\t\t\t\t\t".s:C_Com1." create ifstream object ".s:C_Com2."\n\n"
		let zz= zz.ifstreamobject.".open(".filename.");\t\t".s:C_Com1." open ifstream ".s:C_Com2."\n"
		let zz= zz."if (!".ifstreamobject.")\n{\n"
		let zz= zz."\tcerr << \"\\nERROR : failed to open input file \" << ".filename." << \" --- exit program\\n\";\n"
		let zz= zz."\texit (1);\n}\n\n\n"
		let zz= zz.ifstreamobject.".close();\t\t".s:C_Com1." close ifstream ".s:C_Com2."\n"
		put =zz
		normal =11+
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
		let zz=    "char *".filename." = \"\";\t\t".s:C_Com1." output file name ".s:C_Com2."\n"
		let zz= zz."ofstream\t".ofstreamobject.";\t\t\t\t\t\t\t".s:C_Com1." create ofstream object ".s:C_Com2."\n\n"
		let zz= zz.ofstreamobject.".open(".filename.");\t\t".s:C_Com1." open ofstream ".s:C_Com2."\n"
		let zz= zz."if (!".ofstreamobject.")\n{\n"
		let zz= zz."\tcerr << \"\\nERROR : failed to open output file \" << ".filename." << \" --- exit program\\n\";\n"
		let zz= zz."\texit (2);\n}\n\n\n"
		let zz= zz.ofstreamobject.".close();\t\t".s:C_Com1." close ofstream ".s:C_Com2."\n"
		put =zz
		normal =11+
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C++ : extern "C"
"------------------------------------------------------------------------------
function! C_CodeExternC()
	let zz=    "extern \"C\"\n{\n\t#include\t\".h\"\n}"
	put =zz
endfunction
"
"------------------------------------------------------------------------------
"  C++ : output operator
"------------------------------------------------------------------------------
function! C_CodeOutputOperator ()
	let	identifier=inputdialog("class name", s:C_ClassName )
	if identifier != ""
		let zz=    "friend ostream &\noperator << (ostream & os, const ".identifier." & obj )\n"
		let zz= zz."{\n\tos << obj. ;\n\treturn os;\n}"
		let zz= zz."\t\t\t\t".s:C_Com1." ----------  class ".identifier." : end of friend function operator <<  ---------- ".s:C_Com2
		put =zz
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C++ : input operator
"------------------------------------------------------------------------------
function! C_CodeInputOperator ()
	let	identifier=inputdialog("class name", s:C_ClassName )
	if identifier != ""
		let zz=    "friend istream &\noperator >> (istream & is, ".identifier." & obj )"
		let zz= zz."\n{\n\tis >> obj. ;\n\treturn is;\n}"
		let zz= zz."\t\t\t\t".s:C_Com1." ----------  class ".identifier." : end of friend function operator >>  ---------- ".s:C_Com2
		put =zz
	endif
endfunction
"
"------------------------------------------------------------------------------
"  C++ : try catch
"------------------------------------------------------------------------------
function! C_CodeTryCatch ()
  let zz=    "try\n{\n\t\n}\n"
  let zz= zz."catch (const  &ExceptObj)\t\t".s:C_Com1." handle exception: ".s:C_Com2."\n{\n\t\n}\n"
  let zz= zz."catch (...)\t\t\t".s:C_Com1." handle exception: unspezified ".s:C_Com2."\n{\n\t\n}"
	put =zz		
	normal  =11+
endfunction
"
"------------------------------------------------------------------------------
"  C++ : catch
"------------------------------------------------------------------------------
function! C_CodeCatch ()
  put =\"catch (const  &ExceptObj)\t\t\".s:C_Com1.\" handle exception: \".s:C_Com2.\"\n{\n\t\n}\n\"
	normal  =3+
endfunction
"
"------------------------------------------------------------------------------
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
		" 
		" COMPILATION
		exe		"make ".s:C_CFlags." ".Sou." -o ".Obj		
		exe		"set makeprg=make"
		" 
		" open error window if necessary 
		exe	":cwindow"
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
			exe		"!./".Exe." ".s:C_ExeCmdLineArgs
		else
			exe		"!./".Exe." ".s:C_ExeCmdLineArgs." | ".s:C_Pager
		endif
	endif

endfunction
"
"------------------------------------------------------------------------------
"  run : Arguments for the executable
"------------------------------------------------------------------------------
function! C_Arguments ()
	let	s:C_ExeCmdLineArgs= inputdialog("command line arguments",s:C_ExeCmdLineArgs)
endfunction
"
"------------------------------------------------------------------------------
"  run : Arguments for make
"------------------------------------------------------------------------------
function! C_MakeArguments ()
	let	s:C_MakeCmdLineArgs= inputdialog("make command line arguments",s:C_MakeCmdLineArgs)
endfunction
"
function! C_Make()
			exe		":make ".s:C_MakeCmdLineArgs
endfunction
"
"
"------------------------------------------------------------------------------
"  run : settings
"------------------------------------------------------------------------------
function! C_Settings ()
	let	settings	=         "C/C++-Support settings\n\n"
	let settings = settings."author  :  ".s:C_AuthorName." (".s:C_AuthorRef.") ".s:C_Email."\n"
	let settings = settings."company :  ".s:C_Company."\n"
	let settings = settings."project :  ".s:C_Project."\n"
	let settings = settings."copyright holder :  ".s:C_CopyrightHolder."\n"
	let settings = settings."\n"
	let settings = settings."C / C++ compiler :  ".s:C_CCompiler." / ".s:C_CplusCompiler."\n"
	let settings = settings."C file extension :  ".s:C_CExtension."  (everything else is C++)\n"
	let settings = settings."compiler flags :  ".s:C_CFlags."\n"
	let settings = settings."compiler+link flags :  ".s:C_LFlags."\n"
	let settings = settings."libraries :  ".s:C_Libs."\n"
	let settings = settings."pager :  ".s:C_Pager."\n"
	let settings = settings."code snippet directory  :  ".s:C_CodeSnippets."\n"
	let settings = settings."comment template directory  :  ".s:C_Template_Directory."\n"
	let settings = settings."\n"
	let settings = settings."\nMake changes in file c.vim\n"
	let	settings = settings."----------------------------------------------------------------------------------------\n"
	let	settings = settings."C/C++-Support, Version ".s:C_Version."  /  Dr.-Ing. Fritz Mehner  /  mehner@fh-swf.de\n"
	let dummy=confirm( settings, "ok", 1, "Info" )
endfunction
"
"------------------------------------------------------------------------------
"  run : hardcopy
"------------------------------------------------------------------------------
function! C_Hardcopy (arg1)
	let	Sou		= expand("%")								" name of the file in the current buffer
	" ----- normal mode ----------------
	if a:arg1=="n"
		exe	"hardcopy > ".Sou.".ps"		
	endif
	" ----- visual mode ----------------
	if a:arg1=="v"
		exe	"*hardcopy > ".Sou.".part.ps"		
	endif
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
	" protect the following submenu names against interpolation by using single qoutes (Mn)
	"
	if  s:C_Active == 1
		:aunmenu &Tools.Load\ C\ Support
		exe 'amenu <silent> 40.1030 &Tools.Unload\ C\ Support  	<C-C>:call C_Handle()<CR>'
	else
		" C is now inactive and was former active or in initial state -1 
		if s:C_Active == 0
			" Remove Tools.Unload if C was former inactive
			:aunmenu &Tools.Unload\ C\ Support
		else
			" Set initial state C_Active=-1 to inactive state C_Active=0
			" This protects from removing Tools.Unload during initialization after
			" loading this script
			let s:C_Active = 0
			" Insert Tools.Load
		endif
		exe 'amenu <silent> 40.1000 &Tools.-SEP100- : '
		exe 'amenu <silent> 40.1030 &Tools.Load\ C\ Support <C-C>:call C_Handle()<CR>'
	endif
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
"
" vim:set tabstop=2: 
