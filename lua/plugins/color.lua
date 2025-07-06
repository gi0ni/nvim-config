return
{
	'ellisonleao/gruvbox.nvim',
	priority = 1000,

	config = function()
		require('gruvbox').setup({
			vim.cmd('colorscheme gruvbox'),

			vim.api.nvim_set_hl(0, '@function', { fg = '#fe8019', bold = true }),
			vim.api.nvim_set_hl(0, '@method', { fg = '#fe8019', bold = true })
		})
	end
}
