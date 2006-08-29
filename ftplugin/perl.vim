" Vim filetype plugin file
"
" Language   :  Perl
" Plugin     :  perl-support.vim (version 3.2.1)
" Maintainer :  Fritz Mehner <mehner@fh-swf.de>
" Last Change:  29.08.2006
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

"
" ---------- Key mappings : menu entries -------------------------------------
"
nmap    <buffer>  <silent>  <Leader>cl    A<Tab><Tab><Tab>#<Space>
vmap    <buffer>  <silent>  <Leader>cl    <Esc><Esc>:call Perl_MultiLineEndComments()<CR>
nmap    <buffer>  <silent>  <Leader>cf    :call Perl_CommentTemplates('frame')<CR>
nmap    <buffer>  <silent>  <Leader>cu    :call Perl_CommentTemplates('function')<CR>
nmap    <buffer>  <silent>  <Leader>ch    :call Perl_CommentTemplates('header')<CR>
nmap    <buffer>  <silent>  <Leader>ce    :call Perl_CommentTemplates('module')<CR>
nmap    <buffer>  <silent>  <Leader>ca    :call Perl_CommentTemplates('test')<CR>
nmap    <buffer>  <silent>  <Leader>ckb   $<Esc>:call Perl_CommentClassified("BUG")     <CR>kJA
nmap    <buffer>  <silent>  <Leader>ckt   $<Esc>:call Perl_CommentClassified("TODO")    <CR>kJA
nmap    <buffer>  <silent>  <Leader>ckr   $<Esc>:call Perl_CommentClassified("TRICKY")  <CR>kJA
nmap    <buffer>  <silent>  <Leader>ckw   $<Esc>:call Perl_CommentClassified("WARNING") <CR>kJA
nmap    <buffer>  <silent>  <Leader>cko   $<Esc>:call Perl_CommentClassified("WORKAROUND") <CR>kJA
nmap    <buffer>  <silent>  <Leader>ckn   $<Esc>:call Perl_CommentClassified("")        <CR>kJf:a
vmap    <buffer>  <silent>  <Leader>cc    <Esc><Esc>:'<,'>s/^/#/<CR><Esc>:nohlsearch<CR>
vmap    <buffer>  <silent>  <Leader>co    <Esc><Esc>:'<,'>s/^#//<CR><Esc>:nohlsearch<CR>
nmap    <buffer>  <silent>  <Leader>cd    i<C-R>=strftime("%x")<CR>
nmap    <buffer>  <silent>  <Leader>ct    i<C-R>=strftime("%x %X %Z")<CR>
nmap    <buffer>  <silent>  <Leader>cv    :call Perl_CommentVimModeline()<CR>
nmap    <buffer>  <silent>  <Leader>cb    :call Perl_CommentBlock("a")<CR>
vmap    <buffer>  <silent>  <Leader>cb    <Esc><Esc>:call Perl_CommentBlock("v")<CR>
nmap    <buffer>  <silent>  <Leader>cn    :call Perl_UncommentBlock()<CR>

nmap    <buffer>  <silent>  <Leader>ad    :call Perl_DoWhile("a")<CR><Esc>f(la
nmap    <buffer>  <silent>  <Leader>af    :call Perl_StatBlock( "a", "for ( ; ; ) {\n}","" )<CR>f;i
nmap    <buffer>  <silent>  <Leader>ao    :call Perl_StatBlock( "a", "foreach  (  ) {\n}", "" )<CR>f(hi
nmap    <buffer>  <silent>  <Leader>ai    :call Perl_StatBlock( "a", "if (  ) {\n}", "" )<CR>f(la
nmap    <buffer>  <silent>  <Leader>ae    :call Perl_StatBlock( "a", "if (  ) {\n}\nelse {\n}", "" )<CR>f(la
nmap    <buffer>  <silent>  <Leader>au    :call Perl_StatBlock( "a", "unless (  ) {\n}", "" )<CR>f(la
nmap    <buffer>  <silent>  <Leader>an    :call Perl_StatBlock( "a", "unless (  ) {\n}\nelse {\n}", "" )<CR>f(la
nmap    <buffer>  <silent>  <Leader>at    :call Perl_StatBlock( "a", "until (  ) {\n}", "" )<CR>f(la
nmap    <buffer>  <silent>  <Leader>aw    :call Perl_StatBlock( "a", "while (  ) {\n}", "" )<CR>f(la
nmap    <buffer>  <silent>  <Leader>a{    :call Perl_Block("a")<CR>o

vmap    <buffer>  <silent>  <Leader>ad    <Esc><Esc>:call Perl_DoWhile("v")<CR><Esc>f(la
vmap    <buffer>  <silent>  <Leader>af    <Esc><Esc>:call Perl_StatBlock( "v", "for ( ; ; ) {", "}" )<CR>f;i
vmap    <buffer>  <silent>  <Leader>ao    <Esc><Esc>:call Perl_StatBlock( "v", "foreach  (  ) {", "}" )<CR>f(hi
vmap    <buffer>  <silent>  <Leader>ai    <Esc><Esc>:call Perl_StatBlock( "v", "if (  ) {", "}" )<CR>f(la
vmap    <buffer>  <silent>  <Leader>ae    <Esc><Esc>:call Perl_StatBlock( "v", "if (  ) {", "}\nelse {\n}" )<CR>f(la
vmap    <buffer>  <silent>  <Leader>au    <Esc><Esc>:call Perl_StatBlock( "v", "unless (  ) {", "}" )<CR>f(la
vmap    <buffer>  <silent>  <Leader>an    <Esc><Esc>:call Perl_StatBlock( "v", "unless (  ) {", "}\nelse {\n}" )<CR>f(la
vmap    <buffer>  <silent>  <Leader>at    <Esc><Esc>:call Perl_StatBlock( "v", "until (  ) {", "}" )<CR>f(la
vmap    <buffer>  <silent>  <Leader>aw    <Esc><Esc>:call Perl_StatBlock( "v", "while (  ) {", "}" )<CR>f(la
vmap    <buffer>  <silent>  <Leader>a{    <Esc><Esc>:call Perl_Block("v")<CR>
"

nmap    <buffer>  <silent>  <Leader>dm    omy<Tab>$;<Esc>i
nmap    <buffer>  <silent>  <Leader>dy    omy<Tab>$<Tab>= ;<Esc>F$a
nmap    <buffer>  <silent>  <Leader>d,    omy<Tab>) $, $ );<Esc>2F)r(f$a
nmap    <buffer>  <silent>  <Leader>d1    omy<Tab>@;<Esc>i
nmap    <buffer>  <silent>  <Leader>d2    omy<Tab>@<Tab>== ) , ,  );<Esc>2F)r(F@a
nmap    <buffer>  <silent>  <Leader>d3    omy<Tab>%;<Esc>i
nmap    <buffer>  <silent>  <Leader>d4    omy<Tab>%<Tab>= <CR>)<CR>=> ,<CR>=> ,<CR>);<Esc>k0i<Tab><Tab><Esc>k0i<Tab><Tab><Esc>kr(k^f%a
nmap    <buffer>  <silent>  <Leader>d5    omy<Tab>$rgx_<Tab>= q//;<Esc>F_a
nmap    <buffer>  <silent>  <Leader>d6    omy<Tab>$rgx_<Tab>= qr//;<Esc>F_a
nmap    <buffer>  <silent>  <Leader>d7    <Esc>a$ =~ m//xm<Esc>F$a
nmap    <buffer>  <silent>  <Leader>d8    <Esc>a$ =~ s///xm<Esc>F$a
nmap    <buffer>  <silent>  <Leader>d9    <Esc>a$ =~ tr///xm<Esc>F$a
nmap    <buffer>  <silent>  <Leader>dp    <Esc>aprint "\n";<ESC>3hi
nmap    <buffer>  <silent>  <Leader>df    <Esc>aprintf x\nx;<ESC>hr"3hr"a
nmap    <buffer>  <silent>  <Leader>ds    <Esc><Esc>:call Perl_Subroutine("a")<CR>A
vmap    <buffer>  <silent>  <Leader>ds    <Esc><Esc>:call Perl_Subroutine("v")<CR>f(a
nmap    <buffer>  <silent>  <Leader>di    <Esc><Esc>:call Perl_OpenInputFile()<CR>a
nmap    <buffer>  <silent>  <Leader>do    <Esc><Esc>:call Perl_OpenOutputFile()<CR>a
nmap    <buffer>  <silent>  <Leader>de    <Esc><Esc>:call Perl_OpenPipe()<CR>a
"
nmap    <buffer>  <silent>  <Leader>la    a]:alnum:]<Esc>F]r[f]'
nmap    <buffer>  <silent>  <Leader>lh    a]:alpha:]<Esc>F]r[f]'
nmap    <buffer>  <silent>  <Leader>li    a]:ascii:]<Esc>F]r[f]'
nmap    <buffer>  <silent>  <Leader>lb    a]:blank:]<Esc>F]r[f]'
nmap    <buffer>  <silent>  <Leader>lc    a]:cntrl:]<Esc>F]r[f]'
nmap    <buffer>  <silent>  <Leader>ld    a]:digit:]<Esc>F]r[f]'
nmap    <buffer>  <silent>  <Leader>lg    a]:graph:]<Esc>F]r[f]'
nmap    <buffer>  <silent>  <Leader>ll    a]:lower:]<Esc>F]r[f]'
nmap    <buffer>  <silent>  <Leader>lp    a]:print:]<Esc>F]r[f]'
nmap    <buffer>  <silent>  <Leader>ln    a]:punct:]<Esc>F]r[f]'
nmap    <buffer>  <silent>  <Leader>ls    a]:space:]<Esc>F]r[f]'
nmap    <buffer>  <silent>  <Leader>lu    a]:upper:]<Esc>F]r[f]'
nmap    <buffer>  <silent>  <Leader>lw    a]:word:]<Esc>F]r[f]'
nmap    <buffer>  <silent>  <Leader>lx    a]:xdigit:]<Esc>F]r[f]'
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
