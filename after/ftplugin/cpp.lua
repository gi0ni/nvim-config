vim.treesitter.start()

local hl = require("utils.hl")
hl.set("@keyword.import.cpp", {link="Purple"})
hl.set("@custom.directive.cpp", {link="Purple"})
