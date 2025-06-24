-- cursor blink --
vim.opt.guicursor = { "i-ci:ver25-Cursor/lCursor-blinkwait1000-blinkon100-blinkoff100" }

-- netrw --
vim.api.nvim_set_keymap("n", "<leader>e", ":Explore<cr>", { noremap = true, silent = true })

-- comments --
vim.api.nvim_create_autocmd("FileType", { pattern = "*", callback = function() vim.opt_local.formatoptions:remove({ 'c', 'r', 'o' }) end })

-- search --
vim.api.nvim_set_keymap("n", "<esc>", ":noh<cr>", { noremap = true, silent = true })

-- generate a default cmakelist --

vim.api.nvim_create_user_command("CmakeList", function()
	local file = io.open("CMakeLists.txt", "w")
	if file == nil then return end
	file:write([[
cmake_minimum_required(VERSION 3.20)

project(program)

set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

file(GLOB SRCS "src/*.c" "src/*.cpp")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "../bin")
add_executable(${PROJECT_NAME} ${SRCS})
	]])
	file:close()
	print("Created default CMakeLists.txt.")
end, {})

-- build and run --
if vim.loop.os_uname().sysname == "Windows_NT" then
	vim.keymap.set("n", "<leader>r", function()
		vim.cmd("wa")

		local isdir = vim.fn.isdirectory("build")

		if isdir ~= 0 then
			vim.fn.jobstart([[ start "" /wait cmd /c "ninja -C build && (for %a in (bin\*.exe) do @call %a) || (echo. & echo. & pause)" ]])
		else
			local compiler = "g++"
			if vim.api.nvim_buf_get_name(0):match("%.c$") then
				compiler = "gcc"
			end

			local src = vim.fn.expand("%")
			local program = vim.fn.expand("%:t:r")

			vim.fn.system('rg -F "int main(int argc, char** argv" ' .. src)
			local flag = vim.v.shell_error
			local args = "none"

			if flag == 0 then
				vim.ui.input({prompt = "Enter Args: "}, function(input) if input then args = input end end)
			end

			vim.fn.jobstart([[ start "" /wait cmd /c "]] .. compiler .. [[ ]] .. src .. [[ -o ]] .. program .. [[ && @call ]] .. program .. [[ ]] .. args .. [[ & (echo. & echo. & pause)" ]])
		end
	end, { noremap = true, silent = true })
else
	vim.keymap.set("n", "<leader>r", function()
		vim.cmd("wa")

		local pause = [[
			;
			ret=$?
			end=$(date +%s%3N)

			duration_ms=$((end - start))
			minutes=$((duration_ms / 60000))
			seconds=$(( (duration_ms % 60000) / 1000 ))
			millis=$((duration_ms % 1000))
			formatted_time=$(printf "%02d:%02d.%03d" $minutes $seconds $millis)

			echo -e "\n\n=========================================="
			echo "Process returned code $ret (0x$(printf "%X" $ret))"
			echo "Execution time: $formatted_time"
			echo "=========================================="
			echo -ne "Press any key to continue..."
			read -n 1 
		]]

		local isdir = vim.fn.isdirectory("build")

		if vim.api.nvim_buf_get_name(0):match("%.sh$") then
			local args = ""
			vim.ui.input({prompt = "Enter Args: "}, function(input) if input then args = input end end)
			vim.cmd("!chmod u+x %")
			vim.fn.jobstart({ "gnome-terminal", "--", "bash", "-ic", [[ start=$(date +%s%3N); ./]] .. vim.fn.expand("%") .. " " .. args .. pause })
			vim.api.nvim_feedkeys("\r", "n", false)
		elseif isdir ~= 0 then
			vim.cmd("!ninja -C build")
			vim.fn.jobstart({ "gnome-terminal", "--", "bash", "-c", [[ ./bin/* ]] }, { detach = true })
			vim.api.nvim_feedkeys("\r", "n", false)
		else
			local compiler = "g++"
			if vim.api.nvim_buf_get_name(0):match("%.c$") then
				compiler = "gcc"
			end

			local src = vim.fn.expand("%")
			local program = vim.fn.expand("%:t:r")

			vim.fn.system([[ grep -F 'int main(int argc, char** argv' ]] .. src)
			local flag = vim.v.shell_error
			local args = ""

			if flag == 0 then
				vim.ui.input({prompt = "Enter Args: "}, function(input) if input then args = input end end)
			end

			vim.fn.jobstart({ "gnome-terminal", "--", "bash", "-ic", compiler .. [[ ]] .. src .. [[ -o ]] .. program .. [[; start=$(date +%s%3N); ./]] .. program .. [[ ]] .. args .. pause }, { detach = true })
		end
	end, { noremap = true, silent = true })
end

-- indent --
vim.keymap.set('n', 'a', function()
	return vim.api.nvim_get_current_line() == "" and '"_cc' or "a"
end, { expr = true, noremap = true, silent = true })

vim.keymap.set('i', '<up>', function()
	local curr = vim.api.nvim_win_get_cursor(0)[1]
	local prev = vim.api.nvim_buf_get_lines(0, curr - 2, curr - 1, false)[1]
	return prev ~= nil and prev == "" and '<up><esc>"_cc' or "<up>"
end, { expr = true, noremap = true, silent = true })

vim.keymap.set('i', '<down>', function()
	local curr = vim.api.nvim_win_get_cursor(0)[1]
	local next = vim.api.nvim_buf_get_lines(0, curr, curr + 1, false)[1]
	return next ~= nil and next == "" and '<down><esc>"_cc' or "<down>"
end, { expr = true, noremap = true, silent = true })

-- don't overwrite yank when deleting --
vim.keymap.set("n", "x", "\"_x")
vim.keymap.set("n", "d", "\"_d")
vim.keymap.set("n", "c", "\"_c")
vim.keymap.set("v", "d", "\"_d")
vim.keymap.set("v", "c", "\"_c")

-- select all --
vim.keymap.set('n', '<space>a', 'ggVG')

-- stop clearing selections --
vim.keymap.set("v", "<space>y", '"+y')
vim.keymap.set("v", ">", function() vim.cmd("normal! >") vim.cmd("normal! gv") end)
vim.keymap.set("v", "<", function() vim.cmd("normal! <") vim.cmd("normal! gv") end)

-- autoindent on paste --
vim.keymap.set({'n', 'v'}, "p", function() vim.cmd("normal! p") vim.cmd("normal! `[=`]") end)
vim.keymap.set({'n', 'v'}, "P", function() vim.cmd("normal! P") vim.cmd("normal! `[=`]") end)
vim.keymap.set({'n', 'v'}, "<leader>p", function() vim.cmd('normal! "+p') vim.cmd("normal! `[=`]") end)

-- scoped token rename --
vim.api.nvim_set_keymap('n', '<leader>gr', '<cmd>lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })

vim.api.nvim_create_user_command("Rename", function(opts)
	local old_name = vim.fn.expand('%')
	local new_name = vim.fn.fnamemodify(old_name, ":h") .. '/' .. opts.args

	if vim.fn.filereadable(new_name) == 1 then
		print('File ' .. new_name .. ' already exists')
		return
	end

	local ok, err = os.rename(old_name, new_name)
	if not ok then
		print('Rename failed: ' .. err)
		return
	end

	vim.api.nvim_buf_set_name(vim.api.nvim_get_current_buf(), new_name)
	vim.cmd('w!')
end, { nargs = 1, complete = 'file'})

-- better splits --
vim.keymap.set('n', '<leader>s', ':split<CR><C-w>j', { silent = true })
vim.keymap.set('n', '<leader>v', ':vsplit<CR><C-w>l', { silent = true })
vim.keymap.set('n', '<leader>c', ':close<CR>', { silent = true })
vim.keymap.set('t', '<esc>', '<C-\\><C-n>', { silent = true }) -- close terminal; vim.keymap.set defaults to noremap = true

-- navigate splits --
vim.keymap.set('n', '<leader>h', '<C-w>h', { silent = true })
vim.keymap.set('n', '<leader>j', '<C-w>j', { silent = true })
vim.keymap.set('n', '<leader>k', '<C-w>k', { silent = true })
vim.keymap.set('n', '<leader>l', '<C-w>l', { silent = true })
vim.keymap.set('n', '<leader>w', '<C-w>r', { silent = true })

-- move splits --
vim.keymap.set('n', '<leader>H', ':wincmd H<CR>', { silent = true })
vim.keymap.set('n', '<leader>J', ':wincmd J<CR>', { silent = true })
vim.keymap.set('n', '<leader>K', ':wincmd K<CR>', { silent = true })
vim.keymap.set('n', '<leader>L', ':wincmd L<CR>', { silent = true })

-- resize splits --
vim.keymap.set('n', '<C-Left>',  ':vertical resize +2<CR>', { silent = true })
vim.keymap.set('n', '<C-Right>', ':vertical resize -2<CR>', { silent = true })
vim.keymap.set('n', '<C-Up>', ':resize +2<CR>', { silent = true })
vim.keymap.set('n', '<C-Down>', ':resize -2<CR>', { silent = true })

-- toggle bufferline --
local bufferline_visible = true
vim.keymap.set('n', '<leader>bh', function()
	bufferline_visible = not bufferline_visible
	if bufferline_visible then
		vim.o.showtabline = 2
	else
		vim.o.showtabline = 0
	end
end, {})

-- reload config without restarting nvim --
vim.api.nvim_create_user_command('Reload', function()
	local function source_luafiles(path)
		local scan = vim.loop.fs_scandir(path)
		if not scan then return end

		while true do
			local name, t = vim.loop.fs_scandir_next(scan)
			if not name then break end

			local full_path = path .. '/' .. name
			if t == 'file' and name:match('%.lua$') and name ~= "lazy.lua" then -- ignore lazy.lua for that one you need to restart neovim
				vim.cmd('luafile ' .. full_path)
			elseif t == 'directory' then
				source_luafiles(full_path)
			end
		end
	end

	local config_path = vim.fn.stdpath('config')
	source_luafiles(config_path)
	vim.notify('succesfully sourced all ~/.config/nvim lua files')
end, {})
