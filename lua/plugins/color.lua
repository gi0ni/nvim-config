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
		lazy = false,
		build = ':TSUpdate',

		opts = {},

		config = function()
			local site = require('nvim-treesitter')
			site.setup({
				install_dir = vim.fn.stdpath('data') .. '/site'
			})
			site.install({ 'html', 'glsl', 'python'})

			vim.filetype.add({
				extension = {
					vert = 'glsl',
					frag = 'glsl',
					geom = 'glsl',
					tesc = 'glsl',
					tese = 'glsl',
					comp = 'glsl'
				}
			})

			vim.api.nvim_set_hl(0, '@core_token',          { link = '@keyword.directive.glsl' })
			vim.api.nvim_set_hl(0, '@function.call.glsl',  { link = '@function.glsl' })
			vim.api.nvim_set_hl(0, '@keyword.import.glsl', { link = 'PreProc' })
		end
	}
}
