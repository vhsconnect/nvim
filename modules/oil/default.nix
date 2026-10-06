{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.oil;
in
{
  options.vim = {
    oil = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "enable oil.nvim (file manager that edits the filesystem like a buffer)";
      };
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = [ "oil" ];

    vim.luaConfigRC.oil =
      nvim.dag.entryAnywhere # lua
        ''
          require("oil").setup()

          vim.keymap.set("n", "<leader>o", function()
            require("oil").open(vim.fn.expand("%:p:h"))
          end, { desc = "Open Oil at current buffer's directory" })
        '';
  };
}
