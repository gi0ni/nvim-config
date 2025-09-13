-- disable comment insertion
vim.api.nvim_create_autocmd('FileType', { pattern = '*', callback = function() vim.opt_local.formatoptions:remove({ 'c', 'r', 'o' }) end })

-- remember cursor position
vim.api.nvim_create_autocmd('BufReadPost', { pattern = '*', callback = function() vim.cmd('normal! `"zz') end })

-- indent blank lines
vim.api.nvim_create_autocmd('BufEnter', {
	pattern = '*',
	callback = function(args)
		local blacklist = { '', 'text', 'NvimTree', 'asm', 's', 'ps1' }

		for _, item in pairs(blacklist) do
			if vim.bo.filetype == item then
				return
			end
		end

		vim.keymap.set('n', 'a', function()
			return vim.fn.getline('.'):match('^%s*$') and 'a<C-f>' or 'a'
		end, { expr = true, silent = true, buffer = args.buf })

		vim.keymap.set('i', '<Up>', function()
			return vim.fn.getline(vim.fn.line('.') - 1):match('^%s*$') and '<Up><C-f>' or '<Up>'
		end, { expr = true, silent = true, buffer = args.buf })

		vim.keymap.set('i', '<Down>', function()
			return vim.fn.getline(vim.fn.line('.') + 1):match('^%s*$') and '<Down><C-f>' or '<Down>'
		end, { expr = true, silent = true, buffer = args.buf })
	end
})
