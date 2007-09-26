"###############################################################################################
"  
"       Filename:  c.vim
"  
"    Description:  C/C++-IDE. Write programs by inserting complete statements, 
"                  comments, idioms, code snippets, templates and comments.
"                  Compile, link and run one-file-programs without a makefile.
"                  See also help file csupport.txt .
"  
"   GVIM Version:  7.0+
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
"       Revision:  $Id: c.vim,v 1.27 2007/09/26 07:58:39 mehner Exp $
"        
"------------------------------------------------------------------------------
" 
if v:version < 700
  echohl WarningMsg | echo 'The plugin c-support.vim needs Vim version >= 7 .'| echohl None
  finish
endif
"
" Prevent duplicate loading: 
" 
if exists("g:C_Version") || &cp
 finish
endif
let g:C_Version= "5.0.1"  							" version number of this script; do not change
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
  let s:escfilename      = ''
  let s:plugin_dir       = $VIM.'\vimfiles\'
  let s:C_CodeSnippets   = s:plugin_dir.'c-support/codesnippets/'
  let s:C_IndentErrorLog = $HOME.'.indent.errorlog'
	let s:installation	   = 'system'
	"
else
	"
  let s:escfilename 	= ' \%#[]'
	let s:installation	= 'local'
	"
	" user / system wide installation (Linux/Unix)
	"
	if match( expand("<sfile>"), $VIM ) >= 0
		" system wide installation 
		let s:plugin_dir  = $VIM.'/vimfiles/'
		let s:installation	= 'system'
	else
		" user installation assumed
		let s:plugin_dir  = $HOME.'/.vim/'
	endif
	"
	let s:C_CodeSnippets   = $HOME.'/.vim/c-support/codesnippets/'
	let s:C_IndentErrorLog = $HOME.'/.indent.errorlog'
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
if	s:MSWIN
	let s:C_CCompiler           = 'gcc.exe'  " the C   compiler
	let s:C_CplusCompiler       = 'g++.exe'  " the C++ compiler
	let s:C_ExeExtension        = '.exe'     " file extension for executables (leading point required)
	let s:C_ObjExtension        = '.obj'     " file extension for objects (leading point required)
else                          
	let s:C_CCompiler           = 'gcc'      " the C   compiler
	let s:C_CplusCompiler       = 'g++'      " the C++ compiler
	let s:C_ExeExtension        = ''         " file extension for executables (leading point required)
	let s:C_ObjExtension        = '.o'       " file extension for objects (leading point required)
endif

let s:C_CExtension     				= 'c'                    " C file extension; everything else is C++
let s:C_CFlags         				= '-Wall -g -O0 -c'      " compiler flags: compile, don't optimize
let s:C_CodeCheckExeName      = 'check'
let s:C_CodeCheckOptions      = '-K13'
let s:C_LFlags         				= '-Wall -g -O0'         " compiler flags: link   , don't optimize
let s:C_Libs           				= '-lm'                  " libraries to use
let s:C_LineEndCommColDefault = 49
let s:C_LoadMenus      				= 'yes'
let s:C_MenuHeader     				= 'yes'
let s:C_OutputGvim            = 'vim'
let s:C_Printheader           = "%<%f%h%m%<  %=%{strftime('%x %X')}     Page %N"
let s:C_Root  	       				= '&C\/C\+\+.'           " the name of the root menu of this plugin
let s:C_TypeOfH               = 'cpp'
let s:C_Wrapper               = s:plugin_dir.'c-support/scripts/wrapper.sh'
let s:C_XtermDefaults         = '-fa courier -fs 12 -geometry 80x24'
"
let s:C_GlobalTemplateFile    = s:plugin_dir.'c-support/templates/Templates'
let s:C_GlobalTemplateDir     = fnamemodify( s:C_GlobalTemplateFile, ":p:h" ).'/'
let s:C_LocalTemplateFile     = $HOME.'/.vim/c-support/templates/Templates'
let s:C_LocalTemplateDir      = fnamemodify( s:C_LocalTemplateFile, ":p:h" ).'/'
let s:C_TemplateOverwrittenMsg= 'yes'
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
call C_CheckGlobal('C_CCompiler              ')
call C_CheckGlobal('C_CExtension             ')
call C_CheckGlobal('C_CFlags                 ')
call C_CheckGlobal('C_CodeCheckExeName       ')
call C_CheckGlobal('C_CodeCheckOptions       ')
call C_CheckGlobal('C_CodeSnippets           ')
call C_CheckGlobal('C_CplusCompiler          ')
call C_CheckGlobal('C_ExeExtension           ')
call C_CheckGlobal('C_GlobalTemplateFile     ')
call C_CheckGlobal('C_IndentErrorLog         ')
call C_CheckGlobal('C_LFlags                 ')
call C_CheckGlobal('C_Libs                   ')
call C_CheckGlobal('C_LineEndCommColDefault  ')
call C_CheckGlobal('C_LoadMenus              ')
call C_CheckGlobal('C_LocalTemplateFile      ')
call C_CheckGlobal('C_MenuHeader             ')
call C_CheckGlobal('C_ObjExtension           ')
call C_CheckGlobal('C_OutputGvim             ')
call C_CheckGlobal('C_Printheader            ')
call C_CheckGlobal('C_Root                   ')
call C_CheckGlobal('C_TemplateOverwrittenMsg ')
call C_CheckGlobal('C_TypeOfH                ')
call C_CheckGlobal('C_XtermDefaults          ')
"
"----- some variables for internal use only -----------------------------------
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
"  Control variables (not user configurable)
"------------------------------------------------------------------------------
let s:Attribute                = { 'below':'', 'above':'', 'start':'', 'append':'', 'insert':'' }
let s:C_Attribute              = {}
let s:C_ExpansionLimit         = 10
let s:C_FileVisited            = []
"
let s:C_MacroNameRegex         = '\([a-zA-Z][a-zA-Z0-9_]*\)'
let s:C_MacroLineRegex				 = '^\s*|'.s:C_MacroNameRegex.'|\s*=\s*\(.*\)'
let s:C_ExpansionRegex				 = '|?'.s:C_MacroNameRegex.'\(:\a\)\?|'
let s:C_NonExpansionRegex			 = '|'.s:C_MacroNameRegex.'\(:\a\)\?|'
"
let s:C_TemplateNameDelimiter  = '-+_,\. '
let s:C_TemplateLineRegex			 = '^==\s*\([a-zA-Z][0-9a-zA-Z'.s:C_TemplateNameDelimiter
let s:C_TemplateLineRegex			.= ']\+\)\s*==\s*\([a-z]\+\s*==\)\?'
"
let s:C_ExpansionCounter       = {}
let s:C_Template               = {}
let s:C_Macro                  = {'|AUTHOR|'         : 'first name surname', 
											\						'|AUTHORREF|'      : '',
											\						'|EMAIL|'          : '',
											\						'|COMPANY|'        : '',
											\						'|PROJECT|'        : '',
											\						'|COPYRIGHTHOLDER|': '' 
											\						}
let	s:C_MacroFlag								= {	':l' : 'lowercase'			, 
											\							':u' : 'uppercase'			, 
											\							':c' : 'capitalize'		, 
											\							':L' : 'legalize name'	, 
											\						}

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
	exe "amenu <silent> ".s:C_Root.'&Comments.end-of-&line\ comment           <Esc><Esc><Esc>:call C_LineEndComment( )<CR>'
	exe "vmenu <silent> ".s:C_Root.'&Comments.end-of-&line\ comment           <Esc><Esc><Esc>:call C_MultiLineEndComments( )<CR>'

	exe "amenu <silent> ".s:C_Root.'&Comments.ad&just\ end-of-line\ com\.     <Esc><Esc>:call C_AdjustLineEndComm("a")<CR>'
	exe "vmenu <silent> ".s:C_Root.'&Comments.ad&just\ end-of-line\ com\.     <Esc><Esc>:call C_AdjustLineEndComm("v")<CR>'

	exe "amenu <silent> ".s:C_Root.'&Comments.&set\ end-of-line\ com\.\ col\. <Esc><Esc>:call C_GetLineEndCommCol()<CR>'
	
	exe "amenu  ".s:C_Root.'&Comments.-SEP10-                              :'
	exe "amenu <silent> ".s:C_Root.'&Comments.code\ ->\ comment\ \/&*\ *\/   <Esc><Esc>:call C_CodeComment("a","yes")<CR><Esc>:nohlsearch<CR>j'
	exe "vmenu <silent> ".s:C_Root.'&Comments.code\ ->\ comment\ \/&*\ *\/   <Esc><Esc>:call C_CodeComment("v","yes")<CR><Esc>:nohlsearch<CR>j'
	exe "amenu <silent> ".s:C_Root.'&Comments.code\ ->\ comment\ &\/\/       <Esc><Esc>:call C_CodeComment("a","no")<CR><Esc>:nohlsearch<CR>j'
	exe "vmenu <silent> ".s:C_Root.'&Comments.code\ ->\ comment\ &\/\/       <Esc><Esc>:call C_CodeComment("v","no")<CR><Esc>:nohlsearch<CR>j'
	exe "amenu <silent> ".s:C_Root.'&Comments.c&omment\ ->\ code             <Esc><Esc>:call C_CommentCode("a")<CR><Esc>:nohlsearch<CR>'
	exe "vmenu <silent> ".s:C_Root.'&Comments.c&omment\ ->\ code             <Esc><Esc>:call C_CommentCode("v")<CR><Esc>:nohlsearch<CR>'
	
	exe "amenu          ".s:C_Root.'&Comments.-SEP0-                  :'
	exe "amenu <silent> ".s:C_Root.'&Comments.&frame\ comment         <Esc><Esc>:call C_InsertTemplate("comment.frame")<CR>'
	exe "amenu <silent> ".s:C_Root.'&Comments.f&unction\ description  <Esc><Esc>:call C_InsertTemplate("comment.function")<CR>'
	exe "amenu          ".s:C_Root.'&Comments.-SEP1-                  :'
	exe "amenu <silent> ".s:C_Root.'&Comments.&method\ description    <Esc><Esc>:call C_InsertTemplate("comment.method")<CR>'
	exe "amenu <silent> ".s:C_Root.'&Comments.cl&ass\ description     <Esc><Esc>:call C_InsertTemplate("comment.class")<CR>'
	exe "amenu          ".s:C_Root.'&Comments.-SEP2-                  :'
	exe "amenu <silent> ".s:C_Root.'&Comments.file\ description         <Esc><Esc>:call C_InsertTemplate("comment.file-description")<CR>'
	exe "amenu          ".s:C_Root.'&Comments.-SEP3-                  :'
	"
	"----- Submenu : C-Comments : file sections  -------------------------------------------------------------
	"
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.file\ sections<Tab>C\/C\+\+            <Esc>'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.-Sep0-                                 :'
	"
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.&Header\ File\ Includes  <Esc><Esc>:call C_InsertTemplate("comment.file-section-cpp-header-includes")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.Local\ &Macros           <Esc><Esc>:call C_InsertTemplate("comment.file-section-cpp-macros")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.Local\ &Type\ Def\.      <Esc><Esc>:call C_InsertTemplate("comment.file-section-cpp-typedefs")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.Local\ &Data\ Types      <Esc><Esc>:call C_InsertTemplate("comment.file-section-cpp-data-types")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.Local\ &Variables        <Esc><Esc>:call C_InsertTemplate("comment.file-section-cpp-class-defs")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.Local\ &Prototypes       <Esc><Esc>:call C_InsertTemplate("comment.file-section-cpp-local-variables")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.&Exp\.\ Function\ Def\.  <Esc><Esc>:call C_InsertTemplate("comment.file-section-cpp-prototypes")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.&Local\ Function\ Def\.  <Esc><Esc>:call C_InsertTemplate("comment.file-section-cpp-function-defs-exported")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.-SEP6-                   :'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.Local\ &Class\ Def\.     <Esc><Esc>:call C_InsertTemplate("comment.file-section-cpp-function-defs-local")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.E&xp\.\ Class\ Impl\.    <Esc><Esc>:call C_InsertTemplate("comment.file-section-cpp-class-implementations-exported")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&C\/C\+\+-file\ sections.L&ocal\ Class\ Impl\.    <Esc><Esc>:call C_InsertTemplate("comment.file-section-cpp-class-implementations-local")<CR>'
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
	exe "amenu  ".s:C_Root.'&Comments.&H-file\ sections.&Header\ File\ Includes    <Esc><Esc>:call C_InsertTemplate("comment.file-section-hpp-header-includes")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&H-file\ sections.Exported\ &Macros          <Esc><Esc>:call C_InsertTemplate("comment.file-section-hpp-macros")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&H-file\ sections.Exported\ &Type\ Def\.     <Esc><Esc>:call C_InsertTemplate("comment.file-section-hpp-exported-typedefs")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&H-file\ sections.Exported\ &Data\ Types     <Esc><Esc>:call C_InsertTemplate("comment.file-section-hpp-exported-data-types")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&H-file\ sections.Exported\ &Variables       <Esc><Esc>:call C_InsertTemplate("comment.file-section-hpp-exported-class-defs")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&H-file\ sections.Exported\ &Funct\.\ Decl\. <Esc><Esc>:call C_InsertTemplate("comment.file-section-hpp-exported-variables")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&H-file\ sections.-SEP4-                     :'
	exe "amenu  ".s:C_Root.'&Comments.&H-file\ sections.E&xported\ Class\ Def\.    <Esc><Esc>:call C_InsertTemplate("comment.file-section-hpp-exported-function-declarations")<CR>'

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
"
	exe "amenu  ".s:C_Root.'&Comments.&KEYWORD+comm\..\:&BUG\:          <Esc><Esc>$<Esc>:call C_InsertTemplate("comment.keyword-bug")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&KEYWORD+comm\..\:&COMPILER\:     <Esc><Esc>$<Esc>:call C_InsertTemplate("comment.keyword-compiler")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&KEYWORD+comm\..\:&TODO\:         <Esc><Esc>$<Esc>:call C_InsertTemplate("comment.keyword-todo")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&KEYWORD+comm\..\:T&RICKY\:       <Esc><Esc>$<Esc>:call C_InsertTemplate("comment.keyword-tricky")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&KEYWORD+comm\..\:&WARNING\:      <Esc><Esc>$<Esc>:call C_InsertTemplate("comment.keyword-warning")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&KEYWORD+comm\..\:W&ORKAROUND\:   <Esc><Esc>$<Esc>:call C_InsertTemplate("comment.keyword-workaround")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.&KEYWORD+comm\..\:&new\ keyword\: <Esc><Esc>$<Esc>:call C_InsertTemplate("comment.keyword-keyword")<CR>'
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
	"----- Submenu : C-Comments : Tags  ----------------------------------------------------------
	"
	exe "amenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).tags\ (plugin)<Tab>C\/C\+\+     <Esc>'
	exe "amenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).-Sep0-            :'
	"
	exe "amenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).&AUTHOR           <Esc><Esc>:call C_InsertMacroValue("AUTHOR")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).AUTHOR&REF        <Esc><Esc>:call C_InsertMacroValue("AUTHORREF")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).&COMPANY          <Esc><Esc>:call C_InsertMacroValue("COMPANY")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).C&OPYRIGHTHOLDER  <Esc><Esc>:call C_InsertMacroValue("COPYRIGHTHOLDER")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).&EMAIL            <Esc><Esc>:call C_InsertMacroValue("EMAIL")<CR>'
	exe "amenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).&PROJECT          <Esc><Esc>:call C_InsertMacroValue("PROJECT")<CR>'
                                       
	exe "imenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).&AUTHOR           <Esc><Esc>:call C_InsertMacroValue("AUTHOR")<CR>a'
	exe "imenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).AUTHOR&REF        <Esc><Esc>:call C_InsertMacroValue("AUTHORREF")<CR>a'
	exe "imenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).&COMPANY          <Esc><Esc>:call C_InsertMacroValue("COMPANY")<CR>a'
	exe "imenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).C&OPYRIGHTHOLDER  <Esc><Esc>:call C_InsertMacroValue("COPYRIGHTHOLDER")<CR>a'
	exe "imenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).&EMAIL            <Esc><Esc>:call C_InsertMacroValue("EMAIL")<CR>a'
	exe "imenu  ".s:C_Root.'&Comments.ta&gs\ (plugin).&PROJECT          <Esc><Esc>:call C_InsertMacroValue("PROJECT")<CR>a'
	"
	"
	exe "amenu  ".s:C_Root.'&Comments.-SEP9-                     :'
	"
	exe " menu  ".s:C_Root.'&Comments.&date                   a<C-R>=strftime("%x")<CR>'
	exe "imenu  ".s:C_Root.'&Comments.&date                    <C-R>=strftime("%x")<CR>'
	exe " menu  ".s:C_Root.'&Comments.date\ &time             a<C-R>=strftime("%x %X %Z")<CR>'
	exe "imenu  ".s:C_Root.'&Comments.date\ &time              <C-R>=strftime("%x %X %Z")<CR>'

	exe "amenu  ".s:C_Root.'&Comments.-SEP12-                    :'
	exe "amenu <silent> ".s:C_Root.'&Comments.\/\/\ xxx\ \ \ \ \ &->\ \ \/*\ xxx\ *\/    <Esc><Esc>:call C_CommentCppToC()<CR>'
	exe "vmenu <silent> ".s:C_Root.'&Comments.\/\/\ xxx\ \ \ \ \ &->\ \ \/*\ xxx\ *\/    <Esc><Esc>:'."'<,'>".'call C_CommentCppToC()<CR>'
	exe "amenu <silent> ".s:C_Root.'&Comments.\/*\ xxx\ *\/\ \ -&>\ \ \/\/\ xxx          <Esc><Esc>:call C_CommentCToCpp()<CR>'
	exe "vmenu <silent> ".s:C_Root.'&Comments.\/*\ xxx\ *\/\ \ -&>\ \ \/\/\ xxx          <Esc><Esc>:'."'<,'>".'call C_CommentCToCpp()<CR>'
	"
	"===============================================================================================
	"----- Menu : C-Statements-------------------------------------------------   {{{2
	"===============================================================================================
	"
	if s:C_MenuHeader == 'yes'
		exe "amenu  ".s:C_Root.'&Statements.&Statements<Tab>C\/C\+\+     <Esc>'
		exe "amenu  ".s:C_Root.'&Statements.-Sep00-                      :'
	endif
	"
	exe "amenu <silent>".s:C_Root.'&Statements.&do\ \{\ \}\ while          <Esc><Esc>:call C_InsertTemplate("statements.do-while")<CR>'
	exe "vmenu <silent>".s:C_Root.'&Statements.&do\ \{\ \}\ while          <Esc><Esc>:call C_InsertTemplate("statements.do-while", "v")<CR>'
	"
	exe "amenu <silent>".s:C_Root.'&Statements.f&or                        <Esc><Esc>:call C_InsertTemplate("statements.for")<CR>'
	"
	exe "anoremenu <silent>".s:C_Root.'&Statements.fo&r\ \{\ \}            <Esc><Esc>:call C_InsertTemplate("statements.for-block")<CR>'
	exe "vnoremenu <silent>".s:C_Root.'&Statements.fo&r\ \{\ \}            <Esc><Esc>:call C_InsertTemplate("statements.for-block", "v")<CR>'
	"
	exe "amenu <silent>".s:C_Root.'&Statements.&if                         <Esc><Esc>:call C_InsertTemplate("statements.if")<CR>'
	"
	exe "amenu <silent>".s:C_Root.'&Statements.i&f\ \{\ \}                 <Esc><Esc>:call C_InsertTemplate("statements.if-block")<CR>'
	exe "vmenu <silent>".s:C_Root.'&Statements.i&f\ \{\ \}                 <Esc><Esc>:call C_InsertTemplate("statements.if-block", "v")<CR>'

	exe "amenu <silent>".s:C_Root.'&Statements.if\ &else                   <Esc><Esc>:call C_InsertTemplate("statements.if-else")<CR>'
	exe "vmenu <silent>".s:C_Root.'&Statements.if\ &else                   <Esc><Esc>:call C_InsertTemplate("statements.if-else", "v")<CR>'
	"
	exe "amenu <silent>".s:C_Root.'&Statements.if\ \{\ \}\ e&lse\ \{\ \}   <Esc><Esc>:call C_InsertTemplate("statements.if-block-else")<CR>'
	exe "vmenu <silent>".s:C_Root.'&Statements.if\ \{\ \}\ e&lse\ \{\ \}   <Esc><Esc>:call C_InsertTemplate("statements.if-block-else", "v")<CR>'
	"
	exe "amenu <silent>".s:C_Root.'&Statements.&while                      <Esc><Esc>:call C_InsertTemplate("statements.while")<CR>'
	"
	exe "amenu <silent>".s:C_Root.'&Statements.w&hile\ \{\ \}              <Esc><Esc>:call C_InsertTemplate("statements.while-block")<CR>'
	exe "vmenu <silent>".s:C_Root.'&Statements.w&hile\ \{\ \}              <Esc><Esc>:call C_InsertTemplate("statements.while-block", "v")<CR>'
	"
	exe "amenu <silent>".s:C_Root.'&Statements.&switch\ \{\ \}             <Esc><Esc>:call C_InsertTemplate("statements.switch")<CR>'
	exe "vmenu <silent>".s:C_Root.'&Statements.&switch\ \{\ \}             <Esc><Esc>:call C_InsertTemplate("statements.switch", "v")<CR>'
	"
	exe "amenu  ".s:C_Root.'&Statements.&case\ \.\.\.\ break               <<Esc><Esc>:call C_InsertTemplate("statements.case")<CR>'
	"
	"
	exe "amenu <silent>".s:C_Root.'&Statements.&\{\ \}                     <Esc><Esc>:call C_InsertTemplate("statements.block")<CR>'
	exe "vmenu <silent>".s:C_Root.'&Statements.&\{\ \}                   	 <Esc><Esc>:call C_InsertTemplate("statements.block", "v")<CR>'
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
	exe "amenu <silent> ".s:C_Root.'&Idioms.&function                   <Esc><Esc>:call C_InsertTemplate("idioms.function")<CR>'
	exe "vmenu <silent> ".s:C_Root.'&Idioms.&function                   <Esc><Esc>:call C_InsertTemplate("idioms.function", "v")<CR>'
	exe "amenu <silent> ".s:C_Root.'&Idioms.s&tatic\ function           <Esc><Esc>:call C_InsertTemplate("idioms.function-static")<CR>'
	exe "vmenu <silent> ".s:C_Root.'&Idioms.s&tatic\ function           <Esc><Esc>:call C_InsertTemplate("idioms.function-static", "v")<CR>'
	exe "amenu <silent> ".s:C_Root.'&Idioms.&main                       <Esc><Esc>:call C_InsertTemplate("idioms.main")<CR>'
	exe "vmenu <silent> ".s:C_Root.'&Idioms.&main                       <Esc><Esc>:call C_InsertTemplate("idioms.main", "v")<CR>'

	exe "amenu          ".s:C_Root.'&Idioms.-SEP1-                      :'
	exe "amenu          ".s:C_Root.'&Idioms.for(x=&0;\ x<n;\ x\+=1)     <Esc><Esc>:call C_CodeFor("up"  , "a")<CR>a'
	exe "amenu          ".s:C_Root.'&Idioms.for(x=&n-1;\ x>=0;\ x\-=1)  <Esc><Esc>:call C_CodeFor("down", "a")<CR>a'
	exe "vmenu          ".s:C_Root.'&Idioms.for(x=&0;\ x<n;\ x\+=1)     <Esc><Esc>:call C_CodeFor("up"  , "v")<CR>'
	exe "vmenu          ".s:C_Root.'&Idioms.for(x=&n-1;\ x>=0;\ x\-=1)  <Esc><Esc>:call C_CodeFor("down", "v")<CR>'
	
	exe "amenu          ".s:C_Root.'&Idioms.-SEP2-                      :'
	exe "amenu <silent> ".s:C_Root.'&Idioms.&enum\+typedef              <Esc><Esc>:call C_InsertTemplate("idioms.enum")<CR>'
	exe "amenu <silent> ".s:C_Root.'&Idioms.&struct\+typedef            <Esc><Esc>:call C_InsertTemplate("idioms.struct")<CR>'
	exe "amenu <silent> ".s:C_Root.'&Idioms.&union\+typedef             <Esc><Esc>:call C_InsertTemplate("idioms.union")<CR>'
	exe "vmenu <silent> ".s:C_Root.'&Idioms.&enum\+typedef              <Esc><Esc>:call C_InsertTemplate("idioms.enum"  , "v")<CR>'
	exe "vmenu <silent> ".s:C_Root.'&Idioms.&struct\+typedef            <Esc><Esc>:call C_InsertTemplate("idioms.struct", "v")<CR>'
	exe "vmenu <silent> ".s:C_Root.'&Idioms.&union\+typedef             <Esc><Esc>:call C_InsertTemplate("idioms.union" , "v")<CR>'
	exe "amenu          ".s:C_Root.'&Idioms.-SEP3-                      :'
	"
	exe " noremenu          ".s:C_Root.'&Idioms.&printf                     <Esc><Esc>oprintf("\n");<Esc>2F"a'
	exe "inoremenu          ".s:C_Root.'&Idioms.&printf                                printf("\n");<Esc>2F"a'
	
	exe " noremenu          ".s:C_Root.'&Idioms.s&canf                      <Esc><Esc>oscanf("", & );<Esc>F"i'
	exe "inoremenu          ".s:C_Root.'&Idioms.s&canf                                 scanf("", & );<Esc>F"i'
	"
	exe "amenu          ".s:C_Root.'&Idioms.-SEP4-                       :'
	exe "amenu <silent> ".s:C_Root.'&Idioms.p=ca&lloc\(n,sizeof(type)\)  <Esc><Esc>:call C_InsertTemplate("idioms.calloc")<CR>'
	exe "amenu <silent> ".s:C_Root.'&Idioms.p=m&alloc\(sizeof(type)\)    <Esc><Esc>:call C_InsertTemplate("idioms.malloc")<CR>'
	"
	exe "anoremenu <silent> ".s:C_Root.'&Idioms.si&zeof(\ \)             isizeof()<Left>'
	exe "inoremenu <silent> ".s:C_Root.'&Idioms.si&zeof(\ \)             sizeof()<Left>'
	exe "vnoremenu <silent> ".s:C_Root.'&Idioms.si&zeof(\ \)             ssizeof()<Esc>P'
	"
	exe "anoremenu <silent> ".s:C_Root.'&Idioms.asse&rt(\ \)             oassert();<Left><Left>'
	exe "vnoremenu <silent> ".s:C_Root.'&Idioms.asse&rt(\ \)             sassert();<Esc>F(p'
	exe "amenu          ".s:C_Root.'&Idioms.-SEP5-                       :'
	exe "amenu <silent> ".s:C_Root.'&Idioms.open\ &input\ file           <Esc><Esc>:call C_InsertTemplate("idioms.open-input-file")<CR>'
	exe "amenu <silent> ".s:C_Root.'&Idioms.open\ &output\ file          <Esc><Esc>:call C_InsertTemplate("idioms.open-output-file")<CR>'
	exe "amenu <silent> ".s:C_Root.'&Idioms.fscanf                       <Esc><Esc>:call C_InsertTemplate("idioms.fscanf")<CR>'
	exe "amenu <silent> ".s:C_Root.'&Idioms.fprintf                      <Esc><Esc>:call C_InsertTemplate("idioms.fprintf")<CR>'
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
	exe "amenu  ".s:C_Root.'&Preprocessor.#&define                       <Esc><Esc>:call C_InsertTemplate("preprocessor.define")<CR>'
	exe "amenu  ".s:C_Root.'&Preprocessor.&#undef                        <Esc><Esc>:call C_InsertTemplate("preprocessor.undefine")<CR>'
	"
	exe "amenu  ".s:C_Root.'&Preprocessor.#&if\ #else\ #endif            <Esc><Esc>:call C_InsertTemplate("preprocessor.if-else-endif")<CR>'
	exe "amenu  ".s:C_Root.'&Preprocessor.#i&fdef\ #else\ #endif         <Esc><Esc>:call C_InsertTemplate("preprocessor.ifdef-else-endif")<CR>'
	exe "amenu  ".s:C_Root.'&Preprocessor.#if&ndef\ #else\ #endif        <Esc><Esc>:call C_InsertTemplate("preprocessor.ifndef-else-endif")<CR>'
	exe "amenu  ".s:C_Root.'&Preprocessor.#ifnd&ef\ #def\ #endif         <Esc><Esc>:call C_InsertTemplate("preprocessor.ifndef-def-endif")<CR>'
	exe "amenu  ".s:C_Root.'&Preprocessor.#if\ &0\ #endif                <Esc><Esc>:call C_PPIf0("a")<CR>2ji'
	"
	exe "vmenu  ".s:C_Root.'&Preprocessor.#&if\ #else\ #endif            <Esc><Esc>:call C_InsertTemplate("preprocessor.if-else-endif", "v")<CR>'
	exe "vmenu  ".s:C_Root.'&Preprocessor.#i&fdef\ #else\ #endif         <Esc><Esc>:call C_InsertTemplate("preprocessor.ifdef-else-endif", "v")<CR>'
	exe "vmenu  ".s:C_Root.'&Preprocessor.#if&ndef\ #else\ #endif        <Esc><Esc>:call C_InsertTemplate("preprocessor.ifndef-else-endif", "v")<CR>'
	exe "vmenu  ".s:C_Root.'&Preprocessor.#ifnd&ef\ #def\ #endif         <Esc><Esc>:call C_InsertTemplate("preprocessor.ifndef-def-endif", "v")<CR>'
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
	exe "amenu <silent> ".s:C_Root.'C&++.&method\ implement\.          <Esc><Esc>:call C_InsertTemplate("cpp.method-implementation")<CR>'

	exe "amenu <silent> ".s:C_Root.'C&++.&class                        <Esc><Esc>:call C_InsertTemplate("cpp.class")<CR>'
	exe "amenu <silent> ".s:C_Root.'C&++.class\ (w\.\ &new)            <Esc><Esc>:call C_InsertTemplate("cpp.class-using-new")<CR>'
	exe "amenu <silent> ".s:C_Root.'C&++.-SEP3-                        :'
	exe "amenu <silent> ".s:C_Root.'C&++.tem&pl\.\ method\ impl\.      <Esc><Esc>:call C_InsertTemplate("cpp.template-method-implementation")<CR>'
	exe "amenu <silent> ".s:C_Root.'C&++.&templ\.\ class               <Esc><Esc>:call C_InsertTemplate("cpp.template-class")<CR>'
	exe "amenu <silent> ".s:C_Root.'C&++.templ\.\ class\ (w\.\ ne&w)   <Esc><Esc>:call C_InsertTemplate("cpp.template-class-using-new")<CR>'

	exe "amenu <silent> ".s:C_Root.'C&++.-SEP31-                       :'
	exe "amenu <silent> ".s:C_Root.'C&++.templ\.\ &function            <Esc><Esc>:call C_InsertTemplate("cpp.template-function")<CR>'
	exe "amenu <silent> ".s:C_Root.'C&++.&error\ class                 <Esc><Esc>:call C_InsertTemplate("cpp.error-class")<CR>'
	exe "amenu <silent> ".s:C_Root.'C&++.-SEP4-                        :'
	exe "amenu <silent> ".s:C_Root.'C&++.operator\ &<<                 <Esc><Esc>:call C_InsertTemplate("cpp.operator-in")<CR>'
	exe "amenu <silent> ".s:C_Root.'C&++.operator\ &>>                 <Esc><Esc>:call C_InsertTemplate("cpp.operator-out")<CR>'
	exe "amenu <silent> ".s:C_Root.'C&++.-SEP5-                        :'
	exe "amenu <silent> ".s:C_Root.'C&++.tr&y\ \.\.\ catch             <Esc><Esc>:call C_InsertTemplate("cpp.try-catch")<CR>'
	exe "vmenu <silent> ".s:C_Root.'C&++.tr&y\ \.\.\ catch             <Esc><Esc>:call C_InsertTemplate("cpp.try-catch", "v")<CR>'
	exe "amenu <silent> ".s:C_Root.'C&++.catc&h                        <Esc><Esc>:call C_InsertTemplate("cpp.catch")<CR>'
	exe "vmenu <silent> ".s:C_Root.'C&++.catc&h                        <Esc><Esc>:call C_InsertTemplate("cpp.catch", "v")<CR>'

	exe "amenu <silent> ".s:C_Root.'C&++.catch\(&\.\.\.\)              <Esc><Esc>:call C_InsertTemplate("cpp.catch-points")<CR>'
	exe "vmenu <silent> ".s:C_Root.'C&++.catch\(&\.\.\.\)              <Esc><Esc>:call C_InsertTemplate("cpp.catch-points", "v")<CR>'

	exe "amenu <silent> ".s:C_Root.'C&++.-SEP6-                        :'
	exe "amenu <silent> ".s:C_Root.'C&++.open\ input\ file\ \ \(&4\)   <Esc><Esc>:call C_InsertTemplate("cpp.open-input-file")<CR>'
	exe "amenu <silent> ".s:C_Root.'C&++.open\ output\ file\ \(&5\)    <Esc><Esc>:call C_InsertTemplate("cpp.open-output-file")<CR>'
	exe "amenu <silent> ".s:C_Root.'C&++.-SEP7-                        :'

	exe " menu <silent> ".s:C_Root.'C&++.&using\ namespace\ std;       <Esc><Esc>ousing namespace std;<CR>'
	exe " menu <silent> ".s:C_Root.'C&++.usin&g\ namespace\ ;          <Esc><Esc>ousing namespace ;<Esc>$i'
	exe "amenu <silent> ".s:C_Root.'C&++.namespace\ &\{\ \}            <Esc><Esc>:call C_InsertTemplate("cpp.namespace")<CR>'

	exe "imenu <silent> ".s:C_Root.'C&++.&using\ namespace\ std;       using namespace std;<CR>'
	exe "imenu <silent> ".s:C_Root.'C&++.usin&g\ namespace\ ;          using namespace ;<Esc>$i'
	exe "vmenu <silent> ".s:C_Root.'C&++.namespace\ &\{\ \}            <Esc><Esc>:call C_InsertTemplate("cpp.namespace", "v")<CR>'

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
	exe "amenu  <silent>".s:C_Root.'C&++.e&xtern\ \"C\"\ \{\ \}       <Esc><Esc>:call C_InsertTemplate("cpp.extern")<CR>'
	exe "vmenu  <silent>".s:C_Root.'C&++.e&xtern\ \"C\"\ \{\ \}       <Esc><Esc>:call C_InsertTemplate("cpp.extern", "v")<CR>'
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

	exe "amenu  <silent>  ".s:C_Root.'&Run.rebuild\ &templates                   <C-C>:call C_RebuildTemplates()<CR>'
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
	echohl Search																					" highlight prompt
	call inputsave()																			" preserve typeahead
	let	retval=input( a:promp, a:text )										" read input
	call inputrestore()																		" restore typeahead
	echohl None																						" reset highlighting
	let retval  = substitute( retval, '^\s\+', "", "" )		" remove leading whitespaces
	let retval  = substitute( retval, '\s\+$', "", "" )		" remove trailing whitespaces
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
	endif

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
		endif

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
			endif

			" remove some spaces
			if vpos1 < b:C_LineEndCommentColumn && vpos2 > b:C_LineEndCommentColumn
				let	diff	= vpos2 - b:C_LineEndCommentColumn
				call setpos(".", [ 0, ln, b:C_LineEndCommentColumn, 0 ] )
				exe "normal	".diff."x"
			endif

		endif
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
	call C_InsertTemplate('comment.end-of-line-comment')
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
			call C_InsertTemplate('comment.end-of-line-comment')
		endif
		let linenumber=linenumber+1
	endwhile
	" ----- back to the begin of the marked block -----
	exe ":".pos0
	normal $
endfunction		" ---------- end of function  C_MultiLineEndComments  ----------
"
"------------------------------------------------------------------------------
"  C_CommentSpecial : special comments    {{{1
"------------------------------------------------------------------------------
function! C_CommentSpecial (special)
  	put = '	'.s:C_Com1.' '.a:special.' '.s:C_Com2
endfunction    " ----------  end of function C_CommentSpecial ----------
"
"------------------------------------------------------------------------------
"  C_Comment_C_SectionAll: Section Comments    {{{1
"------------------------------------------------------------------------------
"
function! C_Comment_C_SectionAll ( type )

	call C_InsertTemplate("comment.file-section-cpp-header-includes")
	call C_InsertTemplate("comment.file-section-cpp-macros")
	call C_InsertTemplate("comment.file-section-cpp-typedefs")
	call C_InsertTemplate("comment.file-section-cpp-data-types")
	if a:type=="cpp"
		call C_InsertTemplate("comment.file-section-cpp-class-defs")
	endif
	call C_InsertTemplate("comment.file-section-cpp-local-variables")
	call C_InsertTemplate("comment.file-section-cpp-prototypes")
	call C_InsertTemplate("comment.file-section-cpp-function-defs-exported")
	call C_InsertTemplate("comment.file-section-cpp-function-defs-local")
	if a:type=="cpp"
		call C_InsertTemplate("comment.file-section-cpp-class-implementations-exported")
		call C_InsertTemplate("comment.file-section-cpp-class-implementations-local")
	endif

endfunction    " ----------  end of function C_Comment_C_SectionAll ----------
"
function! C_Comment_H_SectionAll ( type )

	call C_InsertTemplate("comment.file-section-hpp-header-includes")
	call C_InsertTemplate("comment.file-section-hpp-macros")
	call C_InsertTemplate("comment.file-section-hpp-exported-typedefs")
	call C_InsertTemplate("comment.file-section-hpp-exported-data-types")
	if a:type=="cpp"
		call C_InsertTemplate("comment.file-section-hpp-exported-class-defs")
	endif
	call C_InsertTemplate("comment.file-section-hpp-exported-variables")
	call C_InsertTemplate("comment.file-section-hpp-exported-function-declarations")

endfunction    " ----------  end of function C_Comment_H_SectionAll ----------
"
"----------------------------------------------------------------------
"  C_CodeComment : Code -> Comment   {{{1
"----------------------------------------------------------------------
function! C_CodeComment( mode, style )

	if a:mode=="a"
		if a:style == 'yes' 
			silent exe ":s#^#/\* #"
			silent put = ' */'
		else
			silent exe ":s#^#//#"
		endif
	endif
	
	if a:mode=="v"
		if a:style == 'yes' 
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
"=====================================================================================
"----- Menu : Statements -----------------------------------------------------------
"=====================================================================================
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
			normal 2==
			if jmp!=0
				exe "normal ".jmp."Wh"
			else
				exe 'normal $'
			endif
		endif

		" ----- visual mode ----------------
		if a:mode=="v" 
			let	zz	= zz." {"
			:'<put! =zz
			let zz=    "}"
			:'>put =zz
			:'<-1
			:exe "normal =".(line("'>")-line(".")+3)."+"
		endif
	endif
endfunction    " ----------  end of function C_CodeFor ----------
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
		put =s:C_Prototype
		let	s:C_PrototypeCounter	-= 1
		silent exe "normal =".s:C_PrototypeCounter."-"
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
"  C_Toggle_Gvim_Xterm : change output destination       {{{1
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
	let answer  = substitute( answer, '\s\+', "x", "" )						" replace inner whitespaces
	let s:C_XtermDefaults	= substitute( s:C_XtermDefaults, regex, "-geometry ".answer , "" )
endfunction    " ----------  end of function C_XtermSize ----------
"
"------------------------------------------------------------------------------
"  C_MakeArguments : run make(1)       {{{1
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
"  C_SplintCheck : run splint(1)        {{{1
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
"  C_CodeCheck : run CodeCheck       {{{1
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
"  C_Indent : run indent(1)       {{{1
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
	let txt = txt.'                   author :  "'.s:C_Macro['|AUTHOR|']."\"\n"
	let txt = txt.'                 initials :  "'.s:C_Macro['|AUTHORREF|']."\"\n"
	let txt = txt.'                    email :  "'.s:C_Macro['|EMAIL|']."\"\n"
	let txt = txt.'                  company :  "'.s:C_Macro['|COMPANY|']."\"\n"
	let txt = txt.'                  project :  "'.s:C_Macro['|PROJECT|']."\"\n"
	let txt = txt.'         copyright holder :  "'.s:C_Macro['|COPYRIGHTHOLDER|']."\"\n"
	let txt = txt.'         C / C++ compiler :  '.s:C_CCompiler.' / '.s:C_CplusCompiler."\n"
	let txt = txt.'         C file extension :  '.s:C_CExtension.'  (everything else is C++)'."\n"
	let txt = txt.'    extension for objects :  "'.s:C_ObjExtension."\"\n"
	let txt = txt.'extension for executables :  "'.s:C_ExeExtension."\"\n"
	let txt = txt.'           compiler flags :  "'.s:C_CFlags."\"\n"
	let txt = txt.'             linker flags :  "'.s:C_LFlags."\"\n"
	let txt = txt.'                libraries :  "'.s:C_Libs."\"\n"
	let txt = txt.'   code snippet directory :  '.s:C_CodeSnippets."\n"
	if s:installation == 'system'
		let txt = txt.'global template directory :  '.s:C_GlobalTemplateDir."\n"
		if filereadable( s:C_LocalTemplateFile )
			let txt = txt.' local template directory :  '.s:C_LocalTemplateDir."\n"
		endif
	else
		let txt = txt.' local template directory :  '.s:C_GlobalTemplateDir."\n"
	endif
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
"  C_RebuildTemplates
"  rebuild commands and the menu from the (changed) template file
"------------------------------------------------------------------------------
function! C_RebuildTemplates ()
    let s:C_Template     = {}
    let s:C_FileVisited  = []
    call C_ReadTemplates(s:C_GlobalTemplateFile)
    echomsg "templates rebuilt from '".s:C_GlobalTemplateFile."'"
		"
		if s:installation == 'system' && filereadable( s:C_LocalTemplateFile )
			call C_ReadTemplates( s:C_LocalTemplateFile ) 
			echomsg " and from '".s:C_LocalTemplateFile."'"
		endif
endfunction    " ----------  end of function C_RebuildTemplates  ----------

"------------------------------------------------------------------------------
"  C_ReadTemplates
"  read the template file(s), build the macro and the template dictionary
"
"------------------------------------------------------------------------------
function! C_ReadTemplates ( templatefile )

  if !filereadable( a:templatefile )
    echohl WarningMsg
    echomsg "C/C++ template file '".a:templatefile."' does not exist or is not readable"
    echohl None
    return
  endif

	let	skipmacros	= 0
  let s:C_FileVisited  += [a:templatefile]

  "------------------------------------------------------------------------------
  "  read template file, start with an empty template dictionary
  "------------------------------------------------------------------------------

  let item  = ''
  for line in readfile( a:templatefile )
		" if not a comment :
    if line !~ '^\$'
      "
      " macros and file includes
      "

      let string  = matchlist( line, s:C_MacroLineRegex )
      if !empty(string) && skipmacros == 0
        let key = '|'.string[1].'|'
        let val = string[2]
        let val = substitute( val, '\s\+$', '', '' )
        let val = substitute( val, "[\"\']$", '', '' )
        let val = substitute( val, "^[\"\']", '', '' )
        "
        if key == '|includefile|' && count( s:C_FileVisited, val ) == 0
					let path   = fnamemodify( a:templatefile, ":p:h" )
          call C_ReadTemplates( path.'/'.val )    " recursive call
        else
          let s:C_Macro[key] = val
        endif
        continue                                            " next line
      endif
      "
      " template header
      "
      let name  = matchstr( line, s:C_TemplateLineRegex )
      "
      if name != ''
        let part  = split( name, '\s*==\s*')
        let item  = part[0]
        if has_key( s:C_Template, item ) && s:C_TemplateOverwrittenMsg == 'yes'
          echomsg "existing C/C++ template '".item."' overwritten"
        endif
        let s:C_Template[item] = ''
				let skipmacros	= 1
        "
        let s:C_Attribute[item] = 'below'
        if has_key( s:Attribute, get( part, 1, 'NONE' ) )
          let s:C_Attribute[item] = part[1]
        endif
      else
        if item != ''
          let s:C_Template[item] = s:C_Template[item].line."\n"
        endif
      endif
    endif
  endfor

	call C_SetSmallCommentStyle()
endfunction    " ----------  end of function C_ReadTemplates  ----------

"------------------------------------------------------------------------------
"  C_InsertTemplate
"  insert a template from the template dictionary
"  do macro expansion
"------------------------------------------------------------------------------
function! C_InsertTemplate ( key, ... )

	if !has_key( s:C_Template, a:key )
		echomsg "Template '".a:key."' not found. Please check your template file in '".s:C_GlobalTemplateDir."'"
		return
	endif

  "------------------------------------------------------------------------------
  "  insert the user macros
  "------------------------------------------------------------------------------
  let mode  = s:C_Attribute[a:key]

	" remove <SPLIT> and insert the complete macro
	"
	if a:0 == 0
		let val = C_ExpandUserMacros (a:key)
		if val	== ""
			return
		endif
		let val	= C_ExpandSingleMacro( val, '<SPLIT>', '' )

		if mode == 'below'
			let pos1  = line(".")+1
			put  =val
			let pos2  = line(".")
			" proper indenting 
			exe ":".pos1
			let ins	= pos2-pos1+1
			exe "normal ".ins."=="
		endif

		if mode == 'above'
			let pos1  = line(".")
			put! =val
			let pos2  = line(".")
			" proper indenting 
			exe ":".pos1
			let ins	= pos2-pos1+1
			exe "normal ".ins."=="
		endif

		if mode == 'start'
			normal gg
			let pos1  = 1
			put! =val
			let pos2  = line(".")
			" proper indenting 
			exe ":".pos1
			let ins	= pos2-pos1+1
			exe "normal ".ins."=="
		endif

		if mode == 'append'
			let pos1  = line(".")
			put =val
			let pos2  = line(".")-1
			exe ":".pos1
			:join!
		endif

		if mode == 'insert'
			let val   = substitute( val, '\n$', '', '' )
			let pos1  = line(".")
			let pos2  = pos1 + count( split(val,'\zs'), "\n" ) 
			exe "normal a".val
		endif
		"
	else
		"
		" =====  visual mode  ===============================
		"
		if  a:1 == 'v'
			let val = C_ExpandUserMacros (a:key)
			if val	== ""
				return
			endif

			let part	= split( val, '<SPLIT>' )
			if len(part) < 2
				let part	= [ "" ] + part
				echomsg 'SPLIT missing in template '.a:key
			endif

			if mode == 'below'

				:'<put! =part[0]
				:'>put  =part[1]

				let pos1  = line("'<") - len(split(part[0], '\n' ))
				let pos2  = line("'>") + len(split(part[1], '\n' ))
				""			echo part[0] part[1] pos1 pos2
				"			" proper indenting 
				exe ":".pos1
				let ins	= pos2-pos1+1
				exe "normal ".ins."=="
			endif

			"
		endif
	endif
  "------------------------------------------------------------------------------
  "  position the cursor
  "------------------------------------------------------------------------------
  exe ":".pos1
  let mtch = search( '<CURSOR>', "c", pos2 )
  if mtch != 0
    if  matchend( getline(mtch) ,'<CURSOR>') == match( getline(mtch) ,"$" )
      normal 8x
      :startinsert!
    else
      normal 8x
      :startinsert
    endif
	else
		" to the end of the block; needed for repeated inserts
		if mode == 'below'
			exe ":".pos2
		endif
  endif

endfunction    " ----------  end of function C_InsertTemplate  ----------

"------------------------------------------------------------------------------
"  C_ExpandUserMacros
"------------------------------------------------------------------------------
function! C_ExpandUserMacros ( key )

  let template 								= s:C_Template[ a:key ]
	let	s:C_ExpansionCounter		= {}										" reset the expansion counter

  "------------------------------------------------------------------------------
  "  renew the predefined macros and expand them
	"  can be replaced, with e.g. |?DATE|
  "------------------------------------------------------------------------------
	let	s:C_Macro['|BASENAME|']	= toupper(expand("%:t:r"))
  let s:C_Macro['|DATE|']  		= strftime("%x")
  let s:C_Macro['|FILENAME|'] = expand("%:t")
  let s:C_Macro['|PATH|']  		= expand("%:p:h")
  let s:C_Macro['|SUFFIX|'] 	= expand("%:e")
  let s:C_Macro['|TIME|']  		= strftime("%X %Z")
  let s:C_Macro['|YEAR|']  		= strftime("%Y")

  "------------------------------------------------------------------------------
  "  look for replacements
  "------------------------------------------------------------------------------
	while match( template, s:C_ExpansionRegex ) != -1
		let macro				= matchstr( template, s:C_ExpansionRegex )
		let replacement	= substitute( macro, '?', '', '' )
		let template		= substitute( template, macro, replacement, "g" )

		let match	= matchlist( macro, s:C_ExpansionRegex )

		if match[1] != ''
			let macroname	= '|'.match[1].'|'
			"
			" notify flag action, if any
			let flagaction	= ''
			if has_key( s:C_MacroFlag, match[2] )
				let flagaction	= ' (-> '.s:C_MacroFlag[ match[2] ].')'
			endif
			"
			" ask for a replacement
			if has_key( s:C_Macro, macroname )
				let	name	= C_Input( match[1].flagaction.' : ', C_ApplyFlag( s:C_Macro[macroname], match[2] ) )
			else
				let	name	= C_Input( match[1].flagaction.' : ', '' )
			endif
			if name == ""
				return ""
			endif
			"
			" keep the modified name
			let s:C_Macro[macroname]  			= C_ApplyFlag( name, match[2] )
		endif
	endwhile

  "------------------------------------------------------------------------------
  "  do the actual macro expansion
	"  loop over the macros found in the template
  "------------------------------------------------------------------------------
	while match( template, s:C_NonExpansionRegex ) != -1

		let macro			= matchstr( template, s:C_NonExpansionRegex )
		let match			= matchlist( macro, s:C_NonExpansionRegex )

		if match[1] != ''
			let macroname	= '|'.match[1].'|'

			if has_key( s:C_Macro, macroname ) 
				"-------------------------------------------------------------------------------
				"   check for recursion
				"-------------------------------------------------------------------------------
				if has_key( s:C_ExpansionCounter, macroname )
					let	s:C_ExpansionCounter[macroname]	+= 1
				else
					let	s:C_ExpansionCounter[macroname]	= 0
				endif
				if s:C_ExpansionCounter[macroname]	>= s:C_ExpansionLimit
					echomsg " recursion terminated for recursive macro ".macroname
					return template
				endif
				"-------------------------------------------------------------------------------
				"   replace
				"-------------------------------------------------------------------------------
				let replacement = C_ApplyFlag( s:C_Macro[macroname], match[2] )
				let template 		= substitute( template, macro, replacement, "g" )
			else
				"
				" macro not yet defined
				let s:C_Macro['|'.match[1].'|']  		= ''
			endif
		endif

	endwhile

  return template
endfunction    " ----------  end of function C_ExpandUserMacros  ----------

"------------------------------------------------------------------------------
"  C_ApplyFlag
"------------------------------------------------------------------------------
function! C_ApplyFlag ( val, flag )
	"
	" l : lowercase
	if a:flag == ':l'
		return  tolower(a:val)
	end
	"
	" u : uppercase
	if a:flag == ':u'
		return  toupper(a:val)
	end
	"
	" c : capitalize
	if a:flag == ':c'
		return  toupper(a:val[0]).a:val[1:]
	end
	"
	" L : legalized name
	if a:flag == ':L'
		return  C_LegalizeName(a:val)
	end
	"
	" flag not valid
	return a:val			
endfunction    " ----------  end of function C_ApplyFlag  ----------
"
"------------------------------------------------------------------------------
"  C_ExpandSingleMacro
"------------------------------------------------------------------------------
function! C_ExpandSingleMacro ( val, macroname, replacement )
  return substitute( a:val, escape(a:macroname, '$' ), a:replacement, "g" )
endfunction    " ----------  end of function C_ExpandSingleMacro  ----------

"------------------------------------------------------------------------------
"  C_SetSmallCommentStyle
"------------------------------------------------------------------------------
function! C_SetSmallCommentStyle ()
	if has_key( s:C_Template, 'comment.end-of-line-comment' ) 
		if match( s:C_Template['comment.end-of-line-comment'], '^\s*/\*' ) != -1
			let s:C_Com1          = '/*'     " C-style : comment start 
			let s:C_Com2          = '*/'     " C-style : comment end
		else
			let s:C_Com1          = '//'     " C++style : comment start 
			let s:C_Com2          = ''       " C++style : comment end
		endif
	endif
endfunction    " ----------  end of function C_SetSmallCommentStyle  ----------

"------------------------------------------------------------------------------
"  C_InsertMacroValue
"------------------------------------------------------------------------------
function! C_InsertMacroValue ( key )
	if col(".") > 1
		exe 'normal a'.s:C_Macro['|'.a:key.'|']
	else
		exe 'normal i'.s:C_Macro['|'.a:key.'|']
	end
endfunction    " ----------  end of function C_InsertMacroValue  ----------

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
if has("autocmd")
	"
	"  Automated header insertion (suffixes from the gcc manual)
	"
	autocmd BufNewFile  * if (&filetype=='cpp' || &filetype=='c') | 
				\     call C_InsertTemplate("comment.file-description") | endif
	"
	"  *.h has filetype 'cpp' by default; this can be changed to 'c' :
	"
	if s:C_TypeOfH=='c' 
		autocmd BufNewFile,BufEnter  *.h  :set filetype=c
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
"------------------------------------------------------------------------------
"  READ THE TEMPLATE FILES
"------------------------------------------------------------------------------
call C_ReadTemplates(s:C_GlobalTemplateFile)
if s:installation == 'system' && filereadable( s:C_LocalTemplateFile )
	call C_ReadTemplates( s:C_LocalTemplateFile ) 
endif

"
"=====================================================================================
" vim: tabstop=2 shiftwidth=2 foldmethod=marker 
