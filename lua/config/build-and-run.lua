--========== Build on Windows ==========--
if vim.loop.os_uname().sysname == 'Windows_NT' then
		vim.keymap.set('n', '<leader>r', function()
			vim.cmd('wa')

			--========== cmake ==========--
			if vim.api.nvim_buf_get_name(0):match('%.py$') then
				vim.fn.jobstart([[ start cmd.exe /c "python ]]..vim.fn.expand('%')..[[ & (echo. & echo. & pause)" ]])
			elseif vim.fn.isdirectory('build') ~= 0 then
				vim.fn.jobstart([[ start cmd.exe /c "ninja -C build && (echo. & for %a in (bin\*.exe) do @call %a) || (echo. & echo. & pause)" ]])
			else
				vim.notify("failed to run '"..vim.fn.expand('%').."'. unknown file type")
			end
	end, { silent = true })

--========== Build on Linux ==========--
else
	vim.keymap.set('n', '<leader>r', function()
		vim.cmd('wa')

		local pause_a = [[
			start=$(date +%s%3N);
		]]
		local pause_b = [[
			;ret=$?
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

		local term_arg_a = 'konsole'
		local term_arg_b = '-e'
		if vim.fn.executable('konsole') == 0 then
			term_arg_a = "gnome-terminal"
			term_arg_b = '--'
		end

		--========== cmake ==========--
		if vim.fn.isdirectory('build') ~= 0 then
			vim.fn.jobstart({ term_arg_a, term_arg_b, 'bash', '-ic', pause_a .. [[ ninja -C build && (echo; ./bin/*) ]] .. pause_b },
			                { detach = true })

		--========== script ==========--
		elseif vim.api.nvim_buf_get_name(0):match('%.sh$') then
			local args = ''
			local buff = vim.fn.expand('%')
			vim.ui.input({ prompt = 'Enter Args: ' }, function(input) if input then args = input end end)
			vim.fn.jobstart({ term_arg_a, term_arg_b, 'bash', '-ic', pause_a..'chmod u+x '..buff..'; sh '..buff..args..pause_b },
			                { detach = true })

		--========== single file c/c++ ==========--
		elseif vim.api.nvim_buf_get_name(0):match('%.c$') or vim.api.nvim_buf_get_name(0):match('%.cpp$') then
			local compiler = 'gcc'
			if vim.api.nvim_buf_get_name(0):match('%.cpp$') then
				compiler = 'g++'
			end

			local src = vim.fn.expand('%')
			local bin = vim.fn.expand('%:t:r')

			vim.fn.system([[ grep -rF 'int main(int argc, char** argv' ]])
			local flag = vim.v.shell_error
			local args = ''

			if flag == 0 then
				vim.ui.input({ prompt = 'Enter Args: ' }, function(input) if input then args = input end end)
			end

			vim.fn.jobstart({ term_arg_a, term_arg_b, 'bash', '-ic', compiler..' '..src..' -o '..bin..';'..pause_a..'./'..bin..' '..args..pause_b },
			                { detach = true })

		--========== unknown ==========--
		else
			vim.notify("failed to run '"..vim.fn.expand('%').."'. unknown file type")
		end
	end, { silent = true })
end
