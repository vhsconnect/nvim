{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.vim.winshift;
in
{
  options.vim.winshift = {
    enable = mkEnableOption "winshift.nvim (rearrange windows interactively)";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = [ "winshift" ];
    vim.luaConfigRC.winshift =
      nvim.dag.entryAnywhere # lua
        ''
          require("winshift").setup({
            highlight_moving_win = true,
            focused_hl_group = "Visual",
            moving_win_options = {
              wrap = false,
              cursorline = false,
              cursorcolumn = false,
              colorcolumn = "",
            },
          })

          vim.keymap.set("n", "<BSlash>wm", "<Cmd>WinShift<CR>", { desc = "WinShift: move window" })
          vim.keymap.set("n", "<BSlash>ws", "<Cmd>WinShift swap<CR>", { desc = "WinShift: swap window" })
        '';
  };
}
