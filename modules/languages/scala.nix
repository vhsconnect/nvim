{ pkgs
, config
, lib
, ...
}:
with lib;
with builtins; let
  cfg = config.vim.languages.scala;
in
{
  options.vim.languages.scala = {
    enable = mkEnableOption "Scala Language Support";

    treesitter = {
      enable = mkOption {
        description = "Enable Scala treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      package = nvim.options.mkGrammarOption pkgs "scala";
    };
    lsp = {
      enable = mkOption {
        description = "Scala LSP support (metals)";
        type = types.bool;
        default = config.vim.languages.enableLSP;
      };
      # TODO: Fix the zls package styles
      package = mkOption {
        description = "Metals package";
        type = types.package;
        default = pkgs.metals;
      };
      # zigPackage = mkOption {
      #   description = "Zig package used by ZLS";
      #   type = types.package;
      #   default = pkgs.zig;
      # };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [ cfg.treesitter.package ];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.scala-lsp = /* lua */ ''
        vim.opt_global.shortmess:remove("F")
         local cmd = {"${cfg.lsp.package}/bin/metals"}
         require'lspconfig'.metals.setup {
         cmd = cmd,
         on_attach = default_on_attach
         }



      '';
    })
  ]);
}
