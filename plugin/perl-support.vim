"#################################################################################
"
"       Filename:  perl-support.vim
"
"    Description:  perl-support.vim implements a Perl-IDE for Vim/gVim.  It is
"                  written to considerably speed up writing code in a consistent
"                  style.
"                  This is done by inserting complete statements, comments,
"                  idioms, code snippets, templates, comments and POD
"                  documentation.  Reading perldoc is integrated.  Syntax
"                  checking, running a script, starting a debugger and a
"                  profiler can be done by a keystroke.
"                  There a many additional hints and options which can improve
"                  speed and comfort when writing Perl. Please read the
"                  documentation.
"
"  Configuration:  There are at least some personal details which should be 
"                   configured (see the files README.perlsupport and
"                   perlsupport.txt).
"
"   Dependencies:  perl           pod2man
"                  podchecker     pod2text
"                  pod2html       perldoc
"
"                  optional:
"
"                  ddd                  (debugger frontend)
"                  Devel::ptkdb         (debugger frontend)
"                  Devel::SmallProf     (profiler)
"                  Devel::FastProf      (profiler)
"                  Devel::NYTProf       (profiler)
"                  sort(1)              (rearrange profiler statistics)
"                  Perl::Critic         (stylechecker)
"                  Perl::Tags           (generate Ctags style tags)
"                  Perl::Tidy           (beautifier)
"                  Pod::Pdf             (Pod to Pdf conversion)
"                  YAPE::Regex::Explain (regular expression analyzer)
"
"         Author:  Dr.-Ing. Fritz Mehner <mehner@fh-swf.de>
"
"        Version:  see variable  g:Perl_Version  below
"        Created:  09.07.2001
"        License:  Copyright (c) 2001-2011, Fritz Mehner
"                  This program is free software; you can redistribute it
"                  and/or modify it under the terms of the GNU General Public
"                  License as published by the Free Software Foundation,
"                  version 2 of the License.
"                  This program is distributed in the hope that it will be
"                  useful, but WITHOUT ANY WARRANTY; without even the implied
"                  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
"                  PURPOSE.
"                  See the GNU General Public License version 2 for more details.
"        Credits:  see perlsupport.txt
"       Revision:  $Id: perl-support.vim,v 1.116 2011/04/21 07:33:24 mehner Exp $
"-------------------------------------------------------------------------------
"
" Prevent duplicate loading:
"
if exists("g:Perl_Version") || &compatible
  finish
endif
let g:Perl_Version= "4.11"
"
"#################################################################################
"
"  Global variables (with default values) which can be overridden.
"
"------------------------------------------------------------------------------
"  Define a global variable and assign a default value if nor already defined.
"------------------------------------------------------------------------------
function! Perl_SetGlobalVariable ( name, default )
  if !exists('g:'.a:name)
    exe 'let g:'.a:name."  = '".a:default."'"
  endif
endfunction   " ---------- end of function  Perl_SetGlobalVariable  ----------
"
"------------------------------------------------------------------------------
"  Assign a value to a local variable if a corresponding global variable
"  exists.
"------------------------------------------------------------------------------
function! Perl_SetLocalVariable ( name )
  if exists('g:'.a:name)
    exe 'let s:'.a:name.'  = g:'.a:name
  endif
endfunction   " ---------- end of function  Perl_SetLocalVariable  ----------
"
call Perl_SetGlobalVariable( "Perl_MenuHeader",'yes' )
call Perl_SetGlobalVariable( "Perl_OutputGvim",'vim' )
call Perl_SetGlobalVariable( "Perl_PerlRegexSubstitution",'$~' )
call Perl_SetGlobalVariable( "Perl_Root",'&Perl.' )
"
"------------------------------------------------------------------------------
"
" Platform specific items:
" - plugin directory
" - characters that must be escaped for filenames
"
let s:MSWIN = has("win16") || has("win32")   || has("win64")    || has("win95")
let s:UNIX	= has("unix")  || has("macunix") || has("win32unix")
"
let g:Perl_Installation				= 'local'
let s:vimfiles								= $VIM
let	s:sourced_script_file			= expand("<sfile>")
let s:Perl_GlobalTemplateFile	= ''
let s:Perl_GlobalTemplateDir	= ''
"
if  s:MSWIN
  " ==========  MS Windows  ======================================================
	"
	if match( s:sourced_script_file, escape( s:vimfiles, ' \' ) ) == 0
		" system wide installation
		let g:Perl_Installation				= 'system'
		let s:plugin_dir							= $VIM.'/vimfiles/'
		let s:Perl_GlobalTemplateDir	= s:plugin_dir.'perl-support/templates'
		let s:Perl_GlobalTemplateFile	= s:Perl_GlobalTemplateDir.'/Templates'
	else
		" user installation assumed
		let s:plugin_dir  						= $HOME.'/vimfiles/'
	endif
	"
	let s:Perl_LocalTemplateFile		= $HOME.'/vimfiles/perl-support/templates/Templates'
	let s:Perl_LocalTemplateDir			= fnamemodify( s:Perl_LocalTemplateFile, ":p:h" ).'/'
	let s:Perl_CodeSnippets  				= $HOME.'/vimfiles/perl-support/codesnippets/'
  let s:escfilename 	  					= ''
	let s:Perl_Display  						= ''
	"
else
  " ==========  Linux/Unix  ======================================================
	"
	if match( expand("<sfile>"), expand( "$HOME" ) ) == 0
		" user installation assumed
		let s:plugin_dir  						= $HOME.'/.vim/'
	else
		" system wide installation
		let g:Perl_Installation				= 'system'
		let s:plugin_dir  						= $VIM.'/vimfiles/'
		let s:Perl_GlobalTemplateDir	= s:plugin_dir.'perl-support/templates'
		let s:Perl_GlobalTemplateFile	= s:Perl_GlobalTemplateDir.'/Templates'
	endif
	"
	let s:Perl_LocalTemplateFile		= $HOME.'/.vim/perl-support/templates/Templates'
	let s:Perl_LocalTemplateDir			= fnamemodify( s:Perl_LocalTemplateFile, ":p:h" ).'/'
	let s:Perl_CodeSnippets  				= $HOME.'/.vim/perl-support/codesnippets/'
	let s:escfilename   						= ' \%#[]'
	let s:Perl_Display							= "$DISPLAY"
	"
  " ==============================================================================
endif
"
" g:Perl_CodeSnippets is used in autoload/perlsupportgui.vim
"
call Perl_SetGlobalVariable( 'Perl_CodeSnippets', s:Perl_CodeSnippets )
"
"
call Perl_SetGlobalVariable( 'Perl_PerlTags', 'enabled' )
"
"  Key word completion is enabled by the filetype plugin 'perl.vim'
"  g:Perl_Dictionary_File  must be global
"
if !exists("g:Perl_Dictionary_File")
  let g:Perl_Dictionary_File       = s:plugin_dir.'perl-support/wordlists/perl.list'
endif
"
"
"  Modul global variables (with default values) which can be overridden.     {{{1
"
let s:Perl_LoadMenus             = 'yes'
let s:Perl_TemplateOverwrittenMsg= 'yes'
let s:Perl_Ctrl_j								 = 'on'
"
let s:Perl_FormatDate						 = '%x'
let s:Perl_FormatTime						 = '%X'
let s:Perl_FormatYear						 = '%Y'
let s:Perl_TimestampFormat       = '%Y%m%d.%H%M%S'

let s:Perl_PerlModuleList        = s:plugin_dir.'perl-support/modules/perl-modules.list'
let s:Perl_XtermDefaults         = "-fa courier -fs 12 -geometry 80x24"
let s:Perl_Debugger              = "perl"
let s:Perl_ProfilerTimestamp     = "no"
let s:Perl_LineEndCommColDefault = 49
let s:Perl_PodcheckerWarnings    = "yes"
let s:Perl_PerlcriticOptions     = ""
let s:Perl_PerlcriticSeverity    = 3
let s:Perl_PerlcriticVerbosity   = 5
let s:Perl_Printheader           = "%<%f%h%m%<  %=%{strftime('%x %X')}     Page %N"
let s:Perl_GuiSnippetBrowser     = 'gui'										" gui / commandline
let s:Perl_GuiTemplateBrowser    = 'gui'										" gui / explorer / commandline
"
let s:Perl_Wrapper                 = s:plugin_dir.'perl-support/scripts/wrapper.sh'
let s:Perl_EfmPerl                 = s:plugin_dir.'perl-support/scripts/efm_perl.pl'
let s:Perl_PerlModuleListGenerator = s:plugin_dir.'perl-support/scripts/pmdesc3.pl'
"
"------------------------------------------------------------------------------
"
"  Look for global variables (if any), to override the defaults.
"
call Perl_SetLocalVariable('Perl_GuiSnippetBrowser      ')
call Perl_SetLocalVariable('Perl_GuiTemplateBrowser     ')
call Perl_SetLocalVariable("Perl_Ctrl_j                 ")
call Perl_SetLocalVariable("Perl_Debugger               ")
call Perl_SetLocalVariable("Perl_FormatDate             ")
call Perl_SetLocalVariable("Perl_FormatTime             ")
call Perl_SetLocalVariable("Perl_FormatYear             ")
call Perl_SetLocalVariable("Perl_TimestampFormat        ")
call Perl_SetLocalVariable("Perl_LineEndCommColDefault  ")
call Perl_SetLocalVariable("Perl_LoadMenus              ")
call Perl_SetLocalVariable("Perl_NYTProf_browser        ")
call Perl_SetLocalVariable("Perl_NYTProf_html           ")
call Perl_SetLocalVariable("Perl_PerlcriticOptions      ")
call Perl_SetLocalVariable("Perl_PerlcriticSeverity     ")
call Perl_SetLocalVariable("Perl_PerlcriticVerbosity    ")
call Perl_SetLocalVariable("Perl_PerlModuleList         ")
call Perl_SetLocalVariable("Perl_PerlModuleListGenerator")
call Perl_SetLocalVariable("Perl_PodcheckerWarnings     ")
call Perl_SetLocalVariable("Perl_Printheader            ")
call Perl_SetLocalVariable("Perl_ProfilerTimestamp      ")
call Perl_SetLocalVariable("Perl_TemplateOverwrittenMsg ")
call Perl_SetLocalVariable("Perl_XtermDefaults          ")
call Perl_SetLocalVariable("Perl_GlobalTemplateFile     ")

if exists('g:Perl_GlobalTemplateFile') && g:Perl_GlobalTemplateFile != ''
	let s:Perl_GlobalTemplateDir	= fnamemodify( s:Perl_GlobalTemplateFile, ":h" )
endif
"
"
" set default geometry if not specified
"
if match( s:Perl_XtermDefaults, "-geometry\\s\\+\\d\\+x\\d\\+" ) < 0
  let s:Perl_XtermDefaults  = s:Perl_XtermDefaults." -geometry 80x24"
endif
"
" Flags for perldoc
"
if has("gui_running")
  let s:Perl_perldoc_flags  = ""
else
  " Display docs using plain text converter.
  let s:Perl_perldoc_flags  = "-otext"
endif
"
" escape the printheader
"
let s:Perl_Printheader  		= escape( s:Perl_Printheader, ' %' )
let s:Perl_InterfaceVersion = ''
"
"------------------------------------------------------------------------------
"  Control variables (not user configurable)
"------------------------------------------------------------------------------
let s:InsertionAttribute       = { 'below':'', 'above':'', 'start':'', 'append':'', 'insert':'' }
let s:IndentAttribute          = { 'noindent':'', 'indent':'' }
let s:Perl_InsertionAttribute  = {}
let s:Perl_IndentAttribute     = {}
let s:Perl_ExpansionLimit      = 10
let s:Perl_FileVisited         = []
"
let s:Perl_MacroNameRegex        = '\([a-zA-Z][a-zA-Z0-9_]*\)'
let s:Perl_MacroLineRegex				 = '^\s*|'.s:Perl_MacroNameRegex.'|\s*=\s*\(.*\)'
let s:Perl_MacroCommentRegex		 = '^§'
let s:Perl_ExpansionRegex				 = '|?'.s:Perl_MacroNameRegex.'\(:\a\)\?|'
let s:Perl_NonExpansionRegex		 = '|'.s:Perl_MacroNameRegex.'\(:\a\)\?|'
"
let s:Perl_TemplateNameDelimiter = '-+_,\. '
"let s:Perl_TemplateLineRegex		 = '^==\s*\([a-zA-Z][0-9a-zA-Z'.s:Perl_TemplateNameDelimiter
"let s:Perl_TemplateLineRegex		.= ']\+\)\s*==\s*\([a-z]\+\s*==\)\?'
let s:Perl_TemplateLineRegex		 = '^==\s*\([a-zA-Z][0-9a-zA-Z'.s:Perl_TemplateNameDelimiter
let s:Perl_TemplateLineRegex		.= ']\+\)\s*==\(\s*[a-z]\+\s*==\)*'
let s:Perl_TemplateIf						 = '^==\s*IF\s\+|STYLE|\s\+IS\s\+'.s:Perl_MacroNameRegex.'\s*=='
let s:Perl_TemplateEndif				 = '^==\s*ENDIF\s*=='
"
let s:Perl_ExpansionCounter     = {}
let s:Perl_TJT									= '[ 0-9a-zA-Z_]*'
let s:Perl_TemplateJumpTarget1  = '<+'.s:Perl_TJT.'+>\|{+'.s:Perl_TJT.'+}'
let s:Perl_TemplateJumpTarget2  = '<-'.s:Perl_TJT.'->\|{-'.s:Perl_TJT.'-}'
let s:Perl_Template             = {}
let s:Perl_Macro                = {'|AUTHOR|'         : 'first name surname',
											\						 '|AUTHORREF|'      : '',
											\						 '|EMAIL|'          : '',
											\						 '|COMPANY|'        : '',
											\						 '|PROJECT|'        : '',
											\						 '|COPYRIGHTHOLDER|': '',
											\		 				 '|STYLE|'          : ''
											\						}
let	s:Perl_MacroFlag						= {	':l' : 'lowercase'			,
											\							':u' : 'uppercase'			,
											\							':c' : 'capitalize'		,
											\							':L' : 'legalize name'	,
											\						}

let s:MsgInsNotAvail	= "insertion not available for a fold"
"
"------------------------------------------------------------------------------
"-----   variables for internal use   -----------------------------------------
"------------------------------------------------------------------------------
"
"------------------------------------------------------------------------------
"  Input after a highlighted prompt     {{{1
"------------------------------------------------------------------------------
function! Perl_Input ( promp, text, ... )
	echohl Search																					" highlight prompt
	call inputsave()																			" preserve typeahead
	if a:0 == 0 || a:1 == ''
		let retval	=input( a:promp, a:text )
	else
		let retval	=input( a:promp, a:text, a:1 )
	endif
	call inputrestore()																		" restore typeahead
	echohl None																						" reset highlighting
	let retval  = substitute( retval, '^\s\+', "", "" )		" remove leading whitespaces
	let retval  = substitute( retval, '\s\+$', "", "" )		" remove trailing whitespaces
	return retval
endfunction    " ----------  end of function Perl_Input ----------
"
"------------------------------------------------------------------------------
"  Comments : get line-end comment position     {{{1
"------------------------------------------------------------------------------
function! Perl_GetLineEndCommCol ()
  let actcol  = virtcol(".")
  if actcol+1 == virtcol("$")
    let b:Perl_LineEndCommentColumn = ''
		while match( b:Perl_LineEndCommentColumn, '^\s*\d\+\s*$' ) < 0
			let b:Perl_LineEndCommentColumn = Perl_Input( 'start line-end comment at virtual column : ', actcol, '' )
		endwhile
  else
    let b:Perl_LineEndCommentColumn = virtcol(".")
  endif
  echomsg "line end comments will start at column  ".b:Perl_LineEndCommentColumn
endfunction   " ---------- end of function  Perl_GetLineEndCommCol  ----------
"
"------------------------------------------------------------------------------
"  Comments : single line-end comment     {{{1
"------------------------------------------------------------------------------
function! Perl_LineEndComment ( comment )
  if !exists("b:Perl_LineEndCommentColumn")
    let b:Perl_LineEndCommentColumn = s:Perl_LineEndCommColDefault
  endif
  " ----- trim whitespaces -----
	exe 's/\s*$//'
  let linelength= virtcol("$") - 1
	let	diff	= 1
	if linelength < b:Perl_LineEndCommentColumn
		let diff	= b:Perl_LineEndCommentColumn -1 -linelength
	endif
	exe "normal	".diff."A "
	call Perl_InsertTemplate('comment.end-of-line-comment')
endfunction   " ---------- end of function  Perl_LineEndComment  ----------
"
"------------------------------------------------------------------------------
"  Perl_AlignLineEndComm: adjust line-end comments     {{{1
"------------------------------------------------------------------------------
"
" patterns to ignore when adjusting line-end comments (incomplete):
" some heuristics used (only Perl can parse Perl)
let	s:AlignRegex	= [
	\	'\$#' ,
	\	'"[^"]\+"' ,
	\	"'[^']\\+'" ,
	\	"`[^`]\+`" ,
	\	'\(m\|qr\)#[^#]\+#' ,
	\	'\(m\|qr\)\?\([\?\/]\)\(.*\)\(\2\)\([imsxg]*\)'  ,
	\	'\(m\|qr\)\([[:punct:]]\)\(.*\)\(\2\)\([imsxg]*\)'  ,
	\	'\(m\|qr\){\(.*\)}\([imsxg]*\)'  ,
	\	'\(m\|qr\)(\(.*\))\([imsxg]*\)'  ,
	\	'\(m\|qr\)\[\(.*\)\]\([imsxg]*\)'  ,
	\	'\(s\|tr\)#[^#]\+#[^#]\+#' ,
	\	'\(s\|tr\){[^}]\+}{[^}]\+}' ,
	\	]

function! Perl_AlignLineEndComm ( mode ) range
	"
	if !exists("b:Perl_LineEndCommentColumn")
		let	b:Perl_LineEndCommentColumn	= s:Perl_LineEndCommColDefault
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
		"
		" line is not a pure comment but may contains a comment:
		"
		if match( line, '^\s*#' ) < 0 && match( line, '#.*$' ) > 0
      "
      " disregard comments starting in a string
      "
			let	idx1	      = -1
			let	idx2	      = -1
			let	commentstart= -2
			let	commentend	= 0
			while commentstart < idx2 && idx2 < commentend
				let start	      = commentend
				let idx2	      = match( line, '#.*$', start )
				" loop over the items to ignore
        for regex in s:AlignRegex
          if match( line, regex ) > -1
            let commentstart	= match   ( line, regex, start )
            let commentend		= matchend( line, regex, start )
            break
          endif
        endfor
			endwhile
      "
      " try to adjust the comment
      "
			let idx1	= 1 + match( line, '\s*#.*$', start )
			let idx2	= 1 + idx2
			call setpos(".", [ 0, linenumber, idx1, 0 ] )
			let vpos1	= virtcol(".")
			call setpos(".", [ 0, linenumber, idx2, 0 ] )
			let vpos2	= virtcol(".")

			if   ! (   vpos2 == b:Perl_LineEndCommentColumn
						\	|| vpos1 > b:Perl_LineEndCommentColumn
						\	|| idx2  == 0 )

				exe ":.,.retab"
				" insert some spaces
				if vpos2 < b:Perl_LineEndCommentColumn
					let	diff	= b:Perl_LineEndCommentColumn-vpos2
					call setpos(".", [ 0, linenumber, vpos2, 0 ] )
					let	@"	= ' '
					exe "normal	".diff."P"
				endif

				" remove some spaces
				if vpos1 < b:Perl_LineEndCommentColumn && vpos2 > b:Perl_LineEndCommentColumn
					let	diff	= vpos2 - b:Perl_LineEndCommentColumn
					call setpos(".", [ 0, linenumber, b:Perl_LineEndCommentColumn, 0 ] )
					exe "normal	".diff."x"
				endif

			endif
		endif
		let linenumber=linenumber+1
		normal j
	endwhile
	" restore tab expansion settings and cursor position
	let &expandtab	= save_expandtab
	call setpos('.', save_cursor)

endfunction		" ---------- end of function  Perl_AlignLineEndComm  ----------
"
"------------------------------------------------------------------------------
"  Comments : multi line-end comments     {{{1
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! Perl_MultiLineEndComments ( )
	"
  if !exists("b:Perl_LineEndCommentColumn")
		let	b:Perl_LineEndCommentColumn	= s:Perl_LineEndCommColDefault
  endif
	"
	let pos0	= line("'<")
	let pos1	= line("'>")
	"
	" ----- trim whitespaces -----
  exe pos0.','.pos1.'s/\s*$//'
	"
	" ----- find the longest line -----
	let maxlength	= max( map( range(pos0, pos1), "virtcol([v:val, '$'])" ) )
	let	maxlength	= max( [b:Perl_LineEndCommentColumn, maxlength+1] )
	"
	" ----- fill lines with blanks -----
	for linenumber in range( pos0, pos1 )
		exe ":".linenumber
		if getline(linenumber) !~ '^\s*$'
			let diff	= maxlength - virtcol("$")
			exe "normal	".diff."A "
			call Perl_InsertTemplate('comment.end-of-line-comment')
		endif
	endfor
	"
	" ----- back to the begin of the marked block -----
	stopinsert
	normal '<$
	if match( getline("."), '\/\/\s*$' ) < 0
		if search( '\/\*', 'bcW', line(".") ) > 1
			normal l
		endif
		let save_cursor = getpos(".")
		if getline(".")[save_cursor[2]+1] == ' '
			normal l
		endif
	else
		normal $
	endif
endfunction		" ---------- end of function  Perl_MultiLineEndComments  ----------
"
"------------------------------------------------------------------------------
"  Comments : comment block     {{{1
"------------------------------------------------------------------------------
"
let s:Perl_CmtCounter   = 0
let s:Perl_CmtLabel     = "BlockCommentNo_"
"
function! Perl_CommentBlock (mode)
  "
  let s:Perl_CmtCounter = 0
  let save_line         = line(".")
  let actual_line       = 0
  "
  " search for the maximum option number (if any)
  "
  normal gg
  while actual_line < search( s:Perl_CmtLabel."\\d\\+" )
    let actual_line = line(".")
    let actual_opt  = matchstr( getline(actual_line), s:Perl_CmtLabel."\\d\\+" )
    let actual_opt  = strpart( actual_opt, strlen(s:Perl_CmtLabel),strlen(actual_opt)-strlen(s:Perl_CmtLabel))
    if s:Perl_CmtCounter < actual_opt
      let s:Perl_CmtCounter = actual_opt
    endif
  endwhile
  let s:Perl_CmtCounter = s:Perl_CmtCounter+1
  silent exe ":".save_line
  "
  if a:mode=='a'
    let zz=      "\n=begin  BlockComment  # ".s:Perl_CmtLabel.s:Perl_CmtCounter
    let zz= zz."\n\n=end    BlockComment  # ".s:Perl_CmtLabel.s:Perl_CmtCounter
    let zz= zz."\n\n=cut\n\n"
    put =zz
  endif

  if a:mode=='v'
    let zz=    "\n=begin  BlockComment  # ".s:Perl_CmtLabel.s:Perl_CmtCounter."\n\n"
    :'<put! =zz
    let zz=    "\n=end    BlockComment  # ".s:Perl_CmtLabel.s:Perl_CmtCounter
    let zz= zz."\n\n=cut\n\n"
    :'>put  =zz
  endif

endfunction    " ----------  end of function Perl_CommentBlock ----------
"
"------------------------------------------------------------------------------
"  uncomment block     {{{1
"------------------------------------------------------------------------------
function! Perl_UncommentBlock ()

  let frstline  = searchpair( '^=begin\s\+BlockComment\s*#\s*'.s:Perl_CmtLabel.'\d\+',
      \                       '',
      \                       '^=end\s\+BlockComment\s\+#\s*'.s:Perl_CmtLabel.'\d\+',
      \                       'bn' )
  if frstline<=0
    echohl WarningMsg | echo 'no comment block/tag found or cursor not inside a comment block'| echohl None
    return
  endif
  let lastline  = searchpair( '^=begin\s\+BlockComment\s*#\s*'.s:Perl_CmtLabel.'\d\+',
      \                       '',
      \                       '^=end\s\+BlockComment\s\+#\s*'.s:Perl_CmtLabel.'\d\+',
      \                       'n' )
  if lastline<=0
    echohl WarningMsg | echo 'no comment block/tag found or cursor not inside a comment block'| echohl None
    return
  endif
  let actualnumber1  = matchstr( getline(frstline), s:Perl_CmtLabel."\\d\\+" )
  let actualnumber2  = matchstr( getline(lastline), s:Perl_CmtLabel."\\d\\+" )
  if actualnumber1 != actualnumber2
    echohl WarningMsg | echo 'lines '.frstline.', '.lastline.': comment tags do not match'| echohl None
    return
  endif

  let line1 = lastline
  let line2 = lastline
  " empty line before =end
  if match( getline(lastline-1), '^\s*$' ) != -1
    let line1 = line1-1
  endif
  if lastline+1<line("$") && match( getline(lastline+1), '^\s*$' ) != -1
    let line2 = line2+1
  endif
  if lastline+2<line("$") && match( getline(lastline+2), '^=cut' ) != -1
    let line2 = line2+1
  endif
  if lastline+3<line("$") && match( getline(lastline+3), '^\s*$' ) != -1
    let line2 = line2+1
  endif
  silent exe ':'.line1.','.line2.'d'

  let line1 = frstline
  let line2 = frstline
  if frstline>1 && match( getline(frstline-1), '^\s*$' ) != -1
    let line1 = line1-1
  endif
  if match( getline(frstline+1), '^\s*$' ) != -1
    let line2 = line2+1
  endif
  silent exe ':'.line1.','.line2.'d'

endfunction    " ----------  end of function Perl_UncommentBlock ----------
"
"------------------------------------------------------------------------------
"  toggle comments     {{{1
"------------------------------------------------------------------------------
function! Perl_CommentToggle ()
	let	linenumber	= line(".")
	let line				= getline(linenumber)
	if match( line, '^#' ) == 0
		call setline( linenumber, strpart(line, 1) )
	else
		call setline( linenumber, '#'.line )
	endif
endfunction    " ----------  end of function Perl_CommentToggle  ----------
"
"------------------------------------------------------------------------------
"  Comments : toggle comments (range)   {{{1
"------------------------------------------------------------------------------
function! Perl_CommentToggleRange ()
	let	comment=1									" 
	let pos0	= line("'<")
	let pos1	= line("'>")
	for line in getline( pos0, pos1 )
		if match( line, '^\s*$' ) != 0					" skip empty lines
			if match( line, '^#') == -1						" no comment 
				let comment = 0
				break
			endif
		endif
	endfor

	if comment == 0
		for linenumber in range( pos0, pos1 )
			if match( line, '^\s*$' ) != 0					" skip empty lines
				call setline( linenumber, '#'.getline(linenumber) )
			endif
		endfor
	else
		for linenumber in range( pos0, pos1 )
			call setline( linenumber, substitute( getline(linenumber), '^#', '', '' ) )
		endfor
	endif

endfunction    " ----------  end of function Perl_CommentToggleRange  ----------
"
"------------------------------------------------------------------------------
"  Comments : vim modeline     {{{1
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! Perl_CommentVimModeline ()
  put = '# vim: set tabstop='.&tabstop.' shiftwidth='.&shiftwidth.': '
endfunction    " ----------  end of function Perl_CommentVimModeline  ----------
"
"------------------------------------------------------------------------------
"  Perl-Idioms : read / edit code snippet     {{{1
"------------------------------------------------------------------------------
function! Perl_CodeSnippet(mode)
  if isdirectory(g:Perl_CodeSnippets)
    "
    " read snippet file, put content below current line
    "
    if a:mode == "r"
			if has("gui_running") && s:Perl_GuiSnippetBrowser == 'gui'
				let l:snippetfile=browse(0,"read a code snippet",g:Perl_CodeSnippets,"")
			else
				let	l:snippetfile=input("read snippet ", g:Perl_CodeSnippets, "file" )
			endif
      if filereadable(l:snippetfile)
        let linesread= line("$")
        let l:old_cpoptions = &cpoptions " Prevent the alternate buffer from being set to this files
        setlocal cpoptions-=a
        :execute "read ".l:snippetfile
        let &cpoptions  = l:old_cpoptions   " restore previous options
        "
        let linesread= line("$")-linesread-1
        if linesread>=0 && match( l:snippetfile, '\.\(ni\|noindent\)$' ) < 0
          silent exe "normal =".linesread."+"
        endif
      endif
    endif
    "
    " update current buffer / split window / edit snippet file
    "
    if a:mode == "e"
			if has("gui_running") && s:Perl_GuiSnippetBrowser == 'gui'
				let l:snippetfile=browse(0,"edit a code snippet",g:Perl_CodeSnippets,"")
			else
				let	l:snippetfile=input("edit snippet ", g:Perl_CodeSnippets, "file" )
			endif
      if l:snippetfile != ""
        :execute "update! | split | edit ".l:snippetfile
      endif
    endif
    "
    " write whole buffer or marked area into snippet file
    "
    if a:mode == "w" || a:mode == "wv"
			if has("gui_running") && s:Perl_GuiSnippetBrowser == 'gui'
				let l:snippetfile=browse(0,"write a code snippet",g:Perl_CodeSnippets,"")
			else
				let	l:snippetfile=input("write snippet ", g:Perl_CodeSnippets, "file" )
			endif
      if l:snippetfile != ""
        if filereadable(l:snippetfile)
          if confirm("File ".l:snippetfile." exists ! Overwrite ? ", "&Cancel\n&No\n&Yes") != 3
            return
          endif
        endif
				if a:mode == "w"
					:execute ":write! ".l:snippetfile
				else
					:execute ":*write! ".l:snippetfile
				endif
      endif
    endif

  else
    redraw!
    echohl ErrorMsg
    echo "code snippet directory ".g:Perl_CodeSnippets." does not exist"
    echohl None
  endif
endfunction   " ---------- end of function  Perl_CodeSnippet  ----------
"
"------------------------------------------------------------------------------
"  Perl-Run : Perl_perldoc - lookup word under the cursor or ask     {{{1
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
"
let s:Perl_PerldocBufferName       = "PERLDOC"
let s:Perl_PerldocHelpBufferNumber = -1
let s:Perl_PerldocModulelistBuffer = -1
let s:Perl_PerldocSearchWord       = ""
let s:Perl_PerldocTry              = "module"
"
function! Perl_perldoc()

  if( expand("%:p") == s:Perl_PerlModuleList )
    normal 0
    let item=expand("<cWORD>")        			" WORD under the cursor
  else
		let cuc		= getline(".")[col(".") - 1]	" character under the cursor
    let item	= expand("<cword>")       		" word under the cursor
		if item == "" || match( item, cuc ) == -1
			let item=Perl_Input("perldoc - module, function or FAQ keyword : ", "", '')
		endif
  endif

  "------------------------------------------------------------------------------
  "  replace buffer content with Perl documentation
  "------------------------------------------------------------------------------
  if item != ""
    "
    " jump to an already open PERLDOC window or create one
    "
    if bufloaded(s:Perl_PerldocBufferName) != 0 && bufwinnr(s:Perl_PerldocHelpBufferNumber) != -1
      exe bufwinnr(s:Perl_PerldocHelpBufferNumber) . "wincmd w"
      " buffer number may have changed, e.g. after a 'save as'
      if bufnr("%") != s:Perl_PerldocHelpBufferNumber
        let s:Perl_PerldocHelpBufferNumber=bufnr(s:Perl_OutputBufferName)
        exe ":bn ".s:Perl_PerldocHelpBufferNumber
      endif
    else
      exe ":new ".s:Perl_PerldocBufferName
      let s:Perl_PerldocHelpBufferNumber=bufnr("%")
      setlocal buftype=nofile
      setlocal noswapfile
      setlocal bufhidden=delete
			silent  setlocal filetype=perl    " allows repeated use of <S-F1>
      setlocal syntax=OFF
    endif
    "
    " search order:  library module --> builtin function --> FAQ keyword
    "
    let delete_perldoc_errors = ""
    if s:UNIX
      let delete_perldoc_errors = " 2>/dev/null"
    endif
    setlocal  modifiable
    "
    " controll repeated search
    "
    if item == s:Perl_PerldocSearchWord
      " last item : search ring :
      if s:Perl_PerldocTry == 'module'
        let next  = 'function'
      endif
      if s:Perl_PerldocTry == 'function'
        let next  = 'faq'
      endif
      if s:Perl_PerldocTry == 'faq'
        let next  = 'module'
      endif
      let s:Perl_PerldocTry = next
    else
      " new item :
      let s:Perl_PerldocSearchWord  = item
      let s:Perl_PerldocTry         = 'module'
    endif
    "
    " module documentation
    if s:Perl_PerldocTry == 'module'
      let command=":%!perldoc  ".s:Perl_perldoc_flags." ".item.delete_perldoc_errors
      silent exe command
      if v:shell_error != 0
        redraw!
        let s:Perl_PerldocTry         = 'function'
      endif
    endif
    "
    " function documentation
    if s:Perl_PerldocTry == 'function'
      " -otext has to be ahead of -f and -q
      silent exe ":%!perldoc ".s:Perl_perldoc_flags." -f ".item.delete_perldoc_errors
      if v:shell_error != 0
        redraw!
        let s:Perl_PerldocTry         = 'faq'
      endif
    endif
    "
    " FAQ documentation
    if s:Perl_PerldocTry == 'faq'
      silent exe ":%!perldoc ".s:Perl_perldoc_flags." -q ".item.delete_perldoc_errors
      if v:shell_error != 0
        redraw!
        let s:Perl_PerldocTry         = 'error'
      endif
    endif
    "
    " no documentation found
    if s:Perl_PerldocTry == 'error'
      redraw!
      let zz=   "No documentation found for perl module, perl function or perl FAQ keyword\n"
      let zz=zz."  '".item."'  "
      silent put! =zz
      normal  2jdd$
      let s:Perl_PerldocTry         = 'module'
      let s:Perl_PerldocSearchWord  = ""
    endif
    if s:UNIX
      " remove windows line ends
      silent! exe ":%s/\r$// | normal gg"
    endif
    setlocal nomodifiable
    redraw!
		" highlight the headlines
		:match Search '^\S.*$'
  endif
endfunction   " ---------- end of function  Perl_perldoc  ----------
"
"------------------------------------------------------------------------------
"  Perl-Run : Perl_perldoc - show module list     {{{1
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! Perl_perldoc_show_module_list()
  if !filereadable(s:Perl_PerlModuleList)
    redraw!
    echohl WarningMsg | echo 'Have to create '.s:Perl_PerlModuleList.' for the first time:'| echohl None
    call Perl_perldoc_generate_module_list()
  endif
  "
  " jump to the already open buffer or create one
  "
  if bufexists(s:Perl_PerldocModulelistBuffer) && bufwinnr(s:Perl_PerldocModulelistBuffer)!=-1
    silent exe bufwinnr(s:Perl_PerldocModulelistBuffer) . "wincmd w"
  else
		:split
    exe ":view ".s:Perl_PerlModuleList
    let s:Perl_PerldocModulelistBuffer=bufnr("%")
    setlocal nomodifiable
    setlocal filetype=perl
    setlocal syntax=none
  endif
  normal gg
  redraw!
  if has("gui_running")
    echohl Search | echomsg 'use S-F1 to show a manual' | echohl None
  else
    echohl Search | echomsg 'use \hh in normal mode to show a manual' | echohl None
  endif
endfunction   " ---------- end of function  Perl_perldoc_show_module_list  ----------
"
"------------------------------------------------------------------------------
"  Perl-Run : Perl_perldoc - generate module list     {{{1
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! Perl_perldoc_generate_module_list()
	" save the module list, if any
	if filereadable( s:Perl_PerlModuleList )
		let	backupfile	= s:Perl_PerlModuleList.'.backup'
		if rename( s:Perl_PerlModuleList, backupfile ) != 0
			echomsg 'Could not rename "'.s:Perl_PerlModuleList.'" to "'.backupfile.'"'
		endif
	endif
	"
  echohl Search
  echo " ... generating Perl module list ... "
  if  s:MSWIN
    silent exe ":!perl \"".s:Perl_PerlModuleListGenerator."\" > \"".s:Perl_PerlModuleList."\""
    silent exe ":!sort \"".s:Perl_PerlModuleList."\" /O \"".s:Perl_PerlModuleList."\""
  else
		" direct STDOUT and STDERR to the module list file :
    silent exe ":!perl ".s:Perl_PerlModuleListGenerator." -s &> ".s:Perl_PerlModuleList
  endif
	redraw!
  echo " DONE "
  echohl None
endfunction   " ---------- end of function  Perl_perldoc_generate_module_list  ----------
"
"------------------------------------------------------------------------------
"  Run : settings     {{{1
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! Perl_Settings ()
  let txt =     "  Perl-Support settings\n\n"
  let txt = txt.'             author name  :  "'.s:Perl_Macro['|AUTHOR|']."\"\n"
  let txt = txt.'                initials  :  "'.s:Perl_Macro['|AUTHORREF|']."\"\n"
  let txt = txt.'                   email  :  "'.s:Perl_Macro['|EMAIL|']."\"\n"
  let txt = txt.'                 company  :  "'.s:Perl_Macro['|COMPANY|']."\"\n"
  let txt = txt.'                 project  :  "'.s:Perl_Macro['|PROJECT|']."\"\n"
  let txt = txt.'        copyright holder  :  "'.s:Perl_Macro['|COPYRIGHTHOLDER|']."\"\n"
  let txt = txt.'  code snippet directory  :  "'.g:Perl_CodeSnippets."\"\n"
	let txt = txt.'           template style :  "'.s:Perl_Macro['|STYLE|']."\"\n"
	let txt = txt.'      plugin installation :  "'.g:Perl_Installation."\"\n"
	" ----- template files  ------------------------
	if g:Perl_Installation == 'system'
		let txt = txt.'global template directory :  "'.s:Perl_GlobalTemplateDir."\"\n"
		if filereadable( s:Perl_LocalTemplateFile )
			let txt = txt.' local template directory :  '.s:Perl_LocalTemplateDir."\n"
		endif
	else
		let txt = txt.' local template directory :  '.s:Perl_LocalTemplateDir."\n"
	endif
	" ----- xterm ------------------------
	if	!s:MSWIN
		let txt = txt.'           xterm defaults :  '.s:Perl_XtermDefaults."\n"
	endif
	" ----- dictionaries ------------------------
  if g:Perl_Dictionary_File != ""
		let ausgabe= &dictionary
    let ausgabe = substitute( ausgabe, ",", ",\n                          + ", "g" )
    let txt     = txt."       dictionary file(s) :  ".ausgabe."\n"
  endif
  let txt = txt."    current output dest.  :  ".g:Perl_OutputGvim."\n"
  let txt = txt."              perlcritic  :  perlcritic -severity ".s:Perl_PerlcriticSeverity
				\				.' ['.s:PCseverityName[s:Perl_PerlcriticSeverity].']'
				\				."  -verbosity ".s:Perl_PerlcriticVerbosity
				\				."  ".s:Perl_PerlcriticOptions."\n"
	if s:Perl_InterfaceVersion != ''
		let txt = txt."  Perl interface version  :  ".s:Perl_InterfaceVersion."\n"
	endif
  let txt = txt."\n"
  let txt = txt."    Additional hot keys\n\n"
  let txt = txt."                Shift-F1  :  read perldoc (for word under cursor)\n"
  let txt = txt."                      F9  :  start a debugger (".s:Perl_Debugger.")\n"
  let txt = txt."                  Alt-F9  :  run syntax check          \n"
  let txt = txt."                 Ctrl-F9  :  run script                \n"
  let txt = txt."                Shift-F9  :  set command line arguments\n"
  let txt = txt."_________________________________________________________________________\n"
  let txt = txt."  Perl-Support, Version ".g:Perl_Version." / Dr.-Ing. Fritz Mehner / mehner@fh-swf.de\n\n"
  echo txt
endfunction   " ---------- end of function  Perl_Settings  ----------
"
"------------------------------------------------------------------------------
"  run : syntax check     {{{1
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! Perl_SyntaxCheck ()
  exe ":cclose"
  let l:currentbuffer   = bufname("%")
	let l:fullname        = expand("%:p")
  silent exe  ":update"
  "
  " avoid filtering the Perl output if the file name does not contain blanks:
  "
	if s:MSWIN && ( l:fullname =~ ' ' ||  s:Perl_EfmPerl =~ ' ' )
    "
    " Use tools/efm_perl.pl from the VIM distribution.
    " This wrapper can handle filenames containing blanks.
    " Errorformat from tools/efm_perl.pl .
		" direct call 
    "
		let tmpfile = tempname()
    exe ':setlocal errorformat=%f:%l:%m'
		silent exe ":!\"".s:Perl_EfmPerl."\" -c % > ".tmpfile
		exe ":cfile ".tmpfile
  else
    "
		" no whitespaces
    " Errorformat from compiler/perl.vim (VIM distribution).
    "
    exe ':set makeprg=perl\ -c'
    exe ':setlocal errorformat=
        \%-G%.%#had\ compilation\ errors.,
        \%-G%.%#syntax\ OK,
        \%m\ at\ %f\ line\ %l.,
        \%+A%.%#\ at\ %f\ line\ %l\\,%.%#,
       \%+C%.%#'
	  let	l:fullname	= fnameescape( l:fullname )
  	silent exe  ':make  '.l:fullname
  endif

  exe ":botright cwindow"
  exe ':setlocal errorformat='
  exe "set makeprg=make"
  "
  " message in case of success
  "
	redraw!
  if l:currentbuffer ==  bufname("%")
			echohl Search
			echomsg l:currentbuffer." : Syntax is OK"
			echohl None
    return 0
  else
    setlocal wrap
    setlocal linebreak
  endif
endfunction   " ---------- end of function  Perl_SyntaxCheck  ----------
"
"----------------------------------------------------------------------
"  run : toggle output destination     {{{1
"  Also called in the filetype plugin perl.vim
"----------------------------------------------------------------------
function! Perl_Toggle_Gvim_Xterm ()

	if g:Perl_OutputGvim == "vim"
		if has("gui_running")
			exe "aunmenu  <silent>  ".g:Perl_Root.'&Run.&output:\ VIM->buffer->xterm'
			exe "amenu    <silent>  ".g:Perl_Root.'&Run.&output:\ BUFFER->xterm->vim              :call Perl_Toggle_Gvim_Xterm()<CR>'
		endif
		let	g:Perl_OutputGvim	= "buffer"
	else
		if g:Perl_OutputGvim == "buffer"
			if has("gui_running")
				exe "aunmenu  <silent>  ".g:Perl_Root.'&Run.&output:\ BUFFER->xterm->vim'
				if (!s:MSWIN)
					exe "amenu    <silent>  ".g:Perl_Root.'&Run.&output:\ XTERM->vim->buffer             :call Perl_Toggle_Gvim_Xterm()<CR>'
				else
					exe "amenu    <silent>  ".g:Perl_Root.'&Run.&output:\ VIM->buffer->xterm            :call Perl_Toggle_Gvim_Xterm()<CR>'
				endif
			endif
			if (!s:MSWIN) && (s:Perl_Display != '')
				let	g:Perl_OutputGvim	= "xterm"
			else
				let	g:Perl_OutputGvim	= "vim"
			endif
		else
			" ---------- output : xterm -> gvim
			if has("gui_running")
				exe "aunmenu  <silent>  ".g:Perl_Root.'&Run.&output:\ XTERM->vim->buffer'
				exe "amenu    <silent>  ".g:Perl_Root.'&Run.&output:\ VIM->buffer->xterm            :call Perl_Toggle_Gvim_Xterm()<CR>'
			endif
			let	g:Perl_OutputGvim	= "vim"
		endif
	endif
  echomsg "output destination is '".g:Perl_OutputGvim."'"

endfunction    " ----------  end of function Perl_Toggle_Gvim_Xterm ----------
"
"------------------------------------------------------------------------------
"  run : Perl_PerlSwitches     {{{1
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! Perl_PerlSwitches ()
  let filename = fnameescape( expand("%:p") )
  if filename == ""
    redraw!
    echohl WarningMsg | echo " no file name " | echohl None
    return
  endif
  let prompt   = 'perl command line switches for "'.filename.'" : '
  if exists("b:Perl_Switches")
    let b:Perl_Switches= Perl_Input( prompt, b:Perl_Switches, '' )
  else
    let b:Perl_Switches= Perl_Input( prompt , "", '' )
  endif
endfunction   " ---------- end of function  Perl_PerlSwitches  ----------
"
"------------------------------------------------------------------------------
"  run : run     {{{1
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
"
let s:Perl_OutputBufferName   = "Perl-Output"
let s:Perl_OutputBufferNumber = -1
"
function! Perl_Run ()
  "
  if &filetype != "perl"
    echohl WarningMsg | echo expand("%:p").' seems not to be a Perl file' | echohl None
    return
  endif
  let buffername  = expand("%")
  if fnamemodify( s:Perl_PerlModuleList, ":p:t" ) == buffername || s:Perl_PerldocBufferName == buffername
    return
  endif
  "
  let l:currentbuffernr = bufnr("%")
  let l:arguments       = exists("b:Perl_CmdLineArgs") ? " ".b:Perl_CmdLineArgs : ""
  let l:switches        = exists("b:Perl_Switches") ? b:Perl_Switches.' ' : ""
  let l:currentbuffer   = bufname("%")
  let l:fullname        = expand("%:p")
  let l:fullname_esc    = fnameescape( expand("%:p") )
  "
  silent exe ":update"
  silent exe ":cclose"
  "
  "
  "------------------------------------------------------------------------------
  "  run : run from the vim command line
  "------------------------------------------------------------------------------
  if g:Perl_OutputGvim == "vim"
    "
    if  s:MSWIN
      exe "!perl ".l:switches.'"'.l:fullname.'" '.l:arguments
    else
      exe "!perl ".l:switches.l:fullname_esc.l:arguments
    endif
    "
  endif
  "
  "------------------------------------------------------------------------------
  "  run : redirect output to an output buffer
  "------------------------------------------------------------------------------
  if g:Perl_OutputGvim == "buffer"
    let l:currentbuffernr = bufnr("%")
    if l:currentbuffer ==  bufname("%")
      "
      "
      if bufloaded(s:Perl_OutputBufferName) != 0 && bufwinnr(s:Perl_OutputBufferNumber) != -1
        exe bufwinnr(s:Perl_OutputBufferNumber) . "wincmd w"
        " buffer number may have changed, e.g. after a 'save as'
        if bufnr("%") != s:Perl_OutputBufferNumber
          let s:Perl_OutputBufferNumber=bufnr(s:Perl_OutputBufferName)
          exe ":bn ".s:Perl_OutputBufferNumber
        endif
      else
        silent exe ":new ".s:Perl_OutputBufferName
        let s:Perl_OutputBufferNumber=bufnr("%")
        setlocal buftype=nofile
        setlocal noswapfile
        setlocal syntax=none
        setlocal bufhidden=delete
        setlocal tabstop=8
      endif
      "
      " run script
      "
      setlocal  modifiable
      silent exe ":update"
      if  s:MSWIN
        exe ":%!perl ".l:switches.'"'.l:fullname.'" '.l:arguments
      else
        exe ":%!perl ".l:switches.l:fullname_esc.l:arguments
      endif
      setlocal  nomodifiable
      "
			if winheight(winnr()) >= line("$")
				exe bufwinnr(l:currentbuffernr) . "wincmd w"
			endif
			"
    endif
  endif
  "
  "------------------------------------------------------------------------------
  "  run : run in a detached xterm  (not available for MS Windows)
  "------------------------------------------------------------------------------
  if g:Perl_OutputGvim == "xterm"
    "
    if  s:MSWIN
      " same as "vim"
      exe "!perl ".l:switches.'"'.l:fullname.'" '.l:arguments
    else
      silent exe '!xterm -title '.l:fullname_esc.' '.s:Perl_XtermDefaults.' -e '.s:Perl_Wrapper.' perl '.l:switches.l:fullname_esc.l:arguments
			:redraw!
    endif
    "
  endif
  "
endfunction    " ----------  end of function Perl_Run  ----------
"
"------------------------------------------------------------------------------
"  Perl_MakeArguments : run make(1)       {{{1
"------------------------------------------------------------------------------

let s:Perl_MakeCmdLineArgs   = ""     " command line arguments for Run-make; initially empty

function! Perl_MakeArguments ()
	let	s:Perl_MakeCmdLineArgs= Perl_Input("make command line arguments : ",s:Perl_MakeCmdLineArgs, 'file' )
endfunction    " ----------  end of function Perl_MakeArguments ----------
"
function! Perl_Make()
	" update : write source file if necessary
	exe	":update"
	" run make
	exe		":!make ".s:Perl_MakeCmdLineArgs
endfunction    " ----------  end of function Perl_Make ----------
"
"------------------------------------------------------------------------------
"  run : start debugger     {{{1
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! Perl_Debugger ()
  "
  silent exe  ":update"
  let l:arguments 	= exists("b:Perl_CmdLineArgs") ? " ".b:Perl_CmdLineArgs : ""
  let filename      = expand("%:p")
  let filename_esc  = fnameescape( expand("%:p") )
  "
  if  s:MSWIN
    let l:arguments = substitute( l:arguments, '^\s\+', ' ', '' )
    let l:arguments = substitute( l:arguments, '\s\+', "\" \"", 'g')
  endif
  "
  " debugger is ' perl -d ... '
  "
  if s:Perl_Debugger == "perl"
    if  s:MSWIN
      exe '!perl -d "'.filename.l:arguments.'"'
    else
      if has("gui_running") || &term == "xterm"
        silent exe "!xterm ".s:Perl_XtermDefaults.' -e perl -d '.filename_esc.l:arguments.' &'
      else
        silent exe '!clear; perl -d '.filename_esc.l:arguments
      endif
    endif
  endif
  "
  if has("gui_running")
    "
    " grapical debugger is 'ptkdb', uses a PerlTk interface
    "
    if s:Perl_Debugger == "ptkdb"
      if  s:MSWIN
				exe '!perl -d:ptkdb "'.filename.l:arguments.'"'
      else
        silent exe '!perl -d:ptkdb  '.filename_esc.l:arguments.' &'
      endif
    endif
    "
    " debugger is 'ddd'  (not available for MS Windows); graphical front-end for GDB
    "
    if s:Perl_Debugger == "ddd" && !s:MSWIN
      if !executable("ddd")
        echohl WarningMsg
        echo 'ddd does not exist or is not executable!'
        echohl None
        return
      else
        silent exe '!ddd '.filename_esc.l:arguments.' &'
      endif
    endif
    "
  endif
  "
	redraw!
endfunction   " ---------- end of function  Perl_Debugger  ----------
"
"------------------------------------------------------------------------------
"  run : Arguments     {{{1
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! Perl_Arguments ()
  let filename = fnameescape( expand("%") )
  if filename == ""
    redraw!
    echohl WarningMsg | echo " no file name " | echohl None
    return
  endif
  let prompt   = 'command line arguments for "'.filename.'" : '
  if exists("b:Perl_CmdLineArgs")
    let b:Perl_CmdLineArgs= Perl_Input( prompt, b:Perl_CmdLineArgs, 'file' )
  else
    let b:Perl_CmdLineArgs= Perl_Input( prompt , "", 'file' )
  endif
endfunction   " ---------- end of function  Perl_Arguments  ----------
"
"------------------------------------------------------------------------------
"  run : xterm geometry     {{{1
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! Perl_XtermSize ()
  let regex = '-geometry\s\+\d\+x\d\+'
  let geom  = matchstr( s:Perl_XtermDefaults, regex )
  let geom  = matchstr( geom, '\d\+x\d\+' )
  let geom  = substitute( geom, 'x', ' ', "" )
  let answer= Perl_Input("   xterm size (COLUMNS LINES) : ", geom )
  while match(answer, '^\s*\d\+\s\+\d\+\s*$' ) < 0
    let answer= Perl_Input(" + xterm size (COLUMNS LINES) : ", geom )
  endwhile
  let answer  = substitute( answer, '\s\+', "x", "" )           " replace inner whitespaces
  let s:Perl_XtermDefaults  = substitute( s:Perl_XtermDefaults, regex, "-geometry ".answer , "" )
endfunction   " ---------- end of function  Perl_XtermSize  ----------
"
"------------------------------------------------------------------------------
"  run : make script executable     {{{1
"  Also called in the filetype plugin perl.vim
"  Only on systems where execute permission is implemented
"------------------------------------------------------------------------------
function! Perl_MakeScriptExecutable ()
  let filename  = fnameescape( expand("%:p") )
  if executable(filename) == 0                  " not executable
    silent exe "!chmod u+x ".filename
    redraw!
    if v:shell_error
      echohl WarningMsg
      echo 'Could not make "'.filename.'" executable !'
    else
      echohl Search
      echo 'Made "'.filename.'" executable.'
    endif
    echohl None
	else
		echo '"'.filename.'" is already executable.'
  endif
endfunction   " ---------- end of function  Perl_MakeScriptExecutable  ----------
"
"------------------------------------------------------------------------------
"  run POD checker     {{{1
"------------------------------------------------------------------------------
function! Perl_PodCheck ()
  exe ":cclose"
  let l:currentbuffer   = bufname("%")
  silent exe  ":update"
  "
  if s:Perl_PodcheckerWarnings == "no"
    let PodcheckerWarnings  = '-nowarnings '
  else
    let PodcheckerWarnings  = '-warnings '
  endif
  :set makeprg=podchecker

  exe ':setlocal errorformat=***\ %m\ at\ line\ %l\ in\ file\ %f'
	if  s:MSWIN
		silent exe  ':make '.PodcheckerWarnings.'"'.expand("%:p").'"'
	else
		silent exe  ':make '.PodcheckerWarnings.fnameescape( expand("%:p") )
	endif

  exe ":botright cwindow"
  exe ':setlocal errorformat='
  exe ":set makeprg=make"
  "
  " message in case of success
  "
	redraw!
  if l:currentbuffer ==  bufname("%")
    echohl Search
    echomsg  l:currentbuffer." : POD syntax is OK"
    echohl None
    return 0
  endif
  return 1
endfunction   " ---------- end of function  Perl_PodCheck  ----------
"
"------------------------------------------------------------------------------
"  run : POD -> html / man / text     {{{1
"------------------------------------------------------------------------------
function! Perl_POD ( format )
	let	source			= expand("%:p")
	let	source_esc	= fnameescape( expand("%:p"),  )
	let target	  	= source.'.'.a:format
	let target_esc	= source_esc.'.'.a:format

  silent exe  ":update"
	if executable( 'pod2'.a:format )
		if  s:MSWIN
			if a:format=='html'
				silent exe  ':!pod2'.a:format.' "--infile='.source.'"  "--outfile='.target.'"'
			else
				silent exe  ':!pod2'.a:format.' "'.source.'" "'.target.'"'
			endif
		else
			if a:format=='html'
				silent exe  ':!pod2'.a:format.' --infile='.source_esc.' --outfile='.target_esc
			else
				silent exe  ':!pod2'.a:format.' '.source_esc.' '.target_esc
			endif
		endif
		redraw!
		echo  "file '".target."' generated"
	else
		redraw!
		echomsg 'Application "pod2'.a:format.'" does not exist or is not executable.'
	endif
endfunction   " ---------- end of function  Perl_POD  ----------

"------------------------------------------------------------------------------
"  Perl_RereadTemplates     {{{1
"  rebuild commands and the menu from the (changed) template file
"------------------------------------------------------------------------------
function! Perl_RereadTemplates ( msg )
    let s:Perl_Template     	= {}
    let s:Perl_FileVisited  	= []
		let	messsage							= ''
		"
		if g:Perl_Installation == 'system'
			"
			if filereadable( s:Perl_GlobalTemplateFile )
				call Perl_ReadTemplates( s:Perl_GlobalTemplateFile )
			else
				echomsg "Global template file '.s:Perl_GlobalTemplateFile.' not readable."
				return
			endif
			let	messsage	= "Templates read from '".s:Perl_GlobalTemplateFile."'"
			"
			if filereadable( s:Perl_LocalTemplateFile )
				call Perl_ReadTemplates( s:Perl_LocalTemplateFile )
				let messsage	= messsage." and '".s:Perl_LocalTemplateFile."'"
			endif
			"
		else
			"
			if filereadable( s:Perl_LocalTemplateFile )
				call Perl_ReadTemplates( s:Perl_LocalTemplateFile )
				let	messsage	= "Templates read from '".s:Perl_LocalTemplateFile."'"
			else
				echomsg "Local template file '".s:Perl_LocalTemplateFile."' not readable." 
				return
			endif
			"
		endif
		if a:msg == 'yes'
			echomsg messsage.'.'
		endif

endfunction    " ----------  end of function Perl_RereadTemplates  ----------

"------------------------------------------------------------------------------
"  Perl_BrowseTemplateFiles     {{{1
"------------------------------------------------------------------------------
function! Perl_BrowseTemplateFiles ( type )
	let	templatefile	= eval( 's:Perl_'.a:type.'TemplateFile' )
	let	templatedir		= eval( 's:Perl_'.a:type.'TemplateDir' )
	if isdirectory( templatedir )
		if has("browse") && s:Perl_GuiTemplateBrowser == 'gui'
			let	l:templatefile	= browse(0,"edit a template file", templatedir, "" )
		else
				let	l:templatefile	= ''
			if s:Perl_GuiTemplateBrowser == 'explorer'
				exe ':Explore '.templatedir
			endif
			if s:Perl_GuiTemplateBrowser == 'commandline'
				let	l:templatefile	= input("edit a template file", templatedir, "file" )
			endif
		endif
		if l:templatefile != ""
			:execute "update! | split | edit ".l:templatefile
		endif
	else
		echomsg "Template directory '".templatedir."' does not exist."
	endif
endfunction    " ----------  end of function Perl_BrowseTemplateFiles  ----------
"
"------------------------------------------------------------------------------
"  Perl_ReadTemplates     {{{1
"  read the template file(s), build the macro and the template dictionary
"
"------------------------------------------------------------------------------
function! Perl_ReadTemplates ( templatefile )

  if !filereadable( a:templatefile )
    echohl WarningMsg
    echomsg "Perl Support template file '".a:templatefile."' does not exist or is not readable"
    echohl None
    return
  endif

	let	skipmacros	= 0
  let s:Perl_FileVisited  += [a:templatefile]

  "------------------------------------------------------------------------------
  "  read template file, start with an empty template dictionary
  "------------------------------------------------------------------------------

  let item  		= ''
	let	skipline	= 0
  for line in readfile( a:templatefile )
		" if not a comment :
    if line !~ s:Perl_MacroCommentRegex
      "
			" IF
      "
      let string  = matchlist( line, s:Perl_TemplateIf )
      if !empty(string) 
				if s:Perl_Macro['|STYLE|'] != string[1]
					let	skipline	= 1
				endif
			endif
			"
			" ENDIF
      "
      let string  = matchlist( line, s:Perl_TemplateEndif )
      if !empty(string)
				let	skipline	= 0
				continue
			endif
			"
      if skipline == 1
				continue
			endif
      "
      " macros and file includes
      "
      let string  = matchlist( line, s:Perl_MacroLineRegex )
      if !empty(string) && skipmacros == 0
        let key = '|'.string[1].'|'
        let val = string[2]
        let val = substitute( val, '\s\+$', '', '' )
        let val = substitute( val, "[\"\']$", '', '' )
        let val = substitute( val, "^[\"\']", '', '' )
        "
        if key == '|includefile|' && count( s:Perl_FileVisited, val ) == 0
					let path   = fnamemodify( a:templatefile, ":p:h" )
          call Perl_ReadTemplates( path.'/'.val )    " recursive call
        else
          let s:Perl_Macro[key] = escape( val, '&' )
        endif
        continue                                     " next line
      endif
      "
      " template header
      "
      let name  = matchstr( line, s:Perl_TemplateLineRegex )
      "
      if name != ''
        let part  = split( name, '\s*==\s*')
        let item  = part[0]
        if has_key( s:Perl_Template, item ) && s:Perl_TemplateOverwrittenMsg == 'yes'
          echomsg "existing Perl Support template '".item."' overwritten"
        endif
        let s:Perl_Template[item] = ''
				let skipmacros	= 1
        "
				" control insertion
				"
        let s:Perl_InsertionAttribute[item] = 'below'
        if has_key( s:InsertionAttribute, get( part, 1, 'NONE' ) )
          let s:Perl_InsertionAttribute[item] = part[1]
        endif
        "
				" control indentation
				"
        let s:Perl_IndentAttribute[item] = 'indent'
        if has_key( s:IndentAttribute, get( part, 2, 'NONE' ) )
          let s:Perl_IndentAttribute[item] = part[2]
        endif
      else
        if item != ''
          let s:Perl_Template[item] = s:Perl_Template[item].line."\n"
        endif
      endif
    endif
  endfor

endfunction    " ----------  end of function Perl_ReadTemplates  ----------

"------------------------------------------------------------------------------
" Perl_OpenFold     {{{1
" Open fold and go to the first or last line of this fold.
"------------------------------------------------------------------------------
function! Perl_OpenFold ( mode )
	if foldclosed(".") >= 0
		" we are on a closed  fold: get end position, open fold, jump to the
		" last line of the previously closed fold
		let	foldstart	= foldclosed(".")
		let	foldend		= foldclosedend(".")
		normal zv
		if a:mode == 'below'
			exe ":".foldend
		endif
		if a:mode == 'start'
			exe ":".foldstart
		endif
	endif
endfunction    " ----------  end of function Perl_OpenFold  ----------

"------------------------------------------------------------------------------
"  Perl_InsertTemplate     {{{1
"  insert a template from the template dictionary
"  do macro expansion
"------------------------------------------------------------------------------
function! Perl_InsertTemplate ( key, ... )

	if !has_key( s:Perl_Template, a:key )
		echomsg "Template '".a:key."' not found. Please check your template file in '".s:Perl_GlobalTemplateDir."'"
		return
	endif

	if &foldenable
		let	foldmethod_save	= &foldmethod
		set foldmethod=manual
	endif
  "------------------------------------------------------------------------------
  "  insert the user macros
  "------------------------------------------------------------------------------

	" use internal formatting to avoid conficts when using == below
	"
	let	equalprg_save	= &equalprg
	set equalprg=

  let mode  = s:Perl_InsertionAttribute[a:key]
  let indent = s:Perl_IndentAttribute[a:key]

	" remove <SPLIT> and insert the complete macro
	"
	if a:0 == 0
		let val = Perl_ExpandUserMacros (a:key)
		if val	== ""
			return
		endif
		let val	= Perl_ExpandSingleMacro( val, '<SPLIT>', '' )

		if mode == 'below'
			call Perl_OpenFold('below')
			let pos1  = line(".")+1
			put  =val
			let pos2  = line(".")
			" proper indenting
			if indent == 'indent'
				exe ":".pos1
				let ins	= pos2-pos1+1
				exe "normal ".ins."=="
			endif
			"
		elseif mode == 'above'
			let pos1  = line(".")
			put! =val
			let pos2  = line(".")
			" proper indenting
			if indent == 'indent'
				exe ":".pos1
				let ins	= pos2-pos1+1
				exe "normal ".ins."=="
			endif
			"
		elseif mode == 'start'
			normal gg
			call Perl_OpenFold('start')
			let pos1  = 1
			put! =val
			let pos2  = line(".")
			" proper indenting
			if indent == 'indent'
				exe ":".pos1
				let ins	= pos2-pos1+1
				exe "normal ".ins."=="
			endif
			"
		elseif mode == 'append'
			if &foldenable && foldclosed(".") >= 0
				echohl WarningMsg | echomsg s:MsgInsNotAvail  | echohl None
				exe "set foldmethod=".foldmethod_save
				return
			else
				let pos1  = line(".")
				put =val
				let pos2  = line(".")-1
				exe ":".pos1
				:join!
			endif
			"
		elseif mode == 'insert'
			if &foldenable && foldclosed(".") >= 0
				echohl WarningMsg | echomsg s:MsgInsNotAvail  | echohl None
				exe "set foldmethod=".foldmethod_save
				return
			else
				let val   = substitute( val, '\n$', '', '' )
				let currentline	= getline( "." )
				let pos1  = line(".")
				let pos2  = pos1 + count( split(val,'\zs'), "\n" )
				" assign to the unnamed register "" :
				let @"=val
				normal p
				" reformat only multiline inserts and previously empty lines
				if ( pos2-pos1 > 0 || currentline =~ '' ) && indent == 'indent'
					exe ":".pos1
					let ins	= pos2-pos1+1
					exe "normal ".ins."=="
				endif
			endif
			"
		endif
		"
	else
		"
		" =====  visual mode  ===============================
		"
		if  a:1 == 'v'
			let val = Perl_ExpandUserMacros (a:key)
			let val	= Perl_ExpandSingleMacro( val, s:Perl_TemplateJumpTarget2, '' )
			if val	== ""
				return
			endif

			if match( val, '<SPLIT>\s*\n' ) >= 0
				let part	= split( val, '<SPLIT>\s*\n' )
			else
				let part	= split( val, '<SPLIT>' )
			endif

			if len(part) < 2
				let part	= [ "" ] + part
				echomsg 'SPLIT missing in template '.a:key
			endif
			"
			" 'visual' and mode 'insert':
			"   <part0><marked area><part1>
			" part0 and part1 can consist of several lines
			"
			if mode == 'insert'
				let pos1  = line(".")
				let pos2  = pos1
				let	string= @*
				let replacement	= part[0].string.part[1]
				" remove trailing '\n'
				let replacement   = substitute( replacement, '\n$', '', '' )
				exe ':s/'.string.'/'.replacement.'/'
			endif
			"
			" 'visual' and mode 'below':
			"   <part0>
			"   <marked area>
			"   <part1>
			" part0 and part1 can consist of several lines
			"
			if mode == 'below'

				:'<put! =part[0]
				:'>put  =part[1]

				let pos1  = line("'<") - len(split(part[0], '\n' ))
				let pos2  = line("'>") + len(split(part[1], '\n' ))
				"			" proper indenting
				if indent == 'indent'
					exe ":".pos1
					let ins	= pos2-pos1+1
					exe "normal ".ins."=="
				endif
			endif
			"
		endif		" ---------- end visual mode
	endif

	" restore formatter programm
	let &equalprg	= equalprg_save

  "------------------------------------------------------------------------------
  "  position the cursor
  "------------------------------------------------------------------------------
  exe ":".pos1
  let mtch = search( '<CURSOR>', 'c', pos2 )
	if mtch != 0
		let line	= getline(mtch)
		if line =~ '<CURSOR>$'
			call setline( mtch, substitute( line, '<CURSOR>', '', '' ) )
			if  a:0 != 0 && a:1 == 'v' && getline(".") =~ '^\s*$'
				normal J
			else
				:startinsert!
			endif
		else
			call setline( mtch, substitute( line, '<CURSOR>', '', '' ) )
			:startinsert
		endif
	else
		" to the end of the block; needed for repeated inserts
		if mode == 'below'
			exe ":".pos2
		endif
  endif

  "------------------------------------------------------------------------------
  "  marked words
  "------------------------------------------------------------------------------
	" define a pattern to highlight
	call Perl_HighlightJumpTargets ()

	if &foldenable
		" restore folding method
		exe "set foldmethod=".foldmethod_save
		normal zv
	endif

endfunction    " ----------  end of function Perl_InsertTemplate  ----------

"------------------------------------------------------------------------------
"  Perl_JumpCtrlJ     {{{1
"------------------------------------------------------------------------------
function! Perl_HighlightJumpTargets ()
	if s:Perl_Ctrl_j == 'on'
		exe 'match Search /'.s:Perl_TemplateJumpTarget1.'\|'.s:Perl_TemplateJumpTarget2.'/'
	endif
endfunction    " ----------  end of function Perl_HighlightJumpTargets  ----------

"------------------------------------------------------------------------------
"  Perl_JumpCtrlJ     {{{1
"------------------------------------------------------------------------------
function! Perl_JumpCtrlJ ()
  let match	= search( s:Perl_TemplateJumpTarget1.'\|'.s:Perl_TemplateJumpTarget2, 'c' )
	if match > 0
		" remove the target
		call setline( match, substitute( getline('.'), s:Perl_TemplateJumpTarget1.'\|'.s:Perl_TemplateJumpTarget2, '', '' ) )
	else
		" try to jump behind parenthesis or strings in the current line 
		if match( getline(".")[col(".") - 1], "[\]})\"'`]"  ) != 0
			call search( "[\]})\"'`]", '', line(".") )
		endif
		normal l
	endif
	return ''
endfunction    " ----------  end of function Perl_JumpCtrlJ  ----------

"------------------------------------------------------------------------------
"  Perl_ExpandUserMacros     {{{1
"------------------------------------------------------------------------------
function! Perl_ExpandUserMacros ( key )

  let template 								= s:Perl_Template[ a:key ]
	let	s:Perl_ExpansionCounter	= {}										" reset the expansion counter

  "------------------------------------------------------------------------------
  "  renew the predefined macros and expand them
	"  can be replaced, with e.g. |?DATE|
  "------------------------------------------------------------------------------
	let	s:Perl_Macro['|BASENAME|']	= toupper(expand("%:t:r"))
  let s:Perl_Macro['|DATE|']  		= Perl_DateAndTime('d')
  let s:Perl_Macro['|FILENAME|']	= expand("%:t")
  let s:Perl_Macro['|PATH|']  		= expand("%:p:h")
  let s:Perl_Macro['|SUFFIX|']		= expand("%:e")
  let s:Perl_Macro['|TIME|']  		= Perl_DateAndTime('t')
  let s:Perl_Macro['|YEAR|']  		= Perl_DateAndTime('y')

  "------------------------------------------------------------------------------
  "  delete jump targets if mapping for C-j is off
  "------------------------------------------------------------------------------
	if s:Perl_Ctrl_j == 'off'
		let template	= substitute( template, s:Perl_TemplateJumpTarget1.'\|'.s:Perl_TemplateJumpTarget2, '', 'g' )
	endif

  "------------------------------------------------------------------------------
  "  look for replacements
  "------------------------------------------------------------------------------
	while match( template, s:Perl_ExpansionRegex ) != -1
		let macro				= matchstr( template, s:Perl_ExpansionRegex )
		let replacement	= substitute( macro, '?', '', '' )
		let template		= substitute( template, macro, replacement, "g" )

		let match	= matchlist( macro, s:Perl_ExpansionRegex )

		if match[1] != ''
			let macroname	= '|'.match[1].'|'
			"
			" notify flag action, if any
			let flagaction	= ''
			if has_key( s:Perl_MacroFlag, match[2] )
				let flagaction	= ' (-> '.s:Perl_MacroFlag[ match[2] ].')'
			endif
			"
			" ask for a replacement
			if has_key( s:Perl_Macro, macroname )
				let	name	= Perl_Input( match[1].flagaction.' : ', Perl_ApplyFlag( s:Perl_Macro[macroname], match[2] ) )
			else
				let	name	= Perl_Input( match[1].flagaction.' : ', '' )
			endif
			if name == ""
				return ""
			endif
			"
			" keep the modified name
			let s:Perl_Macro[macroname]  			= Perl_ApplyFlag( name, match[2] )
		endif
	endwhile

  "------------------------------------------------------------------------------
  "  do the actual macro expansion
	"  loop over the macros found in the template
  "------------------------------------------------------------------------------
	while match( template, s:Perl_NonExpansionRegex ) != -1

		let macro			= matchstr( template, s:Perl_NonExpansionRegex )
		let match			= matchlist( macro, s:Perl_NonExpansionRegex )

		if match[1] != ''
			let macroname	= '|'.match[1].'|'

			if has_key( s:Perl_Macro, macroname )
				"-------------------------------------------------------------------------------
				"   check for recursion
				"-------------------------------------------------------------------------------
				if has_key( s:Perl_ExpansionCounter, macroname )
					let	s:Perl_ExpansionCounter[macroname]	+= 1
				else
					let	s:Perl_ExpansionCounter[macroname]	= 0
				endif
				if s:Perl_ExpansionCounter[macroname]	>= s:Perl_ExpansionLimit
					echomsg " recursion terminated for recursive macro ".macroname
					return template
				endif
				"-------------------------------------------------------------------------------
				"   replace
				"-------------------------------------------------------------------------------
				let replacement = Perl_ApplyFlag( s:Perl_Macro[macroname], match[2] )
				let template 		= substitute( template, macro, replacement, "g" )
			else
				"
				" macro not yet defined
				let s:Perl_Macro['|'.match[1].'|']  		= ''
			endif
		endif

	endwhile

  return template
endfunction    " ----------  end of function Perl_ExpandUserMacros  ----------

"------------------------------------------------------------------------------
"  Perl_ApplyFlag     {{{1
"------------------------------------------------------------------------------
function! Perl_ApplyFlag ( val, flag )
	"
	" l : lowercase
	if a:flag == ':l'
		return  tolower(a:val)
	endif
	"
	" u : uppercase
	if a:flag == ':u'
		return  toupper(a:val)
	endif
	"
	" c : capitalize
	if a:flag == ':c'
		return  toupper(a:val[0]).a:val[1:]
	endif
	"
	" L : legalized name
	if a:flag == ':L'
		return  Perl_LegalizeName(a:val)
	endif
	"
	" flag not valid
	return a:val
endfunction    " ----------  end of function Perl_ApplyFlag  ----------
"
"------------------------------------------------------------------------------
"  Perl_ExpandSingleMacro     {{{1
"------------------------------------------------------------------------------
function! Perl_ExpandSingleMacro ( val, macroname, replacement )
  return substitute( a:val, escape(a:macroname, '$' ), a:replacement, "g" )
endfunction    " ----------  end of function Perl_ExpandSingleMacro  ----------

"------------------------------------------------------------------------------
"  Perl_InsertMacroValue     {{{1
"------------------------------------------------------------------------------
function! Perl_InsertMacroValue ( key )
	if s:Perl_Macro['|'.a:key.'|'] == ''
		echomsg 'the tag |'.a:key.'| is empty'
		return
	endif
	"
	if &foldenable && foldclosed(".") >= 0
		echohl WarningMsg | echomsg s:MsgInsNotAvail  | echohl None
		return
	endif
	if col(".") > 1
		exe 'normal a'.s:Perl_Macro['|'.a:key.'|']
	else
		exe 'normal i'.s:Perl_Macro['|'.a:key.'|']
	endif
endfunction    " ----------  end of function Perl_InsertMacroValue  ----------

"------------------------------------------------------------------------------
"  insert date and time     {{{1
"------------------------------------------------------------------------------
function! Perl_InsertDateAndTime ( format )
	if &foldenable && foldclosed(".") >= 0
		echohl WarningMsg | echomsg s:MsgInsNotAvail  | echohl None
		return ""
	endif
	if col(".") > 1
		exe 'normal a'.Perl_DateAndTime(a:format)
	else
		exe 'normal i'.Perl_DateAndTime(a:format)
	endif
endfunction    " ----------  end of function Perl_InsertDateAndTime  ----------

"------------------------------------------------------------------------------
"  generate date and time     {{{1
"------------------------------------------------------------------------------
function! Perl_DateAndTime ( format )
	if a:format == 'd'
		return strftime( s:Perl_FormatDate )
	elseif a:format == 't'
		return strftime( s:Perl_FormatTime )
	elseif a:format == 'dt'
		return strftime( s:Perl_FormatDate ).' '.strftime( s:Perl_FormatTime )
	elseif a:format == 'y'
		return strftime( s:Perl_FormatYear )
	endif
endfunction    " ----------  end of function Perl_DateAndTime  ----------

"
"------------------------------------------------------------------------------
"  run : perltidy     {{{1
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
"
let s:Perl_perltidy_startscript_executable = 'no'
let s:Perl_perltidy_module_executable      = 'no'

function! Perl_Perltidy (mode)

  let Sou   = expand("%")               " name of the file in the current buffer
	if   (&filetype != 'perl') && 
				\ ( a:mode != 'v' || input( "'".Sou."' seems not to be a Perl file. Continue (y/n) : " ) != 'y' ) 
		echomsg "'".Sou."' seems not to be a Perl file."
		return
	endif
  "
  " check if perltidy start script is executable
  "
  if s:Perl_perltidy_startscript_executable == 'no'
    if !executable("perltidy")
      echohl WarningMsg
      echo 'perltidy does not exist or is not executable!'
      echohl None
      return
    else
      let s:Perl_perltidy_startscript_executable  = 'yes'
    endif
  endif
  "
  " check if perltidy module is executable
  " WORKAROUND: after upgrading Perl the module will no longer be found
  "
  if s:Perl_perltidy_module_executable == 'no'
    let perltidy_version = system("perltidy -v")
    if match( perltidy_version, 'copyright\c' )      >= 0 &&
    \  match( perltidy_version, 'Steve\s\+Hancock' ) >= 0
      let s:Perl_perltidy_module_executable = 'yes'
    else
      echohl WarningMsg
      echo 'The module Perl::Tidy can not be found! Please reinstall perltidy.'
      echohl None
      return
    endif
  endif
  " ----- normal mode ----------------
  if a:mode=="n"
    if Perl_Input("reformat whole file [y/n/Esc] : ", "y", '' ) != "y"
      return
    endif
    silent exe  ":update"
    let pos1  = line(".")
    if  s:MSWIN
      silent exe  "%!perltidy"
    else
      silent exe  "%!perltidy 2>/dev/null"
    endif
    exe ':'.pos1
    echo 'File "'.Sou.'" reformatted.'
  endif
  " ----- visual mode ----------------
  if a:mode=="v"

    let pos1  = line("'<")
    let pos2  = line("'>")
    if  s:MSWIN
      silent exe  pos1.",".pos2."!perltidy"
    else
      silent exe  pos1.",".pos2."!perltidy 2>/dev/null"
    endif
    echo 'File "'.Sou.'" (lines '.pos1.'-'.pos2.') reformatted.'
  endif
  "
  if filereadable("perltidy.ERR")
    echohl WarningMsg
    echo 'Perltidy detected an error when processing file "'.Sou.'". Please see file perltidy.ERR'
    echohl None
  endif
  "
endfunction   " ---------- end of function  Perl_Perltidy  ----------

"------------------------------------------------------------------------------
"  run : Save buffer with timestamp     {{{1
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! Perl_SaveWithTimestamp ()
  let file   = fnameescape( expand("%") ) " name of the file in the current buffer
  if file == ""
		" do we have a quickfix buffer : syntax errors / profiler report
		if &filetype == 'qf'
			let file	= getcwd().'/Quickfix-List'
		else
			redraw!
			echohl WarningMsg | echo " no file name " | echohl None
			return
		endif
  endif
  let file   = file.'.'.strftime(s:Perl_TimestampFormat)
  silent exe ":write ".file
  echomsg 'file "'.file.'" written'
endfunction   " ---------- end of function  Perl_SaveWithTimestamp  ----------
"
"------------------------------------------------------------------------------
"  run : hardcopy     {{{1
"    MSWIN : a printer dialog is displayed
"    other : print PostScript to file
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! Perl_Hardcopy (mode)
  let outfile = expand("%")
  if outfile == ""
    redraw!
    echohl WarningMsg | echo " no file name " | echohl None
    return
  endif
	let outdir	= getcwd()
	if outdir == substitute( s:Perl_PerlModuleList, '/[^/]\+$', '', '' ) || filewritable(outdir) != 2
		let outdir	= $HOME
	endif
	if  !s:MSWIN
		let outdir	= outdir.'/'
	endif

	let old_printheader=&printheader
	exe  ':set printheader='.s:Perl_Printheader
	" ----- normal mode ----------------
	if a:mode=="n"
		silent exe  'hardcopy > '.outdir.outfile.'.ps'
		if  !s:MSWIN
			echo 'file "'.outfile.'" printed to "'.outdir.outfile.'.ps"'
		endif
	endif
	" ----- visual mode ----------------
	if a:mode=="v"
		silent exe  "*hardcopy > ".outdir.outfile.".ps"
		if  !s:MSWIN
			echo 'file "'.outfile.'" (lines '.line("'<").'-'.line("'>").') printed to "'.outdir.outfile.'.ps"'
		endif
	endif
	exe  ':set printheader='.escape( old_printheader, ' %' )
endfunction   " ---------- end of function  Perl_Hardcopy  ----------
"
"------------------------------------------------------------------------------
"  run : help perlsupport      {{{1
"------------------------------------------------------------------------------
function! Perl_HelpPerlsupport ()
  try
    :help perlsupport
  catch
    exe ':helptags '.s:plugin_dir.'doc'
    :help perlsupport
  endtry
endfunction    " ----------  end of function Perl_HelpPerlsupport ----------
"
"------------------------------------------------------------------------------
"  run : perlcritic      {{{1
"------------------------------------------------------------------------------
"
" All formats consist of 2 parts:
"  1. the perlcritic message format
"  2. the trailing    '%+A%.%#\ at\ %f\ line\ %l%.%#'
" Part 1 rebuilds the original perlcritic message. This is done to make
" parsing of the messages easier.
" Part 2 captures errors from inside perlcritic if any.
" Some verbosity levels are treated equal to give quickfix the filename.
"
" verbosity rebuilt
"
let s:PCverbosityFormat1 	= 1
let s:PCverbosityFormat2 	= 2
let s:PCverbosityFormat3 	= 3
let s:PCverbosityFormat4 	= escape( '"%f:%l:%c:%m.  %e  (Severity: %s)\n"', '%' )
let s:PCverbosityFormat5 	= escape( '"%f:%l:%c:%m.  %e  (Severity: %s)\n"', '%' )
let s:PCverbosityFormat6 	= escape( '"%f:%l:%m, near ' . "'%r'." . '  (Severity: %s)\n"', '%' )
let s:PCverbosityFormat7 	= escape( '"%f:%l:%m, near ' . "'%r'." . '  (Severity: %s)\n"', '%' )
let s:PCverbosityFormat8 	= escape( '"%f:%l:%c:[%p] %m. (Severity: %s)\n"', '%' )
let s:PCverbosityFormat9 	= escape( '"%f:%l:[%p] %m, near ' . "'%r'" . '. (Severity: %s)\n"', '%' )
let s:PCverbosityFormat10	= escape( '"%f:%l:%c:%m.\n  %p (Severity: %s)\n%d\n"', '%' )
let s:PCverbosityFormat11	= escape( '"%f:%l:%m, near ' . "'%r'" . '.\n  %p (Severity: %s)\n%d\n"', '%' )
"
" parses output for different verbosity levels:
"
let s:PCInnerErrorFormat	= ',\%+A%.%#\ at\ %f\ line\ %l%.%#'
let s:PCerrorFormat1 			= '%f:%l:%c:%m'         . s:PCInnerErrorFormat
let s:PCerrorFormat2 			= '%f:\ (%l:%c)\ %m'    . s:PCInnerErrorFormat
let s:PCerrorFormat3 			= '%m\ at\ %f\ line\ %l'. s:PCInnerErrorFormat
let s:PCerrorFormat4 			= '%f:%l:%c:%m'         . s:PCInnerErrorFormat
let s:PCerrorFormat5 			= '%f:%l:%c:%m'         . s:PCInnerErrorFormat
let s:PCerrorFormat6 			= '%f:%l:%m'            . s:PCInnerErrorFormat
let s:PCerrorFormat7 			= '%f:%l:%m'            . s:PCInnerErrorFormat
let s:PCerrorFormat8 			= '%f:%l:%m'            . s:PCInnerErrorFormat
let s:PCerrorFormat9 			= '%f:%l:%m'            . s:PCInnerErrorFormat
let s:PCerrorFormat10			= '%f:%l:%m'            . s:PCInnerErrorFormat
let s:PCerrorFormat11			= '%f:%l:%m'            . s:PCInnerErrorFormat
"
"------------------------------------------------------------------------------
"  run : perlcritic (PC)
"------------------------------------------------------------------------------
function! Perl_Perlcritic ()
  let l:currentbuffer = bufname("%")
  if &filetype != "perl"
    echohl WarningMsg | echo l:currentbuffer.' seems not to be a Perl file' | echohl None
    return
  endif
  if executable("perlcritic") == 0                  " not executable
    echohl WarningMsg | echo 'perlcritic not installed or not executable' | echohl None
    return
  endif
  let s:Perl_PerlcriticMsg = ""
  exe ":cclose"
  silent exe  ":update"
	"
	" check for a configuration file
	"
	let	perlCriticRcFile			= ''
	let	perlCriticRcFileUsed	= 'no'
	if exists("$PERLCRITIC")
		let	perlCriticRcFile	= $PERLCRITIC
	elseif filereadable( '.perlcriticrc' )
		let	perlCriticRcFile	= '.perlcriticrc'
	elseif filereadable( $HOME.'/.perlcriticrc' )
		let	perlCriticRcFile	= $HOME.'/.perlcriticrc'
	endif
	"
	" read severity and/or verbosity from the configuration file if specified
	"
	if perlCriticRcFile != ''
		for line in readfile(perlCriticRcFile)
			" default settings come before the first named block
			if line =~ '^\s*['
				break
			else
				let	list = matchlist( line, '^\s*severity\s*=\s*\([12345]\)' )
				if !empty(list)
					let s:Perl_PerlcriticSeverity	= list[1]
					let	perlCriticRcFileUsed	= 'yes'
				endif
				let	list = matchlist( line, '^\s*severity\s*=\s*\(brutal\|cruel\|harsh\|stern\|gentle\)' )
				if !empty(list)
					let s:Perl_PerlcriticSeverity	= index( s:PCseverityName, list[1] )
					let	perlCriticRcFileUsed	= 'yes'
				endif
				let	list = matchlist( line, '^\s*verbose\s*=\s*\(\d\+\)' )
				if !empty(list) && 1<= list[1] && list[1] <= 11
					let s:Perl_PerlcriticVerbosity	= list[1]
					let	perlCriticRcFileUsed	= 'yes'
				endif
			endif
		endfor
	endif
	" 
  let perlcriticoptions	=
		  \      ' -severity '.s:Perl_PerlcriticSeverity
      \     .' -verbose '.eval("s:PCverbosityFormat".s:Perl_PerlcriticVerbosity)
      \     .' '.escape( s:Perl_PerlcriticOptions, s:escfilename )
      \     .' '
	"
  exe  ':setlocal errorformat='.eval("s:PCerrorFormat".s:Perl_PerlcriticVerbosity)
	:set makeprg=perlcritic
  "
	if  s:MSWIN
		silent exe ':make '.perlcriticoptions.'"'.expand("%:p").'"'
	else
		silent exe ':make '.perlcriticoptions.fnameescape( expand("%:p") )
	endif
  "
	redraw!
  exe ":botright cwindow"
  exe ':setlocal errorformat='
  exe "set makeprg=make"
  "
  " message in case of success
  "
	let sev_and_verb	= 'severity '.s:Perl_PerlcriticSeverity.
				\				      ' ['.s:PCseverityName[s:Perl_PerlcriticSeverity].']'.
				\							', verbosity '.s:Perl_PerlcriticVerbosity
	"
	let rcfile	= ''
	if perlCriticRcFileUsed == 'yes'
		let rcfile	= " ( configcfile '".perlCriticRcFile."' )"
	endif
  if l:currentbuffer ==  bufname("%")
		let s:Perl_PerlcriticMsg	= l:currentbuffer.' :  NO CRITIQUE, '.sev_and_verb.' '.rcfile
  else
    setlocal wrap
    setlocal linebreak
		let s:Perl_PerlcriticMsg	= 'perlcritic : '.sev_and_verb.rcfile
  endif
	redraw!
  echohl Search | echo s:Perl_PerlcriticMsg | echohl None
endfunction   " ---------- end of function  Perl_Perlcritic  ----------
"
"-------------------------------------------------------------------------------
"   set severity for perlcritic     {{{1
"-------------------------------------------------------------------------------
let s:PCseverityName	= [ "DUMMY", "brutal", "cruel", "harsh", "stern", "gentle" ]
let s:PCverbosityName	= [ '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11' ]

function!	Perl_PerlCriticSeverityList ( ArgLead, CmdLine, CursorPos )
	return filter( copy( s:PCseverityName[1:] ), 'v:val =~ "\\<'.a:ArgLead.'\\w*"' )
endfunction    " ----------  end of function Perl_PerlCriticSeverityList  ----------

function!	Perl_PerlCriticVerbosityList ( ArgLead, CmdLine, CursorPos )
	return filter( copy( s:PCverbosityName), 'v:val =~ "\\<'.a:ArgLead.'\\w*"' )
endfunction    " ----------  end of function Perl_PerlCriticVerbosityList  ----------

function! Perl_PerlCriticSeverity ( severity )
	let s:Perl_PerlcriticSeverity = 3                         " the default
	let	sev	= a:severity
	let sev	= substitute( sev, '^\s\+', '', '' )  	     			" remove leading whitespaces
	let sev	= substitute( sev, '\s\+$', '', '' )	       			" remove trailing whitespaces
	"
	if sev =~ '^\d$' && 1 <= sev && sev <= 5
		" parameter is numeric
		let s:Perl_PerlcriticSeverity = sev
		"
	elseif sev =~ '^\a\+$' 
		" parameter is a word
		let	nr	= index( s:PCseverityName, tolower(sev) )
		if nr > 0
			let s:Perl_PerlcriticSeverity = nr
		endif
	else
		"
		echomsg "wrong argument '".a:severity."' / severity is set to ".s:Perl_PerlcriticSeverity
		return
	endif
	echomsg "perlcritic severity is set to ".s:Perl_PerlcriticSeverity
endfunction    " ----------  end of function Perl_PerlCriticSeverity  ----------
"
"-------------------------------------------------------------------------------
"   set verbosity for perlcritic     {{{1
"-------------------------------------------------------------------------------
function! Perl_PerlCriticVerbosity ( verbosity )
	let s:Perl_PerlcriticVerbosity = 4
	let	vrb	= a:verbosity
  let vrb	= substitute( vrb, '^\s\+', '', '' )  	     			" remove leading whitespaces
  let vrb	= substitute( vrb, '\s\+$', '', '' )	       			" remove trailing whitespaces
  if vrb =~ '^\d\{1,2}$' && 1 <= vrb && vrb <= 11
    let s:Perl_PerlcriticVerbosity = vrb
		echomsg "perlcritic verbosity is set to ".s:Perl_PerlcriticVerbosity
	else
		echomsg "wrong argument '".a:verbosity."' / perlcritic verbosity is set to ".s:Perl_PerlcriticVerbosity
  endif
endfunction    " ----------  end of function Perl_PerlCriticVerbosity  ----------
"
"-------------------------------------------------------------------------------
"   set options for perlcritic     {{{1
"-------------------------------------------------------------------------------
function! Perl_PerlCriticOptions ( ... )
	let s:Perl_PerlcriticOptions = ""
	if a:0 > 0
		let s:Perl_PerlcriticOptions = a:1
	endif
endfunction    " ----------  end of function Perl_PerlCriticOptions  ----------
"
"------------------------------------------------------------------------------
"  Check the perlcritic default severity and verbosity.
"------------------------------------------------------------------------------
silent call Perl_PerlCriticSeverity (s:Perl_PerlcriticSeverity)
silent call Perl_PerlCriticVerbosity(s:Perl_PerlcriticVerbosity)

"------------------------------------------------------------------------------
"  Perl_CreateGuiMenus     {{{1
"------------------------------------------------------------------------------
let s:Perl_MenuVisible = 0								" state : 0 = not visible / 1 = visible
"
function! Perl_CreateGuiMenus ()
  if s:Perl_MenuVisible != 1
		aunmenu <silent> &Tools.Load\ Perl\ Support
    amenu   <silent> 40.1000 &Tools.-SEP100- :
    amenu   <silent> 40.1160 &Tools.Unload\ Perl\ Support :call Perl_RemoveGuiMenus()<CR>
    call perlsupportgui#Perl_InitMenu()
    let s:Perl_MenuVisible = 1
  endif
endfunction    " ----------  end of function Perl_CreateGuiMenus  ----------

"------------------------------------------------------------------------------
"  Perl_ToolMenu     {{{1
"------------------------------------------------------------------------------
function! Perl_ToolMenu ()
    amenu   <silent> 40.1000 &Tools.-SEP100- :
    amenu   <silent> 40.1160 &Tools.Load\ Perl\ Support :call Perl_CreateGuiMenus()<CR>
endfunction    " ----------  end of function Perl_ToolMenu  ----------

"------------------------------------------------------------------------------
"  Perl_RemoveGuiMenus     {{{1
"------------------------------------------------------------------------------
function! Perl_RemoveGuiMenus ()
  if s:Perl_MenuVisible == 1
    if g:Perl_Root == ""
      aunmenu <silent> Comments
      aunmenu <silent> Statements
      aunmenu <silent> Idioms
      aunmenu <silent> Snippets
      aunmenu <silent> Regex
      aunmenu <silent> File-Tests
      aunmenu <silent> Spec-Var
      aunmenu <silent> POD
      aunmenu <silent> Profiling
      aunmenu <silent> Run
      aunmenu <silent> help
    else
      exe "aunmenu <silent> ".g:Perl_Root
    endif
    "
    aunmenu <silent> &Tools.Unload\ Perl\ Support
		call Perl_ToolMenu()
    "
    let s:Perl_MenuVisible = 0
  endif
endfunction    " ----------  end of function Perl_RemoveGuiMenus  ----------

"------------------------------------------------------------------------------
"  Perl_do_tags     {{{1
"  tag a new file (Perl::Tags)
"------------------------------------------------------------------------------
function! Perl_do_tags(filename, tagsfile)

		perl <<EOF
		my $filename = VIM::Eval('a:filename');
		my $tagsfile = VIM::Eval('a:tagsfile');

		if ( -e $filename ) {
			$naive_tagger->process(files => $filename, refresh=>1 );
			}

		VIM::SetOption("tags+=$tagsfile");

		# of course, it may not even output, for example, if there's nothing new to process
		$naive_tagger->output( outfile => $tagsfile );
EOF

endfunction    " ----------  end of function Perl_do_tags  ----------
"
"------------------------------------------------------------------------------
"  show / hide the menus
"  define key mappings (gVim only)
"------------------------------------------------------------------------------
"
if has("gui_running")
	"
	call Perl_ToolMenu()

  if s:Perl_LoadMenus == 'yes'
    call Perl_CreateGuiMenus()
  endif
  "
  nmap	<silent>  <Leader>lps		:call Perl_CreateGuiMenus()<CR>
  nmap	<silent>  <Leader>ups		:call Perl_RemoveGuiMenus()<CR>
  "
endif
"
"------------------------------------------------------------------------------
"  Automated header insertion
"------------------------------------------------------------------------------
if has("autocmd")

	autocmd BufNewFile  *.pl  call Perl_InsertTemplate('comment.file-description-pl')
	autocmd BufNewFile  *.pm  call Perl_InsertTemplate('comment.file-description-pm')
	autocmd BufNewFile  *.t   call Perl_InsertTemplate('comment.file-description-t')

	autocmd BufRead  *.pl  call Perl_HighlightJumpTargets()
	autocmd BufRead  *.pm  call Perl_HighlightJumpTargets()
	autocmd BufRead  *.t   call Perl_HighlightJumpTargets() 
  "
  autocmd BufRead            *.pod  set filetype=perl
  autocmd BufNewFile         *.pod  set filetype=perl | call Perl_InsertTemplate('comment.file-description-pod')
  autocmd BufNewFile,BufRead *.t    set filetype=perl
  "
  " Wrap error descriptions in the quickfix window.
  autocmd BufReadPost quickfix  setlocal wrap | setlocal linebreak
  "
endif
"
let g:Perl_PerlRegexAnalyser			= 'yes'
"
"-------------------------------------------------------------------------------
"   initialize the Perl interface     {{{1
"-------------------------------------------------------------------------------
function! Perl_InitializePerlInterface( )
	if has('perl')
    perl <<INITIALIZE_PERL_INTERFACE
		#
    use utf8;                                   # Perl pragma to enable/disable UTF-8 in source
		use encoding ("utf8");

		# ---------------------------------------------------------------
		# find out the version of the Perl interface
		# ---------------------------------------------------------------
		my $perlversion=sprintf "%vd", $^V;
		VIM::DoCommand("let s:Perl_InterfaceVersion = \"$perlversion\"");
		#
		# ---------------------------------------------------------------
		# Perl_RegexVisualize (function)
		# ---------------------------------------------------------------
		# -- empty --
		#
		# ---------------------------------------------------------------
		# Perl_RegexExplain (function)
		# try to load the regex analyzer module; report failure
		# ---------------------------------------------------------------
		eval "require YAPE::Regex::Explain";
		if ( $@ ) {
			VIM::DoCommand("let g:Perl_PerlRegexAnalyser = 'no'");
			}
		#
INITIALIZE_PERL_INTERFACE

	endif		" ----- has('perl')
endfunction    " ----------  end of function Perl_InitializePerlInterface  ----------
"
"------------------------------------------------------------------------------
"  READ THE TEMPLATE FILES
"------------------------------------------------------------------------------
call Perl_RereadTemplates('no')
"
call Perl_InitializePerlInterface()
"
" vim: tabstop=2 shiftwidth=2 foldmethod=marker
