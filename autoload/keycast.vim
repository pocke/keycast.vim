let s:save_cpo = &cpo
set cpo&vim

" --- Formatters

function! s:banner_command(char) abort
  return systemlist('banner ' . shellescape(s:key2str(a:char)))
endfunction

function! s:vanner(char) abort
  let data = vanner#string(a:char, {})
  return split(data, "\n")
endfunction

function! s:raw(char) abort
  return [a:char]
endfunction

function! s:format(char) abort
  return call(g:keycast#formatters[g:keycast#formatter], [a:char])
endfunction

let keycast#formatters = {
\   "banner_command": funcref("s:banner_command"),
\   "vanner": funcref("s:vanner"),
\   "raw": funcref("s:raw"),
\ }
let keycast#formatter = get(g:, 'keycast#formatter', 'vanner')

let s:ch_a = char2nr('a')
let s:ch_z = char2nr('z')
let s:ctrl_offest = 96

let s:bottom_win_positions = {}
let s:other_win_positions = {}


function! s:key2str(key) abort
  if a:key ==# "\<Esc>"
    return '<Esc>'
  elseif a:key ==# "\<CR>"
    return '<CR>'
  elseif a:key ==# "\<BS>"
    return '<BS>'
  elseif a:key ==# "\<Tab>"
    return '<Tab>'
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
  let ch = s:format(s:key2str(a:key))

  " Move existing popups
  let width = max(map(copy(ch), { _, v -> len(v) }))
  let height = len(ch)
  if a:key ==# "\<CR>"
    call s:move_existing_popups_to_top(height + 1)
  else
    call s:move_existing_popups_to_left(width)
  end

  let line = &lines - 1
  let col = &columns - 1

  let winid = popup_create(ch, {
  \   "time": 2000,
  \   "pos": "botright",
  \   "line": line,
  \   "col": col,
  \   "callback": { id, _ -> s:handle_popup_close(id) }
  \ })

  let pos = {"line": line, "col": col, "width": width, "height": height}
  let s:bottom_win_positions[winid] = pos
endfunction

function! s:handle_popup_close(winid) abort
  if has_key(s:bottom_win_positions, a:winid)
    call remove(s:bottom_win_positions, a:winid)
  endif
  if has_key(s:other_win_positions, a:winid)
    call remove(s:other_win_positions, a:winid)
  endif
endfunction

function! s:move_existing_popups_to_left(offset) abort
  for id in keys(s:bottom_win_positions)
    let pos = s:bottom_win_positions[id]
    let pos.col -= a:offset

    if pos.col - pos.width < 0
      call popup_close(id)
      call s:handle_popup_close(id)
    else
      call popup_move(id, {
      \   "pos": "botright",
      \   "line": pos.line,
      \   "col": pos.col,
      \ })
    end
  endfor
endfunction

function! s:move_existing_popups_to_top(offset) abort
  call s:move_to_top(s:bottom_win_positions, a:offset)
  call s:move_to_top(s:other_win_positions, a:offset)

  call extend(s:other_win_positions, s:bottom_win_positions)
  let s:bottom_win_positions = {}
endfunction

function! s:move_to_top(positions, offset) abort
  for id in keys(a:positions)
    let pos = a:positions[id]
    let pos.line -= a:offset

    if pos.line - pos.height < 0
      call popup_close(id)
      call s:handle_popup_close(id)
    else
      call popup_move(id, {
      \   "pos": "botright",
      \   "line": pos.line,
      \   "col": pos.col,
      \ })
    end
  endfor
endfunction

function! keycast#start() abort
  let s:filter_popup_id = popup_create('', {"filter": { _, key -> s:display_key(key)}, "zindex": 10000})
endfunction

function! keycast#stop() abort
  call popup_close(s:filter_popup_id)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
