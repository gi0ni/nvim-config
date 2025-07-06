-- disable automatic comment insertion on new lines --
vim.api.nvim_create_autocmd("FileType", { pattern = "*", callback = function() vim.opt_local.formatoptions:remove({ 'c', 'r', 'o' }) end })
