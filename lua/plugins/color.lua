return
{
	{
		"neanias/everforest-nvim",
		priority = 1000,

		config = function()
			require("everforest").setup({
				background = 'hard',
			})

			vim.cmd('colorscheme everforest')

			local hl = require('utils.hl')
			hl.set('ErrorMsg', {link='Red', underline=false})
			hl.set('LspInlayHint', {link='Grey'})
			hl.set('String', {link='Aqua'})
			hl.set('cDefine', {link='Purple'})
		end
	},

	{
		'nvim-treesitter/nvim-treesitter',
		branch = 'main',
		lazy = false,
		build = ':TSUpdate',

		config = function()
			local site = require('nvim-treesitter')

			site.setup({
				install_dir = vim.fn.stdpath('data') .. '/site'
			})

			site.install({'glsl', 'python'})
		end
	}
}
