return
{
	{
		"ellisonleao/gruvbox.nvim",

		config = function()
			require("gruvbox").setup({
				vim.cmd("colorscheme gruvbox")
			})
		end
	},

--	{
--		"folke/tokyonight.nvim",
--		opts = {},
--
--		config = function()
--			require("tokyonight").setup({
--				vim.cmd("colorscheme tokyonight-moon")
--			})
--		end
--	}
}
