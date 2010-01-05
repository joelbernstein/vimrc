"color_toon.vim -- colorscheme toy
" Maintainer:   Walter Hutchins
" Last Change:  July 13 2006
" Version:      1.4.02
" Requires:     colornames.vim plugin (Version 1.3 or later)
"
" Setup:        Copy color_toon.vim to ~/.vim/plugin/
"               Copy colornames.vim to ~/.vim/plugin/
"               Recommend adding to vimrc the mappings:
"                  map cn  :Colortoon<Space>
"                  map cm  :Colormake<Space>
"                  map cc  :Colorchange h 9<Space>
"
"               Windows - copy to $VIMRUNTIME/plugin
"                       - adjust myjunk | adjust plugin location if necessary.
"
" Thanks to: colortest
" Thanks to: Tip #634: To view all colours 
" Thanks to: hitest.vim
"Use without any expectations.
"Please liberally use :qa! and :q! whenever you like.
"
"Usage: Colortoon
"       Colortoon d  - shows 2nd group of 127 cterm_gui colors
"       Colortoon j  - sets colors from last myjunk.vim file
"       
" Usage: (1) First, run Colortoon.
"        (2) Get the desired range of colors into the NamedColors window:
"              If cc is mapped to Colorchange as in the suggested setup,
"              typing cc will type for you the command line:
"              Colorchange h 9
"              Following 9<Space>, type a number between 0 and 6.
"                0 or blank - All the colors (too many for vim < 7)
"                1 - 1st group of 182 named colors (only for guifg and guibg)
"                2 - 2nd group of 182 named colors (only for guifg and guibg)
"                3 - 3rd group of 182 named colors (only for guifg and guibg)
"                4 - 1st group of 128 cterm_gui colors
"                5 - 2nd group of 127 cterm_gui colors
"                6 - All 255 cterm_gui colors (too many for vim < 7)
"
"                4 or 5 is recommended.
"                You may follow the number with a space and the letter r if you
"                want to see color blocks instead of colored lettering.
"
"              Step (2) may be repeated whenever desired.
"                
"        (3) Position to desired hi group in myjunk window and type :y b
"        (4) Position to desired color in NamedColors window and type :y a
"        (5) Colormake                 - Set foreground color per registers a,b
"            Colormake b               - Set background color per registers a,b
"            If you mapped cm to Colormake as in the suggested setup,
"            type cm instead.
"
"         In steps 2 & 3, ':y a' means :y<SPACEBAR>a<RETURN>
"                                   or :yank<SPACEBAR>a<RETURN>
"                                   or "ayy
"                         ':y b' means :y<SPACEBAR>b<RETURN>
"                                   or :yank<SPACEBAR>b<RETURN>
"                                   or "byy
"                         
"                        If you consistently(!) reverse a and b, it still works.
"
"Somethings: to do are:
"Scroll up and down in the NamedColors window to see what the
"cterm and gui numbers are for the colors.
"Scroll up and down in the 'myjunk.vim' window to see highlighting groups.
"Go into myjunk window and :w! to save current colors in myjunk.vim.
"
"If you happen to get a color scheme, copy 'myjunk.vim' to 'myugly.vim'
"or whatever. Then stick 'let colors_name="myugly"' in myugly.vim.
"If myjunk.vim gets to where you don't like it anymore, then delete it
"and it will be created from your default colorscheme (maybe).
"
"Customize a gui color. Only works for six-digit-hex color numbers.
" (1) Position to the color nearest to your desired color in the light or dark 
" (2) window and type :y a
" (3) type :new
" (4) type "ap
" (5) edit the gui_xxxxxx 
" (6) type :y a
" (7) type :q!
" (8) type :Colormake   or  :Colormake -b
" (9) Go into the myjunk window and type :w! (only if you like it.)
" Note: The custom color won't 'stick' if you later change that hi group.
"
"Manually edit a hi group and manually "refresh" the highlighting.
" (1) Edit the hi group line in the myjunk window.
" (2) On that line, in normal mode, type yy
" (3) Type :@"<ENTER>
"
"Translate a supported color from gui to cterm or cterm to gui to make
" it work the same in both gui and xterm.
"
"Get assistance with selecting a color from the colorsel.vim script
" at www.vim.org
"
"Remember to use :qa! and :q! whenever you like -- to bail out.
command -nargs=* Colortoon call Color_toon(<f-args>)
command -nargs=* Colormake call Color_toon_make(<f-args>)
command -nargs=* Colorchange call s:Showhexcolornames(<f-args>)

function s:Showhexcolornames(...)
    let outargs="9"
    let comma=","
    let nxtarg=0
    let remargs=a:0
    while remargs > 0
        let nxtarg=nxtarg + 1
        exec 'let arg=a:' . nxtarg
        let outargs=outargs . comma
        if arg !~? '[a-z]'
            let outargs=outargs . arg
        else
            let outargs=outargs . '"' . arg . '"'
        endif
        let remargs=remargs - 1
    endwhile
    exec 'call Showhexcolornames(' . outargs . ')'
endfunction
           
"Begin function Color_toon
function Color_toon(...)
if !exists("*Showhexcolornames")
    echo "ERROR: colornames.vim v1.3 or later is required, but not installed!"
    return
endif

" save global options and registers
let s:hidden      = &hidden
let s:lazyredraw  = &lazyredraw
let s:more        = &more
let s:report      = &report
let s:shortmess   = &shortmess
let s:wrapscan    = &wrapscan
let s:register_a  = @a
let s:register_b  = @b
let s:register_se = @/

let g:zoo=""
let s:junk=""
let s:myjunk_buf=""
let s:choice="light"
let remargs=a:0
while remargs > 0
    exec 'let thearg=a:'.remargs
    if thearg =~? "^d" || thearg =~? "^-d"
        let s:choice="dark"
    elseif thearg =~? "^j" || thearg =~? "^-j"
        let s:junk="junk"
    endif
    let remargs=remargs - 1
endwhile

if $OS =~? "Windows"
    let myjunk=$VIMRUNTIME . "/colors/myjunk.vim"
else
    let myjunk='~/.vim/colors/myjunk.vim'
endif

let s:myjunk_buf=myjunk

if exists("s:junk") && s:junk == "junk"
    colo myjunk
endif

"myjunk window - current highlighting specs
set hidden lazyredraw nomore report=99999 shortmess=aoOstTW wrapscan
new
":help window-move-cursor
let s:myjunk_window=winnr()
exec 'edit ' myjunk
"Can we capture the intro?
let s:color_intro=""
let s:colorname=""
if exists("g:colors_name")
    let s:colorname=g:colors_name
    let cur_scheme=s:colorname
    let cur_f=""
    let cur_chk=$VIMRUNTIME . '/colors/' . cur_scheme . '.vim'
    if filereadable(cur_chk)
        let cur_f=cur_chk
    endif
    if $OS =~? "Windows"
        let cur_chk=$VIMRUNTIME . '/colors/' . cur_scheme . '.vim' "?????
    else
        let cur_chk=$HOME . '/.vim/colors/' . cur_scheme . '.vim'
    endif
    if filereadable(cur_chk)
        let cur_f=cur_chk
    endif
    if cur_f != ""
        let reg_h=@h
        new
        exec 'r ' . cur_f
        "foo\(bar\)\@!
        g/^hi\s\+\(clear\)\@!/d
        "Some commands in the intro would mess things up, so comment them
        g/^\(\s*hi\s\+clear\s\+\S\+\|\s*set\s\+\|\s*let\s\+.*colors_name\s*=\)\@!/ s/^\([^"]\)/"\1/e
        g/^$/d
        % yank h
        q!
        let s:color_intro=@h
        let @h=reg_h
    endif
endif
call s:Myjunk()

" the following trick avoids the "Press RETURN ..." prompt
"0 append
".


"Colors choices to look at
if !bufloaded("NamedColors")
    let s:myjunk_window=s:myjunk_window + 1
endif
if exists("s:choice") && s:choice ==? "dark"
    call Showhexcolornames(9,5,"h")
else
    call Showhexcolornames(9,4,"h")
endif

" restore global options and registers
let &hidden      = s:hidden
let &lazyredraw  = s:lazyredraw
let &more        = s:more
let &report      = s:report
let &shortmess   = s:shortmess
let &wrapscan    = s:wrapscan
let @a           = s:register_a
let @b           = s:register_b

" restore last search pattern
call histdel("search", -1)
let @/ = s:register_se

exec s:myjunk_window . "wincmd w" 
" show Normal at top
if !search('\chi normal','w')
    echo "WARNING: No Normal! The background may be wrong for xterms!"
    if !search('\chi comment','w')
        let nnc=search('\chi cursor','w')
    endif
endif

endfunction
"End function Color_toon

"Begin function s:Myjunk()
function s:Myjunk(...)
exec s:myjunk_window . "wincmd w" 

" save global options and registers
let hidden      = &hidden
let lazyredraw  = &lazyredraw
let more          = &more
let report      = &report
let shortmess   = &shortmess
let wrapscan    = &wrapscan
let register_a  = @a
let register_b  = @b
let register_se = @/
set hidden lazyredraw nomore report=99999 shortmess=aoOstTW wrapscan
1,$d
redir @a
silent hi
redir END
put a
%s/^\s\+\(term\|cterm\|gui\)\@!//
%s/^.*links to.*$//
"foo\(bar\)\@!
%s/font=.*\(term\|cterm\|gui\)\@!//e
%s/xxx//
g/^$/d
silent g/^col_cterm_/d
silent g/^col_[0-9a-fA-F]\{6,6}_/d
silent g/^colorsel/d
silent g/ cleared/d
g/\(\n\)\s\+/j
" precede syntax command
% substitute /^[^ ]*/syn keyword & &/
" execute syntax commands
syntax clear
% yank b
silent @b
" remove syntax commands again
% substitute /^syn keyword \(\S\+\) //
%s/^/hi /

" restore global options and registers
let &hidden      = hidden
let &lazyredraw  = lazyredraw
let &more        = more
let &report      = report
let &shortmess   = shortmess
let &wrapscan    = wrapscan
let @a           = register_a
let @b           = register_b
" restore last search pattern
call histdel("search", -1)
let @/ = register_se

if s:color_intro != "" && s:colorname != ""
    if match(s:color_intro, 'colors_name\s*=\s*"' . s:colorname . '"') != -1
        let @@=s:color_intro
        1put!
    endif
endif

" we don't want to save myjunk unless user made a change
set nomodified

" the following trick avoids the "Press RETURN ..." prompt
0 append
.

endfunction
"End function s:Myjunk()

"Begin function Color_toon_make
function Color_toon_make(...)
    if a:0 == 0
        let ground="fg"
    elseif a:1 =~? "^[br]" || a:1 =~? "^-b"
        let ground="bg"
    else
        let ground="fg"
    endif
    let group=""
    let color=""
    let reg_a=@a
    let reg_b=@b
    if match(reg_a, "cterm_") != -1 || match(reg_a, '[a-fA-F0-9]\{6,6}_') != -1
        let color=reg_a
    elseif match(reg_a, "=") != -1
        let group=reg_a
    endif
    if match(reg_b, "cterm_") != -1 || match(reg_b, '[a-fA-F0-9]\{6,6}_') != -1
        let color=reg_b
    elseif match(reg_b, "=") != -1
        let group=reg_b
    endif
    if group == "" || color == ""
        return
    endif
    let color_group=matchstr(group, '\S*', 3)
    let named_color=0
    if match(color, 'gui_') != - 1
        let gui_start=match(color, 'gui_')+4
        let gui_end=match(color, '[^a-zA-Z0-9]', gui_start)
    elseif match(color, '[a-fA-F0-9]\{6,6}_') != - 1
        let gui_start=matchend(color, '[a-fA-F0-9]\{6,6}_')
        let gui_end=match(color, '[^a-zA-Z0-9]', gui_start)
        let named_color=1
    endif
    let gui_len=gui_end - gui_start
    let gui_color=strpart(color, gui_start, gui_len)
    if !named_color
        let gui_color='#' . gui_color
        let cterm_start=match(color, '_')
        let cterm_end=match(color, '_', cterm_start+1)
        let cterm_len=cterm_end - cterm_start
        let cterm_color=strpart(color, cterm_start+1, cterm_len-1)
    endif
    let spec=group
    if ground == "fg"
        if !named_color
            let ctermfg=' ctermfg=' . cterm_color . ' '
            let spec=substitute(spec, 'ctermfg=\S*', ctermfg, '')
        endif
        let guifg=' guifg=' . gui_color . ' '
        let spec=substitute(spec, 'guifg=\S*', guifg, '')
        if !named_color && match(spec, 'ctermfg=') == -1
            let spec=substitute(spec, '\(hi \S*\)', '\1' . ctermfg, '')
        endif
        if match(spec, 'guifg=') == -1
            let spec=substitute(spec, '\(hi \S*\)', '\1' . guifg, '')
        endif
    endif

    if ground == "bg"
        if !named_color
            let ctermbg=' ctermbg=' . cterm_color . ' '
            let spec=substitute(spec, 'ctermbg=\S*', ctermbg, '')
        endif
        let guibg=' guibg=' . gui_color . ' '
        let spec=substitute(spec, 'guibg=\S*', guibg, '')
        if !named_color && match(spec, 'ctermbg=') == -1
            let spec=substitute(spec, '\(hi \S*\)', '\1' . ctermbg, '')
        endif
        if match(spec, 'guibg=') == -1
            let spec=substitute(spec, '\(hi \S*\)', '\1' . guibg, '')
        endif
    endif

    let g:zoo=g:zoo.':'.s:myjunk_window.':'.s:myjunk_buf.':'.bufwinnr(s:myjunk_buf).':'.s:junk
    if !exists("s:myjunk_window") || bufwinnr(s:myjunk_buf) == -1
        echo "Did you forget to run Colortoon? Myjunk is in window(" . not_exists . ")"
        "not_exists doesn't exist so it would throw an error -- I know,
    else
        exec s:myjunk_window . "wincmd w" 
        let pat=group
        if match(pat,"\n") != -1 || match(pat,'\n') != -1
            let pat=strpart(pat,0,strlen(pat)-1)
        endif
        exec '/' . pat . '/ s/' . pat . '/' . spec . '/'
        exec 's/\(=\S*\)\s*/\1 /ge'
        exec 's/' . nr2char(10) . '//ge'
        exec spec
    endif
    return spec
endfunction
"End function Color_toon_make
