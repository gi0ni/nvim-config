return
{
	-- linter
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
					'-header-insertion=never',
					'--function-arg-placeholders=0'
				}
			})

			lspconfig.rust_analyzer.setup({
				settings = {
					['rust-analyzer'] = {
						completion = {
							callable = {
								snippets = "add_parentheses" -- no placeholder args
							}
						}
					}
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
				'pylsp',

				'clangd',
				'rust_analyzer',

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


	-- complete suggestions
	{
		'hrsh7th/nvim-cmp',

		config = function()
			local cmp = require('cmp')

			cmp.setup({
				sources = {
					{
						name = 'cmp_gl', -- glad headers don't come with docs for some reason
						entry_filter = function(_, _)
							local lines = vim.api.nvim_buf_get_lines(0, 0, 5, false)

							for i = 1, 5 do
								local current_line = lines[i] or ''
								if current_line:match('#include <glad/glad.h>') then
									return true
								end
							end

							return false
						end
					},
					{ name = 'nvim_lsp' },
					{ name = 'nvim_lsp_signature_help' },
					{ name = 'path' }
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
