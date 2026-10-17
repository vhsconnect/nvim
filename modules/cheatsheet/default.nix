{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.cheatsheet;

  # Store copy of this flake's source; the build-time snapshot the index is
  # generated from and the fallback target for jump-to-source. Kept as a
  # path value (NOT toString) so derivation interpolation registers the tree
  # as a build input -- otherwise the sandbox cannot see it.
  repoRoot = ../..;

  tsv = pkgs.runCommand "cheatsheet.tsv"
    {
      nativeBuildInputs = [ pkgs.python3 ];
    }
    ''
      src=${repoRoot}
      [ -d "$src" ] || { echo "cheatsheet: source tree missing: $src" >&2; exit 1; }
      python3 ${./generate.py} "$src" > $out
    '';
in
{
  options.vim.cheatsheet = {
    enable = mkEnableOption "an fzf cheat sheet over the keymaps defined in this config (index generated at build time), plus files/grep pickers over the config repo itself";

    keymap = mkOption {
      type = types.str;
      default = "<leader>?";
      description = "Keymap that opens the cheat sheet picker.";
    };

    filesKeymap = mkOption {
      type = types.str;
      default = "<leader>fc";
      description = "Keymap that opens a file picker over the config repo.";
    };

    grepKeymap = mkOption {
      type = types.str;
      default = "<leader>fC";
      description = "Keymap that opens a live grep picker over the config repo.";
    };

    livePath = mkOption {
      type = types.str;
      default = "/home/common/SConfig/nvim";
      description = ''
        Working-tree path of this config repo, preferred for jump-to-source
        so you land in an editable file. Falls back to the store copy baked
        in at build time when this path does not exist.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = elem "fzf-lua" config.vim.startPlugins;
        message = "vim.cheatsheet: requires fzf-lua, enable vim.fzf";
      }
    ];

    vim.luaConfigRC.cheatsheet =
      nvim.dag.entryAfter [ "fzf" ] # lua
        ''
          -- cheatsheet: fzf over the keymap index generated at build time
          -- from this config repo, plus fzf files/grep over the repo itself.
          local cs = {}

          cs.store_path = "${repoRoot}"
          cs.live_path = "${cfg.livePath}"
          cs.tsv = "${tsv}"

          vim.g.cheatsheet_tsv = cs.tsv

          cs.root = function()
            if vim.fn.isdirectory(cs.live_path .. "/modules") == 1 then
              return cs.live_path
            end
            return cs.store_path
          end

          cs.rows = function()
            local rows = {}
            local f = io.open(cs.tsv, "r")
            if not f then
              return rows
            end
            for line in f:lines() do
              rows[#rows + 1] = line
            end
            f:close()
            return rows
          end

          -- Display keeps the location as the last whitespace-delimited
          -- token so the shell preview can grab it with awk $NF.
          cs.display = function(row)
            local mode, lhs, desc = row:match("^(%S*)\t(%S*)\t(.-)\t")
            if desc == "" then
              desc = "…"
            end
            return lhs .. "  [" .. mode .. "]  " .. desc .. "  │  " .. row:match("\t(%S+)$")
          end

          cs.cheat = function()
            local root = cs.root()
            local entries = {}
            for _, row in ipairs(cs.rows()) do
              entries[#entries + 1] = cs.display(row)
            end
            if #entries == 0 then
              vim.notify("cheatsheet: index is empty", vim.log.levels.WARN)
              return
            end

            local root_esc = vim.fn.shellescape(root)
            local preview = string.format(
              [[f=$(printf %%s {} | awk '{print $NF}' | cut -d: -f1); l=$(printf %%s {} | awk '{print $NF}' | cut -d: -f2); if [ -z "$l" ]; then l=1; fi; s=$(( l > 8 ? l - 8 : 1 )); [ -f %s/$f ] && sed -n "$s,$(( l + 8 ))p" %s/$f]],
              root_esc,
              root_esc
            )

            require("fzf-lua").fzf_exec(entries, {
              prompt = "Cheat sheet> ",
              fzf_opts = {
                ["--preview"] = preview,
                ["--preview-window"] = "right:60%:wrap",
                ["--header"] = "enter: open config at the definition",
              },
              actions = {
                ["enter"] = function(sel)
                  local line = sel and sel[1]
                  if not line then
                    return
                  end
                  local rel, lno = line:match("(%S+):(%d+)%s*$")
                  if not rel then
                    return
                  end
                  vim.cmd(("edit +%d %s"):format(tonumber(lno), vim.fn.fnameescape(root .. "/" .. rel)))
                end,
              },
            })
          end

          cs.files = function()
            require("fzf-lua").files({
              cwd = cs.root(),
              cmd = "rg --files --hidden --glob '!.git'",
              prompt = "Config files> ",
            })
          end

          cs.grep = function()
            require("fzf-lua").live_grep({
              cwd = cs.root(),
              prompt = "Config grep> ",
              rg_opts = "--hidden --glob '!.git' --column --line-number --no-heading --color=always --smart-case",
            })
          end

          vim.api.nvim_create_user_command("Cheat", function()
            cs.cheat()
          end, {})
          -- Old command name, kept for muscle memory.
          vim.api.nvim_create_user_command("CheatSheet", function()
            cs.cheat()
          end, {})
          vim.api.nvim_create_user_command("ConfigFiles", function()
            cs.files()
          end, {})
          vim.api.nvim_create_user_command("ConfigGrep", function()
            cs.grep()
          end, {})

          vim.keymap.set("n", "${cfg.keymap}", cs.cheat, { desc = "Cheat sheet: keymaps -> config source" })
          vim.keymap.set("n", "${cfg.filesKeymap}", cs.files, { desc = "Config: browse config repo files" })
          vim.keymap.set("n", "${cfg.grepKeymap}", cs.grep, { desc = "Config: live grep config repo" })
        '';
  };
}
