vim.keymap.set("n", "<space>n", ":NvimTreeToggle<CR>", { noremap = true })
vim.keymap.set("n", "<space>ss", ":set spell<CR>", { noremap = true })
vim.keymap.set("n", "<space>sn", ":set nospell<CR>", { noremap = true })
vim.keymap.set("n", "<space>ld", ":DBUI<CR>", { noremap = true })
vim.keymap.set("n", "<space>ln", ":Neogit<CR>", { noremap = true })
vim.keymap.set("n", "<space>'", ":b#<CR>", { noremap = true })
vim.keymap.set("n", "<space>gl", ":PrettierAsync<CR>", { noremap = true })
vim.keymap.set("v", "<space>gl", ":PrettierFragment<CR>", { noremap = true })
vim.keymap.set("n", "<space><space>", ":e #<CR>", { noremap = true })
vim.keymap.set("n", "<space>g<space>", ":Gen<CR>", { noremap = true })

vim.keymap.set("n", "K", "5k", { noremap = true })
vim.keymap.set("n", "J", "5j", { noremap = true })
vim.keymap.set("n", "L", "10l", { noremap = true })
vim.keymap.set("n", "H", "10h", { noremap = true })

vim.keymap.set("n", "<Up>", ":resize +3<CR>", { noremap = true })
vim.keymap.set("n", "<Down>", ":resize -3<CR>", { noremap = true })
vim.keymap.set("n", "<Right>", ":vertical resize +3<CR>", { noremap = true })
vim.keymap.set("n", "<Left>", ":vertical resize -3<CR>", { noremap = true })

vim.keymap.set("i", "<Up>", "<C-o>:resize +3<CR>", { noremap = true })
vim.keymap.set("i", "<Down>", "<C-o>:resize -3<CR>", { noremap = true })
vim.keymap.set("i", "<Right>", "<C-o>:vertical resize +3<CR>", { noremap = true })
vim.keymap.set("i", "<Left>", "<C-o>:vertical resize -3<CR>", { noremap = true })

-- move visual block up and down
vim.keymap.set("x", "J", ":move '>+1<CR>gv-gv", { noremap = true })
vim.keymap.set("x", "K", ":move '<-2<CR>gv-gv", { noremap = true })

-- move split into own tab
vim.keymap.set("n", "<BSlash><BSlash>", "<C-W>T", { noremap = true })

-- move split to the left
vim.keymap.set("n", "<BSlash>wh", ":wincmd H<CR>", { noremap = true })
vim.keymap.set("n", "<BSlash>wl", ":wincmd L<CR>", { noremap = true })

-- leap
vim.keymap.set("n", "s", "<Plug>(leap-forward)", { noremap = true })
vim.keymap.set("n", "S", "<Plug>(leap-backward)", { noremap = true })

-- neogit
vim.keymap.set("n", "<leader>hn", ":Neogit<CR>", { noremap = true })

-- fold all indented
vim.keymap.set("n", "zz", ":set fdm=indent<CR>", { noremap = true })

-- todo
vim.keymap.set("n", "<space>u", ":tabdo e<CR>", { noremap = true })
-- vim.keymap.set('n', '<space>e', ':ALEDetail<CR>', {noremap = true})

-- close quickfix
-- vim.keymap.set('n', '<space><space>q', ':cclose<CR>', {noremap = true})

function interop(str)
	local outer_env = _ENV
	return (
		str:gsub("%b{}", function(block)
			local code = block:match("{(.*)}")
			local exp_env = {}
			setmetatable(exp_env, {
				__index = function(_, k)
					local stack_level = 5
					while debug.getinfo(stack_level, "") ~= nil do
						local i = 1
						repeat
							local name, value = debug.getlocal(stack_level, i)
							if name == k then
								return value
							end
							i = i + 1
						until name == nil
						stack_level = stack_level + 1
					end
					return rawget(outer_env, k)
				end,
			})
			local fn, err = load("return " .. code, "expression `" .. code .. "`", "t", exp_env)
			if fn then
				return tostring(fn())
			else
				error(err, 0)
			end
		end)
	)
end

------------------
-- markdown
------------------

vim.g["mkdp_auto_start"] = 0
vim.g["mkdp_refresh_slow"] = 1
vim.g["mkdp_browser"] = "firefox"

-- delphi
------------------
-- colorscheme
------------------
vim.keymap.set("n", "<space>1", ":colorscheme OceanicNext<CR>", { noremap = true })
vim.keymap.set("n", "<space>2", ":colorscheme gruvbox<CR>", { noremap = true })
vim.keymap.set("n", "<space>3", ":colorscheme horseradish256<CR>", { noremap = true })
vim.keymap.set("n", "<space>4", ":colorscheme falcon<CR>", { noremap = true })
vim.keymap.set("n", "<space>5", ":colorscheme seoul256<CR>", { noremap = true })
vim.keymap.set("n", "<space>6", ":colorscheme Tomorrow<CR>", { noremap = true })
vim.keymap.set("n", "<space>7", ":colorscheme lightning<CR>", { noremap = true })
vim.keymap.set("n", "<space>8", ":colorscheme seoul256-light<CR>", { noremap = true })
vim.keymap.set("n", "<space>9", ":colorscheme summerfruit256<CR>", { noremap = true })
vim.keymap.set("n", "<space>0", ":colorscheme PaperColor<CR>", { noremap = true })
-- atom theme

------------------
-- navigation
------------------
vim.keymap.set("n", "<C-J>", ":TmuxNavigateDown<CR>", { noremap = true })
vim.keymap.set("n", "<C-K>", ":TmuxNavigateUp<CR>", { noremap = true })
vim.keymap.set("n", "<C-L>", ":TmuxNavigateRight<CR>", { noremap = true })
vim.keymap.set("n", "<C-H>", ":TmuxNavigateLeft<CR>", { noremap = true })

------------------
-- leap
------------------

require("leap").setup({
	case_insensitive = true,
})

----------------
-- themed-tabs
----------------

-- os.setenv("ESLINT_USE_FLAT_CONFIG", "true")
require("themed-tabs").setup({
	colorschemes = {
		"tokyonight",
		"oxocarbon",
		"PaperColor",
		"gruvbox",
	},
})

require("nvim-surround").setup()

------------------
-- git gutter
------------------

vim.g["gitgtter_signs"] = 1
vim.g["gitgutter_sign_added"] = ""
vim.g["gitgutter_sign_modified"] = ""
vim.g["gitgutter_sign_removed"] = ""
vim.g["gitgutter_sign_removed_first_line"] = ""
vim.g["gitgutter_sign_removed_above_and_below"] = ""
vim.g["gitgutter_sign_modified_removed"] = ""
vim.g["gitgutter_sign_allow_clobber"] = 0

vim.keymap.set("n", "<space>gj", ":GitGutterNextHunk<CR>", { noremap = true })
vim.keymap.set("n", "<space>gk", ":GitGutterPrevHunk<CR>", { noremap = true })

------------------
-- global subs with confirm
------------------

vim.keymap.set("n", "<space>r", [[:%s/\<<C-r><C-w>\>//gc<Left><Left><Left>]], { noremap = true })

------------------
-- tshjkl
------------------

require("tshjkl").setup({
	keymaps = {
		toggle = "<C-w>",
		toggle_outer = "<S-C-w>",

		parent = "h",
		next = "j",
		prev = "k",
		child = "l",
		toggle_named = "<S-M-n>", -- named mode skips unnamed nodes
	},
})

----------------
-- Oil
---------------
require("oil").setup()
vim.keymap.set("n", "<leader>o", function()
	require("oil").open(vim.fn.expand("%:p:h"))
end, { desc = "Open Oil at current buffer's directory" })

----------------
-- Theme
---------------
vim.cmd("colorscheme " .. os.getenv("VIM_THEME"))
----------------
-- DBUI
---------------

vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_save_location = "/home/common/Folder/db_queries"
-- TODO this belongs in completion module
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "sql", "mysql", "plsql" },
	callback = function()
		require("cmp").setup.buffer({
			sources = { {
				name = "vim-dadbod-completion",
			} },
		})
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = "dbout",
	callback = function()
		vim.opt_local.foldenable = false
	end,
})

----------------
-- Prettier
---------------
vim.g["prettier#exec_cmd_path"] = "/etc/profiles/per-user/vhs/bin/prettierd"

----------------
-- Link to Github
---------------
function GetGitHubLineLink(useMaster)
	local remote_url = vim.fn.system("git config --get remote.origin.url"):gsub("\n", "")
	if remote_url:match("^git@github.com:") then
		remote_url = remote_url:gsub("^git@github.com:", "https://github.com/")
		remote_url = remote_url:gsub("%.git$", "")
	end
	local file_path = vim.fn.system("git ls-files --full-name " .. vim.fn.expand("%:p")):gsub("\n", "")
	local branch = vim.fn.system("git rev-parse --abbrev-ref HEAD"):gsub("\n", "")
	local line_number = vim.fn.line(".")
	local github_link = string.format("%s/blob/%s/%s#L%d", remote_url, branch, file_path, line_number)

	vim.fn.setreg("+", github_link)
	print("GitHub link copied: " .. github_link)
end

vim.api.nvim_set_keymap("n", "<leader>gL", ":lua GetGitHubLineLink()<CR>", { noremap = true, silent = true })

----------------
-- Shift windows
---------------
function Rotate_windows()
	local wins = vim.fn.winnr("$")
	if wins <= 1 then
		return
	end

	local current_win = vim.fn.winnr()

	local buffers = {}
	for i = 1, wins do
		vim.cmd(i .. "wincmd w")
		buffers[i] = vim.fn.bufnr("%")
	end

	local temp = buffers[1]
	for i = 1, wins - 1 do
		vim.cmd(i .. "wincmd w")
		vim.cmd("buffer " .. buffers[i + 1])
	end

	vim.cmd(wins .. "wincmd w")
	vim.cmd("buffer " .. temp)

	local new_win = current_win - 1
	if new_win < 1 then
		new_win = wins -- Wrap around to the last window
	end

	vim.cmd(new_win .. "wincmd w")
end

vim.keymap.set("n", "<leader>V", Rotate_windows, { noremap = true, silent = true })

-- vim.cmd([[
--    profile start nvim-profile.log
--    profile func *
--    profile file *
--  ]])

vim.g.loaded_matchparen = 1

-- Gutter Context Plugin
-- Shows code context using curly braces in the gutter (line number area)
-- Similar to treesitter-context but displays in gutter instead of floating window

local gutter_context = {}

-- Configuration
local config = {
	enabled = true,
	max_depth = 3,
	min_window_height = 10,
	gutter_char_open = "{",
	gutter_char_close = "}",
}

-- State
local ns_id = vim.api.nvim_create_namespace("gutter_context")
local context_cache = {}
local last_cursor_line = 0

-- Helper function to check if treesitter is available for current buffer
local function has_treesitter()
	local ok, parsers = pcall(require, "nvim-treesitter.parsers")
	if not ok then
		return false
	end

	local lang = parsers.get_buf_lang()
	if not lang then
		return false
	end

	return parsers.has_parser(lang)
end

-- Get the root node for the current buffer
local function get_root()
	local ok, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
	if not ok then
		return nil
	end

	local parser = vim.treesitter.get_parser()
	if not parser then
		return nil
	end

	local tree = parser:parse()[1]
	return tree and tree:root()
end

-- Check if a node type should be considered for context
local function should_include_node(node)
	local node_type = node:type()

	-- Common context-worthy node types across languages
	local context_types = {
		-- Functions and methods
		"function_declaration",
		"function_definition",
		"method_declaration",
		"method_definition",
		"function",
		"arrow_function",
		"function_item",

		-- Classes and structures
		"class_declaration",
		"class_definition",
		"struct_declaration",
		"struct_definition",
		"interface_declaration",
		"trait_declaration",
		"impl_item",

		-- Control flow
		"if_statement",
		"for_statement",
		"while_statement",
		"loop_statement",
		"match_statement",
		"switch_statement",
		"try_statement",

		-- Blocks and scopes
		"block",
		"compound_statement",
		"statement_block",

		-- Modules and namespaces
		"module",
		"namespace",
		"package_declaration",

		-- Language specific
		"chunk", -- Lua
		"source_file",
		"program", -- General
	}

	for _, type in ipairs(context_types) do
		if node_type == type then
			return true
		end
	end

	return false
end

-- Get context nodes for a given line
local function get_context_nodes(line)
	local root = get_root()
	if not root then
		return {}
	end

	local contexts = {}
	local current_node = root:descendant_for_range(line, 0, line, 0)

	if not current_node then
		return {}
	end

	-- Walk up the tree to find context nodes
	local node = current_node
	local depth = 0

	while node and depth < config.max_depth do
		if should_include_node(node) then
			local start_row, start_col, end_row, end_col = node:range()

			-- Only include if the context starts before our line
			if start_row < line then
				table.insert(contexts, {
					node = node,
					start_line = start_row + 1, -- Convert to 1-based
					end_line = end_row + 1, -- Convert to 1-based
					depth = depth,
				})
				depth = depth + 1
			end
		end
		node = node:parent()
	end

	-- Reverse to get outermost context first
	local result = {}
	for i = #contexts, 1, -1 do
		table.insert(result, contexts[i])
	end

	return result
end

-- Clear all gutter signs
local function clear_gutter_signs(bufnr)
	vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
end

-- Place gutter signs for context
local function place_gutter_signs(bufnr, contexts, current_line)
	clear_gutter_signs(bufnr)

	if not contexts or #contexts == 0 then
		return
	end

	-- Track which lines already have signs to avoid duplicates
	local signed_lines = {}

	for i, context in ipairs(contexts) do
		local start_line = context.start_line
		local end_line = context.end_line

		-- Place opening brace sign
		if start_line ~= current_line and not signed_lines[start_line] then
			vim.api.nvim_buf_set_extmark(bufnr, ns_id, start_line - 1, 0, {
				sign_text = config.gutter_char_open,
				sign_hl_group = "LineNr",
				priority = 10 + i,
			})
			signed_lines[start_line] = true
		end

		-- Place closing brace sign
		if
			end_line ~= current_line
			and end_line <= vim.api.nvim_buf_line_count(bufnr)
			and not signed_lines[end_line]
		then
			vim.api.nvim_buf_set_extmark(bufnr, ns_id, end_line - 1, 0, {
				sign_text = config.gutter_char_close,
				sign_hl_group = "LineNr",
				priority = 10 + i,
			})
			signed_lines[end_line] = true
		end
	end
end

-- Main update function
local function update_context()
	if not config.enabled then
		return
	end

	local bufnr = vim.api.nvim_get_current_buf()
	local winnr = vim.api.nvim_get_current_win()

	-- Check minimum window height
	if vim.api.nvim_win_get_height(winnr) < config.min_window_height then
		clear_gutter_signs(bufnr)
		return
	end

	-- Check if treesitter is available
	if not has_treesitter() then
		clear_gutter_signs(bufnr)
		return
	end

	local cursor_line = vim.api.nvim_win_get_cursor(winnr)[1]

	-- Avoid unnecessary updates
	if cursor_line == last_cursor_line and context_cache[bufnr] then
		return
	end

	last_cursor_line = cursor_line

	-- Get context for current line
	local contexts = get_context_nodes(cursor_line - 1) -- Convert to 0-based

	-- Cache the result
	context_cache[bufnr] = contexts

	-- Update gutter signs
	place_gutter_signs(bufnr, contexts, cursor_line)
end

-- Setup autocommands
local function setup_autocommands()
	local group = vim.api.nvim_create_augroup("GutterContext", { clear = true })

	vim.api.nvim_create_autocmd({
		"CursorMoved",
		"CursorMovedI",
		"BufEnter",
		"WinEnter",
	}, {
		group = group,
		callback = function()
			vim.schedule(update_context)
		end,
	})

	vim.api.nvim_create_autocmd("BufLeave", {
		group = group,
		callback = function(args)
			clear_gutter_signs(args.buf)
			context_cache[args.buf] = nil
		end,
	})

	vim.api.nvim_create_autocmd("BufDelete", {
		group = group,
		callback = function(args)
			context_cache[args.buf] = nil
		end,
	})
end

-- Public API
function gutter_context.setup(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})
	setup_autocommands()
end

function gutter_context.enable()
	config.enabled = true
	update_context()
end

function gutter_context.disable()
	config.enabled = false
	local bufnr = vim.api.nvim_get_current_buf()
	clear_gutter_signs(bufnr)
end

function gutter_context.toggle()
	if config.enabled then
		gutter_context.disable()
	else
		gutter_context.enable()
	end
end

-- User commands
vim.api.nvim_create_user_command("GutterContextEnable", gutter_context.enable, {})
vim.api.nvim_create_user_command("GutterContextDisable", gutter_context.disable, {})
vim.api.nvim_create_user_command("GutterContextToggle", gutter_context.toggle, {})

gutter_context.setup({
	enabled = true,
	max_depth = 1,
}
)
