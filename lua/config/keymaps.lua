require('config.build-and-run')

-- toggle file explorer
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { silent = true })

-- clear search results
vim.keymap.set('n', '<Esc>', ':noh<CR>', { silent = true })

-- shift selection up and down
vim.keymap.set('v', 'j', ":move '>+1<CR>gv=gv", { silent = true })
vim.keymap.set('v', 'k', ":move '<-2<CR>gv=gv", { silent = true })

-- show all diagnostics
vim.keymap.set('n', '<leader>fd', ':lua require("telescope.builtin").diagnostics()<CR>', { silent = true })

-- stop overwriting yank register
vim.keymap.set( 'n',       'x', '"_x')
vim.keymap.set({'n', 'v'}, 'd', '"_d')
vim.keymap.set({'n', 'v'}, 'c', '"_c')

-- select all
vim.keymap.set('n', '<space>a', 'ggVG')

-- do not clear selection when shifting
vim.keymap.set('v', '>', function() vim.cmd('normal! >') vim.cmd('normal! gv') end)
vim.keymap.set('v', '<', function() vim.cmd('normal! <') vim.cmd('normal! gv') end)

-- yank to system clipboard
vim.keymap.set('v', '<space>y', '"+y')

-- indent pasted region automatically
vim.keymap.set({'n', 'v'}, 'p', function() vim.cmd('normal! p') vim.cmd('normal! `[=`]') end)
vim.keymap.set({'n', 'v'}, 'P', function() vim.cmd('normal! P') vim.cmd('normal! `[=`]') end)
vim.keymap.set({'n', 'v'}, '<leader>p', function() vim.cmd('normal! "+p') vim.cmd('normal! `[=`]') end)

-- experimental
vim.keymap.set('n', '<C-f>', '<Up>zz');
vim.keymap.set('n', '<C-b>', '<Down>zz');

vim.keymap.set('n', ';', ':')
vim.keymap.set('c', ';', '<CR>')

-- lsp keymaps
vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition)
vim.keymap.set('n', '<leader>gD', vim.lsp.buf.declaration)
vim.keymap.set('n', '<leader>gi', vim.lsp.buf.implementation)
vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references)
vim.keymap.set('n', '<leader>gt', vim.lsp.buf.type_definition)
vim.keymap.set('n', '<leader>k',  vim.lsp.buf.hover)

-- scoped token rename
vim.keymap.set('n', '<leader>gr', function()
	local cmdId
	cmdId = vim.api.nvim_create_autocmd({ 'CmdlineEnter' }, {
		callback = function()
			local key = vim.api.nvim_replace_termcodes('<C-f>', true, false, true)
			vim.api.nvim_feedkeys(key, 'c', false)
			vim.api.nvim_feedkeys('0', 'n', false)
			cmdId = nil
			return true
		end
	})
	vim.lsp.buf.rename()
	vim.defer_fn(function()
		if cmdId then
			vim.api.nvim_del_autocmd(cmdId)
		end
	end, 500)
end)

-- lsp hover using cmp
vim.keymap.set('n', '<leader><leader>', function()
	local line = vim.fn.getline('.')
	local col = vim.fn.col('.')
	local chr = line:sub(col + 1, col + 1)

	if not string.find('(),', chr, 1, true) then
		vim.cmd('normal! e')
	end

	vim.cmd('startinsert')
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Right>', true, false, true), 'm', false)

	local cmp = require('cmp')
	vim.schedule(function()
		cmp.complete()
		vim.schedule(function()
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Down>', true, false, true), 'm', false)
		end)
	end)
end, { silent = true})

-- split actions
vim.keymap.set('n', '<leader>s', ':split<CR><C-w>j',  { silent = true })
vim.keymap.set('n', '<leader>v', ':vsplit<CR><C-w>l', { silent = true })
vim.keymap.set('n', '<leader>c', ':close<CR>',        { silent = true })

-- open terminal split
vim.keymap.set('n', '<leader>t', function()
	vim.cmd('split')
	vim.cmd('wincmd j')
	vim.cmd('term pwsh')
	vim.cmd('normal! a')
end, { silent = true })

-- exit terminal mode
vim.keymap.set('t', '<esc>', '<C-\\><C-n>')

-- split navigation
vim.keymap.set('n', '<leader>h', '<C-w>h')
vim.keymap.set('n', '<leader>j', '<C-w>j')
vim.keymap.set('n', '<leader>k', '<C-w>k')
vim.keymap.set('n', '<leader>l', '<C-w>l')
vim.keymap.set('n', '<leader>w', '<C-w>r')

-- split organization
vim.keymap.set('n', '<leader>H', ':wincmd H<CR>', { silent = true })
vim.keymap.set('n', '<leader>J', ':wincmd J<CR>', { silent = true })
vim.keymap.set('n', '<leader>K', ':wincmd K<CR>', { silent = true })
vim.keymap.set('n', '<leader>L', ':wincmd L<CR>', { silent = true })

-- split resize
vim.keymap.set('n', '<C-Left>',  ':vertical resize +2<CR>', { silent = true })
vim.keymap.set('n', '<C-Right>', ':vertical resize -2<CR>', { silent = true })
vim.keymap.set('n', '<C-Up>',    ':resize +2<CR>',          { silent = true })
vim.keymap.set('n', '<C-Down>',  ':resize -2<CR>',          { silent = true })
