-- disable comment insertion
vim.api.nvim_create_autocmd('FileType', { pattern = '*', callback = function() vim.opt_local.formatoptions:remove({ 'c', 'r', 'o' }) end })

-- indent blank lines
vim.api.nvim_create_autocmd('BufEnter', {
	pattern = '*',
	callback = function()
		vim.schedule(function()
			if not vim.bo.indentkeys:find('%^F') or vim.bo.indentexpr == '' then
				vim.keymap.set('n', 'a',      'a',      { silent = true })
				vim.keymap.set('i', '<Up>',   '<Up>',   { silent = true })
				vim.keymap.set('i', '<Down>', '<Down>', { silent = true })
			else
				vim.keymap.set('n', 'a', function()
					return vim.fn.getline('.'):match('^%s*$') and 'a<C-f>' or 'a'
				end, { expr = true, silent = true })

				vim.keymap.set('i', '<Up>', function()
					return vim.fn.getline(vim.fn.line('.') - 1):match('^%s*$') and '<Up><C-f>' or '<Up>'
				end, { expr = true, silent = true })

				vim.keymap.set('i', '<Down>', function()
					return vim.fn.getline(vim.fn.line('.') + 1):match('^%s*$') and '<Down><C-f>' or '<Down>'
				end, { expr = true, silent = true })
			end
		end)
	end
})

-- remember cursor position
vim.api.nvim_create_autocmd('BufReadPost', { pattern = '*', callback = function() vim.cmd('normal! `"zz') end })
