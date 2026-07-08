-- Disable auto comment insertion in insert mode. No, this will not work if set only once in `options.lua`
vim.api.nvim_create_autocmd('FileType', {
	pattern = '*',
	callback = function()
		vim.opt_local.formatoptions:remove({'c', 'r', 'o'})
	end
})

-- Remember the cursor position when opening a file
vim.api.nvim_create_autocmd('BufReadPost', {
	pattern = '*',
	callback = function()
		vim.cmd('normal! `"zz')
	end
})

-- Make append command go to the correct indentation level
vim.api.nvim_create_autocmd('BufEnter', {
	pattern = '*',
	callback = function(args)
		if vim.bo.indentexpr == '' and vim.bo.cindent == false then
			return
		end

		vim.keymap.set('n', 'a', function()
			return vim.fn.getline('.'):match('^%s*$') and 'a<C-f>' or 'a'
		end, {expr=true, buffer=args.buf})
	end
})
