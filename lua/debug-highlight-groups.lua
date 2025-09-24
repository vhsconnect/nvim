-- Highlight Group Debug Tool in Lua
-- This will log all highlight groups under cursor to a file
-- usage:
-- `:luafile <path-to-here>`
--  <:LogHighlight, :ShowHighlight, :ClearHighlightLog>

local M = {}

-- Function to get Treesitter captures at cursor
local function get_treesitter_captures()
	local captures = {}

	if not vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] then
		return { "Treesitter not active" }
	end

	local ok, result = pcall(function()
		return vim.treesitter.get_captures_at_cursor(0)
	end)

	if ok and result then
		for _, capture in ipairs(result) do
			table.insert(captures, capture)
		end
	else
		table.insert(captures, "Error getting captures")
	end

	return captures
end

-- Function to get semantic token info at cursor
local function get_semantic_tokens()
	local buf = vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row = cursor[1] - 1 -- Convert to 0-based
	local col = cursor[2]

	local ok, result = pcall(function()
		return vim.lsp.semantic_tokens.get_at_pos(buf, row, col)
	end)

	if ok and result then
		return vim.inspect(result)
	else
		return "No semantic tokens or error"
	end
end

-- Function to get traditional syntax highlighting info
local function get_syntax_info()
	local line = vim.fn.line(".")
	local col = vim.fn.col(".")

	local synid = vim.fn.synID(line, col, 1)
	local synname = vim.fn.synIDattr(synid, "name")
	local synid_trans = vim.fn.synIDtrans(synid)
	local synname_trans = vim.fn.synIDattr(synid_trans, "name")

	-- Get color attributes
	local fg = vim.fn.synIDattr(synid_trans, "fg")
	local bg = vim.fn.synIDattr(synid_trans, "bg")
	local ctermfg = vim.fn.synIDattr(synid_trans, "fg", "cterm")
	local ctermbg = vim.fn.synIDattr(synid_trans, "bg", "cterm")
	local bold = vim.fn.synIDattr(synid_trans, "bold")
	local italic = vim.fn.synIDattr(synid_trans, "italic")

	return {
		synid = synid,
		synname = synname,
		synid_trans = synid_trans,
		synname_trans = synname_trans,
		fg = fg ~= "" and fg or "NONE",
		bg = bg ~= "" and bg or "NONE",
		ctermfg = ctermfg ~= "" and ctermfg or "NONE",
		ctermbg = ctermbg ~= "" and ctermbg or "NONE",
		bold = bold == "1",
		italic = italic == "1",
	}
end

-- Function to get highlight group information using vim.api
local function get_highlight_groups()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local buf = vim.api.nvim_get_current_buf()
	local row = cursor[1] - 1
	local col = cursor[2]

	-- Get all highlight groups at this position
	local hl_groups = {}

	-- Try to get highlight ID at cursor position
	local ok, hl_id = pcall(function()
		return vim.api.nvim_get_hl_id_at_pos(0, row, col, true)
	end)

	if ok and hl_id then
		hl_groups.hl_id = hl_id
	end

	return hl_groups
end

-- Function to get inspect output (Neovim's built-in highlight inspector)
local function get_inspect_output()
	local ok, result = pcall(function()
		-- This is equivalent to running :Inspect
		return vim.inspect_pos()
	end)

	if ok and result then
		return vim.inspect(result)
	else
		return "Error getting inspect output"
	end
end

-- Main function to collect all highlight information
function M.get_highlight_info()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local line_num = cursor[1]
	local col_num = cursor[2] + 1 -- Convert to 1-based for display

	local line_content = vim.api.nvim_get_current_line()
	local char = col_num <= #line_content and line_content:sub(col_num, col_num) or "EOF"
	local word = vim.fn.expand("<cword>")

	local syntax_info = get_syntax_info()
	local ts_captures = get_treesitter_captures()
	local semantic_tokens = get_semantic_tokens()
	local hl_groups = get_highlight_groups()
	local inspect_output = get_inspect_output()

	local info = {
		"=== HIGHLIGHT DEBUG INFO ===",
		"Time: " .. os.date("%Y-%m-%d %H:%M:%S"),
		"Position: Line " .. line_num .. ", Col " .. col_num,
		"Character: '" .. char .. "'",
		"Word under cursor: " .. word,
		"",
		"--- TRADITIONAL SYNTAX HIGHLIGHTING ---",
		"Syntax ID: " .. syntax_info.synid,
		"Syntax Name: " .. syntax_info.synname,
		"Translated ID: " .. syntax_info.synid_trans,
		"Translated Name: " .. syntax_info.synname_trans,
		"",
		"--- COLOR ATTRIBUTES ---",
		"GUI FG: " .. syntax_info.fg,
		"GUI BG: " .. syntax_info.bg,
		"CTERM FG: " .. syntax_info.ctermfg,
		"CTERM BG: " .. syntax_info.ctermbg,
		"Bold: " .. (syntax_info.bold and "YES" or "NO"),
		"Italic: " .. (syntax_info.italic and "YES" or "NO"),
		"",
		"--- TREESITTER CAPTURES ---",
	}

	for _, capture in ipairs(ts_captures) do
		table.insert(info, "  - " .. capture)
	end

	table.insert(info, "")
	table.insert(info, "--- LSP SEMANTIC TOKENS ---")
	table.insert(info, semantic_tokens)
	table.insert(info, "")
	table.insert(info, "--- HIGHLIGHT GROUPS ---")
	table.insert(info, vim.inspect(hl_groups))
	table.insert(info, "")
	table.insert(info, "--- FULL INSPECT OUTPUT ---")
	table.insert(info, inspect_output)
	table.insert(info, "")
	table.insert(info, string.rep("=", 60))
	table.insert(info, "")

	return info
end

-- Function to log highlight info to file
function M.log_highlight_info()
	local logfile = vim.fn.expand("~/highlight_debug.log")
	local info = M.get_highlight_info()

	-- Append to log file
	local file = io.open(logfile, "a")
	if file then
		for _, line in ipairs(info) do
			file:write(line .. "\n")
		end
		file:close()

		-- Show confirmation
		local current_hl =
			vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.synID(vim.fn.line("."), vim.fn.col("."), 1)), "name")
		print("Highlight info logged to " .. logfile)
		print("Current highlight: " .. current_hl)
	else
		print("Error: Could not open log file " .. logfile)
	end
end

-- Function to clear the log file
function M.clear_log()
	local logfile = vim.fn.expand("~/highlight_debug.log")
	local file = io.open(logfile, "w")
	if file then
		file:close()
		print("Log file cleared: " .. logfile)
	else
		print("Error: Could not clear log file " .. logfile)
	end
end

-- Function to show highlight info in a floating window
function M.show_highlight_info()
	local info = M.get_highlight_info()
	local content = table.concat(info, "\n")

	-- Create a temporary buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, info)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")

	-- Calculate window size
	local width = math.max(60, vim.api.nvim_get_option("columns") - 20)
	local height = math.min(#info, vim.api.nvim_get_option("lines") - 10)

	-- Create floating window
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = (vim.api.nvim_get_option("columns") - width) / 2,
		row = (vim.api.nvim_get_option("lines") - height) / 2,
		border = "rounded",
		title = "Highlight Debug Info",
		title_pos = "center",
	})

	-- Set window options
	vim.api.nvim_win_set_option(win, "wrap", false)
	vim.api.nvim_win_set_option(win, "cursorline", true)

	-- Close with q or Escape
	vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>close<CR>", { noremap = true, silent = true })
end

-- Setup function to create commands and keymaps
function M.setup()
	-- Create user commands
	vim.api.nvim_create_user_command("LogHighlight", M.log_highlight_info, {})
	vim.api.nvim_create_user_command("ShowHighlight", M.show_highlight_info, {})
	vim.api.nvim_create_user_command("ClearHighlightLog", M.clear_log, {})

	-- Create keymaps
	vim.keymap.set("n", "<F12>", M.log_highlight_info, { desc = "Log highlight info to file" })
	vim.keymap.set("n", "<leader>hi", M.show_highlight_info, { desc = "Show highlight info in float" })
	vim.keymap.set("n", "<leader>hl", M.log_highlight_info, { desc = "Log highlight info to file" })

	print("Highlight debug tool loaded!")
	print("Commands: :LogHighlight, :ShowHighlight, :ClearHighlightLog")
	print("Keymaps: <F12> (log), <leader>hi (show float), <leader>hl (log)")
end

-- Auto-setup if this file is sourced
M.setup()

return M
