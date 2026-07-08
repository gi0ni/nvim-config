vim.opt.indentkeys:remove(':')
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
