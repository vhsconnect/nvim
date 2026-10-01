local M = {}

M.setup = function()
	vim.keymap.set("n", "<leader>qd", function()
		require("fzf_utils.git_diff_qf").pick()
	end, { desc = "Quickfix: files changed since commit" })
end

return M
