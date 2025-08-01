return
{
	{
		'ellisonleao/gruvbox.nvim',
		priority = 1000,

		config = function()
			require('gruvbox').setup({
				vim.cmd('colorscheme gruvbox'),

				vim.api.nvim_set_hl(0, '@function', { fg = '#fe8019' }),
				vim.api.nvim_set_hl(0, '@method',   { fg = '#fe8019' })
			})
		end
	},

	{
		'nvim-treesitter/nvim-treesitter',
		opts = {
			highlight = {
				enable = true,
				disable = 'lua', 'html'
			},

			ensure_installed = {
				'html', 'glsl'
			}
		},

		config = function(_, opts)
			require('nvim-treesitter.configs').setup(opts)

			vim.filetype.add({
				extension = {
					vert = 'glsl',
					frag = 'glsl'
				}
			})

			vim.api.nvim_set_hl(0, '@core_token',         { fg = '#8ec07c' })
			vim.api.nvim_set_hl(0, '@constant.glsl',      { fg = '#8ec07c' })
			vim.api.nvim_set_hl(0, '@function.call.glsl', { fg = '#fe8019' })
		end
	}
}
