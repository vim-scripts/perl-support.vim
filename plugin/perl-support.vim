"###############################################################################################
"
"       Filename:  perl-support.vim
"
"    Description:  Write, compile and run Perl-scripts using menus and key mappings.
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
"                  - show compilation errors in a quickfix window; navigate with hotkeys 
"                  - read perldoc for functions and modules 
"                 
"  Configuration:  There are some personal details which should be configured 
"                  (see the files README and perlsupport.txt).
"
"         Author:  Dr.-Ing. Fritz Mehner <mehner@fh-swf.de>
"
let s:Perl_Version = "1.9.2"              " version number of this script; do not change
"
"       Revision:  04.08.2003
"
"        Created:  09.07.2001 - 12:21:33
"
"        License:  This program is free software; you can redistribute it and/or modify
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
"        Credits:  Lukas Zapletal for the errorformat (taken from the script perl.vim).
"        
"                  David Fishburn <fishburn@ianywhere.com> for the implementation of the 
"                  single root menu and several suggestions for improving the customization
"                  and the documentation.
"        
"###############################################################################################
"
"------------------------------------------------------------------------------
"
"  Global variables (with default values) which can be overridden.
"
let s:Perl_AuthorName            = ""
let s:Perl_AuthorRef             = ""
let s:Perl_Email                 = ""
let s:Perl_Company               = ""
let s:Perl_Project               = ""
let s:Perl_CopyrightHolder       = ""
"
let s:Perl_LoadMenus             = "yes"
" 
let s:Perl_CodeSnippets          = $HOME."/.vim/codesnippets-perl"
" 
let s:Perl_Template_Directory    = $HOME."/.vim/plugin/templates/"
let s:Perl_Template_File         = "perl-file-header"
let s:Perl_Template_Frame        = "perl-frame"
let s:Perl_Template_Function     = "perl-function-description"
"
"
let s:Perl_Pager                 = "less"
"
"------------------------------------------------------------------------------
"
"  Look for global variables (if any), to override the defaults.
"  
if exists("g:Perl_AuthorName")
	let s:Perl_AuthorName         = g:Perl_AuthorName
endif

if exists("g:Perl_AuthorRef")
	let s:Perl_AuthorRef          = g:Perl_AuthorRef       
endif

if exists("g:Perl_Email")
	let s:Perl_Email              = g:Perl_Email
endif

if exists("g:Perl_Company")
	let s:Perl_Company            = g:Perl_Company
endif

if exists("g:Perl_Project")
	let s:Perl_Project            = g:Perl_Project
endif

if exists("g:Perl_CopyrightHolder")
	let s:Perl_CopyrightHolder    = g:Perl_CopyrightHolder
endif
"
if exists("g:Perl_LoadMenus")
	let s:Perl_LoadMenus          = g:Perl_LoadMenus
endif
"
if exists("g:Perl_CodeSnippets")
	let s:Perl_CodeSnippets       = g:Perl_CodeSnippets
endif
"                           
if exists("g:Perl_Template_Directory")
	let s:Perl_Template_Directory = g:Perl_Template_Directory
endif
"                           
if exists("g:Perl_Template_File")
	let s:Perl_Template_File      = g:Perl_Template_File
endif
"                           
if exists("g:Perl_Template_Frame")
	let s:Perl_Template_Frame     = g:Perl_Template_Frame
endif
"                           
if exists("g:Perl_Template_Function")
	let s:Perl_Template_Function  = g:Perl_Template_Function
endif
"
if exists("g:Perl_Pager")
	let s:Perl_Pager              = g:Perl_Pager
endif
"
"
"------------------------------------------------------------------------------
"  Perl Menu Initialization
"------------------------------------------------------------------------------
function!	Perl_InitMenu ()
"
"----- The following two maps are only used for the development of this plugin ----------------
"
   noremap   <F12>       :write<CR><Esc>:so %<CR><Esc>:call Perl_Handle()<CR><Esc>:call Perl_Handle()<CR>
  inoremap   <F12>  <Esc>:write<CR><Esc>:so %<CR><Esc>:call Perl_Handle()<CR><Esc>:call Perl_Handle()<CR>
"
"-----------------------------------------------------------------------------------------------
"
if has("gui_running")

	amenu &Perl.<Tab>Perl                                    <Esc>
	amenu &Perl.-Sep0-                         :
	"
	"---------- Comments-Menu ----------------------------------------------------------------------
	"
	amenu &Perl.&Comments.<Tab>Perl                                    <Esc>
	amenu &Perl.&Comments.-Sep0-                         :

	amenu &Perl.&Comments.&Line\ End\ Comment               <Esc><Esc>A<Tab><Tab><Tab>#<Space>
	amenu <silent>  &Perl.&Comments.&Frame\ Comment         <Esc><Esc>:call Perl_CommentTemplates('frame')<CR>
	amenu <silent>  &Perl.&Comments.F&unction\ Description  <Esc><Esc>:call Perl_CommentTemplates('function')<CR>
	amenu <silent>  &Perl.&Comments.File\ &Header           <Esc><Esc>:call Perl_CommentTemplates('header')<CR>

	amenu &Perl.&Comments.-SEP1-                       :
	"
	vmenu &Perl.&Comments.&code->comment               <Esc><Esc>:'<,'>s/^/#/<CR><Esc>:nohlsearch<CR>
	vmenu &Perl.&Comments.c&omment->code               <Esc><Esc>:'<,'>s/^#//<CR><Esc>:nohlsearch<CR>
	"
	amenu &Perl.&Comments.-SEP2-                       :
	"
	 menu &Perl.&Comments.&Date                      i<C-R>=strftime("%x")<CR>
	imenu &Perl.&Comments.&Date                       <C-R>=strftime("%x")<CR>
	 menu &Perl.&Comments.Date\ &Time                i<C-R>=strftime("%x %X %Z")<CR>
	imenu &Perl.&Comments.Date\ &Time                 <C-R>=strftime("%x %X %Z")<CR>


	amenu &Perl.&Comments.-SEP3-                       :
	"
	"--------- submenu : KEYWORD -------------------------------------------------------------
	"
	amenu &Perl.&Comments.#:&KEYWORD\:.<Tab>Perl                                    <Esc>
	amenu &Perl.&Comments.#:&KEYWORD\:.-Sep0-                         :
	"
	amenu &Perl.&Comments.#:&KEYWORD\:.&BUG          <Esc><Esc>$<Esc>:call Perl_CommentClassified("BUG")     <CR>kJA
	amenu &Perl.&Comments.#:&KEYWORD\:.&TODO         <Esc><Esc>$<Esc>:call Perl_CommentClassified("TODO")    <CR>kJA
	amenu &Perl.&Comments.#:&KEYWORD\:.T&RICKY       <Esc><Esc>$<Esc>:call Perl_CommentClassified("TRICKY")  <CR>kJA
	amenu &Perl.&Comments.#:&KEYWORD\:.&WARNING      <Esc><Esc>$<Esc>:call Perl_CommentClassified("WARNING") <CR>kJA
	amenu &Perl.&Comments.#:&KEYWORD\:.&new\ keyword <Esc><Esc>$<Esc>:call Perl_CommentClassified("")        <CR>kJf:a
	"
	amenu &Perl.&Comments.&vim\ modeline             <Esc><Esc>:call Perl_CommentVimModeline()<CR>

	"---------- Statements-Menu ----------------------------------------------------------------------

	amenu &Perl.St&atements.<Tab>Perl                                    <Esc>
	amenu &Perl.St&atements.-Sep0-                         :
	"
	amenu &Perl.St&atements.&do\ \{\ \}\ while               <Esc><Esc>:call Perl_DoWhile('a')<CR><Esc>4jf(la
	amenu &Perl.St&atements.&for\ \{\ \}                     <Esc><Esc>ofor ( ; ;  )<CR>{<CR>}<Esc>2kf;i
	amenu &Perl.St&atements.f&oreach\ \{\ \}                 <Esc><Esc>oforeach  (  )<CR>{<CR>}<Tab><Tab><Tab><Tab># -----  end foreach  -----<Esc>2kF(hi
	amenu &Perl.St&atements.&if\ \{\ \}		                   <Esc><Esc>oif (  )<CR>{<CR>}<Esc>2kf(la
	amenu &Perl.St&atements.if\ \{\ \}\ &else\ \{\ \}        <Esc><Esc>oif (  )<CR>{<CR>}<CR>else<CR>{<CR>}<Esc>5kf(la
	amenu &Perl.St&atements.&unless\ \{\ \}                  <Esc><Esc>ounless (  )<CR>{<CR>}<Esc>2kf(la
	amenu &Perl.St&atements.u&nless\ \{\ \}\ else\ \{\ \}    <Esc><Esc>ounless (  )<CR>{<CR>}<CR>else<CR>{<CR>}<Esc>5kf(la
	amenu &Perl.St&atements.un&til\ \{\ \}                   <Esc><Esc>ountil (  )<CR>{<CR>}<Esc>2kf(la
	amenu &Perl.St&atements.&while\ \{\ \}                   <Esc><Esc>owhile (  )<CR>{<CR>}<Tab><Tab><Tab><Tab># -----  end while  -----<Esc>2kF(la
	"
	vmenu &Perl.St&atements.&do\ \{\ \}\ while               <Esc><Esc>:call Perl_DoWhile('v')<CR><Esc>f(la
	vmenu &Perl.St&atements.&for\ \{\ \}                     DOfor ( ; ;  )<CR>{<CR>}<Esc>P2k<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>f;i
	vmenu &Perl.St&atements.f&oreach\ \{\ \}                 DOforeach  (  )<CR>{<CR>}<Tab><Tab><Tab><Tab># -----  end foreach  -----<Esc>P2k<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>f(hi
	vmenu &Perl.St&atements.&if\ \{\ \}		                   DOif (  )<CR>{<CR>}<Esc>Pk<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>f(la
	vmenu &Perl.St&atements.if\ \{\ \}\ &else\ \{\ \}        DOif (  )<CR>{<CR>}<CR>else<CR>{<CR>}<Esc>3kP2k<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>f(la
	vmenu &Perl.St&atements.&unless\ \{\ \}                  DOunless (  )<CR>{<CR>}<Esc>P2k<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>f(la
	vmenu &Perl.St&atements.u&nless\ \{\ \}\ else\ \{\ \}    DOunless (  )<CR>{<CR>}<CR>else<CR>{<CR>}<Esc>3kP2k<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>f(la
	vmenu &Perl.St&atements.un&til\ \{\ \}                   DOuntil (  )<CR>{<CR>}<Esc>P2k<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>f(la
	vmenu &Perl.St&atements.&while\ \{\ \}                   DOwhile (  )<CR>{<CR>}<Tab><Tab><Tab><Tab># -----  end while  -----<Esc>P2k<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>f(la
	"
	"
	"---------- submenu : idioms -------------------------------------------------------------
	"
	amenu &Perl.I&dioms.<Tab>Perl                                    <Esc>
	amenu &Perl.I&dioms.-Sep0-                         :
	"
	amenu &Perl.I&dioms.&my\ $;                          <Esc><Esc>omy<Tab>$;<Esc>i
	amenu &Perl.I&dioms.m&y\ $\ =\ ;                     <Esc><Esc>omy<Tab>$<Tab>= ;<Esc>F$a
	amenu &Perl.I&dioms.my\ (\ $&,\ $\ );                <Esc><Esc>omy<Tab>( $, $ );<Esc>2F$a
	amenu &Perl.I&dioms.-SEP1-                           :
	amenu &Perl.I&dioms.(&1)\ \ \ my\ @;                 <Esc><Esc>omy<Tab>@;<Esc>i
	amenu &Perl.I&dioms.(&2)\ \ \ my\ @\ =\ (,,);        <Esc><Esc>omy<Tab>@<Tab>= ( , ,  );<Esc>F@a
	amenu &Perl.I&dioms.-SEP2-                           :
	amenu &Perl.I&dioms.(&3)\ \ \ my\ %;                 <Esc><Esc>omy<Tab>%;<Esc>i
	amenu &Perl.I&dioms.(&4)\ \ \ my\ %\ =\ (=>,=>,);    <Esc><Esc>omy<Tab>%<Tab>= <CR>(<CR>=> ,<CR>=> ,<CR>);<Esc>k0i<Tab><Tab><Esc>k0i<Tab><Tab><Esc>2kf%a
	amenu &Perl.I&dioms.(&5)\ \ \ my\ $regex_\ =\ '';    <Esc><Esc>omy<Tab>$regex_<Tab>= '';<Esc>F_a
	amenu &Perl.I&dioms.(&6)\ \ \ my\ $regex_\ =\ qr//;  <Esc><Esc>omy<Tab>$regex_<Tab>= qr//;<Esc>F_a
	"

	amenu &Perl.I&dioms.-SEP3-                           :

	 menu &Perl.I&dioms.(&7)\ \ \ $\ =~\ m//             <Esc>a$ =~ m//<Esc>F$a
	 menu &Perl.I&dioms.(&8)\ \ \ $\ =~\ s///            <Esc>a$ =~ s///<Esc>F$a
	 menu &Perl.I&dioms.(&9)\ \ \ $\ =~\ tr///           <Esc>a$ =~ tr///<Esc>F$a
	imenu &Perl.I&dioms.(&7)\ \ \ $\ =~\ m//             $ =~ m//<Esc>F$a
	imenu &Perl.I&dioms.(&8)\ \ \ $\ =~\ s///            $ =~ s///<Esc>F$a
	imenu &Perl.I&dioms.(&9)\ \ \ $\ =~\ tr///           $ =~ tr///<Esc>F$a


	 menu &Perl.I&dioms.-SEP4-                           :

	 menu &Perl.I&dioms.&print\ \"\.\.\.\\n\";           <Esc>aprint "\n";<ESC>3hi
	 menu &Perl.I&dioms.print&f\ (\"\.\.\.\\n\");        <Esc>aprintf ("\n");<ESC>4hi
	imenu &Perl.I&dioms.&print\ \"\.\.\.\\n\";           print "\n";<ESC>3hi
	imenu &Perl.I&dioms.print&f\ (\"\.\.\.\\n\");        printf ("\n");<ESC>4hi

	amenu &Perl.I&dioms.&subroutine                      <Esc><Esc>:call Perl_CodeFunction()<CR>A
	amenu &Perl.I&dioms.open\ &input\ file               <Esc><Esc>:call Perl_CodeOpenRead()<CR>a
	amenu &Perl.I&dioms.open\ &output\ file              <Esc><Esc>:call Perl_CodeOpenWrite()<CR>a
	amenu &Perl.I&dioms.open\ pip&e                      <Esc><Esc>:call Perl_CodeOpenPipe()<CR>a


	amenu &Perl.I&dioms.-SEP5-                           :

	 menu &Perl.I&dioms.<STDIN>                          <Esc>a<STDIN>
	 menu &Perl.I&dioms.<STDOUT>                         <Esc>a<STDOUT>
	 menu &Perl.I&dioms.<STDERR>                         <Esc>a<STDERR>
	imenu &Perl.I&dioms.<STDIN>                          <STDIN>
	imenu &Perl.I&dioms.<STDOUT>                         <STDOUT>
	imenu &Perl.I&dioms.<STDERR>                         <STDERR>

" The menu entries for code snippet support will not appear if the following string is empty 
	if s:Perl_CodeSnippets != ""
		imenu &Perl.I&dioms.-SEP6-                         :
		amenu <silent>  &Perl.&Idioms.&read\ code\ snippet        <C-C>:call Perl_CodeSnippet("r")<CR>
		amenu <silent>  &Perl.&Idioms.&write\ code\ snippet       <C-C>:call Perl_CodeSnippet("w")<CR>
		vmenu <silent>  &Perl.&Idioms.&write\ code\ snippet       <C-C>:call Perl_CodeSnippet("wv")<CR>
		amenu <silent>  &Perl.&Idioms.e&dit\ code\ snippet        <C-C>:call Perl_CodeSnippet("e")<CR>
	endif
	imenu &Perl.I&dioms.-SEP7-                         :
	"
	"---------- submenu : POSIX character classes --------------------------------------------
	"
	amenu &Perl.CharC&ls.<Tab>Perl                                    <Esc>
	amenu &Perl.CharC&ls.-Sep0-                         :
	"
	 menu &Perl.CharC&ls.[:&alnum:]										<Esc>a[:alnum:]
	 menu &Perl.CharC&ls.[:alp&ha:]										<Esc>a[:alpha:]
	 menu &Perl.CharC&ls.[:asc&ii:]										<Esc>a[:ascii:]
	 menu &Perl.CharC&ls.[:&cntrl:]										<Esc>a[:cntrl:]
	 menu &Perl.CharC&ls.[:&digit:]										<Esc>a[:digit:]
	 menu &Perl.CharC&ls.[:&graph:]										<Esc>a[:graph:]
	 menu &Perl.CharC&ls.[:&lower:]										<Esc>a[:lower:]
	 menu &Perl.CharC&ls.[:&print:]										<Esc>a[:print:]
	 menu &Perl.CharC&ls.[:pu&nct:]										<Esc>a[:punct:]
	 menu &Perl.CharC&ls.[:&space:]										<Esc>a[:space:]
	 menu &Perl.CharC&ls.[:&upper:]										<Esc>a[:upper:]
	 menu &Perl.CharC&ls.[:&word:]										<Esc>a[:word:]
	 menu &Perl.CharC&ls.[:&xdigit:]									<Esc>a[:xdigit:]
	"
	imenu &Perl.CharC&ls.[:&alnum:]										[:alnum:]
	imenu &Perl.CharC&ls.[:alp&ha:]										[:alpha:]
	imenu &Perl.CharC&ls.[:asc&ii:]										[:ascii:]
	imenu &Perl.CharC&ls.[:&cntrl:]										[:cntrl:]
	imenu &Perl.CharC&ls.[:&digit:]										[:digit:]
	imenu &Perl.CharC&ls.[:&graph:]										[:graph:]
	imenu &Perl.CharC&ls.[:&lower:]										[:lower:]
	imenu &Perl.CharC&ls.[:&print:]										[:print:]
	imenu &Perl.CharC&ls.[:pu&nct:]										[:punct:]
	imenu &Perl.CharC&ls.[:&space:]										[:space:]
	imenu &Perl.CharC&ls.[:&upper:]										[:upper:]
	imenu &Perl.CharC&ls.[:&word:]										[:word:]
	imenu &Perl.CharC&ls.[:&xdigit:]									[:xdigit:]
	"
	"
	"---------- File-Tests-Menu ----------------------------------------------------------------------
	"
	amenu &Perl.F&ile-Tests.<Tab>Perl                                    <Esc>
	amenu &Perl.F&ile-Tests.-Sep0-                         :
	"
	 menu &Perl.F&ile-Tests.exists															<Esc>a-e <Esc>a
	 menu &Perl.F&ile-Tests.has\ zero\ size											<Esc>a-z <Esc>a
	 menu &Perl.F&ile-Tests.has\ nonzero\ size									<Esc>a-s <Esc>a
	 menu &Perl.F&ile-Tests.plain\ file													<Esc>a-f <Esc>a
	 menu &Perl.F&ile-Tests.directory														<Esc>a-d <Esc>a
	 menu &Perl.F&ile-Tests.symbolic\ link											<Esc>a-l <Esc>a
	 menu &Perl.F&ile-Tests.named\ pipe													<Esc>a-p <Esc>a
	 menu &Perl.F&ile-Tests.socket															<Esc>a-S <Esc>a
	 menu &Perl.F&ile-Tests.block\ special\ file								<Esc>a-b <Esc>a
	 menu &Perl.F&ile-Tests.character\ special\ file						<Esc>a-c <Esc>a
	imenu &Perl.F&ile-Tests.exists															-e <Esc>a
	imenu &Perl.F&ile-Tests.has\ zero\ size											-z <Esc>a
	imenu &Perl.F&ile-Tests.has\ nonzero\ size									-s <Esc>a
	imenu &Perl.F&ile-Tests.plain\ file													-f <Esc>a
	imenu &Perl.F&ile-Tests.directory														-d <Esc>a
	imenu &Perl.F&ile-Tests.symbolic\ link											-l <Esc>a
	imenu &Perl.F&ile-Tests.named\ pipe													-p <Esc>a
	imenu &Perl.F&ile-Tests.socket															-S <Esc>a
	imenu &Perl.F&ile-Tests.block\ special\ file								-b <Esc>a
	imenu &Perl.F&ile-Tests.character\ special\ file						-c <Esc>a
	"
	 menu &Perl.F&ile-Tests.-SEP1-															:
	"
	 menu &Perl.F&ile-Tests.readable\ by\ effective\ UID/GID		<Esc>a-r <Esc>a
	 menu &Perl.F&ile-Tests.writable\ by\ effective\ UID/GID		<Esc>a-w <Esc>a
	 menu &Perl.F&ile-Tests.executable\ by\ effective\ UID/GID	<Esc>a-x <Esc>a
	 menu &Perl.F&ile-Tests.owned\ by\ effective\ UID						<Esc>a-o <Esc>a
	imenu &Perl.F&ile-Tests.readable\ by\ effective\ UID/GID		-r <Esc>a
	imenu &Perl.F&ile-Tests.writable\ by\ effective\ UID/GID		-w <Esc>a
	imenu &Perl.F&ile-Tests.executable\ by\ effective\ UID/GID	-x <Esc>a
	imenu &Perl.F&ile-Tests.owned\ by\ effective\ UID						-o <Esc>a
	"
	 menu &Perl.F&ile-Tests.-SEP2-																:
	"
	 menu &Perl.F&ile-Tests.readable\ by\ real\ UID/GID					<Esc>a-R <Esc>a
	 menu &Perl.F&ile-Tests.writable\ by\ real\ UID/GID					<Esc>a-W <Esc>a
	 menu &Perl.F&ile-Tests.executable\ by\ real\ UID/GID				<Esc>a-X <Esc>a
	 menu &Perl.F&ile-Tests.owned\ by\ real\ UID								<Esc>a-O <Esc>a
	"
	imenu &Perl.F&ile-Tests.readable\ by\ real\ UID/GID					-R <Esc>a
	imenu &Perl.F&ile-Tests.writable\ by\ real\ UID/GID					-W <Esc>a
	imenu &Perl.F&ile-Tests.executable\ by\ real\ UID/GID				-X <Esc>a
	imenu &Perl.F&ile-Tests.owned\ by\ real\ UID								-O <Esc>a
	"
	 menu &Perl.F&ile-Tests.-SEP3-															:
	"
	 menu &Perl.F&ile-Tests.setuid\ bit\ set										<Esc>a-u <Esc>a
	 menu &Perl.F&ile-Tests.setgid\ bit\ set										<Esc>a-g <Esc>a
	 menu &Perl.F&ile-Tests.sticky\ bit\ set										<Esc>a-k <Esc>a
	imenu &Perl.F&ile-Tests.setuid\ bit\ set										-u <Esc>a
	imenu &Perl.F&ile-Tests.setgid\ bit\ set										-g <Esc>a
	imenu &Perl.F&ile-Tests.sticky\ bit\ set										-k <Esc>a
	"
	imenu &Perl.F&ile-Tests.-SEP4-															:
	"
	 menu &Perl.F&ile-Tests.age\ since\ modification						<Esc>a-M <Esc>a
	 menu &Perl.F&ile-Tests.age\ since\ last\ access						<Esc>a-A <Esc>a
	 menu &Perl.F&ile-Tests.age\ since\ inode\ change						<Esc>a-C <Esc>a
	imenu &Perl.F&ile-Tests.age\ since\ modification						-M <Esc>a
	imenu &Perl.F&ile-Tests.age\ since\ last\ access						-A <Esc>a
	imenu &Perl.F&ile-Tests.age\ since\ inode\ change						-C <Esc>a
	"
	imenu &Perl.F&ile-Tests.-SEP5-															:
	"
	 menu &Perl.F&ile-Tests.text\ file													<Esc>a-T <Esc>a
	 menu &Perl.F&ile-Tests.binary\ file												<Esc>a-B <Esc>a
	 menu &Perl.F&ile-Tests.handle\ opened\ to\ a\ tty					<Esc>a-t <Esc>a
	imenu &Perl.F&ile-Tests.text\ file													-T <Esc>a
	imenu &Perl.F&ile-Tests.binary\ file												-B <Esc>a
	imenu &Perl.F&ile-Tests.handle\ opened\ to\ a\ tty					-t <Esc>a
	"
	"---------- Special-Variables -------------------------------------------------------------
	"
	amenu &Perl.Spec-&Var.<Tab>Perl                                    <Esc>
	amenu &Perl.Spec-&Var.-Sep0-                         :
	"
	"-------- submenu errors -------------------------------------------------
	amenu &Perl.Spec-&Var.&errors.<Tab>Perl                                    <Esc>
	amenu &Perl.Spec-&Var.&errors.-Sep0-                         :
	 menu &Perl.Spec-&Var.&errors.$CHILD_ERROR      					<Esc>a$CHILD_ERROR
	 menu &Perl.Spec-&Var.&errors.$ERRNO            					<Esc>a$ERRNO
	 menu &Perl.Spec-&Var.&errors.$EVAL_ERROR       					<Esc>a$EVAL_ERROR
	 menu &Perl.Spec-&Var.&errors.$EXTENDED_OS_ERROR					<Esc>a$EXTENDED_OS_ERROR
	 menu &Perl.Spec-&Var.&errors.$OS_ERRNO         					<Esc>a$OS_ERRNO
	 menu &Perl.Spec-&Var.&errors.$WARNING          					<Esc>a$WARNING
	imenu &Perl.Spec-&Var.&errors.$CHILD_ERROR      					$CHILD_ERROR
	imenu &Perl.Spec-&Var.&errors.$ERRNO            					$ERRNO
	imenu &Perl.Spec-&Var.&errors.$EVAL_ERROR       					$EVAL_ERROR
	imenu &Perl.Spec-&Var.&errors.$EXTENDED_OS_ERROR					$EXTENDED_OS_ERROR
	imenu &Perl.Spec-&Var.&errors.$OS_ERRNO         					$OS_ERRNO
	imenu &Perl.Spec-&Var.&errors.$WARNING          					$WARNING

	"-------- submenu files -------------------------------------------------
	amenu &Perl.Spec-&Var.&files.<Tab>Perl                                    <Esc>
	amenu &Perl.Spec-&Var.&files.-Sep0-                         :
	 menu &Perl.Spec-&Var.&files.$AUTOFLUSH            				<Esc>a$AUTOFLUSH
	 menu &Perl.Spec-&Var.&files.$OUTPUT_AUTOFLUSH     				<Esc>a$OUTPUT_AUTOFLUSH
	 menu &Perl.Spec-&Var.&files.$FORMAT_LINES_LEFT    				<Esc>a$FORMAT_LINES_LEFT
	 menu &Perl.Spec-&Var.&files.$FORMAT_LINES_PER_PAGE				<Esc>a$FORMAT_LINES_PER_PAGE
	 menu &Perl.Spec-&Var.&files.$FORMAT_NAME          				<Esc>a$FORMAT_NAME
	 menu &Perl.Spec-&Var.&files.$FORMAT_PAGE_NUMBER   				<Esc>a$FORMAT_PAGE_NUMBER
	 menu &Perl.Spec-&Var.&files.$FORMAT_TOP_NAME      				<Esc>a$FORMAT_TOP_NAME
	imenu &Perl.Spec-&Var.&files.$AUTOFLUSH            				$AUTOFLUSH
	imenu &Perl.Spec-&Var.&files.$OUTPUT_AUTOFLUSH     				$OUTPUT_AUTOFLUSH
	imenu &Perl.Spec-&Var.&files.$FORMAT_LINES_LEFT    				$FORMAT_LINES_LEFT
	imenu &Perl.Spec-&Var.&files.$FORMAT_LINES_PER_PAGE				$FORMAT_LINES_PER_PAGE
	imenu &Perl.Spec-&Var.&files.$FORMAT_NAME          				$FORMAT_NAME
	imenu &Perl.Spec-&Var.&files.$FORMAT_PAGE_NUMBER   				$FORMAT_PAGE_NUMBER
	imenu &Perl.Spec-&Var.&files.$FORMAT_TOP_NAME      				$FORMAT_TOP_NAME

	"-------- submenu IDs -------------------------------------------------
	amenu &Perl.Spec-&Var.&IDs.<Tab>Perl                                    <Esc>
	amenu &Perl.Spec-&Var.&IDs.-Sep0-                         :
	 menu &Perl.Spec-&Var.&IDs.$PID               						<Esc>a$PID
	 menu &Perl.Spec-&Var.&IDs.$PROCESS_ID        						<Esc>a$PROCESS_ID
	 menu &Perl.Spec-&Var.&IDs.$GID               						<Esc>a$GID
	 menu &Perl.Spec-&Var.&IDs.$REAL_GROUP_ID     						<Esc>a$REAL_GROUP_ID
	 menu &Perl.Spec-&Var.&IDs.$EGID              						<Esc>a$EGID
	 menu &Perl.Spec-&Var.&IDs.$EFFECTIVE_GROUP_ID						<Esc>a$EFFECTIVE_GROUP_ID
	imenu &Perl.Spec-&Var.&IDs.$PID               						$PID
	imenu &Perl.Spec-&Var.&IDs.$PROCESS_ID        						$PROCESS_ID
	imenu &Perl.Spec-&Var.&IDs.$GID               						$GID
	imenu &Perl.Spec-&Var.&IDs.$REAL_GROUP_ID     						$REAL_GROUP_ID
	imenu &Perl.Spec-&Var.&IDs.$EGID              						$EGID
	imenu &Perl.Spec-&Var.&IDs.$EFFECTIVE_GROUP_ID						$EFFECTIVE_GROUP_ID

	"-------- submenu IO -------------------------------------------------
	amenu &Perl.Spec-&Var.I&O.<Tab>Perl                                    <Esc>
	amenu &Perl.Spec-&Var.I&O.-Sep0-                         :
	 menu &Perl.Spec-&Var.I&O.$INPUT_LINE_NUMBER      				<Esc>a$INPUT_LINE_NUMBER
	 menu &Perl.Spec-&Var.I&O.$NR                     				<Esc>a$NR
	imenu &Perl.Spec-&Var.I&O.$INPUT_LINE_NUMBER      				$INPUT_LINE_NUMBER
	imenu &Perl.Spec-&Var.I&O.$NR                     				$NR

	imenu &Perl.Spec-&Var.I&O.-SEP1-      		            :

	 menu &Perl.Spec-&Var.I&O.$INPUT_RECORD_SEPARATOR 				<Esc>a$INPUT_RECORD_SEPARATOR
	 menu &Perl.Spec-&Var.I&O.$RS                     				<Esc>a$RS
	 menu &Perl.Spec-&Var.I&O.$LIST_SEPARATOR         				<Esc>a$LIST_SEPARATOR
	 menu &Perl.Spec-&Var.I&O.$OUTPUT_FIELD_SEPARATOR 				<Esc>a$OUTPUT_FIELD_SEPARATOR
	 menu &Perl.Spec-&Var.I&O.$OFS                    				<Esc>a$OFS
	 menu &Perl.Spec-&Var.I&O.$OUTPUT_RECORD_SEPARATOR				<Esc>a$OUTPUT_RECORD_SEPARATOR
	 menu &Perl.Spec-&Var.I&O.$ORS                    				<Esc>a$ORS
	 menu &Perl.Spec-&Var.I&O.$SUBSCRIPT_SEPARATOR    				<Esc>a$SUBSCRIPT_SEPARATOR
	 menu &Perl.Spec-&Var.I&O.$SUBSEP                 				<Esc>a$SUBSEP
	imenu &Perl.Spec-&Var.I&O.$INPUT_RECORD_SEPARATOR 				$INPUT_RECORD_SEPARATOR
	imenu &Perl.Spec-&Var.I&O.$RS                     				$RS
	imenu &Perl.Spec-&Var.I&O.$LIST_SEPARATOR         				$LIST_SEPARATOR
	imenu &Perl.Spec-&Var.I&O.$OUTPUT_FIELD_SEPARATOR 				$OUTPUT_FIELD_SEPARATOR
	imenu &Perl.Spec-&Var.I&O.$OFS                    				$OFS
	imenu &Perl.Spec-&Var.I&O.$OUTPUT_RECORD_SEPARATOR				$OUTPUT_RECORD_SEPARATOR
	imenu &Perl.Spec-&Var.I&O.$ORS                    				$ORS
	imenu &Perl.Spec-&Var.I&O.$SUBSCRIPT_SEPARATOR    				$SUBSCRIPT_SEPARATOR
	imenu &Perl.Spec-&Var.I&O.$SUBSEP                 				$SUBSEP

	"-------- submenu regexp -------------------------------------------------
	amenu &Perl.Spec-&Var.&regexp.<Tab>Perl                                    <Esc>
	amenu &Perl.Spec-&Var.&regexp.-Sep0-                         :
	 menu &Perl.Spec-&Var.&regexp.$digits                 		<Esc>a$digits
	 menu &Perl.Spec-&Var.&regexp.@LAST_MATCH_END         		<Esc>a@LAST_MATCH_END
	 menu &Perl.Spec-&Var.&regexp.@LAST_MATCH_START       		<Esc>a@LAST_MATCH_START
	 menu &Perl.Spec-&Var.&regexp.$LAST_PAREN_MATCH       		<Esc>a$LAST_PAREN_MATCH
	 menu &Perl.Spec-&Var.&regexp.$LAST_REGEXP_CODE_RESULT		<Esc>a$LAST_REGEXP_CODE_RESULT
	 menu &Perl.Spec-&Var.&regexp.$MATCH                  		<Esc>a$MATCH
	 menu &Perl.Spec-&Var.&regexp.$POSTMATCH              		<Esc>a$POSTMATCH
	 menu &Perl.Spec-&Var.&regexp.$PREMATCH               		<Esc>a$PREMATCH
	imenu &Perl.Spec-&Var.&regexp.$digits                 		$digits
	imenu &Perl.Spec-&Var.&regexp.@LAST_MATCH_END         		@LAST_MATCH_END
	imenu &Perl.Spec-&Var.&regexp.@LAST_MATCH_START       		@LAST_MATCH_START
	imenu &Perl.Spec-&Var.&regexp.$LAST_PAREN_MATCH       		$LAST_PAREN_MATCH
	imenu &Perl.Spec-&Var.&regexp.$LAST_REGEXP_CODE_RESULT		$LAST_REGEXP_CODE_RESULT
	imenu &Perl.Spec-&Var.&regexp.$MATCH                  		$MATCH
	imenu &Perl.Spec-&Var.&regexp.$POSTMATCH              		$POSTMATCH
	imenu &Perl.Spec-&Var.&regexp.$PREMATCH               		$PREMATCH

	 menu &Perl.Spec-&Var.$BASETIME      					<Esc>a$BASETIME
	 menu &Perl.Spec-&Var.$PERL_VERSION  					<Esc>a$PERL_VERSION
	 menu &Perl.Spec-&Var.$PROGRAM_NAME  					<Esc>a$PROGRAM_NAME
	 menu &Perl.Spec-&Var.$OSNAME       					<Esc>a$OSNAME
	 menu &Perl.Spec-&Var.$SYSTEM_FD_MAX 					<Esc>a$SYSTEM_FD_MAX
	 menu &Perl.Spec-&Var.$ENV{\ }			 					<Esc>a$ENV{}<ESC>i
	 menu &Perl.Spec-&Var.$INC{\ }			 					<Esc>a$INC{}<ESC>i
	 menu &Perl.Spec-&Var.$SIG{\ }			 					<Esc>a$SIG{}<ESC>i
	imenu &Perl.Spec-&Var.$BASETIME      					$BASETIME
	imenu &Perl.Spec-&Var.$PERL_VERSION  					$PERL_VERSION
	imenu &Perl.Spec-&Var.$PROGRAM_NAME  					$PROGRAM_NAME
	imenu &Perl.Spec-&Var.$OSNAME       					$OSNAME
	imenu &Perl.Spec-&Var.$SYSTEM_FD_MAX 					$SYSTEM_FD_MAX
	imenu &Perl.Spec-&Var.$ENV{\ }			 					$ENV{}<ESC>i
	imenu &Perl.Spec-&Var.$INC{\ }			 					$INC{}<ESC>i
	imenu &Perl.Spec-&Var.$SIG{\ }			 					$SIG{}<ESC>i
	"
	"---------- submenu : POSIX signals --------------------------------------
	"
	amenu &Perl.Spec-&Var.POSIX\ signals.<Tab>Perl                                    <Esc>
	amenu &Perl.Spec-&Var.POSIX\ signals.-Sep0-                         :
	 menu &Perl.Spec-&Var.POSIX\ signals.HUP 		<Esc>aHUP
	 menu &Perl.Spec-&Var.POSIX\ signals.INT 		<Esc>aINT
	 menu &Perl.Spec-&Var.POSIX\ signals.QUIT		<Esc>aQUIT
	 menu &Perl.Spec-&Var.POSIX\ signals.ILL 		<Esc>aILL
	 menu &Perl.Spec-&Var.POSIX\ signals.ABRT		<Esc>aABRT
	 menu &Perl.Spec-&Var.POSIX\ signals.FPE 		<Esc>aFPE
	 menu &Perl.Spec-&Var.POSIX\ signals.KILL		<Esc>aKILL
	 menu &Perl.Spec-&Var.POSIX\ signals.SEGV		<Esc>aSEGV
	 menu &Perl.Spec-&Var.POSIX\ signals.PIPE		<Esc>aPIPE
	 menu &Perl.Spec-&Var.POSIX\ signals.ALRM		<Esc>aALRM
	 menu &Perl.Spec-&Var.POSIX\ signals.TERM		<Esc>aTERM
	 menu &Perl.Spec-&Var.POSIX\ signals.USR1		<Esc>aUSR1
	 menu &Perl.Spec-&Var.POSIX\ signals.USR2		<Esc>aUSR2
	 menu &Perl.Spec-&Var.POSIX\ signals.CHLD		<Esc>aCHLD
	 menu &Perl.Spec-&Var.POSIX\ signals.CONT		<Esc>aCONT
	 menu &Perl.Spec-&Var.POSIX\ signals.STOP		<Esc>aSTOP
	 menu &Perl.Spec-&Var.POSIX\ signals.TSTP		<Esc>aTSTP
	 menu &Perl.Spec-&Var.POSIX\ signals.TTIN		<Esc>aTTIN
	 menu &Perl.Spec-&Var.POSIX\ signals.TTOU		<Esc>aTTOU
	"
	imenu &Perl.Spec-&Var.POSIX\ signals.HUP 		HUP
	imenu &Perl.Spec-&Var.POSIX\ signals.INT 		INT
	imenu &Perl.Spec-&Var.POSIX\ signals.QUIT		QUIT
	imenu &Perl.Spec-&Var.POSIX\ signals.ILL 		ILL
	imenu &Perl.Spec-&Var.POSIX\ signals.ABRT		ABRT
	imenu &Perl.Spec-&Var.POSIX\ signals.FPE 		FPE
	imenu &Perl.Spec-&Var.POSIX\ signals.KILL		KILL
	imenu &Perl.Spec-&Var.POSIX\ signals.SEGV		SEGV
	imenu &Perl.Spec-&Var.POSIX\ signals.PIPE		PIPE
	imenu &Perl.Spec-&Var.POSIX\ signals.ALRM		ALRM
	imenu &Perl.Spec-&Var.POSIX\ signals.TERM		TERM
	imenu &Perl.Spec-&Var.POSIX\ signals.USR1		USR1
	imenu &Perl.Spec-&Var.POSIX\ signals.USR2		USR2
	imenu &Perl.Spec-&Var.POSIX\ signals.CHLD		CHLD
	imenu &Perl.Spec-&Var.POSIX\ signals.CONT		CONT
	imenu &Perl.Spec-&Var.POSIX\ signals.STOP		STOP
	imenu &Perl.Spec-&Var.POSIX\ signals.TSTP		TSTP
	imenu &Perl.Spec-&Var.POSIX\ signals.TTIN		TTIN
	imenu &Perl.Spec-&Var.POSIX\ signals.TTOU		TTOU
	"
	imenu &Perl.Spec-&Var.-SEP2-      		              	      :

	 menu &Perl.Spec-&Var.\'IGNORE\' 														<Esc>a'IGNORE'
	 menu &Perl.Spec-&Var.\'DEFAULT\' 													<Esc>a'DEFAULT'
	imenu &Perl.Spec-&Var.\'IGNORE\' 														'IGNORE'
	imenu &Perl.Spec-&Var.\'DEFAULT\' 													'DEFAULT'

	imenu &Perl.Spec-&Var.-SEP3-      		              	      :
	 menu &Perl.Spec-&Var.use\ English; 												<ESC><ESC>ouse English;

	"
	"---------- Run-Menu ----------------------------------------------------------------------
	"
	amenu &Perl.&Run.<Tab>Perl                                    <Esc>
	amenu &Perl.&Run.-Sep0-                         :
	"
	"   run the script from the local directory 
	"   ( the one which is being edited; other versions may exist elsewhere ! )
	" 
	amenu &Perl.&Run.update\ file,\ &run\ script<Tab><Ctrl><F9>   <C-C>:call Perl_Run(0)<CR>
	"
	" The menu entrie 'run with pager' will not appear if the following string is empty 
	if s:Perl_Pager != ""
		amenu &Perl.&Run.update\ file,\ run\ with\ &pager<Tab><F9>    <C-C>:call Perl_Run(1)<CR>
	endif
	"
	"   run the script from the local directory / only syntax check
	"   ( the one which is being edited; other versions may exist elsewhere ! )
	" 
	amenu &Perl.&Run.update\ file,\ run\ &syntax\ check<Tab><Alt><F9>   <C-C>:call Perl_SyntaxCheck()<CR><CR>
	"
	"   set execution right only for the user ( may be user root ! )
	"
	amenu <silent> &Perl.&Run.make\ script\ e&xecutable                <C-C>:!chmod -c u+x %<CR>
	amenu <silent> &Perl.&Run.command\ line\ &arguments                <C-C>:call Perl_Arguments()<CR>
	amenu          &Perl.&Run.-SEP2-      		              	         :

	amenu <silent> &Perl.&Run.read\ perl&doc<Tab><Shift><F1>            <C-C>:call Perl_perldoc_dialog()<CR><CR>
	"
	amenu          &Perl.&Run.-SEP3-      		              	         :
	amenu <silent> &Perl.&Run.&hardcopy\ buffer\ to\ FILENAME\.ps      <C-C>:call Perl_Hardcopy("n")<CR>
	vmenu <silent> &Perl.&Run.hard&copy\ part\ to\ FILENAME\.part\.ps  <C-C>:call Perl_Hardcopy("v")<CR>
	imenu          &Perl.&Run.-SEP4-                                   :
	amenu <silent> &Perl.&Run.se&ttings\ and\ hot\ keys                <C-C>:call Perl_Settings()<CR>
	"
	"
endif
"
"--------------------------------------------------------------------------------------------
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
"  Comments : classified comments
"------------------------------------------------------------------------------
function! Perl_CommentClassified (class)
  	put = '# :'.a:class.':'.strftime(\"%x\").':'.s:Perl_AuthorRef.': '
endfunction
"
"------------------------------------------------------------------------------
"  Substitute tags
"------------------------------------------------------------------------------
function! Perl_SubstituteTag( pos1, pos2, tag, replacement )
	" 
	" loop over marked block
	" 
	let	linenumber=a:pos1
	while linenumber <= a:pos2
		let line=getline(linenumber)
		" 
		" loop for multiple tags in one line
		" 
		let	start=0
		while match(line,a:tag,start)>=0				" do we have a tag ?
			let frst=match(line,a:tag,start)
			let last=matchend(line,a:tag,start)
			if frst!=-1
				let part1=strpart(line,0,frst)
				let part2=strpart(line,last)
				let line=part1.a:replacement.part2
				"
				" next search starts after the replacement to suppress recursion
				" 
				let start=strlen(part1)+strlen(a:replacement)
			endif
			exe linenumber
			exe "d"
			put! =line
		endwhile
		let	linenumber=linenumber+1
	endwhile

endfunction    " ----------  end of function  Perl_SubstituteTag  ----------
"
"------------------------------------------------------------------------------
"  Comments : Insert Template Files
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
		" 
		call  Perl_SubstituteTag( pos1, pos2, '|FILENAME|',        expand("%:t")        )
		call  Perl_SubstituteTag( pos1, pos2, '|DATE|',            strftime("%x %X %Z") )
		call  Perl_SubstituteTag( pos1, pos2, '|TIME|',            strftime("%X")       )
		call  Perl_SubstituteTag( pos1, pos2, '|YEAR|',            strftime("%Y")       )
		call  Perl_SubstituteTag( pos1, pos2, '|AUTHOR|',          s:Perl_AuthorName       )
		call  Perl_SubstituteTag( pos1, pos2, '|EMAIL|',           s:Perl_Email            )
		call  Perl_SubstituteTag( pos1, pos2, '|AUTHORREF|',       s:Perl_AuthorRef        )
		call  Perl_SubstituteTag( pos1, pos2, '|PROJECT|',         s:Perl_Project          )
		call  Perl_SubstituteTag( pos1, pos2, '|COMPANY|',         s:Perl_Company          )
		call  Perl_SubstituteTag( pos1, pos2, '|COPYRIGHTHOLDER|', s:Perl_CopyrightHolder  )
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

	else
		echohl WarningMsg | echo 'template file '.templatefile.' does not exist or is not readable'| echohl None
	endif
	return
endfunction    " ----------  end of function  Perl_CommentTemplates  ----------
"
"------------------------------------------------------------------------------
"  Comments : vim modeline
"------------------------------------------------------------------------------
function! Perl_CommentVimModeline ()
  	put = '# vim: set tabstop='.&tabstop.': set shiftwidth='.&shiftwidth.': '
endfunction    " ----------  end of function Perl_CommentVimModeline  ----------
"
"------------------------------------------------------------------------------
"  Statements : subroutine
"------------------------------------------------------------------------------
function! Perl_CodeFunction ()
	if has("gui_running")
		let	identifier=inputdialog("subroutine name", "f" )
	else
		let	identifier=input("subroutine name : ", "f" )
	endif
	if identifier==""
		let	identifier	= "f"
	endif
  let zz=    "sub ".identifier."\n{\n\tmy\t$par1\t= shift;\n\t\n\treturn ;\n}"
  let zz= zz."\t# ----------  end of subroutine ".identifier."  ----------" 
	put =zz
	normal 3j
endfunction
"
"------------------------------------------------------------------------------
"  Statements : do-while
"------------------------------------------------------------------------------
"
function! Perl_DoWhile (arg)

	if a:arg=='a'
		let zz=    "do\n{\n\t\n}\nwhile (  );"
		let zz= zz."\t\t\t\t# -----  end do-while  -----\n"
		put =zz
		normal	=4+
	endif

	if a:arg=='v'
		let zz=    "do\n{"
		:'<put! =zz
		let zz=    "}\nwhile (  );\t\t\t\t# -----  end do-while  -----\n"
		:'>put =zz
		:'<-2
		:exe "normal =".(line("'>")-line(".")+3)."+"
		:'>+2
	endif

endfunction
"
"------------------------------------------------------------------------------
"  Perl-Idioms : CodeOpenRead
"------------------------------------------------------------------------------
function! Perl_CodeOpenRead ()

	if has("gui_running")
		let	filehandle=inputdialog("input file handle", "INFILE")
	else
		let	filehandle=input("input file handle : ", "INFILE" )
	endif
	
	if filehandle==""
		let	filehandle	= "INFILE"
	endif
	
	let filename=filehandle."_file_name"

	let zz=    "my\t$".filename." = \'\';\t\t# input file name\n\n"
	let zz= zz."open ( ".filehandle.", \'<\', $".filename." )\n"
	let zz= zz."\tor die \"$0 : failed to open input file $".filename." : $!\\n\";\n\n\n"
	let zz= zz."close ( ".filehandle." );\t\t\t# close input file\n"
	exe ":imenu &Perl.I&dioms.<".filehandle.">      <".filehandle."><ESC>a"
	put =zz
	normal =6+
	normal f'
endfunction
"
"------------------------------------------------------------------------------
"  Perl-Idioms : CodeOpenWrite
"------------------------------------------------------------------------------
function! Perl_CodeOpenWrite ()

	if has("gui_running")
		let	filehandle=inputdialog("output file handle", "OUTFILE")
	else
		let	filehandle=input("output file handle : ", "OUTFILE" )
	endif
	
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
	exe ":imenu &Perl.I&dioms.print\\ ".filehandle."\\ \"\\\\n\";       print ".filehandle." \"\\n\";<ESC>3hi"
	normal f'
endfunction
"
"------------------------------------------------------------------------------
"  Perl-Idioms : CodeOpenPipe
"------------------------------------------------------------------------------
function! Perl_CodeOpenPipe ()

	if has("gui_running")
		let	filehandle=inputdialog("pipe handle", "PIPE")
	else
		let	filehandle=input("pipe handle : ", "PIPE" )
	endif

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
	normal f'
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
	let settings = settings."author name  :  ".s:Perl_AuthorName."\n"
	let settings = settings."author ref  :  ".s:Perl_AuthorRef."\n"
	let settings = settings."autho  email  :  ".s:Perl_Email."\n"
	let settings = settings."company  :  ".s:Perl_Company."\n"
	let settings = settings."project  :  ".s:Perl_Project."\n"
	let settings = settings."copyright holder  :  ".s:Perl_CopyrightHolder."\n"
	let settings = settings."code snippet directory  :  ".s:Perl_CodeSnippets."\n"
	let settings = settings."template directory  :  ".s:Perl_Template_Directory."\n"
	if exists("g:Perl_Dictionary_File")
		let settings = settings."dictionary file  :  ".g:Perl_Dictionary_File."\n"
	endif
	let settings = settings."pager  :  ".s:Perl_Pager."\n"
	let settings = settings."\n"
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
		if has("gui_running")
			aunmenu Perl
		endif

		let s:Perl_Active = 0
	endif

	call Perl_CreateUnLoadMenuEntries ()
endfunction
"
"------------------------------------------------------------------------------
" 
call Perl_CreateUnLoadMenuEntries()			" create the menu entry in the GVIM tool menu
if s:Perl_LoadMenus == "yes"
	call Perl_Handle()											" load the menus
endif
	
nmap    <silent>  <Leader>lps             :call Perl_Handle()<CR>
nmap    <silent>  <Leader>ups             :call Perl_Handle()<CR>
"
" vim:set tabstop=2: 
