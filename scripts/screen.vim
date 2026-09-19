" 안쪽 vim 을 터미널 버퍼로 띄우고 화면을 칸 단위로 긁어 JSON 으로 저장한다.
"
" scripts/terminal.py 가 환경 변수로 인자를 넘긴다. 진짜 터미널 화면을
" 그대로 받아 오므로 airline 의 구분자와 색을 손으로 흉내 낼 필요가 없다.
" 바깥 vim 에는 pty 가 있어야 하니 script(1) 을 통해 부른다.

let s:rows = str2nr($MPX_ROWS)
let s:cols = str2nr($MPX_COLS)

let s:buf = term_start(split($MPX_CMD, "\n"), {
      \ 'term_rows': s:rows, 'term_cols': s:cols,
      \ 'hidden': 1, 'term_kill': 'kill'})
call term_wait(s:buf, str2nr($MPX_WAIT))

" 화면을 잡기 전에 보낼 키. "\<CR>" 같은 표기를 쓰려고 eval 을 거친다.
for s:keys in filter(split($MPX_KEYS, "\n"), 'v:val !=# ""')
  call term_sendkeys(s:buf, eval('"' . escape(s:keys, '"') . '"'))
  call term_wait(s:buf, 400)
endfor

let s:screen = []
for s:r in range(1, s:rows)
  let s:line = []
  for s:cell in term_scrape(s:buf, s:r)
    call add(s:line, {
          \ 'c': s:cell.chars, 'fg': s:cell.fg, 'bg': s:cell.bg,
          \ 'w': s:cell.width,
          \ 'b': term_getattr(s:cell.attr, 'bold'),
          \ 'i': term_getattr(s:cell.attr, 'italic'),
          \ 'u': term_getattr(s:cell.attr, 'underline'),
          \ 'r': term_getattr(s:cell.attr, 'reverse')})
  endfor
  call add(s:screen, s:line)
endfor

call writefile([json_encode(s:screen)], $MPX_OUT)
qall!
