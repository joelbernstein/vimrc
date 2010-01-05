"=============================================================================
"    Copyright: Copyright (C) 2001-2003 Amos Elliston
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               bufexplorer.vim is provided *as is* and comes with no
"               warranty of any kind, either expressed or implied. In no
"               event will the copyright holder be liable for any damages
"               resulting from the use of this software.
" Name Of File: unittest.vim
"  Description: Plugin to use perl unit testing framework in vim
"   Maintainer: Amos Elliston <aelliston@shopzilla.com>
"  Last Change: Sat Dec 31 14:11:21 2005
"        Usage: Normally, this file should reside in the plugins
"               directory and be automatically sourced. If not, you must
"               manually source this file using ':source unittest.vim'.
"
"               You may use the default keymappings of
"
"                 <Leader>uu  - Runs unit test in separate window
"                 <Leader>ut  - Toggles file between regular and perl
"                 <Leader>un  - Creates the shell of a unit test
"
"=============================================================================

" Exit quickly when unittest has already been loaded or when 'compatible'
" is set.
"-------------------------------------------------- 
"if exists("loaded_unittest") || &cp
  "finish
"endif

let loaded_unittest = 1

if !exists("g:unit_test_runner")
	let g:unit_test_runner = "~/playground/apps/hackman/t/test_runner.pl"
endif

nnoremap <silent> <Leader>uu :call <SID>RunUnitTest()<CR><CR>
nnoremap <silent> <Leader>ut :call <SID>ToggleUnitTest()<CR>

function! <SID>RunUnitTest()

	" capture current name of file to run test on
    let s:filename = expand("%")
    if match(s:filename,"\\.pm") < 0
		echomsg "Sorry, you can only run unit tests on pm files."
	endif

    " transform filename into clasname
    let s:filename = substitute(s:filename,"^t/","","")
    let s:filename = substitute(s:filename,"^lib/","","")
    let s:filename = substitute(s:filename,"\.pm$","","")
    let s:filename = substitute(s:filename,"/","::","g")

    " make sure we've got the test class
   	if match(s:filename,"Test") < 1
        let s:filename = s:filename . "Test"
    endif

perl << EOF_PERL_DONE
  my @windows = VIM::Windows();
  for( @windows ) #Do it once for each window
  {
    VIM::DoCommand("normal \cWw"); #Switch to next window
    if( $curbuf->Name() eq 'UnitTest' )
    {
      VIM::DoCommand(":bd!"); #Delete buffer
      last;   
    }
  }

EOF_PERL_DONE


	exe "silent! 20sp UnitTest"
	setlocal bufhidden=delete
	setlocal buftype=nofile
	setlocal modifiable
	setlocal noswapfile
	setlocal wrap

	if has("syntax")
		call <SID>SetupSyntax()
	endif

	redir @a
        echo g:unit_test_runner
        echo s:filename
		exe "r!" . g:unit_test_runner . " '" . s:filename . "'"
	redir END

	silent! put =@a

	" clean up output
	silent! 0,1 d _
	silent! g/^shell/d

  	setlocal nomodifiable
endfun

function! <SID>ToggleUnitTest()

   	if match(expand("%"),"\\.pm$") < 0
		echomsg "Sorry, you can only toggle pm files."
		return
	endif

   	if match(expand("%"),"Test\\.pm") > 0
        let s:flipname = substitute(expand("%"),"Test\\.pm$",".pm","")
        let s:flipname = substitute(s:flipname,"^t/","","")
	else
        let s:flipname = substitute(expand("%"),"\\.pm$","Test.pm","")
    endif 

    exe ":find " s:flipname

endfun

function! <SID>SetupSyntax()
	syn match unitFail /^not.*$/
	syn match unitFail /^#  .*$/
	syn match unitFail /^# Looks like you failed.*$/
	syn match unitPass /^ok.*$/
	syn match unitInfo /^##.*$/
	syn match unitInfo /^# S.*$/
	syn match unitInfo /^1\.\..*$/
	syn match unitInfo /^use.*$/

	if !exists("g:did_unit_syntax_inits")
		let g:did_unit_syntax_inits = 1
		hi link unitPass	Structure
		hi link unitFail	String
		hi link unitInfo	Comment
	endif

endfunction

