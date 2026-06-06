{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.treesitter;
  usingNvimCmp = config.vim.autocomplete.enable && config.vim.autocomplete.type == "nvim-cmp";
in
{
  options.vim.treesitter = {
    enable = mkEnableOption "treesitter, also enabled automatically through language options";

    fold = mkEnableOption "fold with treesitter";

    highlight = mkOption {
      description = "Enable treesitter highlighting via vim.treesitter.start";
      type = types.bool;
      default = true;
    };

    grammars = mkOption {
      type = with types; listOf package;
      default = [ ];
      description = ''
        List of treesitter grammars to install. For supported languages
        use the `vim.languages.<language>.treesitter.enable` option
      '';
    };
  };

  config = mkIf cfg.enable {
    vim = {
      startPlugins = [ "nvim-treesitter" ] ++ optional usingNvimCmp "cmp-treesitter";

      autocomplete.sources = [
        #{
        # "treesitter" = null;
        #}
      ];

      configRC.treesitter-fold = mkIf cfg.fold (
        nvim.dag.entryBefore [ "basic" ] ''
          set foldmethod=expr
          set foldexpr=v:lua.vim.treesitter.foldexpr()
          set nofoldenable
        ''
      );

      luaConfigRC.treesitter-highlight = mkIf cfg.highlight (
        nvim.dag.entryAnywhere # lua
          ''
            vim.api.nvim_create_autocmd("FileType", {
              callback = function()
                pcall(vim.treesitter.start)
              end,
            })
          ''
      );

      luaConfigRC.treesitter-selection =
        nvim.dag.entryAfter [ "treesitter-highlight" ] # lua
          ''
            require('nvim-treesitter').setup {
              incremental_selection = {
                enable = true,
                keymaps = {
                  init_selection = "gnn",
                  node_incremental = "<leader>]",
                  scope_incremental = "<leader><leader>]",
                  node_decremental = "<leader>[",
                },
              },
            }
          '';
    };
  };
}
