require('config.build-and-run')
local opt = { silent = true }

-- toggle file explorer
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', opt)

-- clear search results
vim.keymap.set('n', '<Esc>', ':noh<CR>', opt)

-- exit terminal mode
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')

-- scroll
vim.keymap.set({ 'n', 'v' }, '<C-f>', '<Up>zz');
vim.keymap.set({ 'n', 'v' }, '<C-b>', '<Down>zz');

-- shift in any direction
vim.keymap.set('v', '>', '>gv')
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', 'J', ":move '>+1<CR>gv=gv", opt)
vim.keymap.set('v', 'K', ":move '<-2<CR>gv=gv", opt)

-- yank and put
vim.keymap.set({'n', 'v'}, 'd', '"_d')
vim.keymap.set({'n', 'v'}, 'c', '"_c')
vim.keymap.set('n', 'x', '"_x')
vim.keymap.set('v', 'x', '"0x')

vim.keymap.set('n', '<space>y', '"+yy')
vim.keymap.set('v', '<space>y', '"+y')

-- TODO: if on empty line do NOT paste below

vim.keymap.set('n', 'p', 'p`[=`]')
vim.keymap.set('v', 'p', '"0p`[=`]')
vim.keymap.set({'n', 'v'}, 'P', 'P`[=`]')
vim.keymap.set({'n', 'v'}, '<leader>p', '"+p`[=`]')


--======================================== lsp ========================================--
vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition)
vim.keymap.set('n', '<leader>gD', vim.lsp.buf.declaration)
vim.keymap.set('n', '<leader>gi', vim.lsp.buf.implementation)
vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references)
vim.keymap.set('n', '<leader>gt', vim.lsp.buf.type_definition)
vim.keymap.set('n', '<leader>i',  vim.lsp.buf.hover)
vim.keymap.set('n', '<leader>o',  ':lua vim.diagnostic.open_float()<CR>', opt)

-- search diagnostics
vim.keymap.set('n', '<leader>fd', ':lua require("telescope.builtin").diagnostics()<CR>', opt)

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

-- cmp hover
vim.keymap.set('n', 'K', function()
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


--======================================== splits ========================================--
vim.keymap.set('n', '<leader>s', ':split<CR><C-w>j',  opt)
vim.keymap.set('n', '<leader>v', ':vsplit<CR><C-w>l', opt)
vim.keymap.set('n', '<leader>c', ':close<CR>',        opt)

-- quick terminal split
vim.keymap.set('n', '<leader>t', function()
	if IsWin32 then
		vim.cmd('split | wincmd j | resize 7 | term pwsh -nologo')
	else
		vim.cmd('split | wincmd j | resize 7 | term')
	end

	vim.cmd('normal! a')
end, opt)

-- focus 
vim.keymap.set('n', '<leader>h', '<C-w>h')
vim.keymap.set('n', '<leader>j', '<C-w>j')
vim.keymap.set('n', '<leader>k', '<C-w>k')
vim.keymap.set('n', '<leader>l', '<C-w>l')
vim.keymap.set('n', '<leader>w', '<C-w>r')

-- move
vim.keymap.set('n', '<leader>H', ':wincmd H<CR>', opt)
vim.keymap.set('n', '<leader>J', ':wincmd J<CR>', opt)
vim.keymap.set('n', '<leader>K', ':wincmd K<CR>', opt)
vim.keymap.set('n', '<leader>L', ':wincmd L<CR>', opt)

-- resize
vim.keymap.set('n', '<C-Left>',  ':vertical resize -2<CR>', opt)
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', opt)
vim.keymap.set('n', '<C-Up>',    ':resize -2<CR>',          opt)
vim.keymap.set('n', '<C-Down>',  ':resize +2<CR>',          opt)
