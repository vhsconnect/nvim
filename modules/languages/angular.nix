{ pkgs
, config
, lib
, ...
}:
with lib;
with builtins; let
  cfg = config.vim.languages.angular;
  defaultServer = "angular-language-server";

  servers = {
    angular-language-server = {
      package = [ "vscode-extensions" "angular" "ng-template" ];
      lspConfig = /* lua */ ''
        local cmd = {"${cfg.lsp.package}/share/vscode/extensions/Angular.ng-template/server/bin/ngserver", "--stdio", "--tsProbeLocations", " ", "--ngProbeLocations", " "}

        require'lspconfig'.angularls.setup{
          cmd = cmd,
          on_new_config = function(new_config,new_root_dir)
            new_config.cmd = cmd
          end,
        }
      '';

    };

  };


in
{
  options.vim.languages.angular = {
    enable = mkEnableOption "Angular language support";

    treesitter = {
      enable = mkOption {
        description = "Enable Angular treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
    };

    lsp = {
      enable = mkOption {
        description = "Enable Angular LSP support";
        type = types.bool;
        default = config.vim.languages.enableLSP;
      };
      server = mkOption {
        description = "Angular LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;

      };
      package = nvim.options.mkCommandOption pkgs {
        description = "Angular LSP server";
        inherit (servers.${cfg.lsp.server}) package;
      };
    };


  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [ cfg.treesitter.tsPackage cfg.treesitter.jsPackage ];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.angular-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

  ]);
}
