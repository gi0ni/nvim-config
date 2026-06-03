vim.opt.shortmess:append('I') -- Disable start screen.
vim.opt.fillchars:append({ eob = ' ' }) -- Do not display ~ after end of buffers.
vim.opt.guicursor = "n-v-c:block-Cursor"

vim.opt.relativenumber = true
vim.opt.nu = true

vim.diagnostic.config({ virtual_text = true })
vim.opt.signcolumn = "no"

vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.cinkeys:remove('0#') -- Disable auto indent for keywords like 'public:' and # directives.
vim.opt.cinkeys:remove(':')
vim.opt.cinscopedecls = ''
