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
vim.keymap.set("n", "<space>5", ":colorscheme duotone-darksea<CR>", { noremap = true })
vim.keymap.set("n", "<space>6", ":colorscheme Tomorrow<CR>", { noremap = true })
vim.keymap.set("n", "<space>7", ":colorscheme lightning<CR>", { noremap = true })
vim.keymap.set("n", "<space>8", ":colorscheme LightDefault<CR>", { noremap = true })
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

require("themed-tabs").setup({
	colorschemes = {
		"horseradish256",
		"oxocarbon",
		"PaperColor",
		"tokyonight",
	},
})

require("scope-gutter").setup({
	enabled = true,
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

-----------
--- Clojure / Conjure
------------
vim.g["conjure#mapping#enable_defaults"] = true
vim.g["conjure#mapping#doc_word"] = false
vim.g["conjure#mapping#prefix"] = "<leader>c"
vim.g["conjure#mapping#eval_current_form"] = "c"
vim.g["conjure#mapping#eval_buf"] = "f"
-- vim.g["conjure#mapping#log_split"] = "s"
-- vim.g["conjure#mapping#log_vsplit"] = "v"
--
vim.filetype.add({
	extension = {
		cljd = "clojure",
	},
})

----------------
-- Debugging
---------------

-- vim.cmd([[
--    profile start nvim-profile.log
--    profile func *
--    profile file *
--  ]])
