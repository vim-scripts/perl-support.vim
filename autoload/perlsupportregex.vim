"===============================================================================
"
"          File:  perlsupportregex.vim
"
"   Description:  Plugin perl-support:
"                 Regular expression explanation and visualization.
"
"   VIM Version:  7.0+
"        Author:  Dr. Fritz Mehner (mn), mehner@fh-swf.de
"       Company:  FH Südwestfalen, Iserlohn
"       Version:  1.0
"       Created:  16.12.2008 18:16:55
"      Revision:  $Id: perlsupportregex.vim,v 1.2 2008/12/16 17:32:10 mehner Exp $
"       License:  Copyright 2008 Dr. Fritz Mehner
"===============================================================================
"
" Exit quickly when:
" - this plugin was already loaded
" - when 'compatible' is set
"
if exists("g:loaded_perlsupportregex") || &compatible
  finish
endif
let g:loaded_perlsupportregex = "v1.0"

let s:MSWIN = has("win16") || has("win32")   || has("win64")    || has("win95")
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
"   run the regular expression analyzer YAPE::Regex::Explain     {{{1
"------------------------------------------------------------------------------
let s:Perl_PerlRegexBufferName    = 'REGEX-EXPLAIN'
let s:Perl_PerlRegexBufferNumber  = -1

function! perlsupportregex#Perl_RegexExplain( mode )

  if !has('perl')
    echomsg "*** Your version of Vim was not compiled with Perl interface. ***"
    return
  endif

  if g:Perl_PerlRegexAnalyser != 'yes'
    echomsg "*** The Perl module YAPE::Regex::Explain can not be found. ***"
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
  silent normal ggdG

  perl <<EOF
      my $explanation;
      my ( $success, $regexp ) = VIM::Eval('s:MSWIN');

      my  $flag     = VIM::Eval('s:Perl_PerlRegexVisualizeFlag');
      ( $success, $regexp ) = VIM::Eval('s:Perl_PerlRegexVisualize_regexp');
      if ( $success == 1 ) {
        # get the explanation
        $regexp = eval 'qr{'.$regexp.'}'.$flag;
        $explanation  = YAPE::Regex::Explain->new($regexp)->explain();
        }
      else {
        $explanation  = "\n*** VIM failed to evaluate the regular expression ***\n";
        }

      # split explanation into lines
      my  @explanation  = split /\n/, $explanation;

      # put the explanation to the top of the buffer
      $curbuf->Append( 0, @explanation );
EOF

endfunction    " ----------  end of function Perl_RegexExplain  ----------
"
"------------------------------------------------------------------------------
"   command line switch 'RegexCodeEvaluation'     {{{1
"------------------------------------------------------------------------------
function! perlsupportregex#Perl_RegexCodeEvaluation ( onoff )
  if a:onoff == 'on'
    let s:Perl_PerlRegexCodeEvaluation        = 'on'
  else
    let s:Perl_PerlRegexCodeEvaluation        = 'off'
  endif
endfunction    " ----------  end of function Perl_RegexCodeEvaluation  ----------

"------------------------------------------------------------------------------
"   pick up string or regular expression     {{{1
"------------------------------------------------------------------------------
function! perlsupportregex#Perl_RegexPick ( item, mode )
  "
  " the complete line; remove leading and trailing whitespaces
  "
  if a:mode == 'n'
    let line  = getline(line("."))
    if  s:MSWIN
      " MSWIN : copy item to the yank-register, remove trailing CR
      let line  = substitute( line, "\n$", '', '' )
    endif
    let line  = substitute( line, '^\s\+', '', '' )  " remove leading whitespaces
    let line  = substitute( line, '\s\+$', '', '' )  " remove trailing whitespaces
    let s:Perl_PerlRegexVisualize_{a:item}  = line
  endif
  "
  " the marked area
  "
  if a:mode == 'v'
    " copy item to the yank-register (Windows has no selection register)
    normal gvy
    let s:Perl_PerlRegexVisualize_{a:item}  = eval('@"')
  endif
  "
  echomsg a:item." : '".s:Perl_PerlRegexVisualize_{a:item}."'"
endfunction    " ----------  end of function Perl_RegexPick  ----------
"
"------------------------------------------------------------------------------
"   pick up flags     {{{1
"------------------------------------------------------------------------------
function! perlsupportregex#Perl_RegexPickFlag ( mode )
  if a:mode == 'v'
    " copy item to the yank-register
    normal gvy
    let s:Perl_PerlRegexVisualizeFlag = eval('@"')
  else
    let s:Perl_PerlRegexVisualizeFlag = Perl_Input("regex modifier(s) [imsx] : ", s:Perl_PerlRegexVisualizeFlag , '')
  endif
  let s:Perl_PerlRegexVisualizeFlag=substitute(s:Perl_PerlRegexVisualizeFlag, '[^imsx]', '', 'g')
  echomsg "regex modifier(s) : '".s:Perl_PerlRegexVisualizeFlag."'"
endfunction    " ----------  end of function Perl_RegexPickFlag  ----------
"
"------------------------------------------------------------------------------
"   visualize regular expression     {{{1
"------------------------------------------------------------------------------
function! perlsupportregex#Perl_RegexVisualize( )

  if !has('perl')
    echomsg "*** Your version of Vim was not compiled with Perl interface. ***"
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
  silent normal ggdG

  perl <<EOF

  my  @substchar= split //, VIM::Eval('g:Perl_PerlRegexSubstitution');

  if ( VIM::Eval('s:Perl_PerlRegexCodeEvaluation') eq 'on' ) {
    ##use re 'eval';
    ##no strict "vars";
    use utf8;                                   # Perl pragma to enable/disable UTF-8 in source
    regex_evaluate();
    }
  else {
    use utf8;                                   # Perl pragma to enable/disable UTF-8 in source
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

    $flag     = VIM::Eval('s:Perl_PerlRegexVisualizeFlag');
    $string   = VIM::Eval('s:Perl_PerlRegexVisualize_string') || '';
    $regexp   = VIM::Eval('s:Perl_PerlRegexVisualize_regexp');

    utf8::decode($string);
    utf8::decode($regexp);

    if ( defined($regexp) && $regexp ne '' ) {

      my  $format1    = "%-9s [%3d,%3d] =%s \n";      # see also Perl_RegexVisualize()
      my  $format2    = "%-9s [%3d,%3d] =%s\n";
      my  $format3    = "REGEXP = m{%s}%s\n\n";
      my  $format4    = "lines : %-3d         = %s\n";
      my  $format5    = "%-9s     [%3d] =%s\n";
      my  $format6    = "%-9s undefined\n";
      my  $linecount  = 1;
      my  $lineruler;
      my  $result     = '';
      my  $rgx_1      = q/^[a-ln-z]*m[a-ln-z]*[-]?/;
      my  $stringout  = prepare_stringout($string);

      if ( $flag =~ m{$rgx_1} ) {
        ($lineruler, $linecount)  = lineruler($string);
        }

        my $regexp1 = join "\n           ", ( split /\n/, $regexp );

        $result .= sprintf $format3, $regexp1, $flag;

        if ( $flag =~ m{$rgx_1} ) {
          $result .= sprintf $format4, $linecount, $lineruler;
          }
        $result .= sprintf $format1, 'STRING', 0, length $string,
            marker_string( 0, $stringout );

        #---------------------------------------------------------------------------
        #  match (single line / multiline)
        #---------------------------------------------------------------------------
        if (   $string =~ m{(?$flag:$regexp)}   ) {
          #
          # print the prematch, if not empty
          #
          if ( $` ne '' ) {
            $result .= sprintf $format2, 'prematch', 0, length $`,
             marker_string( 0, prepare_stringout($`) );
            }
          #
          # print the match
          #
          $result .= sprintf $format2, 'MATCH', $-[0], length $&,
           marker_string( $-[0], prepare_stringout($&) );
          #
          # print the postmatch, if not empty
          #
          if ( $' ne '' ) {
            $result .= sprintf $format2, 'postmatch', $+[0], length $',
            marker_string( $+[0],  prepare_stringout($') );
            }
          $result .= "\n";
          #
          # print the numbered variables $1, $2, ...
          #
          foreach my $n ( 1 .. (scalar( @-) -1) ) {
            if ( defined eval( "\$$n" ) ) {
            $result .= sprintf $format2, "\$$n", $-[$n], $+[$n] - $-[$n],
              marker_string( $-[$n], prepare_stringout(substr( $string, $-[$n], $+[$n] - $-[$n] )) );
              }
            else {
            $result .= sprintf $format6, "\$$n";
              }
          }
          $result .= "\n";
          #
          # print $+, $^N, $LAST_SUBMATCH_RESULT (only if not equal $+ )
          #
          if ( defined $+ && defined $^N && "$+" ne "$^N" ) {
            $result .= sprintf $format5, '$+', length $+,
                        marker_string( 0, prepare_stringout($+) );
            $result .= sprintf $format5, '$^N', length $^N,
                      marker_string( 0, prepare_stringout($^N) );
            }
          #
          # show the control character replacement (if any)
          #
          if ( $string ne $stringout ) {
            $result .= "\nControl character replacement: \\n -> '$substchar[0]'   \\t -> '$substchar[1]'"
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
        $result .= "\n *****  NO MATCH  *****"
        }

        $curbuf->Append( 0, split(/\n/,$result) ); # put the result to the top of the buffer
        }
      else {
        VIM::DoCommand("echomsg 'regexp is not defined or has zero length'");
        }
        return ;
    } # ----------  end of subroutine regex_evaluate  ----------

    #===  FUNCTION  ================================================================
    #         NAME:  prepare_stringout
    #      PURPOSE:  Sustitute tabs and newlines with printable characters.
    #   PARAMETERS:  string
    #      RETURNS:  string with replacements
    #===============================================================================
    sub prepare_stringout {
      my  ( $par1 ) = @_;
      $par1 =~ s/\n/$substchar[0]/g;
      $par1 =~ s/\t/$substchar[1]/g;
      return $par1;
    } # ----------  end of subroutine prepare_stringout  ----------

    #===  FUNCTION  ================================================================
    #         NAME:  marker_string
    #      PURPOSE:  Prepend blanks;
    #                surround string with bars if starting/ending with whitespaces
    #   PARAMETERS:  1. first column of the marker bar (>=0)
    #                2. string
    #      RETURNS:  The augmented string.
    #===============================================================================
    sub marker_string {
      my  ( $start, $str )  = @_;
      my  $result = ' ' x ($start);
      if ( $str =~ m{^\s} || $str =~ m{\s$} ) {
        $result .= "|".$str."|"
        }
      else {
        $result .= ' '.$str;
        }
      return $result;
    } # ----------  end of subroutine marker_string  ----------

    #===  FUNCTION  ================================================================
    #         NAME:  lineruler
    #      PURPOSE:  Generate a line ruler like  "|1... |2... |3......."
    #   PARAMETERS:  1. a (multiline) string
    #      RETURNS:  ( ruler, number of lines )
    #===============================================================================
    sub lineruler {
      my  ( $string ) = @_;
      my  $result     = '';                     # result string (the ruler)
      my  @lines      = split /\n/, $string;    # lines as an array
      my  $lineno     = 0;                      # current line number
      my  $linecount  = 0;                      # number of lines

      while ( $string =~/\n/g ) {
        $linecount++;
        }
      if ( $string !~ /\n$/ ) {                 # last non-empty line
        $linecount++;
        }

      foreach my $line ( @lines ) {
        $lineno++;
        if ( $lineno > 1 ) {
          $result .= ' ';
        }
        if ( length($line) == 1 ) {
          $result .= '|';
        }
        if ( length($line) > 1 ) {
          $result .= '|'.$lineno;
          $result .= '.' x ((length $line)-(length $lineno)-1);
        }
      }
      return ($result, $linecount);
    } # ----------  end of subroutine lineruler  ----------
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
    let nr    = char2nr('!')
    let tilde = char2nr('~')
    let tick1 = char2nr("'")
    let tick2 = char2nr('"')
    let tick3 = char2nr('|')
    while nr <= tilde
      if nr != tick1 && nr != tick2 &&  nr != tick3 &&
            \ match( s:Perl_PerlRegexMatch, nr2char(nr) ) < 0
        break
      endif
      let nr  = nr+1
    endwhile

    if nr <= tilde
      :highlight color_match ctermbg=green guibg=green
      let delim   = nr2char(nr)
      " escape Vim regexp metacharacters
      let match0  = escape( s:Perl_PerlRegexPrematch , '*$~' )
      let match1  = escape( s:Perl_PerlRegexMatch    , '*$~' )
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
"   read the substitution characters for \n, \t,  ... from the command line
"   used in ftplugin/perl.vim
"-------------------------------------------------------------------------------
function! perlsupportregex#Perl_PerlRegexSubstitutions ( string )
  let result  = a:string
  let result  = substitute( result, '^\s\+', '', '' )  " remove leading whitespaces
  let result  = substitute( result, '\s\+$', '', '' )  " remove trailing whitespaces
  let result  = substitute( result, "^'", '', '' )
  let result  = substitute( result, "'$", '', '' )
  "
  " replacement string: length 2, printable characters, no control characters
  "
  if      strlen( result )                   ==  2 &&
        \ match( result, '^[[:print:]]\+$' ) ==  0 &&
        \ match( result, '[[:cntrl:]]' )     == -1
    let g:Perl_PerlRegexSubstitution  = result
  endif
endfunction    " ----------  end of function Perl_PerlRegexSubstitutions  ----------
"
