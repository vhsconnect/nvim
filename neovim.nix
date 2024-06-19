{ inputs, ... }:
let
  flake-utils = inputs.flake-utils;
  nixpkgs = inputs.nixpkgs;
  rawPlugins = nvimLib.plugins.fromInputs inputs "plugin-";

  neovimConfiguration = args:
    let
      modules = args.modules ++ [{ config.build.rawPlugins = rawPlugins; }];
    in
    import ./modules (args // { inherit modules; });

  nvimBin = pkg: "${pkg}/bin/nvim";

  buildPkg = pkgs: modules: (neovimConfiguration {
    inherit pkgs modules;
  });

  nvimLib = (import ./modules/lib/stdlib-extended.nix nixpkgs.lib).nvim;

  mainConfig =
    let
      overrideable = nixpkgs.lib.mkOverride 1200; # between mkOptionDefault and mkDefault
    in
    {
      config = {
        build.viAlias = overrideable false;
        build.vimAlias = overrideable true;
        vim.languages = {
          enableLSP = overrideable true;
          enableFormat = overrideable true;
          enableTreesitter = overrideable true;
          enableExtraDiagnostics = overrideable true;
          enableDebugger = overrideable true;

          nix.enable = overrideable true;
          markdown.enable = overrideable true;
          html.enable = overrideable false;
          clang.enable = overrideable false;
          sql.enable = overrideable false;
          rust = {
            enable = overrideable false;
            crates.enable = overrideable false;
          };
          ts.enable = overrideable false;
          go.enable = overrideable false;
          zig.enable = overrideable false;
          python.enable = overrideable false;
          plantuml.enable = overrideable false;
          bash.enable = overrideable false;

        };
        vim.lsp = {
          formatOnSave = overrideable true;
          lspkind.enable = overrideable true;
          lightbulb.enable = overrideable true;
          lspsaga.enable = overrideable false;
          nvimCodeActionMenu.enable = overrideable true;
          trouble.enable = overrideable true;
          lspSignature.enable = overrideable true;
        };
        vim.visuals = {
          enable = overrideable true;
          nvimWebDevicons.enable = overrideable true;
          indentBlankline = {
            enable = overrideable true;
            fillChar = overrideable null;
            eolChar = overrideable null;
            showCurrContext = overrideable true;
          };
          cursorWordline = {
            enable = overrideable true;
            lineTimeout = overrideable 0;
          };
        };
        vim.statusline.lualine.enable = overrideable true;
        vim.theme.enable = true;
        vim.autopairs.enable = overrideable true;
        vim.autocomplete = {
          enable = overrideable true;
          type = overrideable "nvim-cmp";
        };
        vim.debugger.ui.enable = overrideable true;
        vim.filetree.nvimTreeLua.enable = overrideable true;
        vim.tabline.nvimBufferline.enable = overrideable true;
        vim.treesitter.context.enable = overrideable true;
        vim.keys = {
          enable = overrideable true;
          whichKey.enable = overrideable true;
        };
        vim.telescope = {
          enable = overrideable true;
          fileBrowser.enable = overrideable true;
          liveGrepArgs.enable = overrideable true;
        };
        vim.git = {
          enable = overrideable true;
          gitsigns.enable = overrideable true;
          gitsigns.codeActions = overrideable true;
        };
      };
    };

in
{
  lib = {
    nvim = nvimLib;
    inherit neovimConfiguration;
  };

  overlays.default = final: prev: {
    inherit neovimConfiguration;
    neovim-nix = buildPkg prev [ mainConfig ];
    neovim-maximal = buildPkg prev [ mainConfig ];
  };
}
  // (flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
      ];
    };


    nixPkg = buildPkg pkgs [ mainConfig ];

    devPkg = nixPkg.extendConfiguration {
      modules = [
        {
          vim.syntaxHighlighting = false;
          vim.languages.nix.format.type = "nixpkgs-fmt";
          vim.languages.bash.enable = true;
          vim.languages.html.enable = true;
          vim.filetree.nvimTreeLua.enable = false;
        }
      ];
    };
  in
  {
    apps.default = {
      type = "app";
      program = nvimBin nixPkg;
    };

    devShells.default = pkgs.mkShell {
      nativeBuildInputs = [ devPkg ];
    };

    packages = {
      default = nixPkg;
      nix = nixPkg;
      develop = devPkg;
    };
  }
))
