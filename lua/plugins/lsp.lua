local on_attach = function(event)
	local bufnr = event.buf
	local client = vim.lsp.get_client_by_id(event.data.client_id)

	local map = function(keys, func, desc)
		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
	end

	local builtin = require("telescope.builtin")
	map("gd", builtin.lsp_definitions, "[G]oto [D]efinition")
	map("gI", builtin.lsp_implementations, "[G]oto [I]mplementation")
	map("gr", builtin.lsp_references, "[G]oto [R]eferences")
	map("<leader>ds", builtin.lsp_document_symbols, "[D]ocument [S]ymbols")
	map("<leader>dS", builtin.lsp_dynamic_workspace_symbols, "[D]ocument workspace [S]ymbols")
	map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
	map("<leader>e", vim.diagnostic.open_float, "[E]rror Dialog")
	map("K", vim.lsp.buf.hover, "Hover Documentation")

	vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
		require("conform").format({ async = true, lsp_fallback = true })
	end, {})

	if client and client.server_capabilities.documentHighlightProvider then
		local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
			buffer = bufnr,
			group = highlight_augroup,
			callback = vim.lsp.buf.document_highlight,
		})
		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
			buffer = bufnr,
			group = highlight_augroup,
			callback = vim.lsp.buf.clear_references,
		})
		vim.api.nvim_create_autocmd("LspDetach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
			callback = function(event)
				vim.lsp.buf.clear_references()
				vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event.buf })
			end,
		})
	end

	if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
		map("<leader>th", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
		end, "[T]oggle Inlay [H]ints")
	end
end

return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "williamboman/mason.nvim", config = true },
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		{ "j-hui/fidget.nvim", opts = {} },
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
			callback = on_attach,
		})

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

		local servers = {
			lua_ls = {
				settings = {
					Lua = {
						workspace = { checkThirdParty = false },
						telemetry = { enable = false },
						completion = { callSnippet = "Replace" },
					},
				},
			},
			tsserver = {},
			svelte = {},
			tailwindcss = {
				filetypes = { "templ", "astro", "javascript", "typescript", "react", "svelte" },
				settings = {
					tailwindCSS = {
						includeLanguages = { templ = "html" },
					},
				},
			},
			templ = {},
			html = { filetypes = { "html", "templ" } },
			htmx = { filetypes = { "html", "templ" } },
			cssls = {},
			jsonls = {},
			gopls = {},
			clangd = {},
			csharp_ls = {},
			astro = {},
		}

		require("mason").setup()

		local ensure_installed = vim.tbl_keys(servers or {})
		vim.list_extend(ensure_installed, { "stylua" })

		require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

		require("mason-lspconfig").setup({
			handlers = {
				function(server_name)
					local server = servers[server_name] or {}
					server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
					require("lspconfig")[server_name].setup(server)
				end,
			},
		})
	end,
}
