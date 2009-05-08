"===============================================================================
"
"          File:  perltags.vim
" 
"   Description:  Generate (possibly exuberant) Ctags style tags 
"                 for Perl sourcecode
" 
"        Source:  Perl::Tags module documentation
"   VIM Version:  7.0+
"        Author:  Dr.-Ing. Fritz Mehner (Mn), mehner@fh-swf.de
"       Company:  Fachhochschule Südwestfalen, Iserlohn
"       Version:  1.1
"       Created:  11.04.2007 10:21:26 CEST
"      Revision:  $Id: perltags.vim,v 1.5 2009/03/28 19:04:14 mehner Exp $
"===============================================================================

setlocal iskeyword+=:  " make tags with :: in them useful

" let vim do the tempfile cleanup and protection
let s:tagsfile = tempname()

if ! exists("s:defined_functions")

"===  FUNCTION  ================================================================
"          NAME:  init_tags
"   DESCRIPTION:  load Perl::Tags if installed
"===============================================================================
function s:init_tags()
    perl <<EOF
        eval "require Perl::Tags";
				if ( $@ ) {
					VIM::DoCommand("let g:Perl_PerlTags = 'disabled' ");
					}
				else {
					$naive_tagger = Perl::Tags::Naive->new( max_level=>2 );
					# only go one level down by default
					}
EOF
endfunction    " ----------  end of function s:init_tags  ----------

"===  FUNCTION  ================================================================
"          NAME:  do_tags
"   DESCRIPTION:  tag a new file
"===============================================================================
function s:do_tags(filename)
	perl <<EOF
	my $filename = VIM::Eval('a:filename');

	$naive_tagger->process(files => $filename, refresh=>1 );

	my $tagsfile=VIM::Eval('s:tagsfile');
	VIM::SetOption("tags+=$tagsfile");

	# of course, it may not even output, for example, if there's nothing new to process
	$naive_tagger->output( outfile => $tagsfile );
EOF
endfunction    " ----------  end of function s:do_tags  ----------

	call s:init_tags() 														" only the first time
	let s:defined_functions = 1

endif
"
" tag a new file 
"
if g:Perl_PerlTags == 'enabled'
	call s:do_tags( expand('%') )
	augroup perltags
		au!
		autocmd BufRead,BufWritePost *.pm,*.pl call s:do_tags(expand('%'))
	augroup END
endif
