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
					hl.TodoBgPERF = {bg=c.green, fg=c.bg, bold=true}
					hl.TodoFgPERF = {fg=c.green}
					hl.NvimTreeNormal = {bg="#070b0b"}
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
