require("config.lazy")

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.nu = true

-- cursor blink --
vim.opt.guicursor = { "i-ci:ver25-Cursor/lCursor-blinkwait1000-blinkon100-blinkoff100" }

-- netrw --
vim.api.nvim_set_keymap("n", "<leader>e", ":Explore<cr>", { noremap = true, silent = true })

-- search --
vim.api.nvim_set_keymap("n", "<esc>", ":noh<cr>", { noremap = true, silent = true })

-- build --
vim.api.nvim_set_keymap("n", "<leader>r", ':wa | !ninja -C build & for ' .. vim.fn.fnameescape('%') .. 'a in ("bin\\*.exe") do (start ' .. vim.fn.fnameescape('%') .. 'a) <cr> | <cr>', { noremap = true, silent = true })
