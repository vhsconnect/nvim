{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.languages.fish;

  defaultFormat = "fish_indent";
  formats = {
    fish_indent = {
      package = [ "fish" ];
      nullConfig = # lua
        ''
          table.insert(
            ls_sources,
            null_ls.builtins.formatting.fish_indent.with({
              command = "${nvim.languages.commandOptToCmd cfg.format.package "fish_indent"}",
            })
          )
        '';
    };
  };

  defaultDiagnostics = [ "fish" ];
  diagnostics = {
    fish = {
      package = pkgs.fish;
      nullConfig =
        pkg: # lua
        ''
          table.insert(
            ls_sources,
            null_ls.builtins.diagnostics.fish.with({
              command = "${pkg}/bin/fish", 
            })
          )
        '';
    };
  };
in
{
  options.vim.languages.fish = {
    enable = mkEnableOption "Fish language support";

    treesitter = {
      enable = mkOption {
        description = "Fish treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      package = nvim.options.mkGrammarOption pkgs "fish";
    };

    format = {
      enable = mkOption {
        description = "Enable Fish formatting";
        type = types.bool;
        default = config.vim.languages.enableFormat;
      };
      type = mkOption {
        description = "Fish formatter to use";
        type = with types; enum (attrNames formats);
        default = defaultFormat;
      };

      package = lib.nvim.options.mkCommandOption pkgs {
        description = "Fish formatter package.";
        inherit (formats.${cfg.format.type}) package;
      };
    };

    extraDiagnostics = {
      enable = mkOption {
        description = "Enable extra Fish diagnostics";
        type = types.bool;
        default = config.vim.languages.enableExtraDiagnostics;
      };
      types = lib.nvim.options.mkDiagnosticsOption {
        langDesc = "Fish";
        inherit diagnostics;
        inherit defaultDiagnostics;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [ cfg.treesitter.package ];
    })

    (mkIf cfg.format.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources.fish-format = formats.${cfg.format.type}.nullConfig;
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources = lib.nvim.languages.diagnosticsToLua {
        lang = "fish";
        config = cfg.extraDiagnostics.types;
        inherit diagnostics;
      };
    })
  ]);
}
