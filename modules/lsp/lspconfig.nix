{ config, lib, ... }:
with lib;
with builtins;
let
  cfg = config.vim.lsp;
in
{
  options.vim.lsp.lspconfig = {
    enable = mkEnableOption "nvim-lspconfig, also enabled automatically";

    sources = mkOption {
      description = "nvim-lspconfig sources";
      type = with types; attrsOf str;
      default = { };
    };
  };

  config = mkIf cfg.lspconfig.enable (mkMerge [
    {
      vim = {
        lsp.enable = true;

        startPlugins = [ "nvim-lspconfig" ];

        luaConfigRC.lspconfig =
          nvim.dag.entryAfter [ "lsp-setup" ] # lua
            ''
              local lspconfig = require('lspconfig')
            '';
      };
    }
    {
      vim.luaConfigRC = mapAttrs (_: v: (nvim.dag.entryAfter [ "lspconfig" ] v)) cfg.lspconfig.sources;
    }
  ]);
}
