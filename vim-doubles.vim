function! SelectTextObject()
    let nomatch = 'x([{''"x"''}])x'
    let maxlen = 99999999

    " set a mark so we know where we started
    normal! mm

    " count length of text inside various delimiters
    let delimiters = ['(', '[', '{', '''', '"']
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
        execute 'normal! `mvi' . d . '"yy'
        if @y == nomatch
            " a very ugly hack follows :/
            call add(delimiter_lens, maxlen)
            execute "normal! \<esc>"
        else
            call add(delimiter_lens, strlen(@y))
        endif
    endfor

    if min(delimiter_lens) == maxlen
        " no delimiters to select inside... just spit out a 1-char selection
        execute 'normal! `mv'
    else
        let idx = index(delimiter_lens, min(delimiter_lens))
        execute 'normal! `mvi' . delimiters[idx]
    endif
endfunction

vnoremap <silent> ii :<C-u>call SelectTextObject()<cr>
