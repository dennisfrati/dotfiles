" startscreen.vim by Dennis Frati
" Vim start page plugin

let s:logo_path = fnamemodify(resolve(expand('<sfile>')), ':h') . '/logo.txt'

function! StartScreen()
    if argc() != 0 | return | endif

    enew
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile

    let l:num_files = 20
    let l:distro = trim(system('grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d ''"'''))
    let l:date   = strftime('%d/%m/%Y %H:%M:%S')

    let l:logo = filereadable(s:logo_path) ? readfile(s:logo_path) : []

    let l:header = l:logo + [
        \ '',
        \ '  [VIM] ' . l:date . ' ' . l:distro,
        \ '',
        \ '  Recent files or empty file',
        \ '',
    \ ]

    let l:files = v:oldfiles[:l:num_files - 1]
    let l:lines = ['  [ 0 ]  <empty file>', '']
    let l:i = 1
    for f in l:files
        call add(l:lines, printf('  [ %d ]  %s', l:i, f))
        let l:i += 1
    endfor

    call setline(1, l:header + l:lines)
    setlocal nomodifiable nonumber norelativenumber signcolumn=no

    hi StartScreenTitle   ctermfg=15
    hi StartScreenBracket ctermfg=1  cterm=bold
    hi StartScreenNum     ctermfg=15 cterm=bold
    hi StartScreenSlash   ctermfg=1

    call matchadd('StartScreenTitle',   '\%' . (len(l:logo) + 2) . 'l.*')
    call matchadd('StartScreenBracket', '\[')
    call matchadd('StartScreenBracket', '\]')
    call matchadd('StartScreenNum',     '\[\s*\zs\d\+\ze\s*\]')
    call matchadd('StartScreenSlash',   '\%>' . len(l:header) . 'l/')

    call cursor(len(l:header) + 1, 5)

    nnoremap <buffer> <CR> :call OpenOldFile()<CR>
    nnoremap <buffer> q :quit<CR>
    nnoremap <buffer> j :call StartScreenDown()<CR>
    nnoremap <buffer> k :call StartScreenUp()<CR>
endfunction

function! StartScreenDown()
    let l:i = line('.') + 1
    while l:i <= line('$')
        if getline(l:i) =~# '\[\s*\d\+\s*\]'
            call cursor(l:i, 5)
            return
        endif
        let l:i += 1
    endwhile
endfunction

function! StartScreenUp()
    let l:i = line('.') - 1
    while l:i >= 1
        if getline(l:i) =~# '\[\s*\d\+\s*\]'
            call cursor(l:i, 5)
            return
        endif
        let l:i -= 1
    endwhile
endfunction

function! OpenOldFile()
    let l:match = matchstr(getline('.'), '\[\s*\d\+\s*\]\s\+\zs.*')
    if l:match ==# '<empty file>'
        enew
    elseif !empty(l:match)
        execute 'edit ' . fnameescape(l:match)
    endif
endfunction

autocmd VimEnter * call StartScreen()
