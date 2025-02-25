return
{
	-- autopairs --
	{
		"windwp/nvim-autopairs",
		opts = {}
	},

	-- indent lines --
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = { indent = { char = '|' } }
	},

	-- smart semicolon --
	{
		"gi0ni/smart-semicolon.nvim",
		opts = {}
	},

	-- tabs --
	{
		"akinsho/bufferline.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons", "ellisonleao/gruvbox.nvim" },

		config = function()
			require("bufferline").setup({
				vim.api.nvim_set_keymap("n", "[b", ":BufferLineCyclePrev<cr>", { noremap = true, silent = true }),
				vim.api.nvim_set_keymap("n", "]b", ":BufferLineCycleNext<cr>", { noremap = true, silent = true })
			})
		end
	}
}
