return
{
	{
		'mfussenegger/nvim-dap',
		lazy = true,

		keys = {
			{
				'<leader>d', function()
					return require('dap').session() == nil and ':DapNew<CR>' or ':DapTerminate<CR>'
				end, expr = true, silent = true
			},

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

			dap.adapters.gdb = {
				id = 'gdb',
				type = 'executable',
				command = 'gdb',
				args = { '--quiet', '--interpreter=dap' }
			}

			dap.configurations.cpp = {
				{
					name = 'Run executable (GDB)',
					type = 'gdb',
					request = 'launch',
					program = function()
						local cwd = vim.fn.getcwd()
						return cwd .. '/bin/' .. vim.fn.fnamemodify(cwd, ':t') .. '.exe'
					end,
					args = { 'DEBUG' }
				}
			}

			dap.configurations.c = dap.configurations.cpp


			-- open and close ui automatically
			dap.listeners.before.launch.dapui_config = function()
				require('dap-view').setup()
				vim.cmd('normal! md')
				vim.cmd('DapViewOpen')

				-- get those local variables opened nicely on the right
				vim.cmd('wincmd j')
				if vim.bo.filetype == 'dap-view-term' then
					vim.cmd('bd')
				end
				vim.cmd('wincmd L')

				vim.api.nvim_feedkeys('S', 'c', false)
				vim.cmd([[ silent !pwsh -Command "& /scripts/minimize_window.ps1" ]])
			end

			dap.listeners.before.event_terminated.dapui_config = function()
				require('dap-view').setup()
				vim.cmd('DapViewClose')
				vim.cmd("normal! 'd")

				-- evil
				local func = vim.notify
				vim.notify = function(_) end
				vim.defer_fn(function()
					vim.notify = func
				end, 100)
			end


			-- highlight lines with breakpoints. no pesky signcolumn needed
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
