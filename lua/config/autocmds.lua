-- disable comment insertion
vim.api.nvim_create_autocmd('FileType', { pattern = '*', callback = function() vim.opt_local.formatoptions:remove({ 'c', 'r', 'o' }) end })

-- remember cursor position
vim.api.nvim_create_autocmd('BufReadPost', { pattern = '*', callback = function() vim.cmd('normal! `"zz') end })

-- indent blank lines
vim.api.nvim_create_autocmd('BufEnter', {
	pattern = '*',
	callback = function(args)
		if vim.bo.indentexpr == '' and vim.bo.cindent == false then
			return
		end

		vim.keymap.set('n', 'a', function()
			return vim.fn.getline('.'):match('^%s*$') and 'a<C-f>' or 'a'
		end, { expr = true, buffer = args.buf })

		vim.keymap.set('i', '<Up>', function()
			return vim.fn.getline(vim.fn.line('.') - 1):match('^%s*$') and '<Up><C-f>' or '<Up>'
		end, { expr = true, buffer = args.buf })

		vim.keymap.set('i', '<Down>', function()
			return vim.fn.getline(vim.fn.line('.') + 1):match('^%s*$') and '<Down><C-f>' or '<Down>'
		end, { expr = true, buffer = args.buf })
	end
})

-- terminal
vim.api.nvim_create_autocmd('BufEnter', {
	pattern = 'term://*',
	callback = function()
		vim.cmd('normal! a')
	end
})

vim.api.nvim_create_autocmd('TermLeave', {
	pattern = 'term://*',
	callback = function()
		local keys = vim.api.nvim_replace_termcodes('<C-w><C-w>', true, false, true)
		vim.api.nvim_feedkeys(keys, 'n', true)
	end
})
