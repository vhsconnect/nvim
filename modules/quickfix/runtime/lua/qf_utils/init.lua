local M = {}

-- snapshots of removed-from lists, keyed by quickfix list id (ids are global across qf and loclists)
local undo_stacks = {}

local function list_for(win)
	win = win == 0 and vim.api.nvim_get_current_win() or win
	if vim.fn.getwininfo(win)[1].loclist == 1 then
		return {
			get = function(what)
				return vim.fn.getloclist(win, what)
			end,
			set = function(what)
				return vim.fn.setloclist(win, {}, "r", what)
			end,
			older = "lolder",
			newer = "lnewer",
			filter = "Lfilter",
		}
	end
	return {
		get = function(what)
			return vim.fn.getqflist(what)
		end,
		set = function(what)
			return vim.fn.setqflist({}, "r", what)
		end,
		older = "colder",
		newer = "cnewer",
		filter = "Cfilter",
	}
end

local function shifted_idx(idx, first, last, remaining)
	if idx > last then
		idx = idx - (last - first + 1)
	elseif idx >= first then
		idx = first
	end
	return math.max(1, math.min(idx, remaining))
end

local function apply(win, list, items, idx, cursor)
	list.set({ items = items, idx = idx })
	vim.api.nvim_win_set_cursor(win, { math.max(1, math.min(cursor, #items)), 0 })
end

M.remove = function(win, first, last)
	local list = list_for(win)
	local state = list.get({ id = 0, idx = 0, items = 0 })
	local items = state.items
	if #items == 0 then
		return
	end
	first, last = math.min(first, last), math.min(math.max(first, last), #items)

	undo_stacks[state.id] = undo_stacks[state.id] or {}
	table.insert(undo_stacks[state.id], { items = vim.deepcopy(items), idx = state.idx, cursor = first })

	for _ = first, last do
		table.remove(items, first)
	end
	apply(win, list, items, shifted_idx(state.idx, first, last, #items), first)
end

M.undo = function(win)
	local list = list_for(win)
	local stack = undo_stacks[list.get({ id = 0 }).id]
	local snapshot = stack and table.remove(stack)
	if not snapshot then
		vim.notify("qf: nothing to undo", vim.log.levels.INFO)
		return
	end
	apply(win, list, snapshot.items, snapshot.idx, snapshot.cursor)
end

M.history = function(win, direction)
	local list = list_for(win)
	local ok, err = pcall(vim.cmd, list[direction])
	if not ok then
		vim.notify(err:gsub("^.-:%s*E%d+: ", ""), vim.log.levels.INFO)
	end
end

M.filter = function(win, bang)
	local list = list_for(win)
	vim.ui.input({ prompt = bang and "Drop matching: " or "Keep matching: " }, function(pattern)
		if pattern and pattern ~= "" then
			vim.cmd(("%s%s %s"):format(list.filter, bang and "!" or "", pattern))
		end
	end)
end

M.toggle = function()
	local open = vim.iter(vim.fn.getwininfo()):any(function(info)
		return info.quickfix == 1 and info.loclist == 0
	end)
	vim.cmd(open and "cclose" or "copen")
end

M.attach = function(buf)
	local function map(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buffer = buf, nowait = true, desc = "Quickfix: " .. desc })
	end

	map("n", "dd", function()
		local line = vim.fn.line(".")
		M.remove(0, line, line + vim.v.count1 - 1)
	end, "remove entry")
	map("x", "d", function()
		local first, last = vim.fn.line("v"), vim.fn.line(".")
		vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
		M.remove(0, first, last)
	end, "remove selected entries")
	map("n", "u", function()
		M.undo(0)
	end, "undo removal")
	map("n", "<", function()
		M.history(0, "older")
	end, "older list")
	map("n", ">", function()
		M.history(0, "newer")
	end, "newer list")
	map("n", "zk", function()
		M.filter(0, false)
	end, "keep entries matching pattern")
	map("n", "zd", function()
		M.filter(0, true)
	end, "drop entries matching pattern")
end

M.setup = function()
	vim.cmd.packadd("cfilter")
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("qf_utils", {}),
		pattern = "qf",
		callback = function(ev)
			M.attach(ev.buf)
		end,
	})
	vim.keymap.set("n", "<leader>qq", M.toggle, { desc = "Quickfix: toggle" })
end

return M
