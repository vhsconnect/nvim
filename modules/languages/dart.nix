{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.languages.dart;

  defaultServer = "dartls";
  servers = {
    dartls = {
      package = "dart";
      lspConfig = # lua
        ''
          vim.lsp.enable("dartls", {
            capabilities = capabilities,
            on_attach = attach_keymaps,
            cmd = {"${nvim.languages.commandOptToCmd cfg.lsp.package "dart"}", "language-server", "--protocol=lsp"},
          }) 
        '';
    };
  };

  # TODO: specify packages
  defaultFormat = "dart_format";
  formats = {
    dart_format = {
      package = "dart";
      nullConfig = # lua
        ''
          table.insert(
            ls_sources,
            null_ls.builtins.formatting.dart_format.with({
              command = "${nvim.languages.commandOptToCmd cfg.format.package "dart"}",
              args = { "format" },
            })
          )
        '';
    };
  };

in
{
  options.vim.languages.dart = {
    enable = mkEnableOption "Dart language support";

    treesitter = {
      enable = mkOption {
        description = "Enable treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      dart = nvim.options.mkGrammarOption pkgs "dart";
    };

    lsp = {
      enable = mkOption {
        description = "Enable Dart LSP support";
        type = types.bool;
        default = config.vim.languages.enableLSP;
      };
      server = mkOption {
        description = "Dart LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };
      package = nvim.options.mkCommandOption pkgs {
        description = "Dart LSP server";
        inherit (servers.${cfg.lsp.server}) package;
      };
    };

    format = {
      enable = mkOption {
        description = "Enable Dart formatting";
        type = types.bool;
        default = config.vim.languages.enableFormat;
      };
      type = mkOption {
        description = "Dart formatter to use";
        type = with types; enum (attrNames formats);
        default = defaultFormat;
      };
      package = nvim.options.mkCommandOption pkgs {
        description = "Dart formatter";
        inherit (formats.${cfg.format.type}) package;
      };
    };

  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [
        cfg.treesitter.dart
      ];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.dart-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf cfg.format.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources.dart-format = # lua
        ''
          vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = {'*.dart'},
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format()
            end
            })
        '';
    })

  ]);
}
