-- FIX:
-- 1. windows/lldb: prints harmless warning about 'feature ignored'. prob because of exceptions

-- 3. linux/cppdbg: gdb prints harmless(?) warnings too. 'gdb failed to set controlling terminal'
-- 4. refocus neovim
-- 5. make WSEBTR take you to dap-view from any buffer

return
{
	{
		'mfussenegger/nvim-dap',
		lazy = true,

		keys = {
			{ '<leader>d', ':DapNew<CR>', silent = true },
			{ '<leader>b', ':lua require("dap").toggle_breakpoint()<CR>', silent = true },
			{ '<leader>q', ':DapClearBreakpoints<CR>', silent = true },

			{ '1', function() return require('dap').session() ~= nil and ':DapStepOver<CR>'  or '1' end, expr = true, silent = true },
			{ '2', function() return require('dap').session() ~= nil and ':DapStepInto<CR>'  or '2' end, expr = true, silent = true },
			{ '3', function() return require('dap').session() ~= nil and ':DapStepOut<CR>'   or '3' end, expr = true, silent = true },
			{ '4', function() return require('dap').session() ~= nil and ':DapContinue<CR>'  or '4' end, expr = true, silent = true },
			{ '`', function() return require('dap').session() ~= nil and ':DapTerminate<CR>' or '`' end, expr = true, silent = true },
		},

		config = function()
			local dap = require('dap')
			dap.set_log_level('error')

			if IsWin32 == false then
				dap.defaults.fallback.external_terminal = {
					command = '/usr/bin/gnome-terminal',
					args = { '--' }
				}

				dap.defaults.fallback.force_external_terminal = true
			end

			-- ========== c/cpp ========== --
			dap.adapters.cppdbg = {
				id = 'cppdbg',
				type = 'executable',
				command = vim.fn.stdpath('data') .. '/mason/bin/OpenDebugAD7' .. (IsWin32 and '.cmd' or ''),
				options = {
					detached = false
				}
			}

			dap.configurations.cpp = {
				{
					name = 'debug',
					type = 'cppdbg',
					request = 'launch',

					cwd = '${workspaceFolder}',
					program = '${workspaceFolder}/bin/${workspaceFolderBasename}' .. (IsWin32 and '.exe' or ''),

					externalConsole = true
				}
			}

			dap.configurations.c = dap.configurations.cpp
			-- =========================== --

			-- ========== rust =========== --
			dap.adapters.lldb = {
				type = 'server',
				port = '${port}',
				executable = {
					command = vim.fn.stdpath('data') .. '/mason/bin/codelldb' .. (IsWin32 and '.cmd' or ''),
					args = { '--port', '${port}' }
				},
				detached = false
			}

			dap.configurations.rust = {
				{
					name = 'debug',
					type = 'lldb',
					request = 'launch',

					cwd = '${workspaceFolder}',
					program = '${workspaceFolder}/target/debug/${workspaceFolderBasename}' .. (IsWin32 and '.exe' or ''),

					stopOnEntry = false,
					terminal = 'console', -- works on windows
					console = 'externalTerminal' -- works on linux
				}
			}
			-- =========================== --


			-- open and close dap-view automatically
			dap.listeners.before.launch['dap_view_open'] = function()
				require('dap-view').setup()
				vim.cmd('DapViewOpen')

				-- start with locals tab open by default
				vim.cmd('wincmd j')
				if vim.bo.filetype == 'dap-view-term' then
					vim.cmd('bd')
				end
				vim.cmd('wincmd L')

				vim.api.nvim_feedkeys('S', 'c', false)

				-- refocus neovim
				-- if IsWin32 then
				-- 	vim.cmd([[ silent !pwsh -Command "& /scripts/minimize_window.ps1" ]])
				-- end

				-- close adapter disconnect notification
				local original_notify = vim.notify
				vim.notify = function(msg, level, opts)
					if msg:match('cppdbg') then
						return
					end
					original_notify(msg, level, opts)
				end
			end

			dap.listeners.after.disconnect['dap_view_close'] = function()
				vim.cmd('DapViewClose')
			end


			-- highlight lines that have breakpoints
			vim.api.nvim_set_hl(0, 'DapBreakpointLine', { bg = '#fb4934', fg = '#ebdbb2' })
			vim.fn.sign_define('DapBreakpoint', {
				linehl = 'DapBreakpointLine',
				numhl  = 'DapBreakpointLine'
			})

			local function place_custom_breakpoints()
				local breakpoints = require('dap.breakpoints').get()
				for bufnr, bps in pairs(breakpoints) do
					for _, bp in ipairs(bps) do
						vim.fn.sign_place(0, 'dap_breakpoints', 'DapBreakpoint', bufnr, { lnum = bp.line, priority = 10 })
					end
				end
			end

			dap.listeners.after.launch['place_custom_breakpoints'] = place_custom_breakpoints
			dap.listeners.after.event_terminated['place_custom_breakpoints'] = place_custom_breakpoints
		end
	},

	{
		'igorlfs/nvim-dap-view',
		lazy = true,
		opts = {}
	}
}
