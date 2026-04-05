local Job = require("plenary.job")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local actions = require("telescope.actions") -- fix #2
local action_state = require("telescope.actions.state") -- fix #2
local log = require("plenary.log")

local M = {}
local flutter_job = nil
local logger = log.new({ plugin = "flutter", level = "info" }) -- fix #3

local function notify(msg, level)
	vim.notify(msg, level or vim.log.levels.INFO, { title = "Flutter" })
end

local function parse_devices(output)
	local devices = {}
	for line in output:gmatch("[^\r\n]+") do
		local name, device_id = line:match("^%s+(.-)%s*•%s*(.-)%s*•")
		if name and device_id then
			table.insert(devices, { name = name, id = device_id })
		end
	end
	return devices
end

function M.pick_device()
	Job:new({
		command = "flutter",
		args = { "devices" },
		on_exit = function(j, code)
			vim.schedule(function()
				if code ~= 0 then
					notify("Failed to list devices", vim.log.levels.ERROR)
					return
				end
				local output = table.concat(j:result(), "\n")
				local devices = parse_devices(output)
				if #devices == 0 then
					notify("No devices found", vim.log.levels.WARN)
					return
				end
				M._show_device_picker(devices)
			end)
		end,
	}):start()
end

function M._show_device_picker(devices)
	local displayer = entry_display.create({
		separator = " ",
		items = {
			{ width = 30 },
			{ remaining = true },
		},
	})

	pickers
		.new({}, {
			prompt_title = "Flutter Devices",
			finder = finders.new_table({
				results = devices,
				entry_maker = function(entry)
					return {
						value = entry,
						display = function()
							return displayer({
								{ entry.name, "TelescopeResultsIdentifier" },
								{ entry.id, "TelescopeResultsComment" },
							})
						end,
						ordinal = entry.name .. " " .. entry.id,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, _)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					M.run(selection.value.id)
				end)
				return true
			end,
		})
		:find()
end

-- Add this helper near the top, after the notify function
local function find_flutter_root()
	local path = vim.fn.expand("%:p:h") -- directory of current buffer
	local prev = nil
	while path ~= prev do
		if vim.fn.filereadable(path .. "/pubspec.yaml") == 1 then
			return path
		end
		prev = path
		path = vim.fn.fnamemodify(path, ":h") -- go up one level
	end
	return nil
end

-- rest of file unchanged ...
function M.run(device_id)
	if flutter_job then
		notify("Flutter is already running", vim.log.levels.WARN)
		return
	end
	local args = { "run" }
	if device_id then
		table.insert(args, "-d")
		table.insert(args, device_id)
	end
	logger:info("Starting flutter with args: " .. vim.inspect(args))
	flutter_job = Job:new({
		command = "flutter",
		args = args,
		cwd = find_flutter_root(),
		on_stdout = vim.schedule_wrap(function(_, data)
			if data then
				logger:info(data)
			end
		end),
		on_stderr = vim.schedule_wrap(function(_, data)
			if data then
				logger:warn(data)
			end
		end),
		on_exit = vim.schedule_wrap(function(j, code)
			flutter_job = nil
			if code ~= 0 then
				notify("Flutter exited with code " .. tostring(code), vim.log.levels.ERROR)
			else
				notify("Flutter stopped", vim.log.levels.INFO)
			end
		end),
	})
	flutter_job:start()
	notify("Running on device: " .. (device_id or "default"))
end
function M.reload()
	if flutter_job then
		flutter_job:send("r")
		logger:info("Hot reload triggered")
	end
end
function M.restart()
	if flutter_job then
		flutter_job:send("R")
		logger:info("Hot restart triggered")
	end
end
function M.quit()
	if flutter_job then
		local pid = flutter_job.pid
		if pid then
			vim.loop.kill(pid, "sigterm")
			logger:info("Sent SIGTERM to flutter process " .. pid)
		else
			notify("Could not get Flutter process PID", vim.log.levels.WARN)
		end
		flutter_job = nil
	else
		notify("Flutter is not running", vim.log.levels.WARN)
	end
end
function M.setup(opts)
	opts = opts or {}
	if opts.hot_reload_on_save ~= false then
		vim.api.nvim_create_autocmd("BufWritePost", {
			group = vim.api.nvim_create_augroup("flutter_hot_reload", { clear = true }),
			pattern = "*.dart",
			callback = function()
				M.reload()
			end,
		})
	end
	local user_cmds = opts.commands
		or { "FlutterRun", "FlutterDevices", "FlutterReload", "FlutterRestart", "FlutterQuit" }
	if vim.tbl_contains(user_cmds, "FlutterDevices") then
		vim.api.nvim_create_user_command("FlutterDevices", function()
			M.pick_device()
		end, { desc = "Pick a Flutter device and run" })
	end
	if vim.tbl_contains(user_cmds, "FlutterRun") then
		vim.api.nvim_create_user_command("FlutterRun", function()
			M.run(opts.device_id)
		end, { desc = "Run Flutter app", nargs = "?" })
	end
	if vim.tbl_contains(user_cmds, "FlutterReload") then
		vim.api.nvim_create_user_command("FlutterReload", function()
			M.reload()
		end, { desc = "Hot reload Flutter app" })
	end
	if vim.tbl_contains(user_cmds, "FlutterRestart") then
		vim.api.nvim_create_user_command("FlutterRestart", function()
			M.restart()
		end, { desc = "Hot restart Flutter app" })
	end
	if vim.tbl_contains(user_cmds, "FlutterQuit") then
		vim.api.nvim_create_user_command("FlutterQuit", function()
			M.quit()
		end, { desc = "Quit Flutter app" })
	end
end
return M
