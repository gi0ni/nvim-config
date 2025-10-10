require('config.lazy')
IsWin32 = (vim.loop.os_uname().sysname == 'Windows_NT')

require('config.options')
require('config.keymaps')
require('config.autocmds')
