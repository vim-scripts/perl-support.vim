"=====================================================================================
"
"       Filename:  perl-support.vim
"
"    Description:  Write, compile and run PERL-scripts using menus
"
"          Usage:  Load this script manually with :so[urce] perl-support.vim
"                  or better put this file into your plugin directory  ~/.vim/plugin
"                 
"                  You will find the menu entry "Load Perl Support" in the Tools menu.
"                  After loading the menus this menu entry changes to "Unload Perl Support".
"                  All functions of this script are available from the menus
"                  starting with 'P-' (P-Comments, P-Statements, ... )
"                 
"      Features:   - insert various types of comments
"                  - insert complete but empty statements (e.g. 'if {} else {}' )
"                  - insert often used code snippets (e.g. declarations, 
"                    the opening of files, .. )
"                  - insert the names of file tests, character classes, 
"                    special Perl-variables and POSIX-signals
"                  - read, write, maintain your own code snippets in a separate
"                    directory
"                  - run scripts or run syntax check from within the editor
"                  - show compilation erros in a quickfix window; navigate with hotkeys 
"                  - read perldoc for functions and modules 
"                 
"  Configuration:  There are some personal details which should be configured 
"                  (see section Configuration  below; use my configuration as an example)
"
"           Note:  The register z is used in many places.
"
"         Author:  Dr.-Ing. Fritz Mehner
"        Company:  Fachhochschule Südwestfalen, Iserlohn
"          Email:  mehner@fh-swf.de
"
let s:Perl_Version = "1.6"              " version number of this script; do not change
"
"       Revision:  07.02.2003
"
"        Created:  09.07.2001 - 12:21:33
"
"      Copyright:  Copyright (C) 2001-2003 Dr.-Ing. Fritz Mehner  (mehner@fh-swf.de)
"
"                  This program is free software; you can redistribute it and/or modify
"                  it under the terms of the GNU General Public License as published by
"                  the Free Software Foundation; either version 2 of the License, or
"                  (at your option) any later version.
"
"                  This program is distributed in the hope that it will be useful,
"                  but WITHOUT ANY WARRANTY; without even the implied warranty of
"                  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
"                  GNU General Public License for more details.
"
"                  You should have received a copy of the GNU General Public License
"                  along with this program; if not, write to the Free Software
"                  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
"    
"        Credits:  The errorformat is taken from the script perl.vim created by Lukas Zapletal 
"        
"###############################################################################################
"
"  Configuration  (use my configuration as an example)
"
"-------------------------------------------------------------------------------------------
"
let s:PERL_AuthorName      = "Dr.-Ing. Fritz Mehner"
let s:PERL_AuthorRef       = "Mn"
let s:PERL_Email           = "mehner@fh-swf.de"
let s:PERL_Company         = "FH Südwestfalen, Iserlohn"
"
"  Copyright information
"  ---------------------
"  If the code has been developed over a period of years, each year must be stated.
"  If PERL_CopyrightHolder is empty the copyright notice will not appear.
"  If PERL_CopyrightHolder is not empty and PERL_CopyrightYears is empty, 
"  the current year will be inserted.
"
let s:PERL_CopyrightHolder = ""
let s:PERL_CopyrightYears  = ""
"
let s:Perl_ShowMenues      = "no"      " show menues immediately after loading (yes/no)
"
let  s:Tools_menu_name     = "Tools"   " this variable contains the name of the Tools-menu
                                       " if the original VIM-menus are translated;
                                       " for German menus use "Werkzeuge"
"
" The menu entries for code snippet support will not appear if the following string is empty 
" (Do not forget to create the directory if you want to use code snippets)
"
let s:Perl_CodeSnippets    = $HOME."/.vim/codesnippets-perl"   " PERL code snippets
"                                       
" The menu entrie 'run with pager' will not appear if the following string is empty 
"
let s:Perl_Pager           = "less"          " pager
"
"
"-------------------------------------------------------------------------------------------
"  End of the configuration section
"###############################################################################################
"
"
"------------------------------------------------------------------------------
"  PERL Menu Initialization
"------------------------------------------------------------------------------
function!	Perl_InitMenu ()
"
"---------- Key Mappings -------------------------------------------------------------------------
"  This is for convenience only. Comment out the following maps if you dislike them.
"  If enabled, there may be conflicts with predefined key bindings of your window manager.
"-------------------------------------------------------------------------------------------------
"
"        F2   update/save file without confirmation
"        F3   file open dialog
"        F6   open the error window
"        F7   go to the previous error
"        F8   go to the next error   
"   Ctrl-F9   run script
"        F9   run script with pager
"    Alt-F9   run syntax check
"
"   run the script from the local directory 
"   ( the one which is being edited; other versions may exist elsewhere ! )
"   
	nmap     <F1>		<F1>
	vmap     <F1>  "zy<Esc>:call Perl_perldoc_visual(1)<CR><CR>
	vmap   <S-F1>  "zy<Esc>:call Perl_perldoc_visual(0)<CR><CR>

	map     <F2>  :update<CR>
	map     <F3>  :browse confirm e<CR>
	map     <F6>  :cwindow<CR>
	map     <F7>  :cp<CR>
	map     <F8>  :cn<CR>
	map   <A-F9>  :call Perl_SyntaxCheck()<CR><CR>
	map   <C-F9>  :call Perl_Run(0)<CR>
"
	imap    <F2>  <Esc>:update<CR>
	imap    <F3>  <Esc>:browse confirm e<CR>
	imap    <F6>  <Esc>:cwindow<CR>
	imap    <F7>  <Esc>:cp<CR>
	imap    <F8>  <Esc>:cn<CR>
	imap  <A-F9>  <Esc>:call Perl_SyntaxCheck()<CR><CR>
	imap  <C-F9>  <Esc>:call Perl_Run(0)<CR>
	
	if s:Perl_Pager != ""
		noremap    <F9>  :call Perl_Run(1)<CR>
		inoremap   <F9>  <Esc>:call Perl_Run(1)<CR>
	endif
"
"
"----- only used for the developement of this script -------------------------------------------------------------------
"
   noremap   <F12>       :write<CR><Esc>:so %<CR><Esc>:call Perl_Handle()<CR><Esc>:call Perl_Handle()<CR><Esc>:call Perl_Handle()<CR>
  inoremap   <F12>  <Esc>:write<CR><Esc>:so %<CR><Esc>:call Perl_Handle()<CR><Esc>:call Perl_Handle()<CR><Esc>:call Perl_Handle()<CR>
"
"
"---------- P-Comments-Menu ----------------------------------------------------------------------
"
amenu  P-&Comments.&Line\ End\ Comment          <Esc><Esc>A<Tab><Tab><Tab># 
amenu  P-&Comments.&Frame\ Comment              <Esc><Esc>:call Perl_CommentFrame()    <CR>jA
amenu  P-&Comments.&Function\ Description       <Esc><Esc>:call Perl_CommentFunction() <CR>:/NAME<CR>A
amenu  P-&Comments.File\ &Prologue              <Esc><Esc>:call Perl_FilePrologue()    <CR>:/DESCRIPTION<CR>A
amenu  P-&Comments.-SEP1-                       :
	"
	"---------- submenu : KEYWORD -------------------------------------------------------------
	"
	amenu  P-&Comments.#:&KEYWORD\:.&BUG          <Esc><Esc>$<Esc>:call Perl_CommentClassified("BUG")     <CR>kJA
	amenu  P-&Comments.#:&KEYWORD\:.&TODO         <Esc><Esc>$<Esc>:call Perl_CommentClassified("TODO")    <CR>kJA
	amenu  P-&Comments.#:&KEYWORD\:.T&RICKY       <Esc><Esc>$<Esc>:call Perl_CommentClassified("TRICKY")  <CR>kJA
	amenu  P-&Comments.#:&KEYWORD\:.&WARNING      <Esc><Esc>$<Esc>:call Perl_CommentClassified("WARNING") <CR>kJA
	amenu  P-&Comments.#:&KEYWORD\:.&new\ keyword <Esc><Esc>$<Esc>:call Perl_CommentClassified("")        <CR>kJf:a
	"
vmenu  P-&Comments.&code->comment               <Esc><Esc>:'<,'>s/^/#/<CR><Esc>:nohlsearch<CR>
vmenu  P-&Comments.c&omment->code               <Esc><Esc>:'<,'>s/^#//<CR><Esc>:nohlsearch<CR>
amenu  P-&Comments.-SEP2-                       :
amenu  P-&Comments.&Date                        <Esc><Esc>:let @z=strftime("%x")     <CR>"zpa
amenu  P-&Comments.Date\ &Time                  <Esc><Esc>:let @z=strftime("%x - %X")<CR>"zpa
"
"---------- P-Statements-Menu ----------------------------------------------------------------------
"
imenu P-St&atements.&if\ \{\ \}		                   <Esc>:let @z="if (  )\n{\n\t\n}\n"                     <CR>"z]p<Esc>f(la
imenu P-St&atements.if\ \{\ \}\ &else\ \{\ \}        <Esc>:let @z="if (  )\n{\n\t\n}\nelse\n{\n\t\n}\n"     <CR>"z]p<Esc>f(la
imenu P-St&atements.&unless\ \{\ \}                  <Esc>:let @z="unless (  )\n{\n\t\n}\n"                 <CR>"z]p<Esc>f(la
imenu P-St&atements.un&less\ \{\ \}\ else\ \{\ \}    <Esc>:let @z="unless (  )\n{\n\t\n}\nelse\n{\n\t\n}\n" <CR>"z]p<Esc>f(la
imenu P-St&atements.&while\ \{\ \}                   <Esc>:let @z="while (  )\n{\n\t\n}\t\t\t\t# -----  end while  -----\n"<CR>"z]p<Esc>f(la
imenu P-St&atements.&do\ \{\ \}\ while               <Esc>:call Perl_DoWhile()           <CR>"z]p<Esc>:/while <CR>f(la
imenu P-St&atements.un&til\ \{\ \}                   <Esc>:let @z="until (  )\n{\n\t\n}\n"                  <CR>"z]p<Esc>f(la
imenu P-St&atements.f&or\ \{\ \}                     <Esc>:let @z="for ( ; ;  )\n{\n\t\n}\n"                <CR>"z]p<Esc>f;i
imenu P-St&atements.fo&reach\ \{\ \}                 <Esc>:let @z="foreach  (  )\n{\n\t\n}\t\t\t\t# -----  end foreach  -----\n"<CR>"z]p<Esc>f(hi
"
"---------- submenu : idioms -------------------------------------------------------------
"
imenu P-I&dioms.&my\ $;                        my<Tab>$;<Esc>i
imenu P-I&dioms.m&y\ $\ =\ ;                   my<Tab>$ = ;<Esc>F$a
imenu P-I&dioms.my\ (\ $&,\ $\ );              my<Tab>( $, $ );<Esc>2F$a
imenu P-I&dioms.-SEP1-                         :
imenu P-I&dioms.(&1)\ \ \ my\ @;               my<Tab>@;<Esc>i
imenu P-I&dioms.(&2)\ \ \ my\ @\ =\ (,,);      my<Tab>@ = ( , ,  );<Esc>F@a
imenu P-I&dioms.-SEP2-                         :
imenu P-I&dioms.(&3)\ \ \ my\ %;               my<Tab>%;<Esc>i
imenu P-I&dioms.(&4)\ \ \ my\ %\ =\ (=>,=>,);  <Esc>:let @z="my\t% = \n(\n\t => ,\n\t => ,\n);"<CR>"z]p<Esc>f%a
imenu P-I&dioms.-SEP3-                         :
imenu P-I&dioms.(&5)\ \ \ $\ =~\ m//           $ =~ m//<Esc>F$a
imenu P-I&dioms.(&6)\ \ \ $\ =~\ s///          $ =~ s///<Esc>F$a
imenu P-I&dioms.(&7)\ \ \ $\ =~\ tr///         $ =~ tr///<Esc>F$a
imenu P-I&dioms.-SEP4-                         :
imenu P-I&dioms.&print\ \"\.\.\.\\n\";         print "\n";<ESC>3hi
imenu P-I&dioms.print&f\ (\"\.\.\.\\n\");     printf ("\n");<ESC>4hi
""imenu P-I&dioms.&warn\ \"\.\.\.\\n\";          warn "\n";<ESC>3hi
imenu P-I&dioms.&subroutine                    <Esc>:call Perl_CodeFunction()<CR>3jA
imenu P-I&dioms.open\ &input\ file             <Esc>:call Perl_CodeOpenRead()<CR>f'a
imenu P-I&dioms.open\ &output\ file            <Esc>:call Perl_CodeOpenWrite()<CR>f'a
imenu P-I&dioms.open\ pip&e                    <Esc>:call Perl_CodeOpenPipe()<CR>f'a
imenu P-I&dioms.-SEP5-                         :
imenu P-I&dioms.<STDIN>                        <STDIN>
imenu P-I&dioms.<STDOUT>                       <STDOUT>
imenu P-I&dioms.<STDERR>                       <STDERR>
	if s:Perl_CodeSnippets != ""
		imenu P-I&dioms.-SEP6-                         :
		amenu  P-&Idioms.read\ code\ snippet        <C-C>:call Perl_CodeSnippet("r")<CR>
		amenu  P-&Idioms.write\ code\ snippet       <C-C>:call Perl_CodeSnippet("w")<CR>
		vmenu  P-&Idioms.write\ code\ snippet       <C-C>:call Perl_CodeSnippet("wv")<CR>
		amenu  P-&Idioms.edit\ code\ snippet        <C-C>:call Perl_CodeSnippet("e")<CR>
	endif
imenu P-I&dioms.-SEP7-                         :
"
"---------- submenu : POSIX character classes --------------------------------------------
"
imenu P-CharC&ls.[:&alnum:]										[:alnum:]
imenu P-CharC&ls.[:alp&ha:]										[:alpha:]
imenu P-CharC&ls.[:asc&ii:]										[:ascii:]
imenu P-CharC&ls.[:&cntrl:]										[:cntrl:]
imenu P-CharC&ls.[:&digit:]										[:digit:]
imenu P-CharC&ls.[:&graph:]										[:graph:]
imenu P-CharC&ls.[:&lower:]										[:lower:]
imenu P-CharC&ls.[:&print:]										[:print:]
imenu P-CharC&ls.[:pu&nct:]										[:punct:]
imenu P-CharC&ls.[:&space:]										[:space:]
imenu P-CharC&ls.[:&upper:]										[:upper:]
imenu P-CharC&ls.[:&word:]										[:word:]
imenu P-CharC&ls.[:&xdigit:]									[:xdigit:]
"
"---------- P-File-Tests-Menu ----------------------------------------------------------------------
"
imenu P-F&ile-Tests.exists															-e <Esc>a
imenu P-F&ile-Tests.has\ zero\ size											-z <Esc>a
imenu P-F&ile-Tests.has\ nonzero\ size									-s <Esc>a
imenu P-F&ile-Tests.plain\ file													-f <Esc>a
imenu P-F&ile-Tests.directory														-d <Esc>a
imenu P-F&ile-Tests.symbolic\ link											-l <Esc>a
imenu P-F&ile-Tests.named\ pipe													-p <Esc>a
imenu P-F&ile-Tests.socket															-S <Esc>a
imenu P-F&ile-Tests.block\ special\ file								-b <Esc>a
imenu P-F&ile-Tests.character\ special\ file						-c <Esc>a
imenu P-F&ile-Tests.-SEP1-															:
imenu P-F&ile-Tests.readable\ by\ effective\ UID/GID		-r <Esc>a
imenu P-F&ile-Tests.writable\ by\ effective\ UID/GID		-w <Esc>a
imenu P-F&ile-Tests.executable\ by\ effective\ UID/GID	-x <Esc>a
imenu P-F&ile-Tests.owned\ by\ effective\ UID						-o <Esc>a
imenu P-F&ile-Tests.-SEP2-																:
imenu P-F&ile-Tests.readable\ by\ real\ UID/GID					-R <Esc>a
imenu P-F&ile-Tests.writable\ by\ real\ UID/GID					-W <Esc>a
imenu P-F&ile-Tests.executable\ by\ real\ UID/GID				-X <Esc>a
imenu P-F&ile-Tests.owned\ by\ real\ UID								-O <Esc>a
imenu P-F&ile-Tests.-SEP3-															:
imenu P-F&ile-Tests.setuid\ bit\ set										-u <Esc>a
imenu P-F&ile-Tests.setgid\ bit\ set										-g <Esc>a
imenu P-F&ile-Tests.sticky\ bit\ set										-k <Esc>a
imenu P-F&ile-Tests.-SEP4-															:
imenu P-F&ile-Tests.age\ since\ modification						-M <Esc>a
imenu P-F&ile-Tests.age\ since\ last\ access						-A <Esc>a
imenu P-F&ile-Tests.age\ since\ inode\ change						-C <Esc>a
imenu P-F&ile-Tests.-SEP5-															:
imenu P-F&ile-Tests.text\ file													-T <Esc>a
imenu P-F&ile-Tests.binary\ file												-B <Esc>a
imenu P-F&ile-Tests.handle\ opened\ to\ a\ tty					-t <Esc>a
"
"---------- P-Special-Variables -------------------------------------------------------------
"
	"-------- submenu errors -------------------------------------------------
	imenu P-Spec-&Var.&errors.$CHILD_ERROR      					$CHILD_ERROR
	imenu P-Spec-&Var.&errors.$ERRNO            					$ERRNO
	imenu P-Spec-&Var.&errors.$EVAL_ERROR       					$EVAL_ERROR
	imenu P-Spec-&Var.&errors.$EXTENDED_OS_ERROR					$EXTENDED_OS_ERROR
	imenu P-Spec-&Var.&errors.$OS_ERRNO         					$OS_ERRNO
	imenu P-Spec-&Var.&errors.$WARNING          					$WARNING

	"-------- submenu files -------------------------------------------------
	imenu P-Spec-&Var.&files.$AUTOFLUSH            				$AUTOFLUSH
	imenu P-Spec-&Var.&files.$OUTPUT_AUTOFLUSH     				$OUTPUT_AUTOFLUSH
	imenu P-Spec-&Var.&files.$FORMAT_LINES_LEFT    				$FORMAT_LINES_LEFT
	imenu P-Spec-&Var.&files.$FORMAT_LINES_PER_PAGE				$FORMAT_LINES_PER_PAGE
	imenu P-Spec-&Var.&files.$FORMAT_NAME          				$FORMAT_NAME
	imenu P-Spec-&Var.&files.$FORMAT_PAGE_NUMBER   				$FORMAT_PAGE_NUMBER
	imenu P-Spec-&Var.&files.$FORMAT_TOP_NAME      				$FORMAT_TOP_NAME

	"-------- submenu IDs -------------------------------------------------
	imenu P-Spec-&Var.&IDs.$PID               						$PID
	imenu P-Spec-&Var.&IDs.$PROCESS_ID        						$PROCESS_ID
	imenu P-Spec-&Var.&IDs.$GID               						$GID
	imenu P-Spec-&Var.&IDs.$REAL_GROUP_ID     						$REAL_GROUP_ID
	imenu P-Spec-&Var.&IDs.$EGID              						$EGID
	imenu P-Spec-&Var.&IDs.$EFFECTIVE_GROUP_ID						$EFFECTIVE_GROUP_ID

	"-------- submenu IO -------------------------------------------------
	imenu P-Spec-&Var.I&O.$INPUT_LINE_NUMBER      				$INPUT_LINE_NUMBER
	imenu P-Spec-&Var.I&O.$NR                     				$NR
	imenu P-Spec-&Var.I&O.-SEP1-      		            :
	imenu P-Spec-&Var.I&O.$INPUT_RECORD_SEPARATOR 				$INPUT_RECORD_SEPARATOR
	imenu P-Spec-&Var.I&O.$RS                     				$RS
	imenu P-Spec-&Var.I&O.$LIST_SEPARATOR         				$LIST_SEPARATOR
	imenu P-Spec-&Var.I&O.$OUTPUT_FIELD_SEPARATOR 				$OUTPUT_FIELD_SEPARATOR
	imenu P-Spec-&Var.I&O.$OFS                    				$OFS
	imenu P-Spec-&Var.I&O.$OUTPUT_RECORD_SEPARATOR				$OUTPUT_RECORD_SEPARATOR
	imenu P-Spec-&Var.I&O.$ORS                    				$ORS
	imenu P-Spec-&Var.I&O.$SUBSCRIPT_SEPARATOR    				$SUBSCRIPT_SEPARATOR
	imenu P-Spec-&Var.I&O.$SUBSEP                 				$SUBSEP

	"-------- submenu regexp -------------------------------------------------
	imenu P-Spec-&Var.&regexp.$digits                 		$digits
	imenu P-Spec-&Var.&regexp.@LAST_MATCH_END         		@LAST_MATCH_END
	imenu P-Spec-&Var.&regexp.@LAST_MATCH_START       		@LAST_MATCH_START
	imenu P-Spec-&Var.&regexp.$LAST_PAREN_MATCH       		$LAST_PAREN_MATCH
	imenu P-Spec-&Var.&regexp.$LAST_REGEXP_CODE_RESULT		$LAST_REGEXP_CODE_RESULT
	imenu P-Spec-&Var.&regexp.$MATCH                  		$MATCH
	imenu P-Spec-&Var.&regexp.$POSTMATCH              		$POSTMATCH
	imenu P-Spec-&Var.&regexp.$PREMATCH               		$PREMATCH

imenu P-Spec-&Var.$BASETIME      					$BASETIME
imenu P-Spec-&Var.$PERL_VERSION  					$PERL_VERSION
imenu P-Spec-&Var.$PROGRAM_NAME  					$PROGRAM_NAME
imenu P-Spec-&Var.$OSNAME       					$OSNAME
imenu P-Spec-&Var.$SYSTEM_FD_MAX 					$SYSTEM_FD_MAX
imenu P-Spec-&Var.$ENV{\ }			 					$ENV{}<ESC>i
imenu P-Spec-&Var.$INC{\ }			 					$INC{}<ESC>i
imenu P-Spec-&Var.$SIG{\ }			 					$SIG{}<ESC>i
	"
	"---------- submenu : POSIX signals --------------------------------------
	"
	imenu P-Spec-&Var.POSIX\ signals.HUP 		HUP
	imenu P-Spec-&Var.POSIX\ signals.INT 		INT
	imenu P-Spec-&Var.POSIX\ signals.QUIT		QUIT
	imenu P-Spec-&Var.POSIX\ signals.ILL 		ILL
	imenu P-Spec-&Var.POSIX\ signals.ABRT		ABRT
	imenu P-Spec-&Var.POSIX\ signals.FPE 		FPE
	imenu P-Spec-&Var.POSIX\ signals.KILL		KILL
	imenu P-Spec-&Var.POSIX\ signals.SEGV		SEGV
	imenu P-Spec-&Var.POSIX\ signals.PIPE		PIPE
	imenu P-Spec-&Var.POSIX\ signals.ALRM		ALRM
	imenu P-Spec-&Var.POSIX\ signals.TERM		TERM
	imenu P-Spec-&Var.POSIX\ signals.USR1		USR1
	imenu P-Spec-&Var.POSIX\ signals.USR2		USR2
	imenu P-Spec-&Var.POSIX\ signals.CHLD		CHLD
	imenu P-Spec-&Var.POSIX\ signals.CONT		CONT
	imenu P-Spec-&Var.POSIX\ signals.STOP		STOP
	imenu P-Spec-&Var.POSIX\ signals.TSTP		TSTP
	imenu P-Spec-&Var.POSIX\ signals.TTIN		TTIN
	imenu P-Spec-&Var.POSIX\ signals.TTOU		TTOU
	"
imenu P-Spec-&Var.-SEP2-      		              	      :
imenu P-Spec-&Var.\'IGNORE\' 														'IGNORE'
imenu P-Spec-&Var.\'DEFAULT\' 													'DEFAULT'
imenu P-Spec-&Var.-SEP3-      		              	      :
imenu P-Spec-&Var.use\ English; 												<ESC><ESC>^ouse English;

"
"---------- P-Run-Menu ----------------------------------------------------------------------
"
"   run the script from the local directory 
"   ( the one which is being edited; other versions may exist elsewhere ! )
" 
amenu P-&Run.update\ file,\ &run\ script\ \ <Ctrl><F9>   <C-C>:call Perl_Run(0)<CR>
"
if s:Perl_Pager != ""
	amenu P-&Run.update\ file,\ run\ with\ &pager\ \ <F9>    <C-C>:call Perl_Run(1)<CR>
endif
"
"   run the script from the local directory / only syntax check
"   ( the one which is being edited; other versions may exist elsewhere ! )
" 
amenu P-&Run.update\ file,\ run\ &syntax\ check\ \ <Alt><F9>   <C-C>:call Perl_SyntaxCheck()<CR><CR>
"
"   set execution right only for the user ( may be user root ! )
"
amenu P-&Run.make\ script\ e&xecutable            <C-C>:!chmod u+x %<CR>
amenu P-&Run.&command\ line\ arguments            <C-C>:call Perl_Arguments()<CR>
amenu P-&Run.-SEP2-      		              	      :
amenu P-&Run.perldoc\ &module                     <C-C>:call Perl_perldoc_normal(0)<CR><CR>
vmenu P-&Run.perldoc\ &module                     "zy<Esc>:call Perl_perldoc_visual(0)<CR><CR>
amenu P-&Run.perldoc\ -f\ &function               <C-C>:call Perl_perldoc_normal(1)<CR><CR>
vmenu P-&Run.perldoc\ -f\ &function               "zy<Esc>:call Perl_perldoc_visual(1)<CR><CR>
amenu P-&Run.-SEP3-      		              	      :
amenu P-&Run.hardcop&y\ all\ to\ FILENAME\.ps     <C-C>:call Perl_Hardcopy("n")<CR>
vmenu P-&Run.hardcop&y\ part\ to\ FILENAME\.ps    <C-C>:call Perl_Hardcopy("v")<CR>
imenu P-&Run.-SEP4-                               :
amenu P-&Run.additional\ &hot\ keys               <C-C>:call Perl_HotKeys()<CR>
amenu P-&Run.&about\ Perl-Support                 <C-C>:call Perl_Version()<CR>
"
endfunction			" function Perl_InitMenu
"
"
"------------------------------------------------------------------------------
"----- variables for internal use ----------------------------------------
"------------------------------------------------------------------------------
"
let s:Perl_CmdLineArgs  = ""           " command line arguments for Run-run; initially empty
"
"
"------------------------------------------------------------------------------
"  PERL File Prologue
"------------------------------------------------------------------------------
function! Perl_FilePrologue ()

		let	File	= expand("%:t")				" name of the file in the current buffer without path
    let @z=    "#!/usr/bin/perl -w\n"
    let @z= @z."#===================================================================================\n"
    let @z= @z."#\n"
    let @z= @z."#         FILE:  ".File."\n"
    let @z= @z."#\n"
    let @z= @z."#        USAGE:  ./".File." \n"
    let @z= @z."#\n"
    let @z= @z."#  DESCRIPTION:  \n"
    let @z= @z."#\n"
    let @z= @z."#        FILES:  ---\n"
    let @z= @z."#        NOTES:  ---\n"
    let @z= @z."#       AUTHOR:  ".s:PERL_AuthorName."  (".s:PERL_AuthorRef.")\n"
  if(s:PERL_Email!="")
    let @z= @z."#        EMAIL:  ".s:PERL_Email."\n"
	endif
  if(s:PERL_Company!="")
    let @z= @z."#      COMPANY:  ".s:PERL_Company."\n"
	endif
  if(s:PERL_CopyrightHolder!="")
    let @z= @z.  "\n//#  COPYRIGHT:  ".s:PERL_CopyrightHolder
    if(s:PERL_CopyrightYears=="")
      let @z= @z. " , ". strftime("%Y")
    else
      let @z= @z. " , ". s:PERL_CopyrightYears
    endif
  endif
    let @z= @z."#      VERSION:  1.0\n"
    let @z= @z."#      CREATED:  ".strftime("%x - %X")."\n"
    let @z= @z."#     REVISION:  ---\n"
    let @z= @z."#===================================================================================\n"
    let @z= @z."\nuse strict;"
    let @z= @z."\n\n"
    
    put! z
endfunction
"
"------------------------------------------------------------------------------
"  P-Comments : Frame
"------------------------------------------------------------------------------
function! Perl_CommentFrame ()
  let @z=   "#----------------------------------------------------------------------\n"
  let @z=@z."#  \n"
  let @z=@z."#----------------------------------------------------------------------\n"
  put z
endfunction
"
"------------------------------------------------------------------------------
"  P-Comments : Function 
"------------------------------------------------------------------------------
function! Perl_CommentFunction ()
  let @z=    "#===  FUNCTION  ====================================================================\n"
  let @z= @z."#\n"
  let @z= @z."#         NAME:  \n"
  let @z= @z."#\n"
  let @z= @z."#  DESCRIPTION:  \n"
  let @z= @z."#\n"
  let @z= @z."#       AUTHOR:  ".s:PERL_AuthorName."\n"
  let @z= @z."#      CREATED:  ".strftime("%x - %X")."\n"
  let @z= @z."#\n"
  let @z= @z."#---- PARAMETER  -------------------------------------------------------------------\n"
  let @z= @z."#        Number  Description\n"
  let @z= @z."#           1 :  \n"
  let @z= @z."#===================================================================================\n"
  put z
endfunction
"
"------------------------------------------------------------------------------
"  P-Comments : classified comments
"------------------------------------------------------------------------------
function! Perl_CommentClassified (class)
  	put = '# :'.a:class.':'.strftime(\"%x\").':'.s:PERL_AuthorRef.': '
endfunction
"
"------------------------------------------------------------------------------
"  P-Statements : subroutine
"------------------------------------------------------------------------------
function! Perl_CodeFunction ()
	let	identifier=inputdialog("subroutine name", "f" )
	if identifier==""
		let	identifier	= "f"
	endif
  let @z=    "sub ".identifier."\n{\n\tmy\t$par1\t= shift;\n\t\n\treturn ;\n}"
  let @z= @z."\t# ----------  end of subroutine ".identifier."  ----------" 
	  put z
endfunction
"
"------------------------------------------------------------------------------
"  Statements : do-while
"------------------------------------------------------------------------------
"
function! Perl_DoWhile ()
	let @z=    "do\n{\n\t\n}\nwhile (  );"
  let @z= @z."\t\t\t\t# -----  end do-while  -----\n"
endfunction
"
"------------------------------------------------------------------------------
"  PERL-Idioms : CodeOpenRead
"------------------------------------------------------------------------------
function! Perl_CodeOpenRead ()

	let	filehandle=inputdialog("input file handle", "INFILE")
	if filehandle==""
		let	filehandle	= "INFILE"
	endif
	
	let filename=filehandle."_file_name"

	let @z=    "my\t$".filename." = \'\';\t\t# input file name\n\n"
	let @z= @z."open ( ".filehandle.", \'<\', $".filename." )\n"
	let @z= @z."\tor die \"$0 : failed to open input file $".filename." : $!\\n\";\n\n\n"
	let @z= @z."close ( ".filehandle." );\t\t\t# close input file\n"
	exe ":imenu P-I&dioms.<".filehandle.">      <".filehandle."><ESC>a"
	put z
endfunction
"
"------------------------------------------------------------------------------
"  PERL-Idioms : CodeOpenWrite
"------------------------------------------------------------------------------
function! Perl_CodeOpenWrite ()

	let	filehandle=inputdialog("output file handle", "OUTFILE")
	if filehandle==""
		let	filehandle	= "OUTFILE"
	endif
	
	let filename=filehandle."_file_name"

	let @z=    "my\t$".filename." = \'\';\t\t# output file name\n\n"
	let @z= @z."open ( ".filehandle.", \'>\', $".filename." )\n"
	let @z= @z."\tor die \"$0 : failed to open output file $".filename." : $!\\n\";\n\n\n"
	let @z= @z."close ( ".filehandle." );\t\t\t# close output file\n"
	put z
	exe ":imenu P-I&dioms.print\\ ".filehandle."\\ \"\\\\n\";       print ".filehandle." \"\\n\";<ESC>3hi"
endfunction
"
"------------------------------------------------------------------------------
"  PERL-Idioms : CodeOpenPipe
"------------------------------------------------------------------------------
function! Perl_CodeOpenPipe ()

	let	filehandle=inputdialog("pipe handle", "PIPE")
	if filehandle==""
		let	filehandle	= "PIPE"
	endif
	
	let pipecommand=filehandle."_command"

	let @z=    "my\t$".pipecommand." = \'\';\t\t# pipe command\n\n"
	let @z= @z."open ( ".filehandle.", $".pipecommand." )\n"
	let @z= @z."\tor die \"$0 : failed to open pipe > $".pipecommand." < : $!\\n\";\n\n\n"
	let @z= @z."close ( ".filehandle." );\t\t\t# close pipe\n"
	put z
endfunction
"
"------------------------------------------------------------------------------
"  Perl-Idioms : read / edit code snippet
"------------------------------------------------------------------------------
function! Perl_CodeSnippet(arg1)
	if isdirectory(s:Perl_CodeSnippets)
		"
		" read snippet file, put content below current line
		" 
		if a:arg1 == "r"
			let	l:snippetfile=browse(0,"read a code snippet",s:Perl_CodeSnippets,"")
			if l:snippetfile != ""
				:execute "read ".l:snippetfile
			endif
		endif
		"
		" update current buffer / split window / edit snippet file
		" 
		if a:arg1 == "e"
			let	l:snippetfile=browse(0,"edit a code snippet",s:Perl_CodeSnippets,"")
			if l:snippetfile != ""
				:execute "update! | split | edit ".l:snippetfile
			endif
		endif
		"
		" write whole buffer into snippet file 
		" 
		if a:arg1 == "w"
			let	l:snippetfile=browse(0,"write a code snippet",s:Perl_CodeSnippets,"")
			if l:snippetfile != ""
				:execute ":write! ".l:snippetfile
			endif
		endif
		"
		" write marked area into snippet file 
		" 
		if a:arg1 == "wv"
			let	l:snippetfile=browse(0,"write a code snippet",s:Perl_CodeSnippets,"")
			if l:snippetfile != ""
				:execute ":*write! ".l:snippetfile
			endif
		endif

	else
		echohl ErrorMsg
		echo "code snippet directory ".s:Perl_CodeSnippets." does not exist"
		echohl None
	endif
endfunction
"------------------------------------------------------------------------------
"  PERL-Run : Perl_perldoc - normal mode
"------------------------------------------------------------------------------
function! Perl_perldoc_normal (arg1)
	let	l:name=inputdialog("perldoc function : ", "")
	"------------------------------------------------------------------------------
	"  replace buffer content with Perl documentation
	"------------------------------------------------------------------------------
	if a:arg1==0
		exe ":new | %!perldoc    ".l:name
	else
		exe ":new | %!perldoc -f ".l:name
	endif
	set buftype=nofile
	set noswapfile
endfunction
"
"------------------------------------------------------------------------------
"  PERL-Run : Perl_perldoc - visual mode
"------------------------------------------------------------------------------
function! Perl_perldoc_visual (arg1)
	"------------------------------------------------------------------------------
	"  replace buffer content with Perl documentation
	"------------------------------------------------------------------------------
	if a:arg1==0
		exe ":new | %!perldoc    ".@z
	else
		exe ":new | %!perldoc -f ".@z
	endif
	set buftype=nofile
	set noswapfile
endfunction
"
"------------------------------------------------------------------------------
"  run : hot keys
"------------------------------------------------------------------------------
function! Perl_HotKeys ()
	let hotkeylist =            "Additional hot keys\n"
	let hotkeylist = hotkeylist."______________________________________________________\n\n"
	let hotkeylist = hotkeylist."      F1  :  read perldoc for marked function name (Visual Mode)\n"
	let hotkeylist = hotkeylist."Shift-F1  :  read perldoc for marked module name (Visual Mode)\n"
	let hotkeylist = hotkeylist."      F2  :  update (save) file   \n"
	let hotkeylist = hotkeylist."      F3  :  file open dialog     \n"
	let hotkeylist = hotkeylist."      F6  :  open error window    \n"
	let hotkeylist = hotkeylist."      F7  :  go to previous error \n"
	let hotkeylist = hotkeylist."      F8  :  go to next error     \n"
	let dummy=confirm( hotkeylist, "ok", 1, "Info" )
endfunction
"
"------------------------------------------------------------------------------
"  run : about
"------------------------------------------------------------------------------
function! Perl_Version ()
	let	message	=         "perl-support.vim, Vers. ".s:Perl_Version."\n"
	let	message	= message."Dr.-Ing. Fritz Mehner\n"
	let	message	= message."mehner@fh-swf.de\n"
	let dummy=confirm( message, "ok", 1, "Info" )
endfunction
"
"------------------------------------------------------------------------------
"  run : compile
"------------------------------------------------------------------------------
function! Perl_SyntaxCheck ()
	let	l:currentbuffer=bufname("%")
	exe	":update"
	exe	"set makeprg=perl"
	" 
	" match the PERL error messages (quickfix commands)
	" errorformat will be reset by function Perl_Handle()
	" 
	" ignore any lines that didn't match one of the patterns
	" 
	exe	':setlocal errorformat=%m\ at\ %f\ line\ %l%.%#,%-G%.%#'
	exe	"make -wc %"
	exe	":cwin"
	exe	':setlocal errorformat='
	exe	"set makeprg=make"
	"
	" message in case of success
	"
	if l:currentbuffer ==  bufname("%")
		redraw
		echohl Search
		echo l:currentbuffer." : Syntax is OK"
		echohl None
		nohlsearch						" delete unwanted highlighting (Vim bug?)
	endif
endfunction
"
"------------------------------------------------------------------------------
"  run : run
"------------------------------------------------------------------------------
function! Perl_Run (arg1)
	let	l:currentbuffer=bufname("%")
	call Perl_SyntaxCheck()
	if l:currentbuffer ==  bufname("%")
		if a:arg1==0
			exe		"update | !./% ".s:Perl_CmdLineArgs
		else
			exe		"update | !./% ".s:Perl_CmdLineArgs." | ".s:Perl_Pager
		endif
	endif
endfunction
"
"------------------------------------------------------------------------------
"  run : Arguments
"------------------------------------------------------------------------------
function! Perl_Arguments ()
	let	s:Perl_CmdLineArgs= inputdialog("command line arguments",s:Perl_CmdLineArgs)
endfunction
"
"------------------------------------------------------------------------------
"  run : hardcopy
"------------------------------------------------------------------------------
function! Perl_Hardcopy (arg1)
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
"	 Create the load/unload entry in the GVIM tool menu, depending on 
"	 which script is already loaded
"------------------------------------------------------------------------------
"
let s:Perl_Active = -1														" state variable controlling the Perl-menus
"
function! Perl_CreateUnLoadMenuEntries ()
	"
	" C is now active and was former inactive -> 
	" Insert Tools.Unload and remove Tools.Load Menu
	" protect the following submenu names against interpolation by using single qoutes (Mn)
	"
	if  s:Perl_Active == 1
		exe "aunmenu ".s:Tools_menu_name.'.Load\ Perl\ Support'
		exe "amenu   &".s:Tools_menu_name.'.Unload\ Perl\ Support  	<C-C>:call Perl_Handle()<CR>'
	else
		" Perl is now inactive and was former active or in initial state -1 
		if s:Perl_Active == 0
			" Remove Tools.Unload if Perl was former inactive
			exe "aunmenu ".s:Tools_menu_name.'.Unload\ Perl\ Support'
		else
			" Set initial state Perl_Active=-1 to inactive state Perl_Active=0
			" This protects from removing Tools.Unload during initialization after
			" loading this script
			let s:Perl_Active = 0
			" Insert Tools.Load
		endif
		exe "amenu &".s:Tools_menu_name.'.Load\ Perl\ Support <C-C>:call Perl_Handle()<CR>'
	endif
	"
endfunction
"
"------------------------------------------------------------------------------
"  Loads or unloads Perl extensions menus
"------------------------------------------------------------------------------
function! Perl_Handle ()
	if s:Perl_Active == 0
		:call Perl_InitMenu()
		let s:Perl_Active = 1
	else
		aunmenu P-Comments
		aunmenu P-Statements
		aunmenu P-Idioms
		aunmenu P-CharCls
		aunmenu P-File-Tests
		aunmenu P-Spec-Var
		aunmenu P-Run
		let s:Perl_Active = 0
	endif
	
	call Perl_CreateUnLoadMenuEntries ()
endfunction
"
"------------------------------------------------------------------------------
" 
call Perl_CreateUnLoadMenuEntries()			" create the menu entry in the GVIM tool menu
if s:Perl_ShowMenues == "yes"
	call Perl_Handle()											" load the menus
endif
"
