{ config, lib, ... }:
with lib;
with builtins;
let
  cfg = config.vim.lsp;
in
{
  options.vim.lsp = {
    lspsaga = {
      enable = mkEnableOption "LSP Saga";
    };
  };

  config = mkIf (cfg.enable && cfg.lspsaga.enable) {
    vim.startPlugins = [ "lspsaga" ];
    vim.vnoremap = {
      "<silent><leader>ca" = ":<C-U>lua require('lspsaga.codeaction').range_code_action()<CR>";
    };

    vim.tnoremap = {
      "<silent><C-q>" = "<cmd>Lspsaga term_toggle<cr>";
    };
    vim.nnoremap =
      {
        "<silent><leader>lf" = "<cmd>Lspsaga finder<cr>";
        "<silent><C-q>" = "<cmd>Lspsaga term_toggle<cr>";
        "<silent><leader>li" = "<cmd>Lspsaga incomming_calls<cr>";
        "<silent><leader>lo>" = "<cmd>Lspsaga outgoing_calls<cr>";
      }
      // (
        if (!cfg.nvimCodeActionMenu.enable) then
          { "<silent><leader>ca" = "<cmd>lua require('lspsaga.codeaction').code_action()<CR>"; }
        else
          { }
      )
      // (
        if (!cfg.lspSignature.enable) then
          { "<silent><leader>ls" = "<cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>"; }
        else
          { }
      );

    vim.luaConfigRC.lspsage =
      nvim.dag.entryAnywhere # lua
        ''
          -- Enable lspsaga
          local saga = require 'lspsaga'.setup({ 
            lightbulb = { enable = false }
          })
        '';
  };
}
