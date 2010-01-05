" Run the ack command using the supplied pattern
" created by Zack Hobson <zhobson@shopzilla.com>
function! DoAck(pat)
    let cmd = "ack -a ".a:pat." ."
    let cmd_output = system(cmd)
    
    if cmd_output == ""
        echohl WarningMsg |
        echomsg "Pattern not found" | 
        echohl None
        return
    endif
    
    let tmpfile = tempname()
    
    let old_verbose = &verbose
    set verbose&vim
    
    exe "redir! > " . tmpfile
    silent echon "[Search results:]\n"
    silent echon cmd_output
    redir END
    
    let &verbose = old_verbose
    
    let old_efm = &efm
    set efm=%f:%\\s%#%l:%m
    
    if exists(":cgetfile")
        execute "silent! cgetfile " . tmpfile
    else
        execute "silent! cfile " . tmpfile
    endif

    let &efm = old_efm

    botright copen

    call delete(tmpfile)
endfunction

command! -nargs=+ Ack call DoAck(<q-args>)

