return
{
	{
		"ellisonleao/gruvbox.nvim",

		config = function()
			require("gruvbox").setup({
				vim.cmd("colorscheme gruvbox"),

				vim.api.nvim_set_hl(0, "@function", { fg = "#fe8019", bold = true }),
				vim.api.nvim_set_hl(0, "@method", { fg = "#fe8019", bold = true })
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

			vim.api.nvim_set_hl(0, "@core_token", { fg = "#8ec07c" })
		end
	}
}
