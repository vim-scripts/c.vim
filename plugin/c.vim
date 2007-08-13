"###############################################################################################
"  
"       Filename:  c.vim
"  
"    Description:  C/C++-IDE. Write programs by inserting complete statements, 
"                  comments, idioms, code snippets, templates and comments.
"                  Compile, link and run one-file-programs without a makefile.
"                  See also help file csupport.txt .
"  
"   GVIM Version:  6.0+
"  
"  Configuration:  There are some personal details which should be configured 
"                   (see the files README.csupport and csupport.txt).
"  
"         Author:  Dr.-Ing. Fritz Mehner, FH Südwestfalen, 58644 Iserlohn, Germany
"          Email:  mehner@fh-swf.de
"  
"        Version:  see variable  g:C_Version  below 
"        Created:  04.11.2000
"        License:  Copyright (c) 2000-2007, Fritz Mehner
"                  This program is free software; you can redistribute it and/or
"                  modify it under the terms of the GNU General Public License as
"                  published by the Free Software Foundation, version 2 of the
"                  License.
"                  This program is distributed in the hope that it will be
"                  useful, but WITHOUT ANY WARRANTY; without even the implied
"                  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
"                  PURPOSE.
"                  See the GNU General Public License version 2 for more details.
"       Revision:  $Id: c.vim,v 1.19 2007/08/13 10:42:51 mehner Exp $
"        
"------------------------------------------------------------------------------
" 
" Prevent duplicate loading: 
" 
if exists("g:C_Version") || &cp
 finish
endif
let g:C_Version= "4.6.1"  							" version number of this script; do not change
"        
"###############################################################################################
"
"  Global variables (with default values) which can be overridden.
"          
" Platform specific items:  {{{1
" - root directory
" - characters that must be escaped for filenames
" 
let	s:MSWIN =		has("win16") || has("win32")     || has("win64") || 
							\ has("win95") || has("win32unix")
" 
if	s:MSWIN
	"
	let s:plugin_dir	= $VIM.'\vimfiles\'
	let s:home_dir	  = ''
  let s:escfilename = ''
	"
else
	"
	let s:plugin_dir	= $HOME.'/.vim/'
	let s:home_dir	  = $HOME.'/'
  let s:escfilename = ' \%#[]'
	"
endif
"  Use of dictionaries  {{{1
"  Key word completion is enabled by the filetype plugin 'c.vim'
"  g:C_Dictionary_File  must be global
"          
if !exists("g:C_Dictionary_File")
  let g:C_Dictionary_File = s:plugin_dir.'c-support/wordlists/c-c++-keywords.list,'.
        \                   s:plugin_dir.'c-support/wordlists/k+r.list,'.
        \                   s:plugin_dir.'c-support/wordlists/stl_index.list'
endif
"
"  Modul global variables (with default values) which can be overridden. {{{1
"
let s:C_AuthorName     = ''
let s:C_AuthorRef      = ''
let s:C_Email          = ''
let s:C_Company        = ''
let s:C_Project        = ''
let s:C_CopyrightHolder= ''
"
let  s:C_Root          = '&C\/C\+\+.'           " the name of the root menu of this plugin
"
let s:C_LoadMenus      = 'yes'
" 
let s:C_CodeSnippets   = s:plugin_dir.'c-support/codesnippets/'
"                     
let s:C_CExtension     = 'c'                    " C file extension; everything else is C++
if	s:MSWIN
	let s:C_CCompiler      = 'gcc.exe'            " the C   compiler
	let s:C_CplusCompiler  = 'g++.exe'            " the C++ compiler
	let s:C_ObjExtension   = '.obj'               " file extension for objects (leading point required)
	let s:C_ExeExtension   = '.exe'               " file extension for executables (leading point required)
else
	let s:C_CCompiler      = 'gcc'                " the C   compiler
	let s:C_CplusCompiler  = 'g++'                " the C++ compiler
	let s:C_ObjExtension   = '.o'                 " file extension for objects (leading point required)
	let s:C_ExeExtension   = ''                   " file extension for executables (leading point required)
endif
let s:C_BraceOnNewLine = 'yes'
let s:C_CFlags         = '-Wall -g -O0 -c'      " compiler flags: compile, don't optimize
let s:C_Comments       = 'yes'
let s:C_CommentsToggle = 'no'
let s:C_IndentErrorLog = s:home_dir.'.indent.errorlog'
let s:C_LFlags         = '-Wall -g -O0'         " compiler flags: link   , don't optimize
let s:C_Libs           = '-lm'                  " libraries to use
let s:C_MenuHeader     = 'yes'
"  
"   ----- template files ---- ( 1. set of templates ) ----------------
let s:C_Template_Directory       = s:plugin_dir."c-support/templates/"
"
"   ----- C template files ---- ( 1. set of templates ) --------------
let s:C_Template_C_File          = 'c-file-header'
let s:C_Template_Class           = 'c-class-description'
let s:C_Template_Frame           = 'c-frame'
let s:C_Template_Function        = 'c-function-description'
let s:C_Template_H_File          = 'h-file-header'
let s:C_Template_Method          = 'c-method-description'
"   
"   ----- C++ template files -- ( 2. set of templates ) --------------
"   ----- If this set is empty the toggle will not appear. -
let s:Cpp_Template_C_File        = 'cpp-file-header'
let s:Cpp_Template_Class         = 'cpp-class-description'
let s:Cpp_Template_Frame         = 'cpp-frame'
let s:Cpp_Template_Function      = 'cpp-function-description'
let s:Cpp_Template_H_File        = 'hpp-file-header'
let s:Cpp_Template_Method        = 'cpp-method-description'
"   
"   ----- C++ class templates ----------------------------------------
let s:C_Class                    = 'c-class'
let s:C_ClassUsingNew            = 'c-class-using-new'
let s:C_ErrorClass               = 'c-error-class'
let s:C_TemplateClass            = 'c-template-class'
let s:C_TemplateClassUsingNew    = 'c-template-class-using-new'
"
let s:Cpp_Class                  = 'cpp-class'
let s:Cpp_ClassUsingNew          = 'cpp-class-using-new'
let s:Cpp_ErrorClass             = 'cpp-error-class'
let s:Cpp_TemplateClass          = 'cpp-template-class'
let s:Cpp_TemplateClassUsingNew  = 'cpp-template-class-using-new'
"
let s:C_CodeCheckExeName         = 'check'
let s:C_CodeCheckOptions         = '-K13'
let s:C_LineEndCommColDefault    = 49
let s:C_OutputGvim               = 'vim'
let s:C_Printheader              = "%<%f%h%m%<  %=%{strftime('%x %X')}     Page %N"
let s:C_XtermDefaults            = '-fa courier -fs 12 -geometry 80x24'
let s:C_Wrapper                  = s:plugin_dir.'c-support/scripts/wrapper.sh'
"   
"   ----- file extensions to be teated as C++ ------------------------
"
let s:C_TypeOfH                  = 'cpp'
"
"------------------------------------------------------------------------------
"
"  Look for global variables (if any), to override the defaults.
"  
function! C_CheckGlobal ( name )
  if exists('g:'.a:name)
    exe 'let s:'.a:name.'  = g:'.a:name
  endif
endfunction    " ----------  end of function C_CheckGlobal ----------
"
call C_CheckGlobal('C_AuthorName             ')
call C_CheckGlobal('C_AuthorRef              ')
call C_CheckGlobal('C_BraceOnNewLine         ')
call C_CheckGlobal('C_CCompiler              ')
call C_CheckGlobal('C_CExtension             ')
call C_CheckGlobal('C_CFlags                 ')
call C_CheckGlobal('C_Class                  ')
call C_CheckGlobal('C_ClassUsingNew          ')
call C_CheckGlobal('C_CodeCheckExeName       ')
call C_CheckGlobal('C_CodeCheckOptions       ')
call C_CheckGlobal('C_CodeSnippets           ')
call C_CheckGlobal('C_Comments               ')
call C_CheckGlobal('C_CommentsToggle         ')
call C_CheckGlobal('C_Company                ')
call C_CheckGlobal('C_CopyrightHolder        ')
call C_CheckGlobal('C_CplusCompiler          ')
call C_CheckGlobal('C_TypeOfH                ')
call C_CheckGlobal('C_Email                  ')
call C_CheckGlobal('C_ErrorClass             ')
call C_CheckGlobal('C_ExeExtension           ')
call C_CheckGlobal('C_IndentErrorLog         ')
call C_CheckGlobal('C_LFlags                 ')
call C_CheckGlobal('C_Libs                   ')
call C_CheckGlobal('C_LineEndCommColDefault  ')
call C_CheckGlobal('C_LoadMenus              ')
call C_CheckGlobal('C_MenuHeader             ')
call C_CheckGlobal('C_ObjExtension           ')
call C_CheckGlobal('C_OutputGvim             ')
call C_CheckGlobal('Cpp_Class                ')
call C_CheckGlobal('Cpp_ClassUsingNew        ')
call C_CheckGlobal('Cpp_ErrorClass           ')
call C_CheckGlobal('Cpp_Template_C_File      ')
call C_CheckGlobal('Cpp_Template_Class       ')
call C_CheckGlobal('Cpp_TemplateClass        ')
call C_CheckGlobal('Cpp_TemplateClassUsingNew')
call C_CheckGlobal('Cpp_Template_Frame       ')
call C_CheckGlobal('Cpp_Template_Function    ')
call C_CheckGlobal('Cpp_Template_H_File      ')
call C_CheckGlobal('Cpp_Template_Method      ')
call C_CheckGlobal('C_Printheader            ')
call C_CheckGlobal('C_Project                ')
call C_CheckGlobal('C_Root                   ')
call C_CheckGlobal('C_Template_C_File        ')
call C_CheckGlobal('C_Template_Class         ')
call C_CheckGlobal('C_TemplateClass          ')
call C_CheckGlobal('C_TemplateClassUsingNew  ')
call C_CheckGlobal('C_Template_Directory     ')
call C_CheckGlobal('C_Template_Frame         ')
call C_CheckGlobal('C_Template_Function      ')
call C_CheckGlobal('C_Template_H_File        ')
call C_CheckGlobal('C_Template_Method        ')
call C_CheckGlobal('C_XtermDefaults          ')
"
"----- some variables for internal use only -----------------------------------
"
let s:C_ClassName         = ''     " remember class name ; initially empty

if s:C_Comments=='yes'
  let s:C_Com1          = '/*'     " C-style : comment start 
  let s:C_Com2          = '*/'     " C-style : comment end
else
  let s:C_Com1          = '//'     " C++style : comment start 
  let s:C_Com2          = ''       " C++style : comment end
endif
"
" set default geometry if not specified 
" 
if match( s:C_XtermDefaults, "-geometry\\s\\+\\d\\+x\\d\\+" ) < 0
	let s:C_XtermDefaults	= s:C_XtermDefaults." -geometry 80x24"
endif
"
" escape the printheader
"
let s:C_Printheader  = escape( s:C_Printheader, ' %' )
"
let s:C_HlMessage    = ""
"
" characters that must be escaped for filenames
"
let s:C_If0_Counter   = 0
let s:C_If0_Txt		 		= "If0Label_"
"
let s:C_SplintIsExecutable	= 0
if executable( "splint" ) 
	let s:C_SplintIsExecutable	= 1
endif
"
let s:C_CodeCheckIsExecutable	= 0
if executable( s:C_CodeCheckExeName ) 
	let s:C_CodeCheckIsExecutable	= 1
endif
"
"------------------------------------------------------------------------------
"  C : C_InitC                              {{{1
"  Initialization of C support menus
"------------------------------------------------------------------------------
"
function! C_InitC ()
	"
	"===============================================================================================
	"----- Menu : C main menu entry -------------------------------------------   {{{2
	"===============================================================================================
	"
	if s:C_Root != ""
		if s:C_MenuHeader == 'yes'
			exe "amenu  ".s:C_Root.'C\/C\+\+   <Esc>'
			exe "amenu  ".s:C_Root.'-Sep00-         :'
		endif
	endif
	"
	"===============================================================================================
	"----- Menu : C-Comments --------------------------------------------------   {{{2
	"===============================================================================================
	"
	if s:C_MenuHeader == 'yes'
		exe "amenu  ".s:C_Root.'&Comments.&Comments<Tab>C\/C\+\+             <Esc>'
		exe "amenu  ".s:C_Root.'&Comments.-Sep00-                            :'
	endif
	exe "amenu <silent> ".s:C_Root.'&Comments.end-of-&line\ comment           <Esc><Esc><Esc>:call C_LineEndComment( )<CR>a'
	exe "vmenu <silent> ".s:C_Root.'&Comments.end-of-&line\ comment           <Esc><Esc><Esc>:call C_MultiLineEndComments( )<CR>a'

	exe "amenu <silent> ".s:C_Root.'&Comments.ad&just\ end-of-line\ com\.     <Esc><Esc>:call C_AdjustLineEndComm("a")<CR>'
	exe "vmenu <silent> ".s:C_Root.'&Comments.ad&just\ end-of-line\ com\.     <Esc><Esc>:call C_AdjustLineEndComm("v")<CR>'

	exe "amenu <silent> ".s:C_Root.'&Comments.&set\ end-of-line\ com\.\ col\. <Esc><Esc>:call C_GetLineEndCommCol()<CR>'
	
	exe "amenu          ".s:C_Root.'&Comments.mult&iline\ com\.\ \/*\ *\/     <Esc><Esc>o/*<CR>/<Esc>kA<Space>'
	exe "vmenu <silent> ".s:C_Root.'&Comments.mult&iline\ com\.\ \/*\ *\/     <Esc><Esc>:call C_CodeComment("v","yes")<CR><Esc>:nohlsearch<CR>'

	exe "amenu  ".s:C_Root.'&Comments.-SEP10-                              :'
	exe "amenu <silent> ".s:C_Root.'&Comments.code\ ->\ comment\ \/&*\ *\/   <Esc><Esc>:call C_CodeComment("a","yes")<CR><Esc>:nohlsearch<CR>j'
	exe "vmenu <silent> ".s:C_Root.'&Comments.code\ ->\ comment\ \/&*\ *\/   <Esc><Esc>:call C_CodeComment("v","yes")<CR><Esc>:nohlsearch<CR>j'
	exe "amenu <silent> ".s:C_Root.'&Comments.code\ ->\ comment\ &\/\/       <Esc><Esc>:call C_CodeComment("a","no")<CR><Esc>:nohlsearch<CR>j'
	exe "vmenu <silent> ".s:C_Root.'&Comments.code\ ->\ comment\ &\/\/       <Esc><Esc>:call C_CodeComment("v","no")<CR><Esc>:nohlsearch<CR>j'
	exe "amenu <silent> ".s:C_Root.'&Comments.c&omment\ ->\ code             <Esc><Esc>:call C_CommentCode("a")<CR><Esc>:nohlsearch<CR>'
	exe "vmenu <silent> ".s:C_Root.'&Comments.c&omment\ ->\ code             <Esc><Esc>:call C_CommentCode("v")<CR><Esc>:nohlsearch<CR>'
	
	exe "amenu          ".s:C_Root.'&Comments.-SEP0-                  :'
	exe "amenu <silent> ".s:C_Root.'&Comments.&frame\ comment         <Esc><Esc>:call C_CommentTemplates("frame")<CR>'
	exe "amenu <silent> ".s:C_Root.'&Comments.f&unction\ description  <Esc><Esc>:call C_CommentTemplates("function")<CR>'
	exe "amenu          ".s:C_Root.'&Comments.-SEP1-                  :'
	exe "amenu <silent> ".s:C_Root.'&Comments.&method\ description    <Esc><Esc>:call C_CommentTemplates("method")<CR>'
	exe "amenu <silent> ".s:C_Root.'&Comments.cl&ass\ description     <Esc><Esc>:call C_CommentTemplates("class")<CR>'
	exe "amenu          ".s:C_Root.'&Comments.-SEP2-                  :'
	exe "amenu <silent> ".s:C_Root.'&Comments.C\/C\+\+-file\ header   <Esc><Esc>:call C_CommentTemplates("cheader")<CR>'
	exe "amenu <silent> ".s:C_Root.'&Comments.H-file\ header          <Esc><Esc>:call C_CommentTemplates("hheader")<CR>'
	exe "amenu          ".s:C_Root.'&Comments.-SEP3-                  :'
	"
	"----- Submenu : C-Comments : file sections  -------------------------------------------------------------
	"
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.file\ sections<Tab>C\/C\+\+            <Esc>'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.-Sep0-                                 :'
	"
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.&Header\ File\ Includes  '
				\'<Esc><Esc>:call C_CommentSection("HEADER FILE INCLUDES")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.Local\ &Macros           '
				\'<Esc><Esc>:call C_CommentSection("MACROS  -  LOCAL TO THIS SOURCE FILE")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.Local\ &Type\ Def\.      '
				\'<Esc><Esc>:call C_CommentSection("TYPE DEFINITIONS  -  LOCAL TO THIS SOURCE FILE")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.Local\ &Data\ Types      '
				\'<Esc><Esc>:call C_CommentSection("DATA TYPES  -  LOCAL TO THIS SOURCE FILE")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.Local\ &Variables        '
				\'<Esc><Esc>:call C_CommentSection("VARIABLES  -  LOCAL TO THIS SOURCE FILE")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.Local\ &Prototypes       '
				\'<Esc><Esc>:call C_CommentSection("PROTOTYPES  -  LOCAL TO THIS SOURCE FILE")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.&Exp\.\ Function\ Def\.  '
				\'<Esc><Esc>:call C_CommentSection("FUNCTION DEFINITIONS  -  EXPORTED FUNCTIONS")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.&Local\ Function\ Def\.  '
				\'<Esc><Esc>:call C_CommentSection("FUNCTION DEFINITIONS  -  LOCAL TO THIS SOURCE FILE")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.-SEP6-                   :'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.Local\ &Class\ Def\.     '
				\'<Esc><Esc>:call C_CommentSection("CLASS DEFINITIONS  -  LOCAL TO THIS SOURCE FILE")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.E&xp\.\ Class\ Impl\.    '
				\'<Esc><Esc>:call C_CommentSection("CLASS IMPLEMENTATIONS  -  EXPORTED CLASSES")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.L&ocal\ Class\ Impl\.    '
				\'<Esc><Esc>:call C_CommentSection("CLASS IMPLEMENTATIONS  -  LOCAL CLASSES")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.-SEP7-                   :'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.&All\ sections,\ C       '
				\'<Esc><Esc>:call C_Comment_C_SectionAll("c")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.All\ &sections,\ C++     '
				\'<Esc><Esc>:call C_Comment_C_SectionAll("cpp")<CR>'
	"
	"
	"----- Submenu : H-Comments : file sections  -------------------------------------------------------------
	"
	exe "amenu  ".s:C_Root.'&Comments.&H-file\ sections.H-file\ sections<Tab>C\/C\+\+                  <Esc>'
	exe "amenu  ".s:C_Root.'&Comments.&H-file\ sections.-Sep0-                         :'
	"'
	exe "amenu  ".s:C_Root.'&Comments.&H-file\ sections.&Header\ File\ Includes    '
				\'<Esc><Esc>:call C_CommentSection("HEADER FILE INCLUDES")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&H-file\ sections.Exported\ &Macros          '
				\'<Esc><Esc>:call C_CommentSection("EXPORTED MACROS")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&H-file\ sections.Exported\ &Type\ Def\.     '
				\'<Esc><Esc>:call C_CommentSection("EXPORTED TYPE DEFINITIONS")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&H-file\ sections.Exported\ &Data\ Types     '
				\'<Esc><Esc>:call C_CommentSection("EXPORTED DATA TYPES")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&H-file\ sections.Exported\ &Variables       '
				\'<Esc><Esc>:call C_CommentSection("EXPORTED VARIABLES")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&H-file\ sections.Exported\ &Funct\.\ Decl\. '
				\'<Esc><Esc>:call C_CommentSection("EXPORTED FUNCTION DECLARATIONS")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&H-file\ sections.-SEP4-                     :'
	exe "amenu  ".s:C_Root.'&Comments.&H-file\ sections.E&xported\ Class\ Def\.    '
				\'<Esc><Esc>:call C_CommentSection("EXPORTED CLASS DEFINITIONS")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&H-file\ sections.-SEP5-                     :'
	exe "amenu  ".s:C_Root.'&Comments.&H-file\ sections.&All\ sections,\ C         '
				\'<Esc><Esc>:call C_Comment_H_SectionAll("c")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&H-file\ sections.All\ &sections,\ C++       '
				\'<Esc><Esc>:call C_Comment_H_SectionAll("cpp")<CR>'
	"
	exe "amenu  ".s:C_Root.'&Comments.-SEP8-                        :'
	"
	"----- Submenu : C-Comments : keyword comments  ----------------------------------------------------------
	"
	exe "amenu  ".s:C_Root.'&Comments.&KEYWORD+comm\..keyw\.+comm\.<Tab>C\/C\+\+     <Esc>'
	exe "amenu  ".s:C_Root.'&Comments.&KEYWORD+comm\..-Sep0-            :'
	exe "amenu  ".s:C_Root.'&Comments.&KEYWORD+comm\..\:&BUG\:          <Esc><Esc>$<Esc>:call C_CommentClassified("BUG")        <CR>kgJ$F:la'
	exe "amenu  ".s:C_Root.'&Comments.&KEYWORD+comm\..\:&COMPILER\:     <Esc><Esc>$<Esc>:call C_CommentClassified("COMPILER")   <CR>kgJ$F:la'
	exe "amenu  ".s:C_Root.'&Comments.&KEYWORD+comm\..\:&TODO\:         <Esc><Esc>$<Esc>:call C_CommentClassified("TODO")       <CR>kgJ$F:la'
	exe "amenu  ".s:C_Root.'&Comments.&KEYWORD+comm\..\:T&RICKY\:       <Esc><Esc>$<Esc>:call C_CommentClassified("TRICKY")     <CR>kgJ$F:la'
	exe "amenu  ".s:C_Root.'&Comments.&KEYWORD+comm\..\:&WARNING\:      <Esc><Esc>$<Esc>:call C_CommentClassified("WARNING")    <CR>kgJ$F:la'
	exe "amenu  ".s:C_Root.'&Comments.&KEYWORD+comm\..\:W&ORKAROUND\:   <Esc><Esc>$<Esc>:call C_CommentClassified("WORKAROUND") <CR>kgJ$F:la'
	exe "amenu  ".s:C_Root.'&Comments.&KEYWORD+comm\..\:&new\ keyword\: <Esc><Esc>$<Esc>:call C_CommentClassified("")           <CR>kgJf:a'
	"
	"----- Submenu : C-Comments : special comments  ----------------------------------------------------------
	"
	exe "amenu  ".s:C_Root.'&Comments.&special\ comm\..special\ comm\.<Tab>C\/C\+\+         <Esc>'
	exe "amenu  ".s:C_Root.'&Comments.&special\ comm\..-Sep0-                :'
	exe "amenu  ".s:C_Root.'&Comments.&special\ comm\..&EMPTY                <Esc><Esc>$<Esc>:call C_CommentSpecial("EMPTY")                    <CR>kgJA'
	exe "amenu  ".s:C_Root.'&Comments.&special\ comm\..&FALL\ THROUGH        <Esc><Esc>$<Esc>:call C_CommentSpecial("FALL THROUGH")             <CR>kgJA'
	exe "amenu  ".s:C_Root.'&Comments.&special\ comm\..&IMPL\.\ TYPE\ CONV   <Esc><Esc>$<Esc>:call C_CommentSpecial("IMPLICIT TYPE CONVERSION") <CR>kgJA'
	exe "amenu  ".s:C_Root.'&Comments.&special\ comm\..&NO\ RETURN           <Esc><Esc>$<Esc>:call C_CommentSpecial("NO RETURN")                <CR>kgJA'
	exe "amenu  ".s:C_Root.'&Comments.&special\ comm\..NOT\ &REACHED         <Esc><Esc>$<Esc>:call C_CommentSpecial("NOT REACHED")              <CR>kgJA'
	exe "amenu  ".s:C_Root.'&Comments.&special\ comm\..&TO\ BE\ IMPL\.       <Esc><Esc>$<Esc>:call C_CommentSpecial("REMAINS TO BE IMPLEMENTED")<CR>kgJA'
	exe "amenu  ".s:C_Root.'&Comments.&special\ comm\..-SEP81-               :'
	exe "amenu  ".s:C_Root.'&Comments.&special\ comm\..constant\ type\ is\ &long\ (L)              <Esc><Esc>$<Esc>:call C_CommentSpecial("constant type is long")<CR>kgJA'
	exe "amenu  ".s:C_Root.'&Comments.&special\ comm\..constant\ type\ is\ &unsigned\ (U)          <Esc><Esc>$<Esc>:call C_CommentSpecial("constant type is unsigned")<CR>kgJA'
	exe "amenu  ".s:C_Root.'&Comments.&special\ comm\..constant\ type\ is\ unsigned\ l&ong\ (UL)   <Esc><Esc>$<Esc>:call C_CommentSpecial("constant type is unsigned long")<CR>kgJA'

	"
	exe "amenu  ".s:C_Root.'&Comments.-SEP9-                     :'
	"
	exe " menu  ".s:C_Root.'&Comments.&date                   a<C-R>=strftime("%x")<CR>'
	exe "imenu  ".s:C_Root.'&Comments.&date                    <C-R>=strftime("%x")<CR>'
	exe " menu  ".s:C_Root.'&Comments.date\ &time             a<C-R>=strftime("%x %X %Z")<CR>'
	exe "imenu  ".s:C_Root.'&Comments.date\ &time              <C-R>=strftime("%x %X %Z")<CR>'

	"
	"----- Submenu : C-Comments : Tags  ----------------------------------------------------------
	"
	exe "amenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).tags\ (plugin)<Tab>C\/C\+\+     <Esc>'
	exe "amenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).-Sep0-            :'
	"
	exe "amenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).&AUTHOR           a'.s:C_AuthorName."<Esc>"
	exe "amenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).AUTHOR&REF        a'.s:C_AuthorRef."<Esc>"
	exe "amenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).&COMPANY          a'.s:C_Company."<Esc>"
	exe "amenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).C&OPYRIGHTHOLDER  a'.s:C_CopyrightHolder."<Esc>"
	exe "amenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).&EMAIL            a'.s:C_Email."<Esc>"
	exe "amenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).&PROJECT          a'.s:C_Project."<Esc>"
                                       
	exe "imenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).&AUTHOR           <Esc>a'.s:C_AuthorName
	exe "imenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).AUTHOR&REF        <Esc>a'.s:C_AuthorRef
	exe "imenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).&COMPANY          <Esc>a'.s:C_Company
	exe "imenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).C&OPYRIGHTHOLDER  <Esc>a'.s:C_CopyrightHolder
	exe "imenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).&EMAIL            <Esc>a'.s:C_Email
	exe "imenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).&PROJECT          <Esc>a'.s:C_Project
	"
	if			s:Cpp_Template_C_File     != "" || 
				\	s:Cpp_Template_Class      != "" || 
				\	s:Cpp_Template_Frame      != "" || 
				\	s:Cpp_Template_Function   != "" || 
				\	s:Cpp_Template_H_File     != "" || 
				\	s:Cpp_Template_Method     != "" 

		exe "amenu  ".s:C_Root.'&Comments.-SEP11-                    :'
		exe "amenu  ".s:C_Root.'&Comments.&vim\ modeline             <Esc><Esc>:call C_CommentVimModeline()<CR>'
		exe "amenu  ".s:C_Root.'&Comments.-SEP12-                    :'
		if s:C_Comments == 'yes' 
			exe "amenu <silent> ".s:C_Root.'&Comments.\/\/\ xxx\ \ \ \ \ &->\ \ \/*\ xxx\ *\/    <Esc><Esc>:call C_CommentCppToC()<CR>'
			exe "vmenu <silent> ".s:C_Root.'&Comments.\/\/\ xxx\ \ \ \ \ &->\ \ \/*\ xxx\ *\/    <Esc><Esc>:'."'<,'>".'call C_CommentCppToC()<CR>'
			exe "amenu <silent> ".s:C_Root.'&Comments.st&yle\ C\ ->\ C\+\+                       <Esc><Esc>:call C_Toggle_C_Cpp()<CR>'
		else
			exe "amenu <silent> ".s:C_Root.'&Comments.\/*\ xxx\ *\/\ \ -&>\ \ \/\/\ xxx          <Esc><Esc>:call C_CommentCToCpp()<CR>'
			exe "vmenu <silent> ".s:C_Root.'&Comments.\/*\ xxx\ *\/\ \ -&>\ \ \/\/\ xxx          <Esc><Esc>:'."'<,'>".'call C_CommentCToCpp()<CR>'
			exe "amenu <silent> ".s:C_Root.'&Comments.st&yle\ C\+\+\ ->\ C                       <Esc><Esc>:call C_Toggle_C_Cpp()<CR>'
		endif
		"
	endif
	"===============================================================================================
	"----- Menu : C-Statements-------------------------------------------------   {{{2
	"===============================================================================================
	"
	if s:C_MenuHeader == 'yes'
		exe "amenu  ".s:C_Root.'&Statements.&Statements<Tab>C\/C\+\+     <Esc>'
		exe "amenu  ".s:C_Root.'&Statements.-Sep00-                      :'
	endif
	"
	exe "amenu <silent>".s:C_Root.'&Statements.&do\ \{\ \}\ while          <Esc><Esc>:call C_DoWhile("a")<CR><Esc>f(la'
	exe "vmenu <silent>".s:C_Root.'&Statements.&do\ \{\ \}\ while          <Esc><Esc>:call C_DoWhile("v")<CR><Esc>f(la'
	"
	exe "amenu <silent>".s:C_Root.'&Statements.f&or                        <Esc><Esc>:call C_Stat("a","for ( ; ; )")<Esc>f;i'
	exe "vmenu <silent>".s:C_Root.'&Statements.f&or                        <Esc><Esc>:call C_Stat("v","for ( ; ; )")<Esc>f;i'
	"
	exe "amenu <silent>".s:C_Root.'&Statements.fo&r\ \{\ \}                <Esc><Esc>:call C_StatBlock("a","for ( ; ; )")<Esc>f;i'
	exe "vmenu <silent>".s:C_Root.'&Statements.fo&r\ \{\ \}                <Esc><Esc>:call C_StatBlock("v","for ( ; ; )")<Esc>f;i'
	"
	exe "amenu <silent>".s:C_Root.'&Statements.&if                         <Esc><Esc>:call C_Stat("a","if (  )")<Esc>f(la'
	exe "vmenu <silent>".s:C_Root.'&Statements.&if                         <Esc><Esc>:call C_Stat("v","if (  )")<Esc>f(la'
	"
	exe "amenu <silent>".s:C_Root.'&Statements.i&f\ \{\ \}                 <Esc><Esc>:call C_StatBlock("a","if (  )")<Esc>f(la'
	exe "vmenu <silent>".s:C_Root.'&Statements.i&f\ \{\ \}                 <Esc><Esc>:call C_StatBlock("v","if (  )")<Esc>f(la'

	exe "amenu <silent>".s:C_Root.'&Statements.if\ &else                   <Esc><Esc>:call C_IfElse("a")<Esc>f(la'
	exe "vmenu <silent>".s:C_Root.'&Statements.if\ &else                   <Esc><Esc>:call C_IfElse("v")<Esc>f(la'
	"
	exe "amenu <silent>".s:C_Root.'&Statements.if\ \{\ \}\ e&lse\ \{\ \}   <Esc><Esc>:call C_IfBlockElse("a")<Esc>f(la'
	exe "vmenu <silent>".s:C_Root.'&Statements.if\ \{\ \}\ e&lse\ \{\ \}   <Esc><Esc>:call C_IfBlockElse("v")<Esc>f(la'
	"
	exe "amenu <silent>".s:C_Root.'&Statements.&while                      <Esc><Esc>:call C_Stat("a","while (  )")<Esc>f(la'
	exe "vmenu <silent>".s:C_Root.'&Statements.&while                      <Esc><Esc>:call C_Stat("v","while (  )")<Esc>f(la'
	"
	exe "amenu <silent>".s:C_Root.'&Statements.w&hile\ \{\ \}              <Esc><Esc>:call C_StatBlock("a","while (  )")<Esc>f(la'
	exe "vmenu <silent>".s:C_Root.'&Statements.w&hile\ \{\ \}              <Esc><Esc>:call C_StatBlock("v","while (  )")<Esc>f(la'
	"
	exe "amenu <silent>".s:C_Root.'&Statements.&switch\ \{\ \}             <Esc><Esc>:call C_CodeSwitch()<Esc>f(la'
	exe "vmenu <silent>".s:C_Root.'&Statements.&switch\ \{\ \}             <Esc><Esc>:call C_CodeSwitchVisual()<Esc>f(la'
	"
	exe "amenu  ".s:C_Root.'&Statements.&case\ \.\.\.\ break               <Esc><Esc>ocase 0:<Tab><CR>break;<CR><Esc>2kf0s'
	exe "vmenu  ".s:C_Root."&Statements.&case\\ \\.\\.\\.\\ break          <Esc><Esc>:call C_CodeCaseVisual()<Esc>"
	"
	"
	exe "amenu <silent>".s:C_Root.'&Statements.&\{\ \}                     <Esc><Esc>:call C_Block("a")<CR>o'
	exe "vmenu <silent>".s:C_Root.'&Statements.&\{\ \}                   	<Esc><Esc>:call C_Block("v")<CR>'
	"
	"
	"===============================================================================================
	"----- Menu : C-Idioms ----------------------------------------------------   {{{2
	"===============================================================================================
	"
	if s:C_MenuHeader == 'yes'
		exe "amenu          ".s:C_Root.'&Idioms.&Idioms<Tab>C\/C\+\+       <Esc>'
		exe "amenu          ".s:C_Root.'&Idioms.-Sep00-                   :'
	endif
	exe "amenu <silent> ".s:C_Root.'&Idioms.&function                   <Esc><Esc>:call C_CodeFunction("a")<CR>'
	exe "vmenu <silent> ".s:C_Root.'&Idioms.&function                   <Esc><Esc>:call C_CodeFunction("v")<CR>'
	exe "amenu <silent> ".s:C_Root.'&Idioms.s&tatic\ function           <Esc><Esc>:call C_CodeFunction("sa")<CR>w'
	exe "vmenu <silent> ".s:C_Root.'&Idioms.s&tatic\ function           <Esc><Esc>:call C_CodeFunction("sv")<CR>w'
	exe "amenu <silent> ".s:C_Root.'&Idioms.&main                       <Esc><Esc>:call C_CodeMain("a")<CR>3jA'
	exe "vmenu <silent> ".s:C_Root.'&Idioms.&main                       <Esc><Esc>:call C_CodeMain("v")<CR>'

	exe "amenu          ".s:C_Root.'&Idioms.-SEP1-                      :'
	exe "amenu          ".s:C_Root.'&Idioms.for(x=&0;\ x<n;\ x\+=1)     <Esc><Esc>:call C_CodeFor("up"  , "a")<CR>a'
	exe "amenu          ".s:C_Root.'&Idioms.for(x=&n-1;\ x>=0;\ x\-=1)  <Esc><Esc>:call C_CodeFor("down", "a")<CR>a'
	exe "vmenu          ".s:C_Root.'&Idioms.for(x=&0;\ x<n;\ x\+=1)     <Esc><Esc>:call C_CodeFor("up"  , "v")<CR>'
	exe "vmenu          ".s:C_Root.'&Idioms.for(x=&n-1;\ x>=0;\ x\-=1)  <Esc><Esc>:call C_CodeFor("down", "v")<CR>'
	
	exe "amenu          ".s:C_Root.'&Idioms.-SEP2-                      :'
	exe "amenu <silent> ".s:C_Root.'&Idioms.&enum\+typedef              <Esc><Esc>:call C_EST("enum")<CR>o'
	exe "amenu <silent> ".s:C_Root.'&Idioms.&struct\+typedef            <Esc><Esc>:call C_EST("struct")<CR>o'
	exe "amenu <silent> ".s:C_Root.'&Idioms.&union\+typedef             <Esc><Esc>:call C_EST("union")<CR>o'
	exe "amenu          ".s:C_Root.'&Idioms.-SEP3-                      :'
	"
	exe " noremenu          ".s:C_Root.'&Idioms.&printf                     <Esc><Esc>oprintf("\n");<Esc>2F"a'
	exe "inoremenu          ".s:C_Root.'&Idioms.&printf                                printf("\n");<Esc>2F"a'
	
	exe " noremenu          ".s:C_Root.'&Idioms.s&canf                      <Esc><Esc>oscanf("", & );<Esc>F"i'
	exe "inoremenu          ".s:C_Root.'&Idioms.s&canf                                 scanf("", & );<Esc>F"i'
	"
	exe "amenu          ".s:C_Root.'&Idioms.-SEP4-                       :'
	exe "amenu <silent> ".s:C_Root.'&Idioms.p=ca&lloc\(n,sizeof(type)\)  <Esc><Esc>:call C_CodeMalloc("c")<CR>i'
	exe "amenu <silent> ".s:C_Root.'&Idioms.p=m&alloc\(sizeof(type)\)    <Esc><Esc>:call C_CodeMalloc("m")<CR>i'
	"
	exe "anoremenu <silent> ".s:C_Root.'&Idioms.si&zeof(\ \)             isizeof()<Left>'
	exe "inoremenu <silent> ".s:C_Root.'&Idioms.si&zeof(\ \)             sizeof()<Left>'
	exe "vnoremenu <silent> ".s:C_Root.'&Idioms.si&zeof(\ \)             ssizeof()<Esc>P'
	"
	exe "anoremenu <silent> ".s:C_Root.'&Idioms.asse&rt(\ \)             oassert();<Left><Left>'
	exe "vnoremenu <silent> ".s:C_Root.'&Idioms.asse&rt(\ \)             sassert();<Esc>F(p'
	exe "amenu          ".s:C_Root.'&Idioms.-SEP5-                       :'
	exe "amenu <silent> ".s:C_Root.'&Idioms.open\ &input\ file           <Esc><Esc>:call C_CodeFopen("input")<CR>jf"a'
	exe "amenu <silent> ".s:C_Root.'&Idioms.open\ &output\ file          <Esc><Esc>:call C_CodeFopen("output")<CR>jf"a'
"	exe "imenu          ".s:C_Root.'&Idioms.-SEP7-                       :'
	"                                      
	"===============================================================================================
	"----- Menu : C-Preprocessor ----------------------------------------------   {{{2
	"===============================================================================================
	"
	if s:C_MenuHeader == 'yes'
		exe "amenu  ".s:C_Root.'&Preprocessor.&Preprocessor<Tab>C\/C\+\+     <Esc>'
		exe "amenu  ".s:C_Root.'&Preprocessor.-Sep00-                      :'
	endif
	"
	"----- Submenu : C-Idioms: standard library -------------------------------------------------------
	"'
	exe "amenu  ".s:C_Root.'&Preprocessor.#include\ &Std\.Lib\..Std\.Lib\.<Tab>C\/C\+\+  <Esc>'
	exe "amenu  ".s:C_Root.'&Preprocessor.#include\ &Std\.Lib\..-Sep0-         :'
	"
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ &Std\.Lib\..&assert\.h     <Esc><Esc>o#include<Tab><assert.h>'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ &Std\.Lib\..&ctype\.h      <Esc><Esc>o#include<Tab><ctype.h>'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ &Std\.Lib\..&errno\.h      <Esc><Esc>o#include<Tab><errno.h>'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ &Std\.Lib\..&float\.h      <Esc><Esc>o#include<Tab><float.h>'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ &Std\.Lib\..&limits\.h     <Esc><Esc>o#include<Tab><limits.h>'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ &Std\.Lib\..l&ocale\.h     <Esc><Esc>o#include<Tab><locale.h>'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ &Std\.Lib\..&math\.h       <Esc><Esc>o#include<Tab><math.h>'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ &Std\.Lib\..set&jmp\.h     <Esc><Esc>o#include<Tab><setjmp.h>'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ &Std\.Lib\..s&ignal\.h     <Esc><Esc>o#include<Tab><signal.h>'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ &Std\.Lib\..stdar&g\.h     <Esc><Esc>o#include<Tab><stdarg.h>'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ &Std\.Lib\..st&ddef\.h     <Esc><Esc>o#include<Tab><stddef.h>'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ &Std\.Lib\..&stdio\.h      <Esc><Esc>o#include<Tab><stdio.h>'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ &Std\.Lib\..stdli&b\.h     <Esc><Esc>o#include<Tab><stdlib.h>'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ &Std\.Lib\..st&ring\.h     <Esc><Esc>o#include<Tab><string.h>'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ &Std\.Lib\..&time\.h       <Esc><Esc>o#include<Tab><time.h>'
	"
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ C&99.C99<Tab>C\/C\+\+         <Esc>'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ C&99.-Sep0-                :'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ C&99.&complex\.h           <Esc><Esc>o#include<Tab><complex.h>'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ C&99.&fenv\.h              <Esc><Esc>o#include<Tab><fenv.h>'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ C&99.&inttypes\.h          <Esc><Esc>o#include<Tab><inttypes.h>'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ C&99.is&o646\.h            <Esc><Esc>o#include<Tab><iso646.h>'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ C&99.&stdbool\.h           <Esc><Esc>o#include<Tab><stdbool.h>'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ C&99.s&tdint\.h            <Esc><Esc>o#include<Tab><stdint.h>'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ C&99.tg&math\.h            <Esc><Esc>o#include<Tab><tgmath.h>'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ C&99.&wchar\.h             <Esc><Esc>o#include<Tab><wchar.h>'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ C&99.wct&ype\.h            <Esc><Esc>o#include<Tab><wctype.h>'
	"
	exe "amenu  ".s:C_Root.'&Preprocessor.-SEP2-                        :'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ &\<\.\.\.\>      <Esc><Esc>o#include<Tab><><Left>'
	exe "anoremenu  ".s:C_Root.'&Preprocessor.#include\ &\"\.\.\.\"      <Esc><Esc>o#include<Tab>""<Left>'
	exe "amenu  ".s:C_Root.'&Preprocessor.#&define                       <Esc><Esc>:call C_PPDefine()<CR>f<Tab>a'
	exe "amenu  ".s:C_Root.'&Preprocessor.&#undef                        <Esc><Esc>:call C_PPUndef()<CR>f<Tab>a'
	"
	exe "amenu  ".s:C_Root.'&Preprocessor.#&if\ #else\ #endif            <Esc><Esc>:call C_PPIfElse("if"    ,"a+")<CR>'
	exe "amenu  ".s:C_Root.'&Preprocessor.#i&fdef\ #else\ #endif         <Esc><Esc>:call C_PPIfElse("ifdef" ,"a+")<CR>'
	exe "amenu  ".s:C_Root.'&Preprocessor.#if&ndef\ #else\ #endif        <Esc><Esc>:call C_PPIfElse("ifndef","a+")<CR>'
	exe "amenu  ".s:C_Root.'&Preprocessor.#ifnd&ef\ #def\ #endif         <Esc><Esc>:call C_PPifndef(         "a" )<CR>2ji'
	exe "amenu  ".s:C_Root.'&Preprocessor.#if\ &0\ #endif                <Esc><Esc>:call C_PPIf0("a")<CR>2ji'
	"
	exe "vmenu  ".s:C_Root.'&Preprocessor.#&if\ #else\ #endif            <Esc><Esc>:call C_PPIfElse("if"    ,"v+")<CR>'
	exe "vmenu  ".s:C_Root.'&Preprocessor.#i&fdef\ #else\ #endif         <Esc><Esc>:call C_PPIfElse("ifdef" ,"v+")<CR>'
	exe "vmenu  ".s:C_Root.'&Preprocessor.#if&ndef\ #else\ #endif        <Esc><Esc>:call C_PPIfElse("ifndef","v+")<CR>'
	exe "vmenu  ".s:C_Root.'&Preprocessor.#ifnd&ef\ #def\ #endif         <Esc><Esc>:call C_PPifndef(         "v" )<CR>'
	exe "vmenu  ".s:C_Root.'&Preprocessor.#if\ &0\ #endif                <Esc><Esc>:call C_PPIf0("v")<CR>'
	"
	exe "amenu  <silent> ".s:C_Root.'&Preprocessor.&remove\ #if\ 0\ #endif        <Esc><Esc>:call C_PPIf0Remove()<CR>'
	"
	"===============================================================================================
	"----- Menu : Snippets ----------------------------------------------------   {{{2
	"===============================================================================================
	"
	if s:C_MenuHeader == 'yes'
		exe "amenu           ".s:C_Root.'S&nippets.S&nippets<Tab>C\/C\+\+       <Esc>'
		exe "amenu           ".s:C_Root.'S&nippets.-Sep00-                      :'
	endif
	if s:C_CodeSnippets != ""
		exe "amenu  <silent> ".s:C_Root.'S&nippets.&read\ code\ snippet   <C-C>:call C_CodeSnippet("r")<CR>'
		exe "amenu  <silent> ".s:C_Root.'S&nippets.&write\ code\ snippet  <C-C>:call C_CodeSnippet("w")<CR>'
		exe "vmenu  <silent> ".s:C_Root.'S&nippets.&write\ code\ snippet  <C-C>:call C_CodeSnippet("wv")<CR>'
		exe "amenu  <silent> ".s:C_Root.'S&nippets.&edit\ code\ snippet   <C-C>:call C_CodeSnippet("e")<CR>'
		exe " menu  <silent> ".s:C_Root.'S&nippets.-SEP1-									:'
	endif
	exe " menu  <silent> ".s:C_Root.'S&nippets.&pick\ up\ prototype   	<C-C>:call C_ProtoPick("n")<CR>'
	exe "vmenu  <silent> ".s:C_Root.'S&nippets.&pick\ up\ prototype   	<C-C>:call C_ProtoPick("v")<CR>'
	exe " menu  <silent> ".s:C_Root.'S&nippets.&insert\ prototype(s)  	<C-C>:call C_ProtoInsert()<CR>'
	exe " menu  <silent> ".s:C_Root.'S&nippets.&clear\ prototype(s)			<C-C>:call C_ProtoClear()<CR>'
	exe " menu  <silent> ".s:C_Root.'S&nippets.&show\ prototype(s)			<C-C>:call C_ProtoShow()<CR>'

	"
	"===============================================================================================
	"----- Menu : C++ ---------------------------------------------------------   {{{2
	"===============================================================================================
	"
	if s:C_MenuHeader == 'yes'
		exe "amenu  ".s:C_Root.'C&++.C&\+\+<Tab>C\/C\+\+          <Esc>'
		exe "amenu  ".s:C_Root.'C&++.-Sep00-                     :'
	endif
	exe " noremenu ".s:C_Root.'C&++.c&in                 <Esc><Esc>ocin<Tab>>> ;<Esc>i'
	exe " noremenu ".s:C_Root.'C&++.cout\ &variable      <Esc><Esc>ocout<Tab><<  << endl;<Esc>2F<hi'
	exe " noremenu ".s:C_Root.'C&++.cout\ &string        <Esc><Esc>ocout<Tab><< "\n";<Esc>2F"a'
	exe " noremenu ".s:C_Root.'C&++.<<\ &\"\"            i<< "" <Left><Left>'
	"
	exe "inoremenu ".s:C_Root.'C&++.c&in                 cin<Tab>>> ;<Esc>i'
	exe "inoremenu ".s:C_Root.'C&++.cout\ &variable      cout<Tab><<  << endl;<Esc>2F<hi'
	exe "inoremenu ".s:C_Root.'C&++.cout\ &string        cout<Tab><< "\n";<Esc>2F"a'
	exe "inoremenu ".s:C_Root.'C&++.<<\ &\"\"            << "" <Left><Left>'
	"
	"----- Submenu : C++ : output manipulators  -------------------------------------------------------
	"
	exe "amenu ".s:C_Root.'C&++.&output\ manipulators.output\ manip\.<Tab>C\/C\+\+              <Esc>'
	exe "amenu ".s:C_Root.'C&++.&output\ manipulators.-Sep0-                     :'
	"
	exe " noremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ &boolalpha           i<< boolalpha<Space>'
	exe " noremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ &dec                 i<< dec<Space>'
	exe " noremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ &endl                i<< endl<Space>'
	exe " noremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ &fixed               i<< fixed<Space>'
	exe " noremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ fl&ush               i<< flush<Space>'
	exe " noremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ &hex                 i<< hex<Space>'
	exe " noremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ &internal            i<< internal<Space>'
	exe " noremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ &left                i<< left<Space>'
	exe " noremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ &oct                 i<< oct<Space>'
	exe " noremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ &right               i<< right<Space>'
	exe " noremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ s&cientific          i<< scientific<Space>'
	exe " noremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ &setbase\(\ \)       i<< setbase(10) <Left><Left>'
	exe " noremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ se&tfill\(\ \)       i<< setfill() <Left><Left>'
	exe " noremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ setiosfla&g\(\ \)    i<< setiosflags() <Left><Left>'
	exe " noremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ set&precision\(\ \)  i<< setprecision(6) <Left><Left>'
	exe " noremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ set&w\(\ \)          i<< setw(0) <Left><Left>'
	exe " noremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ showb&ase            i<< showbase<Space>'
	exe " noremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ showpoi&nt           i<< showpoint<Space>'
	exe " noremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ showpos\ \(&1\)      i<< showpos<Space>'
	exe " noremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ uppercase\ \(&2\)    i<< uppercase<Space>'
	"                                
	exe "inoremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ &boolalpha           << boolalpha<Space>'
	exe "inoremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ &dec                 << dec<Space>'
	exe "inoremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ &endl                << endl<Space>'
	exe "inoremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ &fixed               << fixed<Space>'
	exe "inoremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ fl&ush               << flush<Space>'
	exe "inoremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ &hex                 << hex<Space>'
	exe "inoremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ &internal            << internal<Space>'
	exe "inoremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ &left                << left<Space>'
	exe "inoremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ o&ct                 << oct<Space>'
	exe "inoremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ &right               << right<Space>'
	exe "inoremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ s&cientific          << scientific<Space>'
	exe "inoremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ &setbase\(\ \)       << setbase(10) <Left><Left>'
	exe "inoremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ se&tfill\(\ \)       << setfill() <Left><Left>'
	exe "inoremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ setiosfla&g\(\ \)    << setiosflags() <Left><Left>'
	exe "inoremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ set&precision\(\ \)  << setprecision(6) <Left><Left>'
	exe "inoremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ set&w\(\ \)          << setw(0) <Left><Left>'
	exe "inoremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ showb&ase            << showbase<Space>'
	exe "inoremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ showpoi&nt           << showpoint<Space>'
	exe "inoremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ showpos\ \(&1\)      << showpos<Space>'
	exe "inoremenu ".s:C_Root.'C&++.&output\ manipulators.\<\<\ uppercase\ \(&2\)    << uppercase<Space>'
	"
	"----- Submenu : C++ : ios flag bits  -------------------------------------------------------------
	"
	exe "amenu ".s:C_Root.'C&++.ios\ flag&bits.ios\ flags<Tab>C\/C\+\+        <Esc>'
	exe "amenu ".s:C_Root.'C&++.ios\ flag&bits.-Sep0-               :'
	"
	exe " noremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::&adjustfield      iios::adjustfield'
	exe " noremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::bas&efield        iios::basefield'
	exe " noremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::&boolalpha        iios::boolalpha'
	exe " noremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::&dec              iios::dec'
	exe " noremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::&fixed            iios::fixed'
	exe " noremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::floa&tfield       iios::floatfield'
	exe " noremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::&hex              iios::hex'
	exe " noremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::&internal         iios::internal'
	exe " noremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::&left             iios::left'
	exe " noremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::&oct              iios::oct'
	exe " noremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::&right            iios::right'
	exe " noremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::s&cientific       iios::scientific'
	exe " noremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::sho&wbase         iios::showbase'
	exe " noremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::showpoint\ \(&1\) iios::showpoint'
	exe " noremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::show&pos          iios::showpos'
	exe " noremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::&skipws           iios::skipws'
	exe " noremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::u&nitbuf          iios::unitbuf'
	exe " noremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::&uppercase        iios::uppercase'
	"
	exe "inoremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::&adjustfield      ios::adjustfield'
	exe "inoremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::bas&efield        ios::basefield'
	exe "inoremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::&boolalpha        ios::boolalpha'
	exe "inoremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::&dec              ios::dec'
	exe "inoremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::&fixed            ios::fixed'
	exe "inoremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::floa&tfield       ios::floatfield'
	exe "inoremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::&hex              ios::hex'
	exe "inoremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::&internal         ios::internal'
	exe "inoremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::&left             ios::left'
	exe "inoremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::&oct              ios::oct'
	exe "inoremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::&right            ios::right'
	exe "inoremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::s&cientific       ios::scientific'
	exe "inoremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::sho&wbase         ios::showbase'
	exe "inoremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::showpoint\ \(&1\) ios::showpoint'
	exe "inoremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::show&pos          ios::showpos'
	exe "inoremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::&skipws           ios::skipws'
	exe "inoremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::u&nitbuf          ios::unitbuf'
	exe "inoremenu ".s:C_Root.'C&++.ios\ flag&bits.ios::&uppercase        ios::uppercase'
	"
	"----- Submenu : C++   library  (algorithm - locale) ----------------------------------------------
	"
	exe "amenu ".s:C_Root.'C&++.#include\ <alg\.\.loc>\ \(&1\).alg\.\.loc<Tab>C\/C\+\+   <Esc>'
	exe "amenu ".s:C_Root.'C&++.#include\ <alg\.\.loc>\ \(&1\).-Sep0-          :'
	"
	exe "anoremenu ".s:C_Root.'C&++.#include\ <alg\.\.loc>\ \(&1\).&algorithm      <Esc><Esc>o#include<Tab><algorithm>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <alg\.\.loc>\ \(&1\).&bitset         <Esc><Esc>o#include<Tab><bitset>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <alg\.\.loc>\ \(&1\).&complex        <Esc><Esc>o#include<Tab><complex>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <alg\.\.loc>\ \(&1\).&deque          <Esc><Esc>o#include<Tab><deque>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <alg\.\.loc>\ \(&1\).&exception      <Esc><Esc>o#include<Tab><exception>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <alg\.\.loc>\ \(&1\).&fstream        <Esc><Esc>o#include<Tab><fstream>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <alg\.\.loc>\ \(&1\).f&unctional     <Esc><Esc>o#include<Tab><functional>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <alg\.\.loc>\ \(&1\).iomani&p        <Esc><Esc>o#include<Tab><iomanip>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <alg\.\.loc>\ \(&1\).&ios            <Esc><Esc>o#include<Tab><ios>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <alg\.\.loc>\ \(&1\).iosf&wd         <Esc><Esc>o#include<Tab><iosfwd>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <alg\.\.loc>\ \(&1\).io&stream       <Esc><Esc>o#include<Tab><iostream>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <alg\.\.loc>\ \(&1\).istrea&m        <Esc><Esc>o#include<Tab><istream>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <alg\.\.loc>\ \(&1\).iterato&r       <Esc><Esc>o#include<Tab><iterator>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <alg\.\.loc>\ \(&1\).&limits         <Esc><Esc>o#include<Tab><limits>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <alg\.\.loc>\ \(&1\).lis&t           <Esc><Esc>o#include<Tab><list>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <alg\.\.loc>\ \(&1\).l&ocale         <Esc><Esc>o#include<Tab><locale>'
	"
	"----- Submenu : C++   library  (map - vector) ----------------------------------------------------
	"
	exe "amenu ".s:C_Root.'C&++.#include\ <map\.\.vec>\ \(&2\).map\.\.vec<Tab>C\/C\+\+   <Esc>'
	exe "amenu ".s:C_Root.'C&++.#include\ <map\.\.vec>\ \(&2\).-Sep0-          :'

	exe "anoremenu ".s:C_Root.'C&++.#include\ <map\.\.vec>\ \(&2\).&map            <Esc><Esc>o#include<Tab><map>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <map\.\.vec>\ \(&2\).memor&y         <Esc><Esc>o#include<Tab><memory>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <map\.\.vec>\ \(&2\).&new            <Esc><Esc>o#include<Tab><new>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <map\.\.vec>\ \(&2\).numeri&c        <Esc><Esc>o#include<Tab><numeric>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <map\.\.vec>\ \(&2\).&ostream        <Esc><Esc>o#include<Tab><ostream>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <map\.\.vec>\ \(&2\).&queue          <Esc><Esc>o#include<Tab><queue>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <map\.\.vec>\ \(&2\).&set            <Esc><Esc>o#include<Tab><set>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <map\.\.vec>\ \(&2\).sst&ream        <Esc><Esc>o#include<Tab><sstream>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <map\.\.vec>\ \(&2\).st&ack          <Esc><Esc>o#include<Tab><stack>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <map\.\.vec>\ \(&2\).stde&xcept      <Esc><Esc>o#include<Tab><stdexcept>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <map\.\.vec>\ \(&2\).stream&buf      <Esc><Esc>o#include<Tab><streambuf>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <map\.\.vec>\ \(&2\).str&ing         <Esc><Esc>o#include<Tab><string>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <map\.\.vec>\ \(&2\).&typeinfo       <Esc><Esc>o#include<Tab><typeinfo>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <map\.\.vec>\ \(&2\).&utility        <Esc><Esc>o#include<Tab><utility>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <map\.\.vec>\ \(&2\).&valarray       <Esc><Esc>o#include<Tab><valarray>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <map\.\.vec>\ \(&2\).v&ector         <Esc><Esc>o#include<Tab><vector>'
	"
	"----- Submenu : C     library  (cassert - ctime) -------------------------------------------------
	"
	exe "amenu ".s:C_Root.'C&++.#include\ <cX>\ \(&3\).cX<Tab>C\/C\+\+ <Esc>'
	exe "amenu ".s:C_Root.'C&++.#include\ <cX>\ \(&3\).-Sep0-        :'
	"
	exe "anoremenu ".s:C_Root.'C&++.#include\ <cX>\ \(&3\).c&assert      <Esc><Esc>o#include<Tab><cassert>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <cX>\ \(&3\).c&ctype       <Esc><Esc>o#include<Tab><cctype>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <cX>\ \(&3\).c&errno       <Esc><Esc>o#include<Tab><cerrno>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <cX>\ \(&3\).c&float       <Esc><Esc>o#include<Tab><cfloat>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <cX>\ \(&3\).c&limits      <Esc><Esc>o#include<Tab><climits>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <cX>\ \(&3\).cl&ocale      <Esc><Esc>o#include<Tab><clocale>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <cX>\ \(&3\).c&math        <Esc><Esc>o#include<Tab><cmath>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <cX>\ \(&3\).cset&jmp      <Esc><Esc>o#include<Tab><csetjmp>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <cX>\ \(&3\).cs&ignal      <Esc><Esc>o#include<Tab><csignal>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <cX>\ \(&3\).cstdar&g      <Esc><Esc>o#include<Tab><cstdarg>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <cX>\ \(&3\).cst&ddef      <Esc><Esc>o#include<Tab><cstddef>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <cX>\ \(&3\).c&stdio       <Esc><Esc>o#include<Tab><cstdio>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <cX>\ \(&3\).cstdli&b      <Esc><Esc>o#include<Tab><cstdlib>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <cX>\ \(&3\).cst&ring      <Esc><Esc>o#include<Tab><cstring>'
	exe "anoremenu ".s:C_Root.'C&++.#include\ <cX>\ \(&3\).c&time        <Esc><Esc>o#include<Tab><ctime>'
	"
	"----- End Submenu : C     library  (cassert - ctime) ---------------------------------------------
	"
	exe "amenu <silent> ".s:C_Root.'C&++.-SEP2-                        :'
	exe "amenu <silent> ".s:C_Root.'C&++.&method\ implement\.          <Esc><Esc>:call C_CodeMethod()<CR>'

	exe "amenu <silent> ".s:C_Root.'C&++.&class                        <Esc><Esc>:call C_CommentTemplates("CppClass")<CR>'
	exe "amenu <silent> ".s:C_Root.'C&++.class\ (w\.\ &new)            <Esc><Esc>:call C_CommentTemplates("CppClassUsingNew")<CR>'
	exe "amenu <silent> ".s:C_Root.'C&++.&error\ class                 <Esc><Esc>:call C_CommentTemplates("CppErrorClass")<CR>'
	exe "amenu <silent> ".s:C_Root.'C&++.-SEP3-                        :'
	exe "amenu <silent> ".s:C_Root.'C&++.&templ\.\ class              <Esc><Esc>:call C_CommentTemplates("CppTemplateClass")<CR>'
	exe "amenu <silent> ".s:C_Root.'C&++.templ\.\ class\ (w\.\ ne&w)  <Esc><Esc>:call C_CommentTemplates("CppTemplateClassUsingNew")<CR>'

	exe "amenu <silent> ".s:C_Root.'C&++.templ\.\ &function           <Esc><Esc>:call C_CodeTemplateFunct()<CR>'
	exe "amenu <silent> ".s:C_Root.'C&++.-SEP4-                        :'
	exe "amenu <silent> ".s:C_Root.'C&++.operator\ &<<                <Esc><Esc>:call C_CodeOutputOperator()<CR>f.a'
	exe "amenu <silent> ".s:C_Root.'C&++.operator\ &>>                <Esc><Esc>:call C_CodeInputOperator()<CR>f.a'
	exe "amenu <silent> ".s:C_Root.'C&++.-SEP5-                        :'
	exe "amenu <silent> ".s:C_Root.'C&++.tr&y\ \.\.\ catch             <Esc><Esc>:call C_CodeTryCatch("a")<CR>o'
	exe "vmenu <silent> ".s:C_Root.'C&++.tr&y\ \.\.\ catch             <Esc><Esc>:call C_CodeTryCatch("v")<CR>f(fci'
	exe "amenu <silent> ".s:C_Root.'C&++.catc&h                        <Esc><Esc>:call C_CodeCatch("a"," const &ExceptObj ")<CR>f(fci'
	exe "vmenu <silent> ".s:C_Root.'C&++.catc&h                        <Esc><Esc>:call C_CodeCatch("v"," const &ExceptObj ")<CR>f(fci'

	exe "amenu <silent> ".s:C_Root.'C&++.catch\(&\.\.\.\)              <Esc><Esc>:call C_CodeCatch("a","...")<CR>'
	exe "vmenu <silent> ".s:C_Root.'C&++.catch\(&\.\.\.\)              <Esc><Esc>:call C_CodeCatch("v","...")<CR>'

	exe "amenu <silent> ".s:C_Root.'C&++.-SEP6-                        :'
	exe "amenu <silent> ".s:C_Root.'C&++.open\ input\ file\ \ \(&4\)   <Esc><Esc>:call C_CodeIOStream("ifstream")<CR>f"a'
	exe "amenu <silent> ".s:C_Root.'C&++.open\ output\ file\ \(&5\)    <Esc><Esc>:call C_CodeIOStream("ofstream")<CR>f"a'
	exe "amenu <silent> ".s:C_Root.'C&++.-SEP7-                        :'

	exe " menu <silent> ".s:C_Root.'C&++.&using\ namespace\ std;       <Esc><Esc>ousing namespace std;<CR>'
	exe " menu <silent> ".s:C_Root.'C&++.usin&g\ namespace\ ;          <Esc><Esc>ousing namespace ;<Esc>$i'
	exe "amenu <silent> ".s:C_Root.'C&++.namespace\ &\{\ \}            <Esc><Esc>:call C_Namespace("a")<CR>o'

	exe "imenu <silent> ".s:C_Root.'C&++.&using\ namespace\ std;       using namespace std;<CR>'
	exe "imenu <silent> ".s:C_Root.'C&++.usin&g\ namespace\ ;          using namespace ;<Esc>$i'
	exe "vmenu <silent> ".s:C_Root.'C&++.namespace\ &\{\ \}            <Esc><Esc>:call C_Namespace("v")<CR>'

	exe "amenu <silent> ".s:C_Root.'C&++.-SEP8-              :'
	"
	"----- Submenu : RTTI  ----------------------------------------------------------------------------
	"
	exe "amenu ".s:C_Root.'C&++.&RTTI.RTTI<Tab>C\/C\+\+          <Esc>'
	exe "amenu ".s:C_Root.'C&++.&RTTI.-Sep0-                 :'
	"
	exe " noremenu ".s:C_Root.'C&++.&RTTI.&typeid                atypeid()<Esc>hr(a'
	exe " noremenu ".s:C_Root.'C&++.&RTTI.&static_cast           astatic_cast<>()<Left>'
	exe " noremenu ".s:C_Root.'C&++.&RTTI.&const_cast            aconst_cast<>()<Left>'
	exe " noremenu ".s:C_Root.'C&++.&RTTI.&reinterpret_cast      areinterpret_cast<>()<Left>'
	exe " noremenu ".s:C_Root.'C&++.&RTTI.&dynamic_cast          adynamic_cast<>()<Left>'
	"
	exe "vnoremenu ".s:C_Root.'C&++.&RTTI.&typeid                stypeid()<Esc>hr(p'
	exe "vnoremenu ".s:C_Root.'C&++.&RTTI.&static_cast           sstatic_cast<>()<Esc>P'
	exe "vnoremenu ".s:C_Root.'C&++.&RTTI.&const_cast            sconst_cast<>()<Esc>P'
	exe "vnoremenu ".s:C_Root.'C&++.&RTTI.&reinterpret_cast      sreinterpret_cast<>()<Esc>P'
	exe "vnoremenu ".s:C_Root.'C&++.&RTTI.&dynamic_cast          sdynamic_cast<>()<Esc>P'
	"
	exe "inoremenu ".s:C_Root.'C&++.&RTTI.&typeid                typeid()<Esc>hr(a'
	exe "inoremenu ".s:C_Root.'C&++.&RTTI.&static_cast           static_cast<>()<Left>'
	exe "inoremenu ".s:C_Root.'C&++.&RTTI.&const_cast            const_cast<>()<Left>'
	exe "inoremenu ".s:C_Root.'C&++.&RTTI.&reinterpret_cast      reinterpret_cast<>()<Left>'
	exe "inoremenu ".s:C_Root.'C&++.&RTTI.&dynamic_cast          dynamic_cast<>()<Left>'
	"
	"----- End Submenu : RTTI  ------------------------------------------------------------------------
	"
	exe "amenu  <silent>".s:C_Root.'C&++.e&xtern\ \"C\"\ \{\ \}       <Esc><Esc>:call C_StatBlock("a","extern \"C\"")<Esc>'
	exe "vmenu  <silent>".s:C_Root.'C&++.e&xtern\ \"C\"\ \{\ \}       <Esc><Esc>:call C_StatBlock("v","extern \"C\"")<Esc>j'
	"
	"===============================================================================================
	"----- Menu : run  ----- --------------------------------------------------   {{{2
	"===============================================================================================
	"
	if s:C_MenuHeader == 'yes'
		exe "amenu  ".s:C_Root.'&Run.&Run<Tab>C\/C\+\+       <Esc>'
		exe "amenu  ".s:C_Root.'&Run.-Sep00-                 :'
	endif
	"
	exe "amenu  <silent>  ".s:C_Root.'&Run.save\ and\ &compile<Tab>\<A-F9\>    <C-C>:call C_Compile()<CR>:redraw<CR>:call C_HlMessage()<CR>'
	exe "amenu  <silent>  ".s:C_Root.'&Run.&link<Tab>\<F9\>                    <C-C>:call C_Link()<CR>:redraw<CR>:call C_HlMessage()<CR>'
	exe "amenu  <silent>  ".s:C_Root.'&Run.&run<Tab>\<C-F9\>                   <C-C>:call C_Run()<CR>'
	exe "amenu  <silent>  ".s:C_Root.'&Run.cmd\.\ line\ &arg\.<Tab>\<S-F9\>    <C-C>:call C_Arguments()<CR>'
	exe "amenu  <silent>  ".s:C_Root.'&Run.-SEP0-                              :'
	exe "amenu  <silent>  ".s:C_Root.'&Run.&make                               <C-C>:call C_Make()<CR>'
	exe "amenu  <silent>  ".s:C_Root.'&Run.cmd\.\ line\ ar&g\.\ for\ make      <C-C>:call C_MakeArguments()<CR>'
	exe "amenu  <silent>  ".s:C_Root.'&Run.-SEP1-                              :'
	if s:C_SplintIsExecutable==1
		exe "amenu  <silent>  ".s:C_Root.'&Run.s&plint                             <C-C>:call C_SplintCheck()<CR>:redraw<CR>:call C_HlMessage()<CR>'
		exe "amenu  <silent>  ".s:C_Root.'&Run.cmd\.\ line\ arg\.\ for\ spl&int    <C-C>:call C_SplintArguments()<CR>'
		exe "amenu  <silent>  ".s:C_Root.'&Run.-SEP2-                              :'
	endif
	"
	if s:C_CodeCheckIsExecutable==1
		exe "amenu  <silent>  ".s:C_Root.'&Run.CodeChec&k                          <C-C>:call C_CodeCheck()<CR>:redraw<CR>:call C_HlMessage()<CR>'
		exe "amenu  <silent>  ".s:C_Root.'&Run.cmd\.\ line\ arg\.\ for\ Cod&eCheck <C-C>:call C_CodeCheckArguments()<CR>'
		exe "amenu  <silent>  ".s:C_Root.'&Run.-SEP3-                              :'
	endif
	"
	exe "amenu            ".s:C_Root.'&Run.in&dent                             <C-C>:call C_Indent("a")<CR>:redraw<CR>:call C_HlMessage()<CR>'
	exe "vmenu            ".s:C_Root.'&Run.in&dent                             <C-C>:call C_Indent("v")<CR>:redraw<CR>:call C_HlMessage()<CR>'
	if	s:MSWIN
		exe "amenu  <silent>  ".s:C_Root.'&Run.&hardcopy\ to\ printer              <C-C>:call C_Hardcopy("n")<CR>'
		exe "vmenu  <silent>  ".s:C_Root.'&Run.&hardcopy\ to\ printer              <C-C>:call C_Hardcopy("v")<CR>'
	else
		exe "amenu  <silent>  ".s:C_Root.'&Run.&hardcopy\ to\ FILENAME\.ps         <C-C>:call C_Hardcopy("n")<CR>'
		exe "vmenu  <silent>  ".s:C_Root.'&Run.&hardcopy\ to\ FILENAME\.ps         <C-C>:call C_Hardcopy("v")<CR>'
	endif
	exe "imenu  <silent>  ".s:C_Root.'&Run.-SEP4-                              :'

	exe "amenu  <silent>  ".s:C_Root.'&Run.&settings                             <C-C>:call C_Settings()<CR>'
	exe "imenu  <silent>  ".s:C_Root.'&Run.-SEP5-                                :'

	if	!s:MSWIN
		exe "amenu  <silent>  ".s:C_Root.'&Run.&xterm\ size                             <C-C>:call C_XtermSize()<CR>'
	endif
	if s:C_OutputGvim == "vim" 
		exe "amenu  <silent>  ".s:C_Root.'&Run.&output:\ VIM->buffer->xterm            <C-C>:call C_Toggle_Gvim_Xterm()<CR><CR>'
	else
		if s:C_OutputGvim == "buffer" 
			exe "amenu  <silent>  ".s:C_Root.'&Run.&output:\ BUFFER->xterm->vim        <C-C>:call C_Toggle_Gvim_Xterm()<CR><CR>'
		else
			exe "amenu  <silent>  ".s:C_Root.'&Run.&output:\ XTERM->vim->buffer          <C-C>:call C_Toggle_Gvim_Xterm()<CR><CR>'
		endif
	endif
	"
	"===============================================================================================
	"----- Menu : help  -------------------------------------------------------   {{{2
	"===============================================================================================
	"
	if s:C_Root != ""
		exe "menu  <silent>  ".s:C_Root.'&help\ \(plugin\)     <C-C><C-C>:call C_HelpCsupport()<CR>'
	endif

endfunction    " ----------  end of function  C_InitC  ----------
"
"===============================================================================================
"----- Menu Functions --------------------------------------------------------------------------
"===============================================================================================
"
"------------------------------------------------------------------------------
"  C_Input: Input after a highlighted prompt     {{{1
"------------------------------------------------------------------------------
function! C_Input ( promp, text )
	echohl Search												" highlight prompt
	call inputsave()										" preserve typeahead
	let	retval=input( a:promp, a:text )	" read input
	call inputrestore()									" restore typeahead
	echohl None													" reset highlighting
	return retval
endfunction    " ----------  end of function C_Input ----------
"
"------------------------------------------------------------------------------
"  C_AdjustLineEndComm: adjust line-end comments     {{{1
"------------------------------------------------------------------------------
function! C_AdjustLineEndComm ( mode ) range
	"
	if !exists("b:C_LineEndCommentColumn")
		let	b:C_LineEndCommentColumn	= s:C_LineEndCommColDefault
	endif

	let save_cursor = getpos(".")

	let	save_expandtab	= &expandtab
	exe	":set expandtab"

	if a:mode == 'v'
		let pos0	= line("'<")
		let pos1	= line("'>")
	else
		let pos0	= line(".")
		let pos1	= pos0
	end

	let	linenumber	= pos0
	exe ":".pos0

	while linenumber <= pos1
		let	line= getline(".")
		" look for a C comment
		let idx1	= 1 + match( line, '\s*\/\*.\{-}\*\/' )
		let idx2	= 1 + match( line, '\/\*.\{-}\*\/' )
		if idx2 == 0					
			" look for a C++ comment
			let idx1	= 1 + match( line, '\s*\/\/.*$' )
			let idx2	= 1 + match( line, '\/\/.*$' )
		end

		let	ln	= line(".")
		call setpos(".", [ 0, ln, idx1, 0 ] )
		let vpos1	= virtcol(".")
		call setpos(".", [ 0, ln, idx2, 0 ] )
		let vpos2	= virtcol(".")

		if   ! (   vpos2 == b:C_LineEndCommentColumn 
					\	|| vpos1 > b:C_LineEndCommentColumn
					\	|| idx2  == 0 )

			exe ":.,.retab"
			" insert some spaces
			if vpos2 < b:C_LineEndCommentColumn
				let	diff	= b:C_LineEndCommentColumn-vpos2
				call setpos(".", [ 0, ln, vpos2, 0 ] )
				let	@"	= ' '
				exe "normal	".diff."P"
			end

			" remove some spaces
			if vpos1 < b:C_LineEndCommentColumn && vpos2 > b:C_LineEndCommentColumn
				let	diff	= vpos2 - b:C_LineEndCommentColumn
				call setpos(".", [ 0, ln, b:C_LineEndCommentColumn, 0 ] )
				exe "normal	".diff."x"
			end

		end
		let linenumber=linenumber+1
		normal j
	endwhile
	" restore tab expansion settings and cursor position
	let &expandtab	= save_expandtab
	call setpos('.', save_cursor)

endfunction		" ---------- end of function  C_AdjustLineEndComm  ----------
"
"------------------------------------------------------------------------------
"  C_GetLineEndCommCol: get line-end comment position    {{{1
"------------------------------------------------------------------------------
function! C_GetLineEndCommCol ()
	let actcol	= virtcol(".")
	if actcol+1 == virtcol("$")
		let	b:C_LineEndCommentColumn	= C_Input( 'start line-end comment at virtual column : ', actcol )
	else
		let	b:C_LineEndCommentColumn	= virtcol(".") 
	endif
  echomsg "line end comments will start at column  ".b:C_LineEndCommentColumn
endfunction		" ---------- end of function  C_GetLineEndCommCol  ----------
"
"------------------------------------------------------------------------------
"  C_LineEndComment: single line-end comment    {{{1
"------------------------------------------------------------------------------
function! C_LineEndComment ( )
	if !exists("b:C_LineEndCommentColumn")
		let	b:C_LineEndCommentColumn	= s:C_LineEndCommColDefault
	endif
	" ----- trim whitespaces -----
	exe 's/\s*$//'
	let linelength= virtcol("$") - 1
	if linelength < b:C_LineEndCommentColumn
		let diff	= b:C_LineEndCommentColumn -1 -linelength
		exe "normal	".diff."A "
	endif
	" append at least one blank
	if linelength >= b:C_LineEndCommentColumn
		exe "normal A "
	endif
	if s:C_Comments=="yes"
		exe "normal	$A".s:C_Com1."  ".s:C_Com2
		normal 3h
	else
		exe "normal	$A".s:C_Com1." ".s:C_Com2
	endif

endfunction		" ---------- end of function  C_LineEndComment  ----------
"
"------------------------------------------------------------------------------
"  C_MultiLineEndComments: multi line-end comments    {{{1
"------------------------------------------------------------------------------
function! C_MultiLineEndComments ( )
	"
  if !exists("b:C_LineEndCommentColumn")
		let	b:C_LineEndCommentColumn	= s:C_LineEndCommColDefault
  endif
	"
	let pos0	= line("'<")
	let pos1	= line("'>")
	"
	" ----- trim whitespaces -----
  exe pos0.','.pos1.'s/\s*$//'  
	" 
	" ----- find the longest line -----
	let	maxlength		= 0
	let	linenumber	= pos0
	normal '<
	while linenumber <= pos1
		if  getline(".") !~ "^\\s*$"  && maxlength<virtcol("$")
			let maxlength= virtcol("$")
		endif
		let linenumber=linenumber+1
		normal j
	endwhile
	"
	if maxlength < b:C_LineEndCommentColumn
	  let maxlength = b:C_LineEndCommentColumn
	else
	  let maxlength = maxlength+1		" at least 1 blank
	endif
	"
	" ----- fill lines with blanks -----
	let	linenumber	= pos0
	while linenumber <= pos1
		exe ":".linenumber
		if getline(".") !~ "^\\s*$"
			let diff	= maxlength - virtcol("$")
			exe "normal	".diff."A "
			if s:C_Comments=="yes"
				exe "normal	$A".s:C_Com1."  ".s:C_Com2
			else
				exe "normal	$A".s:C_Com1." ".s:C_Com2
			endif
		endif
		let linenumber=linenumber+1
	endwhile
	" ----- back to the begin of the marked block -----
	exe ":".pos0
	normal $
	if s:C_Comments=="yes"
		normal 3h
	endif
endfunction		" ---------- end of function  C_MultiLineEndComments  ----------
"
"------------------------------------------------------------------------------
"  C_CommentClassified : classified comments    {{{1
"------------------------------------------------------------------------------
function! C_CommentClassified (class)
  	put = '	'.s:C_Com1.' :'.a:class.':'.strftime(\"%x %X\").':'.s:C_AuthorRef.':  '.s:C_Com2
endfunction    " ----------  end of function C_CommentClassified ----------
"
"------------------------------------------------------------------------------
"  C_CommentSpecial : special comments    {{{1
"------------------------------------------------------------------------------
function! C_CommentSpecial (special)
  	put = '	'.s:C_Com1.' '.a:special.' '.s:C_Com2
endfunction    " ----------  end of function C_CommentSpecial ----------
"
"------------------------------------------------------------------------------
"  C_CommentSection : Section Comments    {{{1
"------------------------------------------------------------------------------
function! C_CommentSection (keyword)
	let zz=   s:C_Com1." #####   ".a:keyword."   "
	put =zz
	if s:C_Comments == 'yes' 
		let	n = 88-strlen(zz)-3								" 3 : ' */'
		exe "normal	".n."A#"
		exe "normal	A"." ".s:C_Com2
	else
		let	n = 88-strlen(zz)
		exe "normal	".n."A#"
	endif	
	let	zz="\n"
	put =zz
endfunction    " ----------  end of function C_CommentSection ----------
"
"------------------------------------------------------------------------------
"  C_Comment_C_SectionAll: Section Comments    {{{1
"------------------------------------------------------------------------------
"
function! C_Comment_C_SectionAll ( type )
	call C_CommentSection("HEADER FILE INCLUDES")
  call C_CommentSection("MACROS  -  LOCAL TO THIS SOURCE FILE")
  call C_CommentSection("TYPE DEFINITIONS  -  LOCAL TO THIS SOURCE FILE")
  call C_CommentSection("DATA TYPES  -  LOCAL TO THIS SOURCE FILE")
	if a:type=="cpp"
		call C_CommentSection("CLASS DEFINITIONS  -  LOCAL TO THIS SOURCE FILE")
	end
  call C_CommentSection("VARIABLES  -  LOCAL TO THIS SOURCE FILE")
  call C_CommentSection("PROTOTYPES  -  LOCAL TO THIS SOURCE FILE")
	call C_CommentSection("FUNCTION DEFINITIONS  -  EXPORTED FUNCTIONS")
	call C_CommentSection("FUNCTION DEFINITIONS  -  LOCAL TO THIS SOURCE FILE")
	if a:type=="cpp"
		call C_CommentSection("CLASS IMPLEMENTATIONS  -  EXPORTED CLASSES")
		call C_CommentSection("CLASS IMPLEMENTATIONS  -  LOCAL CLASSES")
	end
endfunction    " ----------  end of function C_Comment_C_SectionAll ----------
"
function! C_Comment_H_SectionAll ( type )
	call C_CommentSection("HEADER FILE INCLUDES")
  call C_CommentSection("EXPORTED MACROS")
  call C_CommentSection("EXPORTED TYPE DEFINITIONS")
  call C_CommentSection("EXPORTED DATA TYPES")
	if a:type=="cpp"
		call C_CommentSection("EXPORTED CLASS DEFINITIONS")
	end
  call C_CommentSection("EXPORTED VARIABLES") 
  call C_CommentSection("EXPORTED FUNCTION DECLARATIONS")
endfunction    " ----------  end of function C_Comment_H_SectionAll ----------
"
"------------------------------------------------------------------------------
"  C_SubstituteTag: Substitute tags    {{{1
"------------------------------------------------------------------------------
function! C_SubstituteTag( pos1, pos2, tag, replacement )
  let linenumber=a:pos1
  while linenumber <= a:pos2
		let line	= substitute( getline(linenumber), a:tag, a:replacement, "g" )
    call setline( linenumber, line )
    let linenumber=linenumber+1
  endwhile
endfunction    " ----------  end of function  C_SubstituteTag  ----------
"
"------------------------------------------------------------------------------
"  C_CommentTemplates: Insert a template files   {{{1
"------------------------------------------------------------------------------
function! C_CommentTemplates (arg)

	if s:C_Comments == 'yes' 
		let prefix="C"
	else
		let prefix="Cpp"
	endif
	"----------------------------------------------------------------------
	"  templates
	"----------------------------------------------------------------------
	if a:arg=='frame'
		let templatefile=s:C_Template_Directory.s:{prefix}_Template_Frame
	endif
	if a:arg=='function'
		let templatefile=s:C_Template_Directory.s:{prefix}_Template_Function
	endif
	if a:arg=='class'
		let templatefile=s:C_Template_Directory.s:{prefix}_Template_Class
	endif
	if a:arg=='method'
		let templatefile=s:C_Template_Directory.s:{prefix}_Template_Method
	endif
	if a:arg=='cheader'
		let templatefile=s:C_Template_Directory.s:{prefix}_Template_C_File
	endif
	if a:arg=='hheader'
		let templatefile=s:C_Template_Directory.s:{prefix}_Template_H_File
	endif
	if a:arg=='CppClass'
		let templatefile=s:C_Template_Directory.s:{prefix}_Class
	endif
	if a:arg=='CppClassUsingNew'
		let templatefile=s:C_Template_Directory.s:{prefix}_ClassUsingNew
	endif
	if a:arg=='CppTemplateClass'
		let templatefile=s:C_Template_Directory.s:{prefix}_TemplateClass
	endif
	if a:arg=='CppTemplateClassUsingNew'
		let templatefile=s:C_Template_Directory.s:{prefix}_TemplateClassUsingNew
	endif
	if a:arg=='CppErrorClass'
		let templatefile=s:C_Template_Directory.s:{prefix}_ErrorClass
	endif

	if	a:arg=='CppClass'                 ||
		\	a:arg=='CppClassUsingNew'         ||
		\	a:arg=='CppTemplateClass'         ||
		\	a:arg=='CppTemplateClassUsingNew' ||
		\	a:arg=='CppErrorClass' 

		let	name	= C_Input("class name : ", "" )
		if name == ""
			return
		endif
		let s:C_ClassName	= name
	endif

	if filereadable(templatefile)
		let	length= line("$")
		let	pos1  = line(".")+1
		"
		let l:old_cpoptions	= &cpoptions " Prevent the alternate buffer from being set to this files
		setlocal cpoptions-=a
		if  a:arg=='cheader' || a:arg=='hheader'
			:goto 1
			let	pos1  = 1
			silent exe '0read '.templatefile
		else
			silent exe 'read '.templatefile
		endif
		let &cpoptions	= l:old_cpoptions		" restore previous options
		let	length= line("$")-length
		let	pos2  = pos1+length-1
		"----------------------------------------------------------------------
		"  frame comment will be indented
		"----------------------------------------------------------------------
		if a:arg=='frame'
			let	length	= length-1
			silent exe "normal =".length."+"
			let	length	= length+1
		endif
		"----------------------------------------------------------------------
		"  substitute keywords
		"----------------------------------------------------------------------
		let	basename	= expand("%:t:r")
		call  C_SubstituteTag( pos1, pos2, '|BASENAMElegal|',   toupper(C_LegalizeName(basename)) )
		call  C_SubstituteTag( pos1, pos2, '|BASENAME|',        toupper(basename)    )
		call  C_SubstituteTag( pos1, pos2, '|Basename|',                basename     )
		call  C_SubstituteTag( pos1, pos2, '|basename|',        tolower(basename)    )

		call  C_SubstituteTag( pos1, pos2, '|FILENAME|',        expand("%:t")        )
		call  C_SubstituteTag( pos1, pos2, '|DATE|',            strftime("%x %X %Z") )
		call  C_SubstituteTag( pos1, pos2, '|TIME|',            strftime("%X")       )
		call  C_SubstituteTag( pos1, pos2, '|YEAR|',            strftime("%Y")       )
		call  C_SubstituteTag( pos1, pos2, '|AUTHOR|',          s:C_AuthorName       )
		call  C_SubstituteTag( pos1, pos2, '|EMAIL|',           s:C_Email            )
		call  C_SubstituteTag( pos1, pos2, '|AUTHORREF|',       s:C_AuthorRef        )
		call  C_SubstituteTag( pos1, pos2, '|PROJECT|',         s:C_Project          )
		call  C_SubstituteTag( pos1, pos2, '|COMPANY|',         s:C_Company          )
		call  C_SubstituteTag( pos1, pos2, '|COPYRIGHTHOLDER|', s:C_CopyrightHolder  )
		call  C_SubstituteTag( pos1, pos2, '|CLASSNAME|',       s:C_ClassName        )

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
		:set modified
	else
		echohl WarningMsg | echo 'template file '.templatefile.' does not exist or is not readable'| echohl None
	endif
	
endfunction    " ----------  end of function  C_CommentTemplates  ----------
"
"----------------------------------------------------------------------
"  C_CodeComment : Code -> Comment   {{{1
"----------------------------------------------------------------------
function! C_CodeComment( mode, style )
	if a:style==""
		let style=s:C_Comments
	else
		let style=a:style
	endif
	if a:mode=="a"
		if style == 'yes' 
			silent exe ":s#^#/\* #"
			silent put = ' */'
		else
			silent exe ":s#^#//#"
		endif
	endif
	
	if a:mode=="v"
		if style == 'yes' 
			silent exe ":'<,'>s/^/ \* /"
			silent exe ":'< s'^ '\/'"
			silent exe ":'>"
			silent put = ' */'
		else
			silent exe ":'<,'>s#^#//#"
		endif
	endif
endfunction    " ----------  end of function  C_CodeComment  ----------
"
"----------------------------------------------------------------------
"  C_StartMultilineComment : Comment -> Code   {{{1
"----------------------------------------------------------------------
let s:C_StartMultilineComment	= '^\s*\/\*[\*! ]\='

function! C_RemoveCComment( start, end )

	if a:end-a:start<1
		return 0										" lines removed
	endif
	" 
	" Is the C-comment complete ? Get length.
	" 
	let check				= getline(	a:start ) =~ s:C_StartMultilineComment
	let	linenumber	= a:start+1
	while linenumber < a:end && getline(	linenumber ) !~ '^\s*\*\/'
		let check				= check && getline(	linenumber ) =~ '^\s*\*[ ]\='
		let linenumber	= linenumber+1
	endwhile
	let check = check && getline(	linenumber ) =~ '^\s*\*\/'
	"
	" remove a complete comment
	" 
	if check
		exe "silent :".a:start.'   s/'.s:C_StartMultilineComment.'//'
		let	linenumber1	= a:start+1
		while linenumber1 < linenumber
			exe "silent :".linenumber1.' s/^\s*\*[ ]\=//'
			let linenumber1	= linenumber1+1
		endwhile
		exe "silent :".linenumber1.'   s/^\s*\*\///'
	endif

	return linenumber-a:start+1			" lines removed
endfunction    " ----------  end of function  C_RemoveCComment  ----------
"
"----------------------------------------------------------------------
"  C_CommentCode : Comment -> Code       {{{1
"----------------------------------------------------------------------
function! C_CommentCode(mode)
	if a:mode=="a"
		let	pos1		= line(".")
		let	pos2		= pos1
	endif
	if a:mode=="v"
		let	pos1		= line("'<")
		let	pos2		= line("'>")
	endif

	let	removed	= 0
	" 
	let	linenumber=pos1
	while linenumber <= pos2
		" Do we have a C++ comment ?
		if getline(	linenumber ) =~ '^\s*//'
			exe "silent :".linenumber.' s#^\s*//##'
			let	removed    = 1
		endif
		" Do we have a C   comment ?
		if removed == 0 && getline(	linenumber ) =~ s:C_StartMultilineComment
			let removed = C_RemoveCComment(linenumber,pos2)
		endif

		if removed!=0
			let linenumber = linenumber+removed
			let	removed    = 0
		else
			let linenumber = linenumber+1
		endif
	endwhile
endfunction    " ----------  end of function  C_CommentCode  ----------
"
"----------------------------------------------------------------------
"  C_CommentCppToC : C++ Comment -> C Comment       {{{1
"  Removes trailing whitespaces.
"----------------------------------------------------------------------
function! C_CommentCppToC()
		silent! exe ':s#\/\/\s*\(.*\)\s*$#/* \1 */#'
endfunction    " ----------  end of function  C_CommentCppToC  ----------
"
"----------------------------------------------------------------------
"  C_CommentCToCpp : C Comment -> C++ Comment       {{{1
"  Changes the first comment in case of multiple comments:
"    xxxx;               /*  */ /*  */
"    xxxx;               //  /*  */
"  Removes trailing whitespaces.
"----------------------------------------------------------------------
function! C_CommentCToCpp()
		silent! exe ':s!\/\*\s*\(.\{-}\)\*\/!\/\/ \1!'
		silent! exe ':s!\s*$!!'
endfunction    " ----------  end of function  C_CommentCToCpp  ----------
"
"----------------------------------------------------------------------
"  C_Toggle_C_Cpp : Toggle comment style       {{{1
"----------------------------------------------------------------------
function! C_Toggle_C_Cpp ()
	if s:C_Comments == 'yes'
		exe "aunmenu <silent> ".s:C_Root.'&Comments.\/\/\ xxx\ \ \ \ \ &->\ \ \/*\ xxx\ *\/'
		exe "aunmenu <silent> ".s:C_Root.'&Comments.st&yle\ C\ ->\ C\+\+'
		"
		exe "amenu <silent> ".s:C_Root.'&Comments.\/*\ xxx\ *\/\ \ -&>\ \ \/\/\ xxx          <Esc><Esc>:call C_CommentCToCpp()<CR>'
		exe "vmenu <silent> ".s:C_Root.'&Comments.\/*\ xxx\ *\/\ \ -&>\ \ \/\/\ xxx          <Esc><Esc>:'."'<,'>".'call C_CommentCToCpp()<CR>'
		exe "amenu <silent> ".s:C_Root.'&Comments.st&yle\ C\+\+\ ->\ C                       <Esc><Esc>:call C_Toggle_C_Cpp()<CR>'
		let	s:C_Comments	= 'no'
		let s:C_Com1      = '//'     " C++style : comment start 
		let s:C_Com2      = ''       " C++style : comment end
		echomsg "comment style is C++"
	else
		exe "aunmenu <silent> ".s:C_Root.'&Comments.\/*\ xxx\ *\/\ \ -&>\ \ \/\/\ xxx'
		exe "aunmenu <silent> ".s:C_Root.'&Comments.st&yle\ C\+\+\ ->\ C'
		"
		exe "amenu <silent> ".s:C_Root.'&Comments.\/\/\ xxx\ \ \ \ \ &->\ \ \/*\ xxx\ *\/    <Esc><Esc>:call C_CommentCppToC()<CR>'
		exe "vmenu <silent> ".s:C_Root.'&Comments.\/\/\ xxx\ \ \ \ \ &->\ \ \/*\ xxx\ *\/    <Esc><Esc>:'."'<,'>".'call C_CommentCppToC()<CR>'
		exe "amenu <silent> ".s:C_Root.'&Comments.st&yle\ C\ ->\ C\+\+    		               <Esc><Esc>:call C_Toggle_C_Cpp()<CR>'
		let	s:C_Comments	= 'yes'
		let s:C_Com1      = '/*'     " C-style : comment start 
		let s:C_Com2      = '*/'     " C-style : comment end
		echomsg "comment style is C"
	endif
endfunction    " ----------  end of function C_Toggle_C_Cpp  ----------
"
"-------------------------------------------------------------------------------
"   C_ToggleCommentStyle       {{{1
"-------------------------------------------------------------------------------
function! C_ToggleCommentStyle ()
	if s:C_CommentsToggle=='yes'
		if &filetype == 'c'   && s:C_Comments	== 'no'
			call C_Toggle_C_Cpp()
		end
		if &filetype == 'cpp' && s:C_Comments == 'yes'
			call C_Toggle_C_Cpp()
		end
	end
endfunction    " ----------  end of function C_ToggleCommentStyle  ----------
"
"------------------------------------------------------------------------------
"  C_CommentVimModeline : vim modeline       {{{1
"------------------------------------------------------------------------------
function! C_CommentVimModeline ()
  	put = s:C_Com1.' vim: set tabstop='.&tabstop.' shiftwidth='.&shiftwidth.': '.s:C_Com2
endfunction    " ----------  end of function C_CommentVimModeline  ----------
"
"=====================================================================================
"----- Menu : Statements -----------------------------------------------------------
"=====================================================================================
"
"------------------------------------------------------------------------------
"  C_DoWhile : do-while       {{{1
"------------------------------------------------------------------------------
function! C_DoWhile (arg)

	if a:arg=='a'
		if s:C_BraceOnNewLine == 'yes'
			let zz=    "do\n{\n}\nwhile (  );"
			let zz= zz."\t\t\t\t".s:C_Com1." -----  end do-while  ----- ".s:C_Com2."\n"
			put =zz
			if v:version < 700
				normal  =3+
			else
				normal  =3-
			endif
				normal 3j
		else
			let zz=    "do {\n} while (  );"
			let zz= zz."\t\t\t\t".s:C_Com1." -----  end do-while  ----- ".s:C_Com2."\n"
			put =zz
			if v:version < 700
				normal  =1+
			else
				normal  =1-
			endif
			normal j
		endif
	endif
	
	if a:arg=='v'
		if s:C_BraceOnNewLine == 'yes'
			let zz=    "do\n{"
			:'<put! =zz
			let zz=    "}\nwhile (  );\t\t\t\t".s:C_Com1." -----  end do-while  ----- ".s:C_Com2."\n"
			:'>put =zz
			:'<-2
			:exe "normal =".(line("'>")-line(".")+3)."+"
			:'>+2
		else
			let zz=    "do {"
			:'<put! =zz
			let zz=    "} while (  );\t\t\t\t".s:C_Com1." -----  end do-while  ----- ".s:C_Com2."\n"
			:'>put =zz
			:'<-1
			:exe "normal =".(line("'>")-line(".")+1)."+"
			:'>+1
		endif
	endif
endfunction    " ----------  end of function C_DoWhile  ----------
"
"------------------------------------------------------------------------------
"  C_Stat : statement       {{{1
"------------------------------------------------------------------------------
function! C_Stat (mode,stmt)
	let zz=   a:stmt
	if a:mode=='a'
		put =zz
		:exe "normal =="
	endif
	if a:mode=='v'
		:'<put! =zz
		:exe "normal =1+"
	endif
endfunction    " ----------  end of function C_Stat  ----------
"
"------------------------------------------------------------------------------
"  C_IfElse : if else       {{{1
"------------------------------------------------------------------------------
function! C_IfElse (arg)

	if a:arg=='a'
		let zz=    "if (  )\nelse"
		put =zz
		if v:version < 700
			:exe "normal =1+"
		else
			:exe "normal =1-"
		endif
	endif
	
	if a:arg=='v'
		let zz=    "if (  )"
		:'<put! =zz
		let zz=    "else"
		:'<put =zz
		:exe "normal =2-"
	endif
endfunction    " ----------  end of function C_IfElse  ----------
"
"------------------------------------------------------------------------------
"  C_StatBlock : statement  {}       {{{1
"------------------------------------------------------------------------------
function! C_StatBlock (mode,stmt)

	if a:mode=='a'
		if s:C_BraceOnNewLine == 'yes'
			let zz=    a:stmt."\n{\n}"
			put =zz
			if v:version >= 700
				normal 2k
			endif
			:exe "normal =2+"
		else
			let zz=    a:stmt." {\n}"
			put =zz
			if v:version >= 700
				normal 1k
			endif
			:exe "normal =1+"
		endif
	endif
	
	if a:mode=='v'
		if s:C_BraceOnNewLine == 'yes'
			let zz=    a:stmt."\n{"
			:'<put! =zz
			let zz=    "}"
			:'>put =zz
			:exe "normal =".(line("'>")-line("'<")+3)."-"
		else
			let zz=    a:stmt." {"
			:'<put! =zz
			let zz=    "}"
			:'>put =zz
			:exe "normal =".(line("'>")-line("'<")+2)."-"
		endif
	endif
endfunction    " ----------  end of function C_StatBlock  ----------
"
"------------------------------------------------------------------------------
"  C_IfBlockElse : if {} else {}       {{{1
"------------------------------------------------------------------------------
function! C_IfBlockElse (arg)

	if a:arg=='a'
		if s:C_BraceOnNewLine == 'yes'
			let zz=    "if (  )\n{\n}\nelse\n{\n}"
			put =zz
			if v:version < 700
				:exe "normal =5+"
			else
				:exe "normal =5-"
			endif
		else
			let zz=    "if (  ) {\n} else {\n}"
			put =zz
			if v:version < 700
				:exe "normal =2+"
			else
				:exe "normal =2-"
			endif
		endif
	endif
	
	if a:arg=='v'
		if s:C_BraceOnNewLine == 'yes'
			let zz=    "if (  )\n{"
			:'<put! =zz
			let zz=    "}\nelse\n{\n}"
			:'>put =zz
			if v:version < 700
				:exe "normal 3j"
			endif
			:exe "normal =".(line("'>")-line("'<")+6)."-"
		else
			let zz=    "if (  ) {"
			:'<put! =zz
			let zz=    "} else {\n}"
			:'>put =zz
			if v:version < 700
				:exe "normal 1j"
			endif
			:exe "normal =".(line("'>")-line("'<")+3)."-"
		endif
	endif
endfunction    " ----------  end of function C_IfBlockElse  ----------
"
"------------------------------------------------------------------------------
"  C_Block : block ; replaces an empty line       {{{1
"------------------------------------------------------------------------------
function! C_Block (arg)

	if a:arg=='a'
		if match(getline(line(".")), '^\s*$' ) < 0
			let zz=    "{\n\}"
			:put =zz
			if v:version < 700
				normal =+
			else
				normal =-
			endif
		else
			:s/^\s*$/{\r}/ 
			normal =-
		endif
		"
	endif
	
	if a:arg=='v'
		let zz=    '{'
		:'<put! =zz
		let zz=    "}\n"
		:'>put =zz
		:'<-1
		:exe "normal =".(line("'>")-line(".")+2)."+"
		:'>+1
	endif
endfunction    " ----------  end of function C_Block  ----------
"
"------------------------------------------------------------------------------
"  C_CodeSwitchVisual : make switch from a label list       {{{1
"------------------------------------------------------------------------------
"
function! C_CodeSwitchVisual ()

	let	nonemptylines	= 0
	let	linenumber 		= line("'<")
	while linenumber <= line("'>")
		let newline			= getline(linenumber)
		if match(newline, '^\s*$' ) < 0  
			exe ':'.linenumber.'s/\W*\(\w\+\).*/case \1: break;/'
			let nonemptylines	= nonemptylines+1
		endif
		let linenumber	= linenumber+1
	endwhile

	if nonemptylines==0
		echohl WarningMsg | echo " no case label found " | echohl None
		return
	endif

	let zz=    "default:\t\n\t\tbreak;\n}"
	let zz= zz."\t\t\t\t".s:C_Com1." -----  end switch  ----- ".s:C_Com2."\n"
	:'>put =zz

	exe "'<,'>s/break;/\r&\r/"

	if s:C_BraceOnNewLine == 'yes'
		let zz= "switch (  )\n{\n"
		:'<put! =zz
		exe ":'<-2"
		:exe "normal =".(line("'>")-line("'<")+7)."+"
	else
		let zz= "switch (  ) {\n"
		:'<put! =zz
		exe ":'<-1"
		:exe "normal =".(line("'>")-line("'<")+6)."+"
	endif

endfunction    " ----------  end of function C_CodeSwitchVisual  ----------
"
"------------------------------------------------------------------------------
"  C_CodeCaseVisual : make cases from a label list       {{{1
"------------------------------------------------------------------------------
"
function! C_CodeCaseVisual ()

	let	nonemptylines	= 0
	let	linenumber 		= line("'<")
	while linenumber <= line("'>")
		let newline			= getline(linenumber)
		if match(newline, '^\s*$' ) < 0  
			exe ':'.linenumber.'s/\W*\(\w\+\).*/case \1: break;/'
			let nonemptylines	= nonemptylines+1
		endif
		let linenumber	= linenumber+1
	endwhile

	if nonemptylines==0
		echohl WarningMsg | echo " no case label found " | echohl None
		return
	endif

	exe "'<,'>s/break;/\r&\r/"
	exe ":'<-1"
	exe "normal =".(line("'>")-line("'<")+2)."+"

endfunction    " ----------  end of function C_CodeCaseVisual  ----------
"
"------------------------------------------------------------------------------
"  C_CodeSwitch : switch       {{{1
"------------------------------------------------------------------------------
"
function! C_CodeSwitch ()
	let cc=    "case 0:\t\n\t\tbreak;\n\n"
	let cc= cc."case 0:\t\n\t\tbreak;\n\n"
	let cc= cc."case 0:\t\n\t\tbreak;\n\n"
	let cc= cc."case 0:\t\n\t\tbreak;\n\n"
	let cc= cc."default:\t\n\t\tbreak;\n}"
	let cc= cc."\t\t\t\t".s:C_Com1." -----  end switch  ----- ".s:C_Com2."\n"

	if s:C_BraceOnNewLine == 'yes'
		let zz= "switch (  )\n{\n"
		let zz= zz.cc
		put =zz	
		" indent 
		if v:version < 700
			normal  =16+
		else
			normal  =16-
		endif
		" delete case labels
		exe ":.,+12s/0//"
		-11
	else
		let zz= "switch (  ) {\n"
		let zz= zz.cc
		put =zz	
		" indent 
		if v:version < 700
			normal  =15+
		else
			normal  =15-
		endif
		" delete case labels
		exe ":.,+11s/0//"
		-10
	endif
endfunction    " ----------  end of function C_CodeSwitch  ----------
"
"----------------------------------------------------------------------
"  C_PPDefine : #define       {{{1
"----------------------------------------------------------------------
function! C_PPDefine ()
	if s:C_Comments == 'yes' 
		put = \"#define\t\t\t\t\".s:C_Com1.\"  \".s:C_Com2
	else
		put = \"#define\t\t\t\t\".s:C_Com1.\" \"
	endif
endfunction    " ----------  end of function C_PPDefine  ----------
"
"----------------------------------------------------------------------
"  C_PPUndef : #undef       {{{1
"----------------------------------------------------------------------
function! C_PPUndef ()
	if s:C_Comments == 'yes' 
		put = \"#undef\t\t\t\t\".s:C_Com1.\"  \".s:C_Com2
	else
		put = \"#undef\t\t\t\t\".s:C_Com1.\" \"
	endif
endfunction    " ----------  end of function C_PPDefine  ----------
"
"------------------------------------------------------------------------------
"  C_PPIfElse : #if .. #else .. #endif        {{{1
"             : #ifdef .. #else .. #endif 
"             : #ifndef .. #else .. #endif 
"------------------------------------------------------------------------------
function! C_PPIfElse (keyword,mode)
	"
	let identifier = ''
	if a:mode=='a+' || a:mode=='v+'
		let identifier = "CONDITION"
		let	identifier = C_Input("(uppercase) condition for #".a:keyword." : ", identifier )
	endif

	let negate	= 'not '
	if a:keyword == "ifndef"
		let negate	= ''
	endif

	if identifier != ""
		"
		if a:mode=='a+' || a:mode=='a-'
			let zz=    "#".a:keyword."  ".identifier."\n\n"
			if a:mode=='a+'
				let zz= zz."#else      ".s:C_Com1." -----  ".negate.identifier."  ----- ".s:C_Com2."\n\n"
			endif
			let zz= zz."#endif     ".s:C_Com1." -----  ".negate.identifier."  ----- ".s:C_Com2."\n"
			put =zz
			if v:version >= 700
				normal 4kj
			else
				normal j
			endif
		endif

		if a:mode=='v+' || a:mode=='v-'
			let zz=    "#".a:keyword."  ".identifier."\n"
			:'<put! =zz
			let zz	= ""
			if a:mode=='v+'
				let zz=    "#else      ".s:C_Com1." -----  ".negate.identifier."  ----- ".s:C_Com2."\n\n"
			endif
			let zz= zz."#endif     ".s:C_Com1." -----  ".negate.identifier."  ----- ".s:C_Com2."\n"
			:'>put  =zz
			:normal '<
		endif

	endif
endfunction    " ----------  end of function C_PPIfElse ----------
"
"------------------------------------------------------------------------------
"  C_PPIf0 : #if 0 .. #endif        {{{1
"------------------------------------------------------------------------------
function! C_PPIf0 (mode)
	"
	let	s:C_If0_Counter	= 0
	let	save_line					= line(".")
	let	actual_line				= 0
	"
	" search for the maximum option number (if any)
	"
	normal gg
	while actual_line < search( s:C_If0_Txt."\\d\\+" )
		let actual_line	= line(".")
	 	let actual_opt  = matchstr( getline(actual_line), s:C_If0_Txt."\\d\\+" )
		let actual_opt  = strpart( actual_opt, strlen(s:C_If0_Txt),strlen(actual_opt)-strlen(s:C_If0_Txt))
		if s:C_If0_Counter < actual_opt
			let	s:C_If0_Counter = actual_opt
		endif
	endwhile
	let	s:C_If0_Counter = s:C_If0_Counter+1
	silent exe ":".save_line
	"
	if a:mode=='a'
		let zz=    "\n#if  0     ".s:C_Com1." ----- #if 0 : ".s:C_If0_Txt.s:C_If0_Counter." ----- ".s:C_Com2."\n"
		let zz= zz."\n#endif     ".s:C_Com1." ----- #if 0 : ".s:C_If0_Txt.s:C_If0_Counter." ----- ".s:C_Com2."\n\n"
		put =zz
		if v:version >= 700
			normal 4k
		endif
	endif

	if a:mode=='v'
		let zz=    "\n#if  0     ".s:C_Com1." ----- #if 0 : ".s:C_If0_Txt.s:C_If0_Counter." ----- ".s:C_Com2."\n"
		:'<put! =zz
		let zz=      "#endif     ".s:C_Com1." ----- #if 0 : ".s:C_If0_Txt.s:C_If0_Counter." ----- ".s:C_Com2."\n\n"
		:'>put  =zz
		:normal '<
	endif

endfunction    " ----------  end of function C_PPIf0 ----------
"
"------------------------------------------------------------------------------
"  C_PPIf0Remove : remove  #if 0 .. #endif        {{{1
"------------------------------------------------------------------------------
function! C_PPIf0Remove ()

	let frstline	= searchpair( '^\s*#if\s\+0', '', '^\s*#endif\>.\+\<If0Label_', 'bn' )
  if frstline<=0
		echohl WarningMsg | echo 'no  #if 0 ... #endif  found or cursor not inside such a directive'| echohl None
    return
  endif
	let lastline	= searchpair( '^\s*#if\s\+0', '', '^\s*#endif\>.\+\<If0Label_', 'n' )
	if lastline<=0
		echohl WarningMsg | echo 'no  #if 0 ... #endif  found or cursor not inside such a directive'| echohl None
		return
	endif
  let actualnumber1  = matchstr( getline(frstline), s:C_If0_Txt."\\d\\+" )
  let actualnumber2  = matchstr( getline(lastline), s:C_If0_Txt."\\d\\+" )
	if actualnumber1 != actualnumber2
    echohl WarningMsg | echo 'lines '.frstline.', '.lastline.': comment tags do not match'| echohl None
		return
	endif

  silent exe ':'.lastline.','.lastline.'d'
	silent exe ':'.frstline.','.frstline.'d'
	
endfunction    " ----------  end of function C_PPIf0Remove ----------
"
"-------------------------------------------------------------------------------
"   C_LegalizeName : replace non-word characters by underscores
"   - multiple whitespaces
"   - multiple non-word characters
"   - multiple underscores
"-------------------------------------------------------------------------------
function! C_LegalizeName ( name )
	let identifier = substitute(     a:name, '\s\+',  '_', 'g' )
	let identifier = substitute( identifier, '\W\+',  '_', 'g' ) 
	let identifier = substitute( identifier, '_\+', '_', 'g' )
	return identifier
endfunction    " ----------  end of function C_LegalizeName  ----------
"
"------------------------------------------------------------------------------
"  C_PPifndef : #ifndef .. #define .. #endif        {{{1
"------------------------------------------------------------------------------
function! C_PPifndef (arg)
	" use filename without path (:t) and extension (:r) :
	let identifier = toupper(expand("%:t:r"))."_INC"
	let identifier = C_LegalizeName(identifier)
	let	identifier = C_Input("(uppercase) condition for #ifndef : ", identifier )
	if identifier != ""

		if a:arg=='a'
			let zz=    "#ifndef  ".identifier."\n"
			let zz= zz."#define  ".identifier."\n\n"
			let zz= zz."#endif   ".s:C_Com1." ----- #ifndef ".identifier."  ----- ".s:C_Com2."\n"
			put =zz
			if v:version >= 700
				normal 3k
			endif
		endif

		if a:arg=='v'
			let zz=    "#ifndef  ".identifier."\n"
			let zz= zz."#define  ".identifier."\n"
			:'<put! =zz
			let zz=    "#endif   ".s:C_Com1." ----- #ifndef ".identifier."  ----- ".s:C_Com2."\n"
			:'>put  =zz
			:normal '<
		endif

	endif
endfunction    " ----------  end of function C_PPifndef ----------
"
"------------------------------------------------------------------------------
"  C_CodeFunction : function       {{{1
"------------------------------------------------------------------------------
function! C_CodeFunction (arg1)

	let	identifier=C_Input("function name : ", "" )

	if identifier != ""
		if a:arg1=="sa" || a:arg1=="sv"
			let prfx	= "static "
		else
			let prfx	= ""
		endif
		" ----- normal mode ----------------
		if a:arg1=="a" || a:arg1=="sa"
			let zz=    prfx."void\n".identifier." (  )\n{\n\treturn ;\n}"
			let zz= zz."\t\t".s:C_Com1." -----  end of ".prfx."function ".identifier."  ----- ".s:C_Com2
			put =zz
			if v:version >= 700
				normal 4k
			endif
		endif
		" ----- visual mode ----------------
		if a:arg1=="v" || a:arg1=="sv"
			let zz=    prfx."void\n".identifier." (  )\n{"
			:'<put! =zz
			let zz=    "return ;\n}"
			let zz= zz."\t\t".s:C_Com1." -----  end of ".prfx."function ".identifier."  ----- ".s:C_Com2
			:'>put =zz
			:'<-3
			:exe "normal =".(line("'>")-line(".")+2)."+"
		endif
	endif
endfunction    " ----------  end of function C_CodeFunction ----------
"
"------------------------------------------------------------------------------
"  C_CodeMain : main       {{{1
"------------------------------------------------------------------------------
function! C_CodeMain ( mode )
	" ----- normal mode ----------------
	if a:mode == "a"
		let zz=    "int\nmain ( int argc, char *argv[] )\n{\n\t\n"
		let zz= zz."\treturn EXIT_SUCCESS;\n}"
		let zz= zz."\t\t\t\t".s:C_Com1." ----------  end of function main  ---------- ".s:C_Com2
		put =zz
		if v:version >= 700
			normal 5k
		endif
	end
	" ----- visual mode ----------------
	if a:mode == "v"
		let zz=    "int\nmain ( int argc, char *argv[] )\n{"
		:'<put! =zz
		let zz=    "\treturn EXIT_SUCCESS;\n}"
		let zz= zz."\t\t\t\t".s:C_Com1." ----------  end of function main  ---------- ".s:C_Com2
		:'>put =zz
		:'<-3
		:exe "normal =".(line("'>")-line("'<")+5)."+"
		:'<
	end
endfunction    " ----------  end of function C_CodeMain ----------

"------------------------------------------------------------------------------
"  C_CodeSnippet : read / edit code snippet       {{{1
"------------------------------------------------------------------------------
function! C_CodeSnippet(arg1)
	if !has("gui_running")
		return
	endif
	if isdirectory(s:C_CodeSnippets)
		"
		" read snippet file, put content below current line and indent
		" 
		if a:arg1 == "r"
			let	l:snippetfile=browse(0,"read a code snippet",s:C_CodeSnippets,"")
			if filereadable(l:snippetfile)
				let	linesread= line("$")
				let l:old_cpoptions	= &cpoptions " Prevent the alternate buffer from being set to this files
				setlocal cpoptions-=a
				:execute "read ".l:snippetfile
				let &cpoptions	= l:old_cpoptions		" restore previous options
				let	linesread= line("$")-linesread-1
				if linesread>=0 && match( l:snippetfile, '\.\(ni\|noindent\)$' ) < 0 
				endif
			endif
			if line(".")==2 && getline(1)=~"^$"
				silent exe ":1,1d"
			endif
		endif
		"
		" update current buffer / split window / edit snippet file
		" 
		if a:arg1 == "e"
			let	l:snippetfile	= browse(0,"edit a code snippet",s:C_CodeSnippets,"")
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
				if filereadable(l:snippetfile)
					if confirm("File ".l:snippetfile." exists ! Overwrite ? ", "&Cancel\n&No\n&Yes") != 3
						return
					endif
				endif
				:execute ":write! ".l:snippetfile
			endif
		endif
		"
		" write marked area into snippet file 
		" 
		if a:arg1 == "wv"
			let	l:snippetfile=browse(0,"write a code snippet",s:C_CodeSnippets,"")
			if l:snippetfile != ""
				if filereadable(l:snippetfile)
					if confirm("File ".l:snippetfile." exists ! Overwrite ? ", "&Cancel\n&No\n&Yes") != 3
						return
					endif
				endif
				:execute ":*write! ".l:snippetfile
			endif
		endif

	else
		echo "code snippet directory ".s:C_CodeSnippets." does not exist (please create it)"
	endif
endfunction    " ----------  end of function C_CodeSnippets  ----------
"
"------------------------------------------------------------------------------
"  C_CodeFor : for (idiom)       {{{1
"------------------------------------------------------------------------------
function! C_CodeFor( direction, mode )
	if a:direction=="up"
		let	string	= C_Input( " loop var. [ start [ end [ incr. ]]] : ", "" )
	else
		let	string	= C_Input( " loop var. [ start [ end [ decr. ]]] : ", "" )
	endif
	let	pos		= 0
	let	jmp		= 0
	if string != ""
		" loop variable
		let loopvar		= matchstr( string, '\S\+\s*', pos )
		let pos				= pos + strlen(loopvar)
		let loopvar		= substitute( loopvar, '\s*$', "", "" )
		" 
		" start value
		let startval	= matchstr( string, '\S\+\s*', pos )
		let pos				= pos + strlen(startval)
		let startval	= substitute( startval, '\s*$', "", "" )

		" end value
		let endval	= matchstr( string, '\S\+\s*', pos )
		let pos				= pos + strlen(endval)
		let endval	= substitute( endval, '\s*$', "", "" )

		" increment
		let incval	= matchstr( string, '\S\+\s*', pos )
		let pos			= pos + strlen(incval)
		let incval	= substitute( incval, '\s*$', "", "" )

		if incval==""
			let incval	= '1'
			let	jmp		= 10
		endif

		if a:direction=="up"
			if endval==""
				let endval	= 'n'
				let	jmp		= 7
			endif
			if startval==""
				let startval	= '0'
				let	jmp		= 4
			endif
			let zz= "for ( ".loopvar." = ".startval."; ".loopvar." < ".endval."; ".loopvar." += ".incval." )" 
		else
			if endval==""
				let endval	= '0'
				let	jmp		= 7
			endif
			if startval==""
				let startval	= 'n-1'
				let	jmp		= 4
			endif
			let zz= "for ( ".loopvar." = ".startval."; ".loopvar." >= ".endval."; ".loopvar." -= ".incval." )" 
		endif

		" ----- normal mode ----------------
		if a:mode=="a" 
			put =zz
			normal ==
			if jmp!=0
				exe "normal ".jmp."Wh"
			else
				exe 'normal $'
			endif
		endif

		" ----- visual mode ----------------
		if a:mode=="v" 
			if s:C_BraceOnNewLine == 'yes'
				let	zz	= zz."\n{"
				:'<put! =zz
				let zz=    "}"
				:'>put =zz
				:'<-2
				:exe "normal =".(line("'>")-line(".")+4)."+"
			else
				let	zz	= zz." {"
				:'<put! =zz
				let zz=    "}"
				:'>put =zz
				:'<-1
				:exe "normal =".(line("'>")-line(".")+3)."+"
			endif
		endif
	endif
endfunction    " ----------  end of function C_CodeFor ----------
"
"------------------------------------------------------------------------------
"  C_CodeMethod : method       {{{1
"------------------------------------------------------------------------------
function! C_CodeMethod()
	let	identifier=C_Input("method name : ", s:C_ClassName."::" )
	if identifier != ""
		let zz= "
		\void\n".identifier." (  )\n{\n\treturn ;\n}
		\\t\t".s:C_Com1." -----  end of method ".identifier."  ----- ".s:C_Com2
		put =zz
		if v:version >= 700
			normal 4k
		endif
	endif
	" look for the class name
	let identifier 	= matchstr( identifier, '\<\(\h\w*\s*::\s*\)\+' )
	let identifier 	= substitute( identifier, '::\s*$', '', '' )
	let s:C_ClassName	= identifier
endfunction    " ----------  end of function C_CodeMethod ----------
"
"
"------------------------------------------------------------------------------
"  C_CodeTemplateFunct : template function       {{{1
"------------------------------------------------------------------------------
function! C_CodeTemplateFunct ()
	let	identifier=C_Input("template function name : ", "" )
	if identifier != ""
		let zz=    "template <class T>\nvoid ".identifier." ( T param )\n{\n\treturn ;\n}"
		let zz= zz."\t\t".s:C_Com1." -----  end of template function ".identifier."  ----- ".s:C_Com2
		put =zz
		if v:version >= 700
			normal 4k
		endif
		normal jfT
	endif
endfunction    " ----------  end of function C_CodeTemplateFunct ----------
"
"------------------------------------------------------------------------------
"  C_EST : enum struct union       {{{1
"------------------------------------------------------------------------------
function! C_EST (su)
	let name= strpart( a:su, 0, 1 )												" first character of argument
	let	name= C_Input("(lowercase) ".a:su." name : ", name )
	if name != ""
		let	typename	= name
		"
		let	jump			= 1
		if &filetype == 'c'
			let trailer	= "\ntypedef ".a:su." ".name." ".typename.";\n"
			let	jump	= jump + 2
		else
			let	trailer		= ''
		endif
		"
		if s:C_BraceOnNewLine == 'yes'
			let	jump	= jump + 1
			let zz=    a:su." ".name."\n{\n};"
		else
			let zz=    a:su." ".name." {\n};"
		endif
		"
		let zz= zz."\t\t\t\t".s:C_Com1." ----------  end of ".a:su." ".name."  ---------- ".s:C_Com2."\n"
		let zz= zz.trailer
		put =zz

		if v:version < 700
			exe "normal  =".jump."+"
		else
			exe "normal  =".jump."-"
		endif
		if s:C_BraceOnNewLine == 'yes'
			normal	j
		endif

	endif
endfunction    " ----------  end of function C_EST ----------
"
"------------------------------------------------------------------------------
"  C_CodeMalloc : malloc       {{{1
"------------------------------------------------------------------------------
function! C_CodeMalloc (type)
	let	pos		= 0
	let	jmp		= 0
	if a:type == "c"
		let	string	= C_Input("pointer name { count [ type ]] : ", "")
	else
		let	string	= C_Input("pointer name [ type ] : ", "")
	endif

	if string != ""
		" loop variable
		let pointername		= matchstr( string, '\S\+\s*', pos )
		let pos						= pos + strlen(pointername)
		let pointername		= substitute( pointername, '\s*$', "", "" )
		" 
		" calloc
		"
		if a:type == "c"
			" count 
			let cnt	= matchstr( string, '\S\+\s*', pos )
			let pos		= pos + strlen(cnt)
			let cnt	= substitute( cnt, '\s*$', "", "" )
			" size 
			let size	= matchstr( string, '\S\+\s*', pos )
			let pos		= pos + strlen(size)
			let size	= substitute( size, '\s*$', "", "" )
			if size=="" || cnt ==""
				let jmp	= 1
			endif
			let zz=    pointername."\t= (".size."*)calloc ( (size_t)(".cnt."), sizeof(".size.") );"
		" 
		" malloc
		"
		else
			let size	= matchstr( string, '\S\+\s*', pos )
			let pos		= pos + strlen(size)
			let size	= substitute( size, '\s*$', "", "" )
			if size==""
				let jmp	= 1
			endif

			let zz=    pointername."\t= (".size."*)malloc ( sizeof(".size.") );"
		endif
		"
		let rest=      "\n\tfprintf ( stderr, \"\\ndynamic memory allocation failed\\n\" );"
		let rest= rest."\n\texit (EXIT_FAILURE);\n}"
		let rest= rest."\n\nfree (".pointername.");\n\n"
		if s:C_BraceOnNewLine == 'yes'
			let zz=  zz."\nif ( ".pointername."==NULL )\n{".rest
			put =zz
			if v:version >= 700
				normal 8k
			endif
			normal  =7+
			if jmp!=0
				exe "normal f*"
			else
				exe "normal 6j"
			endif
		else
			let zz= zz."\nif ( ".pointername."==NULL ) {".rest
			put =zz
			if v:version >= 700
				normal 7k
			endif
			normal  =6+
			if jmp!=0
				exe "normal f*"
			else
				exe "normal 5j"
			endif
		endif
	endif
endfunction    " ----------  end of function C_CodeMalloc ----------
"
"------------------------------------------------------------------------------
"  C_CodeFopen : open file for reading/writing       {{{1
"------------------------------------------------------------------------------
function! C_CodeFopen ( inout )
	if a:inout=="input"
		let	filepointer	= C_Input(a:inout."-file pointer : ", "infile")
		let	mode				= 'r'
	else
		let	filepointer = C_Input(a:inout."-file pointer : ", "outfile")
		let	mode				= 'w'
	endif
	if filepointer != ""
		let filename=filepointer."_file_name"
		let zz=    "FILE\t*".filepointer.";\t\t\t\t\t\t\t\t\t\t".s:C_Com1." ".a:inout."-file pointer ".s:C_Com2."\n"
		let zz= zz."char\t*".filename." = \"\";\t\t".s:C_Com1." ".a:inout."-file name    ".s:C_Com2."\n\n"
		let zz= zz.filepointer."\t= fopen( ".filename.", \"".mode."\" );\n"
		if s:C_BraceOnNewLine == 'yes'
			let zz= zz."if ( ".filepointer." == NULL )\n{\n"
		else
			let zz= zz."if ( ".filepointer." == NULL ) {\n"
		endif
		let zz= zz."\tfprintf ( stderr, \"couldn't open file '%s'; %s\\n\",\n".filename.", strerror(errno) );\n"
		let zz= zz."\texit (EXIT_FAILURE);\n}\n\n\n"
		if s:C_BraceOnNewLine == 'yes'
			let zz= zz."if( fclose(".filepointer.") == EOF )\t\t\t".s:C_Com1." close ".a:inout." file   ".s:C_Com2."\n"
			let zz= zz."{\n\tfprintf ( stderr, \"couldn't close file '%s'; %s\\n\",\n".filename.", strerror(errno) );\n"
			let zz= zz."\texit (EXIT_FAILURE);\n}\n\n\n"
			put =zz
			if v:version >= 700
				normal 19k
			endif
			normal =17+
		else
			let zz= zz."if( fclose(".filepointer.") == EOF ) {\t\t\t".s:C_Com1." close ".a:inout." file   ".s:C_Com2."\n"
			let zz= zz."\tfprintf ( stderr, \"couldn't close file '%s'; %s\\n\",\n".filename.", strerror(errno) );\n"
			let zz= zz."\texit (EXIT_FAILURE);\n}\n\n\n"
			put =zz
			if v:version >= 700
				normal 17k
			endif
			normal =15+
		endif
		"
		if a:inout=="input"
			exe ": noremenu ".s:C_Root.'&Idioms.fscanf('.filepointer.',\ "",\ );    <Esc><Esc>ofscanf ) '.filepointer.', "", & );<ESC>2F)r(f"a'
			exe ":inoremenu ".s:C_Root.'&Idioms.fscanf('.filepointer.',\ "",\ );               fscanf ) '.filepointer.', "", & );<ESC>2F)r(f"a'
		else
			exe ": noremenu ".s:C_Root.'&Idioms.fprintf('.filepointer.',\ "\\n",\ );     <Esc><Esc>ofprintf ) '.filepointer.', "\n",  );<ESC>2F)r(f\i'
			exe ":inoremenu ".s:C_Root.'&Idioms.fprintf('.filepointer.',\ "\\n",\ );                fprintf ) '.filepointer.', "\n",  );<ESC>2F)r(f\i'
		endif
	endif
endfunction    " ----------  end of function C_CodeFopen ----------
"
"------------------------------------------------------------------------------
"  C_CodeIOStream : open file for reading/writing       {{{1
"------------------------------------------------------------------------------
function! C_CodeIOStream ( stream )
	if a:stream=="ifstream"
		let	streamobject= C_Input("ifstream object : ", "ifs" )
		let direction		= 'input '
	else
		let	streamobject=C_Input("ofstream object : ", "ofs" )
		let direction		= 'output'
	endif
	if streamobject != ""
		let filename=streamobject."_file_name"
		let zz=    "char *".filename." = \"\";\t\t".s:C_Com1." ".direction." file name       ".s:C_Com2."\n"
		let zz= zz.a:stream."\t".streamobject.";\t\t\t\t\t\t\t".s:C_Com1." create ".a:stream." object ".s:C_Com2."\n\n"
		let zz= zz.streamobject.".open (".filename.");\t\t".s:C_Com1." open ".a:stream."          ".s:C_Com2."\n"
		if s:C_BraceOnNewLine == 'yes'
			let zz= zz."if (!".streamobject.")\n{\n"
		else
			let zz= zz."if (!".streamobject.") {\n"
		endif
		let zz= zz."\tcerr << \"\\nERROR : failed to open ".direction." file \" << ".filename." << endl;\n"
		let zz= zz."\texit (EXIT_FAILURE);\n}\n\n\n"
		let zz= zz.streamobject.".close ();\t\t".s:C_Com1." close ".a:stream."         ".s:C_Com2."\n"
		put =zz
		if s:C_BraceOnNewLine == 'yes'
			if v:version < 700
				normal =11+
			else
				normal =11-
			endif
		else
			if v:version < 700
				normal =10+
			else
				normal =10-
			endif
		endif
	endif
endfunction    " ----------  end of function C_CodeIOStream ----------
"
"------------------------------------------------------------------------------
"  C_Namespace : namespace       {{{1
"------------------------------------------------------------------------------
function! C_Namespace (arg1)

	let	identifier=C_Input("namespace name : ", "" )

	if identifier != ""
		" ----- normal mode ----------------
		if a:arg1=="a"
			let zz=    "namespace ".identifier."\n{\n}"
			let zz= zz."\t\t".s:C_Com1." -----  end of namespace  ".identifier."  ----- ".s:C_Com2
			put =zz
			if v:version < 700
				normal j
			else
				normal k
			endif
		endif
		" ----- visual mode ----------------
		if a:arg1=="v"
			let zz=    "namespace ".identifier."\n{\n\n"
			:'<put! =zz
			let zz=    "\n}\t\t".s:C_Com1." -----  end of namespace  ".identifier."  ----- ".s:C_Com2
			:'>put  =zz
			:'<,'>>
		endif
	endif
endfunction    " ----------  end of function C_Namespace ----------
"
"------------------------------------------------------------------------------
"  C_CodeOutputOperator : output operator       {{{1
"------------------------------------------------------------------------------
function! C_CodeOutputOperator ()
	let	identifier=C_Input("class name : ", s:C_ClassName )
	if identifier != ""
		let zz=    "ostream &\noperator << ( ostream & os, const ".identifier." & obj )\n"
		let zz= zz."{\n\tos << obj. ;\n\treturn os;\n}"
		let zz= zz."\t\t".s:C_Com1." -----  class ".identifier." : end of function operator <<  ----- ".s:C_Com2
		put =zz
			if v:version < 700
				normal 3j
			else
				normal 2k
			endif
	endif
endfunction    " ----------  end of function C_CodeOutputOperator ----------
"
"------------------------------------------------------------------------------
"  C_CodeInputOperator : input operator       {{{1
"------------------------------------------------------------------------------
function! C_CodeInputOperator ()
	let	identifier=C_Input("class name : ", s:C_ClassName )
	if identifier != ""
		let zz=    "istream &\noperator >> ( istream & is, ".identifier." & obj )"
		let zz= zz."\n{\n\tis >> obj. ;\n\treturn is;\n}"
		let zz= zz."\t\t".s:C_Com1." -----  class ".identifier." : end of function operator >>  ----- ".s:C_Com2
		put =zz
		if v:version < 700
			normal 3j
		else
			normal 2k
		endif
	endif
endfunction    " ----------  end of function C_CodeInputOperator ----------
"
"------------------------------------------------------------------------------
"  C_CodeTryCatch : try catch       {{{1
"------------------------------------------------------------------------------
function! C_CodeTryCatch (arg1)
	"
	if s:C_BraceOnNewLine == 'yes'
		let str1=    "try\n{"
		let str2=    "}\n"
		let str2= str2."catch ( const &ExceptObj )\t\t".s:C_Com1." handle exception: ".s:C_Com2."\n{\n}\n"
		let str2= str2."catch (...)\t\t".s:C_Com1." handle exception: unspezified ".s:C_Com2."\n{\n}"
		"
		if a:arg1=="a"
			let str1 =str1."\n".str2
			put =str1
			if v:version < 700
				normal  =8+
			else
				normal  =8-
			endif
			normal j
		endif
		"
		if a:arg1=="v"
			:'<put! =str1
			:'>put =str2
			:'<-2
			:exe "normal =".(line("'>")-line(".")+7)."+"
			:'>+2
		endif
	else
		" s:C_BraceOnNewLine == 'no'
		"
		let str1=    "try {"
		let str2=    "}\n"
		let str2= str2."catch ( const &ExceptObj ) {\t\t".s:C_Com1." handle exception: ".s:C_Com2."\n}\n"
		let str2= str2."catch (...) {\t\t".s:C_Com1." handle exception: unspezified ".s:C_Com2."\n}"
		"
		if a:arg1=="a"
			let str1 =str1."\n".str2
			put =str1
			if v:version < 700
				normal  =5+
			else
				normal  =5-
			endif
		endif
		"
		if a:arg1=="v"
			:'<put! =str1
			:'>put =str2
			:'<-1
			:exe "normal =".(line("'>")-line(".")+5)."+"
			:'>+2
		endif
	endif
endfunction    " ----------  end of function C_CodeTryCatch ----------
"
"------------------------------------------------------------------------------
"  C_CodeCatch : catch       {{{1
"------------------------------------------------------------------------------
function! C_CodeCatch (mode,decl)
	if s:C_BraceOnNewLine == 'yes'
		let str1= "catch (".a:decl.")\t\t".s:C_Com1." handle exception: ".s:C_Com2."\n{"
		let str2= "}\n"
		if a:mode=="a"
			let str1 =str1."\n".str2
			put =str1
			if v:version < 700
				normal  =2+
			else
				normal  =2-
			endif
		endif
		if a:mode=="v"
			:'<put! =str1
			:'>put =str2
			:'<-2
			:exe "normal =".(line("'>")-line(".")+1)."+"
		endif
	else
		let str1= "catch (".a:decl.") {\t\t".s:C_Com1." handle exception: ".s:C_Com2
		let str2= "}\n"
		if a:mode=="a"
			let str1 =str1."\n".str2
			put =str1
			if v:version < 700
				normal  =1+
			else
				normal  =1-
			endif
		endif
		if a:mode=="v"
			:'<put! =str1
			:'>put =str2
			:'<-1
			:exe "normal =".(line("'>")-line(".")+1)."+"
		endif
	endif

endfunction    " ----------  end of function C_CodeCatch ----------
"
"------------------------------------------------------------------------------
"  Handle prototypes       {{{1
"------------------------------------------------------------------------------
"
let s:C_Prototype        = ''
let s:C_PrototypeShow    = ''
let s:C_PrototypeCounter = 0
let s:C_CComment         = '\/\*.\{-}\*\/\s*'		" C comment with trailing whitespaces
																								"  '.\{-}'  any character, non-greedy
let s:C_CppComment       = '\/\/.*$'						" C++ comment
"
"------------------------------------------------------------------------------
"  C_ProtoPick : pick up (normal/visual)       {{{1
"------------------------------------------------------------------------------
function! C_ProtoPick (mode)
	if a:mode=="n"
		" --- normal mode -------------------
		let	pos1	= line(".")
		let	pos2	= line(".")
	else
		" --- visual mode -------------------
		let	pos1	= line("'<")
		let	pos2	= line("'>")
	endif
	let	linenumber = pos1
	let prototyp   = getline(linenumber)
	let prototyp   = substitute( prototyp, s:C_CppComment, "", "" ) " remove C++ comment
	let linenumber = linenumber+1
	while linenumber <= pos2
		let newline			= getline(linenumber)
		let newline 	  = substitute( newline, s:C_CppComment, "", "" ) " remove C++ comment
		let prototyp		= prototyp." ".newline
		let linenumber	= linenumber+1
	endwhile
	let prototyp  = substitute( prototyp, '^\s\+', "", "" )					" remove leading whitespaces
	let prototyp  = substitute( prototyp, s:C_CComment, "", "g" )		" remove (multiline) C comments 
	let prototyp  = substitute( prototyp, '\s\+', " ", "g" )				" squeeze whitespaces
	let prototyp  = substitute( prototyp, '\s\+$', "", "" )					" remove trailing whitespaces
	"
	let prototyp  = substitute( prototyp, '^template\s*<\s*class \w\+\s*>\s*', "", "" )
	let prototyp  = substitute( prototyp, '<\s*\w\+\s*>', "", "g" )	
	"
	let parlist 	= stridx( prototyp, '(' )													" start of the parameter list
	let part1   	= strpart( prototyp, 0, parlist )
	let part2   	= strpart( prototyp, parlist )

	let part1   	= substitute( part1, '\<std\s*::', 'std##', 'g' )	" remove the scope res. operator
	let part1   	= substitute( part1, '\<\h\w*\s*::', '', 'g' )		" remove the scope res. operator
	let part1   	= substitute( part1, '\<std##', 'std::', 'g' )		" remove the scope res. operator
	let	prototyp	= part1.part2
	"
	let prototyp	= substitute( prototyp, '\s*{.*$', "", "" )     	" remove trailing parts of the function body
	let prototyp	= prototyp.";\n"
	let s:C_PrototypeCounter = s:C_PrototypeCounter+1
	let s:C_Prototype        = s:C_Prototype.prototyp
	let identstring          = s:C_PrototypeShow."(".s:C_PrototypeCounter.") ".bufname("%")." #  "
	let s:C_PrototypeShow    = identstring.prototyp
	"
	echo	s:C_PrototypeCounter.' prototype(s)'
	"
endfunction    " ---------  end of function C_ProtoPick  ----------
"
"------------------------------------------------------------------------------
"  C_ProtoInsert : insert       {{{1
"------------------------------------------------------------------------------
function! C_ProtoInsert ()
	if s:C_PrototypeCounter==0
		echo "currently no prototypes available"
	else
		let	output	= s:C_Prototype
		put =output
		silent exe "normal =".s:C_PrototypeCounter."+"
		call C_ProtoClear()
	endif
endfunction    " ---------  end of function C_ProtoInsert  ----------
"
"------------------------------------------------------------------------------
"  C_ProtoClear : clear       {{{1
"------------------------------------------------------------------------------
function! C_ProtoClear ()
	if s:C_PrototypeCounter==0
		echo "currently no prototypes available"
	else
		let s:C_Prototype        = ""
		let s:C_PrototypeShow    = ""
		let s:C_PrototypeCounter = 0
		echo 'prototypes deleted'
	endif
endfunction    " ---------  end of function C_ProtoClear  ----------
"
"------------------------------------------------------------------------------
"  C_ProtoShow : show       {{{1
"------------------------------------------------------------------------------
function! C_ProtoShow ()
	if s:C_PrototypeCounter==0
		echo "currently no prototypes available"
	else
		echo s:C_PrototypeShow
	endif
endfunction    " ---------  end of function C_ProtoShow  ----------
"
"------------------------------------------------------------------------------
"  C_EscapeBlanks : C_EscapeBlanks       {{{1
"------------------------------------------------------------------------------
function! C_EscapeBlanks (arg)
	return  substitute( a:arg, " ", "\\ ", "g" )
endfunction    " ---------  end of function C_EscapeBlanks  ----------
"
"------------------------------------------------------------------------------
"  C_Compile : C_Compile       {{{1
"------------------------------------------------------------------------------
"  The standard make program 'make' called by vim is set to the C or C++ compiler
"  and reset after the compilation  (set makeprg=... ).
"  The errorfile created by the compiler will now be read by gvim and
"  the commands cl, cp, cn, ... can be used.
"
"
"------------------------------------------------------------------------------
function! C_Compile ()

	let	l:currentbuffer	= bufname("%")
	let s:C_HlMessage = ""
	exe	":cclose"
	let	Sou		= expand("%")											" name of the file in the current buffer
	let	Obj		= expand("%:r").s:C_ObjExtension	" name of the object
	let SouEsc= escape( Sou, s:escfilename )
	let ObjEsc= escape( Obj, s:escfilename )

	" update : write source file if necessary
	exe	":update"
	
	" compilation if object does not exist or object exists and is older then the source	
	if !filereadable(Obj) || (filereadable(Obj) && (getftime(Obj) < getftime(Sou)))
		" &makeprg can be a string containing blanks
		let makeprg_saved='"'.&makeprg.'"'
		if expand("%:e") == s:C_CExtension
			exe		"set makeprg=".s:C_CCompiler
		else
			exe		"set makeprg=".s:C_CplusCompiler
		endif
		" 
		" COMPILATION
		"
		if s:MSWIN
			exe		"make ".s:C_CFlags." \"".SouEsc."\" -o \"".ObjEsc."\""
		else
			exe		"make ".s:C_CFlags." ".SouEsc." -o ".ObjEsc
		endif
		exe	"set makeprg=".makeprg_saved
		" 
		" open error window if necessary 
		exe	":botright cwindow"
	else
		let s:C_HlMessage = " '".Obj."' is up to date "
	endif
	
endfunction    " ----------  end of function C_Compile ----------
"
"------------------------------------------------------------------------------
"  C_Link : C_Link       {{{1
"------------------------------------------------------------------------------
"  The standard make program which is used by gvim is set to the compiler
"  (for linking) and reset after linking.
"
"  calls: C_Compile
"------------------------------------------------------------------------------
function! C_Link ()

	call	C_Compile()

	let s:C_HlMessage = ""
	let	Sou		= expand("%")						       		" name of the file in the current buffer
	let	Obj		= expand("%:r").s:C_ObjExtension	" name of the object file
	let	Exe		= expand("%:r").s:C_ExeExtension	" name of the executable
	let ObjEsc= escape( Obj, s:escfilename )
	let ExeEsc= escape( Exe, s:escfilename )
	
	" no linkage if:
	"   executable exists
	"   object exists
	"   source exists
	"   executable newer then object
	"   object newer then source

	if    filereadable(Exe)                &&
      \ filereadable(Obj)                &&
      \ filereadable(Sou)                &&
      \ (getftime(Exe) >= getftime(Obj)) &&
      \ (getftime(Obj) >= getftime(Sou))
		let s:C_HlMessage = " '".Exe."' is up to date "
		return
	endif
	
	" linkage if:
	"   object exists
	"   source exists
	"   object newer then source

	if filereadable(Obj) && (getftime(Obj) >= getftime(Sou))
		let makeprg_saved='"'.&makeprg.'"'
		if expand("%:e") == s:C_CExtension
			exe		"set makeprg=".s:C_CCompiler
		else
			exe		"set makeprg=".s:C_CplusCompiler
		endif
		let v:statusmsg="" 
		if s:MSWIN
			silent exe "make ".s:C_LFlags." ".s:C_Libs." -o \"".ExeEsc."\" \"".ObjEsc."\""
		else
			silent exe "make ".s:C_LFlags." ".s:C_Libs." -o ".ExeEsc." ".ObjEsc
		endif
		if v:statusmsg != ""
			let s:C_HlMessage = v:statusmsg 
		endif
		exe	"set makeprg=".makeprg_saved
	endif
endfunction    " ----------  end of function C_Link ----------
"
"------------------------------------------------------------------------------
"  C_Run : 	C_Run       {{{1
"  calls: C_Link
"------------------------------------------------------------------------------
"
let s:C_OutputBufferName   = "C-Output"
let s:C_OutputBufferNumber = -1
"
function! C_Run ()
"
	let Cwd	 		= getcwd()
	let Sou  		= expand("%")															" name of the source file
	let Obj  		= expand("%:r").s:C_ObjExtension					" name of the object file
	let Exe  		= Cwd."/".expand("%:r").s:C_ExeExtension	" name of the executable
	let ExeEsc  = escape( Exe, s:escfilename )						" name of the executable, escaped
	"
	let l:arguments     = exists("b:C_CmdLineArgs") ? b:C_CmdLineArgs : ''
	"
	let	l:currentbuffer	= bufname("%")
	"
	"==============================================================================
	"  run : run from the vim command line
	"==============================================================================
	if s:C_OutputGvim == "vim"
		"
		silent call C_Link()
		"
		if	executable(Exe) && getftime(Exe) >= getftime(Obj) && getftime(Obj) >= getftime(Sou)
			if s:MSWIN
				exe		"!\"".ExeEsc."\" ".l:arguments
			else
				exe		"!".ExeEsc." ".l:arguments
			endif
		else
			echomsg "file ".Exe." does not exist / is not executable"
		endif
	
	endif
	"
	"==============================================================================
	"  run : redirect output to an output buffer
	"==============================================================================
	if s:C_OutputGvim == "buffer"
		let	l:currentbuffernr	= bufnr("%")
		let l:currentdir			= getcwd()
		"
		silent call C_Link()
		"
		if l:currentbuffer ==  bufname("%")
			"
			"
			if bufloaded(s:C_OutputBufferName) != 0 && bufwinnr(s:C_OutputBufferNumber)!=-1 
				exe bufwinnr(s:C_OutputBufferNumber) . "wincmd w"
				" buffer number may have changed, e.g. after a 'save as' 
				if bufnr("%") != s:C_OutputBufferNumber
					let s:C_OutputBufferNumber	= bufnr(s:C_OutputBufferName)
					exe ":bn ".s:C_OutputBufferNumber
				endif
			else
				silent exe ":new ".s:C_OutputBufferName
				let s:C_OutputBufferNumber=bufnr("%")
				setlocal buftype=nofile
				setlocal noswapfile
				setlocal syntax=none
				setlocal bufhidden=delete
			endif
			"
			" run programm 
			"
			setlocal	modifiable
			if	executable(Exe) && getftime(Exe) >= getftime(Obj) && getftime(Obj) >= getftime(Sou)
				if s:MSWIN
					exe		"%!\"".ExeEsc."\" ".l:arguments
				else
					exe		"%!".ExeEsc." ".l:arguments
				endif
			endif
			setlocal	nomodifiable
			"
			" stdout is empty / not empty
			"
			if line("$")==1 && col("$")==1
				silent	exe ":bdelete"
			else
				if winheight(winnr()) >= line("$")
					exe bufwinnr(l:currentbuffernr) . "wincmd w" 
				endif
			endif
			"
		endif
	endif
	"
	"==============================================================================
	"  run : run in a detached xterm  (not available for MS Windows)
	"==============================================================================
	if s:C_OutputGvim == "xterm"
		"
		silent call C_Link()
		"
		if	executable(Exe) && getftime(Exe) >= getftime(Obj) && getftime(Obj) >= getftime(Sou)
			if s:MSWIN
				exe		"!\"".ExeEsc."\" ".l:arguments
			else
				silent exe '!xterm -title '.ExeEsc.' '.s:C_XtermDefaults.' -e '.s:C_Wrapper.' '.ExeEsc.' '.l:arguments.' &'
			endif
		endif
	endif

endfunction    " ----------  end of function C_Run ----------
"
"------------------------------------------------------------------------------
"  C_Arguments : Arguments for the executable       {{{1
"------------------------------------------------------------------------------
function! C_Arguments ()
	let	Exe		  = expand("%:r").s:C_ExeExtension
  if Exe == ""
		redraw
		echohl WarningMsg | echo " no file name " | echohl None
		return
  endif
	let	prompt	= 'command line arguments for "'.Exe.'" : '
	if exists("b:C_CmdLineArgs")
		let	b:C_CmdLineArgs= C_Input( prompt, b:C_CmdLineArgs )
	else
		let	b:C_CmdLineArgs= C_Input( prompt , "" )
	endif
endfunction    " ----------  end of function C_Arguments ----------
"
"----------------------------------------------------------------------
"  C_Toggle_Gvim_Xterm : Toggle comment style       {{{1
"----------------------------------------------------------------------
function! C_Toggle_Gvim_Xterm ()
	
	if s:C_OutputGvim == "vim"
		exe "aunmenu  <silent>  ".s:C_Root.'&Run.&output:\ VIM->buffer->xterm'
		exe "amenu    <silent>  ".s:C_Root.'&Run.&output:\ BUFFER->xterm->vim              <C-C>:call C_Toggle_Gvim_Xterm()<CR><CR>'
		let	s:C_OutputGvim	= "buffer"
	else
		if s:C_OutputGvim == "buffer"
			exe "aunmenu  <silent>  ".s:C_Root.'&Run.&output:\ BUFFER->xterm->vim'
			exe "amenu    <silent>  ".s:C_Root.'&Run.&output:\ XTERM->vim->buffer             <C-C>:call C_Toggle_Gvim_Xterm()<CR><CR>'
			let	s:C_OutputGvim	= "xterm"
		else
			" ---------- output : xterm -> gvim
			exe "aunmenu  <silent>  ".s:C_Root.'&Run.&output:\ XTERM->vim->buffer'
			exe "amenu    <silent>  ".s:C_Root.'&Run.&output:\ VIM->buffer->xterm            <C-C>:call C_Toggle_Gvim_Xterm()<CR><CR>'
			let	s:C_OutputGvim	= "vim"
		endif
	endif

endfunction    " ----------  end of function C_Toggle_Gvim_Xterm ----------
"
"------------------------------------------------------------------------------
"  C_XtermSize : xterm geometry       {{{1
"------------------------------------------------------------------------------
function! C_XtermSize ()
	let regex	= '-geometry\s\+\d\+x\d\+'
	let geom	= matchstr( s:C_XtermDefaults, regex )
	let geom	= matchstr( geom, '\d\+x\d\+' )
	let geom	= substitute( geom, 'x', ' ', "" )
	let	answer= C_Input("   xterm size (COLUMNS LINES) : ", geom )
	while match(answer, '^\s*\d\+\s\+\d\+\s*$' ) < 0
		let	answer= C_Input(" + xterm size (COLUMNS LINES) : ", geom )
	endwhile
	let answer  = substitute( answer, '^\s\+', "", "" )		 				" remove leading whitespaces
	let answer  = substitute( answer, '\s\+$', "", "" )						" remove trailing whitespaces
	let answer  = substitute( answer, '\s\+', "x", "" )						" replace inner whitespaces
	let s:C_XtermDefaults	= substitute( s:C_XtermDefaults, regex, "-geometry ".answer , "" )
endfunction    " ----------  end of function C_XtermSize ----------
"
"------------------------------------------------------------------------------
"  C_MakeArguments : run make       {{{1
"------------------------------------------------------------------------------

let s:C_MakeCmdLineArgs   = ""     " command line arguments for Run-make; initially empty

function! C_MakeArguments ()
	let	s:C_MakeCmdLineArgs= C_Input("make command line arguments : ",s:C_MakeCmdLineArgs)
endfunction    " ----------  end of function C_MakeArguments ----------
"
function! C_Make()
	" update : write source file if necessary
	exe	":update"
	" run make
	exe		":!make ".s:C_MakeCmdLineArgs
endfunction    " ----------  end of function C_Make ----------
"
"------------------------------------------------------------------------------
"  C_SplintArguments : splint command line arguments       {{{1
"------------------------------------------------------------------------------
function! C_SplintArguments ()
	if s:C_SplintIsExecutable==0
		let s:C_HlMessage = ' Splint is not executable or not installed! '
	else
		let	prompt	= 'Splint command line arguments for "'.expand("%").'" : '
		if exists("b:C_SplintCmdLineArgs")
			let	b:C_SplintCmdLineArgs= C_Input( prompt, b:C_SplintCmdLineArgs )
		else
			let	b:C_SplintCmdLineArgs= C_Input( prompt , "" )
		endif
	endif
endfunction    " ----------  end of function C_SplintArguments ----------
"
"------------------------------------------------------------------------------
"  C_SplintCheck : splint check       {{{1
"------------------------------------------------------------------------------
function! C_SplintCheck ()
	if s:C_SplintIsExecutable==0
		let s:C_HlMessage = ' Splint is not executable or not installed! '
		return
	endif
	let	l:currentbuffer=bufname("%")
	if &filetype != "c" && &filetype != "cpp"
		let s:C_HlMessage = ' "'.l:currentbuffer.'" seems not to be a C/C++ file '
		return
	endif
	let s:C_HlMessage = ""
	exe	":cclose"	
	silent exe	":update"
	let makeprg_saved='"'.&makeprg.'"'
	" Windows seems to need this:
	if	s:MSWIN
		:compiler splint
	endif
	:set makeprg=splint
	"	
	let l:arguments  = exists("b:C_SplintCmdLineArgs") ? b:C_SplintCmdLineArgs : ' '
	silent exe	"make ".l:arguments." ".escape(l:currentbuffer,s:escfilename)
	exe	"set makeprg=".makeprg_saved
	exe	":botright cwindow"
	"
	" message in case of success
	"
	if l:currentbuffer == bufname("%")
		let s:C_HlMessage = " Splint --- no warnings for : ".l:currentbuffer
	endif
endfunction    " ----------  end of function C_SplintCheck ----------
"
"------------------------------------------------------------------------------
"  C_CodeCheckArguments : CodeCheck command line arguments       {{{1
"------------------------------------------------------------------------------
function! C_CodeCheckArguments ()
	if s:C_CodeCheckIsExecutable==0
		let s:C_HlMessage = ' CodeCheck is not executable or not installed! '
	else
		let	prompt	= 'CodeCheck command line arguments for "'.expand("%").'" : '
		if exists("b:C_CodeCheckCmdLineArgs")
			let	b:C_CodeCheckCmdLineArgs= C_Input( prompt, b:C_CodeCheckCmdLineArgs )
		else
			let	b:C_CodeCheckCmdLineArgs= C_Input( prompt , s:C_CodeCheckOptions )
		endif
	endif
endfunction    " ----------  end of function C_CodeCheckArguments ----------
"
"------------------------------------------------------------------------------
"  C_CodeCheck : CodeCheck       {{{1
"------------------------------------------------------------------------------
function! C_CodeCheck ()
	if s:C_CodeCheckIsExecutable==0
		let s:C_HlMessage = ' CodeCheck is not executable or not installed! '
		return
	endif
	let	l:currentbuffer=bufname("%")
	if &filetype != "c" && &filetype != "cpp"
		let s:C_HlMessage = ' "'.l:currentbuffer.'" seems not to be a C/C++ file '
		return
	endif
	let s:C_HlMessage = ""
	exe	":cclose"	
	silent exe	":update"
	let makeprg_saved='"'.&makeprg.'"'
	exe	"set makeprg=".s:C_CodeCheckExeName
	" 
	" match the splint error messages (quickfix commands)
	" ignore any lines that didn't match one of the patterns
	"
	:setlocal errorformat=%f(%l)%m
	"	
	let l:arguments  = exists("b:C_CodeCheckCmdLineArgs") ? b:C_CodeCheckCmdLineArgs : ""
	if l:arguments == ""
		let l:arguments	=	s:C_CodeCheckOptions
	endif
	exe	":make ".l:arguments." ".escape( l:currentbuffer, s:escfilename )
	exe	':setlocal errorformat='
	exe	"set makeprg=".makeprg_saved
	exe	":botright cwindow"
	"
	" message in case of success
	"
	if l:currentbuffer == bufname("%")
		let s:C_HlMessage = " CodeCheck --- no warnings for : ".l:currentbuffer
	endif
endfunction    " ----------  end of function C_CodeCheck ----------
"
"------------------------------------------------------------------------------
"  C_Indent : indent       {{{1
"------------------------------------------------------------------------------
"
function! C_Indent ( mode )
	if !executable("indent") 
		let s:C_HlMessage	= ' indent is not executable or not installed! '
		return
	endif
	let	l:currentbuffer=bufname("%")
	if &filetype != "c" && &filetype != "cpp"
		let s:C_HlMessage = ' "'.l:currentbuffer.'" seems not to be a C/C++ file '
		return
	endif
	let s:C_HlMessage    = ""

	if a:mode=="a"
		if C_Input("indent whole file [y/n/Esc] : ", "y" ) != "y"
			return
		endif
		exe	":update"
		if has("MSWIN")
			silent exe ":%!indent"
		else
			silent exe ":%!indent 2> ".s:C_IndentErrorLog
		endif
		let s:C_HlMessage = ' File "'.l:currentbuffer.'" reformatted.'
	endif

	if a:mode=="v"
		if has("MSWIN")
			silent exe ":'<,'>!indent"
		else
			silent exe ":'<,'>!indent 2> ".s:C_IndentErrorLog
		endif
		let s:C_HlMessage = ' File "'.l:currentbuffer.'" (lines '.line("'<").'-'.line("'>").') reformatted. '
	endif

	if v:shell_error != 0
		let s:C_HlMessage = ' Indent reported an error when processing file "'.l:currentbuffer.'". '
	endif

endfunction    " ----------  end of function C_Indent ----------
"
"------------------------------------------------------------------------------
"  C_HlMessage : indent message     {{{1
"------------------------------------------------------------------------------
function! C_HlMessage ()
	echohl Search 
	echo s:C_HlMessage
	echohl None
endfunction    " ----------  end of function C_HlMessage ----------
"
"------------------------------------------------------------------------------
"  C_Settings : settings     {{{1
"------------------------------------------------------------------------------
function! C_Settings ()
	let	txt =     " C/C++-Support settings\n\n"
	let txt = txt.'                   author :  "'.s:C_AuthorName."\"\n"
	let txt = txt.'                 initials :  "'.s:C_AuthorRef."\"\n"
	let txt = txt.'                    email :  "'.s:C_Email."\"\n"
	let txt = txt.'                  company :  "'.s:C_Company."\"\n"
	let txt = txt.'                  project :  "'.s:C_Project."\"\n"
	let txt = txt.'         copyright holder :  "'.s:C_CopyrightHolder."\"\n"
	let txt = txt.'         C / C++ compiler :  '.s:C_CCompiler.' / '.s:C_CplusCompiler."\n"
	let txt = txt.'         C file extension :  '.s:C_CExtension.'  (everything else is C++)'."\n"
	let txt = txt.'    extension for objects :  "'.s:C_ObjExtension."\"\n"
	let txt = txt.'extension for executables :  "'.s:C_ExeExtension."\"\n"
	let txt = txt.'           compiler flags :  "'.s:C_CFlags."\"\n"
	let txt = txt.'             linker flags :  "'.s:C_LFlags."\"\n"
	let txt = txt.'                libraries :  "'.s:C_Libs."\"\n"
	let txt = txt.'   code snippet directory :  '.s:C_CodeSnippets."\n"
	let txt = txt.'       template directory :  '.s:C_Template_Directory."\n"
	let txt = txt.'opening brace on new line :  '.s:C_BraceOnNewLine."\n"
	let txt = txt.'           use C comments :  '.s:C_Comments."\n"
	let txt = txt.'    toggle C/C++ comments :  '.s:C_CommentsToggle."\n"
	if	!s:MSWIN
		let txt = txt.'           xterm defaults :  '.s:C_XtermDefaults."\n"
	endif
	" ----- dictionaries ------------------------
	if g:C_Dictionary_File != ""
		let ausgabe= substitute( g:C_Dictionary_File, ",", ",\n                           + ", "g" )
		let txt = txt."       dictionary file(s) :  ".ausgabe."\n"
	endif
	let txt = txt.'     current output dest. :  '.s:C_OutputGvim."\n"
	" ----- splint ------------------------------
	if s:C_SplintIsExecutable==1
		if exists("b:C_SplintCmdLineArgs")
			let ausgabe = b:C_SplintCmdLineArgs
		else
			let ausgabe = ""
		endif
		let txt = txt."        splint options(s) :  ".ausgabe."\n"
	endif
	" ----- code check --------------------------
	if s:C_CodeCheckIsExecutable==1
		if exists("b:C_CodeCheckCmdLineArgs")
			let ausgabe = b:C_CodeCheckCmdLineArgs
		else
			let ausgabe = s:C_CodeCheckOptions
		endif
		let txt = txt."CodeCheck (TM) options(s) :  ".ausgabe."\n"
	endif
	let txt = txt."\n"
	let	txt = txt."__________________________________________________________________________\n"
	let	txt = txt." C/C++-Support, Version ".g:C_Version." / Dr.-Ing. Fritz Mehner / mehner@fh-swf.de\n\n"
	echo txt
endfunction    " ----------  end of function C_Settings ----------
"
"------------------------------------------------------------------------------
"  C_Hardcopy : hardcopy     {{{1
"    MSWIN : a printer dialog is displayed
"    other : print PostScript to file
"------------------------------------------------------------------------------
function! C_Hardcopy (arg1)
	let Sou	= expand("%")	
  if Sou == ""
		redraw
		echohl WarningMsg | echo " no file name " | echohl None
		return
  endif
	let	Sou		= escape(Sou,s:escfilename)		" name of the file in the current buffer
	let	old_printheader=&printheader
	exe  ':set printheader='.s:C_Printheader
	" ----- normal mode ----------------
	if a:arg1=="n"
		silent exe	"hardcopy > ".Sou.".ps"		
		if	!s:MSWIN
			echo "file \"".Sou."\" printed to \"".Sou.".ps\""
		endif
	endif
	" ----- visual mode ----------------
	if a:arg1=="v"
		silent exe	"*hardcopy > ".Sou.".ps"		
		if	!s:MSWIN
			echo "file \"".Sou."\" (lines ".line("'<")."-".line("'>").") printed to \"".Sou.".ps\""
		endif
	endif
	exe  ':set printheader='.escape( old_printheader, ' %' )
endfunction    " ----------  end of function C_Hardcopy ----------
"
"------------------------------------------------------------------------------
"  C_HelpCsupport : help csupport     {{{1
"------------------------------------------------------------------------------
function! C_HelpCsupport ()
	try
		:help csupport
	catch
		exe ':helptags '.s:plugin_dir.'doc'
		:help csupport
	endtry
endfunction    " ----------  end of function C_HelpCsupport ----------
"
"-------------------------------------------------------------------------------
"   C_SetBraceOnNewLine : set C_BraceOnNewLine from the command line     {{{1
"-------------------------------------------------------------------------------
function! C_SetBraceOnNewLine ( yesno )
  if a:yesno=='yes' || a:yesno=='no'
    let s:C_BraceOnNewLine = a:yesno
	else
		echomsg "wrong argument '".a:yesno."' / 'C_BraceOnNewLine' is ".s:C_BraceOnNewLine
  endif
endfunction    " ----------  end of function C_SetBraceOnNewLine  ----------
"
"-------------------------------------------------------------------------------
"   C_SetCComments : set C_Comments     {{{1
"-------------------------------------------------------------------------------
function! C_SetCComments ( yesno )
  if a:yesno=='yes' || a:yesno=='no'
    let s:C_Comments = a:yesno
	else
		echomsg "wrong argument '".a:yesno."' / 'C_Comments' is ".s:C_Comments
  endif
endfunction    " ----------  end of function C_SetCComments  ----------
"
"-------------------------------------------------------------------------------
"   C_SetCCommentsToggle : set C_CommentsToggle from the command line     {{{1
"-------------------------------------------------------------------------------
function! C_SetCCommentsToggle ( yesno )
  if a:yesno=='yes' || a:yesno=='no'
    let s:C_CommentsToggle = a:yesno
	else
		echomsg "wrong argument '".a:yesno."' / 'C_CommentsToggle' is ".s:C_CommentsToggle
  endif
endfunction    " ----------  end of function C_SetCComments  ----------
"
"-------------------------------------------------------------------------------
"   C_SetClassName : set s:C_ClassName     {{{1
"-------------------------------------------------------------------------------
function! C_SetClassName ( ... )
	if a:0 > 0
		let s:C_ClassName = a:1
	end
endfunction    " ----------  end of function C_SetClassName  ----------

"------------------------------------------------------------------------------
"  C_CreateGuiMenus     {{{1
"------------------------------------------------------------------------------
let s:C_MenuVisible = 0								" state variable controlling the C-menus
"
function! C_CreateGuiMenus ()
	if s:C_MenuVisible != 1
		aunmenu <silent> &Tools.Load\ C\ Support
		amenu   <silent> 40.1000 &Tools.-SEP100- : 
		amenu   <silent> 40.1030 &Tools.Unload\ C\ Support <C-C>:call C_RemoveGuiMenus()<CR>
		call C_InitC()
		let s:C_MenuVisible = 1
	endif
endfunction    " ----------  end of function C_CreateGuiMenus  ----------

"------------------------------------------------------------------------------
"  C_ToolMenu     {{{1
"------------------------------------------------------------------------------
function! C_ToolMenu ()
	amenu   <silent> 40.1000 &Tools.-SEP100- : 
	amenu   <silent> 40.1030 &Tools.Load\ C\ Support <C-C>:call C_CreateGuiMenus()<CR>
endfunction    " ----------  end of function C_ToolMenu  ----------

"------------------------------------------------------------------------------
"  C_RemoveGuiMenus     {{{1
"------------------------------------------------------------------------------
function! C_RemoveGuiMenus ()
	if s:C_MenuVisible == 1
		if s:C_Root == ""
			aunmenu <silent> Comments
			aunmenu <silent> Statements
			aunmenu <silent> Preprocessor
			aunmenu <silent> Idioms
			aunmenu <silent> Snippets
			aunmenu <silent> C++
			aunmenu <silent> Run
		else
			exe "aunmenu <silent> ".s:C_Root
		endif
		"
		aunmenu <silent> &Tools.Unload\ C\ Support
		call C_ToolMenu()
		"
		let s:C_MenuVisible = 0
	endif
endfunction    " ----------  end of function C_RemoveGuiMenus  ----------

"------------------------------------------------------------------------------
"  show / hide the c-support menus
"  define key mappings (gVim only) 
"------------------------------------------------------------------------------
"
if has("gui_running")
	"
	call C_ToolMenu()
	"
	if s:C_LoadMenus == 'yes'
		call C_CreateGuiMenus()
	endif
	"
	nmap  <unique>  <silent>  <Leader>lcs   :call C_CreateGuiMenus()<CR>
	nmap  <unique>  <silent>  <Leader>ucs   :call C_RemoveGuiMenus()<CR>
	"
endif

"------------------------------------------------------------------------------
"  Automated header insertion
"  Local settings for the quickfix window
"------------------------------------------------------------------------------
"
if has("autocmd")
	"
	"  *.h has filetype 'cpp' by default; this can be changed to 'c' :
	"
	if s:C_TypeOfH=='c' 
		autocmd BufNewFile,BufEnter  *.h  :set filetype=c
	end
	"
	"  Automated header insertion (suffixes from the gcc manual)
	"
	if	s:MSWIN
		" Windows does not distinguish between lower and upper case
		autocmd BufEnter   *.c,*.cc,*.cp,*.cxx,*.cpp,*.c++,*.i,*.ii,*.h,*.hh,*.hxx,*.hpp
					\		call C_ToggleCommentStyle()
		autocmd BufNewFile  *.c,*.cc,*.cp,*.cxx,*.cpp,*.c++,*.i,*.ii
					\		call C_CommentTemplates('cheader')
		autocmd BufNewFile  *.h,*.hh,*.hxx,*.hpp
					\		call C_CommentTemplates('hheader')
	else
		autocmd BufNewFile,BufEnter   *.c,*.cc,*.cp,*.cxx,*.cpp,*.c++,*.C,*.i,*.ii,*.h,*.H,*.hh,*.hxx,*.hpp
					\		call C_ToggleCommentStyle()
		autocmd BufNewFile  *.c,*.cc,*.cp,*.cxx,*.cpp,*.c++,*.C,*.i,*.ii
					\		call C_CommentTemplates('cheader')
		autocmd BufNewFile  *.h,*.H,*.hh,*.hxx,*.hpp
					\		call C_CommentTemplates('hheader')
	endif
	"
	" C/C++ source code files which should not be preprocessed.
	"
	autocmd BufNewFile,BufRead  *.i  :set filetype=c
	autocmd BufNewFile,BufRead  *.ii :set filetype=cpp
	"
	" Wrap error descriptions in the quickfix window.
	"
	autocmd BufReadPost quickfix  setlocal wrap | setlocal linebreak 
	"
endif " has("autocmd")
"
"=====================================================================================
" vim: tabstop=2 shiftwidth=2 foldmethod=marker 
