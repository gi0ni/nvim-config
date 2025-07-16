return
{
	-- linting files for errors --
	{
		'neovim/nvim-lspconfig',

		config = function()
			local lspconfig = require('lspconfig')

			lspconfig.lua_ls.setup({
				settings = {
					Lua = {
						diagnostics = {
							globals = {
								'vim'
							}
						}
					}
				}
			})

			lspconfig.clangd.setup({
				cmd = {
					'clangd',
					'-header-insertion=never'
				}
			})

			vim.lsp.set_log_level('off') -- clangd REALLY likes logging the most insignificant stuff
		end
	},

	{
		'mason-org/mason-lspconfig.nvim',
		dependencies = { 'mason-org/mason.nvim', 'neovim/nvim-lspconfig' },

		opts = {
			ensure_installed = {
				'lua_ls',
				'clangd',
				'html',
				'cssls',
				'ts_ls'
			}
		}
	},

	{
		'mason-org/mason.nvim',
		opts = {}
	},

	-- show autocomplete suggestions --
	{
		'hrsh7th/nvim-cmp',

		config = function()
			local cmp = require('cmp')

			cmp.setup({
				sources = {
					{ name = 'nvim_lsp' },
					{ name = 'nvim_lsp_signature_help' },
					{ name = 'path' },
					{
						name = 'cmp_gl',
						entry_filter = function(_, _)
							local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ''
							return first_line:match('#include <glad/glad.h>')
						end
					}
				},

				mapping = cmp.mapping.preset.insert({
					['<C-f>'] = cmp.mapping.scroll_docs(-4),
					['<C-b>'] = cmp.mapping.scroll_docs(4),
					['<C-r>'] = cmp.mapping.abort(),
					['<C-e>'] = cmp.mapping.complete(),
					['<Tab>'] = cmp.mapping.confirm({ select = true }),
					['<C-g>'] = function() if cmp.visible_docs() then cmp.close_docs() else cmp.open_docs() end
				  end
				})
			})

			local cmp_autopairs = require('nvim-autopairs.completion.cmp')
			cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
		end
	},

	{ 'hrsh7th/cmp-nvim-lsp', opts = {} },
	{ 'hrsh7th/cmp-nvim-lsp-signature-help' },
	{ 'gi0ni/cmp-path' },
	{ 'gi0ni/cmp-gl', opts = {} }
}
