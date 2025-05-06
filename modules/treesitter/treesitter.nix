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

    highlight = mkEnableOption "highlight with treesitter";

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

      # For some reason treesitter highlighting does not work on start if this is set before syntax on
      configRC.treesitter-fold = mkIf cfg.fold (
        nvim.dag.entryBefore [ "basic" ] ''
          set foldmethod=expr
          set foldexpr=nvim_treesitter#foldexpr()
          set nofoldenable
        ''
      );

      luaConfigRC.treesitter =
        nvim.dag.entryAnywhere # lua
          ''
            require'nvim-treesitter.configs'.setup {
              highlight = {
                enable = ${if cfg.highlight then "true" else "false"},
                disable = {},
              },

              auto_install = false,
              ignore_install = {"all"},
              ensure_installed = {},

              incremental_selection = {
                enable = true,
                keymaps = {
                  init_selection = "gnn",
                  node_incremental = "<leader>]",
                  scope_incremental = "<leader><leader>]",
                  node_decremental = "<leader>[",
                },
              },

              injection = {
                enable = true,
              },
            }
          '';
    };
  };
}
