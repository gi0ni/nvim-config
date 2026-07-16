-- FIX: rust-analyzer sometimes launches 2 instances. Type annotations get shown twice and you get asked twice to rename something

return
{
	-- LSP config for linting
	{
		'neovim/nvim-lspconfig',

		config = function()
			vim.lsp.config('lua_ls', {
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

			vim.lsp.config('pylsp', {
				settings = {
					pylsp = {
						plugins = {
							pycodestyle = {
								ignore = {
									-- TODO: Just straight up copy what the errors say here so you can tell how stupid they are
									'E501', -- Lines longer than 79 characters
									'E302', -- 2 blank lines after imports
									'E305', -- 2 blank lines after definitions
									'E231', -- Whitespace after operator
									'E251', -- Whitespace after parameter equals
									'E701', -- Multiple statements on same line
									'E303', -- Too many blank lines

									'E261', -- at least two spaces before inline comment
									'W293', -- blank line contains whitespace
									'E221', -- multiple spaces before operator
									'E272', -- multiple spaces before keyword
									'E241', -- multiple spaces after ':'
								}
							}
						}
					}
				}
			})

			local capabilities = require('cmp_nvim_lsp').default_capabilities()
			capabilities.textDocument.completion.completionItem.snippetSupport = false

			vim.lsp.config('clangd', {
				capabilities = capabilities,
				cmd = {
					'clangd',
					'-header-insertion=never',
					'--compile-commands-dir=build',
					'--background-index'
				}
			})

			vim.lsp.config('rust_analyzer', {
				cmd = { vim.fn.stdpath('data') .. '/mason/bin/rust-analyzer' .. (IsWin32 and '.cmd' or '') },

				settings = {
					['rust-analyzer'] = {
						completion = {
							callable = {
								snippets = 'add_parentheses' -- No placeholder args
							}
						}
					}
				}
			})

			vim.lsp.enable('lua_ls')
			vim.lsp.enable('pylsp')
			vim.lsp.enable('clangd')
			vim.lsp.enable('rust_analyzer')
			vim.lsp.enable('html')
			vim.lsp.enable('cssls')
			vim.lsp.enable('ts_ls')

			vim.lsp.log.set_level('off') -- clangd REALLY likes logging the most insignificant stuff
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
			},

			handlers = {
				rust_analyzer = function() end
			}
		}
	},

	{
		'mason-org/mason.nvim',
		opts = {}
	},


	-- Autocomplete
	{
		'hrsh7th/nvim-cmp',

		config = function()
			local cmp = require('cmp')

			cmp.setup({
				completion = {
					completeopt = 'menu,menuone,noinsert'
				},

				sources = {
					{
						name = 'cmp_gl', -- glad headers don't come with docs for some reason
						entry_filter = function(_, _)
							return vim.fn.isdirectory('shd') == 1;
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
					['<Tab>'] = cmp.mapping.confirm({select=true}),
					['<C-g>'] = function() if cmp.visible_docs() then cmp.close_docs() else cmp.open_docs() end
				  end
				}),

				formatting = {
					format = function(_, vim_item)
						vim_item.menu = ''
						return vim_item
					end
				},

				window = {
					completion = cmp.config.window.bordered({
						border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
						scrollbar = false,
						winhighlight = 'Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:Visual,Search:None',
						max_height = 10
					}),
					documentation = cmp.config.window.bordered({
						border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
						scrollbar = false,
						winhighlight = 'Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:Visual,Search:None',
						max_height = 20
					})
				}
			})
		end
	},

	{'hrsh7th/cmp-nvim-lsp', opts = {}},
	{'hrsh7th/cmp-nvim-lsp-signature-help'},
	{'gi0ni/cmp-path'},
	{'gi0ni/cmp-gl', opts = {}}
}
