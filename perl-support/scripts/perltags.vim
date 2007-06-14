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
"       Version:  1.0
"       Created:  11.04.2007 10:21:26 CEST
"      Revision:  $Id: perltags.vim,v 1.1 2007/06/14 16:50:27 mehner Exp $
"===============================================================================

setlocal iskeyword+=:  " make tags with :: in them useful

if ! exists("s:defined_functions")
function s:init_tags()
    perl <<EOF
        use Perl::Tags;
        $naive_tagger = Perl::Tags::Naive->new( max_level=>2 );
            # only go one level down by default
EOF
endfunction

function s:do_tags(filename)
    perl <<EOF
        my $filename = VIM::Eval('a:filename');

        $naive_tagger->process(files => $filename, refresh=>1 );

        # we'll now do a global (for this PID) tags file which will get updated as you source dive.

        my $tagsfile="/tmp/tags_$$";
        VIM::SetOption("tags+=$tagsfile");

        # of course, it may not even output, for example, if there's nothing new to process
        $naive_tagger->output( outfile => $tagsfile );
EOF
endfunction

call s:init_tags() " only the first time

let s:defined_functions = 1
endif

call s:do_tags(expand('%'))

