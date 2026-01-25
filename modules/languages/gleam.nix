{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.languages.gleam;

  defaultServer = "gleam-language-server";
  servers = {
    gleam-language-server = {
      package = [ "gleam" ];

      lspConfig = # lua
        ''
          vim.lsp.enable("gleam", {
            capabilities = capabilities;
            on_attach = attach_keymaps,
            cmd = {"${nvim.languages.commandOptToCmd cfg.lsp.package "gleam"}", "lsp"};
          })
        '';
    };
  };

  defaultFormat = "gleam_format";
  formats = {
    gleam_format = {
      package = [ "gleam" ];
      nullConfig =
        # lua
        ''
          table.insert(
            ls_sources,
            null_ls.builtins.formatting.gleam_format.with({
              command = {"${nvim.languages.commandOptToCmd cfg.format.package "gleam"}"},
              args =  {"format", "--stdin"}
            })
          )
        '';
    };
  };

in
{
  options.vim.languages.gleam = {
    enable = mkEnableOption "Gleam language support";

    lsp = {
      enable = mkOption {
        description = "Enable Gleam LSP support";
        type = types.bool;
        default = config.vim.languages.enableLSP;
      };
      server = mkOption {
        description = "Gleam LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };
      package = nvim.options.mkCommandOption pkgs {
        description = "Gleam LSP server";
        inherit (servers.${cfg.lsp.server}) package;
      };
    };

    format = {
      enable = mkOption {
        description = "Enable Gleam formatting";
        type = types.bool;
        default = config.vim.languages.enableFormat;
      };
      type = mkOption {
        description = "Gleam formatter to use";
        type = with types; enum (attrNames formats);
        default = defaultFormat;
      };
      package = nvim.options.mkCommandOption pkgs {
        description = "Gleam formatter package";
        inherit (formats.${cfg.format.type}) package;
      };
    };

    treesitter = {
      enable = mkOption {
        description = "Enable Gleam treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      package = nvim.options.mkGrammarOption pkgs "gleam";
    };
  };

  config = mkIf cfg.enable (mkMerge [

    (mkIf (cfg.format.enable) {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources.gleam_format = formats.${cfg.format.type}.nullConfig;
    })

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [ cfg.treesitter.package ];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.gleam-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
