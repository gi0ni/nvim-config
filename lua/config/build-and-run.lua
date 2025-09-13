vim.keymap.set('n', '<leader>r', function()
	vim.cmd('wa')

	--  NOTE: If you want to print error codes as well in the future do yourself a favor and use powershell

	-- rust
	if vim.fn.filereadable('Cargo.toml') == 1 then
		vim.fn.jobstart([[ start cmd.exe /c "cargo build && (echo. & for %a in (target\debug\*.exe) do @call %a) & (echo. & echo. & pause)" ]])

	-- python
	elseif vim.api.nvim_buf_get_name(0):match('%.py$') then
		vim.fn.jobstart([[ start cmd.exe /c "python ]] .. vim.fn.expand('%') .. [[ & (echo. & echo. & pause)" ]])

	-- js
	elseif vim.bo.filetype == "javascript" or vim.bo.filetype == "typescript" then
		vim.fn.jobstart([[ start cmd.exe /c "node ]] .. vim.fn.expand('%') .. [[ & (echo. & echo. & pause)" ]])

	-- cmake
	elseif vim.fn.isdirectory('build') ~= 0 then
		vim.fn.jobstart([[ start cmd.exe /c "ninja -C build && (echo. & for %a in (bin\*.exe) do @call %a) || (echo. & echo. & pause)" ]])

	-- unknown
	else
		vim.notify("failed to run '" .. vim.fn.expand('%') .. "'. unknown file type")
	end
end, { silent = true })
