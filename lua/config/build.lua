ArgsList = nil
ArgsListTokenized = {}

vim.keymap.set("n", "<leader>ba", function()
	ArgsList = vim.fn.input("Enter arguments: ")

	-- This is how you remove elements from a table in Lua...
	for key in pairs(ArgsListTokenized) do
		ArgsListTokenized[key] = nil
	end

	if ArgsList == nil then
		return
	end

	-- Important! Copy temporary table by value
	local tokens = vim.split(ArgsList, " +")

	for key, val in pairs(tokens) do
		ArgsListTokenized[key] = val
	end
end)

-- Quick build (and run) shortcuts for a wide variety of languages (4)
local python_runtime = IsWin32 and "python" or "python3"
local global_build_script = vim.fn.stdpath("config") .. "/scripts/build.py"

local current_dirname
local buffer_name
local binary_name

vim.keymap.set("n", "<leader>r", function()
	Build({launch=true})
end)

vim.keymap.set("n", "<leader>bb", function()
	Build({launch=false})
end)

vim.keymap.set("n", "<leader>bm", ":!cmake -B build -G Ninja -D CMAKE_BUILD_TYPE=Debug")

vim.keymap.set("n", "<leader>bpy", function()
	if vim.fn.filereadable("build.py") == 1 then
		vim.notify("There already is a local `build.py`. Will not overwrite.")
		return
	end

	local input_file = io.open(global_build_script, "r")
	local output_file = io.open("build.py", "w")

	if input_file == nil or output_file == nil then
		vim.notify("Error. Failed to copy file!")
		return
	end

	local contents = input_file:read("*a")
	input_file:close()

	output_file:write(contents)
	output_file:close()
	vim.notify(string.format("Copied `%s` to local directory.", vim.fn.stdpath("config") .. "/scripts/build.py"))
end)

function Build(opt)
	local launch_disabled = (opt.launch == false)

	vim.cmd("wa")

	if vim.fn.filereadable("build.py") == 1 then
		Run_Build_Script(nil, nil, {
			build_script = "build.py",
			launch_disabled = launch_disabled
		})
		return
	end

	current_dirname = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
	buffer_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
	binary_name = current_dirname .. (IsWin32 and ".exe" or "")

	local config = Resolve_Builder()
	if config == nil then
		vim.notify(string.format("Failed to launch `%s`. No configuration found.", buffer_name))
		return
	end

	if config.build == nil and (config.launch == nil or launch_disabled) then
		vim.notify("No commands were given. There is nothing to do.")
		return
	end

	Run_Build_Script(config.build, config.launch, {
		launch_disabled = launch_disabled
	})
end

local builders = {
	CMAKE  = 1,
	CARGO  = 2,
	PYTHON = 3,
	BASH   = 4
}

local builder_config = {
	[builders.CMAKE] = {
		build = "ninja -C build",
		launch = "bin/{binary_name} {ArgsList}",
		pattern = {
			type = "file",
			what = "CMakeLists.txt"
		}
	},
	[builders.CARGO] = {
		build = "cargo build",
		launch = "target/debug/{binary_name} {ArgsList}",
		pattern = {
			type = "file",
			what = "Cargo.toml"
		}
	},
	[builders.PYTHON] = {
		build = nil,
		launch = "{python_runtime} {buffer_name} {ArgsList}",
		pattern = {
			type = "extension",
			what = "py"
		}
	},
	[builders.BASH] = {
		build = nil,
		launch = "bash {buffer_name} {ArgsList}",
		pattern = {
			type = "extension",
			what = "sh"
		}
	}
}

function Resolve_Builder()
	local ordered_keys = {}

	for key in pairs(builders) do
		table.insert(ordered_keys, key)
	end

	table.sort(ordered_keys)

	local chosen_key = nil

	for key = 1, #ordered_keys do
		if Match_Builder_Pattern(builder_config[key].pattern) then
			chosen_key = key
			break
		end
	end

	if chosen_key == nil then
		return nil
	end

	return Get_Builder_Commands(builder_config[chosen_key])
end

function Match_Builder_Pattern(pattern)
	if pattern.type == "file" then
		return vim.fn.filereadable(pattern.what) == 1

	elseif pattern.type == "extension" then
		local ext = vim.fn.fnamemodify(buffer_name, ":e")
		return ext == pattern.what
	end
end

function Get_Builder_Commands(config)
	local format_args = {
		["{binary_name}"] = binary_name,
		["{ArgsList}"] = ArgsList or "",
		["{python_runtime}"] = python_runtime,
		["{buffer_name}"] = buffer_name,
	}

	local regex_pattern = "{[a-zA-Z_][0-9a-zA-Z_]*}"

	return {
		build = config.build and string.gsub(config.build, regex_pattern, format_args) or nil,
		launch = config.launch and string.gsub(config.launch, regex_pattern, format_args) or nil
	}
end

function Run_Build_Script(build_cmd, launch_cmd, opt)
	local build_script = opt.build_script or global_build_script
	local launch_disabled = opt.launch_disabled or false

	local cmd = {python_runtime, build_script}

	if build_cmd ~= nil then
		table.insert(cmd, "--build")
		table.insert(cmd, build_cmd)
	end

	if launch_cmd ~= nil then
		table.insert(cmd, "--launch")
		table.insert(cmd, launch_cmd)
	end

	if launch_disabled then
		table.insert(cmd, "--disable-launch")
	end

	vim.fn.jobstart(cmd)
end
