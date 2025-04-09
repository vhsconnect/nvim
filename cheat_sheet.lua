function OpenCheatSheet()
	-- Define your cheat sheet content
	local content = {
		"=== Neovim Cheat Sheet ===",
		"  <leader>fs - fuzzy find symbols in document",
		"  <leader>gL - link current line to github",
		"",
	}

	-- Create a scratch buffer
	local buf = vim.api.nvim_create_buf(false, true)

	-- Set buffer content
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

	-- Set buffer options
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

	-- Calculate window size and position
	local width = 40
	local height = #content
	local win_opts = {
		relative = "editor",
		width = width,
		height = height,
		row = 1,
		col = vim.o.columns - width - 1,
		style = "minimal",
		border = "rounded",
	}

	-- Create and open the floating window
	local win = vim.api.nvim_open_win(buf, true, win_opts)

	-- Set window options
	vim.api.nvim_win_set_option(win, "wrap", false)

	-- Add keymapping to close the window
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q<CR>", { noremap = true, silent = true })
end

-- Create a command to open the cheat sheet
vim.api.nvim_create_user_command("CheatSheet", OpenCheatSheet, {})
