{ pkgs
, config
, lib
, ...
}:
with lib;
with builtins; let
  cfg = config.vim.languages.haskell;

  defaultServer = "hls";
  servers = {
    hls = {
      package = [ "haskell-language-server" ];
      lspConfig = ''
        lspconfig.hls.setup {}
      '';
    };
  };

  defaultFormat = "fourmolu";
  formats = {
    fourmolu = {
      package = [ "haskellPackages" "fourmolu" ];
      nullConfig = /* lua */ ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.fourmolu.with({
             command = "${nvim.languages.commandOptToCmd cfg.format.package "fourmolu"}",
          })
        )
      '';
    };
  };


in
{
  options.vim.languages.haskell = {
    enable = mkEnableOption "Haskell language support";

    treesitter = {
      enable = mkOption {
        description = "Enable Haskell treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      package = nvim.options.mkGrammarOption pkgs "haskell";
    };

    format = {
      enable = mkOption {
        description = "Enable Haskell formatting";
        type = types.bool;
        default = config.vim.languages.enableFormat;
      };
      type = mkOption {
        description = "Haskell formatter to use";
        type = with types; enum (attrNames formats);
        default = defaultFormat;
      };
      package = nvim.options.mkCommandOption pkgs {
        description = "Haskell formatter";
        inherit (formats.${cfg.format.type}) package;
      };
    };

    lsp = {
      enable = mkOption {
        description = "Enable Haskell LSP support";
        type = types.bool;
        default = config.vim.languages.enableLSP;
      };
      server = mkOption {
        description = "Haskell LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };
      package = nvim.options.mkCommandOption pkgs {
        description = "Haskell LSP server";
        inherit (servers.${cfg.lsp.server}) package;
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
      vim.lsp.null-ls.sources.haskell-format = formats.${cfg.format.type}.nullConfig;
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.haskell-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
