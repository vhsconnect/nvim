{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.visuals;
in
{
  options.vim.visuals = {
    enable = mkEnableOption "visual enhancements.";

    nvimWebDevicons.enable = mkEnableOption "dev icons. Required for certain plugins [nvim-web-devicons].";

    cursorWordline = {
      enable = mkEnableOption "word and delayed line highlight [nvim-cursorline].";
    };

    indentBlankline = {
      enable = mkEnableOption "indentation guides [indent-blankline].";

      listChar = mkOption {
        description = "Character for indentation line.";
        type = types.str;
        default = "│";
      };

      fillChar = mkOption {
        description = "Character to fill indents";
        type = with types; nullOr types.str;
        default = "⋅";
      };

      eolChar = mkOption {
        description = "Character at end of line";
        type = with types; nullOr types.str;
        default = "↴";
      };

      showEndOfLine = mkOption {
        description = ''
          Displays the end of line character set by <<opt-vim.visuals.indentBlankline.eolChar>> instead of the
          indent guide on line returns.
        '';
        type = types.bool;
        default = cfg.indentBlankline.eolChar != null;
        defaultText = literalExpression "config.vim.visuals.indentBlankline.eolChar != null";
      };

      showCurrContext = mkOption {
        description = "Highlight current context from treesitter";
        type = types.bool;
        default = config.vim.treesitter.enable;
        defaultText = literalExpression "config.vim.treesitter.enable";
      };

      useTreesitter = mkOption {
        description = "Use treesitter to calculate indentation when possible.";
        type = types.bool;
        default = config.vim.treesitter.enable;
        defaultText = literalExpression "config.vim.treesitter.enable";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.indentBlankline.enable {
      vim.startPlugins = [ "indent-blankline" ];
      vim.luaConfigRC.indent-blankline =
        nvim.dag.entryAnywhere # lua
          ''
            vim.opt.list = true

            ${optionalString (cfg.indentBlankline.eolChar != null) ''
              vim.opt.listchars:append({ eol = "${cfg.indentBlankline.eolChar}" })
            ''}
            ${optionalString (cfg.indentBlankline.fillChar != null) ''
              vim.opt.listchars:append({ space = "${cfg.indentBlankline.fillChar}" })
            ''}

            require("ibl").setup {
              enabled = true,
              indent = {
                char = "",
              },
              scope = {
                enabled = true,
                show_start = true,
                show_end = true,
                include = {
                  node_type = {
                    ["*"] = {
                      "class",
                      "function", 
                      "method",
                      "if_statement",
                      "for_statement",
                      "while_statement",
                      "try_statement",
                    }
                  }
                }
              }
            }


          '';
    })
    (mkIf cfg.cursorWordline.enable {
      vim.startPlugins = [ "nvim-cursorline" ];
      vim.luaConfigRC.cursorline =
        nvim.dag.entryAnywhere # lua
          ''
            require('nvim-cursorline').setup {
              cursorline = {
                enable = false,
                timeout = 1000,
                number = false,
              },
              cursorword = {
                enable = true,
                min_length = 7,
                hl = { underline = true },
              }
            }
          '';
    })
    (mkIf cfg.nvimWebDevicons.enable { vim.startPlugins = [ "nvim-web-devicons" ]; })
  ]);
}
