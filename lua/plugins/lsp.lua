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

			vim.lsp.config('clangd', {
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


	-- Completion suggestions
	{
		'saghen/blink.cmp',
		version = '1.*',
		opts = {
			keymap = {
				preset = 'none',
				['<C-r>'] = {'show', 'hide'},
				['<C-e>'] = {'select_and_accept'},
				['<M-g>'] = {'show_documentation', 'hide_documentation'}, -- FIX: This does not work while the signature is shown. Why?
				['<C-f>'] = {'scroll_documentation_up', 'scroll_signature_up'},
				['<C-b>'] = {'scroll_documentation_down', 'scroll_signature_down'},
				['<C-n>'] = {'select_next'},
				['<C-p>'] = {'select_prev'},
				['<C-k>'] = {'show_signature', 'hide_signature'},
				['<Tab>'] = {'snippet_forward', 'fallback'},
				['<S-Tab>'] = {'snippet_backward'}
			},
			appearance = {
				nerd_font_variant = 'mono'
			},
			completion = {
				documentation = {
					auto_show = false,
					window = {
						border = 'rounded',
						scrollbar = false
					},
				},
				menu = {
					border = 'rounded',
					scrollbar = false
				},
			},
			signature = {
				enabled = true,
				window = {
					show_documentation = false,
					border = 'rounded',
					scrollbar = false
				}
			},
			sources = {
				default = { 'lsp', 'path' } -- 'snippets', 'buffer'
			},
			fuzzy = {
				implementation = 'prefer_rust_with_warning'
			}
		},
		opts_extend = {
			'sources.default'
		},
		config = function(_, opts)
			require('blink.cmp').setup(opts)

			local hl = require('utils.hl')
			hl.set('BlinkCmpMenu', {link='Normal'})
			hl.set('BlinkCmpMenuBorder', {link='Normal'})
			hl.set('BlinkCmpMenuSelection', {link='Visual'})
			hl.set('BlinkCmpLabelDetail', {link='Normal'})
			hl.set('BlinkCmpLabelDeprecated', {link='ErrorMsg'})

			hl.set('BlinkCmpDoc', {link='Normal'})
			hl.set('BlinkCmpDocBorder', {link='Normal'})
			hl.set('BlinkCmpDocSeparator', {link='Normal'})

			hl.set('BlinkCmpSignatureHelp', {link='Normal'})
			hl.set('BlinkCmpSignatureHelpBorder', {link='Normal'})
			hl.set('BlinkCmpSignatureHelpActiveParameter', {link='Visual'})
		end
	}
}
