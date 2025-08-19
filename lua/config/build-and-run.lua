vim.keymap.set('n', '<leader>r', function()
	vim.cmd('wa')

	-- python
	if vim.api.nvim_buf_get_name(0):match('%.py$') then
		vim.fn.jobstart([[ start cmd.exe /c "python ]] .. vim.fn.expand('%') .. [[ & (echo. & echo. & pause)" ]])

	-- cmake
	elseif vim.fn.isdirectory('build') ~= 0 then
		vim.fn.jobstart([[ start cmd.exe /c "ninja -C build && (echo. & for %a in (bin\*.exe) do @call %a) || (echo. & echo. & pause)" ]])

	-- error
	else
		vim.notify("failed to run '" .. vim.fn.expand('%') .. "'. unknown file type")
	end
end, { silent = true })
