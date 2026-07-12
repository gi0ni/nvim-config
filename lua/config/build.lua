ArgsList = nil
ArgsListTokenized = {}

vim.keymap.set('n', '<leader>ba', function()
	ArgsList = vim.fn.input('Enter Args: ')

	-- This is how you remove elements from a table in Lua...
	for key in pairs(ArgsListTokenized) do
		ArgsListTokenized[key] = nil
	end

	if ArgsList == nil then
		return
	end

	-- Important! Copy temporary table by value
	local tokens = vim.split(ArgsList, ' +')

	for key, val in pairs(tokens) do
		ArgsListTokenized[key] = val
	end
end)

-- Quick build (and run) shortcuts for a wide variety of languages (4!)
local pythonRuntime = IsWin32 and 'python' or 'python3'
local globalBuildScript = vim.fn.stdpath('config') .. '/scripts/build.py'

local curDirName
local bufferName
local binaryName

local launchDisabled = false

vim.keymap.set('n', '<leader>r', function()
	Build({launch=true})
end)

vim.keymap.set('n', '<leader>bb', function()
	Build({launch=false})
end)

vim.keymap.set('n', '<leader>bm', ':!cmake -B build -G Ninja -D CMAKE_BUILD_TYPE=Debug')

vim.keymap.set('n', '<leader>bpy', function()
	if vim.fn.filereadable('build.py') == 1 then
		vim.notify('There already is a local `build.py`. Will not overwrite.')
		return
	end

	local inpfile = io.open(globalBuildScript, 'r')
	local outfile = io.open('build.py', 'w')

	if inpfile == nil or outfile == nil then
		vim.notify('Error. Failed to copy file!')
		return
	end

	local contents = inpfile:read('*a')
	inpfile:close()

	outfile:write(contents)
	outfile:close()
	vim.notify(string.format('Copied `%s` to local directory.', vim.fn.stdpath('config') .. '/scripts/build.py'))
end)

function Build(opt)
	launchDisabled = not opt.launch

	vim.cmd('wa')

	if vim.fn.filereadable('build.py') == 1 then
		RunBuildScript(nil, nil, 'build.py')
		return
	end

	curDirName = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
	bufferName = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':t')
	binaryName = curDirName .. (IsWin32 and '.exe' or '')

	local config = ResolveBuilder()
	if config == nil then
		vim.notify(string.format('Failed to launch `%s`. No configuration found.', bufferName))
		return
	end

	if config.build == nil and (config.launch == nil or launchDisabled) then
		vim.notify('No commands were given. There is nothing to do.')
		return
	end

	RunBuildScript(config.build, config.launch)
end

local builders = {
	CMAKE  = 1,
	CARGO  = 2,
	PYTHON = 3,
	BASH   = 4
}

local builderConfig = {
	[builders.CMAKE] = {
		build = 'ninja -C build',
		launch = 'bin/{binaryName} {ArgsList}',
		pattern = {
			type = 'file',
			what = 'CMakeLists.txt'
		}
	},

	[builders.CARGO] = {
		build = 'cargo build',
		launch = 'target/debug/{binaryName} {ArgsList}',
		pattern = {
			type = 'file',
			what = 'Cargo.toml'
		}
	},

	[builders.PYTHON] = {
		build = nil,
		launch = '{pythonRuntime} {bufferName} {ArgsList}',
		pattern = {
			type = 'extension',
			what = 'py'
		}
	},

	[builders.BASH] = {
		build = nil,
		launch = 'bash {bufferName} {ArgsList}',
		pattern = {
			type = 'extension',
			what = 'sh'
		}
	}
}

function ResolveBuilder()
	local orderedKeys = {}

	for key in pairs(builders) do
		table.insert(orderedKeys, key)
	end

	table.sort(orderedKeys)

	local chosenKey = nil

	for key = 1, #orderedKeys do
		if MatchBuilderPattern(builderConfig[key].pattern) then
			chosenKey = key
			break
		end
	end

	if chosenKey == nil then
		return nil
	end

	return GetBuilderCommands(builderConfig[chosenKey])
end

function MatchBuilderPattern(pattern)
	if pattern.type == 'file' then
		return vim.fn.filereadable(pattern.what) == 1

	elseif pattern.type == 'extension' then
		local ext = vim.fn.fnamemodify(bufferName, ':e')
		return ext == pattern.what
	end
end

function GetBuilderCommands(config)
	local fmtArgs = {
		['{binaryName}'] = binaryName,
		['{ArgsList}'] = ArgsList or '',
		['{pythonRuntime}'] = pythonRuntime,
		['{bufferName}'] = bufferName,
	}

	local regexPattern = '{[a-zA-Z_][0-9a-zA-Z_]*}'

	return {
		build = config.build and string.gsub(config.build, regexPattern, fmtArgs) or nil,
		launch = config.launch and string.gsub(config.launch, regexPattern, fmtArgs) or nil
	}
end

function RunBuildScript(buildCmd, launchCmd, buildScript)
	buildScript = buildScript or globalBuildScript

	local cmd = {pythonRuntime, buildScript}

	if buildCmd ~= nil then
		table.insert(cmd, '--build')
		table.insert(cmd, buildCmd)
	end

	if launchCmd ~= nil then
		table.insert(cmd, '--launch')
		table.insert(cmd, launchCmd)
	end

	vim.fn.jobstart(cmd)
end
