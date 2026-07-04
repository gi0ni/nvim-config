require('config.build')
local sopt = { silent = true }

-- Learn how to use Vim properly, dumbass
vim.keymap.set({'n', 'i', 'v', 't', 'c'}, '<Up>', '<Nop>')
vim.keymap.set({'n', 'i', 'v', 't', 'c'}, '<Right>', '<Nop>')
vim.keymap.set({'n', 'i', 'v', 't', 'c'}, '<Left>', '<Nop>')
vim.keymap.set({'n', 'i', 'v', 't', 'c'}, '<Down>', '<Nop>')

-- Toggle the file explorer split
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', sopt)

-- Clear search result highlights
vim.keymap.set('n', '<Esc>', ':noh<CR>', sopt)

-- Scroll while keeping the cursor in the middle of the screen
vim.keymap.set({'n', 'v'}, '<C-f>', '<Up>zz');
vim.keymap.set({'n', 'v'}, '<C-b>', '<Down>zz');

-- Search things more easily
vim.keymap.set('v', '<leader>z', 'y/\\V<C-r>"<CR>N')
vim.keymap.set({'n', 'v'}, '*', '*N');

-- Very annoying, will remove
vim.keymap.set('n', '<C-d>', '<Nop>');
vim.keymap.set('n', 'q:', '<Nop>');
vim.keymap.set('n', 'ZZ', 'zz');

-- Change line identation
vim.keymap.set('v', '>', '>gv')
vim.keymap.set('v', '<', '<gv')

-- Shift lines up and down
vim.keymap.set('v', 'J', ":move '>+1<CR>gv=gv", sopt)
vim.keymap.set('v', 'K', ":move '<-2<CR>gv=gv", sopt)

-- ===== Yank and put tweaks ===== --
-- Do not overwrite yank register when deleting
vim.keymap.set({'n', 'v'}, 'd', '"dd')
vim.keymap.set({'n', 'v'}, 'c', '"dc')
vim.keymap.set('n', 'x', '"dx')
vim.keymap.set('v', 'x', '"0x')

-- Auto indent when putting
vim.keymap.set({'n', 'v'}, 'p', '"0p`[=`]')
vim.keymap.set({'n', 'v'}, 'P', '"0P`[=`]')
vim.keymap.set({'n', 'v'}, 'gp', 'p`[=`]')
vim.keymap.set({'n', 'v'}, 'gP', 'P`[=`]')

-- Quick yank/put to system clipboard
vim.keymap.set('n', '<space>y', '"+yy')
vim.keymap.set('v', '<space>y', '"+y')
vim.keymap.set({'n', 'v'}, '<leader>p', '"+p`[=`]')

-- ===== LSP ===== --
vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition)
vim.keymap.set('n', '<leader>gD', vim.lsp.buf.declaration)
vim.keymap.set('n', '<leader>gi', vim.lsp.buf.implementation)
vim.keymap.set('n', '<leader>gR', vim.lsp.buf.references)
vim.keymap.set('n', '<leader>gt', vim.lsp.buf.type_definition)
vim.keymap.set('n', '<leader>gk', vim.lsp.buf.hover)
vim.keymap.set('n', '<leader>o', ':lua vim.diagnostic.open_float()<CR>', sopt)
vim.keymap.set('n', '<leader>i', ':lua vim.lsp.buf.code_action()<CR>', sopt)

local hints_enabled = false
vim.keymap.set('n', '<leader>gh', function()
	vim.lsp.inlay_hint.enable(not hints_enabled, {0})
	hints_enabled = not hints_enabled;
end, sopt)

-- Jump to diagnostic using Telescope
vim.keymap.set('n', '<leader>fd', ':lua require("telescope.builtin").diagnostics()<CR>', sopt)

-- Fancy scoped token replace, no command history visible
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

	vim.opt.cmdwinheight = 1
	vim.lsp.buf.rename()

	vim.defer_fn(function()
		if cmdId then
			vim.api.nvim_del_autocmd(cmdId)
		end

		vim.opt.cmdwinheight = 7
	end, 500)
end)

-- Shortcut to open up cmp
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


-- ===== Splits ===== --
vim.keymap.set('n', '<leader>s', ':split<CR><C-w>j',  sopt)
vim.keymap.set('n', '<leader>v', ':vsplit<CR><C-w>l', sopt)
vim.keymap.set('n', '<leader>c', ':close<CR>',        sopt)

-- Quick terminal split
vim.keymap.set('n', '<leader>t', function()
	if IsWin32 then
		vim.cmd('vsplit | wincmd l | term pwsh -nologo')
	else
		vim.cmd('vsplit | wincmd l | term')
	end

	vim.cmd('normal! a')
end, sopt)

-- Close terminal shortcut 'cause the existing one is way too complicated to remember
vim.keymap.set('t', '<leader>q', '<C-\\><C-n>')

-- Focus
vim.keymap.set('n', '<leader>h', '<C-w>h')
vim.keymap.set('n', '<leader>j', '<C-w>j')
vim.keymap.set('n', '<leader>k', '<C-w>k')
vim.keymap.set('n', '<leader>l', '<C-w>l')

-- Move
vim.keymap.set('n', '<leader>H', ':wincmd H<CR>', sopt)
vim.keymap.set('n', '<leader>J', ':wincmd J<CR>', sopt)
vim.keymap.set('n', '<leader>K', ':wincmd K<CR>', sopt)
vim.keymap.set('n', '<leader>L', ':wincmd L<CR>', sopt)

-- Resize
vim.keymap.set('n', '<C-Left>',  ':vertical resize +2<CR>', sopt)
vim.keymap.set('n', '<C-Right>', ':vertical resize -2<CR>', sopt)
vim.keymap.set('n', '<C-Up>', ':resize +2<CR>', sopt)
vim.keymap.set('n', '<C-Down>', ':resize -2<CR>', sopt)
