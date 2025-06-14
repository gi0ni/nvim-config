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

-- stop clearing selections --
vim.keymap.set("v", "<space>y", '"+y')
vim.keymap.set("v", ">", function() vim.cmd("normal! >") vim.cmd("normal! gv") end)
vim.keymap.set("v", "<", function() vim.cmd("normal! <") vim.cmd("normal! gv") end)

-- autoindent on paste --
vim.keymap.set("n", "p", function() vim.cmd("normal! p") vim.cmd("normal! `[=`]") end)
vim.keymap.set("n", "P", function() vim.cmd("normal! P") vim.cmd("normal! `[=`]") end)
vim.keymap.set("n", "<leader>p", function() vim.cmd('normal! "+p') vim.cmd("normal! `[=`]") end)

-- scoped token rename --
vim.api.nvim_set_keymap('n', '<leader>gr', '<cmd>lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })
