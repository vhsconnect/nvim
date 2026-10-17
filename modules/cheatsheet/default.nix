{
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.cheatsheet;

  # Store copy of this flake's source; fallback for repo browsing when the
  # working tree is absent. Kept as a path value (NOT toString) so
  # derivation interpolation registers the tree as a build input --
  # otherwise the sandbox cannot see it.
  repoRoot = ../..;
in
{
  options.vim.cheatsheet = {
    enable = mkEnableOption "fzf files/grep pickers over this config repo";

    filesKeymap = mkOption {
      type = types.str;
      default = "<leader>?";
      description = "Keymap that opens a file picker over the config repo.";
    };

    grepKeymap = mkOption {
      type = types.str;
      default = "<leader>??";
      description = "Keymap that opens a live grep picker over the config repo.";
    };

    livePath = mkOption {
      type = types.str;
      default = "/home/common/SConfig/nvim";
      description = ''
        Working-tree path of this config repo, preferred so results land
        in editable files. Falls back to the store copy baked in at build
        time when this path does not exist.
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
          -- config pickers: fzf files / live grep over this config repo,
          -- preferring the working tree so results are editable.
          local cs = {}

          cs.store_path = "${repoRoot}"
          cs.live_path = "${cfg.livePath}"

          cs.root = function()
            if vim.fn.isdirectory(cs.live_path .. "/modules") == 1 then
              return cs.live_path
            end
            return cs.store_path
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

          vim.api.nvim_create_user_command("ConfigFiles", function()
            cs.files()
          end, {})
          vim.api.nvim_create_user_command("ConfigGrep", function()
            cs.grep()
          end, {})

          vim.keymap.set("n", "${cfg.filesKeymap}", cs.files, { desc = "Config: browse config repo files" })
          vim.keymap.set("n", "${cfg.grepKeymap}", cs.grep, { desc = "Config: live grep config repo" })
        '';
  };
}
