-- No tree-sitter C parser installed, using default regex highlight

local hl = require('utils.hl')
hl.set('String', {link='Aqua'})
hl.set('cDefine', {link='Purple'})
