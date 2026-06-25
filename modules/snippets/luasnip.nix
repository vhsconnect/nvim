{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.snippets.luasnip;
in
{
  options.vim.snippets.luasnip = {
    enable = mkEnableOption "Enable luasnip";

    nixPath = mkOption {
      type = types.nullOr types.path;
      default = ../../snippets;
      description = ''
        Directory of VSCode-format snippet json, copied into the nix store at
        build time. Set to null to disable the build-time source.
      '';
    };

    runtimePath = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "~/.config/nvim/snippets";
      description = ''
        Additional snippet directory read from disk at runtime (supports ~ and
        environment variables), letting you edit snippets without rebuilding.
      '';
    };
  };

  config = mkIf cfg.enable (
    let
      resolvedNixPath =
        if cfg.nixPath == null then
          null
        else
          builtins.path {
            path = cfg.nixPath;
            name = "nvim-snippets";
          };

      # Lua list literal helper: each dir wrapped in vim.fn.expand so the
      # runtime path can use ~ / $VARS while store paths pass through unchanged.
      toLuaDirs = dirs: "{ " + concatStringsSep ", " (map (d: ''vim.fn.expand("${d}")'') dirs) + " }";

      # VSCode-format JSON ships from the nix store (repo snippets/).
      vscodeDirsLua = toLuaDirs (optional (resolvedNixPath != null) (toString resolvedNixPath));

      # Custom { name, tags, filetype, query } Lua tables live in the runtime dir.
      luaDirsLua = toLuaDirs (optional (cfg.runtimePath != null) cfg.runtimePath);
    in
    {
      vim.startPlugins = [
        "luasnip"
        "telescope-luasnip"
      ];

      vim.luaConfigRC.luasnip =

        nvim.dag.entryAfter [ "telescope" ] # lua

          ''
            local ls = require("luasnip")
            ls.setup()

            require("luasnip.loaders.from_vscode").lazy_load({ paths = ${vscodeDirsLua} })

            -- Custom Lua format: each file returns a list of
            -- { name, tags, filetype, query } records. `query` uses VSCode
            -- snippet syntax (''${1}, ''${1:default}, $0).
            local function load_query_snippets(dir)
              local files = vim.fn.globpath(vim.fn.expand(dir), "*.lua", false, true)
              for _, file in ipairs(files) do
                local ok, records = pcall(dofile, file)
                if ok and type(records) == "table" then
                  local by_ft = {}
                  for _, r in ipairs(records) do
                    if r.filetype and r.query then
                      local label = r.tags
                      
                        and (r.name .. "  [" .. table.concat(r.tags, ", ") .. "]")
                        or r.name
                      by_ft[r.filetype] = by_ft[r.filetype] or {}
                      table.insert(
                        by_ft[r.filetype],
                        ls.parser.parse_snippet({ trig = r.name, name = r.name, dscr = label }, r.query)
                      )
                    end
                  end
                  for ft, snips in pairs(by_ft) do
                    ls.add_snippets(ft, snips, { key = file .. ":" .. ft })
                  end
                end
              end
            end

            for _, dir in ipairs(${luaDirsLua}) do
              load_query_snippets(dir)
            end

            require("telescope").load_extension("luasnip")

            vim.keymap.set("i", "<C-j>", function()
              require("telescope").extensions.luasnip.luasnip()
            end, { desc = "Insert snippet (luasnip)" })
          '';
    }
  );

}
