-- ask for args manually
ArgsList = ''
ArgsListTokenized = {}
vim.keymap.set('n', '<leader>a', function()
	ArgsList = vim.fn.input('Enter Args: ')

	-- copy by value
	for key, _ in pairs(ArgsListTokenized) do
		ArgsListTokenized[key] = nil
	end

	if ArgsList == '' then
		return
	end

	local temp = vim.split(ArgsList, ' +')

	for key, val in pairs(temp) do
		ArgsListTokenized[key] = val
	end
end)


-- cmake
vim.keymap.set('n', '<leader>m', ':!cmake -B build -G Ninja<CR>')


-- build only
vim.keymap.set('n', '<leader>n', ':Build<CR>')

vim.api.nvim_create_user_command('Build', function()
	vim.cmd('wa')

	-- cmake
	if vim.fn.isdirectory('build') ~= 0 then
		vim.cmd('!ninja -C build')

	-- rust
	elseif vim.fn.filereadable('Cargo.toml') == 1 then
		vim.cmd('!cargo build')

	-- c single file
	elseif vim.bo.filetype == 'c' then
		local file = vim.fn.expand('%')
		if vim.fn.isdirectory('bin') == 0 then vim.cmd('silent! !mkdir bin') end
		local program = 'bin/' .. vim.fn.fnamemodify(file, ':r')
		vim.cmd('!gcc -g ' .. file .. ' -o ' .. program)

	-- unknown
	else
		vim.notify("failed to run build system. unknown project type")
	end
end, { desc = 'build. build. build.' })


-- build and run
vim.keymap.set('n', '<leader>r', function()
	Run(0)
end)

vim.keymap.set('n', '<F5>', function()
	local found = false
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype');
		found = (filetype == 'c')
	end

	if not found then
		vim.notify('only works with single file c applets')
		return
	end

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		Run(bufnr)
	end
end)

function Run(bufnr)
	vim.cmd('wa')

	local file = vim.api.nvim_buf_get_name(bufnr)
	local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype');

	-- cmake
	if vim.fn.filereadable('build-and-run.sh') == 1 then
		vim.cmd("silent! !./build-and-run.sh "..ArgsList)

	elseif vim.fn.isdirectory('build') ~= 0 then
		Launch("ninja -C build", "bin", "buildsystem")

		-- rust
	elseif vim.fn.filereadable('Cargo.toml') == 1 then
		Launch("cargo build", "target/debug", "buildsystem")

		-- python
	elseif filetype == "python" then
		Launch((IsWin32 and "python" or "python3"), file, "interpreter")

		-- javascript
	elseif filetype == "javascript" or filetype == "typescript" then
		Launch("node", file, "interpreter")

		-- bash scripts
	elseif not IsWin32 and filetype == 'sh' then
		LaunchLinux("bash", file, "interpreter")

		-- c single file
	elseif filetype == 'c' then
		if vim.fn.isdirectory("bin") == 0 then vim.cmd("silent! !mkdir bin") end
		local program = "bin/" .. vim.fn.fnamemodify(file, ":t:r")
		Launch("gcc -g " .. file .. " -o " .. program, program, "compiler")

		-- unknown
	else
		vim.notify("failed to run '" .. file .. "'. unknown file type")
	end
end

function Launch(build, run, mode) -- mode can be buildsystem, compiler and interpreter
	if IsWin32 then
		LaunchWindows(build, run, mode)
	else
		LaunchLinux(build, run, mode)
	end
end


--==================== WINDOWS ====================--
function LaunchWindows(build, run, mode)

	if mode == "buildsystem" then
		-- add compile command
		build = string.format([[
			%s
			Write-Host ''
		]], build)

		-- deduct executable path
		local cwd     = vim.fn.getcwd()
		local program = vim.fn.fnamemodify(cwd, ":t")

		run = string.format([[
			& %s/%s.exe %s
		]], run, program, ArgsList)

	elseif mode == "interpreter" then
		run = build .. " " .. run .. " " .. ArgsList
		build = "cmd /c exit 0"

	elseif mode == "compiler" then
		run = "& ./" .. run .. " " .. ArgsList

	else
		vim.notify("unknown launch mode '" .. mode .. "'!")
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


--==================== LINUX ====================--
function LaunchLinux(build, run, mode)

	local command_b = [[]]

	if mode == "buildsystem" then
		-- get binary path
		local cwd     = vim.fn.getcwd()
		local program = vim.fn.fnamemodify(cwd, ":t")

		run = string.format([[
			./%s/%s
		]], run, program)

		command_b = string.format([[ %s && (echo; %s %s);]], build, run, ArgsList);

	elseif mode == "interpreter" then
		command_b = string.format([[ %s %s %s; ]], build, run, ArgsList) -- e.g. python program.py

	elseif mode == "compiler" then
		command_b = string.format([[ %s && (./%s %s); ]], build, run, ArgsList)

	else
		vim.notify("unknown launch mode '" .. mode .. "'!")
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

		echo -ne "\n\n\n";
		echo -ne "Process returned code $ret (0x$(printf "%08X" $ret))";
		echo " in $formatted_time seconds.";
		echo -ne "Press any key to continue...";
		read -n 1;
	]]

	local final_command = command_a .. command_b .. command_c
	vim.fn.jobstart("tmux new-window -n build '" .. final_command .. "'")
end
