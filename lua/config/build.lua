Args_list = nil
Args_list_tokenized = {}

vim.keymap.set("n", "<leader>ba", function()
	Args_list = vim.fn.input("Enter arguments: ")

	-- Remove elements from Lua table
	for key in pairs(Args_list_tokenized) do
		Args_list_tokenized[key] = nil
	end

	if Args_list == nil then
		return
	end

	-- Copy by value here
	local tokens = vim.split(Args_list, " +")

	for key, val in pairs(tokens) do
		Args_list_tokenized[key] = val
	end
end)

local python_runtime = Is_win32 and "python" or "python3"
local global_build_script = vim.fn.stdpath("config") .. "/scripts/build.py"

local current_dirname
local buffer_name
local binary_name

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

local function match_builder_pattern(pattern)
	if pattern.type == "file" then
		return vim.fn.filereadable(pattern.what) == 1

	elseif pattern.type == "extension" then
		local ext = vim.fn.fnamemodify(buffer_name, ":e")
		return ext == pattern.what
	end
end

local function get_builder_commands(config)
	local format_args = {
		["{binary_name}"] = binary_name,
		["{ArgsList}"] = Args_list or "",
		["{python_runtime}"] = python_runtime,
		["{buffer_name}"] = buffer_name,
	}

	local regex_pattern = "{[a-zA-Z_][0-9a-zA-Z_]*}"

	return {
		build = config.build and string.gsub(config.build, regex_pattern, format_args) or nil,
		launch = config.launch and string.gsub(config.launch, regex_pattern, format_args) or nil
	}
end

local function resolve_builder()
	local ordered_keys = {}

	for key in pairs(builders) do
		table.insert(ordered_keys, key)
	end

	table.sort(ordered_keys)

	local chosen_key = nil

	for key = 1, #ordered_keys do
		if match_builder_pattern(builder_config[key].pattern) then
			chosen_key = key
			break
		end
	end

	if chosen_key == nil then
		return nil
	end

	return get_builder_commands(builder_config[chosen_key])
end

local function run_build_script(build_cmd, launch_cmd, opt)
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

local function build(opt)
	local launch_disabled = (opt.launch == false)

	vim.cmd("wa")

	if vim.fn.filereadable("build.py") == 1 then
		run_build_script(nil, nil, {
			build_script = "build.py",
			launch_disabled = launch_disabled
		})
		return
	end

	current_dirname = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
	buffer_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
	binary_name = current_dirname .. (Is_win32 and ".exe" or "")

	local config = resolve_builder()
	if config == nil then
		vim.notify(string.format("Failed to launch `%s`. No configuration found.", buffer_name))
		return
	end

	if config.build == nil and (config.launch == nil or launch_disabled) then
		vim.notify("No commands were given. There is nothing to do.")
		return
	end

	run_build_script(config.build, config.launch, {
		launch_disabled = launch_disabled
	})
end

-- Quick build (and run) shortcuts for a wide variety of languages (4)
vim.keymap.set("n", "<leader>r", function()
	build({launch=true})
end)

vim.keymap.set("n", "<leader>bb", function()
	build({launch=false})
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
