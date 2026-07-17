vim.treesitter.start()

local hl = require('utils.hl')
hl.set('@core.token.glsl', {link='@keyword.directive.glsl'})
hl.set('@keyword.import.glsl', {link='Purple'})
-- hl.set('@layout.specifier', {link='Purple'})
hl.set('@discard.token.glsl', {link='@keyword.glsl'})
