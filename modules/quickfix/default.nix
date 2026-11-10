{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.quickfix;

  qfUtils = pkgs.vimUtils.buildVimPlugin {
    pname = "qf-utils";
    version = "local";
    src = ./runtime;
    doCheck = false;
  };
in
{
  options.vim.quickfix = {
    enable = mkEnableOption "quickfix/location list editing: remove, undo, filter, history";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = [ qfUtils ];
    vim.luaConfigRC.quickfix =
      nvim.dag.entryAnywhere # lua
        ''
          require("qf_utils").setup()
        '';
  };
}
