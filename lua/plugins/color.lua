return
{
	{
		"neanias/everforest-nvim",
		priority = 1000,

		config = function()
			require("everforest").setup({
				background = 'medium',
			})
			vim.cmd('colorscheme everforest')
			vim.api.nvim_set_hl(0, 'ErrorMsg', { bold = true, fg = '#e67e80' })
			vim.api.nvim_set_hl(0, 'cDefine',  { link = 'Include' })
			vim.api.nvim_set_hl(0, 'String',   { link = 'Aqua' })
			vim.api.nvim_set_hl(0, 'cSpecial', { link = 'Green' })
			vim.api.nvim_set_hl(0, 'LspInlayHint', { fg = '#618d88' })
		end,
	},

	{
		'nvim-treesitter/nvim-treesitter',
		opts = {
			highlight = {
				enable = true,
				disable = 'lua', 'html'
			},

			ensure_installed = {
				'html', 'glsl', 'python'
			}
		},

		config = function(_, opts)
			require('nvim-treesitter.config' .. (not (vim.loop.os_uname().sysname == 'Windows_NT') and 's' or '')).setup(opts)

			vim.filetype.add({
				extension = {
					vert = 'glsl',
					frag = 'glsl'
				}
			})

			vim.api.nvim_set_hl(0, '@core_token',          { link = '@keyword.directive.glsl' })
			vim.api.nvim_set_hl(0, '@function.call.glsl',  { link = '@function.glsl' })
			vim.api.nvim_set_hl(0, '@keyword.import.glsl', { link = 'PreProc' })
		end
	}
}
