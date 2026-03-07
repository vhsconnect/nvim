{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.languages.fennel;
in

let

  defaultServer = "fennel-ls";
  servers = {
    fennel-ls = {
      package = [
        "fennel-ls"
      ];
      lspConfig = # lua
        ''
          vim.lsp.enable("fennel_ls", {
            capabilities = capabilities;
            on_attach = attach_keymaps,
            cmd = {"${nvim.languages.commandOptToCmd cfg.lsp.package "fennel-ls"}" },
          })
        '';
    };
  };

  defaultFormat = "fnlfmt";
  formats = {
    fnlfmt = {
      package = [
        "fnlfmt"
      ];
      nullConfig = # lua
        ''
          table.insert(
            ls_sources,
            null_ls.builtins.formatting.fnlfmt.with({
               command = "${nvim.languages.commandOptToCmd cfg.format.package "fnlfmt"}",
            })
          )
        '';
    };
  };

in

{
  options.vim.languages.fennel = {
    enable = mkEnableOption "Fennel language support";

    treesitter = {
      enable = mkOption {
        description = "Enable Fennel treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      package = nvim.options.mkGrammarOption pkgs "fennel";
    };

    format = {
      enable = mkOption {
        description = "Enable Fennel formatting";
        type = types.bool;
        default = config.vim.languages.enableFormat;
      };
      type = mkOption {
        description = "Fennel formatter to use";
        type = with types; enum (attrNames formats);
        default = defaultFormat;
      };
      package = nvim.options.mkCommandOption pkgs {
        description = "Fennel formatter";
        inherit (formats.${cfg.format.type}) package;
      };
    };

    lsp = {
      enable = mkOption {
        description = "Enable Fennel LSP support";
        type = types.bool;
        default = config.vim.languages.enableLSP;
      };
      server = mkOption {
        description = "Fennel LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };
      package = nvim.options.mkCommandOption pkgs {
        description = "Fennel LSP server";
        inherit (servers.${cfg.lsp.server}) package;
      };
    };

  };

  config = mkIf cfg.enable (mkMerge [

    (mkIf cfg.format.enable {
      vim.startPlugins = [ pkgs.fnlfmt ];
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources.fnlfmt = formats.${cfg.format.type}.nullConfig;

    })
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [ cfg.treesitter.package ];
    })
    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.fennel-ls = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
