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
  options.vim.avante = {
    enable = mkEnableOption "Enable avante.nvim";
    provider = mkOption {
      description = "avante.nvim provider";
      type = types.str;
      default = "openrouter";
    };
    openrouterDefaultModel = mkOption {
      description = "avante.nvim model";
      type = with types; str;
      default = "claude-sonnet-4-20250514";
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = [
      "nui-nvim"
      "dressing"
      "render-markdown"
      "avante-nvim"
      "fzf-lua"
    ];
    vim.optPlugins = [ ];
    vim.luaConfigRC.avante =
      nvim.dag.entryAnywhere # lua
        ''
          require('render-markdown').setup ({
            opts = {
              file_types = { "markdown", "Avante" },
            },
              ft = { "markdown", "Avante" },
            })
            require('avante').setup ({
              provider = "${cfg.provider}",
              openrouter = { model = "${cfg.openrouterDefaultModel}" },
              -- claude = {
              --   endpoint = "https://api.anthropic.com",
              --   model = "claude-sonnet-4-20250514",
              --   temperature = 0,
              --   max_tokens = 4096,
              -- },

              mappings = {
                diff = {
                  ours = "co",
                  theirs = "ct",
                  all_theirs = "ca",
                  both = "cb",
                  cursor = "cc",
                  next = "]x",
                  prev = "[x",
                },
                jump = {
                  next = "]]",
                  prev = "[[",
                },
                submit = {
                  normal = "<CR>",
                  insert = "<C-s>",
                },
              },
              hints = { enabled = true },
              windows = {
                wrap = true, -- similar to vim.o.wrap
                width = 30, -- default % based on available width
                sidebar_header = {
                  align = "center", -- left, center, right for title
                  rounded = true,
                },
              },
              highlights = {
                ---@type AvanteConflictHighlights
                diff = {
                  current = "DiffText",
                  incoming = "DiffAdd",
                },
              },
              --- @class AvanteConflictUserConfig
              diff = {
                autojump = true,
                ---@type string | fun(): any
                list_opener = "copen",
              },
           })

        '';
  };
}
