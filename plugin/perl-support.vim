"=====================================================================================
"
"       Filename:  perl-support.vim
"
"    Description:  Write, compile and run Perl-scripts using menus
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
"         Author:  Dr.-Ing. Fritz Mehner
"        Company:  Fachhochschule Südwestfalen, Iserlohn
"          Email:  mehner@fh-swf.de
"
let s:Perl_Version = "1.7"              " version number of this script; do not change
"
"       Revision:  25.04.2003
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
let s:Perl_AuthorName      = "Dr.-Ing. Fritz Mehner"
let s:Perl_AuthorRef       = "Mn"
let s:Perl_Email           = "mehner@fh-swf.de"
let s:Perl_Company         = "FH Südwestfalen, Iserlohn"
"
"  Copyright information
"  ---------------------
"  If the code has been developed over a period of years, each year must be stated.
"  If Perl_CopyrightHolder is empty the copyright notice will not appear.
"  If Perl_CopyrightHolder is not empty and Perl_CopyrightYears is empty, 
"  the current year will be inserted.
"
let s:Perl_CopyrightHolder = ""
let s:Perl_CopyrightYears  = ""
"
let s:Perl_ShowMenues      = "no"      " show menues immediately after loading this plugin (yes/no)
"
"
" The menu entries for code snippet support will not appear if the following string is empty 
" (Do not forget to create the directory if you want to use code snippets)
"
let s:Perl_CodeSnippets    = $HOME."/.vim/codesnippets-perl"   " Perl code snippets
"                                       
" The menu entrie 'run with pager' will not appear if the following string is empty 
"
let s:Perl_Pager           = "less"          " pager
"
"  
let s:Perl_Template_Directory    = $HOME."/.vim/plugin/templates/"
"                           
"                             ----- Perl template files ---- ( 1. set of templates ) ----
"                             
let s:Perl_Template_File         = "perl-file-header"
let s:Perl_Template_Frame        = "perl-frame"
let s:Perl_Template_Function     = "perl-function-description"
"
"-------------------------------------------------------------------------------------------
"  End of the configuration section
"###############################################################################################
"
"
"------------------------------------------------------------------------------
"  Perl Menu Initialization
"------------------------------------------------------------------------------
function!	Perl_InitMenu ()
"
"---------- Key Mappings -------------------------------------------------------------------------
"  This is for convenience only. Comment out the following maps if you dislike them.
"  If enabled, there may be conflicts with predefined key bindings of your window manager.
"-------------------------------------------------------------------------------------------------
"
"   Ctrl-F9   run script
"        F9   run script with pager
"    Alt-F9   run syntax check
"
"   run the script from the local directory 
"   ( the one which is being edited; other versions may exist elsewhere ! )
"   
	nmap   <S-F1>				<Esc>:call Perl_perldoc_cursor()<CR><CR>

	map   <A-F9>  :call Perl_SyntaxCheck()<CR><CR>
	map   <C-F9>  :call Perl_Run(0)<CR>
"
	imap  <A-F9>  <Esc>:call Perl_SyntaxCheck()<CR><CR>
	imap  <C-F9>  <Esc>:call Perl_Run(0)<CR>
	
	if s:Perl_Pager != ""
		noremap    <F9>  :call Perl_Run(1)<CR>
		inoremap   <F9>  <Esc>:call Perl_Run(1)<CR>
	endif
"
"
"----- The following two maps are only used for the developement of this plugin ----------------
"
"   noremap   <F12>       :write<CR><Esc>:so %<CR><Esc>:call Perl_Handle()<CR><Esc>:call Perl_Handle()<CR><Esc>:call Perl_Handle()<CR>
"  inoremap   <F12>  <Esc>:write<CR><Esc>:so %<CR><Esc>:call Perl_Handle()<CR><Esc>:call Perl_Handle()<CR><Esc>:call Perl_Handle()<CR>
"
"
"---------- P-Comments-Menu ----------------------------------------------------------------------
"
amenu  P-&Comments.&Line\ End\ Comment          <Esc><Esc>A<Tab><Tab><Tab>#<Space>

amenu  <silent>  P-&Comments.&Frame\ Comment         <Esc><Esc>:call Perl_CommentTemplates('frame')<CR>
amenu  <silent>  P-&Comments.F&unction\ Description  <Esc><Esc>:call Perl_CommentTemplates('function')<CR>
amenu  <silent>  P-&Comments.File\ &Header           <Esc><Esc>:call Perl_CommentTemplates('header')<CR>

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
"
 menu  P-&Comments.&Date                      i<C-R>=strftime("%x")<CR>
imenu  P-&Comments.&Date                       <C-R>=strftime("%x")<CR>
 menu  P-&Comments.Date\ &Time                i<C-R>=strftime("%x %X %Z")<CR>
imenu  P-&Comments.Date\ &Time                 <C-R>=strftime("%x %X %Z")<CR>

amenu  P-&Comments.-SEP3-                       :
amenu  P-&Comments.&vim\ modeline             <Esc><Esc>:call Perl_CommentVimModeline()<CR>
			
"---------- P-Statements-Menu ----------------------------------------------------------------------
"
amenu P-St&atements.&if\ \{\ \}		                   <Esc><Esc>oif (  )<CR>{<CR>}<Esc>2kf(la
amenu P-St&atements.if\ \{\ \}\ &else\ \{\ \}        <Esc><Esc>oif (  )<CR>{<CR>}<CR>else<CR>{<CR>}<Esc>5kf(la
amenu P-St&atements.&unless\ \{\ \}                  <Esc><Esc>ounless (  )<CR>{<CR>}<Esc>2kf(la
amenu P-St&atements.un&less\ \{\ \}\ else\ \{\ \}    <Esc><Esc>ounless (  )<CR>{<CR>}<CR>else<CR>{<CR>}<Esc>5kf(la
amenu P-St&atements.&while\ \{\ \}                   <Esc><Esc>owhile (  )<CR>{<CR>}<Tab><Tab><Tab><Tab># -----  end while  -----<Esc>2kF(la
amenu P-St&atements.&do\ \{\ \}\ while               <Esc><Esc>:call Perl_DoWhile()<CR><Esc>4jf(la
amenu P-St&atements.un&til\ \{\ \}                   <Esc><Esc>ountil (  )<CR>{<CR>}<Esc>2kf(la
amenu P-St&atements.f&or\ \{\ \}                     <Esc><Esc>ofor ( ; ;  )<CR>{<CR>}<Esc>2kf;i
amenu P-St&atements.fo&reach\ \{\ \}                 <Esc><Esc>oforeach  (  )<CR>{<CR>}<Tab><Tab><Tab><Tab># -----  end foreach  -----<Esc>2kF(hi
"
"---------- submenu : idioms -------------------------------------------------------------
"
amenu P-I&dioms.&my\ $;                          <Esc><Esc>omy<Tab>$;<Esc>i
amenu P-I&dioms.m&y\ $\ =\ ;                     <Esc><Esc>omy<Tab>$ = ;<Esc>F$a
amenu P-I&dioms.my\ (\ $&,\ $\ );                <Esc><Esc>omy<Tab>( $, $ );<Esc>2F$a
amenu P-I&dioms.-SEP1-                           :
amenu P-I&dioms.(&1)\ \ \ my\ @;                 <Esc><Esc>omy<Tab>@;<Esc>i
amenu P-I&dioms.(&2)\ \ \ my\ @\ =\ (,,);        <Esc><Esc>omy<Tab>@ = ( , ,  );<Esc>F@a
amenu P-I&dioms.-SEP2-                           :
amenu P-I&dioms.(&3)\ \ \ my\ %;                 <Esc><Esc>omy<Tab>%;<Esc>i
amenu P-I&dioms.(&4)\ \ \ my\ %\ =\ (=>,=>,);    <Esc><Esc>omy<Tab>% = <CR>(<CR>=> ,<CR>=> ,<CR>);<Esc>k0i<Tab><Tab><Esc>k0i<Tab><Tab><Esc>2kf%a
amenu P-I&dioms.(&5)\ \ \ my\ $regex_\ =\ '';    <Esc><Esc>omy<Tab>$regex_	= '';<Esc>F_a
amenu P-I&dioms.(&6)\ \ \ my\ $regex_\ =\ qr//;  <Esc><Esc>omy<Tab>$regex_	= qr//;<Esc>F_a

amenu P-I&dioms.-SEP3-                           :

 menu P-I&dioms.(&7)\ \ \ $\ =~\ m//             <Esc>a$ =~ m//<Esc>F$a
 menu P-I&dioms.(&8)\ \ \ $\ =~\ s///            <Esc>a$ =~ s///<Esc>F$a
 menu P-I&dioms.(&9)\ \ \ $\ =~\ tr///           <Esc>a$ =~ tr///<Esc>F$a
imenu P-I&dioms.(&7)\ \ \ $\ =~\ m//             $ =~ m//<Esc>F$a
imenu P-I&dioms.(&8)\ \ \ $\ =~\ s///            $ =~ s///<Esc>F$a
imenu P-I&dioms.(&9)\ \ \ $\ =~\ tr///           $ =~ tr///<Esc>F$a

 menu P-I&dioms.-SEP4-                           :

 menu P-I&dioms.&print\ \"\.\.\.\\n\";           <Esc>aprint "\n";<ESC>3hi
 menu P-I&dioms.print&f\ (\"\.\.\.\\n\");        <Esc>aprintf ("\n");<ESC>4hi
imenu P-I&dioms.&print\ \"\.\.\.\\n\";           print "\n";<ESC>3hi
imenu P-I&dioms.print&f\ (\"\.\.\.\\n\");        printf ("\n");<ESC>4hi
amenu P-I&dioms.&subroutine                      <Esc>:call Perl_CodeFunction()<CR>3jA
amenu P-I&dioms.open\ &input\ file               <Esc>:call Perl_CodeOpenRead()<CR>f'a
amenu P-I&dioms.open\ &output\ file              <Esc>:call Perl_CodeOpenWrite()<CR>f'a
amenu P-I&dioms.open\ pip&e                      <Esc>:call Perl_CodeOpenPipe()<CR>f'a

amenu P-I&dioms.-SEP5-                           :

 menu P-I&dioms.<STDIN>                          <Esc>a<STDIN>
 menu P-I&dioms.<STDOUT>                         <Esc>a<STDOUT>
 menu P-I&dioms.<STDERR>                         <Esc>a<STDERR>
imenu P-I&dioms.<STDIN>                          <STDIN>
imenu P-I&dioms.<STDOUT>                         <STDOUT>
imenu P-I&dioms.<STDERR>                         <STDERR>

	if s:Perl_CodeSnippets != ""
		imenu P-I&dioms.-SEP6-                         :
		amenu <silent>  P-&Idioms.read\ code\ snippet        <C-C>:call Perl_CodeSnippet("r")<CR>
		amenu <silent>  P-&Idioms.write\ code\ snippet       <C-C>:call Perl_CodeSnippet("w")<CR>
		vmenu <silent>  P-&Idioms.write\ code\ snippet       <C-C>:call Perl_CodeSnippet("wv")<CR>
		amenu <silent>  P-&Idioms.edit\ code\ snippet        <C-C>:call Perl_CodeSnippet("e")<CR>
	endif
imenu P-I&dioms.-SEP7-                         :
"
"---------- submenu : POSIX character classes --------------------------------------------
"
 menu P-CharC&ls.[:&alnum:]										<Esc>a[:alnum:]
 menu P-CharC&ls.[:alp&ha:]										<Esc>a[:alpha:]
 menu P-CharC&ls.[:asc&ii:]										<Esc>a[:ascii:]
 menu P-CharC&ls.[:&cntrl:]										<Esc>a[:cntrl:]
 menu P-CharC&ls.[:&digit:]										<Esc>a[:digit:]
 menu P-CharC&ls.[:&graph:]										<Esc>a[:graph:]
 menu P-CharC&ls.[:&lower:]										<Esc>a[:lower:]
 menu P-CharC&ls.[:&print:]										<Esc>a[:print:]
 menu P-CharC&ls.[:pu&nct:]										<Esc>a[:punct:]
 menu P-CharC&ls.[:&space:]										<Esc>a[:space:]
 menu P-CharC&ls.[:&upper:]										<Esc>a[:upper:]
 menu P-CharC&ls.[:&word:]										<Esc>a[:word:]
 menu P-CharC&ls.[:&xdigit:]									<Esc>a[:xdigit:]
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
 menu P-F&ile-Tests.exists															<Esc>a-e <Esc>a
 menu P-F&ile-Tests.has\ zero\ size											<Esc>a-z <Esc>a
 menu P-F&ile-Tests.has\ nonzero\ size									<Esc>a-s <Esc>a
 menu P-F&ile-Tests.plain\ file													<Esc>a-f <Esc>a
 menu P-F&ile-Tests.directory														<Esc>a-d <Esc>a
 menu P-F&ile-Tests.symbolic\ link											<Esc>a-l <Esc>a
 menu P-F&ile-Tests.named\ pipe													<Esc>a-p <Esc>a
 menu P-F&ile-Tests.socket															<Esc>a-S <Esc>a
 menu P-F&ile-Tests.block\ special\ file								<Esc>a-b <Esc>a
 menu P-F&ile-Tests.character\ special\ file						<Esc>a-c <Esc>a
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
"
 menu P-F&ile-Tests.-SEP1-															:
"
 menu P-F&ile-Tests.readable\ by\ effective\ UID/GID		<Esc>a-r <Esc>a
 menu P-F&ile-Tests.writable\ by\ effective\ UID/GID		<Esc>a-w <Esc>a
 menu P-F&ile-Tests.executable\ by\ effective\ UID/GID	<Esc>a-x <Esc>a
 menu P-F&ile-Tests.owned\ by\ effective\ UID						<Esc>a-o <Esc>a
imenu P-F&ile-Tests.readable\ by\ effective\ UID/GID		-r <Esc>a
imenu P-F&ile-Tests.writable\ by\ effective\ UID/GID		-w <Esc>a
imenu P-F&ile-Tests.executable\ by\ effective\ UID/GID	-x <Esc>a
imenu P-F&ile-Tests.owned\ by\ effective\ UID						-o <Esc>a
"
 menu P-F&ile-Tests.-SEP2-																:
"
 menu P-F&ile-Tests.readable\ by\ real\ UID/GID					<Esc>a-R <Esc>a
 menu P-F&ile-Tests.writable\ by\ real\ UID/GID					<Esc>a-W <Esc>a
 menu P-F&ile-Tests.executable\ by\ real\ UID/GID				<Esc>a-X <Esc>a
 menu P-F&ile-Tests.owned\ by\ real\ UID								<Esc>a-O <Esc>a
"
imenu P-F&ile-Tests.readable\ by\ real\ UID/GID					-R <Esc>a
imenu P-F&ile-Tests.writable\ by\ real\ UID/GID					-W <Esc>a
imenu P-F&ile-Tests.executable\ by\ real\ UID/GID				-X <Esc>a
imenu P-F&ile-Tests.owned\ by\ real\ UID								-O <Esc>a
"
 menu P-F&ile-Tests.-SEP3-															:
"
 menu P-F&ile-Tests.setuid\ bit\ set										<Esc>a-u <Esc>a
 menu P-F&ile-Tests.setgid\ bit\ set										<Esc>a-g <Esc>a
 menu P-F&ile-Tests.sticky\ bit\ set										<Esc>a-k <Esc>a
imenu P-F&ile-Tests.setuid\ bit\ set										-u <Esc>a
imenu P-F&ile-Tests.setgid\ bit\ set										-g <Esc>a
imenu P-F&ile-Tests.sticky\ bit\ set										-k <Esc>a
"
imenu P-F&ile-Tests.-SEP4-															:
"
 menu P-F&ile-Tests.age\ since\ modification						<Esc>a-M <Esc>a
 menu P-F&ile-Tests.age\ since\ last\ access						<Esc>a-A <Esc>a
 menu P-F&ile-Tests.age\ since\ inode\ change						<Esc>a-C <Esc>a
imenu P-F&ile-Tests.age\ since\ modification						-M <Esc>a
imenu P-F&ile-Tests.age\ since\ last\ access						-A <Esc>a
imenu P-F&ile-Tests.age\ since\ inode\ change						-C <Esc>a
"
imenu P-F&ile-Tests.-SEP5-															:
"
 menu P-F&ile-Tests.text\ file													<Esc>a-T <Esc>a
 menu P-F&ile-Tests.binary\ file												<Esc>a-B <Esc>a
 menu P-F&ile-Tests.handle\ opened\ to\ a\ tty					<Esc>a-t <Esc>a
imenu P-F&ile-Tests.text\ file													-T <Esc>a
imenu P-F&ile-Tests.binary\ file												-B <Esc>a
imenu P-F&ile-Tests.handle\ opened\ to\ a\ tty					-t <Esc>a
"
"---------- P-Special-Variables -------------------------------------------------------------
"
	"-------- submenu errors -------------------------------------------------
	 menu P-Spec-&Var.&errors.$CHILD_ERROR      					<Esc>a$CHILD_ERROR
	 menu P-Spec-&Var.&errors.$ERRNO            					<Esc>a$ERRNO
	 menu P-Spec-&Var.&errors.$EVAL_ERROR       					<Esc>a$EVAL_ERROR
	 menu P-Spec-&Var.&errors.$EXTENDED_OS_ERROR					<Esc>a$EXTENDED_OS_ERROR
	 menu P-Spec-&Var.&errors.$OS_ERRNO         					<Esc>a$OS_ERRNO
	 menu P-Spec-&Var.&errors.$WARNING          					<Esc>a$WARNING
	imenu P-Spec-&Var.&errors.$CHILD_ERROR      					$CHILD_ERROR
	imenu P-Spec-&Var.&errors.$ERRNO            					$ERRNO
	imenu P-Spec-&Var.&errors.$EVAL_ERROR       					$EVAL_ERROR
	imenu P-Spec-&Var.&errors.$EXTENDED_OS_ERROR					$EXTENDED_OS_ERROR
	imenu P-Spec-&Var.&errors.$OS_ERRNO         					$OS_ERRNO
	imenu P-Spec-&Var.&errors.$WARNING          					$WARNING

	"-------- submenu files -------------------------------------------------
	 menu P-Spec-&Var.&files.$AUTOFLUSH            				<Esc>a$AUTOFLUSH
	 menu P-Spec-&Var.&files.$OUTPUT_AUTOFLUSH     				<Esc>a$OUTPUT_AUTOFLUSH
	 menu P-Spec-&Var.&files.$FORMAT_LINES_LEFT    				<Esc>a$FORMAT_LINES_LEFT
	 menu P-Spec-&Var.&files.$FORMAT_LINES_PER_PAGE				<Esc>a$FORMAT_LINES_PER_PAGE
	 menu P-Spec-&Var.&files.$FORMAT_NAME          				<Esc>a$FORMAT_NAME
	 menu P-Spec-&Var.&files.$FORMAT_PAGE_NUMBER   				<Esc>a$FORMAT_PAGE_NUMBER
	 menu P-Spec-&Var.&files.$FORMAT_TOP_NAME      				<Esc>a$FORMAT_TOP_NAME
	imenu P-Spec-&Var.&files.$AUTOFLUSH            				$AUTOFLUSH
	imenu P-Spec-&Var.&files.$OUTPUT_AUTOFLUSH     				$OUTPUT_AUTOFLUSH
	imenu P-Spec-&Var.&files.$FORMAT_LINES_LEFT    				$FORMAT_LINES_LEFT
	imenu P-Spec-&Var.&files.$FORMAT_LINES_PER_PAGE				$FORMAT_LINES_PER_PAGE
	imenu P-Spec-&Var.&files.$FORMAT_NAME          				$FORMAT_NAME
	imenu P-Spec-&Var.&files.$FORMAT_PAGE_NUMBER   				$FORMAT_PAGE_NUMBER
	imenu P-Spec-&Var.&files.$FORMAT_TOP_NAME      				$FORMAT_TOP_NAME

	"-------- submenu IDs -------------------------------------------------
	 menu P-Spec-&Var.&IDs.$PID               						<Esc>a$PID
	 menu P-Spec-&Var.&IDs.$PROCESS_ID        						<Esc>a$PROCESS_ID
	 menu P-Spec-&Var.&IDs.$GID               						<Esc>a$GID
	 menu P-Spec-&Var.&IDs.$REAL_GROUP_ID     						<Esc>a$REAL_GROUP_ID
	 menu P-Spec-&Var.&IDs.$EGID              						<Esc>a$EGID
	 menu P-Spec-&Var.&IDs.$EFFECTIVE_GROUP_ID						<Esc>a$EFFECTIVE_GROUP_ID
	imenu P-Spec-&Var.&IDs.$PID               						$PID
	imenu P-Spec-&Var.&IDs.$PROCESS_ID        						$PROCESS_ID
	imenu P-Spec-&Var.&IDs.$GID               						$GID
	imenu P-Spec-&Var.&IDs.$REAL_GROUP_ID     						$REAL_GROUP_ID
	imenu P-Spec-&Var.&IDs.$EGID              						$EGID
	imenu P-Spec-&Var.&IDs.$EFFECTIVE_GROUP_ID						$EFFECTIVE_GROUP_ID

	"-------- submenu IO -------------------------------------------------
	 menu P-Spec-&Var.I&O.$INPUT_LINE_NUMBER      				<Esc>a$INPUT_LINE_NUMBER
	 menu P-Spec-&Var.I&O.$NR                     				<Esc>a$NR
	imenu P-Spec-&Var.I&O.$INPUT_LINE_NUMBER      				$INPUT_LINE_NUMBER
	imenu P-Spec-&Var.I&O.$NR                     				$NR
	
	imenu P-Spec-&Var.I&O.-SEP1-      		            :

	 menu P-Spec-&Var.I&O.$INPUT_RECORD_SEPARATOR 				<Esc>a$INPUT_RECORD_SEPARATOR
	 menu P-Spec-&Var.I&O.$RS                     				<Esc>a$RS
	 menu P-Spec-&Var.I&O.$LIST_SEPARATOR         				<Esc>a$LIST_SEPARATOR
	 menu P-Spec-&Var.I&O.$OUTPUT_FIELD_SEPARATOR 				<Esc>a$OUTPUT_FIELD_SEPARATOR
	 menu P-Spec-&Var.I&O.$OFS                    				<Esc>a$OFS
	 menu P-Spec-&Var.I&O.$OUTPUT_RECORD_SEPARATOR				<Esc>a$OUTPUT_RECORD_SEPARATOR
	 menu P-Spec-&Var.I&O.$ORS                    				<Esc>a$ORS
	 menu P-Spec-&Var.I&O.$SUBSCRIPT_SEPARATOR    				<Esc>a$SUBSCRIPT_SEPARATOR
	 menu P-Spec-&Var.I&O.$SUBSEP                 				<Esc>a$SUBSEP
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
	 menu P-Spec-&Var.&regexp.$digits                 		<Esc>a$digits
	 menu P-Spec-&Var.&regexp.@LAST_MATCH_END         		<Esc>a@LAST_MATCH_END
	 menu P-Spec-&Var.&regexp.@LAST_MATCH_START       		<Esc>a@LAST_MATCH_START
	 menu P-Spec-&Var.&regexp.$LAST_PAREN_MATCH       		<Esc>a$LAST_PAREN_MATCH
	 menu P-Spec-&Var.&regexp.$LAST_REGEXP_CODE_RESULT		<Esc>a$LAST_REGEXP_CODE_RESULT
	 menu P-Spec-&Var.&regexp.$MATCH                  		<Esc>a$MATCH
	 menu P-Spec-&Var.&regexp.$POSTMATCH              		<Esc>a$POSTMATCH
	 menu P-Spec-&Var.&regexp.$PREMATCH               		<Esc>a$PREMATCH
	imenu P-Spec-&Var.&regexp.$digits                 		$digits
	imenu P-Spec-&Var.&regexp.@LAST_MATCH_END         		@LAST_MATCH_END
	imenu P-Spec-&Var.&regexp.@LAST_MATCH_START       		@LAST_MATCH_START
	imenu P-Spec-&Var.&regexp.$LAST_PAREN_MATCH       		$LAST_PAREN_MATCH
	imenu P-Spec-&Var.&regexp.$LAST_REGEXP_CODE_RESULT		$LAST_REGEXP_CODE_RESULT
	imenu P-Spec-&Var.&regexp.$MATCH                  		$MATCH
	imenu P-Spec-&Var.&regexp.$POSTMATCH              		$POSTMATCH
	imenu P-Spec-&Var.&regexp.$PREMATCH               		$PREMATCH

 menu P-Spec-&Var.$BASETIME      					<Esc>a$BASETIME
 menu P-Spec-&Var.$PERL_VERSION  					<Esc>a$PERL_VERSION
 menu P-Spec-&Var.$PROGRAM_NAME  					<Esc>a$PROGRAM_NAME
 menu P-Spec-&Var.$OSNAME       					<Esc>a$OSNAME
 menu P-Spec-&Var.$SYSTEM_FD_MAX 					<Esc>a$SYSTEM_FD_MAX
 menu P-Spec-&Var.$ENV{\ }			 					<Esc>a$ENV{}<ESC>i
 menu P-Spec-&Var.$INC{\ }			 					<Esc>a$INC{}<ESC>i
 menu P-Spec-&Var.$SIG{\ }			 					<Esc>a$SIG{}<ESC>i
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
	 menu P-Spec-&Var.POSIX\ signals.HUP 		<Esc>aHUP
	 menu P-Spec-&Var.POSIX\ signals.INT 		<Esc>aINT
	 menu P-Spec-&Var.POSIX\ signals.QUIT		<Esc>aQUIT
	 menu P-Spec-&Var.POSIX\ signals.ILL 		<Esc>aILL
	 menu P-Spec-&Var.POSIX\ signals.ABRT		<Esc>aABRT
	 menu P-Spec-&Var.POSIX\ signals.FPE 		<Esc>aFPE
	 menu P-Spec-&Var.POSIX\ signals.KILL		<Esc>aKILL
	 menu P-Spec-&Var.POSIX\ signals.SEGV		<Esc>aSEGV
	 menu P-Spec-&Var.POSIX\ signals.PIPE		<Esc>aPIPE
	 menu P-Spec-&Var.POSIX\ signals.ALRM		<Esc>aALRM
	 menu P-Spec-&Var.POSIX\ signals.TERM		<Esc>aTERM
	 menu P-Spec-&Var.POSIX\ signals.USR1		<Esc>aUSR1
	 menu P-Spec-&Var.POSIX\ signals.USR2		<Esc>aUSR2
	 menu P-Spec-&Var.POSIX\ signals.CHLD		<Esc>aCHLD
	 menu P-Spec-&Var.POSIX\ signals.CONT		<Esc>aCONT
	 menu P-Spec-&Var.POSIX\ signals.STOP		<Esc>aSTOP
	 menu P-Spec-&Var.POSIX\ signals.TSTP		<Esc>aTSTP
	 menu P-Spec-&Var.POSIX\ signals.TTIN		<Esc>aTTIN
	 menu P-Spec-&Var.POSIX\ signals.TTOU		<Esc>aTTOU
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

 menu P-Spec-&Var.\'IGNORE\' 														<Esc>a'IGNORE'
 menu P-Spec-&Var.\'DEFAULT\' 													<Esc>a'DEFAULT'
imenu P-Spec-&Var.\'IGNORE\' 														'IGNORE'
imenu P-Spec-&Var.\'DEFAULT\' 													'DEFAULT'

imenu P-Spec-&Var.-SEP3-      		              	      :
 menu P-Spec-&Var.use\ English; 												<ESC><ESC>ouse English;

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
amenu <silent> P-&Run.make\ script\ e&xecutable                <C-C>:!chmod -c u+x %<CR>
amenu <silent> P-&Run.command\ line\ &arguments                <C-C>:call Perl_Arguments()<CR>
amenu          P-&Run.-SEP2-      		              	         :

amenu <silent> P-&Run.read\ perl&doc                           <C-C>:call Perl_perldoc_dialog()<CR><CR>
"
amenu          P-&Run.-SEP3-      		              	         :
amenu <silent> P-&Run.&hardcopy\ buffer\ to\ FILENAME\.ps      <C-C>:call Perl_Hardcopy("n")<CR>
vmenu <silent> P-&Run.hard&copy\ part\ to\ FILENAME\.part\.ps  <C-C>:call Perl_Hardcopy("v")<CR>
imenu          P-&Run.-SEP4-                                   :
amenu <silent> P-&Run.se&ttings\ and\ hot\ keys                <C-C>:call Perl_Settings()<CR>
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
"  P-Comments : classified comments
"------------------------------------------------------------------------------
function! Perl_CommentClassified (class)
  	put = '# :'.a:class.':'.strftime(\"%x\").':'.s:Perl_AuthorRef.': '
endfunction
"
"------------------------------------------------------------------------------
"  P-Comments : Insert Template Files
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

	if a:arg=='header'
		let templatefile=s:Perl_Template_Directory.s:Perl_Template_File
	endif


	if filereadable(templatefile)
		let	length= line("$")
		let	pos1  = line(".")+1
		if  a:arg=='header' 
			:goto 1
			let	pos1  = 1
			exe '0read '.templatefile
		else
			exe 'read '.templatefile
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
		silent! exe pos1.','.pos2.' s/|AUTHOR|/'.s:Perl_AuthorName.'/g'
		silent! exe pos1.','.pos2.' s/|EMAIL|/'.s:Perl_Email.'/g'
		silent! exe pos1.','.pos2.' s/|AUTHORREF|/'.s:Perl_AuthorRef.'/g'
		silent! exe pos1.','.pos2.' s/|PROJECT|/'.s:Perl_Project.'/g'
		silent! exe pos1.','.pos2.' s/|COMPANY|/'.s:Perl_Company.'/g'
		silent! exe pos1.','.pos2.' s/|COPYRIGHTHOLDER|/'.s:Perl_CopyrightHolder.'/g'
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
endfunction    " ----------  end of function  Perl_CommentTemplates  ----------
"
"------------------------------------------------------------------------------
"  P-Comments : vim modeline
"------------------------------------------------------------------------------
function! Perl_CommentVimModeline ()
  	put = '# vim: set tabstop='.&tabstop.': set shiftwidth='.&shiftwidth.': '
endfunction    " ----------  end of function Perl_CommentVimModeline  ----------
"
"------------------------------------------------------------------------------
"  P-Statements : subroutine
"------------------------------------------------------------------------------
function! Perl_CodeFunction ()
	let	identifier=inputdialog("subroutine name", "f" )
	if identifier==""
		let	identifier	= "f"
	endif
  let zz=    "sub ".identifier."\n{\n\tmy\t$par1\t= shift;\n\t\n\treturn ;\n}"
  let zz= zz."\t# ----------  end of subroutine ".identifier."  ----------" 
	put =zz
endfunction
"
"------------------------------------------------------------------------------
"  Statements : do-while
"------------------------------------------------------------------------------
"
function! Perl_DoWhile ()
	let zz=    "do\n{\n\t\n}\nwhile (  );"
  let zz= zz."\t\t\t\t# -----  end do-while  -----\n"
	put =zz
	normal	=4+
endfunction
"
"------------------------------------------------------------------------------
"  Perl-Idioms : CodeOpenRead
"------------------------------------------------------------------------------
function! Perl_CodeOpenRead ()

	let	filehandle=inputdialog("input file handle", "INFILE")
	if filehandle==""
		let	filehandle	= "INFILE"
	endif
	
	let filename=filehandle."_file_name"

	let zz=    "my\t$".filename." = \'\';\t\t# input file name\n\n"
	let zz= zz."open ( ".filehandle.", \'<\', $".filename." )\n"
	let zz= zz."\tor die \"$0 : failed to open input file $".filename." : $!\\n\";\n\n\n"
	let zz= zz."close ( ".filehandle." );\t\t\t# close input file\n"
	exe ":imenu P-I&dioms.<".filehandle.">      <".filehandle."><ESC>a"
	put =zz
	normal =6+
endfunction
"
"------------------------------------------------------------------------------
"  Perl-Idioms : CodeOpenWrite
"------------------------------------------------------------------------------
function! Perl_CodeOpenWrite ()

	let	filehandle=inputdialog("output file handle", "OUTFILE")
	if filehandle==""
		let	filehandle	= "OUTFILE"
	endif
	
	let filename=filehandle."_file_name"

	let zz=    "my\t$".filename." = \'\';\t\t# output file name\n\n"
	let zz= zz."open ( ".filehandle.", \'>\', $".filename." )\n"
	let zz= zz."\tor die \"$0 : failed to open output file $".filename." : $!\\n\";\n\n\n"
	let zz= zz."close ( ".filehandle." );\t\t\t# close output file\n"
	put =zz
	normal =6+
	exe ":imenu P-I&dioms.print\\ ".filehandle."\\ \"\\\\n\";       print ".filehandle." \"\\n\";<ESC>3hi"
endfunction
"
"------------------------------------------------------------------------------
"  Perl-Idioms : CodeOpenPipe
"------------------------------------------------------------------------------
function! Perl_CodeOpenPipe ()

	let	filehandle=inputdialog("pipe handle", "PIPE")
	if filehandle==""
		let	filehandle	= "PIPE"
	endif
	
	let pipecommand=filehandle."_command"

	let zz=    "my\t$".pipecommand." = \'\';\t\t# pipe command\n\n"
	let zz= zz."open ( ".filehandle.", $".pipecommand." )\n"
	let zz= zz."\tor die \"$0 : failed to open pipe > $".pipecommand." < : $!\\n\";\n\n\n"
	let zz= zz."close ( ".filehandle." );\t\t\t# close pipe\n"
	put =zz
	normal =6+
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
			if filereadable(l:snippetfile)
				let	length= line("$")
				:execute "read ".l:snippetfile
				let	length= line("$")-length-1
				if length>=0
					silent exe "normal =".length."+"
				endif
			endif
"			if l:snippetfile != ""
"				:execute "read ".l:snippetfile
"			endif
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
"
"------------------------------------------------------------------------------
"  Perl-Run : Perl_perldoc - dialog
"------------------------------------------------------------------------------
function! Perl_perldoc_dialog()

	let	item=inputdialog("perldoc function or mudule : ", "")
	"------------------------------------------------------------------------------
	"  replace buffer content with Perl documentation
	"------------------------------------------------------------------------------
	if item != ""
		exe ":new | %!perldoc ".item
		if line("$")==1
			exe ":%!perldoc -f ".item
		endif

		set buftype=nofile
		set noswapfile
	endif
endfunction
"
"------------------------------------------------------------------------------
"  Perl-Run : Perl_perldoc - dialog
"------------------------------------------------------------------------------
function! Perl_perldoc_cursor()

	let	item=expand("<cword>")				" word under the cursor 

	if  item == ""
		let	item=inputdialog("perldoc function or mudule : ", "")
	endif
	"------------------------------------------------------------------------------
	"  replace buffer content with Perl documentation
	"------------------------------------------------------------------------------
	if item != ""
		exe ":new | %!perldoc ".item
		if line("$")==1
			exe ":%!perldoc -f ".item
		endif
		set buftype=nofile
		set noswapfile
	endif
endfunction
"
"------------------------------------------------------------------------------
"  Run : settings
"------------------------------------------------------------------------------
function! Perl_Settings ()
	let	settings =         "Perl-Support settings\n\n"
	let settings = settings."______________________________________________________\n\n"
	let settings = settings."Additional hot keys\n\n"
	let settings = settings."Shift-F1  :  read perldoc (for word under cursor)\n"
	let settings = settings." Ctrl-F9  :  update file, run script           \n"
	let settings = settings."      F9  :  update file, run script with pager\n"
	let settings = settings."  Alt-F9  :  update file, run syntax check     \n"
	let settings = settings."______________________________________________________\n\n"
	let settings = settings."author  :  ".s:Perl_AuthorName." (".s:Perl_AuthorRef.") ".s:Perl_Email."\n"
	let settings = settings."company :  ".s:Perl_Company."\n"
	let settings = settings."copyright holder :  ".s:Perl_CopyrightHolder."\n"
	if(s:Perl_CopyrightHolder!="")
		let settings = settings."copyright year(s) :  ".s:Perl_CopyrightYears."\n"
	endif
	let settings = settings."code snippet directory  :  ".s:Perl_CodeSnippets."\n"
	let settings = settings."\n"
	let settings = settings."\nMake changes in file bash-support.vim\n"
	let	settings = settings."----------------------------------------------------------------------------------------\n"
	let	settings = settings."Perl-Support, Version ".s:Perl_Version."  /  Dr.-Ing. Fritz Mehner  /  mehner@fh-swf.de\n"
	let dummy=confirm( settings, "ok", 1, "Info" )
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
	" match the Perl error messages (quickfix commands)
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
function! Perl_CreateUnLoadMenuEntries ()
	"
	" Perl is now active and was former inactive -> 
	" Insert Tools.Unload and remove Tools.Load Menu
	" protect the following submenu names against interpolation by using single qoutes (Mn)
	"
	if  s:Perl_Active == 1
		:aunmenu &Tools.Load\ Perl\ Support
		exe 'amenu  <silent> 40.1160   &Tools.Unload\ Perl\ Support  	<C-C>:call Perl_Handle()<CR>'
	else
		" Perl is now inactive and was former active or in initial state -1 
		if s:Perl_Active == 0
			" Remove Tools.Unload if Perl was former inactive
			:aunmenu &Tools.Unload\ Perl\ Support
		else
			" Set initial state Perl_Active=-1 to inactive state Perl_Active=0
			" This protects from removing Tools.Unload during initialization after
			" loading this script
			let s:Perl_Active = 0
			" Insert Tools.Load
		endif
		exe 'amenu <silent> 40.1000 &Tools.-SEP100- : '
		exe 'amenu <silent> 40.1160 &Tools.Load\ Perl\ Support <C-C>:call Perl_Handle()<CR>'
		exe 'amenu <silent> &Tools.Load\ Perl\ Support <C-C>:call Perl_Handle()<CR>'
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
" vim:set tabstop=2: 
