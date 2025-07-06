require('config.build-and-run')

-- toggle the file explorer --
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { silent = true })

-- hide search results --
vim.keymap.set('n', '<Esc>', ':noh<CR>', { silent = true })

-- autoindent blank lines --
vim.keymap.set('n', 'a', function()
	return vim.api.nvim_get_current_line() == '' and '"_cc' or 'a'
end, { expr = true, silent = true })

vim.keymap.set('i', '<Up>', function()
	local curr = vim.api.nvim_win_get_cursor(0)[1]
	local prev = vim.api.nvim_buf_get_lines(0, curr - 2, curr - 1, false)[1]
	return prev ~= nil and prev == '' and '<Up><Esc>"_cc' or '<Up>'
end, { expr = true, silent = true })

vim.keymap.set('i', '<Down>', function()
	local curr = vim.api.nvim_win_get_cursor(0)[1]
	local next = vim.api.nvim_buf_get_lines(0, curr, curr + 1, false)[1]
	return next ~= nil and next == '' and '<Down><Esc>"_cc' or '<Down>'
end, { expr = true, silent = true })

-- don't overwrite yank when deleting --
vim.keymap.set('n', 'x', '"_x')
vim.keymap.set({'n', 'v'}, 'd', '"_d')
vim.keymap.set({'n', 'v'}, 'c', '"_c')

-- select all text in buffer --
vim.keymap.set('n', '<space>a', 'ggVG')

-- stop clearing selection when indenting --
vim.keymap.set('v', '>', function() vim.cmd('normal! >') vim.cmd('normal! gv') end)
vim.keymap.set('v', '<', function() vim.cmd('normal! <') vim.cmd('normal! gv') end)

-- yank to system clipboard --
vim.keymap.set('v', '<space>y', '"+y')

-- autoindent pasted region --
vim.keymap.set({'n', 'v'}, 'p', function() vim.cmd('normal! p') vim.cmd('normal! `[=`]') end)
vim.keymap.set({'n', 'v'}, 'P', function() vim.cmd('normal! P') vim.cmd('normal! `[=`]') end)
vim.keymap.set({'n', 'v'}, '<leader>p', function() vim.cmd('normal! "+p') vim.cmd('normal! `[=`]') end)

-- scoped token rename --
vim.keymap.set('n', '<leader>gr', ':lua vim.lsp.buf.rename()<CR>', { silent = true })

-- split shortcuts --
vim.keymap.set('n', '<leader>s', ':split<CR><C-w>j', { silent = true })
vim.keymap.set('n', '<leader>v', ':vsplit<CR><C-w>l', { silent = true })
vim.keymap.set('n', '<leader>c', ':close<CR>', { silent = true })

-- close terminal --
vim.keymap.set('t', '<esc>', '<C-\\><C-n>', { silent = true })

-- navigate splits --
vim.keymap.set('n', '<leader>h', '<C-w>h', { silent = true })
vim.keymap.set('n', '<leader>j', '<C-w>j', { silent = true })
vim.keymap.set('n', '<leader>k', '<C-w>k', { silent = true })
vim.keymap.set('n', '<leader>l', '<C-w>l', { silent = true })
vim.keymap.set('n', '<leader>w', '<C-w>r', { silent = true })

-- arrange splits --
vim.keymap.set('n', '<leader>H', ':wincmd H<CR>', { silent = true })
vim.keymap.set('n', '<leader>J', ':wincmd J<CR>', { silent = true })
vim.keymap.set('n', '<leader>K', ':wincmd K<CR>', { silent = true })
vim.keymap.set('n', '<leader>L', ':wincmd L<CR>', { silent = true })

-- resize splits --
vim.keymap.set('n', '<C-Left>',  ':vertical resize +2<CR>', { silent = true })
vim.keymap.set('n', '<C-Right>', ':vertical resize -2<CR>', { silent = true })
vim.keymap.set('n', '<C-Up>',    ':resize +2<CR>', { silent = true })
vim.keymap.set('n', '<C-Down>',  ':resize -2<CR>', { silent = true })
