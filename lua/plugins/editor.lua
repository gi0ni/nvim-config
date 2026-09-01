local sopt = {silent=true}

return
{
	{ -- Basic text editor features (tabs, visible indent level, file tree)
		"akinsho/bufferline.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("bufferline").setup({
				vim.keymap.set("n", "[b", ":BufferLineCyclePrev<CR>", sopt),
				vim.keymap.set("n", "]b", ":BufferLineCycleNext<CR>", sopt),
				vim.keymap.set("n", "[B", ":BufferLineMovePrev<CR>",  sopt),
				vim.keymap.set("n", "]B", ":BufferLineMoveNext<CR>",  sopt),

				options = {
					numbers = function(opts)
						return string.format(" %s", opts.ordinal)
					end,
					buffer_close_icon = " ",
					offsets = {
						{
							filetype = "NvimTree",
							text = "",
							padding = 0,
							highlight = "NvimTreeNormal"
						}
					}
				}
			})

			for i = 1, 9 do
				vim.keymap.set("n", "<leader>" .. i, ":lua require('bufferline').go_to( " .. i .. ", true)<CR>", sopt)
			end
			vim.keymap.set("n", "<leader>0", ":lua require('bufferline').go_to(10, true)<CR>", sopt)
		end
	},
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = {"nvim-tree/nvim-web-devicons"},
		config = function()
			require("nvim-tree").setup({
				update_focused_file = {
					update_cwd = false
				},
				renderer = {
					root_folder_label = ":~"
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
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			indent = {
				char = "|"
			},
			scope = {
				show_start = false,
				show_end   = false
			}
		}
	},
	{
		"nvim-lualine/lualine.nvim",
		opts = {},
		config = function()
			require("lualine").setup {
				options = {
					section_separators   = { left = "", right = "" },
					component_separators = { left = "/", right = "/" },
					disabled_filetypes = {
						statusline = {
							"NvimTree"
						}
					}
				},
				sections = {
					lualine_a = {
						{
							"mode",
							padding = { left = 3, right = 3 }
						}
					}
				}
			}
		end
	},
	{ -- Essential worflow plugins (telescope, lazygit integration)
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			defaults = {
				file_ignore_patterns = {
					"bin[/\\]",
					"build[/\\]",
					"lib[/\\]",
					"inc[/\\]",
					"target[/\\]"
				}
			}
		},
		keys = {
			{"<leader>ff", "<cmd>Telescope find_files<CR>"},
			{"<leader>fg", "<cmd>Telescope live_grep<CR>"},
			{"<leader>fb", "<cmd>Telescope buffers<CR>"}
		}
	},
	{
		"kdheepak/lazygit.nvim",
		dependencies = {"nvim-lua/plenary.nvim"},
		lazy = true,
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		keys = {
			{"<leader>gg", "<cmd>LazyGit<CR>"}
		}
	},
	{ -- Smaller, quality of life plugins
		"tpope/vim-surround"
	},
	{
		"nvim-mini/mini.comment",
		config = function()
			require("mini.comment").setup()
		end
	},
	{
		"max397574/better-escape.nvim",
		config = function()
			require("better_escape").setup {
				timeout = 150,
				default_mappings = false,
				mappings = {
					i = {
						j = {
							k = "<Esc>",
							j = "<Esc>",
						},
					},
					c = {
						j = {
							k = "<C-c>",
							j = "<C-c>",
						},
					},
					v = {
						j = {
							k = "<Esc>",
						},
					},
					s = {
						j = {
							k = "<Esc>",
						},
					},
				}
			}
		end
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			highlight = {
				keyword = "bg"
			},
			keywords = {
				PERF = { icon = " ", alt = {"OPTIM", "PERFORMANCE", "OPTIMIZE", "TIL"}, color = "#10b981" },
			}
		}
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			modes = {
				char = {
					enabled = false
				}
			}
		},
		keys = {
			{ "s", mode = {"n", "x", "o"}, function() require("flash").jump() end, desc = "Flash" }
		}
	}
}
