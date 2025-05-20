return
{
	-- autopairs --
	{
		"windwp/nvim-autopairs",
		opts = {}
	},

	-- indent lines --
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = { 
			indent = { char = '|' },
			scope = {
				show_start = false,
				show_end = false,
			}
		}
	},

	-- smart semicolon --
	{
		"gi0ni/smart-semicolon.nvim",
		opts = {}
	},

	-- tabs --
	{
		"akinsho/bufferline.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons", "ellisonleao/gruvbox.nvim" },

		config = function()
			require("bufferline").setup({
				vim.api.nvim_set_keymap("n", "[b", ":BufferLineCyclePrev<cr>", { noremap = true, silent = true }),
				vim.api.nvim_set_keymap("n", "]b", ":BufferLineCycleNext<cr>", { noremap = true, silent = true }),
				vim.api.nvim_set_keymap("n", "[B", ":BufferLineMovePrev<cr>",  { noremap = true, silent = true }),
				vim.api.nvim_set_keymap("n", "]B", ":BufferLineMoveNext<cr>",  { noremap = true, silent = true })
			})
		end
	},

	-- easier file management --
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files"   },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Live grep"    },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Find buffers" }
		}
	},

	-- toggle comments --
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	},

	-- f the mouse --
	{
		"folke/flash.nvim",
		event = "VeryLazy",

		opts = {},
		keys = {
			{ "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
		}
	}
}
