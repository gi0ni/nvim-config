-- FIX:
-- 1. Fix debugger disconnecting when an exception happens. That's the entire point of the debugger!!
-- * Windows/lldb: Prints harmless warning about 'feature ignored'. Prob because of exceptions
-- * Linux/cppdbg: gdb prints harmless(?) warnings too. 'gdb failed to set controlling terminal'

return
{
	{
		'mfussenegger/nvim-dap',
		lazy = true,

		keys = {
			{ '<leader>d', ":DapNew<CR>", silent=true },

			{ '<leader>db', ':lua require("dap").toggle_breakpoint()<CR>', silent=true },
			{ '<leader>dB', ':DapClearBreakpoints<CR>', silent=true },
			{ '<leader>dw', ':DapViewWatch<CR>', silent=true },

			{ '<leader>d1', ':DapStepOver<CR>', silent=true },
			{ '<leader>d2', ':DapStepInto<CR>', silent=true },
			{ '<leader>d3', ':DapStepOut<CR>', silent=true },
			{ '<leader>d4', ':DapContinue<CR>', silent=true },
			{ '<leader>d`', ':DapTerminate<CR>', silent=true },

			{ '<leader>dW', ':DapViewJump watches<CR>', silent=true },
			{ '<leader>dS', ':DapViewJump scopes<CR>', silent=true },
			{ '<leader>dE', ':DapViewJump exceptions<CR>', silent=true },
			{ '<leader>dB', ':DapViewJump breakpoints<CR>', silent=true },
			{ '<leader>dT', ':DapViewJump threads<CR>', silent=true },
			{ '<leader>dR', ':DapViewJump repl<CR>', silent=true },
		},

		config = function()
			local dap = require('dap')
			dap.set_log_level('error')

			if IsWin32 == false then
				dap.defaults.fallback.external_terminal = {
					command = 'tmux',
					args = { 'new-window', '-n', 'debug' }
				}

				dap.defaults.fallback.force_external_terminal = true
			end

			-- ##### C/C++ #####
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
					program = function()
						local binaryPath = vim.fn.input("Binary Path: ./")
						return '${workspaceFolder}/' .. binaryPath
					end,
					args = ArgsListTokenized,

					externalConsole = true
				}
			}

			dap.configurations.c = dap.configurations.cpp


			-- ##### Rust #####
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
					program = function()
						local binaryPath = vim.fn.input("Binary Path: ./")
						return '${workspaceFolder}/' .. binaryPath
					end,

					stopOnEntry = false,
					terminal = (IsWin32 and 'console' or 'external'),
					console = 'externalTerminal'
				}
			}


			-- Open and close dap-view automatically
			dap.listeners.before.launch['dap_view_open'] = function()
				require('dap-view').setup()
				vim.cmd('DapViewOpen')

				-- Start with the locals tab open by default
				vim.cmd('wincmd j')
				if vim.bo.filetype == 'dap-view-term' then
					vim.cmd('bd')
				end
				vim.cmd('wincmd L')

				vim.api.nvim_feedkeys('S', 'c', false)

				-- Hide adapter disconnect notification
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


			-- Custom highlight for lines that have breakpoints placed on them
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
