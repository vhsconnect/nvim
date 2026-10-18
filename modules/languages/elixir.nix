{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.languages.elixir;

  defaultServer = "elixir-ls";
  servers = {
    elixir-ls = {
      package = [ "elixir-ls" ];
      lspConfig = # lua
        ''
          vim.lsp.config("elixirls", {
            capabilities = capabilities,
            on_attach = attach_keymaps,
            cmd = {"${nvim.languages.commandOptToCmd cfg.lsp.package "elixir-ls"}"},
          })
          vim.lsp.enable("elixirls")
        '';
    };
  };

  defaultFormat = "mix_format";
  formats = {
    mix_format = {
      package = [ "elixir" ];
      nullConfig = # lua
        ''
          table.insert(
            ls_sources,
            null_ls.builtins.formatting.mix.with({
              command = "${nvim.languages.commandOptToCmd cfg.format.package "mix"}",
              runtime_condition = ${nvim.languages.rootCondition [ "mix.exs" ]},
            })
          )
        '';
    };
  };
in
{
  options.vim.languages.elixir = {
    enable = mkEnableOption "Elixir language support";

    treesitter = {
      enable = mkOption {
        description = "Enable Elixir treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      package = nvim.options.mkGrammarOption pkgs "elixir";
    };

    lsp = {
      enable = mkOption {
        description = "Enable Elixir LSP support";
        type = types.bool;
        default = config.vim.languages.enableLSP;
      };
      server = mkOption {
        description = "Elixir LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };
      package = nvim.options.mkCommandOption pkgs {
        description = "Elixir LSP server";
        inherit (servers.${cfg.lsp.server}) package;
      };
    };

    format = {
      enable = mkOption {
        description = "Enable Elixir formatting";
        type = types.bool;
        default = config.vim.languages.enableFormat;
      };
      type = mkOption {
        description = "Elixir formatter to use";
        type = with types; enum (attrNames formats);
        default = defaultFormat;
      };
      package = nvim.options.mkCommandOption pkgs {
        description = "Elixir formatter package";
        inherit (formats.${cfg.format.type}) package;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [ cfg.treesitter.package ];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.elixir-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf cfg.format.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources.elixir-format = formats.${cfg.format.type}.nullConfig;
    })
  ]);
}
