function! SelectTextObject(type)
    let nomatch = 'x([{''"<x>"''}])x'
    let maxlen = 99999999

    " set a mark so we know where we started
    normal! mm
    let wv = winsaveview()

    " count length of text inside various delimiters
    let delimiters = ['(', '[', '{', '''', '"', '<']
    let delimiter_lens = []
    for d in delimiters
        let @y = nomatch
        " here we take advantage of a rather strange feature of vim.
        " if the vi{d} action fails (i.e. if d is a quote and there's no
        "   quotes to select inside of), vim will just stop executing the
        "   normal! stuff completely.
        " this means that if the 'y' register is unchanged, we can safely
        "   assume that either a.) there were none of this delimiter to select
        "   or b.) the stuff we yanked just so happened to be the same as the
        "   original register
        " to combat case b.), we simply carefully select the register's
        "   original value such that it is impossible for this to be the case.
        execute 'normal! `mv' . a:type . d . '"yy'
        if @y == nomatch
            " a very ugly hack follows :/
            call add(delimiter_lens, maxlen)
            execute "normal! \<esc>"
        else
            " due to strange vim semantics, sometimes we can get a selection
            "   from i[foo] or a[foo] that did not include the cursor position.
            "   fix that:
            let markpos = getpos("'m")
            let startpos = getpos("'<")
            let endpos = getpos("'>")
            let err = 0
            if (markpos[1] < startpos[1]) || (markpos[1] > endpos[1])
                let err = 1
            elseif markpos[1] == startpos[1]
                if markpos[2] < startpos[2]
                    let err = 1
                endif
            elseif markpos[1] == endpos[1]
                if markpos[2] > endpos[2]
                    let err = 1
                endif
            endif

            if err
                call add(delimiter_lens, maxlen)
            else
                call add(delimiter_lens, strlen(@y))
            endif
        endif
    endfor

    if min(delimiter_lens) == maxlen
        " no delimiters to select inside... just spit out an error message
        echoerr 'vim-doubles: no delimiters found'
    else
        let idx = index(delimiter_lens, min(delimiter_lens))
        execute 'normal! `mv' . a:type . delimiters[idx]
    endif

    call winrestview({'topline': wv['topline']})
endfunction

function! VSelectTextObject(type)
    " let's be as safe as possible with mappings and such here
    normal! v
    execute 'normal ' . a:type . a:type
endfunction

vnoremap <silent> ii :<C-u>call SelectTextObject('i')<cr>
onoremap <silent> ii :<C-u>call VSelectTextObject('i')<cr>
vnoremap <silent> aa :<C-u>call SelectTextObject('a')<cr>
onoremap <silent> aa :<C-u>call VSelectTextObject('a')<cr>
