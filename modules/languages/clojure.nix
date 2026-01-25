{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.languages.clojure;
in

let

  defaultServer = "clojure-lsp";
  servers = {
    clojure-lsp = {
      package = [
        "clojure-lsp"
      ];
      lspConfig = # lua
        ''
          vim.lsp.enable("clojure_lsp", {
            capabilities = capabilities;
            on_attach = attach_keymaps,
            cmd = {"${nvim.languages.commandOptToCmd cfg.lsp.package "clojure-lsp"}" },
          })
        '';
    };
  };

  defaultFormat = "cljfmt";
  formats = {
    cljfmt = {
      package = [
        "cljfmt"
      ];
      nullConfig = # lua
        ''
          table.insert(
            ls_sources,
            null_ls.builtins.formatting.cljfmt.with({
               command = "${nvim.languages.commandOptToCmd cfg.format.package "cljfmt"}",
            })
          )
        '';
    };
    zprint = {
      package = [
        "zprint"
      ];
      nullConfig = # lua
        ''
          table.insert(
            ls_sources,
            null_ls.builtins.formatting.zprint.with({
               command = "${nvim.languages.commandOptToCmd cfg.format.package "zprint"}",
            })
          )
        '';
    };
  };

  defaultDiagnostics = [ "clj-kondo" ];
  diagnostics = {
    clj-kondo = {
      package = pkgs.clj-kondo;
      nullConfig =
        pkg: # lua
        ''
          table.insert(
            ls_sources,
            null_ls.builtins.diagnostics.clj_kondo.with({
              command = "${pkg}/bin/clj-kondo", 
            })
          )
        '';
    };
  };

in

{
  options.vim.languages.clojure = {
    enable = mkEnableOption "Clojure language support";

    treesitter = {
      enable = mkOption {
        description = "Enable Clojure treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      package = nvim.options.mkGrammarOption pkgs "clojure";
    };

    extraDiagnostics = {
      enable = mkOption {
        description = "Enable extra Clojure diagnostics";
        type = types.bool;
        default = config.vim.languages.enableExtraDiagnostics;
      };
      types = nvim.options.mkDiagnosticsOption {
        langDesc = "Clojure";
        inherit diagnostics;
        inherit defaultDiagnostics;
      };
    };

    format = {
      enable = mkOption {
        description = "Enable Clojure formatting";
        type = types.bool;
        default = config.vim.languages.enableFormat;
      };
      type = mkOption {
        description = "Clojure formatter to use";
        type = with types; enum (attrNames formats);
        default = defaultFormat;
      };
      package = nvim.options.mkCommandOption pkgs {
        description = "Clojure formatter";
        inherit (formats.${cfg.format.type}) package;
      };
    };

    lsp = {
      enable = mkOption {
        description = "Enable Clojure LSP support";
        type = types.bool;
        default = config.vim.languages.enableLSP;
      };
      server = mkOption {
        description = "Clojure LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };
      package = nvim.options.mkCommandOption pkgs {
        description = "Clojure LSP server";
        inherit (servers.${cfg.lsp.server}) package;
      };
    };

  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.extraDiagnostics.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources = lib.nvim.languages.diagnosticsToLua {
        lang = "clojure";
        config = cfg.extraDiagnostics.types;
        inherit diagnostics;
      };
    })

    (mkIf cfg.format.enable {
      vim.startPlugins = [ pkgs.zprint ];
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources.zprint = formats.${cfg.format.type}.nullConfig;

    })
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [ cfg.treesitter.package ];
    })
    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.clojure-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
