{
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.snippets.querySaver;
in
{
  options.vim.snippets.querySaver = {
    enable = mkEnableOption "the query snippet saver: yank the buffer (or visual selection) into a query snippet file via an fzf picker + input prompts";

    path = mkOption {
      type = types.nullOr types.str;
      default = config.vim.snippets.luasnip.runtimePath;
      defaultText = literalExpression "config.vim.snippets.luasnip.runtimePath";
      description = ''
        Directory holding the query snippet lua files (the
        { name, tags, filetype, query } records). Defaults to the luasnip
        runtime path so both features share one location.
      '';
    };

    keymap = mkOption {
      type = types.str;
      default = "<leader>sj";
      description = "Keymap that saves the buffer (or visual selection) as a query snippet.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.path != null;
        message = "vim.snippets.querySaver: no snippet directory configured (set querySaver.path or luasnip.runtimePath)";
      }
      {
        assertion = elem "fzf-lua" config.vim.startPlugins;
        message = "vim.snippets.querySaver: requires fzf-lua, enable vim.fzf";
      }
    ];

    vim.luaConfigRC.querySaver =
      nvim.dag.entryAfter [ "luasnip" "fzf" ] # lua
      ''
        -- query-saver: capture the buffer (or visual selection) and append it
        -- as a { name, tags, filetype, query } record to a runtime snippet
        -- file. Records are hot-reloaded into luasnip on save.
        local qs = {}

        qs.dir = vim.fn.expand("${toString cfg.path}")

        local function qs_trim(s)
          return (s:gsub("^%s+", ""):gsub("%s+$", ""))
        end

        -- Query text: visual selection when invoked from visual mode,
        -- otherwise the whole buffer. Blank edge lines are dropped and the
        -- common leading indent is stripped so records stay flush-left.
        local function qs_capture()
          local srow, erow
          local m = vim.fn.mode()
          if m == "v" or m == "V" or m == "\22" then
            local a = vim.fn.getpos("v")
            local b = vim.fn.getpos(".")
            srow = math.min(a[2], b[2])
            erow = math.max(a[2], b[2])
          else
            srow = 1
            erow = vim.fn.line("$")
          end
          if erow < srow then
            return {}
          end

          local lines = vim.api.nvim_buf_get_lines(0, srow - 1, erow, false)
          while #lines > 0 and qs_trim(lines[1]) == "" do
            table.remove(lines, 1)
          end
          while #lines > 0 and qs_trim(lines[#lines]) == "" do
            table.remove(lines)
          end

          local indent = nil
          for _, l in ipairs(lines) do
            if qs_trim(l) ~= "" then
              local n = #l:match("^%s*")
              if indent == nil or n < indent then
                indent = n
              end
            end
          end
          if indent and indent > 0 then
            for i, l in ipairs(lines) do
              lines[i] = l:sub(indent + 1)
            end
          end
          return lines
        end

        local function qs_quote(s)
          return string.format("%q", s)
        end

        local function qs_split_tags(s)
          local tags = {}
          for part in string.gmatch(s or "", "[^,]+") do
            local t = qs_trim(part)
            if t ~= "" then
              tags[#tags + 1] = t
            end
          end
          return tags
        end

        -- Pick a long-bracket level that does not collide with the query
        -- text, e.g. a query containing ]] needs [==[ ]==].
        local function qs_brackets(query)
          local lvl = 0
          while query:find("]" .. string.rep("=", lvl) .. "]", 1, true) do
            lvl = lvl + 1
          end
          local pad = string.rep("=", lvl)
          return "[" .. pad .. "[", "]" .. pad .. "]"
        end

        local function qs_record_lines(rec, query_lines)
          local open_b, close_b = qs_brackets(table.concat(query_lines, "\n"))
          local lines = {
            "\t{",
            "\t\tname = " .. qs_quote(rec.name) .. ",",
          }
          if #rec.tags > 0 then
            local quoted = {}
            for _, t in ipairs(rec.tags) do
              quoted[#quoted + 1] = qs_quote(t)
            end
            lines[#lines + 1] = "\t\ttags = { " .. table.concat(quoted, ", ") .. " },"
          end
          lines[#lines + 1] = "\t\tfiletype = " .. qs_quote(rec.filetype) .. ","
          lines[#lines + 1] = "\t\tquery = " .. open_b
          for _, l in ipairs(query_lines) do
            lines[#lines + 1] = l
          end
          -- Closer stays flush-left so the long-bracket body (the query
          -- text itself) does not pick up trailing indentation.
          lines[#lines + 1] = close_b .. ","
          lines[#lines + 1] = "\t},"
          return lines
        end

        -- Splice the record in before the final closing brace of the file
        -- (records live in a plain "return { ... }" table).
        local function qs_write(path, rec_lines)
          local existing = {}
          if vim.fn.filereadable(path) == 1 then
            existing = vim.fn.readfile(path)
          end

          local at = nil
          for i = #existing, 1, -1 do
            if qs_trim(existing[i]) == "}" then
              at = i
              break
            end
          end

          local out = {}
          if at then
            for i = 1, at - 1 do
              out[#out + 1] = existing[i]
            end
            vim.list_extend(out, rec_lines)
            for i = at, #existing do
              out[#out + 1] = existing[i]
            end
          elseif #existing > 0 then
            vim.list_extend(out, existing)
            vim.list_extend(out, rec_lines)
          else
            out[#out + 1] = "return {"
            vim.list_extend(out, rec_lines)
            out[#out + 1] = "}"
          end

          vim.fn.mkdir(vim.fs.dirname(path), "p")
          vim.fn.writefile(out, path)
        end

        -- Re-register the file with luasnip using the same key format as
        -- the loader in the luasnip module, so the new snippet is live
        -- without restarting.
        local function qs_reload(path)
          local ok_ls, ls = pcall(require, "luasnip")
          if not ok_ls then
            return
          end
          local ok, records = pcall(dofile, path)
          if not ok or type(records) ~= "table" then
            return
          end
          local by_ft = {}
          for _, r in ipairs(records) do
            if r.filetype and r.query then
              local label = r.tags
                and (r.name .. "  [" .. table.concat(r.tags, ", ") .. "]")
                or r.name
              by_ft[r.filetype] = by_ft[r.filetype] or {}
              table.insert(
                by_ft[r.filetype],
                ls.parser.parse_snippet({ trig = r.name, name = r.name, dscr = label }, r.query)
              )
            end
          end
          for ft, snips in pairs(by_ft) do
            ls.add_snippets(ft, snips, { key = path .. ":" .. ft })
          end
        end

        local function qs_ask(prompt, default, cb)
          vim.ui.input({ prompt = prompt .. ": ", default = default or "" }, function(ans)
            if ans == nil then
              return
            end
            cb(qs_trim(ans))
          end)
        end

        local function qs_sanitize(name)
          name = qs_trim(name or ""):gsub("%.lua$", "")
          name = name:gsub("%s+", "-"):lower()
          return name
        end

        local function qs_collect(query_lines, file)
          qs_ask("Snippet name", "", function(name)
            if name == "" then
              vim.notify("query-saver: aborted, empty name", vim.log.levels.WARN)
              return
            end
            qs_ask("Tags (comma separated)", "", function(tags_raw)
              local default_ft = qs_trim(vim.bo.filetype)
              if default_ft == "" then
                default_ft = "sql"
              end
              qs_ask("Filetype", default_ft, function(ft)
                local rec = {
                  name = name,
                  tags = qs_split_tags(tags_raw),
                  filetype = (ft ~= "" and ft or "sql"),
                }
                qs_write(file, qs_record_lines(rec, query_lines))
                qs_reload(file)
                vim.notify(
                  "query-saver: saved " .. name .. " to " .. vim.fn.fnamemodify(file, ":t"),
                  vim.log.levels.INFO
                )
              end)
            end)
          end)
        end

        local function qs_pick(query_lines)
          local entries = {}
          for _, f in ipairs(vim.fn.globpath(qs.dir, "*.lua", false, true)) do
            entries[#entries + 1] = vim.fn.fnamemodify(f, ":t:r")
          end
          table.sort(entries)

          local function file_of(name)
            return qs.dir .. "/" .. name .. ".lua"
          end

          -- No snippet files yet: go straight to naming a new one.
          if #entries == 0 then
            qs_ask("New snippet file name", "", function(nm)
              nm = qs_sanitize(nm)
              if nm ~= "" then
                qs_collect(query_lines, file_of(nm))
              end
            end)
            return
          end

          require("fzf-lua").fzf_exec(entries, {
            prompt = "Save snippet into> ",
            fzf_opts = {
              ["--print-query"] = true,
              ["--header"] = "enter: pick file  |  ctrl-n: new file (typed name pre-fills it)",
            },
            actions = {
              ["enter"] = function(sel)
                local typed = qs_sanitize(sel[1])
                local picked = sel[2] and qs_trim(sel[2])
                if picked ~= nil and picked ~= "" then
                  qs_collect(query_lines, file_of(picked))
                elseif typed ~= "" then
                  qs_collect(query_lines, file_of(typed))
                end
              end,
              ["ctrl-n"] = function(sel)
                local typed = qs_sanitize(sel[1])
                if typed ~= "" then
                  qs_collect(query_lines, file_of(typed))
                  return
                end
                qs_ask("New snippet file name", "", function(nm)
                  nm = qs_sanitize(nm)
                  if nm ~= "" then
                    qs_collect(query_lines, file_of(nm))
                  end
                end)
              end,
            },
          })
        end

        local function qs_save()
          local query_lines = qs_capture()
          if #query_lines == 0 then
            vim.notify("query-saver: nothing to save (empty buffer or selection)", vim.log.levels.WARN)
            return
          end
          qs_pick(query_lines)
        end

        vim.keymap.set(
          { "n", "x" },
          "${cfg.keymap}",
          qs_save,
          { desc = "Save buffer/selection as query snippet" }
        )
      '';
  };
}
