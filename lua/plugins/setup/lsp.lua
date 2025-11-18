local vim = vim

local function cmp_setup()
	local cmp = require("cmp")
	local lspkind = require("lspkind")

	cmp.setup {
		snippet = {
			-- REQUIRED - you must specify a snippet engine
			expand = function(args)
				vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
				-- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
				-- require('snippy').expand_snippet(args.body) -- For `snippy` users.
				-- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
				-- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)

				-- For `mini.snippets` users:
				-- local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
				-- insert({ body = args.body }) -- Insert at cursor
				-- cmp.resubscribe({ "TextChangedI", "TextChangedP" })
				-- require("cmp.config").set_onetime({ sources = {} })
			end,
		},
		window = {
			-- completion = cmp.config.window.bordered(),
			-- documentation = cmp.config.window.bordered(),
		},
		mapping = cmp.mapping.preset.insert {
			["<C-b>"] = cmp.mapping.scroll_docs(-4),
			["<C-f>"] = cmp.mapping.scroll_docs(4),
			["<C-Space>"] = cmp.mapping.complete(),
			["<C-e>"] = cmp.mapping.abort(),
			["<CR>"] = cmp.mapping.confirm { select = true }, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		},
		sources = cmp.config.sources({
			{ name = "nvim_lsp" },
			{ name = "vsnip" }, -- For vsnip users.
			-- { name = 'luasnip' }, -- For luasnip users.
			-- { name = 'ultisnips' }, -- For ultisnips users.
			-- { name = 'snippy' }, -- For snippy users.
		}, {
			{ name = "buffer" },
		}),
		formatting = {
			format = lspkind.cmp_format {
				mode = "symbol_text",
				maxiwdth = {
					menu = 50,
					abbr = 50,
				},
				ellipsis_char = "...",
				show_labelDetails = true,
				before = function(entry, vim_item)
					return vim_item
				end,
			},
		},
	}

	-- To use git you need to install the plugin petertriho/cmp-git and uncomment lines below
	-- Set configuration for specific filetype.
	--[[ cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'git' },
    }, {
      { name = 'buffer' },
    })
  })
  require("cmp_git").setup() ]]
	--

	-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
	cmp.setup.cmdline({ "/", "?" }, {
		mapping = cmp.mapping.preset.cmdline(),
		sources = {
			{ name = "buffer" },
		},
	})

	-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
	cmp.setup.cmdline(":", {
		mapping = cmp.mapping.preset.cmdline(),
		sources = cmp.config.sources({
			{ name = "path" },
		}, {
			{ name = "cmdline" },
		}),
		matching = { disallow_symbol_nonprefix_matching = false },
	})

	-- For lsp condig
	return require("cmp_nvim_lsp").default_capabilities()
end

local function get_python_path()
	local pdm = vim.fn.system("pdm info --python 2>/dev/null")

	if vim.v.shell_error == 0 then
		return vim.fn.trim(pdm)
	end

	return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
end

local default_lsp_config = {
	capabilities = cmp_setup(),
}

local lsp_configs = {
	["jedi_language_server"] = {},
	["pyright"] = {
		settings = {
			root_markers = {
				"pyproject.toml",
				"setup.py",
				"requirements.txt",
			},
			python = {
				analysis = {
					typeCheckingMode = "basic",
					autoSearchPaths = true,
					autoImportCompletions = true,
					useLibraryCodeForTypes = false,
					diagnosticMode = "workspace",
				},
				pythonPath = get_python_path(),
			},
		},
	},
	-- "tailwindcss",
	["lua_ls"] = {},
	["ts_ls"] = {},
	["rust_analyzer"] = {},
}

require("mason").setup()

-- require'mason-lspconfig'.setup({
-- ensure_installed = vim.tbl_keys(lsp_configs),
-- automatic_installation = false,
-- })

local lsp = require("lspconfig")

for server_name, server_conf in pairs(lsp_configs) do
	local conf = {}

	for k, v in pairs(default_lsp_config) do
		conf[k] = v
	end
	for k, v in pairs(server_conf) do
		conf[k] = v
	end

	lsp[server_name].setup(conf)
end

vim.cmd([[
    autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
    autocmd BufRead,BufNewFile *.json set filetype=json
    autocmd FileType json setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
    autocmd FileType javascript setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
    autocmd FileType javascriptreact setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
    autocmd FileType typescript setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
    autocmd FileType typescriptreact setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
    autocmd FileType css setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
    autocmd FileType python set shiftwidth=4 tabstop=4 softtabstop=4 expandtab autoindent fileformat=unix
    autocmd FileType lua setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
]])

