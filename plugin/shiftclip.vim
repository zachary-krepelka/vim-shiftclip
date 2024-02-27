" FILENAME: shiftclip.vim
" AUTHOR: Zachary Krepelka
" DATE: Wednesday, February 21st, 2024
" ABOUT: Block alignment for the Vim text editor
" ORIGIN: https://github.com/zachary-krepelka/vim-shiftclip.git

" Commands {{{1

command! -range -nargs=? Left   <line1>, <line2> call s:align('l', <f-args>)
command! -range -nargs=? Right  <line1>, <line2> call s:align('r', <f-args>)
command! -range -nargs=? Center <line1>, <line2> call s:align('c', <f-args>)

" Functions {{{1

function! s:align(direction, width =
			\ a:direction == 'l' ? 0 : &textwidth ?? 80) range

	" guard against faulty input

	if a:width !~# '^\d\+$'
		echoerr 'expected one non-negative integer'
		return
	endif

	let range = a:firstline  .. ',' .. a:lastline

	" evaluation order is important

	" must come first

	call s:cleanup(l:range)

	" must come second

	let slw = s:shortest_leading_whitespace(a:firstline, a:lastline)

	" must come third

	if l:slw != 0
		" remove the shortest leading whitespace
		exe l:range .. 'norm 0' .. l:slw .. 'x'
	endif

	" must come forth

	let lll = s:longest_line_length(a:firstline, a:lastline)

	if l:lll > a:width && a:direction != 'l'
		echoerr 'snippet size exceeds specified length'
		return
	endif

	" now comes the rest

	if a:direction == 'l' " left

		let l:pad = a:width

	elseif a:direction == 'c' " center

		let l:pad = (a:width - l:lll) / 2

	elseif a:direction == 'r' " right

		let l:pad = a:width - l:lll

	endif

	" prepend padding to each line

	exe l:range .. 'norm 0' .. l:pad .. 'i '

endfunction

function! s:cleanup(range)

	" kill leading tabs

	exe a:range .. 's/\(^\s*\)\@<=\t/\=repeat(" ", &tabstop)/ge'

	" kill trailing whitespace

	exe a:range .. 's/\s\+$//e'

endfunction

function! s:longest_line_length(start, end)

	return max(map(getline(a:start, a:end),
				\'strdisplaywidth(v:val)'))

endfunction

function! s:shortest_leading_whitespace(start, end)

	return min(map(getline(a:start, a:end),
				\'len(matchstr(v:val, "^\\s*"))'))

endfunction

" Menus {{{1

if has("gui_running") && has("menu") && &go =~# 'm'

	amenu <silent> &Plugin.Shiftclip.&Left :'<,'> Left<CR>
	amenu <silent> &Plugin.Shiftclip.&Right :'<,'> Right<CR>
	amenu <silent> &Plugin.Shiftclip.&Center :'<,'> Center<CR>
	amenu <silent> &Plugin.Shiftclip.&Help :tab help vim-shiftclip<CR>

endif
