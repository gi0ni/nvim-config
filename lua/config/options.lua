vim.opt.relativenumber = true
vim.opt.nu = true
vim.opt.guicursor = 'n-v-c:block-Cursor'
-- vim.opt.winblend = 20

vim.diagnostic.config({virtual_text = true})
vim.opt.signcolumn = 'no'
vim.opt.foldenable = false

vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.cinkeys:remove('0#') -- Disable auto indent for 'public:', '#ifdef' and etc.
vim.opt.cinkeys:remove(':')
vim.opt.cinscopedecls = ''

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
