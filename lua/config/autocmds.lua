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
	end
})

-- Enable treesitter indentation only for python scripts
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})
