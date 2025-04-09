{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  treesitter = config.vim.treesitter;
  cfg = treesitter.textobjects;
in
{
  options.vim.treesitter.textobjects = {
    enable = mkEnableOption "context of current buffer contents [nvim-treesitter-context] ";
  };

  config = mkIf (treesitter.enable && cfg.enable) {
    vim.startPlugins = [ "nvim-treesitter-textobjects" ];

    vim.luaConfigRC.treesitter-textobjects = nvim.dag.entryAfter [ "nvim-treesitter" ] ''
       
      require'nvim-treesitter.configs'.setup {
        textobjects = {
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["mn"] = "@function.outer",
              ["mcn"] = "@class.outer",
            },
            goto_previous_start = {
              ["mp"] = "@function.outer",
              ["mcp"] = "@class.outer",
            }
          },
          lsp_interop = {
            enable = true,
            border = 'none',
            floating_preview_opts = {},
            peek_definition_code = {
              ["<leader>df"] = "@function.outer",
              ["<leader>dF"] = "@class.outer",
            },
          },

        },
      }

    '';
  };
}
