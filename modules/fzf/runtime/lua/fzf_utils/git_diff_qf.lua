local M = {}

local function pr_labels_by_sha()
    if vim.fn.executable("gh") ~= 1 then
        return {}
    end
    local out = vim.fn.system({
        "gh",
        "pr",
        "list",
        "--state",
        "all",
        "--limit",
        "300",
        "--json",
        "number,title,mergeCommit,headRefOid",
    })
    if vim.v.shell_error ~= 0 then
        return {}
    end

    local labels = {}
    for _, pr in ipairs(vim.json.decode(out)) do
        local label = ("#%d %s"):format(pr.number, pr.title)
        labels[pr.headRefOid] = label
        if type(pr.mergeCommit) == "table" then
            labels[pr.mergeCommit.oid] = label
        end
    end
    return labels
end

M.to_quickfix = function(commit)
    local files = vim.fn.systemlist({ "git", "diff", commit, "--name-only", "--relative" })
    if vim.v.shell_error ~= 0 then
        vim.notify(table.concat(files, "\n"), vim.log.levels.ERROR)
        return
    end
    vim.fn.setqflist(vim.tbl_map(function(f)
        return { filename = f, lnum = 1 }
    end, files))
    vim.cmd.copen()
end

M.pick = function()
    local log = vim.fn.systemlist({ "git", "log", "-n", "300", "--format=%H%x09%h%x09%s" })
    if vim.v.shell_error ~= 0 then
        vim.notify(table.concat(log, "\n"), vim.log.levels.ERROR)
        return
    end

    local labels = pr_labels_by_sha()
    local entries = {}
    for _, line in ipairs(log) do
        local sha, short, subject = line:match("^(%S+)\t(%S+)\t(.*)$")
        local pr = labels[sha]
        table.insert(entries, pr and ("%s %s  [%s]"):format(short, subject, pr) or ("%s %s"):format(short, subject))
    end

    require("fzf-lua").fzf_exec(entries, {
        prompt = "Diff against> ",
        preview = "git show --stat --color=always {1}",
        actions = {
            ["enter"] = function(selected)
                M.to_quickfix(selected[1]:match("^%S+"))
            end,
        },
    })
end

return M
