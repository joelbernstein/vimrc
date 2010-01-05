
:if !exists("*Createwikipage")
:function! Createwikipage()
:	silent exe "file" s:createwikifile
:	call append(0,"=" . s:createwikiname . "=")
:	call append(1,"Define " . s:createwikiname . " here")
:	call append(2,"")
:	call append(3,"")
:	call append(4,"----")
:	call append(5,"related: " . '[' . s:createwikiparentname . ']')
:endfunction
:endif


:if !exists("*Openwiki")
:function! Openwiki()
:	let wword = expand("<cword>")
:		let wikidir  = fnamemodify(bufname("%"),':p:h')
:		let wikifile = wikidir . "/" . wword . ".wiki"
:		if ! filereadable(wikifile)
:			let s:createwikifile = wikifile
:			let s:createwikiname = wword
:			let s:createwikiparentname = expand("%:t:r")
:			silent execute "tag" wword
:		else
:			silent execute "tag" wword
:		endif
:endfunction
:endif

:if !exists("*Makewikitags")
:function! Makewikitags()
:	let s:createwikidir  = fnamemodify(bufname("%"),':p:h')
:	let tagsfile = s:createwikidir . '/' . "tags"
:	let wikifiles = s:createwikidir . '/' . "*.wiki"
:	let tagcmd = "!$HOME/.vim/tools/wikedtags.pl " . wikifiles . " > " . tagsfile
:	silent exec tagcmd
:endfunction
:endif

:autocmd! BufRead $HOME/.vim/tools/unknown.wiki call Createwikipage()
:autocmd! BufWritePost *.wiki call Makewikitags()

:map <buffer>  :call Openwiki()<CR>

