local hl = {}

function hl.set(name, val)
	vim.api.nvim_set_hl(0, name, val)
end

return hl
