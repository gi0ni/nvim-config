require("config.lazy")

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.nu = true
vim.opt.lazyredraw = true

-- quick escape --
vim.api.nvim_set_keymap("i", "jk", "<esc>:noh<cr>", { noremap = true, silent = true });

-- cursor blink --
vim.opt.guicursor = { "i-ci:ver25-Cursor/lCursor-blinkwait1000-blinkon100-blinkoff100" }

-- netrw --
vim.api.nvim_set_keymap("n", "<leader>e", ":Explore<cr>", { noremap = true, silent = true })

-- comments --
vim.api.nvim_create_autocmd("FileType", { pattern = "*", callback = function() vim.opt_local.formatoptions:remove({'c', 'r', 'o' }) end })

-- search --
vim.api.nvim_set_keymap("n", "<esc>", ":noh<cr>", { noremap = true, silent = true })

-- build --
-- vim.api.nvim_set_keymap("n", "<leader>r", ':wa | !ninja -C build & for ' .. vim.fn.fnameescape('%') .. 'a in ("bin\\*.exe") do (start ' .. vim.fn.fnameescape('%') .. 'a) <cr> | <cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>r", ':wa | !ninja -C build; gnome-terminal -- bash -c "./bin/*" <cr> | <cr>', { noremap = true, silent = true })

-- indent --
vim.keymap.set('n', 'a', function()
	return vim.api.nvim_get_current_line() == "" and '"_cc' or "a"
end, { expr = true, noremap = true, silent = true })

vim.keymap.set('i', '<up>', function()
	local curr = vim.api.nvim_win_get_cursor(0)[1]
	local prev = vim.api.nvim_buf_get_lines(0, curr - 2, curr - 1, false)[1]
	return prev ~= nil and prev == "" and '<up><esc>"_cc' or "<up>"
end, { expr = true, noremap = true, silent = true })

vim.keymap.set('i', '<down>', function()
	local curr = vim.api.nvim_win_get_cursor(0)[1]
	local next = vim.api.nvim_buf_get_lines(0, curr, curr + 1, false)[1]
	return next ~= nil and next == "" and '<down><esc>"_cc' or "<down>"
end, { expr = true, noremap = true, silent = true })
