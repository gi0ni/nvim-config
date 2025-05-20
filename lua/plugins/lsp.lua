return
{
	-- linter --
	{
		"williamboman/mason.nvim",
		veresion = "^1.0.0",
		opts = {}
	},

	{
		"neovim/nvim-lspconfig",
		config = function()
			require("mason").setup({})
			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup({ settings = { Lua = { diagnostics = { globals = { "vim" } } } } })
			lspconfig.clangd.setup({ cmd = { "clangd", "-header-insertion=never" } })

			vim.lsp.set_log_level("off")
		end
	},

	{
		"williamboman/mason-lspconfig.nvim",
		version = "^1.0.0",
		opts = {
			ensure_installed = {
				"lua_ls",
				"clangd",
			}
		}
	},

	-- suggestions --
	{
		"hrsh7th/nvim-cmp",
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				sources = {
					{
						name = "cmp_gl",
						entry_filter = function(entry, ctx)
							local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ""
							if first_line:match("#include <glad/glad.h>") then
								return true
							else
								return false
							end
						end,
					},
					{ name = "nvim_lsp" },
					{ name = "nvim_lsp_signature_help" },
					{ name = "path" },
				},
				mapping = cmp.mapping.preset.insert({
					['<C-f>'] = cmp.mapping.scroll_docs(-4),
					['<C-b>'] = cmp.mapping.scroll_docs(4),
					["<C-r>"] = cmp.mapping.abort(),
					["<C-e>"] = cmp.mapping.complete(),
					["<Tab>"] = cmp.mapping.confirm({ select = true }),
					['<C-g>'] = function() if cmp.visible_docs() then cmp.close_docs() else cmp.open_docs() end
				  end
				})
			})
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end
	},

	{ "hrsh7th/cmp-nvim-lsp", opts = {} },
	{ "hrsh7th/cmp-nvim-lsp-signature-help" },
	{ "gi0ni/cmp-path" },
	{ "gi0ni/cmp-gl", opts = {} }
}
