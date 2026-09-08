local palette = {
	bg         = "#0e1415",
	fg         = "#cecece",
	dim        = "#30464a",
	line       = "#182325",
	keyword    = "#999999",
	type       = "#708b8d",
	operator   = "#708b8d",
	comment    = "#707070",
	border     = "#cecece",
	emphasis   = "#71ade7",
	func       = "#71ade7",
	string     = "#95cb82",
	char       = "#dfdf8e",
	special    = "#dfdf8e",
	const      = "#dfdf8e",
	highlight  = "#cd974b",
	info       = "#8ebeec",
	success    = "#6abf40",
	warning    = "#ec8013",
	danger     = "#d2322d",
	green      = "#95cb82",
	orange     = "#ec8013",
	red        = "#c33c33",
	pink       = "#cc8bc9",
	cyan       = "#47bea9",
}

return
{
	{
		"oskarnurm/koda.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("koda").setup({
				colors = {
					moss = {
						const = "#cc8bc9"
					}
				},
				on_highlights = function(hl, c)
					hl.TodoBgPERF = {bg=c.green, fg=c.bg, bold=true}
					hl.TodoFgPERF = {fg=c.green}

					hl.NvimTreeNormal = {bg="#070b0b"}
					hl.Title = {fg=c.pink}
					hl.Directory = {fg=c.green}
					hl.NvimTreeFolderIcon = {fg=c.orange}
				end
			})
			vim.cmd("colorscheme koda-moss")
		end
	},
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local site = require("nvim-treesitter")
			site.setup({
				install_dir = vim.fn.stdpath("data") .. "/site"
			})
			site.install({"cpp", "glsl", "python"})
		end
	}
}
