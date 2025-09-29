vim.keymap.set('n', '<leader>m', ':!cmake -B build -G Ninja<CR>')

local os = vim.loop.os_uname().sysname

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
		if os == 'Windows_NT' then
			Launch("python", file)
		else
			Launch("python3", file)
		end

	-- javascript
	elseif vim.bo.filetype == "javascript" or vim.bo.filetype == "typescript" then
		Launch("node", file)

	-- unknown
	else
		vim.notify("failed to run '" .. file .. "'. unknown file type")
	end
end)

function Launch(build, run)
	if os == 'Windows_NT' then
		LaunchWindows(build, run)
	else
		LaunchLinux(build, run)
	end
end

-- this is terrible :D
function LaunchWindows(build, run)
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
		Write-Host (' in {0:d2}:{1:d2}.{2:d3} seconds.' -f $minutes, $seconds, $milliseconds)

		<# pause #>
		Write-Host -NoNewLine 'Press any key to continue...'
		$null = $Host.UI.RawUI.ReadKey('NoEcho, IncludeKeyDown')
	]], build, run):gsub("[\n\t]+", "\\;")

	vim.fn.jobstart([[ wt -p "PowerShell" --startingDirectory "." pwsh -c "]] .. command .. [["]])
end

function LaunchLinux(build, run)

	local compiler = (build ~= "python3" and build ~= "node")
	local command_b = [[]]

	if compiler then
		-- get binary path
		local cwd     = vim.fn.getcwd()
		local program = vim.fn.fnamemodify(cwd, ":t")

		run = string.format([[
			./%s/%s
		]], run, program)

		command_b = string.format([[ %s && (echo; %s);]], build, run);
	else
		command_b = string.format([[ %s %s; ]], build, run) -- e.g. python program.py
	end

	local command_a = [[
		start=$(date +%s%3N);
	]]

	local command_c = [[
		ret=$?;

		end=$(date +%s%3N);
		duration_ms=$((end - start));
		minutes=$((duration_ms / 60000));
		seconds=$(( (duration_ms % 60000) / 1000 ));
		millis=$((duration_ms % 1000));
		formatted_time=$(printf "%02d:%02d.%03d" $minutes $seconds $millis);

		echo -ne "\n\n";
		echo -ne "Process returned code $ret (0x$(printf "%08X" $ret))";
		echo " in $formatted_time seconds.";
		echo -ne "Press any key to continue...";
		read -n 1;
	]]

	local final_command = command_a .. command_b .. command_c
	vim.fn.jobstart("gnome-terminal -- bash -ic '" .. final_command .. "'")
end
