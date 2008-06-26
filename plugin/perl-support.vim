"###############################################################################################
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
"  Configuration:  There are at least some personal details which should be configured 
"                  (see the files README.perlsupport and perlsupport.txt).
"
"   Dependencies:  perl
"                  podchecker
"                  pod2html
"                  pod2man
"                  pod2text
"                  perldoc
"
"                  optional:
"
"                  ddd                  (debugger frontend)
"                  Devel::ptkdb         (debugger frontend)
"                  Devel::SmallProf     (profiler)
"                  Perl::Critic         (stylechecker)
"                  Perl::Tidy           (beautifier)
"                  YAPE::Regex::Explain (regular expression analyzer)
"
"         Author:  Dr.-Ing. Fritz Mehner <mehner@fh-swf.de>
"
"        Version:  see variable  g:Perl_Version  below 
"        Created:  09.07.2001
"        License:  Copyright (c) 2001-2008, Fritz Mehner
"                  This program is free software; you can redistribute it and/or
"                  modify it under the terms of the GNU General Public License as
"                  published by the Free Software Foundation, version 2 of the
"                  License.
"                  This program is distributed in the hope that it will be
"                  useful, but WITHOUT ANY WARRANTY; without even the implied
"                  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
"                  PURPOSE.
"                  See the GNU General Public License version 2 for more details.
"        Credits:  see perlsupport.txt
"       Revision:  $Id: perl-support.vim,v 1.44 2008/06/26 12:26:42 mehner Exp $
"------------------------------------------------------------------------------
" 
" Prevent duplicate loading: 
" 
if exists("g:Perl_Version") || &cp
 finish
endif
let g:Perl_Version= "3.8.1"
"        
"###############################################################################################
"
"  Global variables (with default values) which can be overridden.
"          
" Platform specific items:
" - plugin directory
" - characters that must be escaped for filenames
" 
let s:MSWIN = has("win16") || has("win32")   || has("win64")    || has("win95")
let s:UNIX	= has("unix")  || has("macunix") || has("win32unix")
" 
if  s:MSWIN
  " ==========  MS Windows  ======================================================
  let s:plugin_dir  = $VIM.'\vimfiles\'
  let s:escfilename = ''
	let s:Perl_CodeSnippets            = s:plugin_dir.'perl-support/codesnippets/'
  "
	let s:Perl_Display        = ''
	"
else
  "
  " ==========  Linux/Unix  ======================================================
	"
	" user / system wide installation
	"
	if match( expand("<sfile>"), $VIM ) >= 0
		" system wide installation 
		let s:plugin_dir  = $VIM.'/vimfiles/'
	else
		" user installation assumed
		let s:plugin_dir  = $HOME.'/.vim/'
	end
	"
	let s:escfilename = ' \%#[]'
  "
	let s:Perl_CodeSnippets            = $HOME.'/.vim/perl-support/codesnippets/'
	"
	let s:Perl_Display	= system("echo -n $DISPLAY")
	"
endif
"
let g:Perl_PluginDir	= s:plugin_dir         " used for communication with ftplugin/perl.vim
"
let g:Perl_PerlTags		= 'enabled'							" enable use of Perl::Tags
"
"  Key word completion is enabled by the filetype plugin 'perl.vim'
"  g:Perl_Dictionary_File  must be global
"          
if !exists("g:Perl_Dictionary_File")
  let g:Perl_Dictionary_File       = s:plugin_dir.'perl-support/wordlists/perl.list'
endif
"
"  Modul global variables (with default values) which can be overridden.
"
let s:Perl_AuthorName              = ''
let s:Perl_AuthorRef               = ''
let s:Perl_Email                   = ''
let s:Perl_Company                 = ''
let s:Perl_Project                 = ''
let s:Perl_CopyrightHolder         = ''

let s:Perl_Root                    = '&Perl.'
let s:Perl_LoadMenus               = 'yes'
let s:Perl_Template_Directory      = s:plugin_dir.'perl-support/templates/'
let s:Perl_Template_File           = 'perl-file-header'
let s:Perl_Template_Module         = 'perl-module-header'
let s:Perl_Template_Test           = 'perl-test-header'
let s:Perl_Template_Pod            = 'perl-pod'
let s:Perl_Template_Frame          = 'perl-frame'
let s:Perl_Template_Function       = 'perl-function-description'
let s:Perl_Template_Method         = 'perl-method-description'
let s:Perl_MenuHeader              = 'yes'
let s:Perl_PerlModuleList          = s:plugin_dir.'perl-support/modules/perl-modules.list'
let s:Perl_OutputGvim              = "vim"
let s:Perl_XtermDefaults           = "-fa courier -fs 12 -geometry 80x24"
let s:Perl_Debugger                = "perl"
let s:Perl_ProfilerTimestamp       = "no"
let s:Perl_LineEndCommColDefault   = 49
let s:Perl_BraceOnNewLine          = "no"
let s:Perl_PodcheckerWarnings      = "yes"
let s:Perl_PerlcriticOptions       = ""
let s:Perl_PerlcriticSeverity      = 5
let s:Perl_PerlcriticVerbosity     = 5
let s:Perl_Printheader             = "%<%f%h%m%<  %=%{strftime('%x %X')}     Page %N"
"
let s:Perl_Wrapper                 = s:plugin_dir.'perl-support/scripts/wrapper.sh'
let s:Perl_EfmPerl                 = s:plugin_dir.'perl-support/scripts/efm_perl.pl'
let s:Perl_PerlModuleListGenerator = s:plugin_dir.'perl-support/scripts/pmdesc3.pl'
let s:Perl_PBP										 = 'no'
let s:Perl_PerlRegexSubstitution   = '$~'

"
"------------------------------------------------------------------------------
"
"  Look for global variables (if any), to override the defaults.
"  
function! Perl_CheckGlobal ( name )
  if exists('g:'.a:name)
    exe 'let s:'.a:name.'  = g:'.a:name
  endif
endfunction   " ---------- end of function  Perl_CheckGlobal  ----------
"
call Perl_CheckGlobal("Perl_AuthorName             ")
call Perl_CheckGlobal("Perl_AuthorRef              ")
call Perl_CheckGlobal("Perl_BraceOnNewLine         ")
call Perl_CheckGlobal("Perl_CodeSnippets           ")
call Perl_CheckGlobal("Perl_Company                ")
call Perl_CheckGlobal("Perl_CopyrightHolder        ")
call Perl_CheckGlobal("Perl_Debugger               ")
call Perl_CheckGlobal("Perl_Email                  ")
call Perl_CheckGlobal("Perl_LineEndCommColDefault  ")
call Perl_CheckGlobal("Perl_LoadMenus              ")
call Perl_CheckGlobal("Perl_MenuHeader             ")
call Perl_CheckGlobal("Perl_OutputGvim             ")
call Perl_CheckGlobal("Perl_PBP                    ")
call Perl_CheckGlobal("Perl_PerlcriticOptions      ")
call Perl_CheckGlobal("Perl_PerlcriticSeverity     ")
call Perl_CheckGlobal("Perl_PerlcriticVerbosity    ")
call Perl_CheckGlobal("Perl_PerlModuleList         ")
call Perl_CheckGlobal("Perl_PerlModuleListGenerator")
call Perl_CheckGlobal("Perl_PerlRegexSubstitution  ")
call Perl_CheckGlobal("Perl_PodcheckerWarnings     ")
call Perl_CheckGlobal("Perl_Printheader            ")
call Perl_CheckGlobal("Perl_ProfilerTimestamp      ")
call Perl_CheckGlobal("Perl_Project                ")
call Perl_CheckGlobal("Perl_Root                   ")
call Perl_CheckGlobal("Perl_Template_Directory     ")
call Perl_CheckGlobal("Perl_Template_File          ")
call Perl_CheckGlobal("Perl_Template_Frame         ")
call Perl_CheckGlobal("Perl_Template_Function      ")
call Perl_CheckGlobal("Perl_Template_Method        ")
call Perl_CheckGlobal("Perl_Template_Module        ")
call Perl_CheckGlobal("Perl_Template_Pod           ")
call Perl_CheckGlobal("Perl_Template_Test          ")
call Perl_CheckGlobal("Perl_XtermDefaults          ")
"
let s:Perl_PerlcriticMsg     = ""
let s:Perl_PodCheckMsg       = ""
let s:Perl_SyntaxCheckMsg    = ""
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
let s:Perl_Printheader  = escape( s:Perl_Printheader, ' %' )
"
let s:Perl_InterfaceVersion = ''
"
"------------------------------------------------------------------------------
" Perl Menu Initializations
" Against the advice of every style guide this function has overlong lines
" to enable the use of block commands when editing.
"------------------------------------------------------------------------------
function! Perl_InitMenu ()
  "
  if has("gui_running")

    if s:Perl_Root != ""
      if s:Perl_MenuHeader == "yes"
        exe "amenu ".s:Perl_Root.'Perl     <Nop>'
        exe "amenu ".s:Perl_Root.'-Sep0-        :'
      endif
    endif
    "
    "---------- Comments-Menu ----------------------------------------------------------------------
    "
    if s:Perl_MenuHeader == "yes"
      exe "amenu ".s:Perl_Root.'&Comments.&Comments<Tab>Perl     <Nop>'
      exe "amenu ".s:Perl_Root.'&Comments.-Sep0-        :'
    endif

		exe "amenu <silent>  ".s:Perl_Root.'&Comments.end-of-&line\ com\.                   :call Perl_LineEndComment("")<CR>A'
		exe "imenu <silent>  ".s:Perl_Root.'&Comments.end-of-&line\ com\.              <C-C>:call Perl_LineEndComment("")<CR>A'
    exe "vmenu <silent>  ".s:Perl_Root.'&Comments.end-of-&line\ com\.              <C-C>:call Perl_MultiLineEndComments()<CR>A'
		"
		exe "amenu <silent>  ".s:Perl_Root.'&Comments.ad&just\ end-of-line\ com\.           :call Perl_AlignLineEndComm("a")<CR>'
		exe "vmenu <silent>  ".s:Perl_Root.'&Comments.ad&just\ end-of-line\ com\.      <C-C>:call Perl_AlignLineEndComm("v")<CR>'
		"
    exe "amenu <silent>  ".s:Perl_Root.'&Comments.&set\ end-of-line\ com\.\ col\.       :call Perl_GetLineEndCommCol()<CR>'
    exe "amenu <silent>  ".s:Perl_Root.'&Comments.&frame\ comm\.                        :call Perl_CommentTemplates("frame")<CR>'
    exe "amenu <silent>  ".s:Perl_Root.'&Comments.f&unction\ descr\.                    :call Perl_CommentTemplates("function")<CR>'
    exe "amenu <silent>  ".s:Perl_Root.'&Comments.&method\ descr\.                      :call Perl_CommentTemplates("method")<CR>'
    exe "amenu <silent>  ".s:Perl_Root.'&Comments.file\ &header\ (\.pl)                 :call Perl_CommentTemplates("header")<CR>'
    exe "amenu <silent>  ".s:Perl_Root.'&Comments.file\ h&eader\ (\.pm)                 :call Perl_CommentTemplates("module")<CR>'
    exe "amenu <silent>  ".s:Perl_Root.'&Comments.file\ he&ader\ (\.t)                  :call Perl_CommentTemplates("test")<CR>'

    exe "amenu ".s:Perl_Root.'&Comments.-SEP1-                     :'
    "
    exe "amenu <silent>  ".s:Perl_Root."&Comments.toggle\\ &comment         :call Perl_CommentToggle()<CR>j"
    exe "imenu <silent>  ".s:Perl_Root."&Comments.toggle\\ &comment    <C-C>:call Perl_CommentToggle()<CR>j"
    exe "vmenu <silent>  ".s:Perl_Root."&Comments.toggle\\ &comment    <C-C>:'<,'>call Perl_CommentToggle()<CR>j"

    exe "amenu <silent>  ".s:Perl_Root.'&Comments.comment\ &block           :call Perl_CommentBlock("a")<CR>'
    exe "imenu <silent>  ".s:Perl_Root.'&Comments.comment\ &block      <C-C>:call Perl_CommentBlock("a")<CR>'
    exe "vmenu <silent>  ".s:Perl_Root.'&Comments.comment\ &block      <C-C>:call Perl_CommentBlock("v")<CR>'
    exe "amenu <silent>  ".s:Perl_Root.'&Comments.u&ncomment\ block         :call Perl_UncommentBlock()<CR>'
    "
    exe "amenu ".s:Perl_Root.'&Comments.-SEP2-               :'
    "
		" %x : The preferred date representation for the current locale without the time.
		"
    exe " menu ".s:Perl_Root.'&Comments.&date                a<C-R>=strftime("%x")<CR>'
    exe "imenu ".s:Perl_Root.'&Comments.&date                 <C-R>=strftime("%x")<CR>'
		" 
		" %x : The preferred date representation for the current locale without the time.
		" %X : The preferred time representation for the current locale without the date.
		" %Z : The time zone or name or abbreviation.
		"
    exe " menu ".s:Perl_Root.'&Comments.date\ &time          a<C-R>=strftime("%x %X %Z")<CR>'
    exe "imenu ".s:Perl_Root.'&Comments.date\ &time           <C-R>=strftime("%x %X %Z")<CR>'

    exe "amenu ".s:Perl_Root.'&Comments.-SEP3-                     :'
    "
    "--------- submenu : KEYWORD -------------------------------------------------------------
    "
    if s:Perl_MenuHeader == "yes"
      exe "amenu ".s:Perl_Root.'&Comments.#:&KEYWORD\:.Comments-1<Tab>Perl   <Nop>'
      exe "amenu ".s:Perl_Root.'&Comments.#:&KEYWORD\:.-Sep0-      :'
    endif
    "
    exe "amenu ".s:Perl_Root.'&Comments.#:&KEYWORD\:.&BUG             :call Perl_CommentClassified("BUG")       <CR>A'
    exe "amenu ".s:Perl_Root.'&Comments.#:&KEYWORD\:.&TODO            :call Perl_CommentClassified("TODO")      <CR>A'
    exe "amenu ".s:Perl_Root.'&Comments.#:&KEYWORD\:.T&RICKY          :call Perl_CommentClassified("TRICKY")    <CR>A'
    exe "amenu ".s:Perl_Root.'&Comments.#:&KEYWORD\:.&WARNING         :call Perl_CommentClassified("WARNING")   <CR>A'
    exe "amenu ".s:Perl_Root.'&Comments.#:&KEYWORD\:.W&ORKAROUND      :call Perl_CommentClassified("WORKAROUND")<CR>A'
    exe "amenu ".s:Perl_Root.'&Comments.#:&KEYWORD\:.&new\ keyword    :call Perl_CommentClassified("")          <CR>3F:i'
    "
    exe "imenu ".s:Perl_Root.'&Comments.#:&KEYWORD\:.&BUG             <C-C>:call Perl_CommentClassified("BUG")       <CR>A'
    exe "imenu ".s:Perl_Root.'&Comments.#:&KEYWORD\:.&TODO            <C-C>:call Perl_CommentClassified("TODO")      <CR>A'
    exe "imenu ".s:Perl_Root.'&Comments.#:&KEYWORD\:.T&RICKY          <C-C>:call Perl_CommentClassified("TRICKY")    <CR>A'
    exe "imenu ".s:Perl_Root.'&Comments.#:&KEYWORD\:.&WARNING         <C-C>:call Perl_CommentClassified("WARNING")   <CR>A'
    exe "imenu ".s:Perl_Root.'&Comments.#:&KEYWORD\:.W&ORKAROUND      <C-C>:call Perl_CommentClassified("WORKAROUND")<CR>A'
    exe "imenu ".s:Perl_Root.'&Comments.#:&KEYWORD\:.&new\ keyword    <C-C>:call Perl_CommentClassified("")          <CR>3F:i'
    "
    "
    "----- Submenu :  Tags  ----------------------------------------------------------
    "
    if s:Perl_MenuHeader == "yes"
      exe "amenu ".s:Perl_Root.'&Comments.ta&gs\ (plugin).Comments-2<Tab>Perl   <Nop>'
      exe "amenu ".s:Perl_Root.'&Comments.ta&gs\ (plugin).-Sep0-      :'
    endif
    "
    exe "amenu  ".s:Perl_Root.'&Comments.ta&gs\ (plugin).&AUTHOR           a'.s:Perl_AuthorName."<Esc>"
    exe "amenu  ".s:Perl_Root.'&Comments.ta&gs\ (plugin).AUTHOR&REF        a'.s:Perl_AuthorRef."<Esc>"
    exe "amenu  ".s:Perl_Root.'&Comments.ta&gs\ (plugin).&COMPANY          a'.s:Perl_Company."<Esc>"
    exe "amenu  ".s:Perl_Root.'&Comments.ta&gs\ (plugin).C&OPYRIGHTHOLDER  a'.s:Perl_CopyrightHolder."<Esc>"
    exe "amenu  ".s:Perl_Root.'&Comments.ta&gs\ (plugin).&EMAIL            a'.s:Perl_Email."<Esc>"
    exe "amenu  ".s:Perl_Root.'&Comments.ta&gs\ (plugin).&PROJECT          a'.s:Perl_Project."<Esc>"

    exe "imenu  ".s:Perl_Root.'&Comments.ta&gs\ (plugin).&AUTHOR           <Esc>a'.s:Perl_AuthorName
    exe "imenu  ".s:Perl_Root.'&Comments.ta&gs\ (plugin).AUTHOR&REF        <Esc>a'.s:Perl_AuthorRef
    exe "imenu  ".s:Perl_Root.'&Comments.ta&gs\ (plugin).&COMPANY          <Esc>a'.s:Perl_Company
    exe "imenu  ".s:Perl_Root.'&Comments.ta&gs\ (plugin).C&OPYRIGHTHOLDER  <Esc>a'.s:Perl_CopyrightHolder
    exe "imenu  ".s:Perl_Root.'&Comments.ta&gs\ (plugin).&EMAIL            <Esc>a'.s:Perl_Email
    exe "imenu  ".s:Perl_Root.'&Comments.ta&gs\ (plugin).&PROJECT          <Esc>a'.s:Perl_Project
    "
    "
    exe "amenu <silent>  ".s:Perl_Root.'&Comments.&vim\ modeline           :call Perl_CommentVimModeline()<CR>'

    "---------- Statements-Menu ----------------------------------------------------------------------

    if s:Perl_MenuHeader == "yes"
      exe "amenu ".s:Perl_Root.'&Statements.&Statements<Tab>Perl     <Nop>'
      exe "amenu ".s:Perl_Root.'&Statements.-Sep0-        :'
    endif
    "
    exe "amenu <silent> ".s:Perl_Root.'&Statements.&do\ \{\ \}\ while              :call Perl_DoWhile("a")<CR>f(la'
    exe "amenu <silent> ".s:Perl_Root.'&Statements.&for\ \{\ \}                    :call Perl_StatBlock( "a", "for ( my $; ;  ) {\n}","" )<CR>f$a'
    exe "amenu <silent> ".s:Perl_Root.'&Statements.f&oreach\ \{\ \}                :call Perl_StatBlock( "a", "foreach my $ (  ) {\n}", "" )<CR>f$a'
    exe "amenu <silent> ".s:Perl_Root.'&Statements.&if\ \{\ \}                     :call Perl_StatBlock( "a", "if (  ) {\n}", "" )<CR>f(la'
    exe "amenu <silent> ".s:Perl_Root.'&Statements.if\ \{\ \}\ &else\ \{\ \}       :call Perl_StatBlock( "a", "if (  ) {\n}\nelse {\n}", "" )<CR>f(la'
    exe "amenu <silent> ".s:Perl_Root.'&Statements.&unless\ \{\ \}                 :call Perl_StatBlock( "a", "unless (  ) {\n}", "" )<CR>f(la'
    exe "amenu <silent> ".s:Perl_Root.'&Statements.u&nless\ \{\ \}\ else\ \{\ \}   :call Perl_StatBlock( "a", "unless (  ) {\n}\nelse {\n}", "" )<CR>f(la'
    exe "amenu <silent> ".s:Perl_Root.'&Statements.un&til\ \{\ \}                  :call Perl_StatBlock( "a", "until (  ) {\n}", "" )<CR>f(la'
    exe "amenu <silent> ".s:Perl_Root.'&Statements.&while\ \{\ \}                  :call Perl_StatBlock( "a", "while (  ) {\n}", "" )<CR>f(la'
    exe "amenu <silent> ".s:Perl_Root.'&Statements.&\{\ \}                         :call Perl_Block("a")<CR>o'
    "
    exe "imenu <silent> ".s:Perl_Root.'&Statements.&do\ \{\ \}\ while              <C-C>:call Perl_DoWhile("a")<CR>f(la'
    exe "imenu <silent> ".s:Perl_Root.'&Statements.&for\ \{\ \}                    <C-C>:call Perl_StatBlock( "a", "for ( my $; ;  ) {\n}","" )<CR>f$a'
    exe "imenu <silent> ".s:Perl_Root.'&Statements.f&oreach\ \{\ \}                <C-C>:call Perl_StatBlock( "a", "foreach my $ (  ) {\n}", "" )<CR>f$a'
    exe "imenu <silent> ".s:Perl_Root.'&Statements.&if\ \{\ \}                     <C-C>:call Perl_StatBlock( "a", "if (  ) {\n}", "" )<CR>f(la'
    exe "imenu <silent> ".s:Perl_Root.'&Statements.if\ \{\ \}\ &else\ \{\ \}       <C-C>:call Perl_StatBlock( "a", "if (  ) {\n}\nelse {\n}", "" )<CR>f(la'
    exe "imenu <silent> ".s:Perl_Root.'&Statements.&unless\ \{\ \}                 <C-C>:call Perl_StatBlock( "a", "unless (  ) {\n}", "" )<CR>f(la'
    exe "imenu <silent> ".s:Perl_Root.'&Statements.u&nless\ \{\ \}\ else\ \{\ \}   <C-C>:call Perl_StatBlock( "a", "unless (  ) {\n}\nelse {\n}", "" )<CR>f(la'
    exe "imenu <silent> ".s:Perl_Root.'&Statements.un&til\ \{\ \}                  <C-C>:call Perl_StatBlock( "a", "until (  ) {\n}", "" )<CR>f(la'
    exe "imenu <silent> ".s:Perl_Root.'&Statements.&while\ \{\ \}                  <C-C>:call Perl_StatBlock( "a", "while (  ) {\n}", "" )<CR>f(la'
    exe "imenu <silent> ".s:Perl_Root.'&Statements.&\{\ \}                         <C-C>:call Perl_Block("a")<CR>o'
    "
    exe "vmenu <silent> ".s:Perl_Root.'&Statements.&do\ \{\ \}\ while              <C-C>:call Perl_DoWhile("v")<CR>f(la'
    exe "vmenu <silent> ".s:Perl_Root.'&Statements.&for\ \{\ \}                    <C-C>:call Perl_StatBlock( "v", "for ( my $; ;  ) {", "}" )<CR>f$a'
    exe "vmenu <silent> ".s:Perl_Root.'&Statements.f&oreach\ \{\ \}                <C-C>:call Perl_StatBlock( "v", "foreach my $ (  ) {", "}" )<CR>f$a'
    exe "vmenu <silent> ".s:Perl_Root.'&Statements.&if\ \{\ \}                     <C-C>:call Perl_StatBlock( "v", "if (  ) {", "}" )<CR>f(la'
    exe "vmenu <silent> ".s:Perl_Root.'&Statements.if\ \{\ \}\ &else\ \{\ \}       <C-C>:call Perl_StatBlock( "v", "if (  ) {", "}\nelse {\n}" )<CR>f(la'
    exe "vmenu <silent> ".s:Perl_Root.'&Statements.&unless\ \{\ \}                 <C-C>:call Perl_StatBlock( "v", "unless (  ) {", "}" )<CR>f(la'
    exe "vmenu <silent> ".s:Perl_Root.'&Statements.u&nless\ \{\ \}\ else\ \{\ \}   <C-C>:call Perl_StatBlock( "v", "unless (  ) {", "}\nelse {\n}" )<CR>f(la'
    exe "vmenu <silent> ".s:Perl_Root.'&Statements.un&til\ \{\ \}                  <C-C>:call Perl_StatBlock( "v", "until (  ) {", "}" )<CR>f(la'
    exe "vmenu <silent> ".s:Perl_Root.'&Statements.&while\ \{\ \}                  <C-C>:call Perl_StatBlock( "v", "while (  ) {", "}" )<CR>f(la'
    exe "vmenu <silent> ".s:Perl_Root.'&Statements.&\{\ \}                         <C-C>:call Perl_Block("v")<CR>'
    "
    " The menu entries for code snippet support will not appear if the following string is empty 
    if s:Perl_CodeSnippets != ""
      exe "amenu ".s:Perl_Root.'&Statements.-SEP6-                            :'
      exe "amenu <silent>  ".s:Perl_Root.'&Statements.&read\ code\ snippet    :call Perl_CodeSnippet("r")<CR>'
      exe "amenu <silent>  ".s:Perl_Root.'&Statements.&write\ code\ snippet   :call Perl_CodeSnippet("w")<CR>'
      exe "vmenu <silent>  ".s:Perl_Root.'&Statements.&write\ code\ snippet   :call Perl_CodeSnippet("wv")<CR>'
      exe "amenu <silent>  ".s:Perl_Root.'&Statements.e&dit\ code\ snippet    :call Perl_CodeSnippet("e")<CR>'
    endif
    "
    "---------- submenu : idioms -------------------------------------------------------------
    "
    if s:Perl_MenuHeader == "yes"
      exe "amenu ".s:Perl_Root.'&Idioms.&Idioms<Tab>Perl    <Nop>'
      exe "amenu ".s:Perl_Root.'&Idioms.-Sep0-       :'
    endif
    "
    exe "nnoremenu <silent> ".s:Perl_Root.'&Idioms.my\ &$;                         o<C-C>:call Perl_Idiom(  "\$", "my<Tab>$;",                       "$" )<CR>a'
    exe "nnoremenu <silent> ".s:Perl_Root.'&Idioms.my\ $\ &=\ ;                    o<C-C>:call Perl_Idiom( "\$=", "my<Tab>$<Tab>= ;",                "$" )<CR>a'
    exe "nnoremenu <silent> ".s:Perl_Root.'&Idioms.my\ (\ $&,\ $\ );               o<C-C>:call Perl_Idiom( "\$$", "my<Tab>( $, $ );",                "$" )<CR>a'
    exe "nnoremenu <silent> ".s:Perl_Root.'&Idioms.my\ &@;                         o<C-C>:call Perl_Idiom(  "\@", "my<Tab>@;",                       "@" )<CR>a'
    exe "nnoremenu <silent> ".s:Perl_Root.'&Idioms.my\ @\ =\ (,,);\ \ \ \ \ (&1)   o<C-C>:call Perl_Idiom( "\@=", "my<Tab>@<Tab>= ( , ,  );",        "@" )<CR>a'
    exe "nnoremenu <silent> ".s:Perl_Root.'&Idioms.my\ &%;                         o<C-C>:call Perl_Idiom(  "\%", "my<Tab>%;",                       "%" )<CR>a'
    exe "nnoremenu <silent> ".s:Perl_Root.'&Idioms.my\ %\ =\ (=>,);\ \ \ \ \ (&2)  o<C-C>:call Perl_Idiom( "\%=", "my<Tab>%<Tab>= (  => ,  => , );", "%" )<CR>a'
    "
    exe "inoremenu <silent> ".s:Perl_Root.'&Idioms.my\ &$;                         <C-C>:call Perl_Idiom( "", "my<Tab>$;",                       "$" )<CR>a'
    exe "inoremenu <silent> ".s:Perl_Root.'&Idioms.my\ $\ &=\ ;                    <C-C>:call Perl_Idiom( "", "my<Tab>$<Tab>= ;",                "$" )<CR>a'
    exe "inoremenu <silent> ".s:Perl_Root.'&Idioms.my\ (\ $&,\ $\ );               <C-C>:call Perl_Idiom( "", "my<Tab>( $, $ );",                "$" )<CR>a'
    exe "inoremenu <silent> ".s:Perl_Root.'&Idioms.my\ &@;                         <C-C>:call Perl_Idiom( "", "my<Tab>@;",                       "@" )<CR>a'
    exe "inoremenu <silent> ".s:Perl_Root.'&Idioms.my\ @\ =\ (,,);\ \ \ \ \ (&1)   <C-C>:call Perl_Idiom( "", "my<Tab>@<Tab>= ( , ,  );",        "@" )<CR>a'
    exe "inoremenu <silent> ".s:Perl_Root.'&Idioms.my\ &%;                         <C-C>:call Perl_Idiom( "", "my<Tab>%;",                       "%" )<CR>a'
    exe "inoremenu <silent> ".s:Perl_Root.'&Idioms.my\ %\ =\ (=>,);\ \ \ \ \ (&2)  <C-C>:call Perl_Idiom( "", "my<Tab>%<Tab>= (  => ,  => , );", "%" )<CR>a'
    "
    exe "anoremenu ".s:Perl_Root.'&Idioms.my\ $rgx_\ =\ q//;\ \ \ (&3)    omy<Tab>$rgx_<Tab>= q//;<Esc>F_a'
    exe "anoremenu ".s:Perl_Root.'&Idioms.-SEP3-                        :'
		if s:Perl_PBP == "yes"
			exe "anoremenu ".s:Perl_Root.'&Idioms.$\ =~\ &m\{\ \}xm             a$ =~ m{}xm<Esc>F$a'
			exe "anoremenu ".s:Perl_Root.'&Idioms.$\ =~\ &s\{\ \}\{\ \}xm       a$ =~ s{}{}xm<Esc>F$a'
			exe "anoremenu ".s:Perl_Root.'&Idioms.$\ =~\ &tr\{\ \}\{\ \}xm      a$ =~ tr{}{}xm<Esc>F$a'
		else
			exe "anoremenu ".s:Perl_Root.'&Idioms.$\ =~\ &m/\ /                 a$ =~ m//<Esc>F$a'
			exe "anoremenu ".s:Perl_Root.'&Idioms.$\ =~\ &s/\ /\ /              a$ =~ s///<Esc>F$a'
			exe "anoremenu ".s:Perl_Root.'&Idioms.$\ =~\ &tr/\ /\ /             a$ =~ tr///<Esc>F$a'
		endif
    exe " noremenu ".s:Perl_Root.'&Idioms.-SEP4-                    :'
    exe "anoremenu ".s:Perl_Root.'&Idioms.s&ubroutine                     :call Perl_Subroutine("a")<CR>A'
    exe "vnoremenu ".s:Perl_Root.'&Idioms.s&ubroutine                     :call Perl_Subroutine("v")<CR>f(a'
		"
    exe "anoremenu ".s:Perl_Root.'&Idioms.&print\ \"\.\.\.\\n\";          aprint "\n";<Left><Left><Left><Left>'
    exe "inoremenu ".s:Perl_Root.'&Idioms.&print\ \"\.\.\.\\n\";           print "\n";<Left><Left><Left><Left>'
		"
    exe "anoremenu ".s:Perl_Root.'&Idioms.open\ &input\ file              :call Perl_OpenInputFile("a")<CR>a'
    exe "inoremenu ".s:Perl_Root.'&Idioms.open\ &input\ file         <C-C>:call Perl_OpenInputFile("a")<CR>a'
    exe "vnoremenu ".s:Perl_Root.'&Idioms.open\ &input\ file         <C-C>:call Perl_OpenInputFile("v")<CR>a'
		"
    exe "anoremenu ".s:Perl_Root.'&Idioms.open\ &output\ file             :call Perl_OpenOutputFile("a")<CR>a'
    exe "inoremenu ".s:Perl_Root.'&Idioms.open\ &output\ file        <C-C>:call Perl_OpenOutputFile("a")<CR>a'
    exe "vnoremenu ".s:Perl_Root.'&Idioms.open\ &output\ file        <C-C>:call Perl_OpenOutputFile("v")<CR>a'
		"
    exe "anoremenu ".s:Perl_Root.'&Idioms.open\ pip&e                     :call Perl_OpenPipe("a")<CR>a'
    exe "inoremenu ".s:Perl_Root.'&Idioms.open\ pip&e                <C-C>:call Perl_OpenPipe("a")<CR>a'
    exe "vnoremenu ".s:Perl_Root.'&Idioms.open\ pip&e                <C-C>:call Perl_OpenPipe("v")<CR>a'
		"
    exe "anoremenu ".s:Perl_Root.'&Idioms.-SEP5-                    :'
    exe "anoremenu ".s:Perl_Root.'&Idioms.<STDIN>                         a<STDIN>'
    exe "anoremenu ".s:Perl_Root.'&Idioms.<STDOUT>                        a<STDOUT>'
    exe "anoremenu ".s:Perl_Root.'&Idioms.<STDERR>                        a<STDERR>'
    exe "inoremenu ".s:Perl_Root.'&Idioms.<STDIN>                         <STDIN>'
    exe "inoremenu ".s:Perl_Root.'&Idioms.<STDOUT>                        <STDOUT>'
    exe "inoremenu ".s:Perl_Root.'&Idioms.<STDERR>                        <STDERR>'
    exe "inoremenu ".s:Perl_Root.'&Idioms.-SEP7-                    :'
    "
    "---------- submenu : Regular Expression Suport  -----------------------------------------
    "
    if s:Perl_MenuHeader == "yes"
      exe "amenu ".s:Perl_Root.'Rege&x.Rege&x<Tab>Perl      <Nop>'
      exe "amenu ".s:Perl_Root.'Rege&x.-Sep0-         :'
    endif
    "
    exe "anoremenu ".s:Perl_Root.'Rege&x.&grouping<Tab>(\ )               a()<Left>'
    exe "anoremenu ".s:Perl_Root.'Rege&x.&alternation<Tab>(\ \|\ )        a(\|)<Left><Left>'
    exe "anoremenu ".s:Perl_Root.'Rege&x.char\.\ &class<Tab>[\ ]          a[]<Left>'
    exe "anoremenu ".s:Perl_Root.'Rege&x.c&ount<Tab>{\ }                  a{}<Left>'
    exe "anoremenu ".s:Perl_Root.'Rege&x.co&unt\ (at\ least)<Tab>{\ ,\ }  a{,}<Left><Left>'
    "
    exe "inoremenu ".s:Perl_Root.'Rege&x.&grouping<Tab>(\ )               ()<Left>'
    exe "inoremenu ".s:Perl_Root.'Rege&x.&alternation<Tab>(\ \|\ )        (\|)<Left><Left>'
    exe "inoremenu ".s:Perl_Root.'Rege&x.char\.\ &class<Tab>[\ ]          []<Left>'
    exe "inoremenu ".s:Perl_Root.'Rege&x.c&ount<Tab>{\ }                  {}<Left>'
    exe "inoremenu ".s:Perl_Root.'Rege&x.co&unt\ (at\ least)<Tab>{\ ,\ }  {,}<Left><Left>'

    exe "vnoremenu ".s:Perl_Root.'Rege&x.&grouping<Tab>(\ )               s()<Esc>P'
    exe "vnoremenu ".s:Perl_Root.'Rege&x.&alternation<Tab>(\ \|\ )        s(\|)<Esc>hPf)i'
    exe "vnoremenu ".s:Perl_Root.'Rege&x.char\.\ &class<Tab>[\ ]          s[]<Esc>P'
    exe "vnoremenu ".s:Perl_Root.'Rege&x.c&ount<Tab>{\ }                  s{}<Esc>P'
    exe "vnoremenu ".s:Perl_Root.'Rege&x.co&unt\ (at\ least)<Tab>{\ ,\ }  s{,}<Esc>hPf}i'
    "
    exe " menu ".s:Perl_Root.'Rege&x.-SEP3-                             :'
    "
    exe "anoremenu ".s:Perl_Root.'Rege&x.word\ &boundary<Tab>\\b              a\b'
    exe "inoremenu ".s:Perl_Root.'Rege&x.word\ &boundary<Tab>\\b               \b'
    exe "anoremenu ".s:Perl_Root.'Rege&x.&digit<Tab>\\d                       a\d'
    exe "inoremenu ".s:Perl_Root.'Rege&x.&digit<Tab>\\d                        \d'
    exe "anoremenu ".s:Perl_Root.'Rege&x.white&space<Tab>\\s                  a\s'
    exe "inoremenu ".s:Perl_Root.'Rege&x.white&space<Tab>\\s                   \s'
    exe "anoremenu ".s:Perl_Root.'Rege&x.&word\ character<Tab>\\w             a\w'
    exe "inoremenu ".s:Perl_Root.'Rege&x.&word\ character<Tab>\\w              \w'
    exe "anoremenu ".s:Perl_Root.'Rege&x.match\ &property<Tab>\\p{}           a\p{}<Left>'
    exe "inoremenu ".s:Perl_Root.'Rege&x.match\ &property<Tab>\\p{}            \p{}<Left>'
    exe "vnoremenu ".s:Perl_Root.'Rege&x.match\ &property<Tab>\\p{}           s\p{}<Esc>P'

    exe "anoremenu ".s:Perl_Root.'Rege&x.-SEP4-                         :'
		exe "anoremenu ".s:Perl_Root.'Rege&x.non-(word\ &bound\.)<Tab>\\B   			a\B'
    exe "inoremenu ".s:Perl_Root.'Rege&x.non-(word\ &bound\.)<Tab>\\B   			 \B'
    exe "anoremenu ".s:Perl_Root.'Rege&x.non-&digit<Tab>\\D             			a\D'
    exe "inoremenu ".s:Perl_Root.'Rege&x.non-&digit<Tab>\\D             			 \D'
    exe "anoremenu ".s:Perl_Root.'Rege&x.non-white&space<Tab>\\S        			a\S'
    exe "inoremenu ".s:Perl_Root.'Rege&x.non-white&space<Tab>\\S        			 \S'
    exe "anoremenu ".s:Perl_Root.'Rege&x.non-(&word\ char\.)<Tab>\\W   				a\W'
    exe "inoremenu ".s:Perl_Root.'Rege&x.non-(&word\ char\.)<Tab>\\W   				 \W'
    exe "anoremenu ".s:Perl_Root.'Rege&x.do\ not\ match\ &prop\.<Tab>\\P{}    a\P{}<Left>'
    exe "inoremenu ".s:Perl_Root.'Rege&x.do\ not\ match\ &prop\.<Tab>\\P{}     \P{}<Left>'
    exe "vnoremenu ".s:Perl_Root.'Rege&x.do\ not\ match\ &prop\.<Tab>\\P{}    s\P{}<Esc>P'
		"
    "---------- submenu : POSIX character classes --------------------------------------------
    "
    exe " noremenu ".s:Perl_Root.'Rege&x.-SEP5-                               :'
    if s:Perl_MenuHeader == "yes"
      exe "amenu ".s:Perl_Root.'Rege&x.CharC&ls.Regex-1<Tab>Perl   <Nop>'
      exe "amenu ".s:Perl_Root.'Rege&x.CharC&ls.-Sep0-             :'
    endif
    "
    exe "anoremenu ".s:Perl_Root.'Rege&x.CharC&ls.[:&alnum:]   a[:alnum:]'
    exe "anoremenu ".s:Perl_Root.'Rege&x.CharC&ls.[:alp&ha:]   a[:alpha:]'
    exe "anoremenu ".s:Perl_Root.'Rege&x.CharC&ls.[:asc&ii:]   a[:ascii:]'
    exe "anoremenu ".s:Perl_Root.'Rege&x.CharC&ls.[:&blank:]   a[:blank:]'
    exe "anoremenu ".s:Perl_Root.'Rege&x.CharC&ls.[:&cntrl:]   a[:cntrl:]'
    exe "anoremenu ".s:Perl_Root.'Rege&x.CharC&ls.[:&digit:]   a[:digit:]'
    exe "anoremenu ".s:Perl_Root.'Rege&x.CharC&ls.[:&graph:]   a[:graph:]'
    exe "anoremenu ".s:Perl_Root.'Rege&x.CharC&ls.[:&lower:]   a[:lower:]'
    exe "anoremenu ".s:Perl_Root.'Rege&x.CharC&ls.[:&print:]   a[:print:]'
    exe "anoremenu ".s:Perl_Root.'Rege&x.CharC&ls.[:pu&nct:]   a[:punct:]'
    exe "anoremenu ".s:Perl_Root.'Rege&x.CharC&ls.[:&space:]   a[:space:]'
    exe "anoremenu ".s:Perl_Root.'Rege&x.CharC&ls.[:&upper:]   a[:upper:]'
    exe "anoremenu ".s:Perl_Root.'Rege&x.CharC&ls.[:&word:]    a[:word:]'
    exe "anoremenu ".s:Perl_Root.'Rege&x.CharC&ls.[:&xdigit:]  a[:xdigit:]'
		"
    "---------- submenu : Unicode properties  --------------------------------------------
    "
    if s:Perl_MenuHeader == "yes"
      	exe "amenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.Regex-2<Tab>Perl   <Nop>'
      	exe "amenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.-Sep0-             :'
    endif
		"
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Letter.L&etter<Tab>\\p{L}           	  					a\p{Letter}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Letter.&Lowercase_Letter<Tab>\\p{Ll}   					a\p{Lowercase_Letter}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Letter.&Uppercase_Letter<Tab>\\p{Lu}   					a\p{Uppercase_Letter}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Letter.&Titlecase_Letter<Tab>\\p{Lt}   					a\p{Titlecase_Letter}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Letter.&Modifier_Letter<Tab>\\p{Lm}    					a\p{Modifier_Letter}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Letter.&Other_Letter<Tab>\\p{Lo}       					a\p{Other_Letter}'
		"
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Mark.&Mark<Tab>\\p{M}           	  							a\p{Mark}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Mark.&Non_Spacing_Mark<Tab>\\p{Mn}   						a\p{Non_Spacing_Mark}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Mark.Spacing_&Combining_Mark<Tab>\\p{Mc} 				a\p{Spacing_Combining_Mark}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Mark.&Enclosing_Mark<Tab>\\p{Me}   							a\p{Enclosing_Mark}'
		"
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.Separator\ (&Z).S&eparator<Tab>\\p{Z}           	a\p{Separator}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.Separator\ (&Z).&Space_Separator<Tab>\\p{Zs}   		a\p{Space_Separator}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.Separator\ (&Z).&Line_Separator<Tab>\\p{Zl} 			a\p{Line_Separator}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.Separator\ (&Z).&Paragraph_Separator<Tab>\\p{Zp}  a\p{Paragraph_Separator}'
		"
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Symbol.&Symbol<Tab>\\p{S}           	  					a\p{Symbol}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Symbol.&Math_Symbol<Tab>\\p{Sm}   								a\p{Math_Symbol}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Symbol.&Currency_Symbol<Tab>\\p{Sc} 							a\p{Currency_Symbol}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Symbol.Modifier_Symbol\ (&k)<Tab>\\p{Sk}   			a\p{Modifier_Symbol}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Symbol.&Other_Symbol<Tab>\\p{So}   							a\p{Other_Symbol}'
		"
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Number.&Number<Tab>\\p{N}           	  					a\p{Number}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Number.&Decimal_Digit_Number<Tab>\\p{Nd}   			a\p{Decimal_Digit_Number}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Number.&Letter_Number<Tab>\\p{Nl} 								a\p{Letter_Number}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Number.&Other_Number<Tab>\\p{No}   							a\p{Other_Number}'
		"
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Punctuation.&Punctuation<Tab>\\p{P}     	  			a\p{Punctuation}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Punctuation.&Dash_Punctuation<Tab>\\p{Pd}   			a\p{Dash_Punctuation}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Punctuation.Open_Punctuation\ (&s)<Tab>\\p{Ps} 	a\p{Open_Punctuation}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Punctuation.Close_Punctuation\ (&e)<Tab>\\p{Pe}	a\p{Close_Punctuation}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Punctuation.&Initial_Punctuation<Tab>\\p{Pi}   	a\p{Initial_Punctuation}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Punctuation.&Final_Punctuation<Tab>\\p{Pf}   		a\p{Final_Punctuation}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Punctuation.&Connector_Punctuation<Tab>\\p{Pc} 	a\p{Connector_Punctuation}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.&Punctuation.&Other_Punctuation<Tab>\\p{Po}   		a\p{Other_Punctuation}'
		"
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.Other\ (&C).O&ther<Tab>\\p{C}            					a\p{Other}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.Other\ (&C).&Control<Tab>\\p{Cc}   								a\p{Control}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.Other\ (&C).&Format<Tab>\\p{Cf} 									a\p{Format}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.Other\ (&C).Private_Use\ (&o)<Tab>\\p{Co}   			a\p{Private_Use}'
    exe "anoremenu ".s:Perl_Root.'Rege&x.Unicode\ propert&y.Other\ (&C).U&nassigned<Tab>\\p{Cn}   						a\p{Unassigned}'
    "
    "---------- subsubmenu : Regular Expression Suport  -----------------------------------------
    "
    if s:Perl_MenuHeader == "yes"
      exe "amenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.Regex-3<Tab>Perl      <Nop>'
      exe "amenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.-Sep0-         :'
    endif
    "
    exe "anoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.&comment<Tab>(?#\ \.\.\.\ )                       a(?#)<Left>'
    exe "anoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.cl&uster\ only\ paren\.<Tab>(?:\ \.\.\.\ )        a(?:)<Left>'
    exe "anoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.pattern\ &modifier<Tab>(?imsx-imsx)               a(?)<Left>'
    exe "anoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.e&xecute\ code<Tab>(?\{\ \.\.\.\ \})              a(?{})<Left><Left>'
    exe "anoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.match\ &regex\ from\ code<Tab>(??\{\ \.\.\.\ \})  a(??{})<Left><Left>'
    exe "anoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.match-if-&then<Tab>(?(\.\.)\.\.)                  a(?())<Left><Left>'
    exe "anoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.match-if-t&hen-else<Tab>(?(\.\.)\.\.\|\.\.)       a(?()\|)<Left><Left><Left>'
    exe "anoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.-SEP11-                                     :'
    exe "anoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.look&ahead\ succeeds<Tab>(?=\ \.\.\.\ )           a(?=)<Left>'
    exe "anoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.looka&head\ fails<Tab>(?!\ \.\.\.\ )              a(?!)<Left>'
    exe "anoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.look&behind\ succeeds<Tab>(?<=\ \.\.\.\ )         a(?<=)<Left>'
    exe "anoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.lookb&ehind\ fails<Tab>(?<!\ \.\.\.\ )            a(?<!)<Left>'
    "
    exe "inoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.&comment<Tab>(?#\ \.\.\.\ )                        (?#)<Left>'
    exe "inoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.cl&uster\ only\ paren\.<Tab>(?:\ \.\.\.\ )         (?:)<Left>'
    exe "inoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.pattern\ &modifier<Tab>(?imsx-imsx)                (?)<Left>'
    exe "inoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.e&xecute\ code<Tab>(?\{\ \.\.\.\ \})               (?{})<Left><Left>'
    exe "inoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.match\ &regex\ from\ code<Tab>(??\{\ \.\.\.\ \})   (??{})<Left><Left>'
    exe "inoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.match-if-&then<Tab>(?(\.\.)\.\.)                   (?())<Left><Left>'
    exe "inoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.match-if-t&hen-else<Tab>(?(\.\.)\.\.\|\.\.)        (?()\|)<Left><Left><Left>'
    exe "inoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.-SEP11-                                     :'
    exe "inoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.look&ahead\ succeeds<Tab>(?=\ \.\.\.\ )            (?=)<Left>'
    exe "inoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.looka&head\ fails<Tab>(?!\ \.\.\.\ )               (?!)<Left>'
    exe "inoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.look&behind\ succeeds<Tab>(?<=\ \.\.\.\ )          (?<=)<Left>'
    exe "inoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.lookb&ehind\ fails<Tab>(?<!\ \.\.\.\ )             (?<!)<Left>'

    exe "vnoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.&comment<Tab>(?#\ \.\.\.\ )                       s(?#)<Esc>P'
    exe "vnoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.cl&uster\ only\ paren\.<Tab>(?:\ \.\.\.\ )        s(?:)<Esc>P'
    exe "vnoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.pattern\ &modifier<Tab>(?imsx-imsx)               s(?)<Esc>P'
    exe "vnoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.e&xecute\ code<Tab>(?\{\ \.\.\.\ \})              s(?{})<Esc>hP'
    exe "vnoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.match\ &regex\ from\ code<Tab>(??\{\ \.\.\.\ \})  s(??{})<Esc>hP'
    exe "vnoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.match-if-&then<Tab>(?(\.\.)\.\.)                  s(?())<Esc>hPla'
    exe "vnoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.match-if-t&hen-else<Tab>(?(\.\.)\.\.\|\.\.)       s(?()\|)<Esc>3hlPla'
    exe "vnoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.-SEP11-                                           :'
    exe "vnoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.look&ahead\ succeeds<Tab>(?=\ \.\.\.\ )           s(?=)<Esc>P'
    exe "vnoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.looka&head\ fails<Tab>(?!\ \.\.\.\ )              s(?!)<Esc>P'
    exe "vnoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.look&behind\ succeeds<Tab>(?<=\ \.\.\.\ )         s(?<=)<Esc>P'
    exe "vnoremenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.lookb&ehind\ fails<Tab>(?<!\ \.\.\.\ )            s(?<!)<Esc>P'
    "
    "
    exe " noremenu ".s:Perl_Root.'Rege&x.-SEP7-                               :'
		exe "amenu <silent> ".s:Perl_Root.'Rege&x.pick\ up\ &regex    			:call Perl_RegexPick( "regexp", "n" )<CR>j'
		exe "amenu <silent> ".s:Perl_Root.'Rege&x.pick\ up\ s&tring   			:call Perl_RegexPick( "string", "n" )<CR>j'
		exe "amenu <silent> ".s:Perl_Root.'Rege&x.pick\ up\ &flag(s)  			:call Perl_RegexPickFlag( "n" )<CR>'
		exe "vmenu <silent> ".s:Perl_Root.'Rege&x.pick\ up\ &regex     <C-C>:call Perl_RegexPick( "regexp", "v" )<CR>'."'>j"
		exe "vmenu <silent> ".s:Perl_Root.'Rege&x.pick\ up\ s&tring    <C-C>:call Perl_RegexPick( "string", "v" )<CR>'."'>j"
		exe "vmenu <silent> ".s:Perl_Root.'Rege&x.pick\ up\ &flag(s)   <C-C>:call Perl_RegexPickFlag( "v" )<CR>'."'>j"
		"
		exe "amenu <silent> ".s:Perl_Root.'Rege&x.&match                     :call Perl_RegexVisualize( )<CR>'
		exe "amenu <silent> ".s:Perl_Root.'Rege&x.&explain\ regex            :call Perl_RegexExplain( "n" )<CR>'
		exe "vmenu <silent> ".s:Perl_Root.'Rege&x.&explain\ regex       <C-C>:call Perl_RegexExplain( "v" )<CR>'
    "
    "---------- File-Tests-Menu ----------------------------------------------------------------------
    "
    if s:Perl_MenuHeader == "yes"
      exe "amenu ".s:Perl_Root.'&File-Tests.&File-Tests<Tab>Perl             <Nop>'
      exe "amenu ".s:Perl_Root.'&File-Tests.-Sep0-                          :'
    endif
    "
    exe "anoremenu ".s:Perl_Root.'&File-Tests.exists<Tab>-e                     a-e '
    exe "anoremenu ".s:Perl_Root.'&File-Tests.has\ zero\ size<Tab>-z            a-z '
    exe "anoremenu ".s:Perl_Root.'&File-Tests.has\ nonzero\ size<Tab>-s         a-s '
    exe "anoremenu ".s:Perl_Root.'&File-Tests.plain\ file<Tab>-f                a-f '
    exe "anoremenu ".s:Perl_Root.'&File-Tests.directory<Tab>-d                  a-d '
    exe "anoremenu ".s:Perl_Root.'&File-Tests.symbolic\ link<Tab>-l             a-l '
    exe "anoremenu ".s:Perl_Root.'&File-Tests.named\ pipe<Tab>-p                a-p '
    exe "anoremenu ".s:Perl_Root.'&File-Tests.socket<Tab>-S                     a-S '
    exe "anoremenu ".s:Perl_Root.'&File-Tests.block\ special\ file<Tab>-b       a-b '
    exe "anoremenu ".s:Perl_Root.'&File-Tests.character\ special\ file<Tab>-c   a-c '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.exists<Tab>-e                      -e '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.has\ zero\ size<Tab>-z             -z '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.has\ nonzero\ size<Tab>-s          -s '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.plain\ file<Tab>-f                 -f '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.directory<Tab>-d                   -d '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.symbolic\ link<Tab>-l              -l '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.named\ pipe<Tab>-p                 -p '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.socket<Tab>-S                      -S '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.block\ special\ file<Tab>-b        -b '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.character\ special\ file<Tab>-c    -c '
    "
    exe " menu ".s:Perl_Root.'&File-Tests.-SEP1-                              :'
    "
    exe "anoremenu ".s:Perl_Root.'&File-Tests.readable\ by\ eff\.\ UID/GID<Tab>-r   a-r '
    exe "anoremenu ".s:Perl_Root.'&File-Tests.writable\ by\ eff\.\ UID/GID<Tab>-w   a-w '
    exe "anoremenu ".s:Perl_Root.'&File-Tests.executable\ by\ eff\.\ UID/GID<Tab>-x a-x '
    exe "anoremenu ".s:Perl_Root.'&File-Tests.owned\ by\ eff\.\ UID<Tab>-o          a-o '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.readable\ by\ eff\.\ UID/GID<Tab>-r    -r '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.writable\ by\ eff\.\ UID/GID<Tab>-w    -w '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.executable\ by\ eff\.\ UID/GID<Tab>-x  -x '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.owned\ by\ eff\.\ UID<Tab>-o           -o '
    "
    exe "anoremenu ".s:Perl_Root.'&File-Tests.-SEP2-                          :'
    "
    exe "anoremenu ".s:Perl_Root.'&File-Tests.readable\ by\ real\ UID/GID<Tab>-R    a-R '
    exe "anoremenu ".s:Perl_Root.'&File-Tests.writable\ by\ real\ UID/GID<Tab>-W    a-W '
    exe "anoremenu ".s:Perl_Root.'&File-Tests.executable\ by\ real\ UID/GID<Tab>-X  a-X '
    exe "anoremenu ".s:Perl_Root.'&File-Tests.owned\ by\ real\ UID<Tab>-O           a-O '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.readable\ by\ real\ UID/GID<Tab>-R     -R '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.writable\ by\ real\ UID/GID<Tab>-W     -W '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.executable\ by\ real\ UID/GID<Tab>-X   -X '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.owned\ by\ real\ UID<Tab>-O            -O '
                                   
    exe "anoremenu ".s:Perl_Root.'&File-Tests.-SEP3-                           :'
    exe "anoremenu ".s:Perl_Root.'&File-Tests.setuid\ bit\ set<Tab>-u               a-u '
    exe "anoremenu ".s:Perl_Root.'&File-Tests.setgid\ bit\ set<Tab>-g               a-g '
    exe "anoremenu ".s:Perl_Root.'&File-Tests.sticky\ bit\ set<Tab>-k               a-k '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.setuid\ bit\ set<Tab>-u                -u '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.setgid\ bit\ set<Tab>-g                -g '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.sticky\ bit\ set<Tab>-k                -k '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.-SEP4-                           :'
    exe "anoremenu ".s:Perl_Root.'&File-Tests.age\ since\ modification<Tab>-M       a-M '
    exe "anoremenu ".s:Perl_Root.'&File-Tests.age\ since\ last\ access<Tab>-A       a-A '
    exe "anoremenu ".s:Perl_Root.'&File-Tests.age\ since\ inode\ change<Tab>-C      a-C '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.age\ since\ modification<Tab>-M        -M '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.age\ since\ last\ access<Tab>-A        -A '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.age\ since\ inode\ change<Tab>-C       -C '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.-SEP5-                           :'
    exe "anoremenu ".s:Perl_Root.'&File-Tests.text\ file<Tab>-T                     a-T '
    exe "anoremenu ".s:Perl_Root.'&File-Tests.binary\ file<Tab>-B                   a-B '
    exe "anoremenu ".s:Perl_Root.'&File-Tests.handle\ opened\ to\ a\ tty<Tab>-t     a-t '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.text\ file<Tab>-T                      -T '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.binary\ file<Tab>-B                    -B '
    exe "inoremenu ".s:Perl_Root.'&File-Tests.handle\ opened\ to\ a\ tty<Tab>-t      -t '
    "
    "---------- Special-Variables -------------------------------------------------------------
    "
    if s:Perl_MenuHeader == "yes"
      exe "amenu ".s:Perl_Root.'Spec-&Var.Spec-&Var<Tab>Perl      <Nop>'
      exe "amenu ".s:Perl_Root.'Spec-&Var.-Sep0-         :'
    endif
    "
    "-------- submenu errors -------------------------------------------------
    if s:Perl_MenuHeader == "yes"
      exe "amenu ".s:Perl_Root.'Spec-&Var.&errors.Spec-Var-1<Tab>Perl       <Nop>'
      exe "amenu ".s:Perl_Root.'Spec-&Var.&errors.-Sep0-                    :'
    endif
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.&errors.$CHILD_ERROR<Tab>$?         a$CHILD_ERROR'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.&errors.$ERRNO<Tab>$!               a$ERRNO'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.&errors.$EVAL_ERROR<Tab>$@          a$EVAL_ERROR'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.&errors.$EXTENDED_OS_ERROR<Tab>$^E  a$EXTENDED_OS_ERROR'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.&errors.$WARNING<Tab>$^W            a$WARNING'

    "-------- submenu files -------------------------------------------------
    if s:Perl_MenuHeader == "yes"
      exe "amenu ".s:Perl_Root.'Spec-&Var.&files.Spec-Var-2<Tab>Perl     <Nop>'
      exe "amenu ".s:Perl_Root.'Spec-&Var.&files.-Sep0-                  :'
    endif
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.&files.$AUTOFLUSH<Tab>$\|              a$AUTOFLUSH'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.&files.$OUTPUT_AUTOFLUSH<Tab>$\|       a$OUTPUT_AUTOFLUSH'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.&files.$FORMAT_LINES_LEFT<Tab>$-       a$FORMAT_LINES_LEFT'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.&files.$FORMAT_LINES_PER_PAGE<Tab>$=   a$FORMAT_LINES_PER_PAGE'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.&files.$FORMAT_NAME<Tab>$~             a$FORMAT_NAME'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.&files.$FORMAT_PAGE_NUMBER<Tab>$%      a$FORMAT_PAGE_NUMBER'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.&files.$FORMAT_TOP_NAME<Tab>$^         a$FORMAT_TOP_NAME'

    "-------- submenu IDs -------------------------------------------------
    if s:Perl_MenuHeader == "yes"
      exe "amenu ".s:Perl_Root.'Spec-&Var.&IDs.Spec-Var-3<Tab>Perl    <Nop>'
      exe "amenu ".s:Perl_Root.'Spec-&Var.&IDs.-Sep0-                 :'
    endif
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.&IDs.$PID<Tab>$$                   a$PID'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.&IDs.$PROCESS_ID<Tab>$$            a$PROCESS_ID'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.&IDs.$GID<Tab>$(                   a$GID'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.&IDs.$REAL_GROUP_ID<Tab>$(         a$REAL_GROUP_ID'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.&IDs.$EGID<Tab>$)                  a$EGID'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.&IDs.$EFFECTIVE_GROUP_ID<Tab>$)    a$EFFECTIVE_GROUP_ID'

    "-------- submenu IO -------------------------------------------------
    if s:Perl_MenuHeader == "yes"
      exe "amenu ".s:Perl_Root.'Spec-&Var.I&O.Spec-Var-4<Tab>Perl       <Nop>'
      exe "amenu ".s:Perl_Root.'Spec-&Var.I&O.-Sep0-                    :'
    endif
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.I&O.$INPUT_LINE_NUMBER<Tab>$\.         a$INPUT_LINE_NUMBER'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.I&O.$NR<Tab>$\.                        a$NR'

    exe "anoremenu ".s:Perl_Root.'Spec-&Var.I&O.-SEP1-                             :'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.I&O.$INPUT_RECORD_SEPARATOR<Tab>$/     a$INPUT_RECORD_SEPARATOR'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.I&O.$RS<Tab>$/                         a$RS'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.I&O.$LIST_SEPARATOR<Tab>$"             a$LIST_SEPARATOR'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.I&O.$OUTPUT_FIELD_SEPARATOR<Tab>$,     a$OUTPUT_FIELD_SEPARATOR'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.I&O.$OFS<Tab>$,                        a$OFS'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.I&O.$OUTPUT_RECORD_SEPARATOR<Tab>$\\   a$OUTPUT_RECORD_SEPARATOR'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.I&O.$ORS<Tab>$\\                       a$ORS'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.I&O.$SUBSCRIPT_SEPARATOR<Tab>$;        a$SUBSCRIPT_SEPARATOR'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.I&O.$SUBSEP<Tab>$;                     a$SUBSEP'

    "-------- submenu regexp -------------------------------------------------
    if s:Perl_MenuHeader == "yes"
      exe "amenu ".s:Perl_Root.'Spec-&Var.&regexp.Spec-Var-5<Tab>Perl       <Nop>'
      exe "amenu ".s:Perl_Root.'Spec-&Var.&regexp.-Sep0-                    :'
    endif
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.&regexp.$digits                            a$digits'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.&regexp.@LAST_MATCH_END<Tab>@+             a@LAST_MATCH_END'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.&regexp.@LAST_MATCH_START<Tab>@-           a@LAST_MATCH_START'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.&regexp.$LAST_PAREN_MATCH<Tab>$+           a$LAST_PAREN_MATCH'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.&regexp.$LAST_REGEXP_CODE_RESULT<Tab>$^R   a$LAST_REGEXP_CODE_RESULT'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.&regexp.$MATCH<Tab>$&                      a$MATCH'
    exe "anoremenu ".s:Perl_Root."Spec-&Var.&regexp.$POSTMATCH<Tab>$'                  a$POSTMATCH"
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.&regexp.$PREMATCH<Tab>$`                   a$PREMATCH'

    exe "anoremenu ".s:Perl_Root.'Spec-&Var.$BASETIME<Tab>$^T         a$BASETIME'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.$PERL_VERSION<Tab>$^V     a$PERL_VERSION'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.$PROGRAM_NAME<Tab>$0      a$PROGRAM_NAME'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.$OSNAME<Tab>$^O           a$OSNAME'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.$SYSTEM_FD_MAX<Tab>$^F    a$SYSTEM_FD_MAX'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.$ENV{\ }                  a$ENV{}<Left>'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.$INC{\ }                  a$INC{}<Left>'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.$SIG{\ }                  a$SIG{}<Left>'
    "
    "---------- submenu : POSIX signals --------------------------------------
    "
    if s:Perl_MenuHeader == "yes"
      exe "amenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.Spec-Var-6<Tab>Perl     <Nop>'
      exe "amenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.-Sep0-        :'
    endif
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.HUP    aHUP'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.INT    aINT'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.QUIT   aQUIT'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.ILL    aILL'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.ABRT   aABRT'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.FPE    aFPE'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.KILL   aKILL'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.SEGV   aSEGV'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.PIPE   aPIPE'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.ALRM   aALRM'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.TERM   aTERM'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.USR1   aUSR1'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.USR2   aUSR2'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.CHLD   aCHLD'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.CONT   aCONT'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.STOP   aSTOP'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.TSTP   aTSTP'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.TTIN   aTTIN'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.TTOU   aTTOU'
    "
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.-SEP2-                :'
    exe "anoremenu ".s:Perl_Root."Spec-&Var.\'IGNORE\'            a'IGNORE'"
    exe "anoremenu ".s:Perl_Root."Spec-&Var.\'DEFAULT\'           a'DEFAULT'"
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.-SEP3-                :'
    exe "anoremenu ".s:Perl_Root.'Spec-&Var.use\ English;         ouse English qw( -no_match_vars );<ESC>'
    "
    "---------- POD-Menu ----------------------------------------------------------------------
    "
    if s:Perl_MenuHeader == "yes"
      exe "amenu ".s:Perl_Root.'&POD.&POD<Tab>Perl          <Nop>'
      exe "amenu ".s:Perl_Root.'&POD.-Sep0-                 :'
    endif
    "
    exe "amenu ".s:Perl_Root.'&POD.=&pod\ /\ =cut                 :call Perl_PodPodCut("a")<CR>3kA'
    exe "imenu ".s:Perl_Root.'&POD.=&pod\ /\ =cut            <C-C>:call Perl_PodPodCut("a")<CR>3kA'
    exe "vmenu ".s:Perl_Root.'&POD.=&pod\ /\ =cut            <C-C>:call Perl_PodPodCut("v")<CR>'
    "
    exe "amenu ".s:Perl_Root.'&POD.=c&ut                     o<CR>=cut<CR><CR><Esc>A'
    "
    exe "amenu ".s:Perl_Root.'&POD.=fo&r\ /\ =cut                 :call Perl_PodForCut("a")<CR>3kA'
    exe "imenu ".s:Perl_Root.'&POD.=fo&r\ /\ =cut            <C-C>:call Perl_PodForCut("a")<CR>3kA'
    exe "vmenu ".s:Perl_Root.'&POD.=fo&r\ /\ =cut            <C-C>:call Perl_PodForCut("v")<CR>A'
    "
    exe "amenu ".s:Perl_Root.'&POD.=begin\ &html\ /\ =end         :call Perl_PodProcessor("a","html")<CR>3kA'
    exe "amenu ".s:Perl_Root.'&POD.=begin\ &man\ /\ =end          :call Perl_PodProcessor("a","man ")<CR>3kA'
    exe "amenu ".s:Perl_Root.'&POD.=begin\ &text\ /\ =end         :call Perl_PodProcessor("a","text")<CR>3kA'
    exe "imenu ".s:Perl_Root.'&POD.=begin\ &html\ /\ =end    <C-C>:call Perl_PodProcessor("a","html")<CR>3kA'
    exe "imenu ".s:Perl_Root.'&POD.=begin\ &man\ /\ =end     <C-C>:call Perl_PodProcessor("a","man ")<CR>3kA'
    exe "imenu ".s:Perl_Root.'&POD.=begin\ &text\ /\ =end    <C-C>:call Perl_PodProcessor("a","text")<CR>3kA'
    exe "vmenu ".s:Perl_Root.'&POD.=begin\ &html\ /\ =end    <C-C>:call Perl_PodProcessor("v","html")<CR>'
    exe "vmenu ".s:Perl_Root.'&POD.=begin\ &man\ /\ =end     <C-C>:call Perl_PodProcessor("v","man ")<CR>'
    exe "vmenu ".s:Perl_Root.'&POD.=begin\ &text\ /\ =end    <C-C>:call Perl_PodProcessor("v","text")<CR>'
    "
    exe "amenu ".s:Perl_Root.'&POD.=head&1                   o<CR>=head1 <CR><Esc>kA'
    exe "amenu ".s:Perl_Root.'&POD.=head&2                   o<CR>=head2 <CR><Esc>kA'
    exe "amenu ".s:Perl_Root.'&POD.=head&3                   o<CR>=head3 <CR><Esc>kA'
    exe "amenu ".s:Perl_Root.'&POD.-Sep1-                    :'
    "
    exe "amenu ".s:Perl_Root.'&POD.=&over\ \.\.\ =back            :call Perl_PodOverBack("a")<CR>7kA'
    exe "imenu ".s:Perl_Root.'&POD.=&over\ \.\.\ =back       <C-C>:call Perl_PodOverBack("a")<CR>7kA'
    exe "vmenu ".s:Perl_Root.'&POD.=&over\ \.\.\ =back       <C-C>:call Perl_PodOverBack("v")<CR>A'
		"
    exe "amenu ".s:Perl_Root.'&POD.=item\ &*                 o<CR>=item *<CR><CR><CR><Esc>kA'
    exe "amenu ".s:Perl_Root.'&POD.-Sep2-                    :'
    "
    if s:Perl_MenuHeader == "yes"
      exe "amenu ".s:Perl_Root.'&POD.in&visible\ POD.invisible\ POD<Tab>Perl     <Nop>'
      exe "amenu ".s:Perl_Root.'&POD.in&visible\ POD.-Sep0-        :'
    endif
    exe "amenu <silent> ".s:Perl_Root.'&POD.in&visible\ POD.&Improvement        :call Perl_InvisiblePOD("a","Improvement")<CR>'
    exe "amenu <silent> ".s:Perl_Root.'&POD.in&visible\ POD.&Optimization       :call Perl_InvisiblePOD("a","Optimization")<CR>'
    exe "amenu <silent> ".s:Perl_Root.'&POD.in&visible\ POD.&Rationale          :call Perl_InvisiblePOD("a","Rationale")<CR>'
    exe "amenu <silent> ".s:Perl_Root.'&POD.in&visible\ POD.&Workaround         :call Perl_InvisiblePOD("a","Workaround")<CR>'
    exe "vmenu <silent> ".s:Perl_Root.'&POD.in&visible\ POD.&Improvement   <C-C>:call Perl_InvisiblePOD("v","Improvement")<CR>'
    exe "vmenu <silent> ".s:Perl_Root.'&POD.in&visible\ POD.&Optimization  <C-C>:call Perl_InvisiblePOD("v","Optimization")<CR>'
    exe "vmenu <silent> ".s:Perl_Root.'&POD.in&visible\ POD.&Rationale     <C-C>:call Perl_InvisiblePOD("v","Rationale")<CR>'
    exe "vmenu <silent> ".s:Perl_Root.'&POD.in&visible\ POD.&Workaround    <C-C>:call Perl_InvisiblePOD("v","Workaround")<CR>'
    exe "amenu ".s:Perl_Root.'&POD.-Sep3-                    :'
    "
    "---------- submenu : Sequences --------------------------------------
    "
    exe "anoremenu ".s:Perl_Root.'&POD.&B<><Tab>bold             aB<><Left>'
    exe "anoremenu ".s:Perl_Root.'&POD.&C<><Tab>literal          aC<><Left>'
    exe "anoremenu ".s:Perl_Root.'&POD.&E<><Tab>escape           aE<><Left>'
    exe "anoremenu ".s:Perl_Root.'&POD.&F<><Tab>filename         aF<><Left>'
    exe "anoremenu ".s:Perl_Root.'&POD.&I<><Tab>italic           aI<><Left>'
    exe "anoremenu ".s:Perl_Root.'&POD.&L<><Tab>link             aL<\|><Left><Left>'
    exe "anoremenu ".s:Perl_Root.'&POD.&S<>\ \ nonbr\.\ spaces   aS<><Left>'
    exe "anoremenu ".s:Perl_Root.'&POD.&X<><Tab>index            aX<><Left>'
    exe "anoremenu ".s:Perl_Root.'&POD.&Z<><Tab>zero-width       aZ<><Left>'
    "
    exe "inoremenu ".s:Perl_Root.'&POD.&B<><Tab>bold              B<><Left>'
    exe "inoremenu ".s:Perl_Root.'&POD.&C<><Tab>literal           C<><Left>'
    exe "inoremenu ".s:Perl_Root.'&POD.&E<><Tab>escape            E<><Left>'
    exe "inoremenu ".s:Perl_Root.'&POD.&F<><Tab>filename          F<><Left>'
    exe "inoremenu ".s:Perl_Root.'&POD.&I<><Tab>italic            I<><Left>'
    exe "inoremenu ".s:Perl_Root.'&POD.&L<><Tab>link              L<\|><Left><Left>'
    exe "inoremenu ".s:Perl_Root.'&POD.&S<>\ \ nonbr\.\ spaces    S<><Left>'
    exe "inoremenu ".s:Perl_Root.'&POD.&X<><Tab>index             X<><Left>'
    exe "inoremenu ".s:Perl_Root.'&POD.&Z<><Tab>zero-width        Z<><Left>'
    "
    exe "vnoremenu ".s:Perl_Root.'&POD.&B<><Tab>bold             sB<><Esc>P2l'
    exe "vnoremenu ".s:Perl_Root.'&POD.&C<><Tab>literal          sC<><Esc>P2l'
    exe "vnoremenu ".s:Perl_Root.'&POD.&E<><Tab>escape           sE<><Esc>P2l'
    exe "vnoremenu ".s:Perl_Root.'&POD.&F<><Tab>filename         sF<><Esc>P2l'
    exe "vnoremenu ".s:Perl_Root.'&POD.&I<><Tab>italic           sI<><Esc>P2l'
    exe "vnoremenu ".s:Perl_Root.'&POD.&L<><Tab>link             sL<\|><Esc>hPl'
    exe "vnoremenu ".s:Perl_Root.'&POD.&S<>\ \ nonbr\.\ spaces   sS<><Esc>P2l'
    exe "vnoremenu ".s:Perl_Root.'&POD.&X<><Tab>index            sX<><Esc>P2l'

    exe "amenu          ".s:Perl_Root.'&POD.-SEP4-                  :'
    exe "amenu <silent> ".s:Perl_Root.'&POD.run\ podchecker\ \ (&4) :call Perl_PodCheck()<CR>:redraw<CR>:call Perl_PodCheckMsg()<CR>'
    exe "amenu <silent> ".s:Perl_Root.'&POD.POD\ ->\ html\ \ (&5)   :call Perl_POD("html")<CR>'
    exe "amenu <silent> ".s:Perl_Root.'&POD.POD\ ->\ man\ \ (&6)    :call Perl_POD("man")<CR>'
    exe "amenu <silent> ".s:Perl_Root.'&POD.POD\ ->\ text\ \ (&7)   :call Perl_POD("text")<CR>'
    "
    "---------- Run-Menu ----------------------------------------------------------------------
    "
    if s:Perl_MenuHeader == "yes"
      exe "amenu ".s:Perl_Root.'&Run.&Run<Tab>Perl                  <Nop>'
      exe "amenu ".s:Perl_Root.'&Run.-Sep0-                         :'
    endif
    "
    "   run the script from the local directory 
    "   ( the one which is being edited; other versions may exist elsewhere ! )
    " 
    exe "amenu <silent> ".s:Perl_Root.'&Run.update,\ &run\ script<Tab><C-F9>         :call Perl_Run()<CR>'
    "
    exe "amenu ".s:Perl_Root.'&Run.update,\ check\ &syntax<Tab><A-F9>                :call Perl_SyntaxCheck()<CR>:redraw<CR>:call Perl_SyntaxCheckMsg()<CR>'
    exe "amenu <silent> ".s:Perl_Root.'&Run.cmd\.\ line\ &arg\.<Tab><S-F9>           :call Perl_Arguments()<CR>'
    exe "amenu <silent> ".s:Perl_Root.'&Run.perl\ s&witches                          :call Perl_PerlSwitches()<CR>'
    exe "amenu <silent> ".s:Perl_Root.'&Run.start\ &debugger<Tab><F9>                :call Perl_Debugger()<CR>'
    "
    "   set execution rights for user only ( user may be root ! )
    "
    if !s:MSWIN
      exe "amenu <silent> ".s:Perl_Root.'&Run.make\ script\ &executable              :call Perl_MakeScriptExecutable()<CR>'
    endif
    exe "amenu          ".s:Perl_Root.'&Run.-SEP2-                     :'

    exe "amenu <silent> ".s:Perl_Root.'&Run.read\ &perldoc<Tab><S-F1>        :call Perl_perldoc()<CR><CR>'
    exe "amenu <silent> ".s:Perl_Root.'&Run.show\ &installed\ Perl\ modules  :call Perl_perldoc_show_module_list()<CR>'
    exe "amenu <silent> ".s:Perl_Root.'&Run.&generate\ Perl\ module\ list    :call Perl_perldoc_generate_module_list()<CR><CR>'
    "
    exe "amenu          ".s:Perl_Root.'&Run.-SEP4-                     :'
    exe "amenu <silent> ".s:Perl_Root.'&Run.run\ perltid&y                        :call Perl_Perltidy("n")<CR>'
    exe "vmenu <silent> ".s:Perl_Root.'&Run.run\ perltid&y                   <C-C>:call Perl_Perltidy("v")<CR>'
    exe "amenu <silent> ".s:Perl_Root.'&Run.run\ S&mallProf                  			:call Perl_Smallprof()<CR><CR>'
    exe "amenu <silent> ".s:Perl_Root.'&Run.run\ perl&critic                 			:call Perl_Perlcritic()<CR>:redraw<CR>:call Perl_PerlcriticMsg()<CR>'
    exe "amenu <silent> ".s:Perl_Root.'&Run.save\ buffer\ with\ &timestamp   			:call Perl_SaveWithTimestamp()<CR>'

    exe "amenu          ".s:Perl_Root.'&Run.-SEP5-                     :'
    exe "amenu <silent> ".s:Perl_Root.'&Run.&hardcopy\ to\ FILENAME\.ps           :call Perl_Hardcopy("n")<CR>'
    exe "vmenu <silent> ".s:Perl_Root.'&Run.&hardcopy\ to\ FILENAME\.ps      <C-C>:call Perl_Hardcopy("v")<CR>'
    exe "amenu          ".s:Perl_Root.'&Run.-SEP6-                     :'
    exe "amenu <silent> ".s:Perl_Root.'&Run.settings\ and\ hot\ &keys             :call Perl_Settings()<CR>'
    "
    if  !s:MSWIN
      exe "amenu  <silent>  ".s:Perl_Root.'&Run.&xterm\ size                          :call Perl_XtermSize()<CR>'
    endif
    if s:Perl_OutputGvim == "vim" 
      exe "amenu  <silent>  ".s:Perl_Root.'&Run.&output:\ VIM->buffer->xterm          :call Perl_Toggle_Gvim_Xterm()<CR>'
    else
      if s:Perl_OutputGvim == "buffer" 
        exe "amenu  <silent>  ".s:Perl_Root.'&Run.&output:\ BUFFER->xterm->vim        :call Perl_Toggle_Gvim_Xterm()<CR>'
      else
        exe "amenu  <silent>  ".s:Perl_Root.'&Run.&output:\ XTERM->vim->buffer        :call Perl_Toggle_Gvim_Xterm()<CR>'
      endif
    endif
    "
  endif
  "
  "===============================================================================================
  "----- Menu : help  ----------------------------------------------------------------------------
  "===============================================================================================
  "
  if s:Perl_Root != ""
    exe "amenu  <silent>  ".s:Perl_Root.'&help\ \(plugin\)        :call Perl_HelpPerlsupport()<CR>'
  endif
  "
  "--------------------------------------------------------------------------------------------
  "
endfunction   " ---------- end of function  Perl_InitMenu  ----------
"
"
"------------------------------------------------------------------------------
"-----   variables for internal use   -----------------------------------------
"------------------------------------------------------------------------------
"
let s:Perl_Active       = -1        " state variable controlling the Perl-menus
"
"------------------------------------------------------------------------------
"  Input after a highlighted prompt
"------------------------------------------------------------------------------
function! Perl_Input ( promp, text )
  echohl Search                       " highlight prompt
  call inputsave()                    " preserve typeahead
  let retval=input( a:promp, a:text ) " read input
  call inputrestore()                 " restore typeahead
  let retval  = substitute( retval, '^\s\+', '', '' )
  let retval  = substitute( retval, '\s\+$', '', '' )
  echohl None                         " reset highlighting
  return retval
endfunction   " ---------- end of function  Perl_Input  ----------

"------------------------------------------------------------------------------
"  Comments : get line-end comment position
"------------------------------------------------------------------------------
function! Perl_GetLineEndCommCol ()
  let actcol  = virtcol(".")
  if actcol+1 == virtcol("$")
    let b:Perl_LineEndCommentColumn = Perl_Input( 'start line-end comment at virtual column : ', actcol )
  else
    let b:Perl_LineEndCommentColumn = virtcol(".") 
  endif
  echomsg "line end comments will start at column  ".b:Perl_LineEndCommentColumn
endfunction   " ---------- end of function  Perl_GetLineEndCommCol  ----------
"
"------------------------------------------------------------------------------
"  Comments : single line-end comment
"------------------------------------------------------------------------------
function! Perl_LineEndComment ( comment )
  if !exists("b:Perl_LineEndCommentColumn")
    let b:Perl_LineEndCommentColumn = s:Perl_LineEndCommColDefault
  endif
  " ----- trim whitespaces -----
	exe 's/\s*$//'
  let linelength= virtcol("$") - 1
  if linelength < b:Perl_LineEndCommentColumn
    let diff  = b:Perl_LineEndCommentColumn -1 -linelength
    exe "normal ".diff."A "
  endif
  " append at least one blank
  if linelength >= b:Perl_LineEndCommentColumn
    exe "normal A "
  endif
  exe "normal A# ".a:comment
endfunction   " ---------- end of function  Perl_LineEndComment  ----------
"
"------------------------------------------------------------------------------
"  Perl_AlignLineEndComm: adjust line-end comments  
"------------------------------------------------------------------------------
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
	end

	let	linenumber	= pos0
	exe ":".pos0

	while linenumber <= pos1
		let	line= getline(".")
		"
		" look for a Perl comment; do not match $#arrayname
		let idx1	= 1 + match( line, '\s*\$\@<!#.*$' )
		let idx2	= 1 + match( line,    '\$\@<!#.*$' )

		let	ln	= line(".")
		call setpos(".", [ 0, ln, idx1, 0 ] )
		let vpos1	= virtcol(".")
		call setpos(".", [ 0, ln, idx2, 0 ] )
		let vpos2	= virtcol(".")

		if   ! (   vpos2 == b:Perl_LineEndCommentColumn 
					\	|| vpos1 > b:Perl_LineEndCommentColumn
					\	|| idx2  == 0 )

			exe ":.,.retab"
			" insert some spaces
			if vpos2 < b:Perl_LineEndCommentColumn
				let	diff	= b:Perl_LineEndCommentColumn-vpos2
				call setpos(".", [ 0, ln, vpos2, 0 ] )
				let	@"	= ' '
				exe "normal	".diff."P"
			end

			" remove some spaces
			if vpos1 < b:Perl_LineEndCommentColumn && vpos2 > b:Perl_LineEndCommentColumn
				let	diff	= vpos2 - b:Perl_LineEndCommentColumn
				call setpos(".", [ 0, ln, b:Perl_LineEndCommentColumn, 0 ] )
				exe "normal	".diff."x"
			end

		end
		let linenumber=linenumber+1
		normal j
	endwhile
	" restore tab expansion settings and cursor position
	let &expandtab	= save_expandtab
	call setpos('.', save_cursor)

endfunction		" ---------- end of function  Perl_AlignLineEndComm  ----------
"
"------------------------------------------------------------------------------
"  Comments : multi line-end comments
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! Perl_MultiLineEndComments ()
  if !exists("b:Perl_LineEndCommentColumn")
    let b:Perl_LineEndCommentColumn = s:Perl_LineEndCommColDefault
  endif
  "
  let pos0  = line("'<")
  let pos1  = line("'>")
  " ----- trim whitespaces -----
  :'<,'>s/\s*$//
  " ----- find the longest line -----
  let maxlength   = 0
  let linenumber  = pos0
  normal '<
  while linenumber <= pos1
    if  getline(".") !~ "^\\s*$"  && maxlength<virtcol("$")
      let maxlength= virtcol("$")
    endif
    let linenumber=linenumber+1
    normal j
  endwhile
  "
  if maxlength < b:Perl_LineEndCommentColumn
    let maxlength = b:Perl_LineEndCommentColumn
  else
    let maxlength = maxlength+1   " at least 1 blank
  endif
  "
  " ----- fill lines with blanks -----
  let linenumber  = pos0
  normal '<
  while linenumber <= pos1
    if getline(".") !~ "^\\s*$"
      let diff  = maxlength - virtcol("$")
      exe "normal ".diff."A "
      exe "normal $A# "
    endif
    let linenumber=linenumber+1
    normal j
  endwhile
  " ----- back to the begin of the marked block -----
  normal '<
endfunction   " ---------- end of function  Perl_MultiLineEndComments  ----------
"
"------------------------------------------------------------------------------
"  Comments : classified comments
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! Perl_CommentClassified (class)
  let	comment = ':'.a:class.':'.strftime("%x").':'.s:Perl_AuthorRef.': '
	call Perl_LineEndComment ( comment )
endfunction   " ---------- end of function  Perl_CommentClassified  ----------
"
"------------------------------------------------------------------------------
"  comment block
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
"  uncomment block
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
"  toggle comments
"------------------------------------------------------------------------------
function! Perl_CommentToggle ()
  if match( getline("."), '^\s*#' ) != -1
		" remove comment sign, keep leading whitespaces
		exe ":s/^\\(\\s*\\)#/\\1/"
	else
		" add comment leader
		exe ":s/^/#/"
	endif
endfunction    " ----------  end of function Perl_CommentToggle  ----------
"
"------------------------------------------------------------------------------
"  Substitute tags
"------------------------------------------------------------------------------
function! Perl_SubstituteTag( pos1, pos2, tag, replacement )
  let linenumber=a:pos1
  while linenumber <= a:pos2
		let line	= substitute( getline(linenumber), a:tag, a:replacement, "g" )
    call setline( linenumber, line )
    let linenumber=linenumber+1
  endwhile
endfunction    " ----------  end of function  Perl_SubstituteTag  ----------
"
"------------------------------------------------------------------------------
"  Comments : Insert Template Files
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! Perl_CommentTemplates (arg)
  "----------------------------------------------------------------------
  "  Perl templates
  "----------------------------------------------------------------------
  if a:arg=='frame'
    let templatefile=s:Perl_Template_Directory.s:Perl_Template_Frame
  endif

  if a:arg=='function'
    let templatefile=s:Perl_Template_Directory.s:Perl_Template_Function
  endif

  if a:arg=='method'
    let templatefile=s:Perl_Template_Directory.s:Perl_Template_Method
  endif

  if a:arg=='header'
    let templatefile=s:Perl_Template_Directory.s:Perl_Template_File
  endif

  if a:arg=='module'
    let templatefile=s:Perl_Template_Directory.s:Perl_Template_Module
  endif

  if a:arg=='test'
    let templatefile=s:Perl_Template_Directory.s:Perl_Template_Test
  endif

  if a:arg=='pod'
    let templatefile=s:Perl_Template_Directory.s:Perl_Template_Pod
  endif


  if filereadable(templatefile)
    let length= line("$")
    let pos1  = line(".")+1
    let l:old_cpoptions = &cpoptions " Prevent the alternate buffer from being set to this files
    setlocal cpoptions-=a
    if a:arg=='header' || a:arg=='module' || a:arg=='test' || a:arg=='pod'
      :goto 1
      let pos1  = 1
      exe '0read '.templatefile
    else
      exe 'read '.templatefile
    endif
    let &cpoptions  = l:old_cpoptions   " restore previous options
    "
    let length= line("$")-length
    let pos2  = pos1+length-1
    "----------------------------------------------------------------------
    "  frame blocks will be indented
    "----------------------------------------------------------------------
    if a:arg=='frame'
      let length  = length-1
      silent exe "normal =".length."+"
      let length  = length+1
    endif
    "----------------------------------------------------------------------
    "  substitute keywords
    "----------------------------------------------------------------------
    " 
    call Perl_SubstituteTag( pos1, pos2, '|FILENAME|',        expand("%:t")          )
    call Perl_SubstituteTag( pos1, pos2, '|DATE|',            strftime("%x %X %Z")   )
    call Perl_SubstituteTag( pos1, pos2, '|TIME|',            strftime("%X")         )
    call Perl_SubstituteTag( pos1, pos2, '|YEAR|',            strftime("%Y")         )
    call Perl_SubstituteTag( pos1, pos2, '|AUTHOR|',          s:Perl_AuthorName      )
    call Perl_SubstituteTag( pos1, pos2, '|EMAIL|',           s:Perl_Email           )
    call Perl_SubstituteTag( pos1, pos2, '|AUTHORREF|',       s:Perl_AuthorRef       )
    call Perl_SubstituteTag( pos1, pos2, '|PROJECT|',         s:Perl_Project         )
    call Perl_SubstituteTag( pos1, pos2, '|COMPANY|',         s:Perl_Company         )
    call Perl_SubstituteTag( pos1, pos2, '|COPYRIGHTHOLDER|', s:Perl_CopyrightHolder )
    "
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
  return
endfunction    " ----------  end of function  Perl_CommentTemplates  ----------
"
"------------------------------------------------------------------------------
"  Comments : vim modeline
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! Perl_CommentVimModeline ()
  put = '# vim: set tabstop='.&tabstop.' shiftwidth='.&shiftwidth.': '
endfunction    " ----------  end of function Perl_CommentVimModeline  ----------
"
"------------------------------------------------------------------------------
"  Statements : subroutine
"------------------------------------------------------------------------------
function! Perl_Subroutine (mode)
  let identifier=Perl_Input("subroutine name : ", "" )
  "
  if identifier==""
    return
  endif
  "
  " ----- normal mode ----------------
  if a:mode=="a" 
    if s:Perl_BraceOnNewLine == "no"
      let zz=    "sub ".identifier." {\n\tmy\t( $par1 )\t= @_;\n\t\n\treturn ;\n}"
      let zz= zz."\t# ----------  end of subroutine ".identifier."  ----------" 
      put =zz
      if v:version<700
        normal 2j
      else
        normal 2k
      endif
    else
      let zz=    "sub ".identifier."\n{\n\tmy\t( $par1 )\t= @_;\n\t\n\treturn ;\n}"
      let zz= zz."\t# ----------  end of subroutine ".identifier."  ----------" 
      put =zz
      if v:version<700
        normal 3j
      else
        normal 2k
      endif
    endif
  endif
  "
  " ----- visual mode ----------------
  if a:mode=="v" 
    if s:Perl_BraceOnNewLine == "no"
      let zz=    "sub ".identifier." {\n\tmy\t( $par1 )\t= @_;"
      :'<put! =zz
      let zz=    "\treturn ;\n}"
      let zz= zz."\t# ----------  end of subroutine ".identifier."  ----------" 
      :'>put =zz
      :'<-3
      let zz=    identifier."();\n\n"
      :put =zz
      if v:version >= 700
        normal k
      endif
      :exe "normal =".(line("'>")-line(".")+2)."+"
    else
      let zz=    "sub ".identifier."\n{\n\tmy\t( $par1 )\t= @_;"
      :'<put! =zz
      let zz=    "\treturn ;\n}"
      let zz= zz."\t# ----------  end of subroutine ".identifier."  ----------" 
      :'>put =zz
      :'<-4
      let zz=    identifier."();\n\n"
      :put =zz
      if v:version >= 700
        normal k
      endif
      :exe "normal =".(line("'>")-line(".")+2)."+"
    endif
  endif
endfunction   " ---------- end of function  Perl_Subroutine  ----------
"
"------------------------------------------------------------------------------
"  Statements : do-while
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! Perl_DoWhile (arg)

  if a:arg=='a'
    if s:Perl_BraceOnNewLine == "no"
      let zz=    "do {\n\t\n}\nwhile (  );"
      let zz= zz."\t\t\t\t# -----  end do-while  -----\n"
      put =zz
      if v:version<700
        normal  =3+3j
      else
        normal  =3-3j
      endif
    else
      let zz=    "do\n{\n\t\n}\nwhile (  );"
      let zz= zz."\t\t\t\t# -----  end do-while  -----\n"
      put =zz
      if v:version<700
        normal  =4+4j
      else
        normal  =4-4j
      endif
    endif
  endif

  if a:arg=='v'
    if s:Perl_BraceOnNewLine == "no"
      let zz=    "do {"
    else
      let zz=    "do\n{"
    endif
    :'<put! =zz
    let zz=    "}\nwhile (  );\t\t\t\t# -----  end do-while  -----\n"
    :'>put =zz
    :'<-2
    :exe "normal =".(line("'>")-line(".")+3)."+"
    :'>+2
  endif

endfunction   " ---------- end of function  Perl_DoWhile  ----------
"
"------------------------------------------------------------------------------
"  Statements : statement  {}
"------------------------------------------------------------------------------
function! Perl_StatBlock ( mode, stmt1, stmt2)

  let part1 = a:stmt1
  let part2 = a:stmt2
  if s:Perl_BraceOnNewLine=="yes"
    let part1 = substitute ( part1, ' {', '\n{', 'g' )
    let part2 = substitute ( part2, ' {', '\n{', 'g' )
  endif
  "
  let cr1=0
  let start=0
  while 1
    let start = matchend( part1, '\n', start ) 
    if start>=0
      let cr1 = cr1+1
    else
      break
    endif
  endwhile
  "
  " whole construct in part1
  if a:mode=='a'
    let zz=    part1
    put =zz
    if v:version<700
      :exe "normal =".cr1."+"
    else
      :exe "normal =".cr1."-"
    endif
  endif

  if a:mode=='v'
    "
    let cr2=0
    let start=0
    while 1
      let start = matchend( part2, '\n', start ) 
      if start>=0
        let cr2 = cr2+1
      else
        break
      endif
    endwhile
    let zz=    part1
    :'<put! =zz
    let zz=  part2
    :'>put =zz
    if cr2>0
      if v:version<700
        :exe "normal ".cr2."j"
      endif
    endif
    let cr1 = cr1+cr2+2+line("'>")-line("'<")
    :exe "normal =".cr1."-"
  endif
endfunction    " ----------  end of function Perl_StatBlock  ----------
"
"------------------------------------------------------------------------------
"  Statements : block ; replaces an empty line
"------------------------------------------------------------------------------
function! Perl_Block (arg)

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
endfunction    " ----------  end of function Perl_Block  ----------
"
"------------------------------------------------------------------------------
"  Idioms : insert some idioms
"  This subroutine is needed because some shortcuts collide with the start
"  of a reference, e.g. the '\$' in  'sub_x ( \$x )' should not be expanded to 
"  'my $;'
"------------------------------------------------------------------------------
function! Perl_Idiom ( shortcut, replacement, mark )
	let	colpos		= col(".")
	let	curline		= getline(".")
	let	curlineno	= line(".")
	let	part1			= strpart( curline, 0, colpos )
	let	part2			= strpart( curline, colpos )
	"
	" 1.part: empty or whitespaces / 2.part: empty or whitespaces or comment 
	" (shortcut empty : replace always) :
	"
	if			 		( a:shortcut == "" )
				\	||	( ( match( part1, '^\s*$' ) >= 0 ) && ( match( part2, '^\s*\(#.*\)\=$' ) >= 0 ) )
		" insert the replacement
		call setline( curlineno, part1.a:replacement.part2 )
		exe "normal f".a:mark
	else
		" insert the shortcut
		if a:shortcut != ""
			call setline( curlineno, part1.a:shortcut.part2 )
			call cursor ( curlineno, colpos + strlen(a:shortcut) )
		endif
	endif
endfunction    " ----------  end of function Perl_Idiom  ----------
"
"------------------------------------------------------------------------------
"  Perl-Idioms : open input file
"------------------------------------------------------------------------------
function! Perl_OpenInputFile (mode)

  let filehandle=Perl_Input( 'input file handle : $', 'INFILE' )
  
  if filehandle==""
    let filehandle  = "INFILE"
  endif
  
  let filename=filehandle."_file_name"

  exe "amenu ".s:Perl_Root.'&Idioms.<$'.filehandle.'>     a<$'.filehandle.'><ESC>'
  exe "vmenu ".s:Perl_Root.'&Idioms.<$'.filehandle.'>     s<$'.filehandle.'><ESC>'
  exe "imenu ".s:Perl_Root.'&Idioms.<$'.filehandle.'>      <$'.filehandle.'><ESC>a'

  let openstmt=    "my\t$".filename." = \'\';\t\t# input file name\n\n"
  let openstmt= openstmt.'open  my $'.filehandle.", \'<\', $".filename."\n"
  let openstmt= openstmt."\tor die  \"$0 : failed to open  input file '$".filename."' : $!\\n\";\n\n"

  let closestmt=           "\n".'close  $'.filehandle."\n"
  let closestmt= closestmt."\tor warn \"$0 : failed to close input file '$".filename."' : $!\\n\";\n\n"

	if a:mode == "a"
		let	all	= openstmt.closestmt
		put =all
		if v:version < 700
			normal =7+
		else
			normal =8-
		endif
	end

	if a:mode == "v"
		if v:version < 700
			:'<put! =openstmt
			normal =4+
			:'>put =closestmt
			normal =2+
			:'<-5
		else
			:'<put! =openstmt
			normal =5-
			:'>put =closestmt
			normal =3-
			:'<-5
		endif
	end

  normal f'
endfunction   " ---------- end of function  Perl_OpenInputFile  ----------
"
"------------------------------------------------------------------------------
"  Perl-Idioms : open output file
"------------------------------------------------------------------------------
function! Perl_OpenOutputFile (mode)

  let filehandle=Perl_Input( 'output file handle : $', 'OUTFILE' )
  
  if filehandle==""
    let filehandle  = "OUTFILE"
  endif
  
  let filename=filehandle."_file_name"

  exe " noremenu ".s:Perl_Root.'&Idioms.print\ {$'.filehandle.'}\ "\\n";   iprint {$'.filehandle.'} "\n";<ESC>3hi'
  exe "inoremenu ".s:Perl_Root.'&Idioms.print\ {$'.filehandle.'}\ "\\n";    print {$'.filehandle.'} "\n";<ESC>3hi'

  let openstmt=    "my\t$".filename." = \'\';\t\t# output file name\n\n"
  let openstmt= openstmt.'open  my $'.filehandle.", \'>\', $".filename."\n"
  let openstmt= openstmt."\tor die  \"$0 : failed to open  output file '$".filename."' : $!\\n\";\n\n"

  let closestmt=           "\n".'close  $'.filehandle."\n"
  let closestmt= closestmt."\tor warn \"$0 : failed to close output file '$".filename."' : $!\\n\";\n\n"

	if a:mode == "a"
		let	all	= openstmt.closestmt
		put =all
		if v:version < 700
			normal =5+
		else
			normal =8-
		endif
	end

	if a:mode == "v"
		if v:version < 700
			:'<put! =openstmt
			normal =4+
			:'>put =closestmt
			normal =2+
			:'<-5
		else
			:'<put! =openstmt
			normal =5-
			:'>put =closestmt
			normal =3-
			:'<-5
		endif
	end

  normal f'
endfunction   " ---------- end of function  Perl_OpenOutputFile  ----------
"
"------------------------------------------------------------------------------
"  Perl-Idioms : open pipe
"------------------------------------------------------------------------------
function! Perl_OpenPipe (mode)

  let pipehandle=Perl_Input( 'pipe handle : $', 'PIPE' )
  
  if pipehandle==""
    let pipehandle  = "PIPE"
  endif
  
  let pipecommand=pipehandle."_command"

  let openstmt=    "my\t$".pipecommand." = \" | \";\t\t# pipe command\n\n"
  let openstmt= openstmt.'open  my $'.pipehandle.", $".pipecommand."\n"
  let openstmt= openstmt."\tor die  \"$0 : failed to open  pipe '$".pipecommand."' : $!\\n\";\n\n"

  let closestmt=           "\n".'close  $'.pipehandle."\n"
  let closestmt= closestmt."\tor warn \"$0 : failed to close pipe '$".pipecommand."' : $!\\n\";\n\n"

	if a:mode == "a"
		let	all	= openstmt.closestmt
		put =all
		if v:version < 700
			normal =5+
		else
			normal =8-
		endif
	end

	if a:mode == "v"
		if v:version < 700
			:'<put! =openstmt
			normal =4+
			:'>put =closestmt
			normal =2+
			:'<-5
		else
			:'<put! =openstmt
			normal =5-
			:'>put =closestmt
			normal =3-
			:'<-5
		endif
	end

  normal f|
endfunction   " ---------- end of function  Perl_OpenPipe  ----------
"
"------------------------------------------------------------------------------
"  Perl-Idioms : read / edit code snippet
"------------------------------------------------------------------------------
function! Perl_CodeSnippet(mode)
  if isdirectory(s:Perl_CodeSnippets)
    "
    " read snippet file, put content below current line
    " 
    if a:mode == "r"
			if has("gui_running")
				let l:snippetfile=browse(0,"read a code snippet",s:Perl_CodeSnippets,"")
			else
				let	l:snippetfile=input("read snippet ", s:Perl_CodeSnippets, "file" )
			end
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
			if has("gui_running")
				let l:snippetfile=browse(0,"edit a code snippet",s:Perl_CodeSnippets,"")
			else
				let	l:snippetfile=input("edit snippet ", s:Perl_CodeSnippets, "file" )
			end
      if l:snippetfile != ""
        :execute "update! | split | edit ".l:snippetfile
      endif
    endif
    "
    " write whole buffer or marked area into snippet file 
    " 
    if a:mode == "w" || a:mode == "wv"
			if has("gui_running")
				let l:snippetfile=browse(0,"write a code snippet",s:Perl_CodeSnippets,"")
			else
				let	l:snippetfile=input("write snippet ", s:Perl_CodeSnippets, "file" )
			end
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
				end
      endif
    endif

  else
    redraw
    echohl ErrorMsg
    echo "code snippet directory ".s:Perl_CodeSnippets." does not exist"
    echohl None
  endif
endfunction   " ---------- end of function  Perl_CodeSnippet  ----------
"
"------------------------------------------------------------------------------
"  Perl-Run : Perl_perldoc - lookup word under the cursor or ask
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
			let item=Perl_Input("perldoc - module, function or FAQ keyword : ", "")
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
  endif
endfunction   " ---------- end of function  Perl_perldoc  ----------
"
"------------------------------------------------------------------------------
"  Perl-Run : Perl_perldoc - show module list
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! Perl_perldoc_show_module_list()
  if !filereadable(s:Perl_PerlModuleList)
    redraw
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
  redraw
  if has("gui_running")
    echohl Search | echomsg 'use S-F1 to show a manual' | echohl None
  else
    echohl Search | echomsg 'use \hh in normal mode to show a manual' | echohl None
  endif
endfunction   " ---------- end of function  Perl_perldoc_show_module_list  ----------
"
"------------------------------------------------------------------------------
"  Perl-Run : Perl_perldoc - generate module list
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
    silent exe ":!perl ".s:Perl_PerlModuleListGenerator." > ".s:Perl_PerlModuleList
    silent exe ":!sort ".s:Perl_PerlModuleList." /O ".s:Perl_PerlModuleList
  else
		" direct STDOUT and STDERR to the module list file :
    silent exe ":!perl ".s:Perl_PerlModuleListGenerator." -s &> ".s:Perl_PerlModuleList
  endif
  echo " DONE " 
  echohl None
endfunction   " ---------- end of function  Perl_perldoc_generate_module_list  ----------
"
"------------------------------------------------------------------------------
"  Run : settings
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! Perl_Settings ()
  let txt =     "  Perl-Support settings\n\n"
  let txt = txt.'            author name  :  "'.s:Perl_AuthorName."\"\n"
  let txt = txt.'               initials  :  "'.s:Perl_AuthorRef."\"\n"
  let txt = txt.'                  email  :  "'.s:Perl_Email."\"\n"
  let txt = txt.'                company  :  "'.s:Perl_Company."\"\n"
  let txt = txt.'                project  :  "'.s:Perl_Project."\"\n"
  let txt = txt.'       copyright holder  :  "'.s:Perl_CopyrightHolder."\"\n"
  let txt = txt." code snippet directory  :  ".s:Perl_CodeSnippets."\n"
  let txt = txt."     template directory  :  ".s:Perl_Template_Directory."\n"
  if g:Perl_Dictionary_File != ""
    let ausgabe = substitute( g:Perl_Dictionary_File, ",", ",\n                          + ", "g" )
    let txt     = txt."      dictionary file(s) :  ".ausgabe."\n"
  endif
  let txt = txt."   current output dest.  :  ".s:Perl_OutputGvim."\n"
  let txt = txt."             perlcritic  :  perlcritic -severity ".s:Perl_PerlcriticSeverity
				\				." -verbosity ".s:Perl_PerlcriticVerbosity
				\				." ".s:Perl_PerlcriticOptions."\n"
	if s:Perl_InterfaceVersion != ''
		let txt = txt." Perl interface version  :  ".s:Perl_InterfaceVersion."\n"
	endif
  let txt = txt."\n"
  let txt = txt."    Additional hot keys\n\n"
  let txt = txt."               Shift-F1  :  read perldoc (for word under cursor)\n"
  let txt = txt."                     F9  :  start a debugger (".s:Perl_Debugger.")\n"
  let txt = txt."                 Alt-F9  :  run syntax check          \n"
  let txt = txt."                Ctrl-F9  :  run script                \n"
  let txt = txt."               Shift-F9  :  set command line arguments\n"
  let txt = txt."_________________________________________________________________________\n"
  let txt = txt." Perl-Support, Version ".g:Perl_Version." / Dr.-Ing. Fritz Mehner / mehner@fh-swf.de\n\n"
  echo txt
endfunction   " ---------- end of function  Perl_Settings  ----------
"
"------------------------------------------------------------------------------
"  run : syntax check
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! Perl_SyntaxCheck ()
  let s:Perl_SyntaxCheckMsg = ""
  exe ":cclose"
  let l:currentbuffer   = bufname("%")
	let l:fullname        = expand("%:p")
  silent exe  ":update"
  "
  " avoid filtering the Perl output if the file name does not contain blanks:
  " 
  if l:fullname !~ " " 
    " 
		" no whitespaces
    " Errorformat from compiler/perl.vim (VIM distribution).
    "
    exe "set makeprg=perl\\ -cw\\ $*"
    exe ':setlocal errorformat=
        \%-G%.%#had\ compilation\ errors.,
        \%-G%.%#syntax\ OK,
        \%m\ at\ %f\ line\ %l.,
        \%+A%.%#\ at\ %f\ line\ %l\\,%.%#,
        \%+C%.%#'
  else
    "
    " Use tools/efm_perl.pl from the VIM distribution.
    " This wrapper can handle filenames containing blanks.
    " Errorformat from tools/efm_perl.pl .
    " 
    exe "set makeprg=".s:Perl_EfmPerl."\\ -c\\ "
    exe ':setlocal errorformat=%f:%l:%m'
  endif

  silent exe  ":make ".escape( l:fullname, s:escfilename )

  exe ":botright cwindow"
  exe ':setlocal errorformat='
  exe "set makeprg=make"
  "
  " message in case of success
  "
  if l:currentbuffer ==  bufname("%")
    let s:Perl_SyntaxCheckMsg = l:currentbuffer." : Syntax is OK"
    return 0
  else
    setlocal wrap
    setlocal linebreak
  endif
  return 1
endfunction   " ---------- end of function  Perl_SyntaxCheck  ----------
"
"  Also called in the filetype plugin perl.vim
function! Perl_SyntaxCheckMsg ()
    echohl Search 
    echo s:Perl_SyntaxCheckMsg
    echohl None
endfunction   " ---------- end of function  Perl_SyntaxCheckMsg  ----------
"
"----------------------------------------------------------------------
"  run : toggle output destination
"  Also called in the filetype plugin perl.vim
"----------------------------------------------------------------------
function! Perl_Toggle_Gvim_Xterm ()

	if s:Perl_OutputGvim == "vim"
		if has("gui_running")
			exe "aunmenu  <silent>  ".s:Perl_Root.'&Run.&output:\ VIM->buffer->xterm'
			exe "amenu    <silent>  ".s:Perl_Root.'&Run.&output:\ BUFFER->xterm->vim              :call Perl_Toggle_Gvim_Xterm()<CR>'
		endif
		let	s:Perl_OutputGvim	= "buffer"
	else
		if s:Perl_OutputGvim == "buffer"
			if has("gui_running")
				exe "aunmenu  <silent>  ".s:Perl_Root.'&Run.&output:\ BUFFER->xterm->vim'
				if (!s:MSWIN) 
					exe "amenu    <silent>  ".s:Perl_Root.'&Run.&output:\ XTERM->vim->buffer             :call Perl_Toggle_Gvim_Xterm()<CR>'
				else
					exe "amenu    <silent>  ".s:Perl_Root.'&Run.&output:\ VIM->buffer->xterm            :call Perl_Toggle_Gvim_Xterm()<CR>'
				endif
			endif
			if (!s:MSWIN) && (s:Perl_Display != '')
				let	s:Perl_OutputGvim	= "xterm"
			else
				let	s:Perl_OutputGvim	= "vim"
			end
		else
			" ---------- output : xterm -> gvim
			if has("gui_running")
				exe "aunmenu  <silent>  ".s:Perl_Root.'&Run.&output:\ XTERM->vim->buffer'
				exe "amenu    <silent>  ".s:Perl_Root.'&Run.&output:\ VIM->buffer->xterm            :call Perl_Toggle_Gvim_Xterm()<CR>'
			endif
			let	s:Perl_OutputGvim	= "vim"
		endif
	endif
  echomsg "output destination is '".s:Perl_OutputGvim."'"

endfunction    " ----------  end of function Perl_Toggle_Gvim_Xterm ----------
"
"------------------------------------------------------------------------------
"  run : Perl_PerlSwitches
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! Perl_PerlSwitches ()
  let filename = escape(expand("%"),s:escfilename)
  if filename == ""
    redraw
    echohl WarningMsg | echo " no file name " | echohl None
    return
  endif
  let prompt   = 'perl command line switches for "'.filename.'" : '
  if exists("b:Perl_Switches")
    let b:Perl_Switches= Perl_Input( prompt, b:Perl_Switches )
  else
    let b:Perl_Switches= Perl_Input( prompt , "" )
  endif
endfunction   " ---------- end of function  Perl_PerlSwitches  ----------
"
"------------------------------------------------------------------------------
"  run : run
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
"
let s:Perl_OutputBufferName   = "Perl-Output"
let s:Perl_OutputBufferNumber = -1
"
function! Perl_Run ()
  "
  if &filetype != "perl"
    echohl WarningMsg | echo expand("%").' seems not to be a Perl file' | echohl None
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
  let l:fullname        = escape( expand("%:p"), s:escfilename )
  "
  silent exe ":update"
  silent exe ":cclose"
  "
  if  s:MSWIN
    let l:arguments = substitute( l:arguments, '^\s\+', ' ', '' )
    let l:arguments = substitute( l:arguments, '\s\+', "\" \"", 'g')
    let l:switches  = substitute( l:switches, '^\s\+', ' ', '' )
    let l:switches  = substitute( l:switches, '\s\+', "\" \"", 'g')
  endif
  "
  "------------------------------------------------------------------------------
  "  run : run from the vim command line
  "------------------------------------------------------------------------------
  if s:Perl_OutputGvim == "vim"
    "
    if  s:MSWIN
      exe "!perl \"".l:switches.l:fullname." ".l:arguments."\""
    else
      exe "!perl ".l:switches.l:fullname.l:arguments
    endif
    "
  endif
  "
  "------------------------------------------------------------------------------
  "  run : redirect output to an output buffer
  "------------------------------------------------------------------------------
  if s:Perl_OutputGvim == "buffer"
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
        exe "%!perl \"".l:switches.l:fullname.l:arguments."\""
      else
        exe "%!perl ".l:switches.l:fullname.l:arguments
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
  if s:Perl_OutputGvim == "xterm"
    "
    if  s:MSWIN
      " same as "vim"
      exe "!perl \"".l:switches.l:fullname." ".l:arguments."\""
    else
      silent exe '!xterm -title '.l:fullname.' '.s:Perl_XtermDefaults.' -e '.s:Perl_Wrapper.' perl '.l:switches.l:fullname.l:arguments
			:redraw!
    endif
    "
  endif
  "
endfunction    " ----------  end of function Perl_Run  ----------
"
"------------------------------------------------------------------------------
"  run : start debugger
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! Perl_Debugger ()
  "
  silent exe  ":update"
  let l:arguments = exists("b:Perl_CmdLineArgs") ? " ".b:Perl_CmdLineArgs : ""
  let Sou         = escape( expand("%"), s:escfilename ) 
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
      silent exe "!perl -d \"".Sou.l:arguments."\""
    else
      if has("gui_running") || &term == "xterm"
        silent exe "!xterm ".s:Perl_XtermDefaults.' -e perl -d ./'.Sou.l:arguments.' &'
      else
        silent exe '!clear; perl -d ./'.Sou.l:arguments
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
        silent exe "!perl -d:ptkdb \"".Sou.l:arguments."\""
      else
        silent exe '!perl -d:ptkdb  ./'.Sou.l:arguments.' &'
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
        silent exe '!ddd ./'.Sou.l:arguments.' &'
      endif
    endif
    "
  endif
  "
endfunction   " ---------- end of function  Perl_Debugger  ----------
"
"------------------------------------------------------------------------------
"  run : Arguments
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! Perl_Arguments ()
  let filename = escape(expand("%"),s:escfilename)
  if filename == ""
    redraw
    echohl WarningMsg | echo " no file name " | echohl None
    return
  endif
  let prompt   = 'command line arguments for "'.filename.'" : '
  if exists("b:Perl_CmdLineArgs")
    let b:Perl_CmdLineArgs= Perl_Input( prompt, b:Perl_CmdLineArgs )
  else
    let b:Perl_CmdLineArgs= Perl_Input( prompt , "" )
  endif
endfunction   " ---------- end of function  Perl_Arguments  ----------
"
"------------------------------------------------------------------------------
"  run : xterm geometry
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
"  run : make script executable
"  Also called in the filetype plugin perl.vim
"  Only on systems where execute permission is implemented
"------------------------------------------------------------------------------
function! Perl_MakeScriptExecutable ()
  let filename  = escape( expand("%:p"), s:escfilename )
  if executable(filename) == 0                  " not executable
    silent exe "!chmod u+x ".filename
    redraw
    if v:shell_error
      echohl WarningMsg
      echo 'Could not make "'.filename.'" executable !'
    else
      echohl Search
      echo 'Made "'.filename.'" executable.'
    endif
    echohl None
  endif
endfunction   " ---------- end of function  Perl_MakeScriptExecutable  ----------
"
"------------------------------------------------------------------------------
"  POD section for a special processor
"------------------------------------------------------------------------------
function! Perl_PodPodCut (mode)
  if a:mode=='a'
    let zz="\n=pod\n\n\n\n=cut\n\n"
    silent put =zz
  endif

  if a:mode=='v'
    let zz="\n=pod\n\n"
    :'<put! =zz
    let zz="\n=cut\n\n"
    :'>put =zz
  endif
endfunction   " ---------- end of function  Perl_PodPodCut  ----------
"
"------------------------------------------------------------------------------
"  POD section for a special processor
"------------------------------------------------------------------------------
function! Perl_PodForCut (mode)
  if a:mode=='a'
    let zz="\n=for  \n\n=cut\n\n"
    silent put =zz
  endif

  if a:mode=='v'
    let zz="\n=for  \n\n"
    :'<put! =zz
    let zz="\n=cut\n\n"
    :'>put =zz
    :'<-2
  endif
endfunction   " ---------- end of function  Perl_PodForCut  ----------
"
"------------------------------------------------------------------------------
"  POD section for a special processor
"------------------------------------------------------------------------------
function! Perl_PodOverBack (mode)
  if a:mode=='a'
    let zz="\n=over 2\n\n=item *\n\n\n\n=item *\n\n\n\n=back\n\n"
    silent put =zz
  endif

  if a:mode=='v'
    let zz="\n=over 2\n\n=item *\n\n"
    :'<put! =zz
    let zz="\n=item *\n\n\n\n=back\n\n"
    :'>put =zz
    :'>+4
  endif
endfunction   " ---------- end of function  Perl_PodOverBack  ----------
"
"------------------------------------------------------------------------------
"  POD section for a special processor
"------------------------------------------------------------------------------
function! Perl_PodProcessor (mode,processor)
  if a:mode=='a'
    let zz="\n=begin  ".a:processor."\n\n\n\n=end    ".a:processor."  #  back to Perl\n\n"
    silent put =zz
  endif

  if a:mode=='v'
    let zz="\n=begin  ".a:processor."\n\n"
    :'<put! =zz
    let zz="\n=end    ".a:processor."  #  back to Perl\n\n"
    :'>put =zz
  endif
endfunction   " ---------- end of function  Perl_PodProcessor  ----------
"
"------------------------------------------------------------------------------
"  run POD checker
"------------------------------------------------------------------------------
function! Perl_PodCheck ()
  let s:Perl_PodCheckMsg = ""
  exe ":cclose"
  let l:currentbuffer   = bufname("%")
  silent exe  ":update"
  "
  if s:Perl_PodcheckerWarnings == "no"
    let PodcheckerWarnings  = '-nowarnings '
  else
    let PodcheckerWarnings  = '-warnings '
  endif
  exe ':set makeprg=podchecker\ '.PodcheckerWarnings

  exe ':setlocal errorformat=***\ %m\ at\ line\ %l\ in\ file\ %f'

  let l:fullname        = escape( expand("%:p"), s:escfilename )
  "
	if  s:MSWIN
		silent exe  ":make \"".l:fullname."\""
	else
		silent exe  ":make ".l:fullname
	endif

  exe ":botright cwindow"
  exe ':setlocal errorformat='
  exe ":set makeprg=make"
  "
  " message in case of success
  "
  if l:currentbuffer ==  bufname("%")
    let s:Perl_PodCheckMsg = l:currentbuffer." : POD syntax is OK"
    return 0
  endif
  return 1
endfunction   " ---------- end of function  Perl_PodCheck  ----------
"
function! Perl_PodCheckMsg ()
    echohl Search 
    echo s:Perl_PodCheckMsg
    echohl None
endfunction   " ---------- end of function  Perl_PodCheckMsg  ----------
"
"------------------------------------------------------------------------------
"  run : POD -> html / man / text
"------------------------------------------------------------------------------
function! Perl_POD ( format )
  let filename  = escape( expand("%:p"), s:escfilename )
  let target	  = escape( expand("%:p:r"), s:escfilename ).'.'.a:format
  silent exe  ":update"
	if  s:MSWIN
		if a:format=='html'
			silent exe  ":!pod2".a:format." \"--infile=".filename."\" \"--outfile=".target."\""
		else
			silent exe  ":!pod2".a:format." \"".filename."\" \"".target."\""
		endif
	else
		silent exe  ":!pod2".a:format." ".filename." > ".target
	endif
  echo  " '".target."' generated"
endfunction   " ---------- end of function  Perl_POD  ----------
"
"------------------------------------------------------------------------------
"  POD : invisible PODs
"------------------------------------------------------------------------------
function! Perl_InvisiblePOD (mode,arg1)
  "
  if a:mode=='a'
    let zz =    "\n=for ".a:arg1.": <keyword>"
    let zz = zz."\n<single paragraph>\n\n=cut\n\n"
    put =zz
    if v:version < 700
      normal j2W
    else
      normal 4k2W
    endif
  endif
  "
  if a:mode=='v'
    let firstnonempty = line("'<")
    while match( getline(firstnonempty), '^\s*$' ) == 0
      let firstnonempty = firstnonempty+1
    endwhile
    let zz = "\n=for ".a:arg1.": <keyword>"
    exe firstnonempty."put! =zz"
    let zz = "\n=cut\n\n"
    :'>put =zz
  endif
  "
endfunction   " ---------- end of function  Perl_POD  ----------
"
"------------------------------------------------------------------------------
"  run : perltidy
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
"
let s:Perl_perltidy_startscript_executable = 'no'
let s:Perl_perltidy_module_executable      = 'no'

function! Perl_Perltidy (mode)

  let Sou   = expand("%")               " name of the file in the current buffer
  if &filetype != "perl"
    echohl WarningMsg | echo Sou.' seems not to be a Perl file' | echohl None
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
    if Perl_Input("reformat whole file [y/n/Esc] : ", "y" ) != "y"
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
    echo "File \"".Sou."\" reformatted."
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
    echo "File \"".Sou."\" (lines ".pos1."-".pos2.") reformatted."
  endif
  "
  if filereadable("perltidy.ERR")
    echohl WarningMsg
    echo 'Perltidy detected an error when processing file "'.Sou.'". Please see file perltidy.ERR' 
    echohl None
  endif
  "
endfunction   " ---------- end of function  Perl_Perltidy  ----------
"
"------------------------------------------------------------------------------
"  run : SmallProf
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
let s:Perl_ProfileOutput    = 'smallprof.out'
let s:Perl_TimestampFormat  = '%y%m%d.%H%M%S'
  
function! Perl_Smallprof ()
  let Sou   = escape( expand("%"), s:escfilename ) " name of the file in the current buffer
  if &filetype != "perl"
    echohl WarningMsg | echo Sou.' seems not to be a Perl file' | echohl None
    return
  endif
  silent exe  ":update"
  "
  let l:arguments       = exists("b:Perl_CmdLineArgs") ? " ".b:Perl_CmdLineArgs : ""
  "
  echohl Search | echo ' ... profiling ... ' | echohl None
  "
  silent exe '!perl -d:SmallProf '.Sou.l:arguments
  "
  if v:shell_error
    redraw
    echohl WarningMsg | echo 'Could not execute "perl -d:SmallProf '.Sou.l:arguments.'"' | echohl None
    return
  endif
    "
  let currentbuffer = s:Perl_ProfileOutput
  if s:Perl_ProfilerTimestamp=="yes"
    let currentbuffer=currentbuffer.".".strftime(s:Perl_TimestampFormat)
    call rename( s:Perl_ProfileOutput, currentbuffer )
  endif
  echohl Search | echo 'file "'.Sou.'" profiled' | echohl None
  if filereadable(currentbuffer) 
    let currentbuffernr=bufnr(currentbuffer)
    if currentbuffernr==-1          " buffer not open
      exe ":botright new"
      exe ":edit +set\\ autoread ".currentbuffer
    else
      if bufwinnr(currentbuffernr)!=-1    " window open ?
        exe  bufwinnr(currentbuffernr) . "wincmd w"
      else
        :botright new
        exe ":buffer ".currentbuffer
      endif
    endif
    normal gg
  else
    echohl WarningMsg | echo currentbuffer.' (profiling results) not readable!' | echohl None
  endif

endfunction   " ---------- end of function  Perl_Smallprof  ----------
"
"------------------------------------------------------------------------------
"  run : Save buffer with timestamp
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! Perl_SaveWithTimestamp ()
  if expand("%") == ""
    redraw
    echohl WarningMsg | echo " no file name " | echohl None
    return
  endif
  let Sou   = escape( expand("%"), s:escfilename ) " name of the file in the current buffer
  let Sou   = Sou.".".strftime(s:Perl_TimestampFormat)
  silent exe ":write ".Sou
  echomsg 'file "'.Sou.'" written'
endfunction   " ---------- end of function  Perl_SaveWithTimestamp  ----------
"
"------------------------------------------------------------------------------
"  run : hardcopy
"    MSWIN : a printer dialog is displayed
"    other : print PostScript to file
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! Perl_Hardcopy (mode)
  let Sou = expand("%") 
  if Sou == ""
    redraw
    echohl WarningMsg | echo " no file name " | echohl None
    return
  endif
  let target  = bufname("%")==s:Perl_PerldocBufferName ? '$HOME/' : './'
  let Sou     = target.expand("%")
  let old_printheader=&printheader
  exe  ':set printheader='.s:Perl_Printheader
  " ----- normal mode ----------------
  if a:mode=="n"
    silent exe  "hardcopy > ".Sou.".ps"   
    if  !s:MSWIN
      echo "file \"".Sou."\" printed to \"".Sou.".ps\""
    endif
  endif
  " ----- visual mode ----------------
  if a:mode=="v"
    silent exe  "*hardcopy > ".Sou.".ps"    
    if  !s:MSWIN
      echo "file \"".Sou."\" (lines ".line("'<")."-".line("'>").") printed to \"".Sou.".ps\""
    endif
  endif
  exe  ':set printheader='.escape( old_printheader, ' %' )
endfunction   " ---------- end of function  Perl_Hardcopy  ----------
"
"------------------------------------------------------------------------------
"  run : help perlsupport 
"------------------------------------------------------------------------------
function! Perl_HelpPerlsupport ()
  try
    :help perlsupport
  catch
    exe ':helptags '.s:plugin_dir.'doc'
    :help perlsupport
  endtry
endfunction    " ----------  end of function Perl_HelpPerlsupport ----------

"------------------------------------------------------------------------------
"  Perl_CreateGuiMenus
"------------------------------------------------------------------------------
let s:Perl_MenuVisible = 0								" state : 0 = not visible / 1 = visible
"
function! Perl_CreateGuiMenus ()
  if s:Perl_MenuVisible != 1
		aunmenu <silent> &Tools.Load\ Perl\ Support
    amenu   <silent> 40.1000 &Tools.-SEP100- : 
    amenu   <silent> 40.1160 &Tools.Unload\ Perl\ Support :call Perl_RemoveGuiMenus()<CR>
    call Perl_InitMenu()
    let s:Perl_MenuVisible = 1
  endif
endfunction    " ----------  end of function Perl_CreateGuiMenus  ----------

"------------------------------------------------------------------------------
"  Perl_ToolMenu
"------------------------------------------------------------------------------
function! Perl_ToolMenu ()
    amenu   <silent> 40.1000 &Tools.-SEP100- : 
    amenu   <silent> 40.1160 &Tools.Load\ Perl\ Support :call Perl_CreateGuiMenus()<CR>
endfunction    " ----------  end of function Perl_ToolMenu  ----------

"------------------------------------------------------------------------------
"  Perl_RemoveGuiMenus
"------------------------------------------------------------------------------
function! Perl_RemoveGuiMenus ()
  if s:Perl_MenuVisible == 1
    if s:Perl_Root == ""
      aunmenu <silent> Comments
      aunmenu <silent> Statements
      aunmenu <silent> Idioms
      aunmenu <silent> Regex
      aunmenu <silent> File-Tests
      aunmenu <silent> Spec-Var
      aunmenu <silent> POD
      aunmenu <silent> Run
      aunmenu <silent> help
    else
      exe "aunmenu <silent> ".s:Perl_Root
    endif
    "
    aunmenu <silent> &Tools.Unload\ Perl\ Support
		call Perl_ToolMenu()
    "
    let s:Perl_MenuVisible = 0
  endif
endfunction    " ----------  end of function Perl_RemoveGuiMenus  ----------
"
"------------------------------------------------------------------------------
"  run : perlcritic 
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
let s:PCverbosityFormat4 	= '\"\\%f:\\%l:\\%c:\\%m\.\ \ \\%e\ \ (Severity:\ \\%s)\\n\"' 
let s:PCverbosityFormat5 	= '\"\\%f:\\%l:\\%c:\\%m\.\ \ \\%e\ \ (Severity:\ \\%s)\\n\"' 
let s:PCverbosityFormat6 	= '\"\\%f:\\%l:\\%m,\ near\ ' . "'\\\\%r'\." . '\ \ (Severity:\ \\%s)\\n\"' 
let s:PCverbosityFormat7 	= '\"\\%f:\\%l:\\%m,\ near\ ' . "'\\\\%r'\." . '\ \ (Severity:\ \\%s)\\n\"' 
let s:PCverbosityFormat8 	= '\"\\%f:\\%l:\\%c:[\\%p]\ \\%m\.\ (Severity:\ \\%s)\\n\"' 
let s:PCverbosityFormat9 	= '\"\\%f:\\%l:[\\%p]\ \\%m,\ near\ ' . "'\\\\%r'" . '\.\ (Severity:\ \\%s)\\n\"' 
let s:PCverbosityFormat10	= '\"\\%f:\\%l:\\%c:\\%m\.\\n\ \ \\%p\ (Severity:\ \\%s)\\n\\%d\\n\"' 
let s:PCverbosityFormat11	= '\"\\%f:\\%l:\\%m,\ near\ ' . "'\\\\%r'" . '\.\\n\ \ \\%p\ (Severity:\ \\%s)\\n\\%d\\n\"' 
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
  exe  ':set makeprg=perlcritic\ -severity\ '.s:Perl_PerlcriticSeverity
      \                      .'\ -verbose\ '.eval("s:PCverbosityFormat".s:Perl_PerlcriticVerbosity)
      \                      .'\ '.escape( s:Perl_PerlcriticOptions, s:escfilename )
	"
  exe  ':setlocal errorformat='.eval("s:PCerrorFormat".s:Perl_PerlcriticVerbosity)
  "
	if  s:MSWIN
		silent exe ':make "'.escape( expand("%:p"), s:escfilename )."\""
	else
		silent exe ':make '.escape( expand("%:p"), s:escfilename )
	endif
  "
  exe ":botright cwindow"
  exe ':setlocal errorformat='
  exe "set makeprg=make"
  "
  " message in case of success
  "
  if l:currentbuffer ==  bufname("%")
    let s:Perl_PerlcriticMsg= l:currentbuffer." : no critique "
  else
    setlocal wrap
    setlocal linebreak
  endif

endfunction   " ---------- end of function  Perl_Perlcritic  ----------
"
function! Perl_PerlcriticMsg ()
  if s:Perl_PerlcriticMsg != ""
    echohl Search | echo s:Perl_PerlcriticMsg | echohl None
  endif
endfunction   " ---------- end of function  Perl_PerlcriticMsg  ----------
"
"-------------------------------------------------------------------------------
"   set severity for perlcritic
"-------------------------------------------------------------------------------
let s:PCseverityName1	= "brutal"
let s:PCseverityName2	= "cruel"
let s:PCseverityName3	= "harsh"
let s:PCseverityName4	= "stern"
let s:PCseverityName5	= "gentle"
"
function! Perl_PerlCriticSeverity ( severity )
	let s:Perl_PerlcriticSeverity = 3                         " the default
	let	sev	= a:severity
	let sev	= substitute( sev, '^\s\+', '', '' )  	     			" remove leading whitespaces
	let sev	= substitute( sev, '\s\+$', '', '' )	       			" remove trailing whitespaces
	"
	" parameter is numeric 
	if sev =~ '^\d$' && 1 <= sev && sev <= 5
		let s:Perl_PerlcriticSeverity = sev
	else
		"
		" parameter is word
		if sev =~ '^\a\+$'
			let	sev = tolower(sev)
			let nr	= 1
			while nr<=5
				if eval("s:PCseverityName".nr) == sev
					let s:Perl_PerlcriticSeverity = nr
					return
				end
				let	nr	= nr+1
			endwhile
		endif
		"
		echomsg "wrong argument '".a:severity."' / severity is set to ".s:Perl_PerlcriticSeverity
	endif
endfunction    " ----------  end of function Perl_PerlCriticSeverity  ----------
"
"-------------------------------------------------------------------------------
"   set verbosity for perlcritic
"-------------------------------------------------------------------------------
function! Perl_PerlCriticVerbosity ( verbosity )
	let s:Perl_PerlcriticVerbosity = 4
	let	vrb	= a:verbosity
  let vrb	= substitute( vrb, '^\s\+', '', '' )  	     			" remove leading whitespaces
  let vrb	= substitute( vrb, '\s\+$', '', '' )	       			" remove trailing whitespaces
  if vrb =~ '^\d\{1,2}$' && 1 <= vrb && vrb <= 11
    let s:Perl_PerlcriticVerbosity = vrb
	else
		echomsg "wrong argument '".a:verbosity."' / verbosity is set to ".s:Perl_PerlcriticVerbosity
  endif
endfunction    " ----------  end of function Perl_PerlCriticVerbosity  ----------
"
"-------------------------------------------------------------------------------
"   set options for perlcritic
"-------------------------------------------------------------------------------
function! Perl_PerlCriticOptions ( ... )
	let s:Perl_PerlcriticOptions = ""
	if a:0 > 0
		let s:Perl_PerlcriticOptions = a:1
	end
endfunction    " ----------  end of function Perl_PerlCriticOptions  ----------
"
"------------------------------------------------------------------------------
"  Check the perlcritic default severity and verbosity.
"------------------------------------------------------------------------------
call Perl_PerlCriticSeverity (s:Perl_PerlcriticSeverity)
call Perl_PerlCriticVerbosity(s:Perl_PerlcriticVerbosity)
"
"------------------------------------------------------------------------------
"  show / hide the menus
"  define key mappings (gVim only) 
"------------------------------------------------------------------------------
"
if has("gui_running")
  "
	call Perl_ToolMenu()
	"
  if s:Perl_LoadMenus == 'yes'
    call Perl_CreateGuiMenus()
  endif
  "
  nmap    <silent>  <Leader>lps             :call Perl_CreateGuiMenus()<CR>
  nmap    <silent>  <Leader>ups             :call Perl_RemoveGuiMenus()<CR>
  "
endif
"
"------------------------------------------------------------------------------
"  Automated header insertion
"------------------------------------------------------------------------------
if has("autocmd")
	
	autocmd BufNewFile  *.pl  call Perl_CommentTemplates('header')	|	:w!
	autocmd BufNewFile  *.pm  call Perl_CommentTemplates('module')	|	:w!
	autocmd BufNewFile  *.t   call Perl_CommentTemplates('test')  	|	:w!
  "
  autocmd BufRead            *.pod  set filetype=perl
  autocmd BufNewFile         *.pod  set filetype=perl | call Perl_CommentTemplates("pod")
  autocmd BufNewFile,BufRead *.t    set filetype=perl
  "
  " Wrap error descriptions in the quickfix window.
  autocmd BufReadPost quickfix  setlocal wrap | setlocal linebreak 
  "
endif
"
"------------------------------------------------------------------------------
"   run the regular expression analyzer YAPE::Regex::Explain
"------------------------------------------------------------------------------
let s:Perl_PerlRegexBufferName    = 'REGEX-EXPLAIN'
let s:Perl_PerlRegexBufferNumber	= -1
let s:Perl_PerlRegexAnalyser			= 'yes'

function! Perl_RegexExplain( mode )

	if !has('perl')
		echomsg	"*** Your version of Vim was not compiled with Perl interface. ***"
		return
	endif

	if s:Perl_PerlRegexAnalyser	!= 'yes'
		echomsg	"*** The Perl module YAPE::Regex::Explain can not be found. ***"
		return
	endif

	if a:mode == 'v'
		call Perl_RegexPick ( "regexp", "v" )
	endif

	if bufloaded(s:Perl_PerlRegexBufferName) != 0 && bufwinnr(s:Perl_PerlRegexBufferNumber) != -1
		silent exe bufwinnr(s:Perl_PerlRegexBufferNumber) . "wincmd w"
		" buffer number may have changed, e.g. after a 'save as' 
	else
		silent exe ":new ".s:Perl_PerlRegexBufferName
		let s:Perl_PerlRegexBufferNumber=bufnr("%")
		setlocal buftype=nofile
		setlocal noswapfile
		setlocal bufhidden=delete
		setlocal syntax=OFF
	endif
	"
	" remove content if any
	"
	silent normal	ggdG

  perl <<EOF
			my $explanation;
			my ( $success, $regexp ) = VIM::Eval('s:MSWIN');

			my	$flag			= VIM::Eval('s:Perl_PerlRegexVisualizeFlag');
			( $success, $regexp )	= VIM::Eval('s:Perl_PerlRegexVisualize_regexp');
			if ( $success == 1 ) {
				# get the explanation
				$regexp = eval 'qr{'.$regexp.'}'.$flag;
				$explanation	= YAPE::Regex::Explain->new($regexp)->explain();
				}
			else {
				$explanation	= "\n*** VIM failed to evaluate the regular expression ***\n";
				}

			# split explanation into lines
			my	@explanation	= split /\n/, $explanation;

			# put the explanation to the top of the buffer
			$curbuf->Append( 0, @explanation );
EOF

endfunction    " ----------  end of function Perl_RegexExplain  ----------
"
"-------------------------------------------------------------------------------
"   read the substitution characters for \n, \t,  ... from the command line
"-------------------------------------------------------------------------------
function! Perl_PerlRegexSubstitutions ( string )
	let result  = a:string
	let result  = substitute( result, '^\s\+', '', '' )  " remove leading whitespaces
	let result 	= substitute( result, '\s\+$', '', '' )	 " remove trailing whitespaces
	let result 	= substitute( result, "^'", '', '' )
	let result 	= substitute( result, "'$", '', '' )
	"
	" replacement string: length 2, printable characters, no control characters
	"
	if 			strlen( result )                   ==  2 && 
				\	match( result, '^[[:print:]]\+$' ) ==  0 &&
				\	match( result, '[[:cntrl:]]' )     == -1 
		let s:Perl_PerlRegexSubstitution 	= result
	endif
endfunction    " ----------  end of function Perl_PerlRegexSubstitutions  ----------
"
"------------------------------------------------------------------------------
"   RUN THE REGULAR EXPRESSION VISUALIZOR
"------------------------------------------------------------------------------
let s:Perl_PerlRegexVisualizeBufferName   = 'REGEX-TEST'
let s:Perl_PerlRegexVisualizeBufferNumber = -1
let s:Perl_PerlRegexVisualize_regexp      = ''
let s:Perl_PerlRegexVisualize_string      = ''
let s:Perl_PerlRegexVisualizeFlag         = ''
let s:Perl_PerlRegexCodeEvaluation        = 'off'
let s:Perl_PerlRegexPrematch              = ''
let s:Perl_PerlRegexMatch                 = ''
"
"------------------------------------------------------------------------------
"   command line switch 'RegexCodeEvaluation'
"------------------------------------------------------------------------------
function! Perl_RegexCodeEvaluation ( onoff )
	if a:onoff == 'on'
		let s:Perl_PerlRegexCodeEvaluation				= 'on'
	else
		let s:Perl_PerlRegexCodeEvaluation				= 'off'
	endif
endfunction    " ----------  end of function Perl_RegexCodeEvaluation  ----------

"------------------------------------------------------------------------------
"   pick up string or regular expression
"------------------------------------------------------------------------------
function! Perl_RegexPick ( item, mode )
	"
	" the complete line; remove leading and trailing whitespaces
	"
	if a:mode == 'n' 
		let line	= getline(line("."))
		if  s:MSWIN
			" MSWIN : copy item to the yank-register, remove trailing CR
			let line	= substitute( line, "\n$", '', '' )
		endif
		let line	= substitute( line, '^\s\+', '', '' )  " remove leading whitespaces
		let line	= substitute( line, '\s\+$', '', '' )	 " remove trailing whitespaces
		let s:Perl_PerlRegexVisualize_{a:item}	= line
	endif
	"
	" the marked area
	"
	if a:mode == 'v' 
		" copy item to the yank-register (Windows has no selection register)
		normal gvy
		let s:Perl_PerlRegexVisualize_{a:item}	= eval('@"')
	endif
	"
	echomsg a:item." : '".s:Perl_PerlRegexVisualize_{a:item}."'"
endfunction    " ----------  end of function Perl_RegexPick  ----------
"
"------------------------------------------------------------------------------
"   pick up flags
"------------------------------------------------------------------------------
function! Perl_RegexPickFlag ( mode )
	if a:mode == 'v'
		" copy item to the yank-register
		normal gvy
		let s:Perl_PerlRegexVisualizeFlag	= eval('@"')
	else
		let s:Perl_PerlRegexVisualizeFlag = Perl_Input("regex modifier(s) [imsx] : ", s:Perl_PerlRegexVisualizeFlag )
	endif
	let s:Perl_PerlRegexVisualizeFlag=substitute(s:Perl_PerlRegexVisualizeFlag, '[^imsx]', '', 'g')
	echomsg "regex modifier(s) : '".s:Perl_PerlRegexVisualizeFlag."'"
endfunction    " ----------  end of function Perl_RegexPickFlag  ----------
"
"------------------------------------------------------------------------------
"   visualize regular expression
"------------------------------------------------------------------------------
function! Perl_RegexVisualize( )

	if !has('perl')
		echomsg	"*** Your version of Vim was not compiled with Perl interface. ***"
		return
	endif

	let l:currentbuffernr = bufnr("%")
	if bufloaded(s:Perl_PerlRegexVisualizeBufferName) != 0 && bufwinnr(s:Perl_PerlRegexVisualizeBufferNumber) != -1
		silent exe bufwinnr(s:Perl_PerlRegexVisualizeBufferNumber) . "wincmd w"
		" buffer number may have changed, e.g. after a 'save as' 
	else
		silent exe ":topleft new ".s:Perl_PerlRegexVisualizeBufferName
		let s:Perl_PerlRegexVisualizeBufferNumber=bufnr("%")
		setlocal buftype=nofile
		setlocal noswapfile
		setlocal bufhidden=delete
		setlocal syntax=OFF
	endif
	"
	" remove content if any:
	silent normal	ggdG

	perl <<EOF

	my	@substchar= split //, VIM::Eval('s:Perl_PerlRegexSubstitution');

	if ( VIM::Eval('s:Perl_PerlRegexCodeEvaluation') eq 'on' ) {
		##use re 'eval';
		##no strict "vars";
		use	utf8;                                   # Perl pragma to enable/disable UTF-8 in source
		regex_evaluate();
		}
	else {
		use	utf8;                                   # Perl pragma to enable/disable UTF-8 in source
		regex_evaluate();
		}

		#===  FUNCTION  ================================================================
		#         NAME:  regex_evaluate
		#      PURPOSE:  evaluate regex an write result into a buffer
		#   PARAMETERS:  ---
		#      RETURNS:  ---
		#===============================================================================
		sub regex_evaluate {

		my ( $regexp, $string, $flag );

		$flag			= VIM::Eval('s:Perl_PerlRegexVisualizeFlag');
		$string 	= VIM::Eval('s:Perl_PerlRegexVisualize_string') || '';
		$regexp 	= VIM::Eval('s:Perl_PerlRegexVisualize_regexp');

		utf8::decode($string);
		utf8::decode($regexp);

		if ( defined($regexp) && $regexp ne '' ) {

			my	$format1		= "%-9s [%3d,%3d] =%s \n";			# see also Perl_RegexVisualize()
			my	$format2		= "%-9s [%3d,%3d] =%s\n";
			my	$format3		= "REGEXP = m{%s}%s\n\n";
			my	$format4		= "lines : %-3d         = %s\n";
			my	$format5		= "%-9s     [%3d] =%s\n";
			my	$format6		= "%-9s undefined\n";
			my	$linecount	= 1;
			my	$lineruler;
			my	$result 		= '';
			my	$rgx_1			= q/^[a-ln-z]*m[a-ln-z]*[-]?/;
			my	$stringout	= prepare_stringout($string);

			if ( $flag =~ m{$rgx_1} ) {
				($lineruler, $linecount)	= lineruler($string);
				}

				my $regexp1	= join "\n           ", ( split /\n/, $regexp );

				$result	.= sprintf $format3, $regexp1, $flag;

				if ( $flag =~ m{$rgx_1} ) {
					$result	.= sprintf $format4, $linecount, $lineruler;
					}
				$result	.= sprintf $format1, 'STRING', 0, length $string, 
						marker_string( 0, $stringout );

				#---------------------------------------------------------------------------
				#  match (single line / multiline)
				#---------------------------------------------------------------------------
				if (	 $string =~ m{(?$flag:$regexp)}   ) {
					#
					# print the prematch, if not empty
					#
					if ( $` ne '' ) {
						$result	.= sprintf $format2, 'prematch', 0, length $`, 
						 marker_string( 0, prepare_stringout($`) );
						}
					#
					# print the match
					#
					$result	.= sprintf $format2, 'MATCH', $-[0], length $&,
					 marker_string( $-[0], prepare_stringout($&) );
					#
					# print the postmatch, if not empty
					#
					if ( $' ne '' ) {
						$result	.= sprintf $format2, 'postmatch', $+[0], length $',
						marker_string( $+[0],  prepare_stringout($') );
						}
					$result	.= "\n";
					#
					# print the numbered variables $1, $2, ...
					#
					foreach my $n ( 1 .. (scalar( @-) -1) ) {
						if ( defined eval( "\$$n" ) ) {
						$result	.= sprintf $format2, "\$$n", $-[$n], $+[$n] - $-[$n], 
							marker_string( $-[$n], prepare_stringout(substr( $string, $-[$n], $+[$n] - $-[$n] )) );
							}
						else {
						$result	.= sprintf $format6, "\$$n";
							}
					}
					$result	.= "\n";
					#
					# print $+, $^N, $LAST_SUBMATCH_RESULT (only if not equal $+ )
					#
					if ( defined $+ && defined $^N && "$+" ne "$^N" ) {
						$result	.= sprintf $format5, '$+', length $+, 
												marker_string( 0, prepare_stringout($+) );
						$result	.= sprintf $format5, '$^N', length $^N, 
											marker_string( 0, prepare_stringout($^N) );
						}
					#
					# show the control character replacement (if any)
					#
					if ( $string ne $stringout ) {
						$result	.= "\nControl character replacement: \\n -> '$substchar[0]'   \\t -> '$substchar[1]'"
						}

					#
					# do not assign matches containing ticks for coloring
					#
					if ( $` !~ m{'} && $& !~ m{'} && $' !~ m{'} ) {
						VIM::DoCommand("let s:Perl_PerlRegexPrematch  = '".prepare_stringout($`)."' ");
						VIM::DoCommand("let s:Perl_PerlRegexMatch     = '".prepare_stringout($&)."' ");
						}
					else {
						VIM::DoCommand("let s:Perl_PerlRegexPrematch  = '' ");
						VIM::DoCommand("let s:Perl_PerlRegexMatch     = '' ");
						}
					}
			else {
				$result	.= "\n *****  NO MATCH  *****"
				}

				$curbuf->Append( 0, split(/\n/,$result) ); # put the result to the top of the buffer
				}
			else {
				VIM::DoCommand("echomsg 'regexp is not defined or has zero length'");
				}
				return ;
		}	# ----------  end of subroutine regex_evaluate  ----------

		#===  FUNCTION  ================================================================
		#         NAME:  prepare_stringout
		#      PURPOSE:  Sustitute tabs and newlines with printable characters. 
		#   PARAMETERS:  string
		#      RETURNS:  string with replacements
		#===============================================================================
		sub prepare_stringout {
			my	( $par1 )	= @_;
			$par1 =~ s/\n/$substchar[0]/g;
			$par1 =~ s/\t/$substchar[1]/g;
			return $par1;
		}	# ----------  end of subroutine prepare_stringout  ----------

		#===  FUNCTION  ================================================================
		#         NAME:  marker_string
		#      PURPOSE:  Prepend blanks; 
		#                surround string with bars if starting/ending with whitespaces
		#   PARAMETERS:  1. first column of the marker bar (>=0)
		#                2. string
		#      RETURNS:  The augmented string.
		#===============================================================================
		sub marker_string {
			my	( $start, $str )	= @_;
			my	$result	= ' ' x ($start);
			if ( $str =~ m{^\s} || $str =~ m{\s$} ) {
				$result	.= "|".$str."|"
				}
			else {
				$result	.= ' '.$str;
				}
			return $result;
		}	# ----------  end of subroutine marker_string  ----------

		#===  FUNCTION  ================================================================
		#         NAME:  lineruler
		#      PURPOSE:  Generate a line ruler like  "|1... |2... |3......."
		#   PARAMETERS:  1. a (multiline) string 
		#      RETURNS:  ( ruler, number of lines )
		#===============================================================================
		sub lineruler {
			my	( $string )	= @_;
			my	$result			= '';                     # result string (the ruler)
			my	@lines			= split /\n/, $string;    # lines as an array
			my	$lineno			= 0;                      # current line number
			my	$linecount	= 0;                      # number of lines

			while ( $string =~/\n/g ) {
				$linecount++;
				}
			if ( $string !~ /\n$/ ) {                 # last non-empty line
				$linecount++;
				}

			foreach my $line ( @lines ) {
				$lineno++;
				if ( $lineno > 1 ) {
					$result	.= ' ';
				}
				if ( length($line) == 1 ) {
					$result	.= '|';
				}
				if ( length($line) > 1 ) {
					$result	.= '|'.$lineno;
					$result	.= '.' x ((length $line)-(length $lineno)-1);
				}
			}
			return ($result, $linecount);
		}	# ----------  end of subroutine lineruler  ----------
EOF
	"
	if line('$') == 1
		:close
		return
	endif
	normal gg

	"-------------------------------------------------------------------------------
	" Highlight the match by matching  MATCH.POSTMATCH.EOL .
	" Find a character not contained in the string to mark start and end of the
	" Vim regex pattern (range 33 ... 126 or '!' ... '~').
	"-------------------------------------------------------------------------------
	exe ":match none"
	if s:Perl_PerlRegexMatch != ''
		let nr		= char2nr('!')
		let tilde	= char2nr('~')
		let tick1	= char2nr("'")
		let tick2	= char2nr('"')
		let tick3	= char2nr('|')
		while nr <= tilde
			if nr != tick1 && nr != tick2 &&  nr != tick3 &&
						\	match( s:Perl_PerlRegexMatch, nr2char(nr) ) < 0
				break
			endif
			let nr	= nr+1
		endwhile

		if nr <= tilde
			:highlight color_match ctermbg=green guibg=green
			let delim		= nr2char(nr)
			" escape Vim regexp metacharacters
			let match0	= escape( s:Perl_PerlRegexPrematch , '*$~' )
			let match1	= escape( s:Perl_PerlRegexMatch    , '*$~' )
			"
			" the first part of the following regular expression describes the
			" beginnning of $format1 in sub regex_evaluate 
			"
			exe ':match color_match '.delim.'\(^STRING\s\+\[\s*\d\+,\s*\d\+\] =[ |]'.match0.'\)\@<='.match1.delim
		endif
	endif

	if winheight(winnr()) >= line("$")
		exe bufwinnr(l:currentbuffernr) . "wincmd w"
	endif

endfunction    " ----------  end of function Perl_RegexVisualize  ----------
"
"-------------------------------------------------------------------------------
"   initialize the Perl interface
"-------------------------------------------------------------------------------
function! Perl_InitializePerlInterface( )
	if has('perl')
    perl <<EOF
		#
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
			VIM::DoCommand("let s:Perl_PerlRegexAnalyser = 'no'");
			}
		#
EOF

	endif
endfunction    " ----------  end of function Perl_InitializePerlInterface  ----------
"
call Perl_InitializePerlInterface()
"
" vim:set tabstop=2: 
