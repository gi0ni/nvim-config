require("config.lazy")
Is_win32 = (vim.loop.os_uname().sysname == "Windows_NT")

require("config.options")
require("config.keymaps")
require("config.autocmds")
