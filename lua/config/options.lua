vim.opt.nu = true
vim.diagnostic.config({ virtual_text = true })

vim.opt.tabstop    = 4
vim.opt.shiftwidth = 4
vim.opt.cinscopedecls = ''
vim.opt.cinkeys:remove(':')

vim.opt.fillchars:append({ eob = ' ' })
vim.opt.guicursor = 'i-ci:ver25-Cursor/lCursor-blinkwait1000-blinkon100-blinkoff100'
