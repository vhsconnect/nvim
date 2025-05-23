{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.languages.ts;

  defaultServer = "ts_ls";
  servers = {
    ts_ls = {
      package = [
        "nodePackages"
        "typescript-language-server"
      ];
      lspConfig = # lua
        ''
          lspconfig.ts_ls.setup {
            capabilities = capabilities;
            on_attach = attach_keymaps,
            cmd = {"${nvim.languages.commandOptToCmd cfg.lsp.package "typescript-language-server"}", "--stdio"},
          }
        '';
    };
  };

  # TODO: specify packages
  defaultFormat = "prettier";
  formats = {
    prettier = {
      package = [
        "nodePackages"
        "prettier"
      ];
      nullConfig = # lua
        ''
          table.insert(
            ls_sources,
            null_ls.builtins.formatting.prettier.with({
              command = "${nvim.languages.commandOptToCmd cfg.format.package "prettier"}",
            })
          )
        '';
    };
    eslint_d = {
      package = [ "eslint_d" ];
      nullConfig = # lua
        ''
          table.insert(
            ls_sources,
            require("none-ls.formatting.eslint_d").with({
               command = "${pkgs.eslint_d}/bin/eslint_d",
            })
          )
        '';
    };
    eslint = {
      package = [ "eslint" ];
      nullConfig = # lua
        ''
          table.insert(
            ls_sources,
            require("none-ls.formatting.eslint").with({
               command = "${pkgs.eslint}/bin/eslint",
            })
          )
        '';
    };
  };

  # TODO: specify packages
  defaultDiagnostics = [ "eslint_d" ];
  diagnostics = {
    eslint_d = {
      package = pkgs.eslint_d;
      nullConfig =
        pkg: # lua
        ''
          table.insert(
            ls_sources,
            require("none-ls.diagnostics.eslint_d").with({
              command = "${pkg}/bin/eslint_d",
            })
            )
        '';
    };
    eslint = {
      package = pkgs.eslint;
      nullConfig =
        pkg: # lua
        ''
          table.insert(
            ls_sources,
            require("none-ls.diagnostics.eslint").with({
              command = "${pkg}/bin/eslint",
            })
            )
        '';
    };
  };
in
{
  options.vim.languages.ts = {
    enable = mkEnableOption "TS/JS language support";

    treesitter = {
      enable = mkOption {
        description = "Enable Typescript/Javascript treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      tsPackage = nvim.options.mkGrammarOption pkgs "typescript";
      jsPackage = nvim.options.mkGrammarOption pkgs "javascript";
    };

    lsp = {
      enable = mkOption {
        description = "Enable Typescript/Javascript LSP support";
        type = types.bool;
        default = config.vim.languages.enableLSP;
      };
      server = mkOption {
        description = "Typescript/Javascript LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };
      package = nvim.options.mkCommandOption pkgs {
        description = "Typescript/Javascript LSP server";
        inherit (servers.${cfg.lsp.server}) package;
      };
    };

    format = {
      enable = mkOption {
        description = "Enable Typescript/Javascript formatting";
        type = types.bool;
        default = config.vim.languages.enableFormat;
      };
      type = mkOption {
        description = "Typescript/Javascript formatter to use";
        type = with types; enum (attrNames formats);
        default = defaultFormat;
      };
      package = nvim.options.mkCommandOption pkgs {
        description = "Typescript/Javascript formatter";
        inherit (formats.${cfg.format.type}) package;
      };
    };

    extraDiagnostics = {
      enable = mkOption {
        description = "Enable extra Typescript/Javascript diagnostics";
        type = types.bool;
        default = config.vim.languages.enableExtraDiagnostics;
      };
      types = nvim.options.mkDiagnosticsOption {
        langDesc = "Typescript/Javascript";
        inherit diagnostics;
        inherit defaultDiagnostics;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [
        cfg.treesitter.tsPackage
        cfg.treesitter.jsPackage
      ];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.ts-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf cfg.format.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources.ts-format = formats.${cfg.format.type}.nullConfig;
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources = lib.nvim.languages.diagnosticsToLua {
        lang = "ts";
        config = cfg.extraDiagnostics.types;
        inherit diagnostics;
      };
    })
  ]);
}
