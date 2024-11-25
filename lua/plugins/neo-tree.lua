return {
	"nvim-neo-tree/neo-tree.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
	},
	cmd = "Neotree",
	opts = {
		close_if_last_window = true,
		window = {
			width = 28,
			mappings = {
				["h"] = "close_node",
				["l"] = "open",
			},
		},
		event_handlers = {
			{
				event = "neo_tree_buffer_enter",
				handler = function()
					vim.cmd("highlight! Cursor blend=100")
				end,
			},
			{
				event = "neo_tree_buffer_leave",
				handler = function()
					vim.cmd("highlight! Cursor guibg=#5f87af blend=0")
				end,
			},
			{
				event = "file_opened",
				handler = function(file_path)
					require("neo-tree.command").execute({ action = "close" })
				end,
			},
		},
		filesystem = {
			filtered_items = {
				hide_by_pattern = {
					"**/*_templ.go",
					"**/*_templ.txt",
				},
			},
			components = {
				harpoon_index = function(config, node, _)
					local harpoon_list = require("harpoon"):list()
					local path = node:get_id()
					local harpoon_key = vim.uv.cwd()

					for i, item in ipairs(harpoon_list.items) do
						local value = item.value
						if string.sub(item.value, 1, 1) ~= "/" then
							value = harpoon_key .. "/" .. item.value
						end

						if value == path then
							vim.print(path)
							return {
								text = string.format(" ⥤ %d", i), -- <-- Add your favorite harpoon like arrow here
								highlight = config.highlight or "NeoTreeDirectoryIcon",
							}
						end
					end
					return {}
				end,
			},
			renderers = {
				file = {
					{ "icon" },
					{ "name", use_git_status_colors = true },
					{ "harpoon_index" }, --> This is what actually adds the component in where you want it
					{ "diagnostics" },
					{ "git_status", highlight = "NeoTreeDimText" },
				},
			},
		},
	},
}
