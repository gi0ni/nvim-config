return
{
	-- autopairs --
	{
		'windwp/nvim-autopairs',
		opts = {}
	},

	{
		'windwp/nvim-ts-autotag',
		dependencies = { 'nvim-treesitter/nvim-treesitter' },
		opts = {},
	},

	{
		'nvim-treesitter/nvim-treesitter',
		opts = {},
		config = function()
			require('nvim-treesitter.configs').setup {
				ensure_installed = { 'html' }
			}
		end,
	},

	{
		'norcalli/nvim-colorizer.lua',
		opts = {},
		config = function()
			require('colorizer').setup({
				'html',
				'css',
				'javascript',
				'typescript'
			})
		end
	},

	-- indent lines --
	{
		'lukas-reineke/indent-blankline.nvim',
		main = 'ibl',

		opts = {
			indent = {
				char = '|'
			},

			scope = {
				show_start = false,
				show_end = false
			}
		}
	},

	-- smart semicolon --
	{
		'gi0ni/smart-semicolon.nvim',
		opts = {}
	},

	-- tabline --
	{
		'akinsho/bufferline.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons', 'ellisonleao/gruvbox.nvim' },

		config = function()
			require('bufferline').setup({
				vim.keymap.set('n', '[b', ':BufferLineCyclePrev<CR>', { silent = true }),
				vim.keymap.set('n', ']b', ':BufferLineCycleNext<CR>', { silent = true }),
				vim.keymap.set('n', '[B', ':BufferLineMovePrev<CR>',  { silent = true }),
				vim.keymap.set('n', ']B', ':BufferLineMoveNext<CR>',  { silent = true }),

				options = {
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
		end
	},

	-- file search --
	{
		'nvim-telescope/telescope.nvim',
		dependencies = { 'nvim-lua/plenary.nvim' },

		opts = {},
		keys = {
			{ '<leader>ff', '<cmd>Telescope find_files<CR>' },
			{ '<leader>fg', '<cmd>Telescope live_grep<CR>' },
			{ '<leader>fb', '<cmd>Telescope buffers<CR>' }
		}
	},

	-- toggle comments --
	{
		'numToStr/Comment.nvim',
		config = function()
			require('Comment').setup()
		end
	},

	-- search current window --
	{
		'folke/flash.nvim',
		event = 'VeryLazy',

		opts = {},
		keys = {
			{ 's', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = 'Flash' }
		}
	},

	-- statusline --
	{
		'nvim-lualine/lualine.nvim',
		opts = {},

		config = function()
			require('lualine').setup {
				options = {
					disabled_filetypes = {
						statusline = {
							'NvimTree'
						}
					}
				}
			}
		end
	},

	-- netrw upgrade --
	{
		'nvim-tree/nvim-tree.lua',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		opts = {}
	}
}
