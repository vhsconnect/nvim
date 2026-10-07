{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.languages.ts;

  defaultServer = "ts_ls";
  servers = {
    oxc = {
      package = [
        "oxlint"
      ];
      lspConfig = # lua
        ''
          local oxlint_on_attach = vim.lsp.config.oxlint.on_attach
          vim.lsp.config("oxlint", {
            capabilities = capabilities,
            on_attach = function(client, bufnr)
              attach_keymaps(client, bufnr)
              oxlint_on_attach(client, bufnr)
            end,
            cmd = { "${nvim.languages.commandOptToCmd cfg.lsp.package "oxlint"}", "--lsp" },
            -- lspconfig's root_dir calls on_dir(nil) without a marker, which attaches everywhere
            root_dir = function(bufnr, on_dir)
              local root = vim.fs.root(bufnr, { ${concatMapStringsSep ", " (m: ''"${m}"'') rootMarkers.oxlint} })
              if root then
                on_dir(root)
              end
            end,
          })
          vim.lsp.enable("oxlint")
        '';
    };
    ts_ls = {
      package = "typescript-language-server";
      lspConfig = # lua
        ''
          local ts_ls_on_attach = vim.lsp.config.ts_ls.on_attach
          vim.lsp.config("ts_ls", {
            capabilities = capabilities,
            on_attach = function(client, bufnr)
              attach_keymaps(client, bufnr)
              ts_ls_on_attach(client, bufnr)
            end,
            cmd = { "${nvim.languages.commandOptToCmd cfg.lsp.package "typescript-language-server"}", "--stdio" },
          })
          vim.lsp.enable("ts_ls")
        '';
    };
  };

  rootMarkers = {
    eslint = [
      "eslint.config.js"
      "eslint.config.mjs"
      "eslint.config.cjs"
      "eslint.config.ts"
      "eslint.config.mts"
      "eslint.config.cts"
      ".eslintrc"
      ".eslintrc.js"
      ".eslintrc.cjs"
      ".eslintrc.json"
      ".eslintrc.yaml"
      ".eslintrc.yml"
    ];
    prettier = [
      ".prettierrc"
      ".prettierrc.json"
      ".prettierrc.json5"
      ".prettierrc.yaml"
      ".prettierrc.yml"
      ".prettierrc.toml"
      ".prettierrc.js"
      ".prettierrc.cjs"
      ".prettierrc.mjs"
      "prettier.config.js"
      "prettier.config.cjs"
      "prettier.config.mjs"
    ];
    oxlint = [
      ".oxlintrc.json"
      ".oxlintrc.jsonc"
    ];
    oxfmt = [
      ".oxfmtrc.json"
      ".oxfmtrc.jsonc"
    ];
  };

  defaultFormats = [
    "eslint_d"
    "oxfmt"
  ];
  formats = {
    prettier = {
      package = pkgs.prettier;
      nullConfig =
        pkg: # lua
        ''
          table.insert(
            ls_sources,
            null_ls.builtins.formatting.prettier.with({
              command = "${pkg}/bin/prettier",
              runtime_condition = ${nvim.languages.rootCondition rootMarkers.prettier},
            })
          )
        '';
    };
    eslint_d = {
      package = pkgs.eslint_d;
      nullConfig =
        pkg: # lua
        ''
          table.insert(
            ls_sources,
            require("none-ls.formatting.eslint_d").with({
              command = "${pkg}/bin/eslint_d",
              runtime_condition = ${nvim.languages.rootCondition rootMarkers.eslint},
            })
          )
        '';
    };
    eslint = {
      package = pkgs.eslint;
      nullConfig =
        pkg: # lua
        ''
          table.insert(
            ls_sources,
            require("none-ls.formatting.eslint").with({
              command = "${pkg}/bin/eslint",
              runtime_condition = ${nvim.languages.rootCondition rootMarkers.eslint},
            })
          )
        '';
    };
    oxfmt = {
      package = pkgs.oxfmt;
      nullConfig =
        pkg: # lua
        ''
          table.insert(
            ls_sources,
            require("none-ls.formatting.oxfmt").with({
              command = "${pkg}/bin/oxfmt",
              runtime_condition = ${nvim.languages.rootCondition rootMarkers.oxfmt},
            })
          )
        '';
    };
  };

  defaultDiagnostics = [
    "eslint_d"
    "oxlint"
  ];
  diagnostics = {
    eslint_d = {
      package = pkgs.eslint_d;
      nullConfig =
        pkg: # lua
        ''
          table.insert(
            ls_sources,
            require("none-ls.diagnostics.eslint_d").with({
              command = "${pkg}/bin/eslint_d",
              runtime_condition = ${nvim.languages.rootCondition rootMarkers.eslint},
            })
          )
        '';
    };
    eslint = {
      package = pkgs.eslint;
      nullConfig =
        pkg: # lua
        ''
          table.insert(
            ls_sources,
            require("none-ls.diagnostics.eslint").with({
              command = "${pkg}/bin/eslint",
              runtime_condition = ${nvim.languages.rootCondition rootMarkers.eslint},
            })
          )
        '';
    };
    oxlint = {
      package = pkgs.oxlint;
      nullConfig =
        pkg: # lua
        ''
          table.insert(
            ls_sources,
            require("none-ls.diagnostics.oxlint").with({
              command = "${pkg}/bin/oxlint",
              prefer_local = "node_modules/.bin",
              to_temp_file = false,
              method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
              runtime_condition = ${nvim.languages.rootCondition rootMarkers.oxlint},
            })
          )
        '';
    };
  };
in
{
  options.vim.languages.ts = {
    enable = mkEnableOption "TS/JS language support";

    treesitter = {
      enable = mkOption {
        description = "Enable Typescript/Javascript treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      tsPackage = nvim.options.mkGrammarOption pkgs "typescript";
      jsPackage = nvim.options.mkGrammarOption pkgs "javascript";
    };

    lsp = {
      enable = mkOption {
        description = "Enable Typescript/Javascript LSP support";
        type = types.bool;
        default = config.vim.languages.enableLSP;
      };
      server = mkOption {
        description = "Typescript/Javascript LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };
      package = nvim.options.mkCommandOption pkgs {
        description = "Typescript/Javascript LSP server";
        inherit (servers.${cfg.lsp.server}) package;
      };
    };

    format = {
      enable = mkOption {
        description = "Enable Typescript/Javascript formatting";
        type = types.bool;
        default = config.vim.languages.enableFormat;
      };
      types = nvim.options.mkFormatsOption {
        langDesc = "Typescript/Javascript";
        inherit formats;
        inherit defaultFormats;
      };
    };

    extraDiagnostics = {
      enable = mkOption {
        description = "Enable extra Typescript/Javascript diagnostics";
        type = types.bool;
        default = config.vim.languages.enableExtraDiagnostics;
      };
      types = nvim.options.mkDiagnosticsOption {
        langDesc = "Typescript/Javascript";
        inherit diagnostics;
        inherit defaultDiagnostics;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [
        cfg.treesitter.tsPackage
        cfg.treesitter.jsPackage
      ];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.ts-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf cfg.format.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources = lib.nvim.languages.formatsToLua {
        lang = "ts";
        config = cfg.format.types;
        inherit formats;
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources = lib.nvim.languages.diagnosticsToLua {
        lang = "ts";
        config = cfg.extraDiagnostics.types;
        inherit diagnostics;
      };
    })
  ]);
}
