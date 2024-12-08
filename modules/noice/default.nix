{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.avante;
in
{
  options.vim.noice = {
    enable = mkEnableOption "Enable noice.nvim";
    config = mkOption {
      description = "noice.nvim configuration";
      type = with types; nullOr lines;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = [
      "nui-nvim"
      "nvim-notify"
      "noice"
    ];
    vim.optPlugins = [ ];
    vim.luaConfigRC.noice =
      nvim.dag.entryAnywhere # lua
        ''
          require("noice").setup({
            messages = {
              enabled = true, -- enables the Noice messages UI
              view = "mini", -- default view for messages
              view_error = "notify", -- view for errors
              view_warn = "notify", -- view for warnings
              view_history = "messages", -- view for :messages
              view_search = "virtualtext", 
            },
            lsp = {
              -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
              override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
                ["cmp.entry.get_documentation"] = true,
              },
              documentation =  { view = "hover"},
              signature = {
                enabled = true ,
                view = "hover",
              },
              hover = { 
                enabled = false
              },
            },
            -- you can enable a preset for easier configuration
            presets = {
              bottom_search = true, -- use a classic bottom cmdline for search
              command_palette = true, -- position the cmdline and popupmenu together
              long_message_to_split = true, -- long messages will be sent to a split
              inc_rename = false, -- enables an input dialog for inc-rename.nvim
              lsp_doc_border = false, -- add a border to hover docs and signature help
            },
          })

        '';
  };
}
