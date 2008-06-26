" Vim filetype plugin file
"
"   Language :  Perl
"     Plugin :  perl-support.vim (version 3.8.1)
" Maintainer :  Fritz Mehner <mehner@fh-swf.de>
"   Revision :  $Id: perl.vim,v 1.32 2008/06/25 08:50:19 mehner Exp $
"
" ----------------------------------------------------------------------------
"
" Only do this when not done yet for this buffer
" 
if exists("b:did_PERL_ftplugin")
  finish
endif
let b:did_PERL_ftplugin = 1
"
let s:UNIX	= has("unix") || has("macunix") || has("win32unix")
let s:MSWIN = has("win16") || has("win32")   || has("win64")    || has("win95")
"
" ---------- tabulator / shiftwidth ------------------------------------------
"  Set tabulator and shift width to 4 conforming to the Perl Style Guide.
"  Uncomment the next two lines to force these settings for all files with
"  filetype 'perl' .
"  
setlocal  tabstop=4
setlocal  shiftwidth=4
"
" ---------- Add ':' to the keyword characters -------------------------------
"            Tokens like 'File::Find' are recognized as 
"            one keyword
" 
setlocal iskeyword+=:
"
" ---------- Perl dictionary -------------------------------------------------
" This will enable keyword completion for Perl
" using Vim's dictionary feature |i_CTRL-X_CTRL-K|.
"
if exists("g:Perl_Dictionary_File")
    silent! exec 'setlocal dictionary+='.g:Perl_Dictionary_File
endif    
"
" ---------- Brace handling --------------------------------------------------
"  
let s:Perl_BraceOnNewLine          = "no"
if exists('g:Perl_BraceOnNewLine')
  let s:Perl_BraceOnNewLine=g:Perl_BraceOnNewLine
endif
"
command! -nargs=? CriticOptions					call Perl_PerlCriticOptions  (<f-args>)
command! -nargs=1 CriticSeverity				call Perl_PerlCriticSeverity (<f-args>)
command! -nargs=1 CriticVerbosity				call Perl_PerlCriticVerbosity(<f-args>)
command! -nargs=1 RegexSubstitutions		call Perl_PerlRegexSubstitutions(<f-args>)
"
"command! -nargs=1 RegexCodeEvaluation		call Perl_RegexCodeEvaluation(<f-args>)
"
" ---------- Key mappings : function keys ------------------------------------
"
"   Ctrl-F9   run script
"    Alt-F9   run syntax check
"  Shift-F9   set command line arguments
"  Shift-F1   read Perl documentation
" Vim (non-GUI) : shifted keys are mapped to their unshifted key !!!
" 
if has("gui_running")
  "
   map    <buffer>  <silent>  <A-F9>             :call Perl_SyntaxCheck()<CR>:redraw!<CR>:call Perl_SyntaxCheckMsg()<CR>
  imap    <buffer>  <silent>  <A-F9>        <C-C>:call Perl_SyntaxCheck()<CR>:redraw!<CR>:call Perl_SyntaxCheckMsg()<CR>
  "
   map    <buffer>  <silent>  <C-F9>             :call Perl_Run()<CR>
  imap    <buffer>  <silent>  <C-F9>        <C-C>:call Perl_Run()<CR>
  "
   map    <buffer>  <silent>  <S-F9>             :call Perl_Arguments()<CR>
  imap    <buffer>  <silent>  <S-F9>        <C-C>:call Perl_Arguments()<CR>
  "
   map    <buffer>  <silent>  <S-F1>             :call Perl_perldoc()<CR><CR>
  imap    <buffer>  <silent>  <S-F1>        <C-C>:call Perl_perldoc()<CR><CR>
endif
"
"-------------------------------------------------------------------------------
"   Key mappings for menu entries
"   The mappings can be switched on and off by g:Perl_NoKeyMappings
"-------------------------------------------------------------------------------
"
if !exists("g:Perl_NoKeyMappings") || ( exists("g:Perl_NoKeyMappings") && g:Perl_NoKeyMappings!=1 )
	"
	" ----------------------------------------------------------------------------
	" Comments
	" ----------------------------------------------------------------------------
	"
	inoremap    <buffer>  <silent>  <Leader>cj    <C-C>:call Perl_AlignLineEndComm("a")<CR>a
	inoremap    <buffer>  <silent>  <Leader>cl    <C-C>:call Perl_LineEndComment("")<CR>A
	nnoremap    <buffer>  <silent>  <Leader>cj         :call Perl_AlignLineEndComm("a")<CR>
	nnoremap    <buffer>  <silent>  <Leader>cl         :call Perl_LineEndComment("")<CR>A
	vnoremap    <buffer>  <silent>  <Leader>cj    <C-C>:call Perl_AlignLineEndComm("v")<CR>
	vnoremap    <buffer>  <silent>  <Leader>cl    <C-C>:call Perl_MultiLineEndComments()<CR>A

	nnoremap    <buffer>  <silent>  <Leader>cs         :call Perl_GetLineEndCommCol()<CR>

	nnoremap    <buffer>  <silent>  <Leader>cfr        :call Perl_CommentTemplates('frame')<CR>
	nnoremap    <buffer>  <silent>  <Leader>cfu        :call Perl_CommentTemplates('function')<CR>
	nnoremap    <buffer>  <silent>  <Leader>cm         :call Perl_CommentTemplates('method')<CR>
	nnoremap    <buffer>  <silent>  <Leader>ch         :call Perl_CommentTemplates('header')<CR>
	nnoremap    <buffer>  <silent>  <Leader>ce         :call Perl_CommentTemplates('module')<CR>
	nnoremap    <buffer>  <silent>  <Leader>ca         :call Perl_CommentTemplates('test')<CR>

	inoremap    <buffer>  <silent>  <Leader>cfr   <C-C>:call Perl_CommentTemplates('frame')<CR>
	inoremap    <buffer>  <silent>  <Leader>cfu   <C-C>:call Perl_CommentTemplates('function')<CR>
	inoremap    <buffer>  <silent>  <Leader>cm    <C-C>:call Perl_CommentTemplates('method')<CR>
	inoremap    <buffer>  <silent>  <Leader>ch    <C-C>:call Perl_CommentTemplates('header')<CR>
	inoremap    <buffer>  <silent>  <Leader>ce    <C-C>:call Perl_CommentTemplates('module')<CR>
	inoremap    <buffer>  <silent>  <Leader>ca    <C-C>:call Perl_CommentTemplates('test')<CR>

	nnoremap    <buffer>  <silent>  <Leader>ckb        :call Perl_CommentClassified("BUG")       <CR>A
	nnoremap    <buffer>  <silent>  <Leader>ckt        :call Perl_CommentClassified("TODO")      <CR>A
	nnoremap    <buffer>  <silent>  <Leader>ckr        :call Perl_CommentClassified("TRICKY")    <CR>A
	nnoremap    <buffer>  <silent>  <Leader>ckw        :call Perl_CommentClassified("WARNING")   <CR>A
	nnoremap    <buffer>  <silent>  <Leader>cko        :call Perl_CommentClassified("WORKAROUND")<CR>A
	nnoremap    <buffer>  <silent>  <Leader>ckn        :call Perl_CommentClassified("")          <CR>3F:i
                                                
	inoremap    <buffer>  <silent>  <Leader>ckb   <C-C>:call Perl_CommentClassified("BUG")       <CR>A
	inoremap    <buffer>  <silent>  <Leader>ckt   <C-C>:call Perl_CommentClassified("TODO")      <CR>A
	inoremap    <buffer>  <silent>  <Leader>ckr   <C-C>:call Perl_CommentClassified("TRICKY")    <CR>A
	inoremap    <buffer>  <silent>  <Leader>ckw   <C-C>:call Perl_CommentClassified("WARNING")   <CR>A
	inoremap    <buffer>  <silent>  <Leader>cko   <C-C>:call Perl_CommentClassified("WORKAROUND")<CR>A
	inoremap    <buffer>  <silent>  <Leader>ckn   <C-C>:call Perl_CommentClassified("")          <CR>3F:i

	nnoremap    <buffer>  <silent>  <Leader>cc         :call Perl_CommentToggle()<CR>j
	vnoremap    <buffer>  <silent>  <Leader>cc    <C-C>:'<,'>call Perl_CommentToggle()<CR>j

	nnoremap    <buffer>  <silent>  <Leader>cd    a<C-R>=strftime("%x")<CR>
	nnoremap    <buffer>  <silent>  <Leader>ct    a<C-R>=strftime("%x %X %Z")<CR>
	inoremap    <buffer>  <silent>  <Leader>cd    <C-R>=strftime("%x")<CR>
	inoremap    <buffer>  <silent>  <Leader>ct    <C-R>=strftime("%x %X %Z")<CR>

	nnoremap    <buffer>  <silent>  <Leader>cv         :call Perl_CommentVimModeline()<CR>
	nnoremap    <buffer>  <silent>  <Leader>cb         :call Perl_CommentBlock("a")<CR>
	vnoremap    <buffer>  <silent>  <Leader>cb    <C-C>:call Perl_CommentBlock("v")<CR>
	nnoremap    <buffer>  <silent>  <Leader>cn         :call Perl_UncommentBlock()<CR>
	"
	" ----------------------------------------------------------------------------
	" Statements
	" ----------------------------------------------------------------------------
	"
	nnoremap    <buffer>  <silent>  <Leader>sd              :call Perl_DoWhile("a")<CR>f(la
	nnoremap    <buffer>  <silent>  <Leader>sf              :call Perl_StatBlock( "a", "for ( my $; ;  ) {\n}","" )<CR>f$a
	nnoremap    <buffer>  <silent>  <Leader>sfe             :call Perl_StatBlock( "a", "foreach my $ (  ) {\n}", "" )<CR>f$a
	nnoremap    <buffer>  <silent>  <Leader>si              :call Perl_StatBlock( "a", "if (  ) {\n}", "" )<CR>f(la
	nnoremap    <buffer>  <silent>  <Leader>sie             :call Perl_StatBlock( "a", "if (  ) {\n}\nelse {\n}", "" )<CR>f(la
	nnoremap    <buffer>  <silent>  <Leader>su              :call Perl_StatBlock( "a", "unless (  ) {\n}", "" )<CR>f(la
	nnoremap    <buffer>  <silent>  <Leader>sue             :call Perl_StatBlock( "a", "unless (  ) {\n}\nelse {\n}", "" )<CR>f(la
	nnoremap    <buffer>  <silent>  <Leader>st              :call Perl_StatBlock( "a", "until (  ) {\n}", "" )<CR>f(la
	nnoremap    <buffer>  <silent>  <Leader>sw              :call Perl_StatBlock( "a", "while (  ) {\n}", "" )<CR>f(la
	nnoremap    <buffer>  <silent>  <Leader>s{              :call Perl_Block("a")<CR>o

	vnoremap    <buffer>  <silent>  <Leader>sd    <C-C>:call Perl_DoWhile("v")<CR>f(la
	vnoremap    <buffer>  <silent>  <Leader>sf    <C-C>:call Perl_StatBlock( "v", "for ( my $; ;  ) {", "}" )<CR>f$a
	vnoremap    <buffer>  <silent>  <Leader>sfe   <C-C>:call Perl_StatBlock( "v", "foreach my $ (  ) {", "}" )<CR>f$a
	vnoremap    <buffer>  <silent>  <Leader>si    <C-C>:call Perl_StatBlock( "v", "if (  ) {", "}" )<CR>f(la
	vnoremap    <buffer>  <silent>  <Leader>sie   <C-C>:call Perl_StatBlock( "v", "if (  ) {", "}\nelse {\n}" )<CR>f(la
	vnoremap    <buffer>  <silent>  <Leader>su    <C-C>:call Perl_StatBlock( "v", "unless (  ) {", "}" )<CR>f(la
	vnoremap    <buffer>  <silent>  <Leader>sue   <C-C>:call Perl_StatBlock( "v", "unless (  ) {", "}\nelse {\n}" )<CR>f(la
	vnoremap    <buffer>  <silent>  <Leader>st    <C-C>:call Perl_StatBlock( "v", "until (  ) {", "}" )<CR>f(la
	vnoremap    <buffer>  <silent>  <Leader>sw    <C-C>:call Perl_StatBlock( "v", "while (  ) {", "}" )<CR>f(la
	vnoremap    <buffer>  <silent>  <Leader>s{    <C-C>:call Perl_Block("v")<CR>

	inoremap    <buffer>  <silent>  <Leader>sd    <C-C>:call Perl_DoWhile("a")<CR>f(la
	inoremap    <buffer>  <silent>  <Leader>sf    <C-C>:call Perl_StatBlock( "a", "for ( my $; ;  ) {\n}","" )<CR>f$a
	inoremap    <buffer>  <silent>  <Leader>sfe   <C-C>:call Perl_StatBlock( "a", "foreach my $ (  ) {\n}", "" )<CR>f$a
	inoremap    <buffer>  <silent>  <Leader>si    <C-C>:call Perl_StatBlock( "a", "if (  ) {\n}", "" )<CR>f(la
	inoremap    <buffer>  <silent>  <Leader>sie   <C-C>:call Perl_StatBlock( "a", "if (  ) {\n}\nelse {\n}", "" )<CR>f(la
	inoremap    <buffer>  <silent>  <Leader>su    <C-C>:call Perl_StatBlock( "a", "unless (  ) {\n}", "" )<CR>f(la
	inoremap    <buffer>  <silent>  <Leader>sue   <C-C>:call Perl_StatBlock( "a", "unless (  ) {\n}\nelse {\n}", "" )<CR>f(la
	inoremap    <buffer>  <silent>  <Leader>st    <C-C>:call Perl_StatBlock( "a", "until (  ) {\n}", "" )<CR>f(la
	inoremap    <buffer>  <silent>  <Leader>sw    <C-C>:call Perl_StatBlock( "a", "while (  ) {\n}", "" )<CR>f(la
	"
	nnoremap    <buffer>  <silent>  <Leader>nr    <C-C>:call Perl_CodeSnippet("r")<CR>
	nnoremap    <buffer>  <silent>  <Leader>nw    <C-C>:call Perl_CodeSnippet("w")<CR>
	vnoremap    <buffer>  <silent>  <Leader>nw    <C-C>:call Perl_CodeSnippet("wv")<CR>
	nnoremap    <buffer>  <silent>  <Leader>ne    <C-C>:call Perl_CodeSnippet("e")<CR>
	"
	" ----------------------------------------------------------------------------
	" Idioms
	" ----------------------------------------------------------------------------
	"	
	nnoremap    <buffer>  <silent>  <Leader>$    o<C-C>:call Perl_Idiom(  '\$', 'my<Tab>$;',                       '$' )<CR>a
	nnoremap    <buffer>  <silent>  <Leader>$=   o<C-C>:call Perl_Idiom( '\$=', 'my<Tab>$<Tab>= ;',                '$' )<CR>a
	nnoremap    <buffer>  <silent>  <Leader>$$   o<C-C>:call Perl_Idiom( '\$$', 'my<Tab>( $, $ );',                '$' )<CR>a
	nnoremap    <buffer>  <silent>  <Leader>@    o<C-C>:call Perl_Idiom(  '\@', 'my<Tab>@;',                       '@' )<CR>a
	nnoremap    <buffer>  <silent>  <Leader>@=   o<C-C>:call Perl_Idiom( '\@=', 'my<Tab>@<Tab>= ( , ,  );',        '@' )<CR>a
	nnoremap    <buffer>  <silent>  <Leader>%    o<C-C>:call Perl_Idiom(  '\%', 'my<Tab>%;',                       '%' )<CR>a
	nnoremap    <buffer>  <silent>  <Leader>%=   o<C-C>:call Perl_Idiom( '\%=', 'my<Tab>%<Tab>= (  => ,  => , );', '%' )<CR>a
	"	
	inoremap    <buffer>  <silent>  <Leader>$    <C-C>:call Perl_Idiom(  '\$', 'my<Tab>$;',                       '$' )<CR>a
	inoremap    <buffer>  <silent>  <Leader>$=   <C-C>:call Perl_Idiom( '\$=', 'my<Tab>$<Tab>= ;',                '$' )<CR>a
	inoremap    <buffer>  <silent>  <Leader>$$   <C-C>:call Perl_Idiom( '\$$', 'my<Tab>( $, $ );',                '$' )<CR>a
	inoremap    <buffer>  <silent>  <Leader>@    <C-C>:call Perl_Idiom(  '\@', 'my<Tab>@;',                       '@' )<CR>a
	inoremap    <buffer>  <silent>  <Leader>@=   <C-C>:call Perl_Idiom( '\@=', 'my<Tab>@<Tab>= ( , ,  );',        '@' )<CR>a
	inoremap    <buffer>  <silent>  <Leader>%    <C-C>:call Perl_Idiom(  '\%', 'my<Tab>%;',                       '%' )<CR>a
	inoremap    <buffer>  <silent>  <Leader>%=   <C-C>:call Perl_Idiom( '\%=', 'my<Tab>%<Tab>= (  => ,  => , );', '%' )<CR>a
	"
	nnoremap    <buffer>  <silent>  <Leader>ir    omy<Tab>$rgx_<Tab>= q//;<Esc>F_a
	inoremap    <buffer>  <silent>  <Leader>ir     my<Tab>$rgx_<Tab>= q//;<Esc>F_a

	if exists("g:Perl_PBP") && g:Perl_PBP == "yes"
		nnoremap    <buffer>  <silent>  <Leader>im    a$ =~ m{}xm<Esc>F$a
		nnoremap    <buffer>  <silent>  <Leader>is    a$ =~ s{}{}xm<Esc>F$a
		nnoremap    <buffer>  <silent>  <Leader>it    a$ =~ tr{}{}xm<Esc>F$a
		"
		inoremap    <buffer>  <silent>  <Leader>im    $ =~ m{}xm<Esc>F$a
		inoremap    <buffer>  <silent>  <Leader>is    $ =~ s{}{}xm<Esc>F$a
		inoremap    <buffer>  <silent>  <Leader>it    $ =~ tr{}{}xm<Esc>F$a
	else
		nnoremap    <buffer>  <silent>  <Leader>im    a$ =~ m//<Esc>F$a
		nnoremap    <buffer>  <silent>  <Leader>is    a$ =~ s///<Esc>F$a
		nnoremap    <buffer>  <silent>  <Leader>it    a$ =~ tr///<Esc>F$a
		"
		inoremap    <buffer>  <silent>  <Leader>im    $ =~ m//<Esc>F$a
		inoremap    <buffer>  <silent>  <Leader>is    $ =~ s///<Esc>F$a
		inoremap    <buffer>  <silent>  <Leader>it    $ =~ tr///<Esc>F$a
	endif
	"
	nnoremap    <buffer>  <silent>  <Leader>ip    aprint "\n";<Left><Left><Left><Left>
	inoremap    <buffer>  <silent>  <Leader>ip     print "\n";<Left><Left><Left><Left>
	"
	inoremap    <buffer>  <silent>  <Leader>ii    <C-C>:call Perl_OpenInputFile("a")<CR>a
	inoremap    <buffer>  <silent>  <Leader>io    <C-C>:call Perl_OpenOutputFile("a")<CR>a
	inoremap    <buffer>  <silent>  <Leader>ipi   <C-C>:call Perl_OpenPipe("a")<CR>a
	inoremap    <buffer>  <silent>  <Leader>isu   <C-C>:call Perl_Subroutine("a")<CR>A
	nnoremap    <buffer>  <silent>  <Leader>ii         :call Perl_OpenInputFile("a")<CR>a
	nnoremap    <buffer>  <silent>  <Leader>io         :call Perl_OpenOutputFile("a")<CR>a
	nnoremap    <buffer>  <silent>  <Leader>ipi        :call Perl_OpenPipe("a")<CR>a
	nnoremap    <buffer>  <silent>  <Leader>isu        :call Perl_Subroutine("a")<CR>A
	vnoremap    <buffer>  <silent>  <Leader>ii    <C-C>:call Perl_OpenInputFile("v")<CR>a
	vnoremap    <buffer>  <silent>  <Leader>io    <C-C>:call Perl_OpenOutputFile("v")<CR>a
	vnoremap    <buffer>  <silent>  <Leader>ipi   <C-C>:call Perl_OpenPipe("v")<CR>a
	vnoremap    <buffer>  <silent>  <Leader>isu   <C-C>:call Perl_Subroutine("v")<CR>f(a
	"
	" ----------------------------------------------------------------------------
	" Regex
	" ----------------------------------------------------------------------------
	"
	nnoremap    <buffer>  <silent>  <Leader>xr        :call Perl_RegexPick( "regexp", "n" )<CR>j
	nnoremap    <buffer>  <silent>  <Leader>xs        :call Perl_RegexPick( "string", "n" )<CR>j
	nnoremap    <buffer>  <silent>  <Leader>xf        :call Perl_RegexPickFlag( "n" )<CR>
	vnoremap    <buffer>  <silent>  <Leader>xr   <C-C>:call Perl_RegexPick( "regexp", "v" )<CR>'>j
	vnoremap    <buffer>  <silent>  <Leader>xs   <C-C>:call Perl_RegexPick( "string", "v" )<CR>'>j
	vnoremap    <buffer>  <silent>  <Leader>xf   <C-C>:call Perl_RegexPickFlag( "v" )<CR>'>j
	nnoremap    <buffer>  <silent>  <Leader>xm        :call Perl_RegexVisualize( )<CR>
	nnoremap    <buffer>  <silent>  <Leader>xe        :call Perl_RegexExplain( "n" )<CR>
	vnoremap    <buffer>  <silent>  <Leader>xe   <C-C>:call Perl_RegexExplain( "v" )<CR>
	"
	" ----------------------------------------------------------------------------
	" POSIX character classes
	" ----------------------------------------------------------------------------
	"
	nnoremap    <buffer>  <silent>  <Leader>pa    a[:alnum:]<Esc>
	nnoremap    <buffer>  <silent>  <Leader>ph    a[:alpha:]<Esc>
	nnoremap    <buffer>  <silent>  <Leader>pi    a[:ascii:]<Esc>
	nnoremap    <buffer>  <silent>  <Leader>pb    a[:blank:]<Esc>
	nnoremap    <buffer>  <silent>  <Leader>pc    a[:cntrl:]<Esc>
	nnoremap    <buffer>  <silent>  <Leader>pd    a[:digit:]<Esc>
	nnoremap    <buffer>  <silent>  <Leader>pg    a[:graph:]<Esc>
	nnoremap    <buffer>  <silent>  <Leader>pl    a[:lower:]<Esc>
	nnoremap    <buffer>  <silent>  <Leader>pp    a[:print:]<Esc>
	nnoremap    <buffer>  <silent>  <Leader>pn    a[:punct:]<Esc>
	nnoremap    <buffer>  <silent>  <Leader>ps    a[:space:]<Esc>
	nnoremap    <buffer>  <silent>  <Leader>pu    a[:upper:]<Esc>
	nnoremap    <buffer>  <silent>  <Leader>pw    a[:word:]<Esc>
	nnoremap    <buffer>  <silent>  <Leader>px    a[:xdigit:]<Esc>
	"
	inoremap    <buffer>  <silent>  <Leader>pa    [:alnum:]
	inoremap    <buffer>  <silent>  <Leader>ph    [:alpha:]
	inoremap    <buffer>  <silent>  <Leader>pi    [:ascii:]
	inoremap    <buffer>  <silent>  <Leader>pb    [:blank:]
	inoremap    <buffer>  <silent>  <Leader>pc    [:cntrl:]
	inoremap    <buffer>  <silent>  <Leader>pd    [:digit:]
	inoremap    <buffer>  <silent>  <Leader>pg    [:graph:]
	inoremap    <buffer>  <silent>  <Leader>pl    [:lower:]
	inoremap    <buffer>  <silent>  <Leader>pp    [:print:]
	inoremap    <buffer>  <silent>  <Leader>pn    [:punct:]
	inoremap    <buffer>  <silent>  <Leader>ps    [:space:]
	inoremap    <buffer>  <silent>  <Leader>pu    [:upper:]
	inoremap    <buffer>  <silent>  <Leader>pw    [:word:]
	inoremap    <buffer>  <silent>  <Leader>px    [:xdigit:]
	"
	" ----------------------------------------------------------------------------
	" Run
	" ----------------------------------------------------------------------------
	"
	 noremap    <buffer>  <silent>  <Leader>rr         :call Perl_Run()<CR>
	 noremap    <buffer>  <silent>  <Leader>rs         :call Perl_SyntaxCheck()<CR>:redraw!<CR>:call Perl_SyntaxCheckMsg()<CR>
	 noremap    <buffer>  <silent>  <Leader>ra         :call Perl_Arguments()<CR>
	 noremap    <buffer>  <silent>  <Leader>rw         :call Perl_PerlSwitches()<CR>
	inoremap    <buffer>  <silent>  <Leader>rr    <C-C>:call Perl_Run()<CR>
	inoremap    <buffer>  <silent>  <Leader>rs    <C-C>:call Perl_SyntaxCheck()<CR>:redraw!<CR>:call Perl_SyntaxCheckMsg()<CR>
	inoremap    <buffer>  <silent>  <Leader>ra    <C-C>:call Perl_Arguments()<CR>
	inoremap    <buffer>  <silent>  <Leader>rw    <C-C>:call Perl_PerlSwitches()<CR>
	"
	if has("gui_running")
		 noremap    <buffer>  <silent>  <Leader>rd         :call Perl_Debugger()<CR>
		 noremap    <buffer>  <silent>    <F9>             :call Perl_Debugger()<CR>
		inoremap    <buffer>  <silent>    <F9>        <C-C>:call Perl_Debugger()<CR>
	else
		 noremap    <buffer>  <silent>  <Leader>rd         :call Perl_Debugger()<CR>:redraw!<CR>
		 noremap    <buffer>  <silent>    <F9>             :call Perl_Debugger()<CR>:redraw!<CR>
		inoremap    <buffer>  <silent>    <F9>        <C-C>:call Perl_Debugger()<CR>:redraw!<CR>
	endif
	"
	if s:UNIX
		 noremap    <buffer>  <silent>  <Leader>re         :call Perl_MakeScriptExecutable()<CR>
		inoremap    <buffer>  <silent>  <Leader>re    <C-C>:call Perl_MakeScriptExecutable()<CR>
	endif
	"
	 map    <buffer>  <silent>  <Leader>rp         :call Perl_perldoc()<CR>
	 map    <buffer>  <silent>  <Leader>h          :call Perl_perldoc()<CR>
	"
	 map    <buffer>  <silent>  <Leader>ri         :call Perl_perldoc_show_module_list()<CR>
	 map    <buffer>  <silent>  <Leader>rg         :call Perl_perldoc_generate_module_list()<CR>:redraw!<CR>
	"
	 map    <buffer>  <silent>  <Leader>ry         :call Perl_Perltidy("n")<CR>
	vmap    <buffer>  <silent>  <Leader>ry    <C-C>:call Perl_Perltidy("v")<CR>
	"
	 map    <buffer>  <silent>  <Leader>rm         :call Perl_Smallprof()<CR>
	 map    <buffer>  <silent>  <Leader>rc         :call Perl_Perlcritic()<CR>:redraw<CR>:call Perl_PerlcriticMsg()<CR>
	 map    <buffer>  <silent>  <Leader>rt         :call Perl_SaveWithTimestamp()<CR>
	 map    <buffer>  <silent>  <Leader>rh         :call Perl_Hardcopy("n")<CR>
	vmap    <buffer>  <silent>  <Leader>rh    <C-C>:call Perl_Hardcopy("v")<CR>
	"
	 map    <buffer>  <silent>  <Leader>rk    :call Perl_Settings()<CR>
	if has("gui_running") && s:UNIX
	 	 map    <buffer>  <silent>  <Leader>rx    :call Perl_XtermSize()<CR>
	endif
	"
	 map    <buffer>  <silent>  <Leader>ro         :call Perl_Toggle_Gvim_Xterm()<CR>
	imap    <buffer>  <silent>  <Leader>ro    <C-C>:call Perl_Toggle_Gvim_Xterm()<CR>
	"
	"
endif

" ----------------------------------------------------------------------------
"  Generate (possibly exuberant) Ctags style tags for Perl sourcecode.
"  Controlled by g:Perl_PerlTags, enabled by default.
" ----------------------------------------------------------------------------
if has('perl')
	if g:Perl_PerlTags == "enabled"
		"
		if s:UNIX
			exe "source ".g:Perl_PluginDir."/perl-support/scripts/perltags.vim"
		endif
		"
		if s:MSWIN
			source $VIM/vimfiles/perl-support/scripts/perltags.vim
		endif
	endif
end
"
" ----------------------------------------------------------------------------
