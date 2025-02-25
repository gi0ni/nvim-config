-- bootstrap lazy --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
    	"clone",
		"--filter=blob:none",
		"--branch=stable",
    	"https://github.com/folke/lazy.nvim.git",
	lazypath
})
end
vim.opt.rtp:prepend(lazypath)

-- leader --
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- setup lazy --
require("lazy").setup({
	spec = {
		import = "plugins"
	},
	rocks = {
		enabled = false
	}
})
