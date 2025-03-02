require("config.lazy")

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.nu = true

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
vim.api.nvim_set_keymap("n", "<leader>r", ':wa | !ninja -C build & for ' .. vim.fn.fnameescape('%') .. 'a in ("bin\\*.exe") do (start ' .. vim.fn.fnameescape('%') .. 'a) <cr> | <cr>', { noremap = true, silent = true })
