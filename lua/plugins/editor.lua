return
{
	-- basic editor utilities
	{
		'akinsho/bufferline.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' },

		config = function()
			require('bufferline').setup({
				vim.keymap.set('n', '[b', ':BufferLineCyclePrev<CR>', { silent = true }),
				vim.keymap.set('n', ']b', ':BufferLineCycleNext<CR>', { silent = true }),
				vim.keymap.set('n', '[B', ':BufferLineMovePrev<CR>',  { silent = true }),
				vim.keymap.set('n', ']B', ':BufferLineMoveNext<CR>',  { silent = true }),

				options = {
					numbers = 'none',
					offsets = {
						{
							filetype = 'NvimTree',
							text = '',
							padding = 0,
							highlight = 'NvimTreeNormal'
						}
					}
				}
			})

			for i = 1, 9 do
				vim.keymap.set('n', '<leader>' .. i, ':lua require("bufferline").go_to( ' .. i .. ', true)<CR>', { silent = true })
			end
			vim.keymap.set('n', '<leader>0', ':lua require("bufferline").go_to(10, true)<CR>', { silent = true })
		end
	},

	{
		'nvim-tree/nvim-tree.lua',
		dependencies = { 'nvim-tree/nvim-web-devicons' },

		config = function()
			require('nvim-tree').setup({
				update_focused_file = {
					update_cwd = false
				},

				renderer = {
					root_folder_label = ':~'
				},

				view = {
					preserve_window_proportions = true
				},

				filters = {
					dotfiles = true
				}
			})
		end
	},

	{
		'lukas-reineke/indent-blankline.nvim',
		main = 'ibl',

		opts = {
			indent = {
				char = '|'
			},

			scope = {
				show_start = false,
				show_end   = false
			}
		}
	},

	{
		'nvim-lualine/lualine.nvim',
		opts = {},

		config = function()
			require('lualine').setup {
				options = {
					section_separators   = { left = '', right = '' },
					component_separators = { left = '/', right = '/' },

					disabled_filetypes = {
						statusline = {
							'NvimTree'
						}
					}
				},

				sections = {
					lualine_a = {
						{
							'mode',
							padding = { left = 3, right = 3 }
						}
					}
				}
			}
		end
	},

	{
		"tversteeg/registers.nvim",
		cmd = "Registers",
		config = true,
		keys = {
			{ "\"",    mode = { "n", "v" } },
			{ "<C-R>", mode = "i" }
		},
		name = "registers",
	},


	-- convinience
	{
		'nvim-telescope/telescope.nvim',
		dependencies = { 'nvim-lua/plenary.nvim' },

		opts = {
			defaults = {
				file_ignore_patterns = {
					"bin/",
					"build/"
				}
			}
		},
		keys = {
			{ '<leader>ff', '<cmd>Telescope find_files<CR>' },
			{ '<leader>fg', '<cmd>Telescope live_grep<CR>'  },
			{ '<leader>fb', '<cmd>Telescope buffers<CR>'    }
		}
	},

	{
		'kdheepak/lazygit.nvim',
		dependencies = { 'nvim-lua/plenary.nvim' },
		lazy = true,

		cmd = {
			'LazyGit',
			'LazyGitConfig',
			'LazyGitCurrentFile',
			'LazyGitFilter',
			'LazyGitFilterCurrentFile',
		},

		keys = {
			{ '<leader>gg', '<cmd>LazyGit<CR>' }
		}
	},

	{
		'windwp/nvim-autopairs',
		opts = {}
	},

	{
		'tpope/vim-surround'
	},

	{
		'windwp/nvim-ts-autotag',
		dependencies = { 'nvim-treesitter/nvim-treesitter' },
		opts = {}
	},

	{
		'numToStr/Comment.nvim',
		config = function()
			require('Comment').setup()
		end
	},


	-- niche
	{
		'max397574/better-escape.nvim',
		config = function()
			require('better_escape').setup {
				timeout = 150
			}
		end
	},

	{
		'folke/todo-comments.nvim',
		dependencies = { 'nvim-lua/plenary.nvim' },
		opts = {
			highlight = {
				keyword = "bg"
			}
		}
	},

	{
		'gi0ni/smart-semicolon.nvim',
		opts = {}
	},

	{
		'folke/flash.nvim',
		event = 'VeryLazy',

		opts = {
			modes = {
				char = {
					enabled = false
				}
			}
		},

		keys = {
			{ 's', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = 'Flash' }
		}
	},
}
