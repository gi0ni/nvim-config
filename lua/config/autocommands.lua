-- autosave --
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
	pattern = "*",
	callback = function()
		if vim.bo.modified then
			vim.cmd("silent! write")
		end
	end,
})
