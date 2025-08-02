-- disable comment insertion
vim.api.nvim_create_autocmd('FileType', { pattern = '*', callback = function() vim.opt_local.formatoptions:remove({ 'c', 'r', 'o' }) end })

-- indent blank lines
vim.api.nvim_create_autocmd('BufEnter', {
	pattern = '*',
	callback = function()
		vim.schedule(function()
			if vim.bo.filetype == 'text' or vim.bo.buftype == 'terminal' then
				vim.keymap.set('n', 'a',      'a',      { silent = true })
				vim.keymap.set('i', '<Up>',   '<Up>',   { silent = true })
				vim.keymap.set('i', '<Down>', '<Down>', { silent = true })
			else
				vim.keymap.set('n', 'a',      'a<C-f>',      { silent = true })
				vim.keymap.set('i', '<Up>',   '<Up><C-f>',   { silent = true })
				vim.keymap.set('i', '<Down>', '<Down><C-f>', { silent = true })
			end
		end)
	end
})

-- remember cursor position
vim.api.nvim_create_autocmd('BufReadPost', { pattern = '*', callback = function() vim.cmd('normal! `"zz') end })
