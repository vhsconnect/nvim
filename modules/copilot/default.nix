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

          vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
            expr = true,
            replace_keycodes = false
          })

          vim.g.copilot_no_tab_map = true
        '';
  };
}
