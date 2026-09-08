return
{
	{
		"oskarnurm/koda.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("koda").setup({
				colors = {
					moss = {
						const = "#cc8bc9"
					}
				},
				on_highlights = function(hl, c)
					hl.DiagnosticUnderlineHint = {undercurl=true, underline=false}
					hl.DiagnosticUnderlineWarn = {undercurl=true, underline=false}
					hl.DiagnosticUnderlineError = {undercurl=true, underline=false}

					hl.Comment = {fg=c.comment, italic=true}

					hl.TodoBgPERF = {bg=c.green, fg=c.bg, bold=true}
					hl.TodoFgPERF = {fg=c.green}

					hl.NvimTreeNormal = {bg="#070b0b"}
					hl.Title = {fg=c.cyan}
					hl.Directory = {fg=c.green}
					hl.NvimTreeFolderIcon = {fg=c.green}
				end
			})
			vim.cmd("colorscheme koda-moss")
		end
	},
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local site = require("nvim-treesitter")
			site.setup({
				install_dir = vim.fn.stdpath("data") .. "/site"
			})
			site.install({"cpp", "glsl", "python"})
		end
	}
}
