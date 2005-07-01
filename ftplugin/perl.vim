" Vim filetype plugin file
"
" Language   :  Perl
" Plugin     :  perl-support.vim
" Maintainer :  Fritz Mehner <mehner@fh-swf.de>
" Last Change:  01.07.2005
"
" -----------------------------------------------------------------
"
" Only do this when not done yet for this buffer
" 
if exists("b:did_PERL_ftplugin")
  finish
endif
let b:did_PERL_ftplugin = 1
"
" ---------- Perl dictionary -----------------------------------
" This will enable keyword completion for Perl
" using Vim's dictionary feature |i_CTRL-X_CTRL-K|.
"
if exists("g:Perl_Dictionary_File")
    silent! exec 'setlocal dictionary+='.g:Perl_Dictionary_File
endif    
"
" ---------- Key mappings  -------------------------------------
"
"   Ctrl-F9   run script
"    Alt-F9   run syntax check
"        F9   run script with pager
"
" Vim : shifted keys are mapped to their unshifted key !!!
"  
if has("gui_running")
  "
   map    <buffer>  <silent>  <A-F9>             :call Perl_SyntaxCheck()<CR>:redraw!<CR>:call Perl_SyntaxCheckMsg()<CR>
  imap    <buffer>  <silent>  <A-F9>        <Esc>:call Perl_SyntaxCheck()<CR>:redraw!<CR>:call Perl_SyntaxCheckMsg()<CR>
  " 
  " <C-C> seems to be essential here:
  "
   map    <buffer>            <C-F9>        <C-C>:call Perl_Run()<CR>
  imap    <buffer>            <C-F9>   <C-C><C-C>:call Perl_Run()<CR>
  "
   map    <buffer>  <silent>  <S-F9>             :call Perl_Arguments()<CR>
  imap    <buffer>  <silent>  <S-F9>        <Esc>:call Perl_Arguments()<CR>
  "
   map    <buffer>  <silent>    <F9>        <C-C>:call Perl_Debugger()<CR>
  imap    <buffer>  <silent>    <F9>   <C-C><C-C>:call Perl_Debugger()<CR>
  "
endif

nmap    <buffer>  <silent>  <Leader>cl    A<Tab><Tab><Tab>#<Space>
vmap    <buffer>  <silent>  <Leader>cl    <Esc><Esc>:call Perl_MultiLineEndComments()<CR>
nmap    <buffer>  <silent>  <Leader>cf    :call Perl_CommentTemplates('frame')<CR>
nmap    <buffer>  <silent>  <Leader>cu    :call Perl_CommentTemplates('function')<CR>
nmap    <buffer>  <silent>  <Leader>ch    :call Perl_CommentTemplates('header')<CR>
nmap    <buffer>  <silent>  <Leader>ce    :call Perl_CommentTemplates('module')<CR>
nmap    <buffer>  <silent>  <Leader>ckb   $<Esc>:call Perl_CommentClassified("BUG")     <CR>kJA
nmap    <buffer>  <silent>  <Leader>ckt   $<Esc>:call Perl_CommentClassified("TODO")    <CR>kJA
nmap    <buffer>  <silent>  <Leader>ckr   $<Esc>:call Perl_CommentClassified("TRICKY")  <CR>kJA
nmap    <buffer>  <silent>  <Leader>ckw   $<Esc>:call Perl_CommentClassified("WARNING") <CR>kJA
nmap    <buffer>  <silent>  <Leader>ckn   $<Esc>:call Perl_CommentClassified("")        <CR>kJf:a
vmap    <buffer>  <silent>  <Leader>cc    <Esc><Esc>:'<,'>s/^/#/<CR><Esc>:nohlsearch<CR>
vmap    <buffer>  <silent>  <Leader>co    <Esc><Esc>:'<,'>s/^#//<CR><Esc>:nohlsearch<CR>
nmap    <buffer>  <silent>  <Leader>cd    i<C-R>=strftime("%x")<CR>
nmap    <buffer>  <silent>  <Leader>ct    i<C-R>=strftime("%x %X %Z")<CR>
nmap    <buffer>  <silent>  <Leader>cv    :call Perl_CommentVimModeline()<CR>

nmap    <buffer>  <silent>  <Leader>ad    :call Perl_DoWhile('a')<CR><Esc>4jf(la
nmap    <buffer>  <silent>  <Leader>af    ofor ( ; ;  )<CR>{<CR>}<Esc>2kf;i
nmap    <buffer>  <silent>  <Leader>ao    oforeach  (  )<CR>{<CR>}<Tab><Tab><Tab><Tab># -----  end foreach  -----<Esc>2kF(hi
nmap    <buffer>  <silent>  <Leader>ai    oif (  )<CR>{<CR>}<Esc>2kf(la
nmap    <buffer>  <silent>  <Leader>ae    oif (  )<CR>{<CR>}<CR>else<CR>{<CR>}<Esc>5kf(la
nmap    <buffer>  <silent>  <Leader>au    ounless (  )<CR>{<CR>}<Esc>2kf(la
nmap    <buffer>  <silent>  <Leader>an    ounless (  )<CR>{<CR>}<CR>else<CR>{<CR>}<Esc>5kf(la
nmap    <buffer>  <silent>  <Leader>at    ountil (  )<CR>{<CR>}<Esc>2kf(la
nmap    <buffer>  <silent>  <Leader>aw    owhile (  )<CR>{<CR>}<Tab><Tab><Tab><Tab># -----  end while  -----<Esc>2kF(la
nmap    <buffer>  <silent>  <Leader>a{    o{<CR>}<Esc>ko

vmap    <buffer>  <silent>  <Leader>ad    <Esc><Esc>:call Perl_DoWhile('v')<CR><Esc>f(la
vmap    <buffer>  <silent>  <Leader>af    DOfor ( ; ;  )<CR>{<CR>}<Esc>P2k<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>f;i
vmap    <buffer>  <silent>  <Leader>ao    DOforeach  (  )<CR>{<CR>}<Tab><Tab><Tab><Tab># -----  end foreach  -----<Esc>P2k<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>f(hi
vmap    <buffer>  <silent>  <Leader>ai    DOif (  )<CR>{<CR>}<Esc>P2k<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>f(la
vmap    <buffer>  <silent>  <Leader>ae    DOif (  )<CR>{<CR>}<CR>else<CR>{<CR>}<Esc>3kP2k<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>f(la
vmap    <buffer>  <silent>  <Leader>au    DOunless (  )<CR>{<CR>}<Esc>P2k<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>f(la
vmap    <buffer>  <silent>  <Leader>an    DOunless (  )<CR>{<CR>}<CR>else<CR>{<CR>}<Esc>3kP2k<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>f(la
vmap    <buffer>  <silent>  <Leader>at    DOuntil (  )<CR>{<CR>}<Esc>P2k<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>f(la
vmap    <buffer>  <silent>  <Leader>aw    DOwhile (  )<CR>{<CR>}<Tab><Tab><Tab><Tab># -----  end while  -----<Esc>P2k<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>f(la
vmap    <buffer>  <silent>  <Leader>a{    DO{<CR>}<Esc>Pk<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>f;i

nmap    <buffer>  <silent>  <Leader>dm    omy<Tab>$;<Esc>i
nmap    <buffer>  <silent>  <Leader>dy    omy<Tab>$<Tab>= ;<Esc>F$a
nmap    <buffer>  <silent>  <Leader>d,    omy<Tab>( $, $ );<Esc>2F$a
nmap    <buffer>  <silent>  <Leader>d1    omy<Tab>@;<Esc>i
nmap    <buffer>  <silent>  <Leader>d2    omy<Tab>@<Tab>= ( , ,  );<Esc>F@a
nmap    <buffer>  <silent>  <Leader>d3    omy<Tab>%;<Esc>i
nmap    <buffer>  <silent>  <Leader>d4    omy<Tab>%<Tab>= <CR>(<CR>=> ,<CR>=> ,<CR>);<Esc>k0i<Tab><Tab><Esc>k0i<Tab><Tab><Esc>2kf%a
nmap    <buffer>  <silent>  <Leader>d5    omy<Tab>$rgx_<Tab>= q//;<Esc>F_a
nmap    <buffer>  <silent>  <Leader>d6    omy<Tab>$rgx_<Tab>= qr//;<Esc>F_a
nmap    <buffer>  <silent>  <Leader>d7    <Esc>a$ =~ m//<Esc>F$a
nmap    <buffer>  <silent>  <Leader>d8    <Esc>a$ =~ s///<Esc>F$a
nmap    <buffer>  <silent>  <Leader>d9    <Esc>a$ =~ tr///<Esc>F$a
nmap    <buffer>  <silent>  <Leader>dp    <Esc>aprint "\n";<ESC>3hi
nmap    <buffer>  <silent>  <Leader>df    <Esc>aprintf ("\n");<ESC>4hi
nmap    <buffer>  <silent>  <Leader>ds    <Esc><Esc>:call Perl_CodeFunction()<CR>
nmap    <buffer>  <silent>  <Leader>di    <Esc><Esc>:call Perl_CodeOpenRead()<CR>
nmap    <buffer>  <silent>  <Leader>do    <Esc><Esc>:call Perl_CodeOpenWrite()<CR>
nmap    <buffer>  <silent>  <Leader>de    <Esc><Esc>:call Perl_CodeOpenPipe()<CR>
nmap    <buffer>  <silent>  <Leader>la    a[:alnum:]
nmap    <buffer>  <silent>  <Leader>lh    a[:alpha:]
nmap    <buffer>  <silent>  <Leader>li    a[:ascii:]
nmap    <buffer>  <silent>  <Leader>lc    a[:cntrl:]
nmap    <buffer>  <silent>  <Leader>ld    a[:digit:]
nmap    <buffer>  <silent>  <Leader>lg    a[:graph:]
nmap    <buffer>  <silent>  <Leader>ll    a[:lower:]
nmap    <buffer>  <silent>  <Leader>lp    a[:print:]
nmap    <buffer>  <silent>  <Leader>ln    a[:punct:]
nmap    <buffer>  <silent>  <Leader>ls    a[:space:]
nmap    <buffer>  <silent>  <Leader>lu    a[:upper:]
nmap    <buffer>  <silent>  <Leader>lw    a[:word:]
nmap    <buffer>  <silent>  <Leader>lx    a[:xdigit:]
"
 map    <buffer>  <silent>  <Leader>rr    <Esc>:call Perl_Run()<CR>
 map    <buffer>  <silent>  <Leader>rs    <Esc>:call Perl_SyntaxCheck()<CR>:redraw!<CR>:call Perl_SyntaxCheckMsg()<CR>
 map    <buffer>  <silent>  <Leader>ra    <Esc>:call Perl_Arguments()<CR>
if has("gui_running")    " starts an xterm
   map    <buffer>  <silent>  <Leader>rd    <Esc>:call Perl_Debugger()<CR>:redraw!<CR>
endif
"
if has("unix")
  nmap    <buffer>  <silent>  <Leader>re    :call Perl_MakeScriptExecutable()<CR>
endif
"
 map              <silent>  <Leader>rp    <Esc>:call Perl_perldoc()<CR>
"
 map    <buffer>  <silent>  <Leader>ri    <Esc>:call Perl_perldoc_show_module_list()<CR>
 map    <buffer>  <silent>  <Leader>rg    <Esc>:call Perl_perldoc_generate_module_list()<CR>:redraw!<CR>
"
 map    <buffer>  <silent>  <Leader>ry    <Esc>:call Perl_Perltidy("n")<CR>
vmap    <buffer>  <silent>  <Leader>ry    <Esc>:call Perl_Perltidy("v")<CR>
"
 map    <buffer>  <silent>  <Leader>rm    <Esc>:call Perl_Smallprof()<CR>
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
