{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.paraedit;
in
{
  options.vim = {
    paraedit = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "enable nvim-paredit (structural editing for lisps)";
      };
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = [ "paraedit" ];

    vim.luaConfigRC.paraedit =
      nvim.dag.entryAnywhere # lua
        ''
          local paredit = require("nvim-paredit")

          local function wrap(open, close)
            return function()
              paredit.wrap.wrap_element_under_cursor(open, close)
            end
          end

          paredit.setup({
            -- Change some keys
            use_default_keys = false,
            keys = {
              ["<localleader>o"] = false,
              ["<localleader>r"] = false,
              ["<localleader>vsl"] = { paredit.api.slurp_forwards, "Slurp forwards" },
              ["<localleader>vsh"] = { paredit.api.slurp_backwards, "Slurp backwards" },
              ["<localleader>vbl"] = { paredit.api.barf_forwards, "Barf forwards" },
              ["<localleader>vbh"] = { paredit.api.barf_backwards, "Barf backwards" },
              -- ["<localleader>vrf"] = { paredit.api.raise_form, "Raise form" },
              -- ["<localleader>vre"] = { paredit.api.raise_element, "Raise element" },

              -- splice / unwrap
              ["<localleader>vj"] = { paredit.unwrap.unwrap_form_under_cursor, "Splice form" },

              -- wrap element in a matched pair (mnemonic: the delimiter you want)
              ["<localleader>vk"] = { wrap("(", ")"), "Wrap element in ()" },
              -- ["<localleader>v["] = { wrap("[", "]"),   "Wrap element in []" },
              -- ["<localleader>v{"] = { wrap("{", "}"),   "Wrap element in {}" },

              -- drag element (reorder args) -- uses > / < like vim's shift operators
              ["<localleader>vl"] = { paredit.api.drag_element_forwards, "Drag element forwards" },
              ["<localleader>vh"] = { paredit.api.drag_element_backwards, "Drag element backwards" },
            },
          })
        '';
  };
}
