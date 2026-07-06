vim.treesitter.start()

local hl = require('utils.hl')
hl.set('@keyword.import.python', {link='Purple'})
hl.set('@module.python', {link='White'})
hl.set('@string.escape.python', {link='Yellow'})
