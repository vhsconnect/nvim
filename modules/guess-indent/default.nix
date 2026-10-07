{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.vim.guessIndent;
in
{
  options.vim.guessIndent = {
    enable = mkEnableOption "detect indentation from the buffer contents";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = [ "guess-indent" ];
    vim.luaConfigRC.guess-indent =
      nvim.dag.entryAnywhere # lua
        ''
          require("guess-indent").setup({})
        '';
  };
}
