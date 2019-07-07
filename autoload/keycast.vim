let s:display_typed_char_zindex = 1

let s:ch_a = char2nr('a')
let s:ch_z = char2nr('z')
let s:ctrl_offest = 96

function! s:key2str(key) abort
  if a:key ==# "\<Esc>"
    return '<Esc>'
  elseif a:key ==# "\<CR>"
    return '<CR>'
  elseif a:key ==# " "
    return '<Space>'
  end

  let nr = char2nr(a:key)
  let nr_without_ctrl = nr + s:ctrl_offest
  if s:ch_a <= nr_without_ctrl && nr_without_ctrl <= s:ch_z
    return "<C-" . nr2char(nr_without_ctrl) . ">"
  else
    return a:key
  endif
endfunction

function! s:display_key(key) abort
  let ch = systemlist('banner ' . shellescape(s:key2str(a:key)))
  let winid = popup_create(ch, {"zindex": s:display_typed_char_zindex})
  let s:display_typed_char_zindex += 1
  call timer_start(500, { -> popup_close(winid) })
endfunction

function! keycast#start() abort
  let s:filter_popup_id = popup_create('', {"filter": { _, key -> s:display_key(key)}, "zindex": 10000})
endfunction

function! keycast#stop() abort
  call popup_close(s:filter_popup_id)
endfunction
