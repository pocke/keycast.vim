keycast.vim
====

Display key strokes on Vim.



![keycast vim](https://user-images.githubusercontent.com/4361134/60764096-7ee96980-a0bd-11e9-848b-5331156ea33b.gif)

Usage
---

* `:KeycastStart`
  * Start casting key strokes.
* `:KeycastStop`
  * Stop casting key strokes.


Requirements
---

* Popup feature of Vim.
* [pocke/vanner](https://github.com/pocke/vanner) or banner (1)
  * Known issue: BSD banner does not work for keycast.vim.


Configuration
---

```vim
" Use pocke/vanner (default)
let keycast#formatter = 'vanner'

" Use banner (1)
let keycast#formatter = 'banner_command'
```
