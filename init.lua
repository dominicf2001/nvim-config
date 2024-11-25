-- ==========
-- GENERAL
-- ==========
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local o = vim.o
o.clipboard = "unnamedplus"

o.mouse = "a"

o.number = true

o.expandtab = true
o.smartindent = true
o.tabstop = 4
o.shiftwidth = 4

o.ignorecase = true
o.smartcase = true

o.breakindent = true

-- save undo history
o.undofile = true

o.updatetime = 250

vim.g.have_nerd_font = true

o.timeoutlen = 300

o.scrolloff = 10

-- better hlsearch exiting
o.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.o.signcolumn = "no"

-- ==========
-- PLUGINS
-- ==========

-- ENSURE LAZY.NVIM INSTALLED
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{ -- Theme
		"rebelot/kanagawa.nvim",
		priority = 1000,
		init = function()
			o.termguicolors = true
			vim.cmd.colorscheme("kanagawa")
			vim.cmd.hi("Comment gui=none")
		end,
	},
	require("plugins.harpoon"),
	require("plugins.cmp"),
	require("plugins.telescope"),
	require("plugins.lsp"),
	require("plugins.conform"),
	require("plugins.neo-tree"),
	require("plugins.treesitter"),
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},
	"Olical/conjure",
	"numToStr/Comment.nvim",
	"gpanders/nvim-parinfer",
	"tpope/vim-sleuth",
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		dependencies = { "hrsh7th/nvim-cmp" },
		config = function()
			require("nvim-autopairs").setup({})
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},
})

-- ==========
-- GENERAL KEYMAPS
-- ==========

-- windows
vim.keymap.set("n", "<leader>w", "<c-w>")

-- telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[F]ind [H]elp" })
vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "[F]ind [K]eymaps" })
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })
vim.keymap.set("n", "<leader>fe", ":Neotree toggle<CR>", { desc = "[Find] in [E]xplorer" })
vim.keymap.set("n", "<leader>fs", builtin.builtin, { desc = "[F]ind [S]elect Telescope" })
vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "[F]ind current [W]ord" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]ind by [G]rep" })
vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "[F]ind [D]iagnostics" })
vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "[F]ind [R]esume" })
vim.keymap.set("n", "<leader>f.", builtin.oldfiles, { desc = '[F]ind Recent Files ("." for repeat)' })
vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
vim.keymap.set("n", "<leader>fc", function()
	builtin.find_files({ cwd = "/etc/nixos" })
end, { desc = "[F]ind [C]onfig" })

vim.keymap.set("n", "<leader>/", function()
	builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = false,
	}))
end, { desc = "[/] Fuzzily search in current buffer" })

-- GENERAL AUTOCOMMANDS
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight on yank",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
