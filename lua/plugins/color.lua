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

	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			highlight = {
				enable = true
			},

			ensure_installed = {
				"glsl"
			}
		},

		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)

			vim.filetype.add({
				extension = {
					vert = "glsl",
					frag = "glsl"
				}
			})
		end
	}
}
