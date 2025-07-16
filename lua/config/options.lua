vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.nu = true
vim.opt.lazyredraw = true

-- show lsp diagnostics in bufer --
vim.diagnostic.config({
	virtual_text = true
})

-- cursor blink in insert mode --
vim.opt.guicursor = 'i-ci:ver25-Cursor/lCursor-blinkwait1000-blinkon100-blinkoff100'
