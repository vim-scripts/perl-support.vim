"###############################################################################################
"
"       Filename:  perl-support.vim
"
"    Description:  Write, compile and run Perl-scripts using menus and key mappings.
"
"       Features:  - insert various types of comments
"                  - insert complete but empty statements (e.g. 'if {} else {}' )
"                  - insert often used code snippets (e.g. declarations, 
"                    the opening of files, .. )
"                  - insert the names of file tests, character classes, 
"                    special Perl-variables and POSIX-signals
"                  - read, write, maintain your own code snippets in a separate
"                    directory
"                  - run scripts or run syntax check from within the editor
"                  - show compilation errors in a quickfix window; navigate with hotkeys 
"                  - read perldoc for functions, modules and FAQs
"                 
"  Configuration:  There are some personal details which should be configured 
"                  (see the files README.perlsupport and perlsupport.txt).
"
"         Author:  Dr.-Ing. Fritz Mehner <mehner@fh-swf.de>
"
"        Version:  see variable  g:Perl_Version  below 
"       Revision:  09.12.2004
"        Created:  09.07.2001
"        License:  GPL (GNU Public License)
"        Credits:  see perlsupport.txt
"
"------------------------------------------------------------------------------
" 
" Prevent duplicate loading: 
" 
if exists("g:Perl_Version") || &cp
 finish
endif
let g:Perl_Version= "2.4"
"        
"###############################################################################################
"
"  Global variables (with default values) which can be overridden.
"
"  Key word completion is enabled by the filetype plugin 'perl.vim'
"  g:Perl_Dictionary_File  must be global
"          
if has('win32')
	let root_dir	= $VIM.'/vimfiles/'			" Windows
else
	let root_dir	= $HOME.'/.vim/'				" Linux/Unix
endif
"          
if !exists("g:Perl_Dictionary_File")
	let g:Perl_Dictionary_File       = root_dir.'wordlists/perl.list'
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
let s:Perl_CodeSnippets            = root_dir.'codesnippets-perl/'
let s:Perl_Template_Directory      = root_dir.'plugin/templates/'
let s:Perl_Template_File           = 'perl-file-header'
let s:Perl_Template_Module         = 'perl-module-header'
let s:Perl_Template_Frame          = 'perl-frame'
let s:Perl_Template_Function       = 'perl-function-description'
let s:Perl_MenuHeader              = 'yes'
let s:Perl_PerlModuleList          = root_dir.'plugin/perl-modules.list'
let s:Perl_PerlModuleListGenerator = root_dir.'plugin/pmdesc3 -s -t36 > '.s:Perl_PerlModuleList
let s:Perl_OutputGvim              = "vim"
let s:Perl_XtermDefaults           = "-fa courier -fs 12 -geometry 80x24"
let s:Perl_Debugger                = "perl"
"
"------------------------------------------------------------------------------
"
"  Look for global variables (if any), to override the defaults.
"  
function! Perl_CheckGlobal ( name )
	if exists('g:'.a:name)
		exe 'let s:'.a:name.'  = g:'.a:name
	endif
endfunction
"
call Perl_CheckGlobal("Perl_AuthorName             ")
call Perl_CheckGlobal("Perl_AuthorRef              ")
call Perl_CheckGlobal("Perl_Email                  ")
call Perl_CheckGlobal("Perl_Company                ")
call Perl_CheckGlobal("Perl_Project                ")
call Perl_CheckGlobal("Perl_CopyrightHolder        ")
call Perl_CheckGlobal("Perl_Root                   ")
call Perl_CheckGlobal("Perl_LoadMenus              ")
call Perl_CheckGlobal("Perl_CodeSnippets           ")
call Perl_CheckGlobal("Perl_Template_Directory     ")
call Perl_CheckGlobal("Perl_Template_File          ")
call Perl_CheckGlobal("Perl_Template_Module        ")
call Perl_CheckGlobal("Perl_Template_Frame         ")
call Perl_CheckGlobal("Perl_Template_Function      ")
call Perl_CheckGlobal("Perl_MenuHeader             ")
call Perl_CheckGlobal("Perl_PerlModuleList         ")
call Perl_CheckGlobal("Perl_PerlModuleListGenerator")
call Perl_CheckGlobal("Perl_OutputGvim             ")
call Perl_CheckGlobal("Perl_XtermDefaults          ")
call Perl_CheckGlobal("Perl_Debugger               ")
"
"
"------------------------------------------------------------------------------
"  Perl Menu Initialization
"------------------------------------------------------------------------------
"
let	s:Perl_POD_cut ='<CR>=pod  <CR><CR><CR><CR>=cut  #  back to Perl<CR>'
let	s:Perl_POD_List='<CR>=over 2<CR><CR>=item *<CR><CR><CR><CR>=item *<CR><CR><CR><CR>=back  #  back to Perl<CR><CR>'
let	s:Perl_POD_html='<CR>=begin  html<CR><CR><CR><CR>=end    html  #  back to Perl<CR>'
let	s:Perl_POD_man ='<CR>=begin  man<CR><CR><CR><CR>=end    man  #  back to Perl<CR>'
let	s:Perl_POD_text='<CR>=begin  text<CR><CR><CR><CR>=end    text  #  back to Perl<CR>'
"
" set default geometry if not specified 
" 
if match( s:Perl_XtermDefaults, "-geometry\\s\\+\\d\\+x\\d\\+" ) < 0
	let s:Perl_XtermDefaults	= s:Perl_XtermDefaults." -geometry 80x24"
endif
"
function!	Perl_InitMenu ()
	"
	if has("gui_running")

		if s:Perl_Root != ""
			if s:Perl_MenuHeader == "yes"
				exe "amenu ".s:Perl_Root.'<Tab>Perl     <Esc>'
				exe "amenu ".s:Perl_Root.'-Sep0-        :'
			endif
		endif
		"
		"---------- Comments-Menu ----------------------------------------------------------------------
		"
		if s:Perl_MenuHeader == "yes"
			exe "amenu ".s:Perl_Root.'&Comments.Comments<Tab>Perl     <Esc>'
			exe "amenu ".s:Perl_Root.'&Comments.-Sep0-        :'
		endif

		exe "amenu           ".s:Perl_Root.'&Comments.&Line\ End\ Comm\.                <Esc><Esc>A<Tab><Tab><Tab>#<Space>'
		exe "vmenu <silent>  ".s:Perl_Root.'&Comments.&Line\ End\ Comm\.                <Esc><Esc>:call Perl_MultiLineEndComments()<CR>A'
		exe "amenu <silent>  ".s:Perl_Root.'&Comments.&Frame\ Comm\.          <Esc><Esc>:call Perl_CommentTemplates("frame")<CR>'
		exe "amenu <silent>  ".s:Perl_Root.'&Comments.F&unction\ Descr\.      <Esc><Esc>:call Perl_CommentTemplates("function")<CR>'
		exe "amenu <silent>  ".s:Perl_Root.'&Comments.File\ &Header\ (\.pl)   <Esc><Esc>:call Perl_CommentTemplates("header")<CR>'
		exe "amenu <silent>  ".s:Perl_Root.'&Comments.File\ &Header\ (\.pm)   <Esc><Esc>:call Perl_CommentTemplates("module")<CR>'

		exe "amenu ".s:Perl_Root.'&Comments.-SEP1-                     :'
		"
		exe "amenu <silent>  ".s:Perl_Root."&Comments.&code->comment       <Esc><Esc>:s/^/#/<CR><Esc>:nohlsearch<CR>"
		exe "vmenu <silent>  ".s:Perl_Root."&Comments.&code->comment       <Esc><Esc>:'<,'>s/^/#/<CR><Esc>:nohlsearch<CR>"
		exe "amenu <silent>  ".s:Perl_Root."&Comments.c&omment->code       <Esc><Esc>:s/^\\(\\s*\\)#/\\1/<CR><Esc>:nohlsearch<CR>"
		exe "vmenu <silent>  ".s:Perl_Root."&Comments.c&omment->code       <Esc><Esc>:'<,'>s/^\\(\\s*\\)#/\\1/<CR><Esc>:nohlsearch<CR>"
		"
		exe "amenu ".s:Perl_Root.'&Comments.-SEP2-               :'
		"
		exe " menu ".s:Perl_Root.'&Comments.&Date                i<C-R>=strftime("%x")<CR>'
		exe "imenu ".s:Perl_Root.'&Comments.&Date                 <C-R>=strftime("%x")<CR>'
		exe " menu ".s:Perl_Root.'&Comments.Date\ &Time          i<C-R>=strftime("%x %X %Z")<CR>'
		exe "imenu ".s:Perl_Root.'&Comments.Date\ &Time           <C-R>=strftime("%x %X %Z")<CR>'



		exe "amenu ".s:Perl_Root.'&Comments.-SEP3-                     :'
		"
		"--------- submenu : KEYWORD -------------------------------------------------------------
		"
		if s:Perl_MenuHeader == "yes"
			exe "amenu ".s:Perl_Root.'&Comments.#:&KEYWORD\:.Comments-1<Tab>Perl   <Esc>'
			exe "amenu ".s:Perl_Root.'&Comments.#:&KEYWORD\:.-Sep0-      :'
		endif
		"
		exe "amenu ".s:Perl_Root.'&Comments.#:&KEYWORD\:.&BUG          <Esc><Esc>$<Esc>:call Perl_CommentClassified("BUG")     <CR>kJA'
		exe "amenu ".s:Perl_Root.'&Comments.#:&KEYWORD\:.&TODO         <Esc><Esc>$<Esc>:call Perl_CommentClassified("TODO")    <CR>kJA'
		exe "amenu ".s:Perl_Root.'&Comments.#:&KEYWORD\:.T&RICKY       <Esc><Esc>$<Esc>:call Perl_CommentClassified("TRICKY")  <CR>kJA'
		exe "amenu ".s:Perl_Root.'&Comments.#:&KEYWORD\:.&WARNING      <Esc><Esc>$<Esc>:call Perl_CommentClassified("WARNING") <CR>kJA'
		exe "amenu ".s:Perl_Root.'&Comments.#:&KEYWORD\:.&new\ keyword <Esc><Esc>$<Esc>:call Perl_CommentClassified("")        <CR>kJf:a'
		"
		"
		"----- Submenu :  Tags  ----------------------------------------------------------
		"
		if s:Perl_MenuHeader == "yes"
			exe "amenu ".s:Perl_Root.'&Comments.Ta&gs\ (plugin).Comments-2<Tab>Perl   <Esc>'
			exe "amenu ".s:Perl_Root.'&Comments.Ta&gs\ (plugin).-Sep0-      :'
		endif
		"
		exe "amenu  ".s:Perl_Root.'&Comments.Ta&gs\ (plugin).&AUTHOR           a'.s:Perl_AuthorName."<Esc>"
		exe "amenu  ".s:Perl_Root.'&Comments.Ta&gs\ (plugin).AUTHOR&REF        a'.s:Perl_AuthorRef."<Esc>"
		exe "amenu  ".s:Perl_Root.'&Comments.Ta&gs\ (plugin).&COMPANY          a'.s:Perl_Company."<Esc>"
		exe "amenu  ".s:Perl_Root.'&Comments.Ta&gs\ (plugin).C&OPYRIGHTHOLDER  a'.s:Perl_CopyrightHolder."<Esc>"
		exe "amenu  ".s:Perl_Root.'&Comments.Ta&gs\ (plugin).&EMAIL            a'.s:Perl_Email."<Esc>"
		exe "amenu  ".s:Perl_Root.'&Comments.Ta&gs\ (plugin).&PROJECT          a'.s:Perl_Project."<Esc>"

		exe "imenu  ".s:Perl_Root.'&Comments.Ta&gs\ (plugin).&AUTHOR           <Esc>a'.s:Perl_AuthorName
		exe "imenu  ".s:Perl_Root.'&Comments.Ta&gs\ (plugin).AUTHOR&REF        <Esc>a'.s:Perl_AuthorRef
		exe "imenu  ".s:Perl_Root.'&Comments.Ta&gs\ (plugin).&COMPANY          <Esc>a'.s:Perl_Company
		exe "imenu  ".s:Perl_Root.'&Comments.Ta&gs\ (plugin).C&OPYRIGHTHOLDER  <Esc>a'.s:Perl_CopyrightHolder
		exe "imenu  ".s:Perl_Root.'&Comments.Ta&gs\ (plugin).&EMAIL            <Esc>a'.s:Perl_Email
		exe "imenu  ".s:Perl_Root.'&Comments.Ta&gs\ (plugin).&PROJECT          <Esc>a'.s:Perl_Project
		"
		"
		exe "amenu ".s:Perl_Root.'&Comments.&vim\ modeline             <Esc><Esc>:call Perl_CommentVimModeline()<CR>'

		"---------- Statements-Menu ----------------------------------------------------------------------

		if s:Perl_MenuHeader == "yes"
			exe "amenu ".s:Perl_Root.'St&atements.Statements<Tab>Perl     <Esc>'
			exe "amenu ".s:Perl_Root.'St&atements.-Sep0-        :'
		endif
		"
		exe "amenu ".s:Perl_Root.'St&atements.&do\ \{\ \}\ while               <Esc><Esc>:call Perl_DoWhile("a")<CR><Esc>4jf(la'
		exe "amenu ".s:Perl_Root.'St&atements.&for\ \{\ \}                     <Esc><Esc>ofor ( ; ;  )<CR>{<CR>}<Esc>2kf;i'
		exe "amenu ".s:Perl_Root.'St&atements.f&oreach\ \{\ \}                 <Esc><Esc>oforeach  (  )<CR>{<CR>}<Tab><Tab><Tab><Tab># -----  end foreach  -----<Esc>2kF(hi'
		exe "amenu ".s:Perl_Root.'St&atements.&if\ \{\ \}		                   <Esc><Esc>oif (  )<CR>{<CR>}<Esc>2kf(la'
		exe "amenu ".s:Perl_Root.'St&atements.if\ \{\ \}\ &else\ \{\ \}        <Esc><Esc>oif (  )<CR>{<CR>}<CR>else<CR>{<CR>}<Esc>5kf(la'
		exe "amenu ".s:Perl_Root.'St&atements.&unless\ \{\ \}                  <Esc><Esc>ounless (  )<CR>{<CR>}<Esc>2kf(la'
		exe "amenu ".s:Perl_Root.'St&atements.u&nless\ \{\ \}\ else\ \{\ \}    <Esc><Esc>ounless (  )<CR>{<CR>}<CR>else<CR>{<CR>}<Esc>5kf(la'
		exe "amenu ".s:Perl_Root.'St&atements.un&til\ \{\ \}                   <Esc><Esc>ountil (  )<CR>{<CR>}<Esc>2kf(la'
		exe "amenu ".s:Perl_Root.'St&atements.&while\ \{\ \}                   <Esc><Esc>owhile (  )<CR>{<CR>}<Tab><Tab><Tab><Tab># -----  end while  -----<Esc>2kF(la'
		exe "amenu ".s:Perl_Root.'St&atements.&\{\ \}                          <Esc><Esc>o{<CR>}<Esc>O'
		"
		exe "vmenu ".s:Perl_Root.'St&atements.&do\ \{\ \}\ while               <Esc><Esc>:call Perl_DoWhile("v")<CR><Esc>f(la'
		exe "vmenu ".s:Perl_Root."St&atements.&for\\ \{\\ \}                   DOfor ( ; ;  )<CR>{<CR>}<Esc>P2k<Esc>:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>f;i"
		exe "vmenu ".s:Perl_Root."St&atements.f&oreach\\ \{\\ \}               DOforeach  (  )<CR>{<CR>}<Tab><Tab><Tab><Tab># -----  end foreach  -----<Esc>P2k<Esc>:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>f(hi"
		exe "vmenu ".s:Perl_Root."St&atements.&if\\ \{\\ \}		                 DOif (  )<CR>{<CR>}<Esc>P2k<Esc>:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>f(la"
		exe "vmenu ".s:Perl_Root."St&atements.if\\ \{\\ \}\\ &else\\ \{\\ \}      DOif (  )<CR>{<CR>}<CR>else<CR>{<CR>}<Esc>3kP2k<Esc>:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>f(la"
		exe "vmenu ".s:Perl_Root."St&atements.&unless\\ \{\\ \}                   DOunless (  )<CR>{<CR>}<Esc>P2k<Esc>:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>f(la"
		exe "vmenu ".s:Perl_Root."St&atements.u&nless\\ \{\\ \}\\ else\\ \{\\ \}  DOunless (  )<CR>{<CR>}<CR>else<CR>{<CR>}<Esc>3kP2k<Esc>:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>f(la"
		exe "vmenu ".s:Perl_Root."St&atements.un&til\\ \{\\ \}                    DOuntil (  )<CR>{<CR>}<Esc>P2k<Esc>:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>f(la"
		exe "vmenu ".s:Perl_Root."St&atements.&while\\ \{\\ \}                    DOwhile (  )<CR>{<CR>}<Tab><Tab><Tab><Tab># -----  end while  -----<Esc>P2k<Esc>:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>f(la"
		exe "vmenu ".s:Perl_Root."St&atements.&\\{\\ \\}                          DO{<CR>}<Esc>Pk<Esc>:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>"
		"
		" The menu entries for code snippet support will not appear if the following string is empty 
		if s:Perl_CodeSnippets != ""
			exe "imenu ".s:Perl_Root.'St&atements.-SEP6-                      			:'
			exe "amenu <silent>  ".s:Perl_Root.'St&atements.&read\ code\ snippet    <C-C>:call Perl_CodeSnippet("r")<CR>'
			exe "amenu <silent>  ".s:Perl_Root.'St&atements.&write\ code\ snippet   <C-C>:call Perl_CodeSnippet("w")<CR>'
			exe "vmenu <silent>  ".s:Perl_Root.'St&atements.&write\ code\ snippet   <C-C>:call Perl_CodeSnippet("wv")<CR>'
			exe "amenu <silent>  ".s:Perl_Root.'St&atements.e&dit\ code\ snippet    <C-C>:call Perl_CodeSnippet("e")<CR>'
		endif
		"
		"---------- submenu : idioms -------------------------------------------------------------
		"
		if s:Perl_MenuHeader == "yes"
			exe "amenu ".s:Perl_Root.'I&dioms.Idioms<Tab>Perl    <Esc>'
			exe "amenu ".s:Perl_Root.'I&dioms.-Sep0-       :'
		endif
		"
		exe "amenu ".s:Perl_Root.'I&dioms.&my\ $;                       <Esc><Esc>omy<Tab>$;<Esc>i'
		exe "amenu ".s:Perl_Root.'I&dioms.m&y\ $\ =\ ;                  <Esc><Esc>omy<Tab>$<Tab>= ;<Esc>F$a'
		exe "amenu ".s:Perl_Root.'I&dioms.my\ (\ $&,\ $\ );             <Esc><Esc>omy<Tab>( $, $ );<Esc>2F$a'
		exe "amenu ".s:Perl_Root.'I&dioms.-SEP1-                        :'
		exe "amenu ".s:Perl_Root.'I&dioms.(&1)\ my\ @;                  <Esc><Esc>omy<Tab>@;<Esc>i'
		exe "amenu ".s:Perl_Root.'I&dioms.(&2)\ my\ @\ =\ (,,);         <Esc><Esc>omy<Tab>@<Tab>= ( , ,  );<Esc>F@a'
		exe "amenu ".s:Perl_Root.'I&dioms.-SEP2-                        :'
		exe "amenu ".s:Perl_Root.'I&dioms.(&3)\ my\ %;                  <Esc><Esc>omy<Tab>%;<Esc>i'
		exe "amenu ".s:Perl_Root.'I&dioms.(&4)\ my\ %\ =\ (=>,);        <Esc><Esc>omy<Tab>%<Tab>= <CR>(<CR>=> ,<CR>=> ,<CR>);<Esc>k0i<Tab><Tab><Esc>k0i<Tab><Tab><Esc>2kf%a'
		exe "amenu ".s:Perl_Root.'I&dioms.(&5)\ my\ $rgx_\ =\ q//;      <Esc><Esc>omy<Tab>$rgx_<Tab>= q//;<Esc>F_a'
		exe "amenu ".s:Perl_Root.'I&dioms.(&6)\ my\ $rgx_\ =\ qr//;     <Esc><Esc>omy<Tab>$rgx_<Tab>= qr//;<Esc>F_a'
		exe "amenu ".s:Perl_Root.'I&dioms.-SEP3-                        :'
		exe " menu ".s:Perl_Root.'I&dioms.(&7)\ $\ =~\ m//              <Esc>a$ =~ m//<Esc>F$a'
		exe " menu ".s:Perl_Root.'I&dioms.(&8)\ $\ =~\ s///             <Esc>a$ =~ s///<Esc>F$a'
		exe " menu ".s:Perl_Root.'I&dioms.(&9)\ $\ =~\ tr///            <Esc>a$ =~ tr///<Esc>F$a'
		exe "imenu ".s:Perl_Root.'I&dioms.(&7)\ $\ =~\ m//              $ =~ m//<Esc>F$a'
		exe "imenu ".s:Perl_Root.'I&dioms.(&8)\ $\ =~\ s///             $ =~ s///<Esc>F$a'
		exe "imenu ".s:Perl_Root.'I&dioms.(&9)\ $\ =~\ tr///            $ =~ tr///<Esc>F$a'
		exe " menu ".s:Perl_Root.'I&dioms.-SEP4-                        :'
		exe " menu ".s:Perl_Root.'I&dioms.&print\ \"\.\.\.\\n\";        <Esc>aprint "\n";<ESC>3hi'
		exe " menu ".s:Perl_Root.'I&dioms.print&f\ (\"\.\.\.\\n\");     <Esc>aprintf ("\n");<ESC>4hi'
		exe "imenu ".s:Perl_Root.'I&dioms.&print\ \"\.\.\.\\n\";        print "\n";<ESC>3hi'
		exe "imenu ".s:Perl_Root.'I&dioms.print&f\ (\"\.\.\.\\n\");     printf ("\n");<ESC>4hi'
		exe "amenu ".s:Perl_Root.'I&dioms.&subroutine                   <Esc><Esc>:call Perl_CodeFunction()<CR>A'
		exe "amenu ".s:Perl_Root.'I&dioms.open\ &input\ file            <Esc><Esc>:call Perl_CodeOpenRead()<CR>a'
		exe "amenu ".s:Perl_Root.'I&dioms.open\ &output\ file           <Esc><Esc>:call Perl_CodeOpenWrite()<CR>a'
		exe "amenu ".s:Perl_Root.'I&dioms.open\ pip&e                   <Esc><Esc>:call Perl_CodeOpenPipe()<CR>a'
		exe "amenu ".s:Perl_Root.'I&dioms.-SEP5-                        :'
		exe " menu ".s:Perl_Root.'I&dioms.<STDIN>                       <Esc>a<STDIN>'
		exe " menu ".s:Perl_Root.'I&dioms.<STDOUT>                      <Esc>a<STDOUT>'
		exe " menu ".s:Perl_Root.'I&dioms.<STDERR>                      <Esc>a<STDERR>'
		exe "imenu ".s:Perl_Root.'I&dioms.<STDIN>                       <STDIN>'
		exe "imenu ".s:Perl_Root.'I&dioms.<STDOUT>                      <STDOUT>'
		exe "imenu ".s:Perl_Root.'I&dioms.<STDERR>                      <STDERR>'
		exe "imenu ".s:Perl_Root.'I&dioms.-SEP7-                        :'
		"
		"---------- submenu : Regular Expression Suport  -----------------------------------------
		"
		if s:Perl_MenuHeader == "yes"
			exe "amenu ".s:Perl_Root.'Rege&x.Regex<Tab>Perl      <Esc>'
			exe "amenu ".s:Perl_Root.'Rege&x.-Sep0-         :'
		endif
		"
		"
		"---------- subsubmenu : Regular Expression Suport  -----------------------------------------
		"
		if s:Perl_MenuHeader == "yes"
			exe "amenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.Regex-1<Tab>Perl      <Esc>'
			exe "amenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.-Sep0-         :'
		endif
		"
		exe "amenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.&comment<Tab>(?#\ \.\.\.\ )                 			<Esc><Esc>a(?#)<Esc>i'
		exe "amenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.cl&uster\ only\ paren\.<Tab>(?:\ \.\.\.\ )        <Esc><Esc>a(?:)<Esc>i'
		exe "amenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.pattern\ &modifier<Tab>(?imsx-imsx)               <Esc><Esc>a(?)<Esc>i'
		exe "amenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.e&xecute\ code<Tab>(?\{\ \.\.\.\ \})            	<Esc><Esc>a(?{})<Esc>hi'
		exe "amenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.match\ &regex\ from\ code<Tab>(??\{\ \.\.\.\ \})	<Esc><Esc>a(??{})<Esc>F{a'
		exe "amenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.match-if-&then<Tab>(?(\.\.)\.\.)       				  	<Esc><Esc>a(?())<Esc>F(a'
		exe "amenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.match-if-t&hen-else<Tab>(?(\.\.)\.\.\|\.\.)     	<Esc><Esc>a(?()\|))<Esc>F(a'
		exe " menu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.-SEP11-																						:'
		exe "amenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.look&ahead\ succeeds<Tab>(?=\ \.\.\.\ )     			<Esc><Esc>a(?=)<Esc>i'
		exe "amenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.looka&head\ fails<Tab>(?!\ \.\.\.\ )         			<Esc><Esc>a(?!)<Esc>i'
		exe "amenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.look&behind\ succeeds<Tab>(?<=\ \.\.\.\ )      		<Esc><Esc>a(?<=)<Esc>i'
		exe "amenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.lookb&ehind\ fails<Tab>(?<!\ \.\.\.\ )         		<Esc><Esc>a(?<!)<Esc>i'

		exe "vmenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.&comment<Tab>(?#\ \.\.\.\ )                 			di(?#)<Esc>P2l'
		exe "vmenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.cl&uster\ only\ paren\.<Tab>(?:\ \.\.\.\ )        di(?:)<Esc>P2l'
		exe "vmenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.pattern\ &modifier<Tab>(?imsx-imsx)               di(?)<Esc>P2l'
		exe "vmenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.e&xecute\ code<Tab>(?\{\ \.\.\.\ \})            	di(?{})<Esc>hP3l'
		exe "vmenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.match\ &regex\ from\ code<Tab>(??\{\ \.\.\.\ \})	di(??{})<Esc>hP3l'
		exe "vmenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.match-if-&then<Tab>(?(\.\.)\.\.)       				  	di(?())<Esc>F(pla'
		exe "vmenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.match-if-t&hen-else<Tab>(?(\.\.)\.\.\|\.\.)     	di(?()\|)<Esc>F(pla'
		exe "vmenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.-SEP11-																						:'
		exe "vmenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.look&ahead\ succeeds<Tab>(?=\ \.\.\.\ )     			di(?=)<Esc>P2l'
		exe "vmenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.looka&head\ fails<Tab>(?!\ \.\.\.\ )         			di(?!)<Esc>P2l'
		exe "vmenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.look&behind\ succeeds<Tab>(?<=\ \.\.\.\ )      		di(?<=)<Esc>P2l'
		exe "vmenu ".s:Perl_Root.'Rege&x.e&xtended\ Regex.lookb&ehind\ fails<Tab>(?<!\ \.\.\.\ )         		di(?<!)<Esc>P2l'
		exe " menu ".s:Perl_Root.'Rege&x.-SEP2-																:'
		"
		exe "amenu ".s:Perl_Root.'Rege&x.&Grouping<Tab>(\ )       				<Esc><Esc><Esc>a()<Esc>i'
		exe "vmenu ".s:Perl_Root.'Rege&x.&Grouping<Tab>(\ )       				di()<Esc>Pla'
		exe "amenu ".s:Perl_Root.'Rege&x.&Alternation<Tab>(\ \|\ )   			<Esc><Esc>a(\|)<Esc>hi'
		exe "vmenu ".s:Perl_Root.'Rege&x.&Alternation<Tab>(\ \|\ )  		 	di(\|)<Esc>hPla'
		exe "amenu ".s:Perl_Root.'Rege&x.Char\.\ &class<Tab>[\ ]       		<Esc><Esc>a[]<Esc>i'
		exe "vmenu ".s:Perl_Root.'Rege&x.Char\.\ &class<Tab>[\ ]       		di[]<Esc>Pla'
		exe "amenu ".s:Perl_Root.'Rege&x.C&ount<Tab>{\ }       			      <Esc><Esc>a{}<Esc>i'
		exe "vmenu ".s:Perl_Root.'Rege&x.C&ount<Tab>{\ }       						di{}<Esc>Pla'
		exe "amenu ".s:Perl_Root.'Rege&x.Co&unt\ (at\ least)<Tab>{\ ,\ }  <Esc><Esc>a{,}<Esc>hi'
		exe "vmenu ".s:Perl_Root.'Rege&x.Co&unt\ (at\ least)<Tab>{\ ,\ }  di{,}<Esc>hPla'
		"
		exe " menu ".s:Perl_Root.'Rege&x.-SEP0-															:'
		"
		exe " menu ".s:Perl_Root.'Rege&x.Word\ &boundary<Tab>\\b              <Esc>a\b'
		exe "imenu ".s:Perl_Root.'Rege&x.Word\ &boundary<Tab>\\b     			 		\b'
		exe " menu ".s:Perl_Root.'Rege&x.&Digit<Tab>\\d                       <Esc>a\d'
		exe "imenu ".s:Perl_Root.'Rege&x.&Digit<Tab>\\d 				              \d'
		exe " menu ".s:Perl_Root.'Rege&x.White&space<Tab>\\s                  <Esc>a\s'
		exe "imenu ".s:Perl_Root.'Rege&x.White&space<Tab>\\s				 			 		\s'
		exe " menu ".s:Perl_Root.'Rege&x.&Word\ character<Tab>\\w             <Esc>a\w'
		exe "imenu ".s:Perl_Root.'Rege&x.&Word\ character<Tab>\\w      		 		\w'
		exe " menu ".s:Perl_Root.'Rege&x.-SEP1-											 			 		:'
		exe " menu ".s:Perl_Root.'Rege&x.Non-(word\ bound\.)\ (&1)<Tab>\\B    <Esc>a\B'
		exe "imenu ".s:Perl_Root.'Rege&x.Non-(word\ bound\.)\ (&1)<Tab>\\B    \B'
		exe " menu ".s:Perl_Root.'Rege&x.Non-digit\ (&2)<Tab>\\D  						<Esc>a\D'
		exe "imenu ".s:Perl_Root.'Rege&x.Non-digit\ (&2)<Tab>\\D 							\D'
		exe " menu ".s:Perl_Root.'Rege&x.Non-whitespace\ (&3)<Tab>\\S    			<Esc>a\S'
		exe "imenu ".s:Perl_Root.'Rege&x.Non-whitespace\ (&3)<Tab>\\S 				\S'
		exe " menu ".s:Perl_Root.'Rege&x.Non-\"word\"\ char\.\ (&4)<Tab>\\W   <Esc>a\W'
		exe "imenu ".s:Perl_Root.'Rege&x.Non-\"word\"\ char\.\ (&4)<Tab>\\W   \W'
		"
		"---------- submenu : POSIX character classes --------------------------------------------
		"
		if s:Perl_MenuHeader == "yes"
			exe "amenu ".s:Perl_Root.'CharC&ls.CharCls<Tab>Perl   <Esc>'
			exe "amenu ".s:Perl_Root.'CharC&ls.-Sep0-      :'
		endif
		"
		exe " menu ".s:Perl_Root.'CharC&ls.[:&alnum:]		<Esc>a[:alnum:]'
		exe " menu ".s:Perl_Root.'CharC&ls.[:alp&ha:]		<Esc>a[:alpha:]'
		exe " menu ".s:Perl_Root.'CharC&ls.[:asc&ii:]		<Esc>a[:ascii:]'
		exe " menu ".s:Perl_Root.'CharC&ls.[:&cntrl:]		<Esc>a[:cntrl:]'
		exe " menu ".s:Perl_Root.'CharC&ls.[:&digit:]		<Esc>a[:digit:]'
		exe " menu ".s:Perl_Root.'CharC&ls.[:&graph:]		<Esc>a[:graph:]'
		exe " menu ".s:Perl_Root.'CharC&ls.[:&lower:]		<Esc>a[:lower:]'
		exe " menu ".s:Perl_Root.'CharC&ls.[:&print:]		<Esc>a[:print:]'
		exe " menu ".s:Perl_Root.'CharC&ls.[:pu&nct:]		<Esc>a[:punct:]'
		exe " menu ".s:Perl_Root.'CharC&ls.[:&space:]		<Esc>a[:space:]'
		exe " menu ".s:Perl_Root.'CharC&ls.[:&upper:]		<Esc>a[:upper:]'
		exe " menu ".s:Perl_Root.'CharC&ls.[:&word:]		<Esc>a[:word:]'
		exe " menu ".s:Perl_Root.'CharC&ls.[:&xdigit:]	<Esc>a[:xdigit:]'
		"
		exe "imenu ".s:Perl_Root.'CharC&ls.[:&alnum:]		[:alnum:]'
		exe "imenu ".s:Perl_Root.'CharC&ls.[:alp&ha:]		[:alpha:]'
		exe "imenu ".s:Perl_Root.'CharC&ls.[:asc&ii:]		[:ascii:]'
		exe "imenu ".s:Perl_Root.'CharC&ls.[:&cntrl:]		[:cntrl:]'
		exe "imenu ".s:Perl_Root.'CharC&ls.[:&digit:]		[:digit:]'
		exe "imenu ".s:Perl_Root.'CharC&ls.[:&graph:]		[:graph:]'
		exe "imenu ".s:Perl_Root.'CharC&ls.[:&lower:]		[:lower:]'
		exe "imenu ".s:Perl_Root.'CharC&ls.[:&print:]		[:print:]'
		exe "imenu ".s:Perl_Root.'CharC&ls.[:pu&nct:]		[:punct:]'
		exe "imenu ".s:Perl_Root.'CharC&ls.[:&space:]		[:space:]'
		exe "imenu ".s:Perl_Root.'CharC&ls.[:&upper:]		[:upper:]'
		exe "imenu ".s:Perl_Root.'CharC&ls.[:&word:]		[:word:]'
		exe "imenu ".s:Perl_Root.'CharC&ls.[:&xdigit:]	[:xdigit:]'
		"
		"
		"---------- File-Tests-Menu ----------------------------------------------------------------------
		"
		if s:Perl_MenuHeader == "yes"
			exe "amenu ".s:Perl_Root.'F&ile-Tests.File-Tests<Tab>Perl             <Esc>'
			exe "amenu ".s:Perl_Root.'F&ile-Tests.-Sep0-                          :'
		endif
		"
		exe " menu ".s:Perl_Root.'F&ile-Tests.exists<Tab>-e											<Esc>a-e <Esc>a'
		exe " menu ".s:Perl_Root.'F&ile-Tests.has\ zero\ size<Tab>-z						<Esc>a-z <Esc>a'
		exe " menu ".s:Perl_Root.'F&ile-Tests.has\ nonzero\ size<Tab>-s					<Esc>a-s <Esc>a'
		exe " menu ".s:Perl_Root.'F&ile-Tests.plain\ file<Tab>-f								<Esc>a-f <Esc>a'
		exe " menu ".s:Perl_Root.'F&ile-Tests.directory<Tab>-d									<Esc>a-d <Esc>a'
		exe " menu ".s:Perl_Root.'F&ile-Tests.symbolic\ link<Tab>-l							<Esc>a-l <Esc>a'
		exe " menu ".s:Perl_Root.'F&ile-Tests.named\ pipe<Tab>-p								<Esc>a-p <Esc>a'
		exe " menu ".s:Perl_Root.'F&ile-Tests.socket<Tab>-S											<Esc>a-S <Esc>a'
		exe " menu ".s:Perl_Root.'F&ile-Tests.block\ special\ file<Tab>-b				<Esc>a-b <Esc>a'
		exe " menu ".s:Perl_Root.'F&ile-Tests.character\ special\ file<Tab>-c		<Esc>a-c <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.exists<Tab>-e											-e <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.has\ zero\ size<Tab>-z						-z <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.has\ nonzero\ size<Tab>-s					-s <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.plain\ file<Tab>-f								-f <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.directory<Tab>-d									-d <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.symbolic\ link<Tab>-l							-l <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.named\ pipe<Tab>-p								-p <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.socket<Tab>-S											-S <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.block\ special\ file<Tab>-b				-b <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.character\ special\ file<Tab>-c		-c <Esc>a'
		"
		exe " menu ".s:Perl_Root.'F&ile-Tests.-SEP1-															:'
		"
		exe " menu ".s:Perl_Root.'F&ile-Tests.readable\ by\ eff\.\ UID/GID<Tab>-r			<Esc>a-r <Esc>a'
		exe " menu ".s:Perl_Root.'F&ile-Tests.writable\ by\ eff\.\ UID/GID<Tab>-w			<Esc>a-w <Esc>a'
		exe " menu ".s:Perl_Root.'F&ile-Tests.executable\ by\ eff\.\ UID/GID<Tab>-x		<Esc>a-x <Esc>a'
		exe " menu ".s:Perl_Root.'F&ile-Tests.owned\ by\ eff\.\ UID<Tab>-o						<Esc>a-o <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.readable\ by\ eff\.\ UID/GID<Tab>-r			-r <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.writable\ by\ eff\.\ UID/GID<Tab>-w			-w <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.executable\ by\ eff\.\ UID/GID<Tab>-x		-x <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.owned\ by\ eff\.\ UID<Tab>-o						-o <Esc>a'
		"
		exe " menu ".s:Perl_Root.'F&ile-Tests.-SEP2-													:'
		exe " menu ".s:Perl_Root.'F&ile-Tests.readable\ by\ real\ UID/GID<Tab>-R			<Esc>a-R <Esc>a'
		exe " menu ".s:Perl_Root.'F&ile-Tests.writable\ by\ real\ UID/GID<Tab>-W			<Esc>a-W <Esc>a'
		exe " menu ".s:Perl_Root.'F&ile-Tests.executable\ by\ real\ UID/GID<Tab>-X		<Esc>a-X <Esc>a'
		exe " menu ".s:Perl_Root.'F&ile-Tests.owned\ by\ real\ UID<Tab>-O							<Esc>a-O <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.readable\ by\ real\ UID/GID<Tab>-R			-R <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.writable\ by\ real\ UID/GID<Tab>-W			-W <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.executable\ by\ real\ UID/GID<Tab>-X		-X <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.owned\ by\ real\ UID<Tab>-O							-O <Esc>a'

		exe " menu ".s:Perl_Root.'F&ile-Tests.-SEP3-													:'
		exe " menu ".s:Perl_Root.'F&ile-Tests.setuid\ bit\ set<Tab>-u					<Esc>a-u <Esc>a'
		exe " menu ".s:Perl_Root.'F&ile-Tests.setgid\ bit\ set<Tab>-g					<Esc>a-g <Esc>a'
		exe " menu ".s:Perl_Root.'F&ile-Tests.sticky\ bit\ set<Tab>-k					<Esc>a-k <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.setuid\ bit\ set<Tab>-u					-u <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.setgid\ bit\ set<Tab>-g					-g <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.sticky\ bit\ set<Tab>-k					-k <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.-SEP4-													:'
		exe " menu ".s:Perl_Root.'F&ile-Tests.age\ since\ modification<Tab>-M				<Esc>a-M <Esc>a'
		exe " menu ".s:Perl_Root.'F&ile-Tests.age\ since\ last\ access<Tab>-A				<Esc>a-A <Esc>a'
		exe " menu ".s:Perl_Root.'F&ile-Tests.age\ since\ inode\ change<Tab>-C			<Esc>a-C <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.age\ since\ modification<Tab>-M				-M <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.age\ since\ last\ access<Tab>-A				-A <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.age\ since\ inode\ change<Tab>-C			-C <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.-SEP5-													:'
		exe " menu ".s:Perl_Root.'F&ile-Tests.text\ file<Tab>-T											<Esc>a-T <Esc>a'
		exe " menu ".s:Perl_Root.'F&ile-Tests.binary\ file<Tab>-B										<Esc>a-B <Esc>a'
		exe " menu ".s:Perl_Root.'F&ile-Tests.handle\ opened\ to\ a\ tty<Tab>-t			<Esc>a-t <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.text\ file<Tab>-T											-T <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.binary\ file<Tab>-B										-B <Esc>a'
		exe "imenu ".s:Perl_Root.'F&ile-Tests.handle\ opened\ to\ a\ tty<Tab>-t			-t <Esc>a'
		"
		"---------- Special-Variables -------------------------------------------------------------
		"
		if s:Perl_MenuHeader == "yes"
			exe "amenu ".s:Perl_Root.'Spec-&Var.Spec-Var<Tab>Perl      <Esc>'
			exe "amenu ".s:Perl_Root.'Spec-&Var.-Sep0-         :'
		endif
		"
		"-------- submenu errors -------------------------------------------------
		if s:Perl_MenuHeader == "yes"
			exe "amenu ".s:Perl_Root.'Spec-&Var.&errors.Spec-Var-1<Tab>Perl       <Esc>'
			exe "amenu ".s:Perl_Root.'Spec-&Var.&errors.-Sep0-              			:'
		endif
		exe " menu ".s:Perl_Root.'Spec-&Var.&errors.$CHILD_ERROR<Tab>$?					<Esc>a$CHILD_ERROR'
		exe " menu ".s:Perl_Root.'Spec-&Var.&errors.$ERRNO<Tab>$!            		<Esc>a$ERRNO'
		exe " menu ".s:Perl_Root.'Spec-&Var.&errors.$EVAL_ERROR<Tab>$@       		<Esc>a$EVAL_ERROR'
		exe " menu ".s:Perl_Root.'Spec-&Var.&errors.$EXTENDED_OS_ERROR<Tab>$^E	<Esc>a$EXTENDED_OS_ERROR'
"		exe " menu ".s:Perl_Root.'Spec-&Var.&errors.$OS_ERRNO         			<Esc>a$OS_ERRNO'
		exe " menu ".s:Perl_Root.'Spec-&Var.&errors.$WARNING<Tab>$^W          		<Esc>a$WARNING'
		exe "imenu ".s:Perl_Root.'Spec-&Var.&errors.$CHILD_ERROR<Tab>$?      			$CHILD_ERROR'
		exe "imenu ".s:Perl_Root.'Spec-&Var.&errors.$ERRNO<Tab>$!            			$ERRNO'
		exe "imenu ".s:Perl_Root.'Spec-&Var.&errors.$EVAL_ERROR<Tab>$@       			$EVAL_ERROR'
		exe "imenu ".s:Perl_Root.'Spec-&Var.&errors.$EXTENDED_OS_ERROR<Tab>$^E		$EXTENDED_OS_ERROR'
"		exe "imenu ".s:Perl_Root.'Spec-&Var.&errors.$OS_ERRNO<Tab>$         			$OS_ERRNO'
		exe "imenu ".s:Perl_Root.'Spec-&Var.&errors.$WARNING<Tab>$^W          		$WARNING'

		"-------- submenu files -------------------------------------------------
		if s:Perl_MenuHeader == "yes"
			exe "amenu ".s:Perl_Root.'Spec-&Var.&files.Spec-Var-2<Tab>Perl     <Esc>'
			exe "amenu ".s:Perl_Root.'Spec-&Var.&files.-Sep0-                  :'
		endif
		exe " menu ".s:Perl_Root.'Spec-&Var.&files.$AUTOFLUSH<Tab>$\|              <Esc>a$AUTOFLUSH'
		exe " menu ".s:Perl_Root.'Spec-&Var.&files.$OUTPUT_AUTOFLUSH<Tab>$\|       <Esc>a$OUTPUT_AUTOFLUSH'
		exe " menu ".s:Perl_Root.'Spec-&Var.&files.$FORMAT_LINES_LEFT<Tab>$-       <Esc>a$FORMAT_LINES_LEFT'
		exe " menu ".s:Perl_Root.'Spec-&Var.&files.$FORMAT_LINES_PER_PAGE<Tab>$=   <Esc>a$FORMAT_LINES_PER_PAGE'
		exe " menu ".s:Perl_Root.'Spec-&Var.&files.$FORMAT_NAME<Tab>$~             <Esc>a$FORMAT_NAME'
		exe " menu ".s:Perl_Root.'Spec-&Var.&files.$FORMAT_PAGE_NUMBER<Tab>$%      <Esc>a$FORMAT_PAGE_NUMBER'
		exe " menu ".s:Perl_Root.'Spec-&Var.&files.$FORMAT_TOP_NAME<Tab>$^         <Esc>a$FORMAT_TOP_NAME'
		exe "imenu ".s:Perl_Root.'Spec-&Var.&files.$AUTOFLUSH<Tab>$\|              $AUTOFLUSH'
		exe "imenu ".s:Perl_Root.'Spec-&Var.&files.$OUTPUT_AUTOFLUSH<Tab>$\|       $OUTPUT_AUTOFLUSH'
		exe "imenu ".s:Perl_Root.'Spec-&Var.&files.$FORMAT_LINES_LEFT<Tab>$-       $FORMAT_LINES_LEFT'
		exe "imenu ".s:Perl_Root.'Spec-&Var.&files.$FORMAT_LINES_PER_PAGE<Tab>$=   $FORMAT_LINES_PER_PAGE'
		exe "imenu ".s:Perl_Root.'Spec-&Var.&files.$FORMAT_NAME<Tab>$~             $FORMAT_NAME'
		exe "imenu ".s:Perl_Root.'Spec-&Var.&files.$FORMAT_PAGE_NUMBER<Tab>$%      $FORMAT_PAGE_NUMBER'
		exe "imenu ".s:Perl_Root.'Spec-&Var.&files.$FORMAT_TOP_NAME<Tab>$^         $FORMAT_TOP_NAME'

		"-------- submenu IDs -------------------------------------------------
		if s:Perl_MenuHeader == "yes"
			exe "amenu ".s:Perl_Root.'Spec-&Var.&IDs.Spec-Var-3<Tab>Perl    <Esc>'
			exe "amenu ".s:Perl_Root.'Spec-&Var.&IDs.-Sep0-                 :'
		endif
		exe " menu ".s:Perl_Root.'Spec-&Var.&IDs.$PID<Tab>$$                   <Esc>a$PID'
		exe " menu ".s:Perl_Root.'Spec-&Var.&IDs.$PROCESS_ID<Tab>$$            <Esc>a$PROCESS_ID'
		exe " menu ".s:Perl_Root.'Spec-&Var.&IDs.$GID<Tab>$(                   <Esc>a$GID'
		exe " menu ".s:Perl_Root.'Spec-&Var.&IDs.$REAL_GROUP_ID<Tab>$(         <Esc>a$REAL_GROUP_ID'
		exe " menu ".s:Perl_Root.'Spec-&Var.&IDs.$EGID<Tab>$)                  <Esc>a$EGID'
		exe " menu ".s:Perl_Root.'Spec-&Var.&IDs.$EFFECTIVE_GROUP_ID<Tab>$)    <Esc>a$EFFECTIVE_GROUP_ID'
		exe "imenu ".s:Perl_Root.'Spec-&Var.&IDs.$PID<Tab>$$                   $PID'
		exe "imenu ".s:Perl_Root.'Spec-&Var.&IDs.$PROCESS_ID<Tab>$$            $PROCESS_ID'
		exe "imenu ".s:Perl_Root.'Spec-&Var.&IDs.$GID<Tab>$(                   $GID'
		exe "imenu ".s:Perl_Root.'Spec-&Var.&IDs.$REAL_GROUP_ID<Tab>$(         $REAL_GROUP_ID'
		exe "imenu ".s:Perl_Root.'Spec-&Var.&IDs.$EGID<Tab>$)                  $EGID'
		exe "imenu ".s:Perl_Root.'Spec-&Var.&IDs.$EFFECTIVE_GROUP_ID<Tab>$)    $EFFECTIVE_GROUP_ID'

		"-------- submenu IO -------------------------------------------------
		if s:Perl_MenuHeader == "yes"
			exe "amenu ".s:Perl_Root.'Spec-&Var.I&O.Spec-Var-4<Tab>Perl       <Esc>'
			exe "amenu ".s:Perl_Root.'Spec-&Var.I&O.-Sep0-                    :'
		endif
		exe " menu ".s:Perl_Root.'Spec-&Var.I&O.$INPUT_LINE_NUMBER<Tab>$\.          <Esc>a$INPUT_LINE_NUMBER'
		exe " menu ".s:Perl_Root.'Spec-&Var.I&O.$NR<Tab>$\.                         <Esc>a$NR'
		exe "imenu ".s:Perl_Root.'Spec-&Var.I&O.$INPUT_LINE_NUMBER<Tab>$\.          $INPUT_LINE_NUMBER'
		exe "imenu ".s:Perl_Root.'Spec-&Var.I&O.$NR<Tab>$\.                         $NR'

		exe "imenu ".s:Perl_Root.'Spec-&Var.I&O.-SEP1-    					 		            :'
		exe " menu ".s:Perl_Root.'Spec-&Var.I&O.$INPUT_RECORD_SEPARATOR<Tab>$/     <Esc>a$INPUT_RECORD_SEPARATOR'
		exe " menu ".s:Perl_Root.'Spec-&Var.I&O.$RS<Tab>$/                         <Esc>a$RS'
		exe " menu ".s:Perl_Root.'Spec-&Var.I&O.$LIST_SEPARATOR<Tab>$"             <Esc>a$LIST_SEPARATOR'
		exe " menu ".s:Perl_Root.'Spec-&Var.I&O.$OUTPUT_FIELD_SEPARATOR<Tab>$,     <Esc>a$OUTPUT_FIELD_SEPARATOR'
		exe " menu ".s:Perl_Root.'Spec-&Var.I&O.$OFS<Tab>$,                        <Esc>a$OFS'
		exe " menu ".s:Perl_Root.'Spec-&Var.I&O.$OUTPUT_RECORD_SEPARATOR<Tab>$\\   <Esc>a$OUTPUT_RECORD_SEPARATOR'
		exe " menu ".s:Perl_Root.'Spec-&Var.I&O.$ORS<Tab>$\\                       <Esc>a$ORS'
		exe " menu ".s:Perl_Root.'Spec-&Var.I&O.$SUBSCRIPT_SEPARATOR<Tab>$;        <Esc>a$SUBSCRIPT_SEPARATOR'
		exe " menu ".s:Perl_Root.'Spec-&Var.I&O.$SUBSEP<Tab>$;                     <Esc>a$SUBSEP'

		exe "imenu ".s:Perl_Root.'Spec-&Var.I&O.$INPUT_RECORD_SEPARATOR<Tab>$/     $INPUT_RECORD_SEPARATOR'
		exe "imenu ".s:Perl_Root.'Spec-&Var.I&O.$RS<Tab>$/                         $RS'
		exe "imenu ".s:Perl_Root.'Spec-&Var.I&O.$LIST_SEPARATOR<Tab>$"             $LIST_SEPARATOR'
		exe "imenu ".s:Perl_Root.'Spec-&Var.I&O.$OUTPUT_FIELD_SEPARATOR<Tab>$,     $OUTPUT_FIELD_SEPARATOR'
		exe "imenu ".s:Perl_Root.'Spec-&Var.I&O.$OFS<Tab>$,                        $OFS'
		exe "imenu ".s:Perl_Root.'Spec-&Var.I&O.$OUTPUT_RECORD_SEPARATOR<Tab>$\\   $OUTPUT_RECORD_SEPARATOR'
		exe "imenu ".s:Perl_Root.'Spec-&Var.I&O.$ORS<Tab>$\\                       $ORS'
		exe "imenu ".s:Perl_Root.'Spec-&Var.I&O.$SUBSCRIPT_SEPARATOR<Tab>$;        $SUBSCRIPT_SEPARATOR'
		exe "imenu ".s:Perl_Root.'Spec-&Var.I&O.$SUBSEP<Tab>$;                     $SUBSEP'

		"-------- submenu regexp -------------------------------------------------
		if s:Perl_MenuHeader == "yes"
			exe "amenu ".s:Perl_Root.'Spec-&Var.&regexp.Spec-Var-5<Tab>Perl       <Esc>'
			exe "amenu ".s:Perl_Root.'Spec-&Var.&regexp.-Sep0-                    :'
		endif
		exe " menu ".s:Perl_Root.'Spec-&Var.&regexp.$digits                 				   <Esc>a$digits'
		exe " menu ".s:Perl_Root.'Spec-&Var.&regexp.@LAST_MATCH_END<Tab>@+             <Esc>a@LAST_MATCH_END'
		exe " menu ".s:Perl_Root.'Spec-&Var.&regexp.@LAST_MATCH_START<Tab>@-           <Esc>a@LAST_MATCH_START'
		exe " menu ".s:Perl_Root.'Spec-&Var.&regexp.$LAST_PAREN_MATCH<Tab>$+           <Esc>a$LAST_PAREN_MATCH'
		exe " menu ".s:Perl_Root.'Spec-&Var.&regexp.$LAST_REGEXP_CODE_RESULT<Tab>$^R   <Esc>a$LAST_REGEXP_CODE_RESULT'
		exe " menu ".s:Perl_Root.'Spec-&Var.&regexp.$MATCH<Tab>$&                      <Esc>a$MATCH'
		exe " menu ".s:Perl_Root."Spec-&Var.&regexp.$POSTMATCH<Tab>$'                  <Esc>a$POSTMATCH"
		exe " menu ".s:Perl_Root.'Spec-&Var.&regexp.$PREMATCH<Tab>$`                   <Esc>a$PREMATCH'
		exe "imenu ".s:Perl_Root.'Spec-&Var.&regexp.$digits            				         $digits'
		exe "imenu ".s:Perl_Root.'Spec-&Var.&regexp.@LAST_MATCH_END<Tab>$@+            @LAST_MATCH_END'
		exe "imenu ".s:Perl_Root.'Spec-&Var.&regexp.@LAST_MATCH_START<Tab>$@-          @LAST_MATCH_START'
		exe "imenu ".s:Perl_Root.'Spec-&Var.&regexp.$LAST_PAREN_MATCH<Tab>$+           $LAST_PAREN_MATCH'
		exe "imenu ".s:Perl_Root.'Spec-&Var.&regexp.$LAST_REGEXP_CODE_RESULT<Tab>$^R   $LAST_REGEXP_CODE_RESULT'
		exe "imenu ".s:Perl_Root.'Spec-&Var.&regexp.$MATCH<Tab>$&                      $MATCH'
		exe "imenu ".s:Perl_Root."Spec-&Var.&regexp.$POSTMATCH<Tab>$'                  $POSTMATCH"
		exe "imenu ".s:Perl_Root.'Spec-&Var.&regexp.$PREMATCH<Tab>$`                   $PREMATCH'

		exe " menu ".s:Perl_Root.'Spec-&Var.$BASETIME<Tab>$^T      		<Esc>a$BASETIME'
		exe " menu ".s:Perl_Root.'Spec-&Var.$PERL_VERSION<Tab>$^V  		<Esc>a$PERL_VERSION'
		exe " menu ".s:Perl_Root.'Spec-&Var.$PROGRAM_NAME<Tab>$0  		<Esc>a$PROGRAM_NAME'
		exe " menu ".s:Perl_Root.'Spec-&Var.$OSNAME<Tab>$^O       		<Esc>a$OSNAME'
		exe " menu ".s:Perl_Root.'Spec-&Var.$SYSTEM_FD_MAX<Tab>$^F 		<Esc>a$SYSTEM_FD_MAX'
		exe " menu ".s:Perl_Root.'Spec-&Var.$ENV{\ }			 				 		<Esc>a$ENV{}<ESC>i'
		exe " menu ".s:Perl_Root.'Spec-&Var.$INC{\ }			 				 		<Esc>a$INC{}<ESC>i'
		exe " menu ".s:Perl_Root.'Spec-&Var.$SIG{\ }			 				 		<Esc>a$SIG{}<ESC>i'
		exe "imenu ".s:Perl_Root.'Spec-&Var.$BASETIME<Tab>$^T      		$BASETIME'
		exe "imenu ".s:Perl_Root.'Spec-&Var.$PERL_VERSION<Tab>$^V  		$PERL_VERSION'
		exe "imenu ".s:Perl_Root.'Spec-&Var.$PROGRAM_NAME<Tab>$0  		$PROGRAM_NAME'
		exe "imenu ".s:Perl_Root.'Spec-&Var.$OSNAME<Tab>$^O       		$OSNAME'
		exe "imenu ".s:Perl_Root.'Spec-&Var.$SYSTEM_FD_MAX<Tab>$^F 		$SYSTEM_FD_MAX'
		exe "imenu ".s:Perl_Root.'Spec-&Var.$ENV{\ }				 			 		$ENV{}<ESC>i'
		exe "imenu ".s:Perl_Root.'Spec-&Var.$INC{\ }				 			 		$INC{}<ESC>i'
		exe "imenu ".s:Perl_Root.'Spec-&Var.$SIG{\ }				 			 		$SIG{}<ESC>i'
		"
		"---------- submenu : POSIX signals --------------------------------------
		"
		if s:Perl_MenuHeader == "yes"
			exe "amenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.Spec-Var-6<Tab>Perl     <Esc>'
			exe "amenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.-Sep0-        :'
		endif
		exe " menu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.HUP 		<Esc>aHUP'
		exe " menu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.INT 		<Esc>aINT'
		exe " menu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.QUIT		<Esc>aQUIT'
		exe " menu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.ILL 		<Esc>aILL'
		exe " menu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.ABRT		<Esc>aABRT'
		exe " menu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.FPE 		<Esc>aFPE'
		exe " menu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.KILL		<Esc>aKILL'
		exe " menu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.SEGV		<Esc>aSEGV'
		exe " menu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.PIPE		<Esc>aPIPE'
		exe " menu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.ALRM		<Esc>aALRM'
		exe " menu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.TERM		<Esc>aTERM'
		exe " menu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.USR1		<Esc>aUSR1'
		exe " menu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.USR2		<Esc>aUSR2'
		exe " menu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.CHLD		<Esc>aCHLD'
		exe " menu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.CONT		<Esc>aCONT'
		exe " menu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.STOP		<Esc>aSTOP'
		exe " menu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.TSTP		<Esc>aTSTP'
		exe " menu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.TTIN		<Esc>aTTIN'
		exe " menu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.TTOU		<Esc>aTTOU'
		"
		exe "imenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.HUP 		HUP'
		exe "imenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.INT 		INT'
		exe "imenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.QUIT		QUIT'
		exe "imenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.ILL 		ILL'
		exe "imenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.ABRT		ABRT'
		exe "imenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.FPE 		FPE'
		exe "imenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.KILL		KILL'
		exe "imenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.SEGV		SEGV'
		exe "imenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.PIPE		PIPE'
		exe "imenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.ALRM		ALRM'
		exe "imenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.TERM		TERM'
		exe "imenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.USR1		USR1'
		exe "imenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.USR2		USR2'
		exe "imenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.CHLD		CHLD'
		exe "imenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.CONT		CONT'
		exe "imenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.STOP		STOP'
		exe "imenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.TSTP		TSTP'
		exe "imenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.TTIN		TTIN'
		exe "imenu ".s:Perl_Root.'Spec-&Var.POSIX\ signals.TTOU		TTOU'
		"
		exe "imenu ".s:Perl_Root.'Spec-&Var.-SEP2-      		      :'
		exe " menu ".s:Perl_Root."Spec-&Var.\'IGNORE\' 						<Esc>a'IGNORE'"
		exe " menu ".s:Perl_Root."Spec-&Var.\'DEFAULT\' 					<Esc>a'DEFAULT'"
		exe "imenu ".s:Perl_Root."Spec-&Var.\'IGNORE\' 						'IGNORE'"
		exe "imenu ".s:Perl_Root."Spec-&Var.\'DEFAULT\' 					'DEFAULT'"
		exe "imenu ".s:Perl_Root.'Spec-&Var.-SEP3-      		      :'
		exe "amenu ".s:Perl_Root.'Spec-&Var.use\ English; 				<ESC><ESC>ouse English;'
		"
		"---------- POD-Menu ----------------------------------------------------------------------
		"
		if s:Perl_MenuHeader == "yes"
			exe "amenu ".s:Perl_Root.'&POD.POD<Tab>Perl           <Esc>'
			exe "amenu ".s:Perl_Root.'&POD.-Sep0-                 :'
		endif
		"
		exe "amenu ".s:Perl_Root.'&POD.=&pod\ /\ =cut            <Esc><Esc>o'.s:Perl_POD_cut.'<Esc>3kA'
		exe "amenu ".s:Perl_Root.'&POD.=c&ut                     <Esc><Esc>o<CR>=cut<CR><CR><Esc>A'
		exe "amenu ".s:Perl_Root.'&POD.=begin\ &html\ /\ =end    <Esc><Esc>o'.s:Perl_POD_html.'<Esc>3kA'
		exe "amenu ".s:Perl_Root.'&POD.=begin\ &man\ /\ =end     <Esc><Esc>o'.s:Perl_POD_man.'<Esc>3kA'
		exe "amenu ".s:Perl_Root.'&POD.=begin\ &text\ /\ =end    <Esc><Esc>o'.s:Perl_POD_text.'<Esc>3kA'
		exe "amenu ".s:Perl_Root.'&POD.=head&1                   <Esc><Esc>o<CR>=head1 <CR><Esc>kA'
		exe "amenu ".s:Perl_Root.'&POD.=head&2                   <Esc><Esc>o<CR>=head2 <CR><Esc>kA'
		exe "amenu ".s:Perl_Root.'&POD.=head&3                   <Esc><Esc>o<CR>=head3 <CR><Esc>kA'
		exe "amenu ".s:Perl_Root.'&POD.-Sep1-                         :'
		exe "amenu ".s:Perl_Root.'&POD.=&over\ \.\.\ =back       <Esc><Esc>o'.s:Perl_POD_List.'<Esc>8kA'
		exe "amenu ".s:Perl_Root.'&POD.=item\ &*                 <Esc><Esc>o<CR>=item *<CR><CR><CR><Esc>kA'
		exe "amenu ".s:Perl_Root.'&POD.-Sep2-                   :'
		"
		"---------- submenu : Sequences --------------------------------------
		"
		exe "amenu ".s:Perl_Root.'&POD.&B<><Tab>bold                    <Esc>iB<><Esc>i'
		exe "amenu ".s:Perl_Root.'&POD.&C<><Tab>literal                 <Esc>iC<><Esc>i'
		exe "amenu ".s:Perl_Root.'&POD.&F<><Tab>filename                <Esc>iF<><Esc>i'
		exe "amenu ".s:Perl_Root.'&POD.&I<><Tab>italic                  <Esc>iI<><Esc>i'
		exe "amenu ".s:Perl_Root.'&POD.&L<><Tab>link                    <Esc>iL<><Esc>i'
		exe "amenu ".s:Perl_Root.'&POD.&S<>\ \ nonbr\.\ spaces          <Esc>iS<><Esc>i'
		exe "amenu ".s:Perl_Root.'&POD.&X<><Tab>index                   <Esc>iX<><Esc>i'
		"
		exe "amenu ".s:Perl_Root.'&POD.&Z<><Tab>zero-width              <Esc>iZ<><Esc>a'
		"
		exe "vmenu ".s:Perl_Root.'&POD.&B<><Tab>bold                    sB<><Esc>P2l'
		exe "vmenu ".s:Perl_Root.'&POD.&C<><Tab>literal                 sC<><Esc>P2l'
		exe "vmenu ".s:Perl_Root.'&POD.&F<><Tab>filename                sF<><Esc>P2l'
		exe "vmenu ".s:Perl_Root.'&POD.&I<><Tab>italic                  sI<><Esc>P2l'
		exe "vmenu ".s:Perl_Root.'&POD.&L<><Tab>link                    sL<><Esc>P2l'
		exe "vmenu ".s:Perl_Root.'&POD.&S<>\ \ nonbr\.\ spaces          sS<><Esc>P2l'
		exe "vmenu ".s:Perl_Root.'&POD.&X<><Tab>index                   sX<><Esc>P2l'

		exe "amenu          ".s:Perl_Root.'&POD.-SEP3-      		        :'
		exe "amenu <silent> ".s:Perl_Root.'&POD.POD\ ->\ html\ \ (&4)   <Esc><C-C>:call Perl_POD("html")<CR>'
		exe "amenu <silent> ".s:Perl_Root.'&POD.POD\ ->\ man\ \ (&5)    <Esc><C-C>:call Perl_POD("man")<CR>'
		exe "amenu <silent> ".s:Perl_Root.'&POD.POD\ ->\ text\ \ (&6)   <Esc><C-C>:call Perl_POD("text")<CR>'
		"
		"---------- Run-Menu ----------------------------------------------------------------------
		"
		if s:Perl_MenuHeader == "yes"
			exe "amenu ".s:Perl_Root.'&Run.Run<Tab>Perl                   <Esc>'
			exe "amenu ".s:Perl_Root.'&Run.-Sep0-                         :'
		endif
		"
		"   run the script from the local directory 
		"   ( the one which is being edited; other versions may exist elsewhere ! )
		" 
		exe "amenu ".s:Perl_Root.'&Run.update,\ &run\ script<Tab><C-F9>   			         <C-C>:call Perl_Run()<CR>'
		"
		exe "amenu ".s:Perl_Root.'&Run.update,\ check\ &syntax<Tab><A-F9>       			   <C-C>:call Perl_SyntaxCheck()<CR>:redraw<CR>:call Perl_SyntaxCheckMsg()<CR>'
		exe "amenu <silent> ".s:Perl_Root.'&Run.cmd\.\ line\ &arg\.<Tab><S-F9>           <C-C>:call Perl_Arguments()<CR>'
		exe "amenu <silent> ".s:Perl_Root.'&Run.deb&ug<Tab><F9>                          <C-C>:call Perl_Debugger()<CR>'
		"
		"   set execution rights for user only ( user may be root ! )
		"
		if !has('win32')
			exe "amenu <silent> ".s:Perl_Root.'&Run.make\ script\ &executable              <C-C>:call Perl_MakeScriptExecutable()<CR>'
		endif
		exe "amenu          ".s:Perl_Root.'&Run.-SEP2-                           :'

		exe "amenu <silent> ".s:Perl_Root.'&Run.read\ perl&doc<Tab><S-F1>        <C-C>:call Perl_perldoc("m")<CR><CR>'
		exe "amenu <silent> ".s:Perl_Root.'&Run.show\ &installed\ Perl\ modules  <Esc><Esc>:call Perl_perldoc_show_module_list()<CR>'
		exe "amenu <silent> ".s:Perl_Root.'&Run.&generate\ Perl\ module\ list    <C-C>:call Perl_perldoc_generate_module_list()<CR><CR>'
		"
		exe "amenu          ".s:Perl_Root.'&Run.-SEP4-                           :'
		exe "amenu <silent> ".s:Perl_Root.'&Run.run\ perltid&y                   <C-C>:call Perl_Perltidy("n")<CR>'
		exe "vmenu <silent> ".s:Perl_Root.'&Run.run\ perltid&y                   <C-C>:call Perl_Perltidy("v")<CR>'

		exe "amenu          ".s:Perl_Root.'&Run.-SEP5-                           :'
		exe "amenu <silent> ".s:Perl_Root.'&Run.&hardcopy\ to\ FILENAME\.ps      <C-C>:call Perl_Hardcopy("n")<CR>'
		exe "vmenu <silent> ".s:Perl_Root.'&Run.&hardcopy\ to\ FILENAME\.ps      <C-C>:call Perl_Hardcopy("v")<CR>'
		exe "amenu          ".s:Perl_Root.'&Run.-SEP6-                           :'
		exe "amenu <silent> ".s:Perl_Root.'&Run.settings\ and\ hot\ &keys        <C-C>:call Perl_Settings()<CR>'
		"
		exe "amenu  <silent>  ".s:Perl_Root.'&Run.x&term\ size                             <C-C>:call Perl_XtermSize()<CR>'
		if s:Perl_OutputGvim == "vim" 
			exe "amenu  <silent>  ".s:Perl_Root.'&Run.output:\ VIM->&buffer->xterm            <C-C>:call Perl_Toggle_Gvim_Xterm()<CR><CR>'
		else
			if s:Perl_OutputGvim == "buffer" 
				exe "amenu  <silent>  ".s:Perl_Root.'&Run.output:\ BUFFER->&xterm->vim        <C-C>:call Perl_Toggle_Gvim_Xterm()<CR><CR>'
			else
				exe "amenu  <silent>  ".s:Perl_Root.'&Run.output:\ XTERM->&vim->buffer          <C-C>:call Perl_Toggle_Gvim_Xterm()<CR><CR>'
			endif
		endif
		"
	endif
	"
	"--------------------------------------------------------------------------------------------
	"
endfunction			" function Perl_InitMenu
"
"
"------------------------------------------------------------------------------
"-----   variables for internal use   -----------------------------------------
"------------------------------------------------------------------------------
"
let s:Perl_Active       = -1				" state variable controlling the Perl-menus
"
"
"------------------------------------------------------------------------------
"  Input after a highlighted prompt
"------------------------------------------------------------------------------
function! Perl_Input ( promp, text )
  echohl Search                       " highlight prompt
  call inputsave()                    " preserve typeahead
  let retval=input( a:promp, a:text ) " read input
  call inputrestore()                 " restore typeahead
  echohl None                         " reset highlighting
  return retval
endfunction
"
"------------------------------------------------------------------------------
"  Comments : multi line-end comments
"------------------------------------------------------------------------------
function! Perl_MultiLineEndComments ()
	let pos0	= line("'<")
	let pos1	= line("'>")
	" ----- trim whitespaces -----
	exe "'<,'>s/\s\*$//"
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
	let	maxlength	= maxlength-1
	let	maxlength	= ((maxlength + &tabstop)/&tabstop)*&tabstop
	" ----- fill lines with tabs -----
	let	linenumber	= pos0
	normal '<
	while linenumber <= pos1
		if getline(".") !~ "^\\s*$"
			let ll		= virtcol("$")-1
			let diff	= (maxlength-ll)/&tabstop
			if ll%(&tabstop)!=0
				let diff	= diff + 1
			endif
			while diff>0
				exe "normal	$A	"
				let diff=diff-1
			endwhile
			exe "normal	$a# "
		endif
		let linenumber=linenumber+1
		normal j
	endwhile
	" ----- back to the beginning of the marked block -----
	normal '<
endfunction
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
		endwhile
		call setline( linenumber, line )
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

	if a:arg=='module'
		let templatefile=s:Perl_Template_Directory.s:Perl_Template_Module
	endif


	if filereadable(templatefile)
		let	length= line("$")
		let	pos1  = line(".")+1
		"
		" Prevent the alternate buffer from being set to this files
		"
		let l:old_cpoptions	= &cpoptions
		setlocal cpo-=a
		if  a:arg=='header'|| a:arg=='module' 
			:goto 1
			let	pos1  = 1
			exe '0read '.templatefile
		else
			exe 'read '.templatefile
		endif
		let &cpoptions	= l:old_cpoptions		" restore previous options
		"
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
	put = '# vim: set tabstop='.&tabstop.' shiftwidth='.&shiftwidth.': '
endfunction    " ----------  end of function Perl_CommentVimModeline  ----------
"
"------------------------------------------------------------------------------
"  Statements : subroutine
"------------------------------------------------------------------------------
function! Perl_CodeFunction ()
	let	identifier=Perl_Input("subroutine name : ", "" )
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

	let	filehandle=Perl_Input("input file handle : ", "INFILE")
	
	if filehandle==""
		let	filehandle	= "INFILE"
	endif
	
	let filename=filehandle."_file_name"

	let zz=    "my\t$".filename." = \'\';\t\t# input file name\n\n"
	let zz= zz."open ( ".filehandle.", \'<\', $".filename." )\n"
	let zz= zz."\tor die \"$0 : failed to open input file $".filename." : $!\\n\";\n\n\n"
	let zz= zz."close ( ".filehandle." );\t\t\t# close input file\n"
	exe "imenu ".s:Perl_Root.'I&dioms.<'.filehandle.'>      <'.filehandle.'><ESC>a'
	put =zz
	normal =6+
	normal f'
endfunction
"
"------------------------------------------------------------------------------
"  Perl-Idioms : CodeOpenWrite
"------------------------------------------------------------------------------
function! Perl_CodeOpenWrite ()

	let	filehandle=Perl_Input("output file handle : ", "OUTFILE")
	
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
	exe "imenu ".s:Perl_Root.'I&dioms.print\ '.filehandle.'\ "\\n";    print '.filehandle.' "\n";<ESC>3hi'
	normal f'
endfunction
"
"------------------------------------------------------------------------------
"  Perl-Idioms : CodeOpenPipe
"------------------------------------------------------------------------------
function! Perl_CodeOpenPipe ()

	let	filehandle=Perl_Input("pipe handle : ", "PIPE")

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
				let	linesread= line("$")
				"
				" Prevent the alternate buffer from being set to this files
				let l:old_cpoptions	= &cpoptions
				setlocal cpo-=a
				:execute "read ".l:snippetfile
				let &cpoptions	= l:old_cpoptions		" restore previous options
				"
				let	linesread= line("$")-linesread-1
				if linesread>=0 && match( l:snippetfile, '\.\(ni\|noindent\)$' ) < 0 
					silent exe "normal =".linesread."+"
				endif
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
			let	l:snippetfile=browse(0,"write a code snippet",s:Perl_CodeSnippets,"")
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
		redraw
		echohl ErrorMsg
		echo "code snippet directory ".s:Perl_CodeSnippets." does not exist"
		echohl None
	endif
endfunction
"
"------------------------------------------------------------------------------
"  Perl-Run : Perl_perldoc - try word under the cursor or ask
"------------------------------------------------------------------------------
"
let s:Perl_PerldocHelpBuffer=-1
let s:Perl_PerldocModulelistBuffer=-1
"
function! Perl_perldoc(arg)

	let	buffername	= getcwd()."/".bufname("%")
	if( buffername == s:Perl_PerlModuleList )
		normal 0
		let	item=expand("<cWORD>")				" WORD under the cursor 
	else
		let	item=expand("<cword>")				" word under the cursor 
	endif
	if  item == ""
		let	item=Perl_Input("perldoc - module, function or FAQ keyword : ", "")
	endif

	"------------------------------------------------------------------------------
	"  replace buffer content with Perl documentation
	"------------------------------------------------------------------------------
	if item != ""
		"
		" jump to an already open perldoc window or create one
		" 
		if bufloaded("PERLDOC") && bufwinnr(s:Perl_PerldocHelpBuffer)!=-1
			exe bufwinnr(s:Perl_PerldocHelpBuffer) . "wincmd w"
			" buffer number may have changed, e.g. after a 'save as' 
			if bufnr("%") != s:Perl_PerldocHelpBuffer
				let s:Perl_PerldocHelpBuffer=bufnr(s:Perl_OutputBufferName)
				exe ":bn ".s:Perl_PerldocHelpBuffer
			endif
		else
			exe ":new PERLDOC"
			let s:Perl_PerldocHelpBuffer=bufnr("%")
			setlocal buftype=nofile
			setlocal noswapfile
			setlocal filetype=perl
			setlocal syntax=none
			setlocal bufhidden=delete
		endif
		"
		" search order:
		"  (1)  library module
		"  (2)  builtin function
		"  (3)  FAQ keyword
		" 
		setlocal	modifiable
		silent exe ":%!perldoc ".item
		if v:shell_error != 0
			redraw!
			silent exe ":%!perldoc -f ".item
			if v:shell_error != 0
				redraw!
				silent exe ":%!perldoc -q ".item
				if v:shell_error != 0
					redraw!
					let zz=   "No documentation found for perl module, perl function or perl FAQ keyword\n"
					let zz=zz."  '".item."'  "
					silent put!	=zz
					normal	2jdd$
				endif
			endif
		endif

		setlocal nomodifiable
		redraw!
	endif
endfunction
"
"------------------------------------------------------------------------------
"  Perl-Run : Perl_perldoc - show module list
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
		silent exe "view ".s:Perl_PerlModuleList
		let s:Perl_PerldocModulelistBuffer=bufnr("%")
		setlocal nomodifiable
	endif
	silent exe ":set filetype=perl"
	silent exe ":syntax clear"
	normal gg
	redraw
	echohl Search | echomsg 'use S-F1 to show a manual' | echohl None
endfunction
"
"------------------------------------------------------------------------------
"  Perl-Run : Perl_perldoc - generate module list
"------------------------------------------------------------------------------
function! Perl_perldoc_generate_module_list()
	echohl Search
	echo " ... generating Perl module list ... " 
	setlocal modifiable
	silent exe ":!".s:Perl_PerlModuleListGenerator
	setlocal nomodifiable
	echo " DONE " 
	echohl None
endfunction
"
"------------------------------------------------------------------------------
"  Run : settings
"------------------------------------------------------------------------------
function! Perl_Settings ()
	let	txt =     "  Perl-Support settings\n\n"
	let txt = txt."            author name  :  ".s:Perl_AuthorName."\n"
	let txt = txt."               initials  :  ".s:Perl_AuthorRef."\n"
	let txt = txt."                  email  :  ".s:Perl_Email."\n"
	let txt = txt."                company  :  ".s:Perl_Company."\n"
	let txt = txt."                project  :  ".s:Perl_Project."\n"
	let txt = txt."       copyright holder  :  ".s:Perl_CopyrightHolder."\n"
	let txt = txt." code snippet directory  :  ".s:Perl_CodeSnippets."\n"
	let txt = txt."     template directory  :  ".s:Perl_Template_Directory."\n"
	if g:Perl_Dictionary_File != ""
		let ausgabe = substitute( g:Perl_Dictionary_File, ",", ",\n                         + ", "g" )
		let txt     = txt."      dictionary file(s) :  ".ausgabe."\n"
	endif
	let txt = txt."    Additional hot keys\n\n"
	let txt = txt."               Shift-F1  :  read perldoc (for word under cursor)\n"
	let txt = txt."                Ctrl-F9  :  update file, run script           \n"
	let txt = txt."                     F9  :  start Perl debugger               \n"
	let txt = txt."                 Alt-F9  :  update file, run syntax check     \n\n"
	let txt = txt."_________________________________________________________________________\n"
	let	txt = txt." Perl-Support, Version ".g:Perl_Version." / Dr.-Ing. Fritz Mehner / mehner@fh-swf.de\n\n"
	echo txt
endfunction
"
"------------------------------------------------------------------------------
"  run : syntax check
"------------------------------------------------------------------------------
"
let s:Perl_SyntaxCheckMsg       = ""
"
function! Perl_SyntaxCheck ()
	let s:Perl_SyntaxCheckMsg = ""
	exe	":cclose"
	let	l:currentbuffer=bufname("%")
	silent exe	":update"
	exe	"set makeprg=perl"
	" 
	" match the Perl error messages (quickfix commands)
	" errorformat will be reset by function Perl_Handle()
	" 
	" ignore any lines that didn't match one of the patterns
	" 
	exe	':setlocal errorformat=%m\ at\ %f\ line\ %l%.%#,%-G%.%#'
	exe	"make -wc %"
	exe	":botright cwindow"
	exe	':setlocal errorformat='
	exe	"set makeprg=make"
	"
	" message in case of success
	"
	if l:currentbuffer ==  bufname("%")
		let s:Perl_SyntaxCheckMsg = l:currentbuffer." : Syntax is OK"
	endif
endfunction
"
function! Perl_SyntaxCheckMsg ()
		echohl Search 
		echo s:Perl_SyntaxCheckMsg
		echohl None
endfunction
"
"----------------------------------------------------------------------
"  run : toggle output destination
"----------------------------------------------------------------------
function! Perl_Toggle_Gvim_Xterm ()
	
	if s:Perl_OutputGvim == "vim"
		exe "aunmenu  <silent>  ".s:Perl_Root.'&Run.output:\ VIM->&buffer->xterm'
		exe "amenu    <silent>  ".s:Perl_Root.'&Run.output:\ BUFFER->&xterm->vim              <C-C>:call Perl_Toggle_Gvim_Xterm()<CR><CR>'
		let	s:Perl_OutputGvim	= "buffer"
	else
		if s:Perl_OutputGvim == "buffer"
			exe "aunmenu  <silent>  ".s:Perl_Root.'&Run.output:\ BUFFER->&xterm->vim'
			exe "amenu    <silent>  ".s:Perl_Root.'&Run.output:\ XTERM->&vim->buffer             <C-C>:call Perl_Toggle_Gvim_Xterm()<CR><CR>'
			let	s:Perl_OutputGvim	= "xterm"
		else
			" ---------- output : xterm -> gvim
			exe "aunmenu  <silent>  ".s:Perl_Root.'&Run.output:\ XTERM->&vim->buffer'
			exe "amenu    <silent>  ".s:Perl_Root.'&Run.output:\ VIM->&buffer->xterm            <C-C>:call Perl_Toggle_Gvim_Xterm()<CR><CR>'
			let	s:Perl_OutputGvim	= "vim"
		endif
	endif

endfunction    " ----------  end of function Perl_Toggle_Gvim_Xterm  ----------
"
"------------------------------------------------------------------------------
"  run : run
"------------------------------------------------------------------------------
"
let s:Perl_OutputBufferName   = "Perl-Output"
let s:Perl_OutputBufferNumber = -1
"
function! Perl_Run ()
	"
	let	l:currentbuffer		= bufname("%")
	let	l:currentbuffernr	= bufnr("%")
	let l:currentdir			= getcwd()
	let	l:arguments				= exists("b:Perl_CmdLineArgs") ? " ".b:Perl_CmdLineArgs : ""
	"
	silent exe ":update"
	"
	"------------------------------------------------------------------------------
	"  run : run from the vim command line
	"------------------------------------------------------------------------------
	if s:Perl_OutputGvim == "vim"
		"
		exe "!./%".l:arguments
		"
	endif
	"
	"------------------------------------------------------------------------------
	"  run : redirect output to an output buffer
	"------------------------------------------------------------------------------
	if s:Perl_OutputGvim == "buffer"
		if l:currentbuffer ==  bufname("%")
			"
			let l:fullname=l:currentdir."/".l:currentbuffer
			"
			if bufloaded(s:Perl_OutputBufferName) != 0 && bufwinnr(s:Perl_OutputBufferNumber)!=-1 
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
			endif
			"
			setlocal	modifiable
			silent exe ":update | %!".l:fullname.l:arguments
			setlocal	nomodifiable
			"
			" stdout is empty / not empty
			"
			normal G
			if line("$")==1 && col("$")==1
				silent	exe ":bdelete"
			else
				if winheight(winnr()) >= line("$")
					exe bufwinnr(l:currentbuffernr) . "wincmd w"
				endif
			endif
		endif
	endif
	"
	"------------------------------------------------------------------------------
	"  run : run in a xterm
	"------------------------------------------------------------------------------
	if s:Perl_OutputGvim == "xterm"
		"
		let script	= expand("%")
		silent exe "!xterm -title ".script." ".s:Perl_XtermDefaults." -e $HOME/.vim/plugin/wrapper.sh ./".script.l:arguments.' &'
		"
	endif
	"
endfunction    " ----------  end of function Perl_Run  ----------
"
"------------------------------------------------------------------------------
"  run : start debugger
"------------------------------------------------------------------------------
function! Perl_Debugger ()
	"
	silent exe	":update"
	let	l:arguments				= exists("b:Perl_CmdLineArgs") ? " ".b:Perl_CmdLineArgs : ""
	"
	" debugger is ' perl -d ... '
	"
	if s:Perl_Debugger == "perl"
		silent exe "!xterm ".s:Perl_XtermDefaults.' -e perl -d ./'.expand("%").l:arguments.' &'
	endif
	"
	" debugger is 'ptkdb'
	"
	if s:Perl_Debugger == "ptkdb"
		silent exe '!perl -d:ptkdb  ./'.expand("%").l:arguments.' &'
	endif
	"
	" debugger is 'ddd'
	"
	if s:Perl_Debugger == "ddd"
		silent exe '!ddd ./'.expand("%").l:arguments.' &'
	endif
	"
endfunction
"
"------------------------------------------------------------------------------
"  run : Arguments
"------------------------------------------------------------------------------
function! Perl_Arguments ()
	let	prompt	= 'command line arguments for "'.expand("%").'" : '
	if exists("b:Perl_CmdLineArgs")
		let	b:Perl_CmdLineArgs= Perl_Input( prompt, b:Perl_CmdLineArgs )
	else
		let	b:Perl_CmdLineArgs= Perl_Input( prompt , "" )
	endif
endfunction
"
"------------------------------------------------------------------------------
"  run : xterm geometry
"------------------------------------------------------------------------------
function! Perl_XtermSize ()
	let regex	= '-geometry\s\+\d\+x\d\+'
	let geom	= matchstr( s:Perl_XtermDefaults, regex )
	let geom	= matchstr( geom, '\d\+x\d\+' )
	let geom	= substitute( geom, 'x', ' ', "" )
	let	answer= Perl_Input("   xterm size (COLUMNS LINES) : ", geom )
	while match(answer, '^\s*\d\+\s\+\d\+\s*$' ) < 0
		let	answer= Perl_Input(" + xterm size (COLUMNS LINES) : ", geom )
	endwhile
	let answer  = substitute( answer, '^\s\+', "", "" )		 				" remove leading whitespaces
	let answer  = substitute( answer, '\s\+$', "", "" )						" remove trailing whitespaces
	let answer  = substitute( answer, '\s\+', "x", "" )						" replace inner whitespaces
	let s:Perl_XtermDefaults	= substitute( s:Perl_XtermDefaults, regex, "-geometry ".answer , "" )
endfunction
"
"------------------------------------------------------------------------------
"  run : make script executable
"------------------------------------------------------------------------------
function! Perl_MakeScriptExecutable ()
	silent exe "!chmod u+x %"
	redraw
	if v:shell_error
		echohl WarningMsg
	  echo 'Could not make '.expand("%").' executable !'
	else
		echohl Search
	  echo 'Made '.expand("%").' executable.'
	endif
	echohl None
endfunction
"
"------------------------------------------------------------------------------
"  run : POD -> html / man / text
"------------------------------------------------------------------------------
function! Perl_POD (arg1)
	let	filename	= expand("%:r").".".a:arg1
	silent exe	":update"
	silent exe	":!pod2".a:arg1." ".expand("%")." > ".filename
	echo  " '".getcwd()."/".filename."' generated"
endfunction
"
"------------------------------------------------------------------------------
"  run : perltidy
"------------------------------------------------------------------------------
function! Perl_Perltidy (arg1)
	if !executable("perltidy")
		echohl WarningMsg
	  echo 'perltidy dos not exist or is not executable!'
		echohl None
		return
	endif

	silent exe	":update"
	let	Sou		= expand("%")								" name of the file in the current buffer
	" ----- normal mode ----------------
	if a:arg1=="n"
		let	pos1  = line(".")
		silent exe	"%!perltidy"		
		exe ':'.pos1
		echo "file \"".Sou."\" reformatted"
	endif
	" ----- visual mode ----------------
	if a:arg1=="v"
		let	pos1	= line("'<")
		let	pos2	= line("'>")
		silent exe	pos1.",".pos2."!perltidy"
		echo "file \"".Sou."\" (lines ".pos1."-".pos2.") reformatted"
	endif
endfunction
"
"------------------------------------------------------------------------------
"  run : hardcopy
"------------------------------------------------------------------------------
function! Perl_Hardcopy (arg1)
	let target	= bufname("%")=='PERLDOC' ? '$HOME/' : './'
	let	Sou			= target.expand("%")					" name of the file in the current buffer
	" ----- normal mode ----------------
	if a:arg1=="n"
		silent exe	"hardcopy > ".Sou.".ps"		
		echo "file \"".Sou."\" printed to \"".Sou.".ps\""
	endif
	" ----- visual mode ----------------
	if a:arg1=="v"
		silent exe	"*hardcopy > ".Sou.".ps"		
		echo "file \"".Sou."\" (lines ".line("'<")."-".line("'>").") printed to \"".Sou.".ps\""
	endif
endfunction
"

"------------------------------------------------------------------------------
"	 Create the load/unload entry in the GVIM tool menu, depending on 
"	 which script is already loaded
"------------------------------------------------------------------------------
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
			if s:Perl_Root == ""
				aunmenu Comments
				aunmenu Statements
				aunmenu Idioms
				aunmenu Regex
				aunmenu CharCls
				aunmenu File-Tests
				aunmenu Spec-Var
				aunmenu POD
				aunmenu Run
			else
				exe "aunmenu ".s:Perl_Root
			endif
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
	call Perl_Handle()										" load the menus
endif
"
"------------------------------------------------------------------------------
"  Automated header insertion
"------------------------------------------------------------------------------
if has("autocmd")
	" 
	" =====  Perl-script : insert header, write file, make it executable  =============
	if has('win32')
		autocmd BufNewFile  *.pl  call Perl_CommentTemplates('header') | :w! 
	else
		autocmd BufNewFile  *.pl  call Perl_CommentTemplates('header') | :w! | call Perl_MakeScriptExecutable()
	endif
	" 
	" =====  Perl module : insert header, write file  =================================
	autocmd BufNewFile  *.pm  call Perl_CommentTemplates('module') | :w!
	" 
	" =====  Perl POD module : set filetype to Perl  ==================================
	autocmd BufNewFile,BufRead *.pod  set filetype=perl
	"
endif " has("autocmd")
"
"------------------------------------------------------------------------------
"  Key mappings : show / hide the perl-support menus
"------------------------------------------------------------------------------
nmap    <silent>  <Leader>lps             :call Perl_Handle()<CR>
nmap    <silent>  <Leader>ups             :call Perl_Handle()<CR>
"
" vim:set tabstop=2: 
