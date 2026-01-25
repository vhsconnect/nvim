{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.languages.rust;
in
{
  options.vim.languages.rust = {
    enable = mkEnableOption "Rust language support";

    packages = {
      rustc = mkPackageOption pkgs "Rustc package to use" { default = [ "rustc" ]; };

      cargo = mkPackageOption pkgs "Cargo package to use" { default = [ "cargo" ]; };
    };

    treesitter = {
      enable = mkOption {
        description = "Enable Rust treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      package = nvim.options.mkGrammarOption pkgs "rust";
    };

    crates = {
      enable = mkEnableOption "crates-nvim, tools for managing dependencies";
      codeActions = mkOption {
        description = "Enable code actions through null-ls";
        type = types.bool;
        default = true;
      };
    };
    formatRsx = {
      enable = mkOption {
        description = "Enable Dioxus RSX formatting";
        type = types.bool;
        default = config.vim.languages.enableFormat;
      };
    };

    format = {
      enable = mkOption {
        description = "Enable Rust formatting";
        type = types.bool;
        default = config.vim.languages.enableFormat;
      };
    };

    lsp = {
      enable = mkOption {
        description = "Rust LSP support (rust-analyzer with extra tools)";
        type = types.bool;
        default = config.vim.languages.enableLSP;
      };
      package = nvim.options.mkCommandOption pkgs {
        description = "rust-analyzer";
        package = [ "rust-analyzer" ];
      };
      opts = mkOption {
        description = "Options to pass to rust analyzer";
        type = types.str;
        default = "";
      };
    };

    debugger = {
      enable = mkOption {
        description = "Rust debugger support (codelldb)";
        type = types.bool;
        default = config.vim.languages.enableDebugger;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.crates.enable {
      vim.lsp.null-ls.enable = mkIf cfg.crates.codeActions true;

      vim.startPlugins = [ "crates-nvim" ];

      vim.autocomplete.sources = [
        {
          name = "crates";
          format = "[Crates]";
          priority = "50";
        }
      ];
      vim.luaConfigRC.rust-crates =
        nvim.dag.entryAnywhere # lua
          ''
            require('crates').setup {
              null_ls = {
                enabled = ${boolToString cfg.crates.codeActions},
                name = "crates.nvim",
              }
            }
          '';
    })
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [ cfg.treesitter.package ];
    })
    (mkIf cfg.format.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources.rust-format = # lua
        ''
          vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = {'*.rs'},
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format()
            end
            })
        '';
    })

    (mkIf cfg.formatRsx.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources.rust-format-rsx = ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.dxfmt.with({
            command = "${pkgs.dioxus-cli}/bin/dx",
          })
        )
      '';
    })
    (mkIf cfg.lsp.enable {
      vim.startPlugins = [ "rustaceanvim" ];
      vim.lsp.lspconfig.enable = true;
      # TODO configure - type hints ?
      vim.lsp.lspconfig.sources.rust-lsp = # lua
        ''
          vim.g.rustaceanvim = {
            -- Plugin configuration
            tools = {
            runnables = { use_telescope = true },
            debuggables = { use_telescope = true }
            },
            server = {
              default_settings = {
                -- rust-analyzer language server configuration
                ['rust-analyzer'] = {
                },
              },
            },
            -- DAP configuration
            dap = {
            },
          }
                
        '';
    })
    (mkIf cfg.debugger.enable {
      vim.startPlugins = [ "rustaceanvim" ];
      vim.debugger.enable = true;
    })
  ]);
}
