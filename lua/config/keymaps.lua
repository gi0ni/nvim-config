require('config.build-and-run')

-- toggle the file explorer --
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { silent = true })

-- hide search results --
vim.keymap.set('n', '<Esc>', ':noh<CR>', { silent = true })

-- autoindent blank lines --
vim.keymap.set('n', 'a', 'a<C-f>')
vim.keymap.set('i', '<Up>', '<Up><C-f>')
vim.keymap.set('i', '<Down>', '<Down><C-f>')

-- i only use x in visual for cutting, thank you
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

-- lsp hover
vim.keymap.set('n', '<leader><leader>', ':lua vim.lsp.buf.hover()<CR>', { silent = true})

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
