return
{
	{
		'neanias/everforest-nvim',
		priority = 1000,

		config = function()
			require('everforest').setup({
				background = 'hard',

				colours_override = function(palette)
					palette.bg0 = palette.bg_dim
					palette.bg_dim = '#101314'
					palette.statusline2 = palette.blue -- Make insert mode blue
				end,

				on_highlights = function(hl, palette)
					hl.LineNr = {fg=palette.fg}
					hl.Visual = {fg=palette.red, bg=palette.bg_visual}
					hl.CmpBorder = {bg=palette.bg0}
					hl.CmpNormal = {bg=palette.bg0}
				end
			})

			vim.cmd('colorscheme everforest')

			local hl = require('utils.hl')
			hl.set('ErrorMsg', {link='Red', underline=false}) -- This prevents underlines in the cmdline area
			hl.set('LspInlayHint', {link='Grey'})

			hl.set('NormalFloat', {link='Normal'})
			hl.set('FloatBorder', {link='Normal'})

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

			site.install({'cpp', 'glsl', 'python'})
		end
	}
}
