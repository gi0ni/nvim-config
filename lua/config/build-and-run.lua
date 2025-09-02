vim.keymap.set('n', '<leader>r', function()
	vim.cmd('wa')

	-- rust
	if vim.fn.filereadable('Cargo.toml') == true then
		vim.fn.jobstart([[ start cmd.exe /c "cargo build && (echo. & for %a in (target\debug\*.exe) do @call %a) & (echo. & echo. & echo Process exited with code %ERRORLEVEL%. & pause)" ]])

	-- python
	elseif vim.api.nvim_buf_get_name(0):match('%.py$') then
		vim.fn.jobstart([[ start cmd.exe /c "python ]] .. vim.fn.expand('%') .. [[ & (echo. & echo. & pause)" ]])

	-- cmake
	elseif vim.fn.isdirectory('build') ~= 0 then
		vim.fn.jobstart([[ start cmd.exe /c "ninja -C build && (echo. & for %a in (bin\*.exe) do @call %a) || (echo. & echo. & pause)" ]])

	-- error
	else
		vim.notify("failed to run '" .. vim.fn.expand('%') .. "'. unknown file type")
	end
end, { silent = true })
