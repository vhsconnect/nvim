{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.fzf;

  fzfUtils = pkgs.vimUtils.buildVimPlugin {
    pname = "fzf-utils";
    version = "local";
    src = ./runtime;
    doCheck = false;
  };
in
{
  options.vim.fzf = {
    enable = mkEnableOption "Enable fzf-lua and the local fzf_utils pickers";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = [
      "fzf-lua"
      fzfUtils
    ];
    vim.luaConfigRC.fzf =
      nvim.dag.entryAnywhere # lua
        ''
          require("fzf_utils").setup()
        '';
  };
}
