let s:ch_a = char2nr('a')
let s:ch_z = char2nr('z')
let s:ctrl_offest = 96

let s:win_positions = {}

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

  let move_offset = max(map(copy(ch), { _, v -> len(v) }))
  call s:move_existing_popups_to_left(move_offset)
  let line = &lines - 1
  let col = &columns - 1

  let winid = popup_create(ch, {
  \   "time": 2000,
  \   "pos": "botright",
  \   "line": line,
  \   "col": col,
  \   "callback": { id, _ -> s:handle_popup_close(id) }
  \ })

  let s:win_positions[winid] = {"line": line, "col": col}
endfunction

function! s:handle_popup_close(winid) abort
  call remove(s:win_positions, a:winid)
endfunction

function! s:move_existing_popups_to_left(offset) abort
  for id in keys(s:win_positions)
    let pos = s:win_positions[id]
    let new_pos = {"line": pos.line, "col": pos.col - a:offset}
    let s:win_positions[id] = new_pos
    call popup_move(id, {
    \   "pos": "botright",
    \   "line": new_pos.line,
    \   "col": new_pos.col,
    \ })
  endfor
endfunction

function! keycast#start() abort
  let s:filter_popup_id = popup_create('', {"filter": { _, key -> s:display_key(key)}, "zindex": 10000})
endfunction

function! keycast#stop() abort
  call popup_close(s:filter_popup_id)
endfunction
