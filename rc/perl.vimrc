
"-------------------------------------------------------------------------------
" perl-support.vim
"-------------------------------------------------------------------------------

let g:Perl_AuthorName      = ""     
let g:Perl_AuthorRef       = ""                         
let g:Perl_Email           = ""            
let g:Perl_Company         = ""    
let g:Perl_Project         = ""
let g:Perl_CopyrightHolder = ""

let g:Perl_LoadMenus       = "yes"

" ----------  Insert header into new PERL files  ----------
if has("autocmd")
  autocmd BufNewFile  *.\(pl\|pm\)         call Perl_CommentTemplates('header')
endif " has("autocmd")


