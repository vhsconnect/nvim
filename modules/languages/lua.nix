{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.languages.lua;

  defaultServer = "lua_ls";
  servers = {
    lua_ls = {
      package = [ "lua-language-server" ];
      lspConfig = # lua
        ''
          require'lspconfig'.lua_ls.setup {
            on_init = function(client)
              if client.workspace_folders then
                local path = client.workspace_folders[1].name
                if vim.uv.fs_stat(path..'/.luarc.json') or vim.uv.fs_stat(path..'/.luarc.jsonc') then
                  return
                end
              end

              client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                runtime = {
                  -- Tell the language server which version of Lua you're using
                  -- (most likely LuaJIT in the case of Neovim)
                  version = 'LuaJIT'
                },
                -- Make the server aware of Neovim runtime files
                workspace = {
                  checkThirdParty = false,
                  library = {
                    vim.env.VIMRUNTIME
                  }
                  -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
                  -- library = vim.api.nvim_get_runtime_file("", true)
                }
              })
            end,
            settings = {
              Lua = {}
            },
          }

          vim.api.nvim_create_autocmd("FileType", {
              pattern = "lua",
              callback = function()
                  vim.cmd("LspStart lua_ls")
              end,
          })

        '';
    };
  };

  defaultFormat = "stylua";
  formats = {
    stylua = {
      package = [ "stylua" ];
      nullConfig = # lua
        ''
          table.insert(
            ls_sources,
            null_ls.builtins.formatting.stylua.with({
              command = "${nvim.languages.commandOptToCmd cfg.format.package "stylua"}",
            })
          )
        '';
    };
  };

  defaultDiagnostics = [ "selene" ];
  diagnostics = {
    selene = {
      package = pkgs.selene;
      nullConfig =
        pkg: # lua
        ''
          table.insert(
            ls_sources,
            null_ls.builtins.diagnostics.selene.with({
              command = "${pkg}/bin/selene",
            })
          )
        '';
    };
  };
in
{
  options.vim.languages.lua = {
    enable = mkEnableOption "Lua language support";

    treesitter = {
      enable = mkOption {
        description = "Lua treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      package = nvim.options.mkGrammarOption pkgs "lua";
    };

    lsp = {
      enable = mkOption {
        description = "Enable Lua LSP support";
        type = types.bool;
        default = config.vim.languages.enableLSP;
      };
      server = mkOption {
        description = "Lua LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };
      package = lib.nvim.options.mkCommandOption pkgs {
        description = " LSP server";
        inherit (servers.${cfg.lsp.server}) package;
      };
    };

    format = {
      enable = mkOption {
        description = "Enable Lua formatting";
        type = types.bool;
        default = config.vim.languages.enableFormat;
      };
      type = mkOption {
        description = "Lua formatter to use";
        type = with types; enum (attrNames formats);
        default = defaultFormat;
      };

      package = lib.nvim.options.mkCommandOption pkgs {
        description = "Lua formatter package.";
        inherit (formats.${cfg.format.type}) package;
      };
    };

    extraDiagnostics = {
      enable = mkOption {
        description = "Enable extra Lua diagnostics";
        type = types.bool;
        default = config.vim.languages.enableExtraDiagnostics;
      };
      types = lib.nvim.options.mkDiagnosticsOption {
        langDesc = "Lua";
        inherit diagnostics;
        inherit defaultDiagnostics;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [ cfg.treesitter.package ];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.lua-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf cfg.format.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources.lua-format = formats.${cfg.format.type}.nullConfig;
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources = lib.nvim.languages.diagnosticsToLua {
        lang = "lua";
        config = cfg.extraDiagnostics.types;
        inherit diagnostics;
      };
    })
  ]);
}
