"===============================================================================
"
"          File:  mmtemplates#core.vim
" 
"   Description:  Template engine: Core.
"
"                 Maps & Menus - Template Engine
" 
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner, wolfgang-mehner@web.de
"  Organization:  
"       Version:  see variable g:Templates_Version below
"       Created:  30.08.2011
"      Revision:  28.03.2014
"       License:  Copyright (c) 2012-2013, Wolfgang Mehner
"                 This program is free software; you can redistribute it and/or
"                 modify it under the terms of the GNU General Public License as
"                 published by the Free Software Foundation, version 2 of the
"                 License.
"                 This program is distributed in the hope that it will be
"                 useful, but WITHOUT ANY WARRANTY; without even the implied
"                 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
"                 PURPOSE.
"                 See the GNU General Public License version 2 for more details.
"===============================================================================
"
"-------------------------------------------------------------------------------
" === Basic Checks ===   {{{1
"-------------------------------------------------------------------------------
"
" need at least 7.0
if v:version < 700
	echohl WarningMsg
	echo 'The plugin templates.vim needs Vim version >= 7.'
	echohl None
	finish
endif
"
" prevent duplicate loading
" need compatible
if &cp || ( exists('g:Templates_Version') && g:Templates_Version != 'searching' && ! exists('g:Templates_DevelopmentOverwrite') )
	finish
endif
"
let s:Templates_Version = '0.9.3'     " version number of this script; do not change
"
"----------------------------------------------------------------------
"  --- Find Newest Version ---   {{{2
"----------------------------------------------------------------------
"
if exists('g:Templates_DevelopmentOverwrite')
	" skip ahead
elseif exists('g:Templates_VersionUse')
	"
	" not the newest one: abort
	if s:Templates_Version != g:Templates_VersionUse
		finish
	endif
	"
	" otherwise: skip ahead
	"
elseif exists('g:Templates_VersionSearch')
	"
	" add own version number to the list
	call add ( g:Templates_VersionSearch, s:Templates_Version )
	"
	finish
	"
else
	"
	"-------------------------------------------------------------------------------
	" s:VersionComp : Compare two version numbers.   {{{3
	"
	" Parameters:
	"   op1 - first version number (string)
	"   op2 - second version number (string)
	" Returns:
	"   result - -1, 0 or 1, to the specifications of sort() (integer)
	"-------------------------------------------------------------------------------
	function! s:VersionComp ( op1, op2 )
		"
		let l1 = split ( a:op1, '[.-]' )
		let l2 = split ( a:op2, '[.-]' )
		"
		for i in range( 0, max( [ len( l1 ), len( l2 ) ] ) - 1 )
			" until now, all fields where equal
			if len ( l2 ) <= i
				return -1                               " op1 has more fields -> sorts first
			elseif len( l1 ) <= i
				return 1                                " op2 has more fields -> sorts first
			elseif str2nr ( l1[i] ) > str2nr ( l2[i] )
				return -1                               " op1 is larger here -> sorts first
			elseif str2nr ( l2[i] ) > str2nr ( l1[i] )
				return 1                                " op2 is larger here -> sorts first
			endif
		endfor
		"
		return 0                                    " same amount of fields, all equal
	endfunction    " ----------  end of function s:VersionComp  ----------
	" }}}3
	"-------------------------------------------------------------------------------
	"
	try
		"
		" collect all available version
		let g:Templates_Version = 'searching'
		let g:Templates_VersionSearch = []
		"
		runtime! autoload/mmtemplates/core.vim
		"
		" select the newest one
		call sort ( g:Templates_VersionSearch, 's:VersionComp' )
		"
		let g:Templates_VersionUse = g:Templates_VersionSearch[ 0 ]
		"
		" run all scripts again, the newest one will be used
		runtime! autoload/mmtemplates/core.vim
		"
		unlet g:Templates_VersionSearch
		unlet g:Templates_VersionUse
		"
		finish
		"
	catch /.*/
		"
		" an error occurred, skip ahead
		echohl WarningMsg
		echomsg 'Search for the newest version number failed.'
		echomsg 'Using this version ('.s:Templates_Version.').'
		echohl None
	endtry
	"
endif
" }}}2
"-------------------------------------------------------------------------------
"
let g:Templates_Version = s:Templates_Version     " version number of this script; do not change
"
"----------------------------------------------------------------------
"  === Modul Setup ===   {{{1
"----------------------------------------------------------------------
"
let s:DebugGlobalOverwrite = 0
let s:DebugLevel           = s:DebugGlobalOverwrite
"
if ! exists ( 'g:Templates_MapInUseWarn' )
	let g:Templates_MapInUseWarn = 1
endif
"
let s:StateStackStyleTop    = -2
let s:StateStackFile        = -1
"
let s:StateStackLength      = 2
"
let s:Flagactions = {
			\ ':i' : '',
			\ ':l' : ' (-> lowercase)',
			\ ':u' : ' (-> uppercase)',
			\ ':c' : ' (-> capitalize)',
			\ ':L' : ' (-> legalize name)',
			\ }
"
let s:StandardPriority = 500
"
let g:CheckedFiletypes = {}
"
"----------------------------------------------------------------------
"  s:StandardMacros : The standard macros.   {{{2
"----------------------------------------------------------------------
"
let s:StandardMacros = {
			\ 'BASENAME'       : '',
			\ 'DATE'           : '%x',
			\ 'FILENAME'       : '',
			\ 'PATH'           : '',
			\ 'SUFFIX'         : '',
			\ 'TIME'           : '%X',
			\ 'YEAR'           : '%Y',
			\ }
"
"----------------------------------------------------------------------
"  s:StandardProperties : The standard properties.   {{{2
"----------------------------------------------------------------------
"
let s:StandardProperties = {
			\ 'Templates::EditTemplates::Map'   : 're',
			\ 'Templates::RereadTemplates::Map' : 'rr',
			\ 'Templates::ChooseStyle::Map'     : 'rs',
			\
			\ 'Templates::EditTemplates::Shortcut'   : 'e',
			\ 'Templates::RereadTemplates::Shortcut' : 'r',
			\ 'Templates::ChooseStyle::Shortcut'     : 's',
			\
			\ 'Templates::Mapleader' : '\',
			\ }
"
"----------------------------------------------------------------------
"  s:TypeNames : Name of types as characters.   {{{2
"----------------------------------------------------------------------
"
let s:TypeNames = [ ' ', ' ', ' ', ' ', ' ', ' ' ]
"
let s:TypeNames[ type(0)   ] = 'i'  " integer
let s:TypeNames[ type("")  ] = 's'  " string
let s:TypeNames[ type([])  ] = 'l'  " list
let s:TypeNames[ type({})  ] = 'd'  " dict
"let s:TypeNames[ type(0.0) ] = 'n'  " number
" TODO: why does float not work in some cases?
"       not important right now.
"
"----------------------------------------------------------------------
"  === Syntax: Regular Expressions ===   {{{1
"----------------------------------------------------------------------
"
let s:RegexSettings = {
			\ 'MacroName'      : '[a-zA-Z_][a-zA-Z0-9_]*',
			\ 'MacroList'      : '\%([a-zA-Z_]\|[a-zA-Z_][a-zA-Z0-9_ \t,]*[a-zA-Z0-9_]\)',
			\ 'TemplateName'   : '[a-zA-Z_][a-zA-Z0-9_+\-\., ]*[a-zA-Z0-9_+\-\.,]',
			\ 'TextOpt'        : '[a-zA-Z_][a-zA-Z0-9_+\-: \t,]*[a-zA-Z0-9_+\-]',
			\ 'Mapping'        : '[a-zA-Z0-9+\-]\+',
			\
			\ 'CommentStart'   : '\$',
			\ 'BlockDelimiter' : '==',
			\
			\ 'CommentHint'    : '$',
			\ 'CommandHint'    : '[A-Z]',
			\ 'DelimHint'      : '=',
			\ 'MacroHint'      : '|',
			\
			\ 'MacroStart'     : '|',
			\ 'MacroEnd'       : '|',
			\ 'EditTagStart'   : '<',
			\ 'EditTagEnd'     : '>',
			\ 'JumpTag1Start'  : '{',
			\ 'JumpTag1End'    : '}',
			\ 'JumpTag2Start'  : '<',
			\ 'JumpTag2End'    : '>',
			\ }
"
"----------------------------------------------------------------------
"  s:UpdateFileReadRegex : Update the regular expressions.   {{{2
"----------------------------------------------------------------------
"
function! s:UpdateFileReadRegex ( regex, settings )
	"
	let quote = '\(["'']\?\)'
	"
	" Basics
	let a:regex.MacroName     = a:settings.MacroName
	let a:regex.MacroNameC    = '\('.a:settings.MacroName.'\)'
	let a:regex.TemplateNameC = '\('.a:settings.TemplateName.'\)'
	let a:regex.Mapping       = a:settings.Mapping
	let a:regex.AbsolutePath  = '^[\~/]'                " TODO: Is that right and/or complete?
	"
	" Syntax Categories
	let a:regex.EmptyLine     = '^\s*$'
	let a:regex.CommentLine   = '^'.a:settings.CommentStart
	let a:regex.FunctionCall  = '^\s*'.a:regex.MacroNameC.'\s*(\(.*\))\s*$'
	let a:regex.MacroAssign   = '^\s*'.a:settings.MacroStart.a:regex.MacroNameC.a:settings.MacroEnd
				\                    .'\s*=\s*'.quote.'\(.\{-}\)'.'\2'.'\s*$'   " deprecated
	"
	" Blocks
	let delim                 = a:settings.BlockDelimiter
	let a:regex.Styles1Start  = '^'.delim.'\s*IF\s\+|STYLE|\s\+IS\s\+'.a:regex.MacroNameC.'\s*'.delim
	let a:regex.Styles1End    = '^'.delim.'\s*ENDIF\s*'.delim

	let a:regex.Styles2Start  = '^'.delim.'\s*USE\s\+STYLES\s*:'
				\                     .'\s*\('.a:settings.MacroList.'\)'.'\s*'.delim
	let a:regex.Styles2End    = '^'.delim.'\s*ENDSTYLES\s*'.delim
	"
	" Texts
	let a:regex.TemplateStart = '^'.delim.'\s*\%(TEMPLATE:\)\?\s*'.a:regex.TemplateNameC.'\s*'.delim
				\                     .'\s*\%(\('.a:settings.TextOpt.'\)\s*'.delim.'\)\?'
	let a:regex.TemplateEnd   = '^'.delim.'\s*ENDTEMPLATE\s*'.delim
	"
	let a:regex.HelpStart     = '^'.delim.'\s*HELP:\s*'.a:regex.TemplateNameC.'\s*'.delim
				\                     .'\s*\%(\('.a:settings.TextOpt.'\)\s*'.delim.'\)\?'
	"let a:regex.HelpEnd       = '^'.delim.'\s*ENDHELP\s*'.delim
	"
	let a:regex.MenuSep       = '^'.delim.'\s*SEP:\s*'.a:regex.TemplateNameC.'\s*'.delim
	"
	let a:regex.ListStart     = '^'.delim.'\s*LIST:\s*'.a:regex.MacroNameC.'\s*'.delim
				\                     .'\s*\%(\('.a:settings.TextOpt.'\)\s*'.delim.'\)\?'
	let a:regex.ListEnd       = '^'.delim.'\s*ENDLIST\s*'.delim
	"
	" Special Hints
	let a:regex.CommentHint   = a:settings.CommentHint
	let a:regex.CommandHint   = a:settings.CommandHint
	let a:regex.DelimHint     = a:settings.DelimHint
	let a:regex.MacroHint     = a:settings.MacroHint
	"
endfunction    " ----------  end of function s:UpdateFileReadRegex  ----------
"
"----------------------------------------------------------------------
"  s:UpdateTemplateRegex : Update the regular expressions.   {{{2
"----------------------------------------------------------------------
"
function! s:UpdateTemplateRegex ( regex, settings )
	"
	let quote = '["'']'
	"
	" Function Arguments
	let a:regex.RemoveQuote  = '^\s*'.quote.'\zs.*\ze'.quote.'\s*$'
	"
	" Basics
	let a:regex.MacroStart   = a:settings.MacroStart
	let a:regex.MacroEnd     = a:settings.MacroEnd
	let a:regex.MacroName    = a:settings.MacroName
	let a:regex.MacroNameC   = '\('.a:settings.MacroName.'\)'
	let a:regex.MacroMatch   = '^'.a:settings.MacroStart.a:settings.MacroName.a:settings.MacroEnd.'$'
	"
	" Syntax Categories
	let a:regex.FunctionLine    = '^'.a:settings.MacroStart.'\('.a:regex.MacroNameC.'(\(.*\))\)'.a:settings.MacroEnd.'\s*\n'
	let a:regex.FunctionChecked = '^'.a:regex.MacroNameC.'(\(.*\))$'
	let a:regex.FunctionList    = '^LIST(\(.\{-}\))$'
	let a:regex.FunctionComment = a:settings.MacroStart.'\(C\|Comment\)'.'(\(.\{-}\))'.a:settings.MacroEnd
	let a:regex.FunctionInsert  = a:settings.MacroStart.'\(Insert\|InsertLine\)'.'(\(.\{-}\))'.a:settings.MacroEnd
	let a:regex.MacroRequest    = a:settings.MacroStart.'?'.a:regex.MacroNameC.'\%(:\(\a\)\)\?'.a:settings.MacroEnd
	let a:regex.MacroInsert     = a:settings.MacroStart.''.a:regex.MacroNameC.'\%(:\(\a\)\)\?'.a:settings.MacroEnd
	let a:regex.MacroNoCapture  = a:settings.MacroStart.a:settings.MacroName.'\%(:\a\)\?'.a:settings.MacroEnd
	let a:regex.ListItem        = a:settings.MacroStart.''.a:regex.MacroNameC.':ENTRY_*'.a:settings.MacroEnd
	"
	let a:regex.TextBlockFunctions = '^\%(C\|Comment\|Insert\|InsertLine\)$'
	"
	" Jump Tags
	let a:regex.JumpTagBoth     = '<-\w*->\|{-\w*-}\|<+\w*+>\|{+\w*+}'
	let a:regex.JumpTagType2    = '<-\w*->\|{-\w*-}'
	"
endfunction    " ----------  end of function s:UpdateTemplateRegex  ----------
" }}}2
"
"----------------------------------------------------------------------
"  === Script: Auxiliary Functions ===   {{{1
"----------------------------------------------------------------------
"
"----------------------------------------------------------------------
"  s:ParameterTypes : Get the types of the arguments.   {{{2
"
"  Returns a string with one character per argument, denoting the type.
"  Uses the codebook 's:TypeNames'.
"
"  Examples:
"  - s:ParameterTypes ( 1, "string", [] ) -> "isl"
"  - s:ParameterTypes ( 1, 'string', {} ) -> "isd"
"  - s:ParameterTypes ( 1, 1.0 )          -> "in"
"----------------------------------------------------------------------
"
function! s:ParameterTypes ( ... )
	return join( map( copy( a:000 ), 's:TypeNames[ type ( v:val ) ]' ), '' )
endfunction    " ----------  end of function s:ParameterTypes  ----------
"
"----------------------------------------------------------------------
"  s:FunctionCheck : Check the syntax, name and parameter types.   {{{2
"
"  Throw a 'Template:Check:*' exception whenever:
"  - The syntax of the call "name( params )" is wrong.
"  - The function name 'name' is not a key in 'namespace'.
"  - The parameter string (as produced by s:ParameterTypes) does not match
"    the regular expression found in "namespace[name]".
"----------------------------------------------------------------------
"
function! s:FunctionCheck ( name, param, namespace )
	"
	" check the syntax and get the parameter string
	try
		exe 'let param_s = s:ParameterTypes( '.a:param.' )'
	catch /^Vim(let):E\d\+:/
		throw 'Template:Check:function call "'.a:name.'('.a:param.')": '.matchstr ( v:exception, '^Vim(let):E\d\+:\zs.*' )
	endtry
	"
	" check the function and the parameters
	if ! has_key ( a:namespace, a:name )
		throw 'Template:Check:unknown function: "'.a:name.'"'
	elseif param_s !~ '^'.a:namespace[ a:name ].'$'
		throw 'Template:Check:wrong parameter types: "'.a:name.'"'
	endif
	"
endfunction    " ----------  end of function s:FunctionCheck  ----------
"
"----------------------------------------------------------------------
"  s:LiteralReplacement : Substitute without using regular expressions.   {{{2
"----------------------------------------------------------------------
"
function! s:LiteralReplacement ( text, remove, insert, flag )
	return substitute( a:text,
				\ '\V'.escape( a:remove, '\' ),
				\      escape( a:insert, '\&~' ), a:flag )
"				\ '\='.string( a:insert      ), a:flag )
endfunction    " ----------  end of function s:LiteralReplacement  ----------
"
"----------------------------------------------------------------------
"  s:ConcatNormalizedFilename : Concatenate and normalize a filename.   {{{2
"----------------------------------------------------------------------
"
function! s:ConcatNormalizedFilename ( ... )
	if a:0 == 1
		let filename = ( a:1 )
	elseif a:0 == 2
		let filename = ( a:1 ).'/'.( a:2 )
	endif
	return fnamemodify( filename, ':p' )
endfunction    " ----------  end of function s:ConcatNormalizedFilename  ----------
"
"----------------------------------------------------------------------
"  s:GetNormalizedPath : Split and normalize a path.   {{{2
"----------------------------------------------------------------------
"
function! s:GetNormalizedPath ( filename )
	return fnamemodify( a:filename, ':p:h' )
endfunction    " ----------  end of function s:GetNormalizedPath  ----------
"
""----------------------------------------------------------------------
"  s:UserInput : Input after a highlighted prompt.   {{{2
"  
"  3. argument : optional completion
"  4. argument : optional list, if the 3. argument is 'customlist'
"
"  Throws an exception 'Template:UserInputAborted' if the obtained input is empty,
"  so use it like this:
"    try
"      let style = s:UserInput( 'prompt', '', ... )
"    catch /Template:UserInputAborted/
"      return
"    endtry
"----------------------------------------------------------------------
"
function! s:UserInput ( prompt, text, ... )
	"
	echohl Search																					" highlight prompt
	call inputsave()																			" preserve typeahead
	if a:0 == 0 || a:1 == ''
		let retval = input( a:prompt, a:text )
	elseif a:1 == 'customlist'
		let s:UserInputList = a:2
		let retval = input( a:prompt, a:text, 'customlist,mmtemplates#core#UserInputEx' )
		let s:UserInputList = []
	else
		let retval = input( a:prompt, a:text, a:1 )
	endif
	call inputrestore()																		" restore typeahead
	echohl None																						" reset highlighting
	"
	if empty( retval )
		throw 'Template:UserInputAborted'
	endif
	"
	let retval  = substitute( retval, '^\s\+', "", "" )		" remove leading whitespaces
	let retval  = substitute( retval, '\s\+$', "", "" )		" remove trailing whitespaces
	"
	return retval
	"
endfunction    " ----------  end of function s:UserInput ----------
"
"----------------------------------------------------------------------
"  mmtemplates#core#UserInputEx : ex-command for s:UserInput.   {{{3
"----------------------------------------------------------------------
"
function! mmtemplates#core#UserInputEx ( ArgLead, CmdLine, CursorPos )
	if empty( a:ArgLead )
		return copy( s:UserInputList )
	endif
	return filter( copy( s:UserInputList ), 'v:val =~ ''\V\<'.escape(a:ArgLead,'\').'\w\*''' )
endfunction    " ----------  end of function mmtemplates#core#UserInputEx  ----------
" }}}3
"
let s:UserInputList = []
"
"----------------------------------------------------------------------
"  s:ErrorMsg : Print an error message.   {{{2
"----------------------------------------------------------------------
"
function! s:ErrorMsg ( ... )
	echohl WarningMsg
	for line in a:000
		echomsg line
	endfor
	echohl None
endfunction    " ----------  end of function s:ErrorMsg  ----------
"
"----------------------------------------------------------------------
"  s:DebugMsg : Print debug information.   {{{2
"----------------------------------------------------------------------
"
function! s:DebugMsg ( msg, ... )
	if s:DebugLevel
		if a:0 == 0 || ( a:1 <= s:DebugLevel )
			echo a:msg
		endif
	endif
endfunction    " ----------  end of function s:DebugMsg  ----------
"
"----------------------------------------------------------------------
" s:OpenFold : Open fold and go to the first or last line of this fold.   {{{2
"----------------------------------------------------------------------
"
function! s:OpenFold ( mode )
	if foldclosed(".") < 0
		return
	endif
	" we are on a closed fold:
	" get end position, open fold,
	" jump to the last line of the previously closed fold
	let foldstart = foldclosed(".")
	let foldend		= foldclosedend(".")
	normal! zv
	if a:mode == 'below'
		exe ":".foldend
	elseif a:mode == 'start'
		exe ":".foldstart
	endif
endfunction    " ----------  end of function s:OpenFold  ----------
"
"----------------------------------------------------------------------
"  mmtemplates#core#NewLibrary : Create a new template library.   {{{1
"----------------------------------------------------------------------
"
function! mmtemplates#core#NewLibrary ( ... )
	"
	" ==================================================
	"  options
	" ==================================================
	"
	let i = 1
	while i <= a:0
		"
		if a:[i] == 'debug' && i+1 <= a:0 && ! s:DebugGlobalOverwrite
			let s:DebugLevel = a:[i+1]
			let i += 2
		else
			if type ( a:[i] ) == type ( '' ) | call s:ErrorMsg ( 'Unknown option: "'.a:[i].'"' )
			else                             | call s:ErrorMsg ( 'Unknown option at position '.i.'.' ) | endif
			let i += 1
		endif
		"
	endwhile
	"
	" ==================================================
	"  data
	" ==================================================
	"
	" library
	let library   = {
				\ 'macros'         : {},
				\ 'properties'     : {},
				\ 'resources'      : {},
				\ 'templates'      : {},
				\
				\ 'menu_order'     : [],
				\
				\ 'styles'         : [ 'default' ],
				\ 'current_style'  : 'default',
				\
				\ 'menu_shortcuts' : {},
				\ 'menu_existing'  : { 'base' : 0 },
				\
				\ 'regex_settings' : ( copy ( s:RegexSettings ) ),
				\ 'regex_file'     : {},
				\ 'regex_template' : {},
				\
				\ 'library_files'  : [],
				\ }
	" entry used by maps: 'map_commands'
	"
	call extend ( library.macros,     s:StandardMacros,     'keep' )
	call extend ( library.properties, s:StandardProperties, 'keep' )
	"
	call s:UpdateFileReadRegex ( library.regex_file,     library.regex_settings )
	call s:UpdateTemplateRegex ( library.regex_template, library.regex_settings )
	"
	" ==================================================
	"  wrap up
	" ==================================================
	"
	let s:DebugLevel = s:DebugGlobalOverwrite   " reset debug
	"
	return library      " return the new library
	"
endfunction    " ----------  end of function mmtemplates#core#NewLibrary  ----------
"
"----------------------------------------------------------------------
"  === Read Templates: Auxiliary Functions ===   {{{1
"----------------------------------------------------------------------
"
"----------------------------------------------------------------------
"  s:TemplateTypeNames : Readable type names for templates.   {{{2
"----------------------------------------------------------------------
"
let s:TemplateTypeNames = {
			\ 'help' : 'help',
			\ 'sep'  : 'separator',
			\ 't'    : 'template',
			\ }
"
"----------------------------------------------------------------------
"  s:AddText : Add a text.   {{{2
"----------------------------------------------------------------------
"
function! s:AddText ( type, name, settings, lines )
	"
	if a:type == 'help'
		call s:AddTemplate ( 'help', a:name, a:settings, a:lines )
	elseif a:type == 'list'
		call s:AddList ( 'list', a:name, a:settings, a:lines )
	elseif a:type == 'template'
		call s:AddTemplate ( 't', a:name, a:settings, a:lines )
	endif
	"
endfunction    " ----------  end of function s:AddText  ----------
"
"----------------------------------------------------------------------
"  s:AddList : Add a list.   {{{2
"----------------------------------------------------------------------
"
function! s:AddList ( type, name, settings, lines )
	"
	" ==================================================
	"  checks
	" ==================================================
	"
	" Error: empty name
	if empty ( a:name )
		call s:ErrorMsg ( 'List name can not be empty.' )
		return
	endif
	"
	" Warning: empty list
	if empty ( a:lines )
		call s:ErrorMsg ( 'Warning: Empty list: "'.a:name.'"' )
	endif
	"
	" Warning: already existing
	if s:t_runtime.overwrite_warning && has_key ( s:library.resources, 'list!'.a:name )
		call s:ErrorMsg ( 'Warning: Overwriting list "'.a:name.'"' )
	endif
	"
	" ==================================================
	"  settings
	" ==================================================
	"
	let type  = 'list'
	let bare  = 0
	"
	for s in a:settings
		"
		if s == 'list'
			let type = 'list'
		elseif s == 'hash' || s == 'dict' || s == 'dictionary'
			let type = 'dict'
		elseif s == 'bare'
			let bare = 1
		else
			call s:ErrorMsg ( 'Warning: Unknown setting in list "'.a:name.'": "'.s.'"' )
		endif
		"
	endfor
	"
	if type == 'list'
		if bare
			let lines = escape( a:lines, '"' )
			let lines = substitute( lines, '^\s*',     '"',    '' )
			let lines = substitute( lines, '\s*\n$',   '"',    '' )
			let lines = substitute( lines, '\s*\n\s*', '", "', 'g' )
			exe 'let list = [ '.lines.' ]'
		else
			exe 'let list = [ '.substitute( a:lines, '\n', ' ', 'g' ).' ]'
		end
		call sort ( list )
	elseif type == 'dict'
		if bare
			s:ErrorMsg ( 'bare hash: to be implemented' )
		else
			exe 'let list = { '.substitute( a:lines, '\n', ' ', 'g' ).' }'
		end
	endif
	"
	let s:library.resources[ 'list!'.a:name ] = list
	"
endfunction    " ----------  end of function s:AddList  ----------
"
"----------------------------------------------------------------------
"  s:AddTemplate : Add a template.   {{{2
"----------------------------------------------------------------------
"
function! s:AddTemplate ( type, name, settings, lines )
	"
	let name = a:name
	"
	" ==================================================
	"  checks
	" ==================================================
	"
	" Error: empty name
	if empty ( name )
		call s:ErrorMsg ( 'Template name can not be empty.' )
		return
	endif
	"
	" Warning: empty template
	if empty ( a:lines )
		call s:ErrorMsg ( 'Warning: Empty template: "'.name.'"' )
	endif
	"
	" ==================================================
	"  new template
	" ==================================================
	"
	if has_key ( s:library.templates, name.'!!type' )
		let my_type    = a:type
		let other_type = split ( s:library.templates[ name.'!!type' ], ',' )[0]
		"
		if my_type != other_type
			if my_type == 't'
				call s:ErrorMsg ( 'Template "'.name.'" can not overwrite an object of the same name of type "'.s:TemplateTypeNames[other_type].'".' )
			elseif my_type == 'help'
				call s:ErrorMsg ( 'Help template "'.name.'" can not overwrite an object of the same name of type "'.s:TemplateTypeNames[other_type].'".' )
			endif
			return
		endif
	else
		"
		" --------------------------------------------------
		"  new template
		" --------------------------------------------------
		let type        = a:type
		let placement   = 'below'
		let indentation = '1'
		"
		let visual    = -1 != stridx ( a:lines, '<SPLIT>' )
		let mp        = ''
		let entry     = 1
		let sc        = ''
		"
		" --------------------------------------------------
		"  settings
		" --------------------------------------------------
		for s in a:settings
			"
			if s == 'start' || s == 'above' || s == 'below' || s == 'append' || s == 'insert'
				let placement = s

				" indentation
			elseif s == 'indent'
				let indentation = '1'
			elseif s == 'noindent'
				let indentation = '0'

				" special insertion in visual mode:
			elseif s == 'visual'
				let visual = 1
			elseif s == 'novisual'
				let visual = 0

				" map:
			elseif s =~ '^map\s*:'
				let mp = matchstr ( s, '^map\s*:\s*\zs'.s:library.regex_file.Mapping )

				" entry and shortcut:
			elseif s == 'nomenu'
				let entry = 0
			elseif s == 'expandmenu'
				let entry = 2
			elseif s =~ '^sc\s*:' || s =~ '^shortcut\s*:'
				let sc = matchstr ( s, '^\w\+\s*:\s*\zs'.s:library.regex_file.Mapping )

			else
				call s:ErrorMsg ( 'Warning: Unknown setting in template "'.name.'": "'.s.'"' )
			endif
			"
		endfor
		"
		" TODO: review this
		if a:type == 'help'
			let placement = 'help'
		endif
		"
		" --------------------------------------------------
		"  new template
		" --------------------------------------------------
		let s:library.templates[ name.'!!type' ] = type.','.placement.','.indentation
		let s:library.templates[ name.'!!menu' ] = visual.",".string(mp).",".entry.",'',".string(sc)
		"
		call add ( s:library.menu_order, name )
		"
	endif
	"
	" ==================================================
	"  text
	" ==================================================
	"
	" the styles
	if a:type == 'help'
		" Warning: overwriting a style
		if s:t_runtime.overwrite_warning && has_key ( s:library.templates, name.'!default' )
			call s:ErrorMsg ( 'Warning: Overwriting a help template: "'.name.'"' )
		endif
		let s:library.templates[ name.'!default' ] = a:lines
		return
	elseif empty ( s:t_runtime.use_styles )
		let styles = [ 'default' ]
	else
		let styles = s:t_runtime.use_styles
	endif
	"
	" save the lines
	for s in styles
		"
		" Warning: overwriting a style
		if s:t_runtime.overwrite_warning && has_key ( s:library.templates, name.'!'.s )
			call s:ErrorMsg ( 'Warning: Overwriting style in template "'.name.'": "'.s.'"' )
		endif
		"
		let s:library.templates[ name.'!'.s ] = a:lines
		"
	endfor
	"
endfunction    " ----------  end of function s:AddTemplate  ----------
"
"----------------------------------------------------------------------
"  s:AddSeparator : Add a menu separator.   {{{2
"----------------------------------------------------------------------
"
function! s:AddSeparator ( type, name, settings )
	"
	let name = a:name
	"
	" ==================================================
	"  checks
	" ==================================================
	"
	" Error: empty name
	if empty ( name )
		call s:ErrorMsg ( 'Separator name can not be empty.' )
		return
	endif
	"
	" ==================================================
	"  new separator
	" ==================================================
	"
	if has_key ( s:library.templates, name.'!!type' )
		"
		let my_type    = a:type
		let other_type = split ( s:library.templates[ name.'!!type' ], ',' )[0]
		"
		if my_type != other_type
			call s:ErrorMsg ( 'Separator "'.name.'" can not overwrite an object of the same name of type "'.s:TemplateTypeNames[other_type].'".' )
			return
		endif
	else
		"
		let s:library.templates[ name.'!!type' ] = 'sep,,0'
		let s:library.templates[ name.'!!menu' ] = "0,'',11,'',''"
		"
		call add ( s:library.menu_order, name )
		"
	endif
	"
endfunction    " ----------  end of function s:AddSeparator  ----------
"
"----------------------------------------------------------------------
"  s:AddStyles : Add styles to the list.   {{{2
"----------------------------------------------------------------------
"
function! s:AddStyles ( styles )
	"
	" TODO: check for valid name
	" add the styles to the list
	for s in a:styles
		if -1 == index ( s:library.styles, s )
			call add ( s:library.styles, s )
		endif
	endfor
	"
endfunction    " ----------  end of function s:AddStyles  ----------
"
"----------------------------------------------------------------------
"  s:UseStyles : Set the styles.   {{{2
"----------------------------------------------------------------------
"
function! s:UseStyles ( styles )
	"
	" 'use_styles' empty? -> we may have new styles
	" otherwise           -> must be a subset, so no new styles
	if empty ( s:t_runtime.use_styles )
		" add the styles to the list
		call s:AddStyles ( a:styles )
	else
		" are the styles a sub-set of the currently used styles?
		for s in a:styles
			if -1 == index ( s:t_runtime.use_styles, s )
				call s:ErrorMsg ( 'Style "'.s.'" currently not in use.' )
				return
			endif
		endfor
	endif
	"
	" push the new style and use it as the current style
	call add ( s:t_runtime.styles_stack, a:styles )
	let  s:t_runtime.use_styles = a:styles
	"
endfunction    " ----------  end of function s:UseStyles  ----------
"
"----------------------------------------------------------------------
"  s:RevertStyles : Revert the styles.   {{{2
"----------------------------------------------------------------------
"
function! s:RevertStyles ( times )
	"
	" get the current top, and check whether any more styles can be removed
	let state_lim = s:t_runtime.state_stack[ s:StateStackStyleTop ]
	let state_top = len( s:t_runtime.styles_stack )
	"
	if state_lim > ( state_top - a:times )
		call s:ErrorMsg ( 'Can not close any more style sections.' )
		return
	endif
	"
	" remove the top
	call remove ( s:t_runtime.styles_stack, -1 * a:times, -1 )
	"
	" reset the current style
	if state_top > a:times
		let s:t_runtime.use_styles = s:t_runtime.styles_stack[ -1 ]
	else
		let s:t_runtime.use_styles = []
	endif
	"
endfunction    " ----------  end of function s:RevertStyles  ----------
"
"----------------------------------------------------------------------
"  === Read Templates: Template File Namespace ===   {{{1
"----------------------------------------------------------------------
"
"----------------------------------------------------------------------
"  s:FileReadNameSpace : The set of functions a template file can call.   {{{2
"----------------------------------------------------------------------
"
let s:FileReadNameSpace = {
			\ 'IncludeFile'  : 'ss\?',
			\ 'SetFormat'    : 'ss',
			\ 'SetMacro'     : 'ss',
			\ 'SetPath'      : 'ss',
			\ 'SetProperty'  : 'ss',
			\ 'SetStyle'     : 's',
			\
			\ 'MenuShortcut' : 'ss',
			\ }
" 			\ 'SetMap'       : 'ss',
" 			\ 'SetShortcut'  : 'ss',
"
"----------------------------------------------------------------------
"  s:SetFormat : Set the format of |DATE|, ... (template function).   {{{2
"----------------------------------------------------------------------
"
function! s:SetFormat ( name, replacement )
	"
	" check for valid name
	if a:name !~ 'TIME\|DATE\|YEAR'
		call s:ErrorMsg ( 'Can not set the format of: '.a:name )
		return
	endif
	"
	let s:library.macros[ a:name ] = a:replacement
	"
endfunction    " ----------  end of function s:SetFormat  ----------
"
"----------------------------------------------------------------------
"  s:SetMacro : Set a replacement (template function).   {{{2
"----------------------------------------------------------------------
"
function! s:SetMacro ( name, replacement )
	"
	" check for valid name
	if a:name !~ s:library.regex_file.MacroName
		call s:ErrorMsg ( 'Macro name must be a valid identifier: '.a:name )
		return
	elseif has_key ( s:StandardMacros, a:name )
		call s:ErrorMsg ( 'The special macro "'.a:name.'" can not be replaced via SetMacro.' )
		return
	endif
	"
	let s:library.macros[ a:name ] = a:replacement
	"
endfunction    " ----------  end of function s:SetMacro  ----------
"
"----------------------------------------------------------------------
"  s:SetStyle : Set the current style (template function).   {{{2
"----------------------------------------------------------------------
"
function! s:SetStyle ( name )
	"
	" check for valid name
	if a:name !~ s:library.regex_file.MacroName
		call s:ErrorMsg ( 'Style name must be a valid identifier: '.a:name )
		return
	endif
	"
	let s:library.current_style = a:name
	"
endfunction    " ----------  end of function s:SetStyle  ----------
"
"----------------------------------------------------------------------
"  s:SetPath : Set a path-resource (template function).   {{{2
"----------------------------------------------------------------------
"
function! s:SetPath ( name, value )
	"
	" check for valid name
	if a:name !~ s:library.regex_file.MacroName
		call s:ErrorMsg ( 'Path name must be a valid identifier: '.a:name )
		return
	endif
	"
	let s:library.resources[ 'path!'.a:name ] = a:value
	"
endfunction    " ----------  end of function s:SetPath  ----------
"
"----------------------------------------------------------------------
"  s:MenuShortcut : Set a shortcut for a sub-menu (template function).   {{{2
"----------------------------------------------------------------------
"
function! s:MenuShortcut ( name, shortcut )
	"
	" check for valid shortcut
	if len ( a:shortcut ) > 1
		call s:ErrorMsg ( 'The shortcut for "'.a:name.'" must be a single character.' )
		return
	endif
	"
	let name = substitute( a:name, '\.$', '', '' )
	"
	let s:library.menu_shortcuts[ name ] = a:shortcut
	"
endfunction    " ----------  end of function s:MenuShortcut  ----------
"
"----------------------------------------------------------------------
"  s:SetMap : TODO (template function).   {{{2
"----------------------------------------------------------------------
"
function! s:SetMap ( name, map )
	"
	echo 'SetMap: TO BE IMPLEMENTED'
	"
endfunction    " ----------  end of function s:SetMap  ----------
"
"----------------------------------------------------------------------
"  s:SetProperty : Set an existing property.   {{{2
"----------------------------------------------------------------------
"
function! s:SetProperty ( name, value )
	"
	let [ _, err ] = mmtemplates#core#Resource ( s:library, 'set', 'property', a:name , a:value )
	"
	if err != ''
		return s:ErrorMsg ( 'Can not set the property "'.a:name.'".' )
	endif
	"
endfunction    " ----------  end of function s:SetProperty  ----------
"
"----------------------------------------------------------------------
"  s:SetShortcut : TODO (template function).   {{{2
"----------------------------------------------------------------------
"
function! s:SetShortcut ( name, shortcut )
	"
	" check for valid shortcut
	if len ( a:shortcut ) > 1
		call s:ErrorMsg ( 'The shortcut for "'.a:name.'" must be a single character.' )
		return
	endif
	"
	echo 'SetShortcut: TO BE IMPLEMENTED'
	"
endfunction    " ----------  end of function s:SetShortcut  ----------
"
"----------------------------------------------------------------------
"  s:IncludeFile : Read a template file (template function).   {{{2
"----------------------------------------------------------------------
"
function! s:IncludeFile ( templatefile, ... )
	"
	let regex = s:library.regex_file
	"
	let read_abs = 0
	if a:0 >= 1 && a:1 == 'abs'
		let read_abs = 1
	endif
	"
	" ==================================================
	"  checks
	" ==================================================
	"
	" Expand ~, $HOME, ... and check for absolute path
	let templatefile = expand( a:templatefile )
	"
" 	if templatefile =~ regex.AbsolutePath
" 		let templatefile = s:ConcatNormalizedFilename ( templatefile )
" 	else
"		let templatefile = s:ConcatNormalizedFilename ( s:t_runtime.state_stack[ s:StateStackFile ], templatefile )
" 	endif
	if read_abs
		let templatefile = s:ConcatNormalizedFilename ( templatefile )
	else
		let templatefile = s:ConcatNormalizedFilename ( s:t_runtime.state_stack[ s:StateStackFile ], templatefile )
	endif
	"
	" file does not exists or was already visited?
	if !filereadable( templatefile )
		throw 'Template:Check:file "'.templatefile.'" does not exist or is not readable'
	elseif has_key ( s:t_runtime.files_visited, templatefile )
		throw 'Template:Check:file "'.templatefile.'" already read'
	endif
	"
	" ==================================================
	"  setup
	" ==================================================
	"
	" add to the state stack
	call add ( s:t_runtime.state_stack, len( s:t_runtime.styles_stack ) )      " length of styles_stack
	call add ( s:t_runtime.state_stack, s:GetNormalizedPath ( templatefile ) ) " current path
	"
	" mark file as read
	let s:t_runtime.files_visited[templatefile] = 1
	"
	" debug:
	call s:DebugMsg ( 'Reading '.templatefile.' ...', 2 )
	"
	let state       = 'command'
	let t_start     = 0
	let last_styles = ''
	"
	" ==================================================
	"  go trough the file
	" ==================================================
	"
	let filelines = readfile( templatefile )
	"
	for line in filelines
		"
		let firstchar = line[0]
		"
		" which state
		if state == 'command'
			" ==================================================
			"  state: command
			" ==================================================
			"
			" empty line? 
			if empty ( line )
				continue
			endif
			"
			" comment?
			if firstchar == regex.CommentHint
				if line =~ regex.CommentLine
					continue
				endif
			endif
			"
			" macro line? --- |MACRO| = something
			if firstchar == regex.MacroHint
				"
				let mlist = matchlist ( line, regex.MacroAssign )
				if ! empty ( mlist )
					" STYLE, includefile or general macro
					if mlist[1] == 'STYLE'
						call s:SetStyle ( mlist[3] )
					elseif mlist[1] == 'includefile'
						try
							call s:IncludeFile ( mlist[3], 'old' )
						catch /Template:Check:.*/
							let msg = v:exception[ len( 'Template:Check:') : -1 ]
							call s:ErrorMsg ( 'While loading "'.templatefile.'":', msg )
						endtry
					else
						call s:SetMacro ( mlist[1], mlist[3] )
					endif
					continue
				endif
				"
			endif
			"
			" function call? --- Function( param_list )
			if firstchar =~ regex.CommandHint
				"
				let mlist = matchlist ( line, regex.FunctionCall )
				if ! empty ( mlist )
					let [ name, param ] = mlist[ 1 : 2 ]
					"
					try
						" check the call
						call s:FunctionCheck ( name, param, s:FileReadNameSpace )
						" try to call
						exe 'call s:'.name.' ( '.param.' ) '
					catch /Template:Check:.*/
						let msg = v:exception[ len( 'Template:Check:') : -1 ]
						call s:ErrorMsg ( 'While loading "'.templatefile.'":', msg )
					catch //
						call s:ErrorMsg ( 'While calling "'.name.'" in "'.templatefile.'":', v:exception )
					endtry
					"
					continue
				endif
				"
			endif
			"
			" section or text?
			if firstchar == regex.DelimHint
				"
				" switch styles?
				let mlist = matchlist ( line, regex.Styles1Start )
				if ! empty ( mlist )
					call s:UseStyles ( [ mlist[1] ] )
					let last_styles = mlist[0]
					continue
				endif
				"
				" switch styles?
				if line =~ regex.Styles1End
					call s:RevertStyles ( 1 )
					continue
				endif
				"
				" switch styles?
				let mlist = matchlist ( line, regex.Styles2Start )
				if ! empty ( mlist )
					call s:UseStyles ( split( mlist[1], '\s*,\s*' ) )
					let last_styles = mlist[0]
					continue
				endif
				"
				" switch styles?
				if line =~ regex.Styles2End
					call s:RevertStyles ( 1 )
					continue
				endif
				"
				" separator?
				let mlist = matchlist ( line, regex.MenuSep )
				if ! empty ( mlist )
					call s:AddSeparator ( 'sep', mlist[1], '' )
					continue
				endif
				"
				" start of text?
				let mlist_template = matchlist ( line, regex.TemplateStart )
				let mlist_help     = matchlist ( line, regex.HelpStart )
				let mlist_list     = matchlist ( line, regex.ListStart )
				if ! empty ( mlist_template )
					let state   = 'text'
					let t_type  = 'template'
					let t_start = 1
				elseif ! empty ( mlist_help )
					let state   = 'text'
					let t_type  = 'help'
					let t_start = 1
				elseif ! empty ( mlist_list )
					let state   = 'text'
					let t_type  = 'list'
					let t_start = 1
				endif
				"
			endif
			"
			" empty line?
			if line =~ regex.EmptyLine
				continue
			endif
			"
		elseif state == 'text'
			" ==================================================
			"  state: text
			" ==================================================
			"
			if firstchar == regex.CommentHint || firstchar == regex.DelimHint
				"
				" comment or end of template?
				if line =~ regex.CommentLine
							\ || line =~ regex.TemplateEnd
							\ || line =~ regex.ListEnd
					let state = 'command'
					call s:AddText ( t_type, t_name, t_settings, t_lines )
					continue
				endif
				"
				" start of new text?
				let mlist_template = matchlist ( line, regex.TemplateStart )
				let mlist_help     = matchlist ( line, regex.HelpStart )
				let mlist_list     = matchlist ( line, regex.ListStart )
				if ! empty ( mlist_template )
					call s:AddText ( t_type, t_name, t_settings, t_lines )
					let t_type  = 'template'
					let t_start = 1
				elseif ! empty ( mlist_help )
					call s:AddText ( t_type, t_name, t_settings, t_lines )
					let t_type  = 'help'
					let t_start = 1
				elseif ! empty ( mlist_list )
					call s:AddText ( t_type, t_name, t_settings, t_lines )
					let t_type  = 'list'
					let t_start = 1
				else
					let t_lines .= line."\n"    " read the line
					continue
				endif
				"
			else
				let t_lines .= line."\n"      " read the line
				continue
			endif
			"
		endif
		"
		" start of template?
		if t_start
			if t_type == 'template'
				let t_name     = mlist_template[1]
				let t_settings = split( mlist_template[2], '\s*,\s*' )
			elseif t_type == 'list'
				let t_name     = mlist_list[1]
				let t_settings = split( mlist_list[2], '\s*,\s*' )
			elseif t_type == 'help'
				let t_name     = mlist_help[1]
				let t_settings = split( mlist_help[2], '\s*,\s*' )
			endif
			let t_lines    = ''
			let t_start    = 0
			continue
		endif
		"
		call s:ErrorMsg ( 'Failed to read line: '.line )
		"
	endfor
	"
	" ==================================================
	"  wrap up
	" ==================================================
	"
	if state == 'text'
		call s:AddText ( t_type, t_name, t_settings, t_lines )
	endif
	"
	" all style sections closed?
	let state_lim = s:t_runtime.state_stack[ s:StateStackStyleTop ]
	let state_top = len( s:t_runtime.styles_stack )
	if state_lim < state_top
		call s:RevertStyles ( state_top - state_lim )
		call s:ErrorMsg ( 'Styles section has not been closed: '.last_styles )
	endif
	"
	" debug:
	call s:DebugMsg ( '... '.templatefile.' done.', 2 )
	"
	" restore the previous state
	call remove ( s:t_runtime.state_stack, -1 * s:StateStackLength, -1 )
	"
endfunction    " ----------  end of function s:IncludeFile  ----------
"
"----------------------------------------------------------------------
"  mmtemplates#core#ReadTemplates : Read a template file.   {{{1
"----------------------------------------------------------------------
"
function! mmtemplates#core#ReadTemplates ( library, ... )
	"
	" ==================================================
	"  parameters
	" ==================================================
	"
	if type( a:library ) == type( '' )
		exe 'let t_lib = '.a:library
	elseif type( a:library ) == type( {} )
		let t_lib = a:library
	else
		return s:ErrorMsg ( 'Argument "library" must be given as a dict or string.' )
	endif
	"
	" ==================================================
	"  setup
	" ==================================================
	"
	" library and runtime information
	let s:library   = t_lib
	let s:t_runtime = {
				\ 'state_stack'   : [],
				\ 'use_styles'    : [],
				\ 'styles_stack'  : [],
				\ 'files_visited' : {},
				\
				\ 'overwrite_warning' : 0,
				\ }
	"
	let mode = ''
	let file = ''
	"
	" ==================================================
	"  options
	" ==================================================
	"
	let i = 1
	while i <= a:0
		"
		if a:[i] == 'load' && i+1 <= a:0
			let mode = 'load'
			let file = a:[i+1]
			let i += 2
		elseif a:[i] == 'reload' && i+1 <= a:0
			let mode = 'reload'
			let file = a:[i+1]
			let i += 2
		elseif a:[i] == 'overwrite_warning'
			let s:t_runtime.overwrite_warning = 1
			let i += 1
		elseif a:[i] == 'debug' && i+1 <= a:0 && ! s:DebugGlobalOverwrite
			let s:DebugLevel = a:[i+1]
			let i += 2
		else
			if type ( a:[i] ) == type ( '' ) | call s:ErrorMsg ( 'Unknown option: "'.a:[i].'"' )
			else                             | call s:ErrorMsg ( 'Unknown option at position '.i.'.' ) | endif
			let i += 1
		endif
		"
	endwhile
	"
	" ==================================================
	"  files
	" ==================================================
	"
	let templatefiles = []
	"
	if mode == 'load'
		"
		" check the type
		if type( file ) != type( '' )
			return s:ErrorMsg ( 'Argument "filename" must be given as a string.' )
		endif
		"
		" expand ~, $HOME, ... and normalize
		let file = expand ( file )
		call add ( templatefiles, s:ConcatNormalizedFilename ( file ) )
		"
		" add to library
		call add ( t_lib.library_files, s:ConcatNormalizedFilename ( file ) )
		"
	elseif mode == 'reload'
		"
		if type( file ) == type( 0 )
			call add ( templatefiles, t_lib.library_files[ file ] )
		elseif type( file ) == type( '' )
			" load all or a specific file
			if file == 'all'
				call extend ( templatefiles, t_lib.library_files )
			else
				"
				" check and add the file
				let file = expand ( file )
				let file = s:ConcatNormalizedFilename ( file )
				"
				if ! filereadable ( file )
					return s:ErrorMsg ( 'The file "'.file.'" does not exist.' )
				elseif index ( t_lib.library_files, file ) == -1
					return s:ErrorMsg ( 'The file "'.file.'" is not part of the template library.' )
				endif
				"
				call add ( templatefiles, file )
				"
			endif
		else
			return s:ErrorMsg ( 'Argument "fileid" must be given as an integer or string.' )
		endif
		"
		" remove old maps
		if has_key ( t_lib, 'map_commands' )
			call remove ( t_lib, 'map_commands' )
		endif
		"
	endif
	"
	" ==================================================
	"  read the library
	" ==================================================
	"
	" debug:
	if s:DebugLevel > 0
		let time_start = reltime()
	endif
	"
	for f in templatefiles
		"
		" file exists?
		if !filereadable ( f )
			call s:ErrorMsg ( 'Template library "'.f.'" does not exist or is not readable.' )
			continue
		endif
		"
		" runtime information:
		" - set up the state stack: length of styles_stack + current path
		" - reset the current styles
		let s:t_runtime.state_stack   = [ 0, s:GetNormalizedPath ( f ) ]
		let s:t_runtime.use_styles    = []
		let s:t_runtime.styles_stack  = []
		"
		" read the top-level file
		call s:IncludeFile ( f, 'abs' )
		"
	endfor
	"
	call sort ( s:library.styles )          " sort the styles
	"
	" debug:
	if s:DebugLevel > 0
		echo 'Loading library: '.reltimestr( reltime( time_start ) )
	endif
	"
	if mode == 'reload'
		echo 'Reloaded the template library.'
	endif
	"
	" ==================================================
	"  wrap up
	" ==================================================
	"
	unlet s:library                             " remove script variables
	unlet s:t_runtime                           " ...
	"
	let s:DebugLevel = s:DebugGlobalOverwrite   " reset debug
	"
endfunction    " ----------  end of function mmtemplates#core#ReadTemplates  ----------
"
"----------------------------------------------------------------------
" === Templates ===   {{{1
"----------------------------------------------------------------------
"
"----------------------------------------------------------------------
" s:ApplyFlag : Modify a text according to 'flag'.   {{{2
"----------------------------------------------------------------------
"
function! s:ApplyFlag ( text, flag )
	"
	if a:flag == '' || a:flag == 'i'      " i : identity
		return a:text
	elseif a:flag == 'l'                  " l : lowercase
		return tolower(a:text)
	elseif a:flag == 'u'                  " u : uppercase
		return toupper(a:text)
	elseif a:flag == 'c'                  " c : capitalize
		return toupper(a:text[0]).a:text[1:]
	elseif a:flag == 'L'                  " L : legalized name
		let text = substitute( a:text, '\s\+', '_', 'g' ) " multiple whitespaces
		let text = substitute(   text, '\W\+', '_', 'g' ) " multiple non-word characters
		let text = substitute(   text, '_\+',  '_', 'g' ) " multiple underscores
		return text
	else                                   " flag not valid
		return a:text
	endif
	"
endfunction    " ----------  end of function s:ApplyFlag  ----------
"
"----------------------------------------------------------------------
" s:ReplaceMacros : Replace all the macros in a text.   {{{2
"----------------------------------------------------------------------
"
function! s:ReplaceMacros ( text, m_local )
	"
	let text1 = ''
	let text2 = a:text
	"
	let regex = '\(\_.\{-}\)'.s:library.regex_template.MacroInsert.'\(\_.*\)'
	"
	while 1
		"
		let mlist = matchlist ( text2, regex )
		"
		" no more macros?
		if empty ( mlist )
			break
		endif
		"
		" check for recursion
		if -1 != index ( s:t_runtime.macro_stack, mlist[2] )
			let m_text = ''
			call add ( s:t_runtime.macro_stack, mlist[2] )
			throw 'Template:MacroRecursion'
		elseif has_key ( a:m_local, mlist[2] )
			let m_text = get ( a:m_local, mlist[2] )
		else
			let m_text = get ( s:library.macros, mlist[2], '' )
		end
		"
		if m_text =~ s:library.regex_template.MacroNoCapture
			"
			call add ( s:t_runtime.macro_stack, mlist[2] )
			"
			let m_text = s:ReplaceMacros ( m_text, a:m_local )
			"
			call remove ( s:t_runtime.macro_stack, -1 )
			"
		endif
		"
		" apply flag?
		if ! empty ( mlist[3] )
			let m_text = s:ApplyFlag ( m_text, mlist[3] )
		endif
		"
		let text1 .= mlist[1].m_text
		let text2  = mlist[4]
		"
	endwhile
	"
	return text1.text2
	"
endfunction    " ----------  end of function s:ReplaceMacros  ----------
"
"----------------------------------------------------------------------
" s:CheckHelp : Check a template (help).   {{{2
"----------------------------------------------------------------------
"
let s:NamespaceHelp = {
			\ 'Word'       : 's',
			\ 'Pattern'    : 's',   'Default'    : 's',
			\ 'Substitute' : 'sss', 'LiteralSub' : 'sss',
			\ 'System'     : 's',   'Vim'        : 's',
			\ }
"
function! s:CheckHelp ( cmds, text, calls )
	return [ a:cmds, a:text ]
endfunction    " ----------  end of function s:CheckHelp  ----------
"
" "----------------------------------------------------------------------
" s:CheckStdTempl : Check a template (standard).   {{{2
"----------------------------------------------------------------------
"
let s:NamespaceStdTempl = {
			\ 'DefaultMacro' : 's[sl]',
			\ 'PickFile'     : 'ss',
			\ 'PickList'     : 's[sld]',
			\ 'Prompt'       : 'ss',
			\ 'SurroundWith' : 's[sl]*',
			\ }
let s:NamespaceStdTemplInsert = {
			\ 'Comment'    : 's\?',
			\ 'Insert'     : 's[sl]*',
			\ 'InsertLine' : 's[sl]*',
			\ }
"
function! s:CheckStdTempl ( cmds, text, calls )
	"
	let regex = s:library.regex_template
	let ms    = regex.MacroStart
	let me    = regex.MacroEnd
	"
	let cmds = a:cmds
	let text = a:text
	"
	let prompted = {}
	"
	" --------------------------------------------------
	"  replacements
	" --------------------------------------------------
	while 1
		"
		let mlist = matchlist ( text, regex.MacroRequest )
		"
		" no more macros?
		if empty ( mlist )
			break
		endif
		"
		let m_name = mlist[1]
		let m_flag = mlist[2]
		"
		" not a special macro and not already done?
		if has_key ( s:StandardMacros, m_name )
			call s:ErrorMsg ( 'The special macro "'.m_name.'" can not be replaced via |?'.m_name.'|.' )
		elseif ! has_key ( prompted, m_name )
			let cmds .= "Prompt(".string(m_name).",".string(m_flag).")\n"
			let prompted[ m_name ] = 1
		endif
		"
		if ! empty ( m_flag ) | let m_flag = ':'.m_flag | endif
		"
		" insert a normal macro
		let text = s:LiteralReplacement ( text, 
					\ mlist[0], ms.m_name.m_flag.me, 'g' )
		"
	endwhile
	"
	" --------------------------------------------------
	"  lists
	" --------------------------------------------------
	let list_items = [ 'EMPTY', 'SINGLE', 'FIRST', 'LAST' ]   " + 'ENTRY'
	"
	while 1
		"
		let mlist = matchlist ( text, regex.ListItem )
		"
		" no more macros?
		if empty ( mlist )
			break
		endif
		"
		let l_name = mlist[1]
		"
		let mlist = matchlist ( text,
					\ '\([^'."\n".']*\)'.ms.l_name.':ENTRY_*'.me.'\([^'."\n".']*\)\n' )
		"
		let cmds .= "LIST(".string(l_name).","
					\ .string(mlist[1]).",".string(mlist[2]).")\n"
		let text  = s:LiteralReplacement ( text,
					\ mlist[0], ms.l_name.':LIST'.me."\n", '' )
		"
		for item in list_items
			"
			let mlist = matchlist ( text,
						\ '\([^'."\n".']*\)'.ms.l_name.':'.item.'_*'.me.'\([^'."\n".']*\)\n' )
			"
			if empty ( mlist )
				let cmds .= "\n"
				continue
			endif
			"
			let cmds .= "[".string(mlist[1]).",".string(mlist[2])."]\n"
			let text  = s:LiteralReplacement ( text, mlist[0], '', '' )
		endfor
		"
	endwhile
	"
	" --------------------------------------------------
	"  comments
	" --------------------------------------------------
	while 1
		"
		let mlist = matchlist ( text, regex.FunctionComment )
		"
		" no more comments?
		if empty ( mlist )
			break
		endif
		"
		let [ f_name, f_param ] = mlist[ 1 : 2 ]
		"
		" check the call
		call s:FunctionCheck ( 'Comment', f_param, s:NamespaceStdTemplInsert )
		"
		exe 'let flist = ['.f_param.']'
		"
		if empty ( flist ) | let flag = 'eol'
		else               | let flag = flist[0] | endif
		"
		let mlist = matchlist ( text, regex.FunctionComment.'\s*\([^'."\n".']*\)' )
		"
		let text = s:LiteralReplacement ( text, mlist[0],
					\ ms.'InsertLine("Comments.end-of-line","|CONTENT|",'.string( mlist[3] ).')'.me, '' )
		"
	endwhile
	"
	return [ cmds, text ]
	"
endfunction    " ----------  end of function s:CheckStdTempl  ----------
"
"----------------------------------------------------------------------
" s:CheckTemplate : Check a template.   {{{2
"
" Get the command and text block.
"----------------------------------------------------------------------
"
function! s:CheckTemplate ( template, type )
	"
	let regex = s:library.regex_template
	"
	let cmds          = ''
	let text          = ''
	let calls         = []
	"
	" the known functions
	if a:type == 't'
		let namespace = s:NamespaceStdTempl
"		" TODO: remove this code:
" 	elseif a:type == 'pick-file'
" 		let namespace = s:NamespacePickFile
" 	elseif a:type == 'pick-list'
" 		let namespace = s:NamespacePickList
	elseif a:type == 'help'
		let namespace = s:NamespaceHelp
	endif
	"
	" go trough the lines
	let idx = 0
	while idx < len ( a:template )
		"
		let idx_n = stridx ( a:template, "\n", idx )
		let mlist = matchlist ( a:template[ idx : idx_n ], regex.FunctionLine )
		"
		" no match or 'Comment' or 'Insert' function?
		if empty ( mlist ) || mlist[ 2 ] =~ regex.TextBlockFunctions
			break
		endif
		"
		let [ f_name, f_param ] = mlist[ 2 : 3 ]
		"
		" check the call
		call s:FunctionCheck ( f_name, f_param, namespace )
		"
		call add ( calls,  [ f_name, f_param ] )
		"
		let cmds .= mlist[1]."\n"
		let idx  += len ( mlist[0] )
		"
	endwhile
	"
	let text = a:template[ idx : -1 ]
	"
	" checks depending on the type
	if a:type == 't'
		return s:CheckStdTempl( cmds, text, calls )
"		" TODO: remove this code:
" 	elseif a:type == 'pick-file'
" 		return s:CheckPickFile( cmds, text, calls )
" 	elseif a:type == 'pick-list'
" 		return s:CheckPickList( cmds, text, calls )
	elseif a:type == 'help'
		return s:CheckHelp( cmds, text, calls )
	endif
	"
endfunction    " ----------  end of function s:CheckTemplate  ----------
"
"----------------------------------------------------------------------
" s:GetTemplate : Get a template.   {{{2
"----------------------------------------------------------------------
"
function! s:GetTemplate ( name, style )
	"
	let name  = a:name
	let style = a:style
	"
	" check the template
	if has_key ( s:library.templates, name.'!!type' )
		let info = s:library.templates[ a:name.'!!type' ]
		let [ type, placement, indentation ] = split ( info, ',' )
	else
		throw 'Template:Prepare:template does not exist'
	endif
	"
	if style == '!any'
		for s in s:library.styles
			if has_key ( s:library.templates, name.'!'.s )
				let template = get ( s:library.templates, name.'!'.s )
				let style    = s
			endif
		endfor
	else
		" check the style
		if has_key ( s:library.templates, name.'!'.style )
			let template = get ( s:library.templates, name.'!'.style )
		elseif has_key ( s:library.templates, name.'!default' )
			let template = get ( s:library.templates, name.'!default' )
			let style    = 'default'
		elseif style == 'default'
			throw 'Template:Prepare:template does not have the default style'
		else
			throw 'Template:Prepare:template has neither the style "'.style.'" nor the default style'
		endif
	endif
	"
	" check the text
	let head = template[ 0 : 5 ]
	"
	if head == "|P()|\n"          " plain text
		" TODO: special type for plain
		let cmds = ''
		let text = template[ 6 : -1 ]
	elseif head == "|T()|\n"      " only text (contains only macros without '?')
		let cmds = ''
		let text = template[ 6 : -1 ]
	elseif head == "|C()|\n"      " command and text block
		let splt = stridx ( template, "|T()|\n" ) - 1
		let cmds = template[ 6 : splt ]
		let text = template[ splt+7 : -1 ]
	else
		"
		" do checks
		let [ cmds, text ] = s:CheckTemplate ( template, type )
		"
		" save the result
		if empty ( cmds )
			let template = "|T()|\n".text
		else
			let template = "|C()|\n".cmds."|T()|\n".text
		end
		let s:library.templates[ a:name.'!'.style  ] = template
		"
	end
	"
	return [ cmds, text, type, placement, indentation ]
endfunction    " ----------  end of function s:GetTemplate  ----------
"
"----------------------------------------------------------------------
" s:GetPickList : Get the list used in a template.   {{{2
"----------------------------------------------------------------------
"
function! s:GetPickList ( name )
	"
	let regex = s:library.regex_template
	"
	" get the template
	let [ cmds, text, type, placement, indentation ] = s:GetTemplate ( a:name, '!any' )
	"
	if type == 't'
		"
		for line in split( cmds, "\n" )
			" the line will match and it will be a valid function
			let [ f_name, f_param ] = matchlist ( line, regex.FunctionChecked )[ 1 : 2 ]
			"
			if f_name == 'PickList'
				"
				exe 'let [ _, listarg ] = [ '.f_param.' ]'
				"
				let entry = ''
				"
				if type ( listarg ) == type ( '' )
					if ! has_key ( s:library.resources, 'list!'.listarg )
						call s:ErrorMsg ( 'List "'.listarg.'" does not exist.' )
						return []
					endif
					let list = s:library.resources[ 'list!'.listarg ]
				else
					let list = listarg
				endif
				"
			endif
		endfor
		"
"		" TODO: remove this code:
" 	elseif type == 'pick-list'
" 		"
" 		for line in split( cmds, "\n" )
" 			" the line will match and it will be a valid function
" 			let [ f_name, f_param ] = matchlist ( line, regex.FunctionChecked )[ 1 : 2 ]
" 			"
" 			if f_name == 'List'
" 				exe 'let list = '.f_param
" 			elseif f_name == 'GetList'
" 				"
" 				let listname = matchstr ( f_param, regex.RemoveQuote )
" 				if ! has_key ( s:library.resources, 'list!'.listname )
" 					call s:ErrorMsg ( 'List "'.listname.'" does not exist.' )
" 					return []
" 				endif
" 				let list = s:library.resources[ 'list!'.listname ]
" 				"
" 			endif
" 		endfor
" 		"
	else
		call s:ErrorMsg ( 'Template "'.a:name.'" is not a list picker.' )
		return []
	endif
	"
	if type ( list ) == type ( [] )
		return list
	else
		return sort ( keys ( list ) )
	endif
	"
endfunction    " ----------  end of function s:GetPickList  ----------
"
"----------------------------------------------------------------------
" s:PrepareHelp : Prepare a template (help).   {{{2
"----------------------------------------------------------------------
"
function! s:PrepareHelp ( cmds, text )
	"
	let regex = s:library.regex_template
	"
	let pick    = ''
	let default = ''
	let method  = ''
	let call    = ''
	"
	let buf_line = getline('.')
	let buf_pos  = col('.') - 1
	"
	" ==================================================
	"  command block
	" ==================================================
	"
	for line in split( a:cmds, "\n" )
		"
		" the line will match and it will be a valid function
		let [ f_name, f_param ] = matchlist ( line, regex.FunctionChecked )[ 1 : 2 ]
		"
		if f_name == 'C'
			" ignore
		elseif f_name == 'Word'
			exe 'let switch = '.f_param   | " TODO: works differently than 'Pattern': picks up word behind the cursor, too
			if switch == 'W' | let pick = expand('<cWORD>')
			else             | let pick = expand('<cword>') | endif
		elseif f_name == 'Pattern'
			exe 'let pattern = '.f_param
			let cnt = 1
			while 1
				let m_end = matchend ( buf_line, pattern, 0, cnt ) - 1
				if m_end < 0
					let pick = ''
					break
				elseif m_end >= buf_pos
					let m_start = match ( buf_line, pattern, 0, cnt )
					if m_start <= buf_pos | let pick = buf_line[ m_start : m_end ]
					else                  | let pick = ''                          | endif
					break
				endif
				let cnt += 1
			endwhile
		elseif f_name == 'Default'
			exe 'let default = '.f_param
		elseif f_name == 'LiteralSub'
			exe 'let [ p, r, f ] = ['.f_param.']'
			let pick = s:LiteralReplacement ( pick, p, r, f )
		elseif f_name == 'Substitute'
			exe 'let [ p, r, f ] = ['.f_param.']'
			let pick = substitute ( pick, p, r, f )
		elseif f_name == 'System' || f_name == 'Vim'
			let method = f_name
			exe 'let call = '.f_param
		endif
		"
	endfor
	"
	" ==================================================
	"  call for help
	" ==================================================
	"
	if empty ( pick ) && empty ( default )
				\ || empty ( method )
		return ''
	endif
	"
	let m_local = copy ( s:t_runtime.macros )
	"
	if ! empty ( pick )
		let m_local.PICK = pick
		let call = s:ReplaceMacros ( call,    m_local )
	else
		let call = s:ReplaceMacros ( default, m_local )
	endif
	"
	if method == 'System'
		echo 'call system ( '.string ( call ).' )'   | " debug
		exe 'call system ( '.string ( call ).' )'
	elseif method == 'Vim'
		echo call   | " debug
		exe call
	endif
	"
	return ''
	"
endfunction    " ----------  end of function s:PrepareHelp  ----------
"
" "----------------------------------------------------------------------
" s:PrepareStdTempl : Prepare a template (standard).   {{{2
"----------------------------------------------------------------------
"
function! s:PrepareStdTempl ( cmds, text )
	"
	" TODO: revert must work like a stack, first set, last reverted
	" TODO: revert in case of PickList and PickFile
	"
	let regex = s:library.regex_template
	let ms    = regex.MacroStart
	let me    = regex.MacroEnd
	"
	let m_local  = s:t_runtime.macros
	let m_global = s:library.macros
	let prompted = s:t_runtime.prompted
	"
	let text     = a:text
	let surround = ''
	let revert   = ''
	"
	"
	" ==================================================
	"  command block
	" ==================================================
	"
	let cmds   = split( a:cmds, "\n" )
	let i_cmds = 0
	let n_cmds = len( cmds )
	"
	while i_cmds < n_cmds
		"
		" the line will match and it will be a valid function
		let [ f_name, f_param ] = matchlist ( cmds[ i_cmds ], regex.FunctionChecked )[ 1 : 2 ]
		"
		if f_name == 'C'
			" ignore
		elseif f_name == 'SurroundWith'
			let surround = f_param
		elseif f_name == 'DefaultMacro'
			"
			let [ m_name, m_text ] = eval ( '[ '.f_param.' ]' )
			"
			if ! has_key ( m_local, m_name )
				let revert = 'call remove ( m_local, "'.m_name.'" ) | '.revert
				let m_local[ m_name ] = m_text
			endif
			"
		elseif f_name == 'PickFile'
			"
			let [ p_prompt, p_path ] = eval ( '[ '.f_param.' ]' )
			"
			if p_path =~ regex.MacroName
				if ! has_key ( s:library.resources, 'path!'.p_path )
					throw 'Template:Prepare:the resources "'.p_path.'" does not exist'
				endif
				let p_path = s:library.resources[ 'path!'.p_path ]
			endif
			"
			let p_path = expand ( p_path )
			let	file = s:UserInput ( p_prompt.' : ', p_path, 'file' )
			"
			let m_local.PICK_COMPL = file
			let m_local.PATH_COMPL = fnamemodify ( file, ':h' )
			"
			let file = substitute ( file, '\V\^'.p_path, '', '' )
			"
			let m_local.PICK     = file
			let m_local.PATH     = fnamemodify ( file, ':h'   )
			let m_local.FILENAME = fnamemodify ( file, ':t'   )
			let m_local.BASENAME = fnamemodify ( file, ':t:r' )
			let m_local.SUFFIX   = fnamemodify ( file, ':e'   )
			"
		elseif f_name == 'PickEntry'
			"
			let [ p_which, p_entry ] = eval ( '[ '.f_param.' ]' )
			"
			let l:pick_entry = p_entry
			"
		elseif f_name == 'PickList'
			"
			let [ p_prompt, p_list ] = eval ( '[ '.f_param.' ]' )
			"
			if type ( p_list ) == type ( '' )
				if ! has_key ( s:library.resources, 'list!'.p_list )
					throw 'Template:Prepare:the resources "'.p_list.'" does not exist'
				endif
				let list = s:library.resources[ 'list!'.p_list ]
			else
				let list = p_list
			end
			"
			if type ( list ) == type ( [] )
				let type = 'list'
				let input_list = list
			else
				let type = 'dict'
				let input_list = sort ( keys ( list ) )
			endif
			"
			if exists ( 'l:pick_entry' )
				let entry = l:pick_entry
			else
				let entry = s:UserInput ( p_prompt.' : ', '', 'customlist', input_list )
			endif
			"
			let m_local.KEY = entry
			"
			if type == 'dict'
				if ! has_key ( list, entry )
					throw 'Template:Prepare:the entry "'.entry.'" does not exist'
				endif
				let entry = list[ entry ]
			endif
			"
			let m_local.VALUE = entry
			let m_local.PICK  = entry
			"
		elseif f_name == 'Prompt'
			"
			let [ m_name, m_flag ] = eval ( '[ '.f_param.' ]' )
			"
			" not already done and not a local macro?
			if ! has_key ( prompted, m_name )
						\ && ! has_key ( m_local, m_name )
				let m_text = get ( m_global, m_name, '' )
				"
				" prompt user for replacement
				let flagaction = get ( s:Flagactions, m_flag, '' )         " notify flag action, if any
				let m_text = s:UserInput ( m_name.flagaction.' : ', m_text )
				let m_text = s:ApplyFlag ( m_text, m_flag )
				"
				" save the result
				let m_global[ m_name ] = m_text
				let prompted[ m_name ] = 1
			endif
		else
			break
		endif
		"
		let i_cmds += 1
	endwhile
	"
	" --------------------------------------------------
	"  lists
	" --------------------------------------------------
	"
	while i_cmds < n_cmds
		"
		let mlist = matchlist ( cmds[ i_cmds ], regex.FunctionList )
		"
		if empty ( mlist )
			break
		endif
		"
		exe 'let [ l_name, head_def, tail_def ] = ['.mlist[1].']'
		let l_text = ''
		if ! has_key ( m_local, l_name )
			let l_len = 0
		elseif type ( m_local[ l_name ] ) == type ( '' )
			let l_list = [ m_local[ l_name ] ]
			let l_len  = 1
		else
			let l_list = m_local[ l_name ]
			let l_len  = len ( l_list )
		endif
		"
		if l_len == 0
			if ! empty ( cmds[ i_cmds+1 ] )
				exe 'let [ head, tail ] = '.cmds[ i_cmds+1 ]
				let l_text = head.tail."\n"
			endif
		elseif l_len == 1
			if ! empty ( cmds[ i_cmds+2 ] )
				exe 'let [ head, tail ] = '.cmds[ i_cmds+2 ]
				let l_text = head.l_list[0].tail."\n"
			elseif ! empty ( cmds[ i_cmds+3 ] )
				exe 'let [ head, tail ] = '.cmds[ i_cmds+3 ]
				let l_text = head.l_list[0].tail."\n"
			else
				let l_text = head_def.l_list[0].tail_def."\n"
			end
		else     " l_len >= 2
			"
			if ! empty ( cmds[ i_cmds+3 ] )
				exe 'let [ head, tail ] = '.cmds[ i_cmds+3 ]
				let l_text .= head.l_list[0].tail."\n"
			else
				let l_text .= head_def.l_list[0].tail_def."\n"
			endif
			"
			for idx in range ( 1, l_len-2 )
				let l_text .= head_def.l_list[idx].tail_def."\n"
			endfor
			"
			if ! empty ( cmds[ i_cmds+4 ] )
				exe 'let [ head, tail ] = '.cmds[ i_cmds+4 ]
				let l_text .= head.l_list[-1].tail."\n"
			else
				let l_text .= head_def.l_list[-1].tail_def."\n"
			endif
		endif
		"
		let text = s:LiteralReplacement ( text, ms.l_name.':LIST'.me."\n", l_text, '' )
		"
		let i_cmds += 5
	endwhile
	"
	" ==================================================
	"  text block: macros and templates
	" ==================================================
	"
	" insert other templates
	while 1
		"
		let mlist = matchlist ( text, regex.FunctionInsert )
		"
		" no more inserts?
		if empty ( mlist )
			break
		endif
		"
		let [ f_name, f_param ] = mlist[ 1 : 2 ]
		"
		" check the call
		call s:FunctionCheck ( f_name, f_param, s:NamespaceStdTemplInsert )
		"
		if f_name == 'InsertLine'
			" get the replacement
			exe 'let m_text = s:PrepareTemplate ( '.f_param.' )[0]'
			let m_text = m_text[ 0 : -2 ]
			" check
			if m_text =~ "\n"
				throw 'Template:Prepare:inserts more than a single line: "'.mlist[0].'"'
			endif
		elseif f_name == 'Insert'
			" get the replacement
			exe 'let m_text = s:PrepareTemplate ( '.f_param.' )[0]'
			let m_text = m_text[ 0 : -2 ]
			" prepare
			let mlist = matchlist ( text, '\([^'."\n".']*\)'.regex.FunctionInsert.'\([^'."\n".']*\)' )
			let head = mlist[1]
			let tail = mlist[4]
			let m_text = head.substitute( m_text, "\n", tail."\n".head, 'g' ).tail
		else
			throw 'Template:Check:the function "'.f_name.'" does not exist'
		endif
		"
		" insert
		let text = s:LiteralReplacement ( text, mlist[0], m_text, '' )
		"
	endwhile
	"
	" insert the replacements
	let text = s:ReplaceMacros ( text, m_local )
	"
	" ==================================================
	"  surround the template
	" ==================================================
	"
	if ! empty ( surround )
		" get the replacement
		exe 'let [ s_text, s_place ] = s:PrepareTemplate ( '.surround.', "do_surround" )'
		"
		if s_place == 'CONTENT'
			if -1 == match( s_text, '<CONTENT>' )
				throw 'Template:Prepare:surround template: <CONTENT> missing'
			endif
			"
			let mcontext = matchlist ( s_text, '\([^'."\n".']*\)'.'<CONTENT>'.'\([^'."\n".']*\)' )
			let head = mcontext[1]
			let tail = mcontext[2]
			" insert
			let text = text[ 0: -2 ]  " remove trailing '\n'
			let text = head.substitute( text, "\n", tail."\n".head, 'g' ).tail
			let text = s:LiteralReplacement ( s_text, mcontext[0], text, '' )
		elseif s_place == 'SPLIT'
			if -1 == match( s_text, '<SPLIT>' )
				throw 'Template:Prepare:surround template: <SPLIT> missing'
			endif
			"
			if match( s_text, '<SPLIT>\s*\n' ) >= 0
				let part = split ( s_text, '\s*<SPLIT>\s*\n', 1 )
			else
				let part = split ( s_text, '<SPLIT>', 1 )
			endif
			let text = part[0].text.part[1]
		endif
	endif
	"
	exe revert
	"
	return text
	"
endfunction    " ----------  end of function s:PrepareStdTempl  ----------
"
"----------------------------------------------------------------------
" s:PrepareTemplate : Prepare a template for insertion.   {{{2
"----------------------------------------------------------------------
"
function! s:PrepareTemplate ( name, ... )
	"
	let regex = s:library.regex_template
	"
	" ==================================================
	"  setup and checks
	" ==================================================
	"
	" check for recursion
	if -1 != index ( s:t_runtime.obj_stack, a:name )
		call add ( s:t_runtime.obj_stack, a:name )
		throw 'Template:Recursion'
	endif
	"
	call add ( s:t_runtime.obj_stack, a:name )
	"
	" current style
	let style = s:library.current_style
	"
	" get the template
	let [ cmds, text, type, placement, indentation ] = s:GetTemplate ( a:name, style )
	"
	" current macros
	let m_local  = s:t_runtime.macros
	let prompted = s:t_runtime.prompted
	"
	let remove_cursor  = 1
	let remove_split   = 1
	let use_surround   = 0
	let use_split      = 0
	"
	let revert = ''
	"
	" ==================================================
	"  parameters
	" ==================================================
	"
	let i = 1
	while i <= a:0
		"
		if a:[i] =~ regex.MacroMatch && i+1 <= a:0
			let m_name = matchlist ( a:[i], regex.MacroNameC )[1]
			if has_key ( m_local, m_name )
				let revert = 'let  m_local["'.m_name.'"] = '.string( m_local[ m_name ] ).' | '.revert
			else
				let revert = 'call remove ( m_local, "'.m_name.'" ) | '.revert
			endif
			let m_local[ m_name ] = a:[i+1]
			let i += 2
		elseif a:[i] == '<CURSOR>'
			let remove_cursor = 0
			let i += 1
		elseif a:[i] == '<SPLIT>'
			let remove_split = 0
			let i += 1
		elseif a:[i] == 'do_surround'
			let use_surround = 1
			let i += 1
		elseif a:[i] == 'use_split'
			let use_split    = 1
			let remove_split = 0
			let i += 1
		elseif a:[i] == 'pick' && i+1 <= a:0
			let cmds = "PickEntry( '', ".string(a:[i+1])." )\n".cmds
			let i += 2
		else
			if type ( a:[i] ) == type ( '' ) | call s:ErrorMsg ( 'Unknown option: "'.a:[i].'"' )
			else                             | call s:ErrorMsg ( 'Unknown option at position '.i.'.' ) | endif
			let i += 1
		endif
		"
	endwhile
	"
	" ==================================================
	"  prepare
	" ==================================================
	"
	if type == 't'
		let text = s:PrepareStdTempl( cmds, text )
"		" TODO: remove this code:
" 	elseif type == 'pick-file'
" 		let text = s:PreparePickFile( cmds, text )
" 	elseif type == 'pick-list'
" 		let text = s:PreparePickList( cmds, text )
	elseif type == 'help'
		let text = s:PrepareHelp( cmds, text )
	endif
	"
	if remove_cursor
		let text = s:LiteralReplacement( text, '<CURSOR>', '', 'g' )
	endif
	if remove_split
		let text = s:LiteralReplacement( text, '<SPLIT>',  '', 'g' )
	endif
	if ! use_surround || use_split
		let text = s:LiteralReplacement( text, '<CONTENT>',  '', 'g' )
	endif
	"
	" ==================================================
	"  wrap up
	" ==================================================
	"
	exe revert
	"
	call remove ( s:t_runtime.obj_stack, -1 )
	"
	if use_split
		return [ text, 'SPLIT' ]
	elseif use_surround
		return [ text, 'CONTENT' ]
	else
		return [ text, placement, indentation ]
	endif
	"
endfunction    " ----------  end of function s:PrepareTemplate  ----------
"
"----------------------------------------------------------------------
" === Insert Templates: Auxiliary Functions ===   {{{1
"----------------------------------------------------------------------
"
"----------------------------------------------------------------------
" s:InsertIntoBuffer : Insert a text into the buffer.   {{{2
" (thanks to Fritz Mehner)
"----------------------------------------------------------------------
"
function! s:InsertIntoBuffer ( text, placement, indentation, flag_mode )
	"
	" TODO: syntax
	let regex = s:library.regex_template
	"
	let placement   = a:placement
	let indentation = a:indentation == '1'
	"
	if a:flag_mode != 'v'
		" --------------------------------------------------
		"  command and insert mode
		" --------------------------------------------------
		"
		" remove the split point
		let text = substitute( a:text, '\V'.'<SPLIT>', '', 'g' )
		"
		if placement == 'below'
			"
			exe ':'.s:t_runtime.range[1]
			call s:OpenFold('below')
			let pos1 = line(".")+1
			silent put = text
			let pos2 = line(".")
			"
		elseif placement == 'above'
			"
			exe ':'.s:t_runtime.range[0]
			let pos1 = line(".")
			silent put! = text
			let pos2 = line(".")
			"
		elseif placement == 'start'
			"
			exe ':1'
			call s:OpenFold('start')
			let pos1 = 1
			silent put! = text
			let pos2 = line(".")
			"
		elseif placement == 'append' || placement == 'insert'
			"
			if &foldenable && foldclosed(".") >= 0
				throw 'Template:Insert:insertion not available for a closed fold'
			elseif placement == 'append'
				let pos1 = line(".")
				silent put = text
				let pos2 = line(".")-1
				exe ":".pos1
				:join!
				let indentation = 0
			elseif placement == 'insert'
				let text = text[ 0: -2 ]  " remove trailing '\n'
				let currentline = getline( "." )
				let pos1 = line(".")
				let pos2 = pos1 + count( split(text,'\zs'), "\n" )
				if a:flag_mode == 'i'
					exe 'normal! gi'.text
				else
					exe 'normal! a'.text
				endif
				" reformat only multi-line inserts and previously empty lines
				if pos1 == pos2 && currentline != ''
					let indentation = 0
				endif
			endif
			"
		else
			throw 'Template:Insert:unknown placement "'.placement.'"'
		endif
		"
	elseif a:flag_mode == 'v'
		" --------------------------------------------------
		"  visual mode
		" --------------------------------------------------
		"
		" remove the jump targets (2nd type)
		let text = substitute( a:text, regex.JumpTagType2, '', 'g' )
		"
		" TODO: Is the behaviour well-defined?
		" Suggestion: The line might include a cursor and a split and nothing else.
		if match( text, '<SPLIT>' ) >= 0
			if match( text, '<SPLIT>\s*\n' ) >= 0
				let part = split ( text, '\s*<SPLIT>\s*\n', 1 )
			else
				let part = split ( text, '<SPLIT>', 1 )
			endif
			let part[1] = part[1][ 0: -2 ]  " remove trailing '\n'
		else
			let part = [ "", text[ 0: -2 ] ]  " remove trailing '\n'
			echomsg 'tag <SPLIT> missing in template.'
		endif
		"
		" 'visual' and placement 'insert':
		"   <part0><marked area><part1>
		" part0 and part1 can consist of several lines
		"
		" 'visual' and placement 'below':
		"   <part0>
		"   <marked area>
		"   <part1>
		" part0 and part1 can consist of several lines
		"
		if placement == 'insert'
			" windows:  register @* does not work
			" solution: recover area of the visual mode and yank,
			"           puts the selected area into the buffer @"
			let pos1 = line("'<")
			let pos2 = line("'>") + len(split( text, '\n' )) - 1
			normal! gvy
			let repl = escape ( part[0].@".part[1], '\&~' )
			" substitute the selected area (using the '< and '> marks)
			exe ':s/\%''<.*\%''>./'.repl.'/'
			let indentation = 0
		elseif placement == 'below'
			silent '<put! = part[0]
			silent '>put  = part[1]
			let pos1 = line("'<") - len(split( part[0], '\n' ))
			let pos2 = line("'>") + len(split( part[1], '\n' ))
		elseif placement =~ '^\%(start\|above\|append\)$'
			throw 'Template:Insert:usage in split mode not allowed for placement "'.placement.'"'
		else
			throw 'Template:Insert:unknown placement "'.placement.'"'
		endif
		"
	endif
	"
	" proper indenting
	if indentation
		silent exe ":".pos1
		silent exe "normal! ".( pos2-pos1+1 )."=="
	endif
	"
	return [ pos1, pos2 ]
	"
endfunction    " ----------  end of function s:InsertIntoBuffer  ----------
"
"----------------------------------------------------------------------
" s:PositionCursor : Position the cursor.   {{{2
" (thanks to Fritz Mehner)
"----------------------------------------------------------------------
"
function! s:PositionCursor ( placement, flag_mode, pos1, pos2 )
	"
	" :TODO:12.08.2013 11:03:WM: changeable syntax?
	" :TODO:12.08.2013 12:00:WM: change behavior?
	"
	call setpos ( '.', [ bufnr('%'), a:pos1, 1, 0 ] )
	let mtch = search( '\m<CURSOR>\|{CURSOR}', 'c', a:pos2 )
	if mtch != 0
		" tag found (and cursor moved, we are now at the position of the match)
		let line = getline(mtch)
		if line =~ '<CURSOR>$\|{CURSOR}$'
			" the tag is at the end of the line
			call setline( mtch, substitute( line, '<CURSOR>\|{CURSOR}', '', '' ) )
			if a:flag_mode == 'v' && getline('.') =~ '^\s*$'
			"if a:flag_mode == 'v' && getline('.') =~ '^\s*\%(<CURSOR>\|{CURSOR}\)\s*$'
				" the line contains nothing but the tag: remove and join without
				" changing the second line
				normal! J
				"call setline( mtch, '' )
				"normal! gJ
			else
				" the line contains other characters: remove the tag and start appending
				"call setline( mtch, substitute( line, '<CURSOR>\|{CURSOR}', '', '' ) )
				startinsert!
			endif
		else
			" the line contains other characters: remove the tag and start inserting
			call setline( mtch, substitute( line, '<CURSOR>\|{CURSOR}', '', '' ) )
			startinsert
		endif
	else
		" no tag found (and cursor not moved)
		if a:placement == 'below'
			" to the end of the block, needed for repeated inserts
			exe ":".a:pos2
		endif
	endif
	"
endfunction    " ----------  end of function s:PositionCursor  ----------
"
"----------------------------------------------------------------------
" s:HighlightJumpTargets : Highlight the jump targets.   {{{2
"----------------------------------------------------------------------
"
function! s:HighlightJumpTargets ( regex )
	exe 'match Search /'.a:regex.'/'
endfunction    " ----------  end of function s:HighlightJumpTargets  ----------
"
"----------------------------------------------------------------------
" mmtemplates#core#InsertTemplate : Insert a template.   {{{1
"----------------------------------------------------------------------
"
function! mmtemplates#core#InsertTemplate ( library, t_name, ... ) range
	"
	" ==================================================
	"  parameters
	" ==================================================
	"
	if type( a:library ) == type( '' )
		exe 'let t_lib = '.a:library
	elseif type( a:library ) == type( {} )
		let t_lib = a:library
	else
		return s:ErrorMsg ( 'Argument "library" must be given as a dict or string.' )
	endif
	"
	if type( a:t_name ) != type( '' )
		return s:ErrorMsg ( 'Argument "template_name" must be given as a string.' )
	endif
	"
	" ==================================================
	"  setup
	" ==================================================
	"
	" library and runtime information
	let s:library = t_lib
	let s:t_runtime = {
				\ 'obj_stack'   : [],
				\ 'macro_stack' : [],
				\ 'macros'      : {},
				\ 'prompted'    : {},
				\
				\ 'placement' : '',
				\ 'range'     : [ a:firstline, a:lastline ],
				\ }
	let regex = s:library.regex_template
	"
	" renew the predefined macros
	let s:t_runtime.macros[ 'BASENAME' ] = expand( '%:t:r' )
	let s:t_runtime.macros[ 'FILENAME' ] = expand( '%:t'   )
	let s:t_runtime.macros[ 'PATH'     ] = expand( '%:p:h' )
	let s:t_runtime.macros[ 'SUFFIX'   ] = expand( '%:e'   )
	"
	let s:t_runtime.macros[ 'DATE' ]     = strftime( s:library.macros[ 'DATE' ] )
	let s:t_runtime.macros[ 'TIME' ]     = strftime( s:library.macros[ 'TIME' ] )
	let s:t_runtime.macros[ 'YEAR' ]     = strftime( s:library.macros[ 'YEAR' ] )
	"
	" handle folds internally (and save the state)
	if &foldenable
		let foldmethod_save = &foldmethod
		set foldmethod=manual
	endif
	" use internal formatting to avoid conflicts when using == below
	" (and save the state)
	let equalprg_save = &equalprg
	set equalprg=
	"
	let flag_mode = 'n'
	let options   = []
	"
	" ==================================================
	"  options
	" ==================================================
	"
	let i = 1
	while i <= a:0
		"
		if a:[i] == 'i' || a:[i] == 'insert'
			let flag_mode = 'i'
			let i += 1
		elseif a:[i] == 'v' || a:[i] == 'visual'
			let flag_mode = 'v'
			let i += 1
		elseif a:[i] == 'placement' && i+1 <= a:0
			let s:t_runtime.placement = a:[i+1]
			let i += 2
		elseif a:[i] == 'range' && i+2 <= a:0
			let s:t_runtime.range[0] = a:[i+1]
			let s:t_runtime.range[1] = a:[i+2]
			let i += 3
		elseif a:[i] =~ regex.MacroMatch && i+1 <= a:0
			let name = matchlist ( a:[i], regex.MacroNameC )[1]
			let s:t_runtime.macros[ name ] = a:[i+1]
			let i += 2
		elseif a:[i] == 'pick' && i+1 <= a:0
			call add ( options, 'pick' )
			call add ( options, a:[i+1] )
			let i += 2
		elseif a:[i] == 'debug' && i+1 <= a:0 && ! s:DebugGlobalOverwrite
			let s:DebugLevel = a:[i+1]
			let i += 2
		else
			if type ( a:[i] ) == type ( '' ) | call s:ErrorMsg ( 'Unknown option: "'.a:[i].'"' )
			else                             | call s:ErrorMsg ( 'Unknown option at position '.i.'.' ) | endif
			let i += 1
		endif
		"
	endwhile
	"
	" ==================================================
	"  do the job
	" ==================================================
	"
	try
		"
		" prepare the template for insertion
		if empty ( options )
			let [ text, placement, indentation ] = s:PrepareTemplate ( a:t_name, '<CURSOR>', '<SPLIT>' )
		else
			let [ text, placement, indentation ] = call ( 's:PrepareTemplate', [ a:t_name, '<CURSOR>', '<SPLIT>' ] + options )
		endif
		"
		if placement == 'help'
			" job already done, TODO: review this
		else
			"
			if ! empty ( s:t_runtime.placement )
				let placement = s:t_runtime.placement
			endif
			"
			" insert the text into the buffer
			let [ pos1, pos2 ] = s:InsertIntoBuffer ( text, placement, indentation, flag_mode )
			"
			" position the cursor
			call s:PositionCursor ( placement, flag_mode, pos1, pos2 )
			"
			" highlight jump targets
			call s:HighlightJumpTargets ( regex.JumpTagBoth )
		endif
		"
	catch /Template:UserInputAborted/
		" noop
	catch /Template:Check:.*/
		"
		let templ = s:t_runtime.obj_stack[ -1 ]
		let msg   = v:exception[ len( 'Template:Check:') : -1 ]
		call s:ErrorMsg ( 'Checking "'.templ.'":', msg )
		"
	catch /Template:Prepare:.*/
		"
		let templ = s:t_runtime.obj_stack[ -1 ]
		let incld = len ( s:t_runtime.obj_stack ) == 1 ? '' : '(included by: "'.s:t_runtime.obj_stack[ -2 ].'")'
		let msg   = v:exception[ len( 'Template:Prepare:') : -1 ]
		call s:ErrorMsg ( 'Preparing "'.templ.'":', incld, msg )
		"
	catch /Template:Recursion/
		"
		let templ = s:t_runtime.obj_stack[ -1 ]
		let idx1  = index ( s:t_runtime.obj_stack, templ )
		let cont  = idx1 == 0 ? [] : [ '...' ]
		call call ( 's:ErrorMsg', [ 'Recursion detected while including the template/s:' ] + cont +
					\ s:t_runtime.obj_stack[ idx1 : -1 ] )
		"
	catch /Template:MacroRecursion/
		"
		let macro = s:t_runtime.macro_stack[ -1 ]
		let idx1  = index ( s:t_runtime.macro_stack, macro )
		let cont  = idx1 == 0 ? [] : [ '...' ]
		call call ( 's:ErrorMsg', [ 'Recursion detected while replacing the macro/s:' ] + cont +
					\ s:t_runtime.macro_stack[ idx1 : -1 ] )
		"
	catch /Template:Insert:.*/
		"
		let msg   = v:exception[ len( 'Template:Insert:') : -1 ]
		call s:ErrorMsg ( 'Inserting "'.a:t_name.'":', msg )
		"
	catch /Template:.*/
		"
		let msg = v:exception[ len( 'Template:') : -1 ]
		call s:ErrorMsg ( msg )
		"
	finally
		"
		" ==================================================
		"  wrap up
		" ==================================================
		"
		" restore the state: folding and formatter program
		if &foldenable
			exe "set foldmethod=".foldmethod_save
			normal! zv
		endif
		let &equalprg = equalprg_save
		"
		unlet s:library                             " remove script variables
		unlet s:t_runtime                           " ...
		"
		let s:DebugLevel = s:DebugGlobalOverwrite   " reset debug
		"
	endtry
	"
endfunction    " ----------  end of function mmtemplates#core#InsertTemplate  ----------
"
"----------------------------------------------------------------------
" mmtemplates#core#CreateMaps : Create maps for a template library.   {{{1
"----------------------------------------------------------------------
"
function! mmtemplates#core#CreateMaps ( library, localleader, ... )
	"
	" ==================================================
	"  parameters
	" ==================================================
	"
	if type( a:library ) == type( '' )
		exe 'let t_lib = '.a:library
	else
		return s:ErrorMsg ( 'Argument "library" must be given as a string.' )
	endif
	"
	if type( a:localleader ) != type( '' )
		call s:ErrorMsg ( 'Argument "localleader" must be given as a string.' )
		return
	elseif ! empty ( a:localleader )
		if exists ( 'g:maplocalleader' )
			let ll_save = g:maplocalleader
		endif
		let g:maplocalleader = a:localleader
	endif
	"
	" ==================================================
	"  reuse previous commands
	" ==================================================
	"
	if has_key ( t_lib, 'map_commands' )
		"let TimeStart = reltime()
		exe t_lib.map_commands
		if ! empty ( a:localleader )
			if exists ( 'll_save' )
				let g:maplocalleader = ll_save
			else
				unlet g:maplocalleader
			endif
		endif
		"echo 'Executing maps: '.reltimestr( reltime( TimeStart ) )
		return
	endif
	"
	" ==================================================
	"  setup
	" ==================================================
	"
	" options
	let options = '<buffer> <silent>'
	let leader  = '<LocalLeader>'
	let sep     = "\n"
	"
	let do_jump_map     = 0
	let do_special_maps = 0
	"
	let cmd     = ''
	"
	" ==================================================
	"  options
	" ==================================================
	"
	let i = 1
	while i <= a:0
		"
		if a:[i] == 'do_jump_map'
			let do_jump_map = 1
			let i += 1
		elseif a:[i] == 'do_special_maps'
			let do_special_maps = 1
			let i += 1
		else
			if type ( a:[i] ) == type ( '' ) | call s:ErrorMsg ( 'Unknown option: "'.a:[i].'"' )
			else                             | call s:ErrorMsg ( 'Unknown option at position '.i.'.' ) | endif
			let i += 1
		endif
		"
	endwhile
	"
	"let TimeStart = reltime()
	"
	" ==================================================
	"  generate new commands
	" ==================================================
	"
	if has_key ( g:CheckedFiletypes, &filetype )
		let echo_warning = 0
	else
		let g:CheckedFiletypes[ &filetype ] = 1
		let echo_warning = g:Templates_MapInUseWarn != 0
	endif
	"
	" go through all the templates
	for t_name in t_lib.menu_order
		"
		exe 'let [ visual, mp ] = ['.t_lib.templates[ t_name.'!!menu' ].'][0:1]'
		"
		" no map?
		" separators have an empty string "map", so they are skipped here
		if empty ( mp )
			continue
		endif
		"
		for mode in [ 'n', 'v', 'i' ]
			"
			" map already existing?
			if ! empty ( maparg( leader.mp, mode ) )
				if echo_warning
					call s:ErrorMsg ( 'Mapping already in use: "'.leader.mp.'", mode "'.mode.'"' )
				endif
				continue
			endif
			"
			" insert and visual mode: insert '<Esc>'
			if mode == 'n' | let esc = ''
			else           | let esc = '<Esc>' | endif
			"
			" insert mode, flag 'i':
			" change behavior of templates with placement 'insert'
			" visual mode, flag 'v':
			" template contains a split tag, or the mode is forced
			if     mode == 'i'                | let flag = ',"i"'
			elseif mode == 'v' && visual == 1 | let flag = ',"v"'
			else                              | let flag = ''     | endif
			"
			" assemble the command to create the maps
			let cmd .= mode.'noremap '.options.' '.leader.mp.' '.esc.':call mmtemplates#core#InsertTemplate('.a:library.',"'.t_name.'"'.flag.')<CR>'.sep
		endfor
		"
	endfor
	"
	" jump map
	if do_jump_map
		let jump_key = '<C-j>'   " TODO: configurable
		if ! empty ( maparg( jump_key ) )
			if echo_warning
				call s:ErrorMsg ( 'Mapping already in use: "'.jump_key.'"' )
			endif
		else
			let jump_regex = string ( escape ( t_lib.regex_template.JumpTagBoth, '|' ) )
			let cmd .= 'nnoremap '.options.' '.jump_key.' i<C-R>=mmtemplates#core#JumpToTag('.jump_regex.')<CR>'.sep
			let cmd .= 'inoremap '.options.' '.jump_key.'  <C-R>=mmtemplates#core#JumpToTag('.jump_regex.')<CR>'.sep
		endif
	endif
	"
	" special maps
	" TODO: configuration of maps
	" TODO: edit template
	if do_special_maps
		let special_maps = {
					\ t_lib.properties[ 'Templates::EditTemplates::Map'   ] : ':call mmtemplates#core#EditTemplateFiles('.a:library.',-1)<CR>',
					\ t_lib.properties[ 'Templates::RereadTemplates::Map' ] : ':call mmtemplates#core#ReadTemplates('.a:library.',"reload","all")<CR>',
					\ t_lib.properties[ 'Templates::ChooseStyle::Map'     ] : ':call mmtemplates#core#ChooseStyle('.a:library.',"!pick")<CR>',
					\ }
		"
		for [ mp, action ] in items ( special_maps )
			if ! empty ( maparg( leader.mp ) )
				if echo_warning
					call s:ErrorMsg ( 'Mapping already in use: "'.leader.mp.'"' )
				endif
			else
				let cmd .= ' noremap '.options.' '.leader.mp.'      '.action.sep
				let cmd .= 'inoremap '.options.' '.leader.mp.' <Esc>'.action.sep
			endif
		endfor
	endif
	"
	let t_lib.map_commands = cmd
	exe cmd
	"
	" ==================================================
	"  wrap up
	" ==================================================
	"
	if ! empty ( a:localleader )
		if exists ( 'll_save' )
			let g:maplocalleader = ll_save
		else
			unlet g:maplocalleader
		endif
	endif
	"
	"echo 'Generating maps: '.reltimestr( reltime( TimeStart ) )
	"
endfunction    " ----------  end of function mmtemplates#core#CreateMaps  ----------
"
"----------------------------------------------------------------------
" === Create Menus: Auxiliary Functions ===   {{{1
"----------------------------------------------------------------------
"
"----------------------------------------------------------------------
" s:InsertShortcut : Insert a shortcut into a menu entry.   {{{2
"
" Inserts the shortcut by prefixing the appropriate character with '&',
" or by appending " (<shortcut>)". If escaped is true, the appended string is
" correctly escaped.
"----------------------------------------------------------------------
"
function! s:InsertShortcut ( entry, shortcut, escaped )
	if empty ( a:shortcut )
		return a:entry
	else
		let entry = a:entry
		let sc    = a:shortcut
		if stridx ( tolower( entry ), tolower( sc ) ) == -1
			if a:escaped | return entry.'\ (&'.sc.')'
			else         | return entry.' (&'.sc.')'
			endif
		else
			return substitute( entry, '\V\c'.sc, '\&&', '' )
		endif
	endif
endfunction    " ----------  end of function s:InsertShortcut  ----------
"
"----------------------------------------------------------------------
" s:CreateSubmenu : Create sub-menus, given they do not already exists.   {{{2
"
" The menu 'menu' can contain '&' and a trailing '.'. Both are ignored.
"----------------------------------------------------------------------
"
function! s:CreateSubmenu ( t_lib, root_menu, global_name, menu, priority )
	"
	" split point:
	" a point, preceded by an even number of backslashes
	" in turn, the backslashes must be preceded by a different character, or the
	" beginning of the string
	let level    = len( split( a:root_menu, '\%(\_^\|[^\\]\)\%(\\\\\)*\zs\.' ) )
	let parts    =      split( a:menu,      '\%(\_^\|[^\\]\)\%(\\\\\)*\zs\.' )
	let n_parts  = len( parts )
	let level   += n_parts
	"
	let priority_str = ''
	"
	" go through the menu, clean up and check for new menus
	let submenu = ''
	for i in range( 1, len( parts ) )
		"
		let part = parts[ i-1 ]
		"
		if i == n_parts
			let priority_str = repeat( '.', level-1 ).a:priority.'. '
		endif
		"
		let clean = substitute( part, '&', '', 'g' )
		if ! has_key ( a:t_lib.menu_existing, submenu.clean )
			" a new menu!
			let a:t_lib.menu_existing[ submenu.clean ] = 0
			"
			" shortcut and menu entry
			if has_key ( a:t_lib.menu_shortcuts, submenu.clean )
				let shortcut = a:t_lib.menu_shortcuts[ submenu.clean ]
				if stridx ( tolower( clean ), tolower( shortcut ) ) == -1
					let assemble = submenu.clean.' (&'.shortcut.')'
				else
					let assemble = submenu.substitute( clean, '\c'.shortcut, '\&&', '' )
				endif
			else
				let assemble = submenu.part
			endif
			"
			let assemble .= '.'
			"
			if -1 != stridx ( clean, '<TAB>' )
				exe 'anoremenu '.priority_str.a:root_menu.escape( assemble.clean, ' ' ).' :echo "This is a menu header."<CR>'
			else
				exe 'anoremenu '.priority_str.a:root_menu.escape( assemble.clean, ' ' ).'<TAB>'.escape( a:global_name, ' .' ).' :echo "This is a menu header."<CR>'
			endif
			exe 'anoremenu '.a:root_menu.escape( assemble,       ' ' ).'-TSep00- <Nop>'
		endif
		let submenu .= clean.'.'
	endfor
	"
endfunction    " ----------  end of function s:CreateSubmenu  ----------
"
"----------------------------------------------------------------------
" s:CreateTemplateMenus : Create menus for the templates.   {{{2
"----------------------------------------------------------------------
"
function! s:CreateTemplateMenus ( t_lib, root_menu, global_name, t_lib_name )
	"
	let map_ldr = mmtemplates#core#EscapeMenu ( a:t_lib.properties[ 'Templates::Mapleader' ], 'right' )
	"
	" go through all the templates
	for t_name in a:t_lib.menu_order
		"
		exe 'let [ visual, mp, entry, _, shortcut ] = ['.a:t_lib.templates[ t_name.'!!menu' ].']'
		"
		" no menu entry?
		if entry == 0
			continue
		endif
		"
		" get the sub-menu and the entry
		let [ t_menu, t_last ] = matchlist ( t_name, '^\(.*\.\)\?\([^\.]\+\)$' )[1:2]
		"
		" menu does not exist?
		if ! empty ( t_menu ) && ! has_key ( a:t_lib.menu_existing, t_menu[ 0 : -2 ] )
			call s:CreateSubmenu ( a:t_lib, a:root_menu, a:global_name, t_menu[ 0 : -2 ], s:StandardPriority )
		endif
		"
		if entry == 11
			let m_key = t_menu[ 0 : -2 ]
			if empty ( m_key )
				let m_key = '!base'
			endif
			"
			let sep_nr = a:t_lib.menu_existing[ m_key ] + 1
			let a:t_lib.menu_existing[ m_key ] = sep_nr
			"
			exe 'anoremenu '.a:root_menu.escape( t_menu, ' ' ).'-TSep'.sep_nr.'- :'
			"
			continue
		endif
		"
		" shortcut and menu entry
		if ! empty ( shortcut )
			if stridx ( tolower( t_last ), tolower( shortcut ) ) == -1
				let t_last .= ' (&'.shortcut.')'
			else
				let t_last = substitute( t_last, '\c'.shortcut, '\&&', '' )
			endif
		endif
		"
		" assemble the entry, including the map, TODO: escape the map
		let compl_entry = escape( t_menu.t_last, ' ' )
		if empty ( mp )
			let map_entry = ''
		else
			let map_entry = '<TAB>'.map_ldr.mp
		end
		"
		if entry == 1
			" <Esc><Esc> prevents problems in insert mode
			exe 'anoremenu <silent> '.a:root_menu.compl_entry.map_entry.' <Esc><Esc>:call mmtemplates#core#InsertTemplate('.a:t_lib_name.',"'.t_name.'")<CR>'
			exe 'inoremenu <silent> '.a:root_menu.compl_entry.map_entry.' <Esc><Esc>:call mmtemplates#core#InsertTemplate('.a:t_lib_name.',"'.t_name.'","i")<CR>'
			if visual == 1
				exe 'vnoremenu <silent> '.a:root_menu.compl_entry.map_entry.' <Esc><Esc>:call mmtemplates#core#InsertTemplate('.a:t_lib_name.',"'.t_name.'","v")<CR>'
			endif
		elseif entry == 2
			call s:CreateSubmenu ( a:t_lib, a:root_menu, a:global_name, t_menu.t_last.map_entry, s:StandardPriority )
			"
			for item in s:GetPickList ( t_name )
				let item_entry = compl_entry.'.'.substitute ( substitute ( escape ( item, ' .' ), '&', '\&\&', 'g' ), '\w', '\&&', '' )
				exe 'anoremenu <silent> '.a:root_menu.item_entry.' <Esc><Esc>:call mmtemplates#core#InsertTemplate('.a:t_lib_name.',"'.t_name.'","pick",'.string(item).')<CR>'
				exe 'inoremenu <silent> '.a:root_menu.item_entry.' <Esc><Esc>:call mmtemplates#core#InsertTemplate('.a:t_lib_name.',"'.t_name.'","i","pick",'.string(item).')<CR>'
				if visual == 1
					exe 'vnoremenu <silent> '.a:root_menu.item_entry.' <Esc><Esc>:call mmtemplates#core#InsertTemplate('.a:t_lib_name.',"'.t_name.'","v","pick",'.string(item).')<CR>'
				endif
			endfor
			"
"			exe 'anoremenu '.a:root_menu.compl_entry.'.-\ choose\ -'.map_entry.' <Esc><Esc>:call mmtemplates#core#InsertTemplate('.a:t_lib_name.',"'.t_name.'")<CR>'
"			if visual == 1
"				exe 'vnoremenu '.a:root_menu.compl_entry.'.-\ choose\ -'.map_entry.' <Esc><Esc>:call mmtemplates#core#InsertTemplate('.a:t_lib_name.',"'.t_name.'","v")<CR>'
"			endif
		endif
		"
	endfor
	"
endfunction    " ----------  end of function s:CreateTemplateMenus  ----------
"
"----------------------------------------------------------------------
" s:CreateSpecialsMenus : Create menus for a template library.   {{{2
"----------------------------------------------------------------------
"
function! s:CreateSpecialsMenus ( t_lib, root_menu, global_name, t_lib_name, specials_menu, styles_only )
	"
	" remove trailing point
	let specials_menu = substitute( a:specials_menu, '\.$', '', '' )
	"
	let map_ldr   = mmtemplates#core#EscapeMenu ( a:t_lib.properties[ 'Templates::Mapleader' ], 'right' )
	let map_edit  = map_ldr.mmtemplates#core#EscapeMenu ( a:t_lib.properties[ 'Templates::EditTemplates::Map' ], 'right' )
	let map_read  = map_ldr.mmtemplates#core#EscapeMenu ( a:t_lib.properties[ 'Templates::RereadTemplates::Map' ], 'right' )
	let map_style = map_ldr.mmtemplates#core#EscapeMenu ( a:t_lib.properties[ 'Templates::ChooseStyle::Map' ], 'right' )
	let sc_edit   = mmtemplates#core#EscapeMenu ( a:t_lib.properties[ 'Templates::EditTemplates::Shortcut' ], 'right' )
	let sc_read   = mmtemplates#core#EscapeMenu ( a:t_lib.properties[ 'Templates::RereadTemplates::Shortcut' ], 'right' )
	let sc_style  = mmtemplates#core#EscapeMenu ( a:t_lib.properties[ 'Templates::ChooseStyle::Shortcut' ], 'right' )
	"
	" create the specials menu
	call s:CreateSubmenu ( a:t_lib, a:root_menu, a:global_name, specials_menu, s:StandardPriority )
	"
	if ! a:styles_only
		" create edit and reread templates
		let entry_edit = s:InsertShortcut ( '.edit\ templates',   sc_edit, 1 ).'<TAB>'.map_edit
		let entry_read = s:InsertShortcut ( '.reread\ templates', sc_read, 1 ).'<TAB>'.map_read
		exe 'anoremenu <silent> '.a:root_menu.specials_menu.entry_edit
					\ .' :call mmtemplates#core#EditTemplateFiles('.a:t_lib_name.',-1)<CR>'
		exe 'anoremenu <silent> '.a:root_menu.specials_menu.entry_read
					\ .' :call mmtemplates#core#ReadTemplates('.a:t_lib_name.',"reload","all")<CR>'
	endif
	"
	" create a menu for all the styles
	if sc_style == 's' | let entry_styles = '.choose &style<TAB>'.map_style
	else               | let entry_styles = s:InsertShortcut ( '.choose style', sc_style, 0 ).'<TAB>'.map_style
	endif
	call s:CreateSubmenu ( a:t_lib, a:root_menu, a:global_name, specials_menu.entry_styles, s:StandardPriority )
	"
	for s in a:t_lib.styles
		exe 'anoremenu <silent> '.a:root_menu.specials_menu.'.choose\ style.&'.s
					\ .' :call mmtemplates#core#ChooseStyle('.a:t_lib_name.','.string(s).')<CR>'
	endfor
	"
endfunction    " ----------  end of function s:CreateSpecialsMenus  ----------
"
"----------------------------------------------------------------------
" mmtemplates#core#CreateMenus : Create menus for a template library.   {{{1
"----------------------------------------------------------------------
"
function! mmtemplates#core#CreateMenus ( library, root_menu, ... )
	"
	" check for feature
	if ! has ( 'menu' )
		return
	endif
	"
	" ==================================================
	"  parameters
	" ==================================================
	"
	if type( a:library ) == type( '' )
		exe 'let t_lib = '.a:library
		let s:library = t_lib
	else
		call s:ErrorMsg ( 'Argument "library" must be given as a string.' )
		return
	endif
	"
	if type( a:root_menu ) != type( '' )
		call s:ErrorMsg ( 'Argument "root_menu" must be given as a string.' )
		return
	endif
	"
	" ==================================================
	"  setup
	" ==================================================
	"
	" options
	let root_menu     = substitute( a:root_menu, '&',   '', 'g' )
	let global_name   = substitute(   root_menu, '\.$', '', ''  )
	let root_menu     = global_name.'.'
	let specials_menu = '&Run'
	let priority      = s:StandardPriority
	let existing      = []
	"
	" jobs
	let do_reset     = 0
	let do_templates = 0
	let do_specials  = 0   " no specials
	let submenus     = []
	"
	" ==================================================
	"  options
	" ==================================================
	"
	let i = 1
	while i <= a:0
		"
		if a:[i] == 'global_name' && i+1 <= a:0
			let global_name = a:[i+1]
			let i += 2
		elseif a:[i] == 'existing_menu' && i+1 <= a:0
			if type ( a:[i+1] ) == type ( '' ) | call add    ( existing, a:[i+1] )
			else                               | call extend ( existing, a:[i+1] ) | endif
			let i += 2
		elseif a:[i] == 'sub_menu' && i+1 <= a:0
			if type ( a:[i+1] ) == type ( '' ) | call add    ( submenus, a:[i+1] )
			else                               | call extend ( submenus, a:[i+1] ) | endif
			let i += 2
		elseif a:[i] == 'specials_menu' && i+1 <= a:0
			let specials_menu = a:[i+1]
			let i += 2
		elseif a:[i] == 'priority' && i+1 <= a:0
			let priority = a:[i+1]
			let i += 2
		elseif a:[i] == 'do_all'
			let do_reset     = 1
			let do_templates = 1
			let do_specials  = 1
			let i += 1
		elseif a:[i] == 'do_reset'
			let do_reset     = 1
			let i += 1
		elseif a:[i] == 'do_templates'
			let do_templates = 1
			let i += 1
		elseif a:[i] == 'do_specials'
			let do_specials   = 1
			let i += 1
		elseif a:[i] == 'do_styles'
			let do_specials   = 2
			let i += 1
		else
			if type ( a:[i] ) == type ( '' ) | call s:ErrorMsg ( 'Unknown option: "'.a:[i].'"' )
			else                             | call s:ErrorMsg ( 'Unknown option at position '.i.'.' ) | endif
			let i += 1
		endif
		"
	endwhile
	"
	" ==================================================
	"  do the jobs
	" ==================================================
	"
	" reset
	if do_reset
		let t_lib.menu_existing = { '!base' : 0 }
	endif
	"
	" existing menus
	for name in existing
		let name = substitute( name, '&', '', 'g' )
		let name = substitute( name, '\.$', '', '' )
		let t_lib.menu_existing[ name ] = 0
	endfor
	"
	" sub-menus
	for name in submenus
		call s:CreateSubmenu ( t_lib, root_menu, global_name, name, priority )
	endfor
	"
	" templates
	if do_templates
		call s:CreateTemplateMenus ( t_lib, root_menu, global_name, a:library )
	endif
	"
	" specials
	if do_specials == 1
		" all specials
		call s:CreateSpecialsMenus ( t_lib, root_menu, global_name, a:library, specials_menu, 0 )
	elseif do_specials == 2
		" styles only
		call s:CreateSpecialsMenus ( t_lib, root_menu, global_name, a:library, specials_menu, 1 )
	endif
	"
	" ==================================================
	"  wrap up
	" ==================================================
	"
	unlet s:library                               " remove script variable
	"
endfunction    " ----------  end of function mmtemplates#core#CreateMenus  ----------
"
"----------------------------------------------------------------------
" mmtemplates#core#EscapeMenu : Escape a string so it can be used as a menu item.   {{{1
"----------------------------------------------------------------------
"
function! mmtemplates#core#EscapeMenu ( str, ... )
	"
	let mode = 'entry'
	"
	if a:0 > 0
		if type( a:1 ) != type( '' )
			return s:ErrorMsg ( 'Argument "mode" must be given as a string.' )
		elseif a:1 == 'menu'
			let mode = 'menu'
		elseif a:1 == 'entry'
			let mode = 'entry'
		elseif a:1 == 'right'
			let mode = 'right'
		else
			return s:ErrorMsg ( 'Unknown mode: '.a:1 )
		endif
	endif
	"
	" whole menu: do not escape '.'
	if mode == 'menu'
		let str = escape ( a:str, ' \|' )
	else
		let str = escape ( a:str, ' \|.' )
	endif
	"
	" right-aligned text: do not escape '&'
	if mode != 'right'
		let str = substitute (   str, '&', '\&\&', 'g' )
	endif
	"
	return str
	"
endfunction    " ----------  end of function mmtemplates#core#EscapeMenu  ----------
"
"----------------------------------------------------------------------
" mmtemplates#core#ChooseStyle : Choose a style.   {{{1
"----------------------------------------------------------------------
"
function! mmtemplates#core#ChooseStyle ( library, style )
	"
	" ==================================================
	"  parameters
	" ==================================================
	"
	if type( a:library ) == type( '' )
		exe 'let t_lib = '.a:library
	elseif type( a:library ) == type( {} )
		let t_lib = a:library
	else
		call s:ErrorMsg ( 'Argument "library" must be given as a dict or string.' )
		return
	endif
	"
	if type( a:style ) != type( '' )
		call s:ErrorMsg ( 'Argument "style" must be given as a string.' )
		return
	endif
	"
	" ==================================================
	"  change the style
	" ==================================================
	"
	" pick the style
	if a:style == '!pick'
		try
			let style = s:UserInput( 'Style (currently '.t_lib.current_style.') : ', '', 
						\ 'customlist', t_lib.styles )
		catch /Template:UserInputAborted/
			return
		endtry
	else
		let style = a:style
	endif
	"
	" check and set the new style
	if style == ''
		" noop
	elseif -1 != index ( t_lib.styles, style )
		if t_lib.current_style != style
			let t_lib.current_style = style
			echo 'Changed style to "'.style.'".'
		elseif a:style == '!pick'
			echo 'Style stayed "'.style.'".'
		endif
	else
		call s:ErrorMsg ( 'Style was not changed. Style "'.style.'" is not available.' )
	end
	"
endfunction    " ----------  end of function mmtemplates#core#ChooseStyle  ----------
"
"----------------------------------------------------------------------
" mmtemplates#core#Resource : Access to various resources.   {{{1
"----------------------------------------------------------------------
"
function! mmtemplates#core#Resource ( library, mode, ... )
	"
	" TODO mode 'special' for |DATE|, |TIME| and |year|
	"
	" ==================================================
	"  parameters
	" ==================================================
	"
	if type( a:library ) == type( '' )
		exe 'let t_lib = '.a:library
	elseif type( a:library ) == type( {} )
		let t_lib = a:library
	else
		return [ '', 'Argument "library" must be given as a dict or string.' ]
	endif
	"
	if type( a:mode ) != type( '' )
		return [ '', 'Argument "mode" must be given as a string.' ]
	endif
	"
	" ==================================================
	"  special inquiries
	" ==================================================
	"
	if a:mode == 'add' || a:mode == 'get' || a:mode == 'set'
		" continue below
	elseif a:mode == 'escaped_mapleader'
		return [ mmtemplates#core#EscapeMenu( t_lib.properties[ 'Templates::Mapleader' ], 'right' ), '' ]
	elseif a:mode == 'jumptag'
		return [ t_lib.regex_template.JumpTagBoth, '' ]
	elseif a:mode == 'style'
		return [ t_lib.current_style, '' ]
	else
		return [ '', 'Mode "'.a:mode.'" is unknown.' ]
	endif
	"
	" ==================================================
	"  options
	" ==================================================
	"
	" type of 'resource'
	let types = { 'list' : '[ld]', 'macro' : 's', 'path' : 's', 'property' : 's' }
	"
	if a:mode == 'add' && a:0 != 3
		return [ '', 'Mode "add" requires three additional arguments.' ]
	elseif a:mode == 'get' && a:0 != 2
		return [ '', 'Mode "get" requires two additional arguments.' ]
	elseif a:mode == 'set' && a:0 != 3
		return [ '', 'Mode "set" requires three additional arguments.' ]
	elseif type( a:1 ) != type( '' )
		return [ '', 'Argument "resource" must be given as a string.' ]
	elseif type( a:2 ) != type( '' )
		return [ '', 'Argument "key" must be given as a string.' ]
	elseif ! has_key ( types, a:1 )
		return [ '', 'Resource "'.a:1.'" does not exist.' ]
	elseif a:mode == 'add' && a:1 != 'property'
		return [ '', 'Can not execute add for resource of type "'.a:1.'".' ]
	endif
	"
	" ==================================================
	"  add, get or set
	" ==================================================
	"
	let resource = a:1
	let key      = a:2
	"
	if a:mode == 'add'
		"
		let value = a:3
		"
		" add (property only)
		if type( value ) != type( '' )
			return [ '', 'Argument "value" must be given as a string.' ]
		else
			let t_lib.properties[ key ] = value
			return [ '', '' ]
		endif
		"
		return [ '', '' ]
	elseif a:mode == 'get'
		"
		" get
		if resource == 'list'
			return [ get( t_lib.resources, 'list!'.key ), '' ]
		elseif resource == 'macro'
			return [ get( t_lib.macros, key ), '' ]
		elseif resource == 'path'
			return [ get( t_lib.resources, 'path!'.key ), '' ]
		elseif resource == 'property'
			if has_key ( t_lib.properties, key )
				return [ t_lib.properties[ key ], '' ]
			else
				return [ '', 'Property "'.key.'" does not exist.' ]
			endif
		endif
		"
	elseif a:mode == 'set'
		"
		let value = a:3
		"
		" check type and set
		if s:TypeNames[ type( value ) ] !~ types[ resource ]
			return [ '', 'Argument "value" has the wrong type.' ]
		elseif resource == 'list'
			let t_lib.resources[ 'list!'.key ] = value
		elseif resource == 'macro'
			let t_lib.macros[ key ] = value
		elseif resource == 'path'
			let t_lib.resources[ 'path!'.key ] = value
		elseif resource == 'property'
			if has_key ( t_lib.properties, key )
				let t_lib.properties[ key ] = value
				return [ '', '' ]
			else
				return [ '', 'Property "'.key.'" does not exist.' ]
			endif
		endif
		"
		return [ '', '' ]
	endif
	"
endfunction    " ----------  end of function mmtemplates#core#Resource  ----------
"
"----------------------------------------------------------------------
" mmtemplates#core#ChangeSyntax : Change the syntax of the templates.   {{{1
"-------------------------------------------------------------------------------
"
function! mmtemplates#core#ChangeSyntax ( library, category, ... )
	"
	" ==================================================
	"  parameters
	" ==================================================
	"
	if type( a:library ) == type( '' )
		exe 'let t_lib = '.a:library
	elseif type( a:library ) == type( {} )
		let t_lib = a:library
	else
		return s:ErrorMsg ( 'Argument "library" must be given as a dict or string.' )
	endif
	"
	if type( a:category ) != type( '' )
		return s:ErrorMsg ( 'Argument "category" must be given as an integer or string.' )
	endif
	"
	" ==================================================
	"  set the syntax
	" ==================================================
	"
	if a:category == 'comment'
		"
		if a:0 < 1
			return s:ErrorMsg ( 'Not enough arguments for '.a:category.'.' )
		elseif a:0 == 1
			let t_lib.regex_settings.CommentStart = a:1
			let t_lib.regex_settings.CommentHint  = a:1[0]
		elseif a:0 == 2
			let t_lib.regex_settings.CommentStart = a:1
			let t_lib.regex_settings.CommentHint  = a:2[0]
		endif
		"
		call s:UpdateFileReadRegex ( t_lib.regex_file, t_lib.regex_settings )
		"
	else
		return s:ErrorMsg ( 'Unknown category: '.a:category )
	endif
	"
endfunction    " ----------  end of function mmtemplates#core#ChangeSyntax  ----------
"
"-------------------------------------------------------------------------------
" mmtemplates#core#ExpandText : Expand the macros in a text.   {{{1
"----------------------------------------------------------------------
"
function! mmtemplates#core#ExpandText ( library, text )
	"
	" ==================================================
	"  parameters
	" ==================================================
	"
	if type( a:library ) == type( '' )
		exe 'let t_lib = '.a:library
	elseif type( a:library ) == type( {} )
		let t_lib = a:library
	else
		return s:ErrorMsg ( 'Argument "library" must be given as a dict or string.' )
	endif
	"
	if type( a:text ) != type( '' )
		return s:ErrorMsg ( 'Argument "text" must be given as a string.' )
	endif
	"
	" ==================================================
	"  setup
	" ==================================================
	"
	" library and runtime information
	let s:library = t_lib
	let s:t_runtime = {
				\ 'macro_stack' : [],
				\ }
	"
	" renew the predefined macros
	let m_local = {}
	let m_local[ 'BASENAME' ] = expand( '%:t:r' )
	let m_local[ 'FILENAME' ] = expand( '%:t'   )
	let m_local[ 'PATH'     ] = expand( '%:p:h' )
	let m_local[ 'SUFFIX'   ] = expand( '%:e'   )
	"
	let m_local[ 'DATE' ]     = strftime( t_lib.macros[ 'DATE' ] )
	let m_local[ 'TIME' ]     = strftime( t_lib.macros[ 'TIME' ] )
	let m_local[ 'YEAR' ]     = strftime( t_lib.macros[ 'YEAR' ] )
	"
	" ==================================================
	"  do the job
	" ==================================================
	"
	let res = ''
	"
	try
		"
		let res = s:ReplaceMacros ( a:text, m_local )
		"
	catch /Template:MacroRecursion/
		"
		let macro = s:t_runtime.macro_stack[ -1 ]
		let idx1  = index ( s:t_runtime.macro_stack, macro )
		let cont  = idx1 == 0 ? [] : [ '...' ]
		call call ( 's:ErrorMsg', [ 'Recursion detected while replacing the macro/s:' ] + cont +
					\ s:t_runtime.macro_stack[ idx1 : -1 ] )
		"
	catch /Template:.*/
		"
		let msg = v:exception[ len( 'Template:') : -1 ]
		call s:ErrorMsg ( msg )
		"
	finally
		"
		" ==================================================
		"  wrap up
		" ==================================================
		"
		unlet s:library                             " remove script variables
		unlet s:t_runtime                           " ...
		"
	endtry
	"
	return res
	"
endfunction    " ----------  end of function mmtemplates#core#ExpandText  ----------
"
"-------------------------------------------------------------------------------
" mmtemplates#core#EditTemplateFiles : Choose and edit a template file.   {{{1
"-------------------------------------------------------------------------------
"
function! mmtemplates#core#EditTemplateFiles ( library, file )
	"
	" ==================================================
	"  parameters
	" ==================================================
	"
	if type( a:library ) == type( '' )
		exe 'let t_lib = '.a:library
	elseif type( a:library ) == type( {} )
		let t_lib = a:library
	else
		return s:ErrorMsg ( 'Argument "library" must be given as a dict or string.' )
	endif
	"
	if type( a:file ) == type( 0 )
		if get( t_lib.library_files, a:file, '' ) == ''
			return s:ErrorMsg ( 'No template file with index '.a:file.'.' )
		endif
		let file = t_lib.library_files[ a:file ]
	elseif type( a:file ) == type( '' )
		"
		let file = expand ( a:file )
		let file = s:ConcatNormalizedFilename ( file )
		"
		if ! filereadable ( file )
			return s:ErrorMsg ( 'The file "'.file.'" does not exist.' )
		elseif index ( t_lib.library_files, file ) == -1
			return s:ErrorMsg ( 'The file "'.file.'" is not part of the template library.' )
		endif
		"
	else
		return s:ErrorMsg ( 'Argument "file" must be given as an integer or string.' )
	endif
	"
	" ==================================================
	"  do the job
	" ==================================================
	"
	" get the directory
	let dir = fnamemodify ( file, ':h' )
	"
	" TODO: method configurable
	let method = 'explore'
	let	templatefile = ''
	"
	if ! filereadable ( file )
		return s:ErrorMsg ( 'The directory "'.dir.'" does not exist.' )
	elseif method == 'explore'
		" open a file explorer
		if ! exists ( 'g:loaded_netrwPlugin' ) | return s:ErrorMsg ( 'The plugin "netrw" is not available.' ) | endif
		exe 'update! | split | Explore '.dir
	elseif method == 'browse'
		" open a file browser
		if ! has ( 'browse' ) | return s:ErrorMsg ( 'The command "browse" is not available.' ) | endif
		let	templatefile = browse ( 0, 'edit a template file', dir, '' )
		" returns an empty string if "Cancel" is pressed
	endif
	"
	" open a buffer and start editing
	if ! empty ( templatefile )
		exe 'update! | split | edit '.templatefile
	endif
	"
endfunction    " ----------  end of function mmtemplates#core#EditTemplateFiles  ----------
"
"----------------------------------------------------------------------
" mmtemplates#core#JumpToTag : Jump to the next tag.   {{{1
"----------------------------------------------------------------------
"
function! mmtemplates#core#JumpToTag ( regex )
	"
	let match	= search( '\m'.a:regex, 'c' )
	if match > 0
		" remove the target
		call setline( match, substitute( getline('.'), a:regex, '', '' ) )
	endif
	"
	return ''
endfunction    " ----------  end of function mmtemplates#core#JumpToTag  ----------
"
"----------------------------------------------------------------------
" mmtemplates#core#SetMapleader : Set the local mapleader.   {{{1
"----------------------------------------------------------------------
"
" list of lists: [ "<localleader>", "<globalleader>" ]
let s:mapleader_stack = []
"
function! mmtemplates#core#SetMapleader ( localleader )
	"
	if empty ( a:localleader )
		call add ( s:mapleader_stack, [] )
	else
		if exists ( 'g:maplocalleader' )
			call add ( s:mapleader_stack, [ a:localleader, g:maplocalleader ] )
		else
			call add ( s:mapleader_stack, [ a:localleader ] )
		endif
		let g:maplocalleader = a:localleader
	endif
	"
endfunction    " ----------  end of function mmtemplates#core#SetMapleader  ----------
"
"----------------------------------------------------------------------
" mmtemplates#core#ResetMapleader : Reset the local mapleader.   {{{1
"----------------------------------------------------------------------
"
function! mmtemplates#core#ResetMapleader ()
	"
	let ll_save = remove ( s:mapleader_stack, -1 )
	"
	if ! empty ( ll_save )
		if len ( ll_save ) > 1
			let g:maplocalleader = ll_save[1]
		else
			unlet g:maplocalleader
		endif
	endif
	"
endfunction    " ----------  end of function mmtemplates#core#ResetMapleader  ----------
"
" }}}1
"
" =====================================================================================
"  vim: foldmethod=marker
