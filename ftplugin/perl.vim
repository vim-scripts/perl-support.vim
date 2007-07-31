" Vim filetype plugin file
"
"   Language :  Perl
"     Plugin :  perl-support.vim (version 3.6.3)
" Maintainer :  Fritz Mehner <mehner@fh-swf.de>
"   Revision :  $Id: perl.vim,v 1.16 2007/07/28 09:50:47 mehner Exp $
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
command! -nargs=? CriticOptions			call Perl_PerlCriticOptions  (<f-args>)
command! -nargs=1 CriticSeverity		call Perl_PerlCriticSeverity (<f-args>)
command! -nargs=1 CriticVerbosity		call Perl_PerlCriticVerbosity(<f-args>)
" ---------- Key mappings : function keys ------------------------------------
"
"   Ctrl-F9   run script
"    Alt-F9   run syntax check
"  Shift-F9   set command line arguments
"
" Vim (non-GUI) : shifted keys are mapped to their unshifted key !!!
" 
if has("gui_running")
  "
   map    <buffer>  <silent>  <A-F9>             :call Perl_SyntaxCheck()<CR>:redraw!<CR>:call Perl_SyntaxCheckMsg()<CR>
  imap    <buffer>  <silent>  <A-F9>        <Esc>:call Perl_SyntaxCheck()<CR>:redraw!<CR>:call Perl_SyntaxCheckMsg()<CR>
  " 
  " <C-C> seems to be essential here:
  "
   map    <buffer>  <silent>  <C-F9>        <C-C>:call Perl_Run()<CR>
  imap    <buffer>  <silent>  <C-F9>   <C-C><C-C>:call Perl_Run()<CR>
  "
   map    <buffer>  <silent>  <S-F9>             :call Perl_Arguments()<CR>
  imap    <buffer>  <silent>  <S-F9>        <Esc>:call Perl_Arguments()<CR>
  "
   map    <buffer>  <silent>  <S-F1>             :call Perl_perldoc()<CR><CR>
  imap    <buffer>  <silent>  <S-F1>        <Esc>:call Perl_perldoc()<CR><CR>
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
	nnoremap    <buffer>  <silent>  <Leader>cl    <Esc><Esc>:call Perl_LineEndComment("")<CR>A
	inoremap    <buffer>  <silent>  <Leader>cl    <Esc><Esc>:call Perl_LineEndComment("")<CR>A
	vnoremap    <buffer>  <silent>  <Leader>cl    <Esc><Esc>:call Perl_MultiLineEndComments()<CR>A
	nnoremap    <buffer>  <silent>  <Leader>cj    <Esc><Esc>:call Perl_AlignLineEndComm("a")<CR>
	inoremap    <buffer>  <silent>  <Leader>cj    <Esc><Esc>:call Perl_AlignLineEndComm("a")<CR>a
	vnoremap    <buffer>  <silent>  <Leader>cj    <Esc><Esc>:call Perl_AlignLineEndComm("v")<CR>
	nnoremap    <buffer>  <silent>  <Leader>cs    <Esc><Esc>:call Perl_GetLineEndCommCol()<CR>

	nnoremap    <buffer>  <silent>  <Leader>cfr        :call Perl_CommentTemplates('frame')<CR>
	nnoremap    <buffer>  <silent>  <Leader>cfu        :call Perl_CommentTemplates('function')<CR>
	nnoremap    <buffer>  <silent>  <Leader>cm         :call Perl_CommentTemplates('method')<CR>
	nnoremap    <buffer>  <silent>  <Leader>ch         :call Perl_CommentTemplates('header')<CR>
	nnoremap    <buffer>  <silent>  <Leader>ce         :call Perl_CommentTemplates('module')<CR>
	nnoremap    <buffer>  <silent>  <Leader>ca         :call Perl_CommentTemplates('test')<CR>

	inoremap    <buffer>  <silent>  <Leader>cfr   <Esc>:call Perl_CommentTemplates('frame')<CR>
	inoremap    <buffer>  <silent>  <Leader>cfu   <Esc>:call Perl_CommentTemplates('function')<CR>
	inoremap    <buffer>  <silent>  <Leader>cm    <Esc>:call Perl_CommentTemplates('method')<CR>
	inoremap    <buffer>  <silent>  <Leader>ch    <Esc>:call Perl_CommentTemplates('header')<CR>
	inoremap    <buffer>  <silent>  <Leader>ce    <Esc>:call Perl_CommentTemplates('module')<CR>
	inoremap    <buffer>  <silent>  <Leader>ca    <Esc>:call Perl_CommentTemplates('test')<CR>

	nnoremap    <buffer>  <silent>  <Leader>ckb   <Esc><Esc>:call Perl_CommentClassified("BUG")       <CR>A
	nnoremap    <buffer>  <silent>  <Leader>ckt   <Esc><Esc>:call Perl_CommentClassified("TODO")      <CR>A
	nnoremap    <buffer>  <silent>  <Leader>ckr   <Esc><Esc>:call Perl_CommentClassified("TRICKY")    <CR>A
	nnoremap    <buffer>  <silent>  <Leader>ckw   <Esc><Esc>:call Perl_CommentClassified("WARNING")   <CR>A
	nnoremap    <buffer>  <silent>  <Leader>cko   <Esc><Esc>:call Perl_CommentClassified("WORKAROUND")<CR>A
	nnoremap    <buffer>  <silent>  <Leader>ckn   <Esc><Esc>:call Perl_CommentClassified("")          <CR>3F:i
                                                     
	inoremap    <buffer>  <silent>  <Leader>ckb   <Esc><Esc>:call Perl_CommentClassified("BUG")       <CR>A
	inoremap    <buffer>  <silent>  <Leader>ckt   <Esc><Esc>:call Perl_CommentClassified("TODO")      <CR>A
	inoremap    <buffer>  <silent>  <Leader>ckr   <Esc><Esc>:call Perl_CommentClassified("TRICKY")    <CR>A
	inoremap    <buffer>  <silent>  <Leader>ckw   <Esc><Esc>:call Perl_CommentClassified("WARNING")   <CR>A
	inoremap    <buffer>  <silent>  <Leader>cko   <Esc><Esc>:call Perl_CommentClassified("WORKAROUND")<CR>A
	inoremap    <buffer>  <silent>  <Leader>ckn   <Esc><Esc>:call Perl_CommentClassified("")          <CR>3F:i

	nnoremap    <buffer>  <silent>  <Leader>cc    <Esc><Esc>:s/^/#/<CR><Esc>:nohlsearch<CR>j
	vnoremap    <buffer>  <silent>  <Leader>cc    <Esc><Esc>:'<,'>s/^/#/<CR><Esc>:nohlsearch<CR>j
	nnoremap    <buffer>  <silent>  <Leader>co    <Esc><Esc>:s/^#//<CR><Esc>:nohlsearch<CR>j
	vnoremap    <buffer>  <silent>  <Leader>co    <Esc><Esc>:'<,'>s/^#//<CR><Esc>:nohlsearch<CR>j

	nnoremap    <buffer>  <silent>  <Leader>cd    a<C-R>=strftime("%x")<CR>
	nnoremap    <buffer>  <silent>  <Leader>ct    a<C-R>=strftime("%x %X %Z")<CR>
	inoremap    <buffer>  <silent>  <Leader>cd    <C-R>=strftime("%x")<CR>
	inoremap    <buffer>  <silent>  <Leader>ct    <C-R>=strftime("%x %X %Z")<CR>

	nnoremap    <buffer>  <silent>  <Leader>cv    :call Perl_CommentVimModeline()<CR>
	nnoremap    <buffer>  <silent>  <Leader>cb    :call Perl_CommentBlock("a")<CR>
	vnoremap    <buffer>  <silent>  <Leader>cb    <Esc><Esc>:call Perl_CommentBlock("v")<CR>
	nnoremap    <buffer>  <silent>  <Leader>cn    :call Perl_UncommentBlock()<CR>
	"
	" ----------------------------------------------------------------------------
	" Statements
	" ----------------------------------------------------------------------------
	"
	nnoremap    <buffer>  <silent>  <Leader>sd              :call Perl_DoWhile("a")<CR><Esc>f(la
	nnoremap    <buffer>  <silent>  <Leader>sf              :call Perl_StatBlock( "a", "for ( ; ; ) {\n}","" )<CR>f;i
	nnoremap    <buffer>  <silent>  <Leader>sfe             :call Perl_StatBlock( "a", "foreach my $ (  ) {\n}", "" )<CR>f$a
	nnoremap    <buffer>  <silent>  <Leader>si              :call Perl_StatBlock( "a", "if (  ) {\n}", "" )<CR>f(la
	nnoremap    <buffer>  <silent>  <Leader>sie             :call Perl_StatBlock( "a", "if (  ) {\n}\nelse {\n}", "" )<CR>f(la
	nnoremap    <buffer>  <silent>  <Leader>su              :call Perl_StatBlock( "a", "unless (  ) {\n}", "" )<CR>f(la
	nnoremap    <buffer>  <silent>  <Leader>sue             :call Perl_StatBlock( "a", "unless (  ) {\n}\nelse {\n}", "" )<CR>f(la
	nnoremap    <buffer>  <silent>  <Leader>st              :call Perl_StatBlock( "a", "until (  ) {\n}", "" )<CR>f(la
	nnoremap    <buffer>  <silent>  <Leader>sw              :call Perl_StatBlock( "a", "while (  ) {\n}", "" )<CR>f(la
	nnoremap    <buffer>  <silent>  <Leader>s{              :call Perl_Block("a")<CR>o

	vnoremap    <buffer>  <silent>  <Leader>sd    <Esc><Esc>:call Perl_DoWhile("v")<CR><Esc>f(la
	vnoremap    <buffer>  <silent>  <Leader>sf    <Esc><Esc>:call Perl_StatBlock( "v", "for ( ; ; ) {", "}" )<CR>f;i
	vnoremap    <buffer>  <silent>  <Leader>sfe   <Esc><Esc>:call Perl_StatBlock( "v", "foreach my $ (  ) {", "}" )<CR>f$a
	vnoremap    <buffer>  <silent>  <Leader>si    <Esc><Esc>:call Perl_StatBlock( "v", "if (  ) {", "}" )<CR>f(la
	vnoremap    <buffer>  <silent>  <Leader>sie   <Esc><Esc>:call Perl_StatBlock( "v", "if (  ) {", "}\nelse {\n}" )<CR>f(la
	vnoremap    <buffer>  <silent>  <Leader>su    <Esc><Esc>:call Perl_StatBlock( "v", "unless (  ) {", "}" )<CR>f(la
	vnoremap    <buffer>  <silent>  <Leader>sue   <Esc><Esc>:call Perl_StatBlock( "v", "unless (  ) {", "}\nelse {\n}" )<CR>f(la
	vnoremap    <buffer>  <silent>  <Leader>st    <Esc><Esc>:call Perl_StatBlock( "v", "until (  ) {", "}" )<CR>f(la
	vnoremap    <buffer>  <silent>  <Leader>sw    <Esc><Esc>:call Perl_StatBlock( "v", "while (  ) {", "}" )<CR>f(la
	vnoremap    <buffer>  <silent>  <Leader>s{    <Esc><Esc>:call Perl_Block("v")<CR>

	inoremap    <buffer>  <silent>  <Leader>sd    <Esc><Esc>:call Perl_DoWhile("a")<CR><Esc>f(la
	inoremap    <buffer>  <silent>  <Leader>sf    <Esc><Esc>:call Perl_StatBlock( "a", "for ( ; ; ) {\n}","" )<CR>f;i
	inoremap    <buffer>  <silent>  <Leader>sfe   <Esc><Esc>:call Perl_StatBlock( "a", "foreach my $ (  ) {\n}", "" )<CR>f$a
	inoremap    <buffer>  <silent>  <Leader>si    <Esc><Esc>:call Perl_StatBlock( "a", "if (  ) {\n}", "" )<CR>f(la
	inoremap    <buffer>  <silent>  <Leader>sie   <Esc><Esc>:call Perl_StatBlock( "a", "if (  ) {\n}\nelse {\n}", "" )<CR>f(la
	inoremap    <buffer>  <silent>  <Leader>su    <Esc><Esc>:call Perl_StatBlock( "a", "unless (  ) {\n}", "" )<CR>f(la
	inoremap    <buffer>  <silent>  <Leader>sue   <Esc><Esc>:call Perl_StatBlock( "a", "unless (  ) {\n}\nelse {\n}", "" )<CR>f(la
	inoremap    <buffer>  <silent>  <Leader>st    <Esc><Esc>:call Perl_StatBlock( "a", "until (  ) {\n}", "" )<CR>f(la
	inoremap    <buffer>  <silent>  <Leader>sw    <Esc><Esc>:call Perl_StatBlock( "a", "while (  ) {\n}", "" )<CR>f(la
	"
	 noremap    <buffer>  <silent>  <Leader>nr    <Esc>:call Perl_CodeSnippet("r")<CR>
	 noremap    <buffer>  <silent>  <Leader>nw    <Esc>:call Perl_CodeSnippet("w")<CR>
	vnoremap    <buffer>  <silent>  <Leader>nw    <Esc>:call Perl_CodeSnippet("wv")<CR>
	 noremap    <buffer>  <silent>  <Leader>ne    <Esc>:call Perl_CodeSnippet("e")<CR>
	"
	" ----------------------------------------------------------------------------
	" Idioms
	" ----------------------------------------------------------------------------
	"	
	nnoremap    <buffer>  <silent>  <Leader>$    omy<Tab>$;<Esc>i
	nnoremap    <buffer>  <silent>  <Leader>$=   omy<Tab>$<Tab>= ;<Esc>F$a
	nnoremap    <buffer>  <silent>  <Leader>$$   omy<Tab>( $, $ );<Esc>2F$a
	nnoremap    <buffer>  <silent>  <Leader>@    omy<Tab>@;<Esc>i
	nnoremap    <buffer>  <silent>  <Leader>@=   omy<Tab>@<Tab>= ( , ,  );<Esc>F@a
	nnoremap    <buffer>  <silent>  <Leader>%    omy<Tab>%;<Esc>i
	nnoremap    <buffer>  <silent>  <Leader>%=   omy<Tab>%<Tab>= <CR>)<CR>=> ,<CR>=> ,<CR>);<Esc>k0i<Tab><Tab><Esc>k0i<Tab><Tab><Esc>2k^f%a
	"	
	inoremap    <buffer>  <silent>  <Leader>$    my<Tab>$;<Esc>i
	inoremap    <buffer>  <silent>  <Leader>$=   my<Tab>$<Tab>= ;<Esc>F$a
	inoremap    <buffer>  <silent>  <Leader>$$   my<Tab>( $, $ );<Esc>2F$a
	inoremap    <buffer>  <silent>  <Leader>@    my<Tab>@;<Esc>i
	inoremap    <buffer>  <silent>  <Leader>@=   my<Tab>@<Tab>= ( , ,  );<Esc>F@a
	inoremap    <buffer>  <silent>  <Leader>%    my<Tab>%;<Esc>i
	inoremap    <buffer>  <silent>  <Leader>%=   my<Tab>%<Tab>= <CR>)<CR>=> ,<CR>=> ,<CR>);<Esc>k0i<Tab><Tab><Esc>k0i<Tab><Tab><Esc>2k^f%a
	"
	nnoremap    <buffer>  <silent>  <Leader>ir    omy<Tab>$rgx_<Tab>= q//;<Esc>F_a
	nnoremap    <buffer>  <silent>  <Leader>im    <Esc>a$ =~ m//xm<Esc>F$a
	nnoremap    <buffer>  <silent>  <Leader>is    <Esc>a$ =~ s///xm<Esc>F$a
	nnoremap    <buffer>  <silent>  <Leader>it    <Esc>a$ =~ tr///xm<Esc>F$a
	nnoremap    <buffer>  <silent>  <Leader>ip    <Esc>aprint "\n";<Left><Left><Left><Left>
	"
	inoremap    <buffer>  <silent>  <Leader>ir    my<Tab>$rgx_<Tab>= q//;<Esc>F_a
	inoremap    <buffer>  <silent>  <Leader>im    $ =~ m//xm<Esc>F$a
	inoremap    <buffer>  <silent>  <Leader>is    $ =~ s///xm<Esc>F$a
	inoremap    <buffer>  <silent>  <Leader>it    $ =~ tr///xm<Esc>F$a
	inoremap    <buffer>  <silent>  <Leader>ip    print "\n";<Left><Left><Left><Left>
	"
	nnoremap    <buffer>  <silent>  <Leader>isu   <Esc><Esc>:call Perl_Subroutine("a")<CR>A
	vnoremap    <buffer>  <silent>  <Leader>isu   <Esc><Esc>:call Perl_Subroutine("v")<CR>f(a
	inoremap    <buffer>  <silent>  <Leader>isu   <Esc><Esc>:call Perl_Subroutine("a")<CR>A
	nnoremap    <buffer>  <silent>  <Leader>ii    <Esc><Esc>:call Perl_OpenInputFile("a")<CR>a
	vnoremap    <buffer>  <silent>  <Leader>ii    <Esc><Esc>:call Perl_OpenInputFile("v")<CR>a
	inoremap    <buffer>  <silent>  <Leader>ii    <Esc><Esc>:call Perl_OpenInputFile("a")<CR>a
	nnoremap    <buffer>  <silent>  <Leader>io    <Esc><Esc>:call Perl_OpenOutputFile("a")<CR>a
	vnoremap    <buffer>  <silent>  <Leader>io    <Esc><Esc>:call Perl_OpenOutputFile("v")<CR>a
	inoremap    <buffer>  <silent>  <Leader>io    <Esc><Esc>:call Perl_OpenOutputFile("a")<CR>a
	nnoremap    <buffer>  <silent>  <Leader>ipi   <Esc><Esc>:call Perl_OpenPipe("a")<CR>a
	vnoremap    <buffer>  <silent>  <Leader>ipi   <Esc><Esc>:call Perl_OpenPipe("v")<CR>a
	inoremap    <buffer>  <silent>  <Leader>ipi   <Esc><Esc>:call Perl_OpenPipe("a")<CR>a
	"
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
	map    <buffer>  <silent>  <Leader>rr    <Esc>:call Perl_Run()<CR>
	map    <buffer>  <silent>  <Leader>rs    <Esc>:call Perl_SyntaxCheck()<CR>:redraw!<CR>:call Perl_SyntaxCheckMsg()<CR>
	map    <buffer>  <silent>  <Leader>ra    <Esc>:call Perl_Arguments()<CR>
	map    <buffer>  <silent>  <Leader>rw    <Esc>:call Perl_PerlSwitches()<CR>
	"
	if has("gui_running")
		map    <buffer>  <silent>  <Leader>rd    <Esc>:call Perl_Debugger()<CR>
		map    <buffer>  <silent>    <F9>        <C-C>:call Perl_Debugger()<CR>
		imap    <buffer>  <silent>    <F9>   <C-C><C-C>:call Perl_Debugger()<CR>
	else
		map    <buffer>  <silent>  <Leader>rd    <Esc>:call Perl_Debugger()<CR>:redraw!<CR>
		map    <buffer>  <silent>    <F9>        <C-C>:call Perl_Debugger()<CR>:redraw!<CR>
		imap    <buffer>  <silent>    <F9>   <C-C><C-C>:call Perl_Debugger()<CR>:redraw!<CR>
	endif
	"
	if has("unix")
		nmap    <buffer>  <silent>  <Leader>re    :call Perl_MakeScriptExecutable()<CR>
	endif
	"
	 map    <buffer>  <silent>  <Leader>rp    <Esc>:call Perl_perldoc()<CR>
	 map    <buffer>  <silent>  <Leader>h     <Esc>:call Perl_perldoc()<CR>
	"
	 map    <buffer>  <silent>  <Leader>ri    <Esc>:call Perl_perldoc_show_module_list()<CR>
	 map    <buffer>  <silent>  <Leader>rg    <Esc>:call Perl_perldoc_generate_module_list()<CR>:redraw!<CR>
	"
	 map    <buffer>  <silent>  <Leader>ry    <Esc>:call Perl_Perltidy("n")<CR>
	vmap    <buffer>  <silent>  <Leader>ry    <Esc>:call Perl_Perltidy("v")<CR>
	"
	 map    <buffer>  <silent>  <Leader>rm    <Esc>:call Perl_Smallprof()<CR>
	 map    <buffer>  <silent>  <Leader>rc    <Esc>:call Perl_Perlcritic()<CR>:redraw<CR>:call Perl_PerlcriticMsg()<CR>
	 map    <buffer>  <silent>  <Leader>rt    <C-C>:call Perl_SaveWithTimestamp()<CR>
	 map    <buffer>  <silent>  <Leader>rh    <Esc>:call Perl_Hardcopy("n")<CR>
	vmap    <buffer>  <silent>  <Leader>rh    <Esc>:call Perl_Hardcopy("v")<CR>
	"
	 map    <buffer>  <silent>  <Leader>rk    <Esc>:call Perl_Settings()<CR>
	if has("gui_running") && has("unix")
	 	 map    <buffer>  <silent>  <Leader>rx    <Esc>:call Perl_XtermSize()<CR>
	endif
	"
	 map    <buffer>  <silent>  <Leader>ro    <Esc>:call Perl_Toggle_Gvim_Xterm()<CR>
	"
	"
endif

" ----------------------------------------------------------------------------
"  Generate (possibly exuberant) Ctags style tags for Perl sourcecode.
"  Controlled by g:Perl_PerlTags, disabled by default.
" ----------------------------------------------------------------------------
if has('perl')
	if exists("g:Perl_PerlTags") && g:Perl_PerlTags=="enable"
		"
		if has("unix")
			exe "source ".g:Perl_PluginDir."/perl-support/scripts/perltags.vim"
		endif
		"
		if has("win16") || has("win32") || has("win64") ||  has("win95") || has("win32unix")
			source $VIM/vimfiles/perl-support/scripts/perltags.vim
		endif
		"
	endif
end
" ----------------------------------------------------------------------------
