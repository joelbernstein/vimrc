" Run the specified grep command using the supplied pattern
" created by zack hobson <zhobson@shopzilla.com>
function! DoSrch(path, ...)
    let cmd = "find '".a:path."' -type f -not -path '*/.svn/*' -a -not -name tags -print0 |xargs --null -l1 grep -P -H --mmap -d skip -In -e '" 
    let idx = 1
    while idx <= a:0
        if idx > 1
            let cmd = cmd . " "
        endif
        let cmd = cmd . escape(a:{idx}, "'\\")
        let idx = idx + 1
    endwhile
    let cmd = cmd . "'"
    echomsg "Searching... (Ctrl-C to cancel)"
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

command! -complete=dir -nargs=+ Srch call DoSrch(<f-args>)
command! -nargs=+ Search call DoSrch('.',<f-args>)

