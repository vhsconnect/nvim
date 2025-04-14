{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.copilot;
in
{
  options.vim.copilot = {
    enable = mkEnableOption "Enable copilot-vim";
    config = mkOption {
      description = "copilot-vim configuration see";
      type = with types; nullOr lines;
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = [
      "copilot-vim"
      "copilot-chat-nvim"
    ];
    vim.luaConfigRC.copilot =
      nvim.dag.entryAnywhere # lua
        ''
          vim.g.copilot_enabled = false
          require("CopilotChat").setup{}
        '';
  };
}
