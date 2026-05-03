local extra = os.getenv("NVIM_EXTRA_PATH") or vim.fn.expand("~/.config/nvim-extra")
vim.opt.runtimepath:prepend(extra)
for _, file in ipairs(vim.fn.glob(extra .. "/lua/*.lua", false, true)) do
	local mod = file:match("([^/]+)%.lua$")
	if mod then
		local ok, err = pcall(require, mod)
		if not ok then
			vim.notify("Failed to load " .. mod .. ": " .. err, vim.log.levels.WARN)
		end
	end
end
