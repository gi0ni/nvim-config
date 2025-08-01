-- disable automatic comment insertion on new lines --
vim.api.nvim_create_autocmd('FileType', { pattern = '*', callback = function() vim.opt_local.formatoptions:remove({ 'c', 'r', 'o' }) end })

-- remember cursor position
vim.api.nvim_create_autocmd('BufReadPost', { pattern = '*', callback = function() vim.cmd('normal! `"zz') end })
