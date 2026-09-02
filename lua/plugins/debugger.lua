local sopt = {silent=true}
local lldb_path = vim.fn.exepath("lldb-dap")

return
{
	{
		"mfussenegger/nvim-dap",
		lazy = true,
		keys = {
			{"<leader>dr", ":DapNew<CR>", sopt},
			{"<leader>db", ":lua require('dap').toggle_breakpoint()<CR>", sopt},
			{"<leader>dc", ":DapClearBreakpoints<CR>", sopt},
			{"<leader>dw", ":DapViewWatch<CR>", sopt},

			{"<M-1>", ":DapStepOver<CR>", sopt},
			{"<M-2>", ":DapStepInto<CR>", sopt},
			{"<M-3>", ":DapStepOut<CR>", sopt},
			{"<M-4>", ":DapContinue<CR>", sopt},
			{"<M-5>", ":DapTerminate<CR>", sopt},
			{"<M-6>", ":lua require('dap').down()<CR>", sopt},
			{"<M-7>", ":lua require('dap').up()<CR>", sopt}
		},
		config = function()
			local dap = require("dap")
			dap.defaults.cpp.exception_breakpoints = {"cpp_throw", "cpp_catch"}
			dap.set_log_level("error")

			if IsWin32 == false then
				dap.defaults.fallback.external_terminal = {
					command = "tmux",
					args = {"new-window", "-dn", "debug"}
				}
			end

			dap.adapters.lldb = {
				type = "executable",
				command = lldb_path,
				options = {
					detached = false
				}
			}
			dap.configurations.c = {
				{
					name = "debug",
					type = "lldb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					args = ArgsListTokenized,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					runInTerminal = true,
					console = "externalTerminal"
				}
			}
			dap.configurations.cpp = dap.configurations.c
			dap.configurations.rust = dap.configurations.c

			-- Open and close dap-view automatically
			dap.listeners.before.launch["dap_view_open"] = function()
				require("dap-view").setup({
					windows = {
						position = "right",
						size = 0.5,
						terminal = {
							hide = true
						}
					}
				})
				vim.cmd("DapViewOpen")
			end

			dap.listeners.after.disconnect["dap_view_close"] = function()
				vim.cmd("DapViewClose")
			end

			-- Custom style for lines with breakpoints
			vim.api.nvim_set_hl(0, "DapBreakpointLine", {bg="#fb4934", fg="#ebdbb2"})
			vim.fn.sign_define("DapBreakpoint", {
				linehl = "DapBreakpointLine",
				numhl = "DapBreakpointLine"
			})

			local function place_custom_breakpoints()
				local breakpoints = require("dap.breakpoints").get()
				for bufnr, bps in pairs(breakpoints) do
					for _, bp in ipairs(bps) do
						vim.fn.sign_place(0, "dap_breakpoints", "DapBreakpoint", bufnr, {lnum=bp.line, priority=10})
					end
				end
			end

			dap.listeners.after.launch["place_custom_breakpoints"] = place_custom_breakpoints
			dap.listeners.after.event_terminated["place_custom_breakpoints"] = place_custom_breakpoints
		end
	},
	{
		"igorlfs/nvim-dap-view",
		lazy = true,
		opts = {}
	}
}
