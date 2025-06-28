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

      lineTimeout = mkOption {
        description = "Time in milliseconds for cursorline to appear.";
        type = types.int;
        default = 500;
      };
    };

  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.cursorWordline.enable {
      vim.startPlugins = [ "nvim-cursorline" ];
      vim.luaConfigRC.cursorline =
        nvim.dag.entryAnywhere # lua
          ''
            vim.g.cursorline_timeout = ${toString cfg.cursorWordline.lineTimeout}
          '';
    })
    (mkIf cfg.nvimWebDevicons.enable { vim.startPlugins = [ "nvim-web-devicons" ]; })
  ]);
}
