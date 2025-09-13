vim.keymap.set('n', '<leader>r', function()
	vim.cmd('wa')

	local file = vim.fn.expand('%')

	-- cmake
    if vim.fn.isdirectory('build') ~= 0 then
		Launch("ninja -C build", "bin")

	-- rust
	elseif vim.fn.filereadable('Cargo.toml') == 1 then
		Launch("cargo build", "target/debug")

	-- python
	elseif vim.bo.filetype == "python" then
		Launch("python", file)

	-- javascript
	elseif vim.bo.filetype == "javascript" or vim.bo.filetype == "typescript" then
		Launch("node", file)

	-- unknown
	else
		vim.notify("failed to run '" .. file .. "'. unknown file type")
	end
end)

-- this is terrible :D
function Launch(build, run)
	local compiler = (build ~= "python" and build ~= "node")

	if compiler then
		-- add compile command
		build = string.format([[
			%s
			Write-Host ''
		]], build)

		-- deduct executable path
		local cwd     = vim.fn.getcwd()
		local program = vim.fn.fnamemodify(cwd, ":t")

		run = string.format([[
			& %s/%s.exe
		]], run, program)
	else
		run = build .. " " .. run
		build = "cmd /c exit 0"
	end

	local command = string.format([[
		<# build #>
		%s

		<# run #>
		$timer = [System.Diagnostics.Stopwatch]::new()

		if($LastExitCode -eq 0) {
			$timer.Start()
			%s
		}

		<# error code #>
		Write-Host ''
		Write-Host ''
		Write-Host ''
		Write-Host -NoNewLine ('Process returned code {0} (0x{1})' -f $LASTEXITCODE, ($LASTEXITCODE).ToString('X').PadLeft(8, '0'))

		<# time #>
		$timer.Stop()
		$minutes      = $timer.Elapsed.Minutes
		$seconds      = $timer.Elapsed.Seconds
		$milliseconds = $timer.Elapsed.Milliseconds
		Write-Host (' in {0:d2}:{1:d2}.{2:d3} seconds' -f $minutes, $seconds, $milliseconds)

		<# pause #>
		Write-Host -NoNewLine 'Press any key to continue...'
		$null = $Host.UI.RawUI.ReadKey('NoEcho, IncludeKeyDown')
	]], build, run):gsub("[\n\t]+", "\\;")

	vim.fn.jobstart([[ wt -p "PowerShell" --startingDirectory "." pwsh -c "]] .. command .. [["]])
end
