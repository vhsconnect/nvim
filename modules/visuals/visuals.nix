{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.visuals;
in
{
  options.vim.visuals = {
    enable = mkEnableOption "visual enhancements.";

    nvimWebDevicons.enable = mkEnableOption "dev icons. Required for certain plugins [nvim-web-devicons].";

    cursorWordline = {
      enable = mkEnableOption "word and delayed line highlight [nvim-cursorline].";
    };

    indentBlankline = {
      enable = mkEnableOption "indentation guides [indent-blankline].";
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.indentBlankline.enable {
      vim.startPlugins = [ "indent-blankline" ];
      vim.luaConfigRC.indent-blankline =
        nvim.dag.entryAnywhere # lua
          ''
            vim.opt.list = true
            require("ibl").setup {}

          '';
    })
    (mkIf cfg.cursorWordline.enable {
      vim.startPlugins = [ "nvim-cursorline" ];
      vim.luaConfigRC.cursorline =
        nvim.dag.entryAnywhere # lua
          ''
            require('nvim-cursorline').setup {
              cursorline = {
                enable = false,
                timeout = 1000,
                number = false,
              },
              cursorword = {
                enable = true,
                min_length = 7,
                hl = { underline = true },
              }
            }
          '';
    })
    (mkIf cfg.nvimWebDevicons.enable { vim.startPlugins = [ "nvim-web-devicons" ]; })
  ]);
}
