{
  inputs.neovim-flake.url = "github:jordanisaacs/neovim-flake";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.leap-nvim = {
    url = "github:ggandor/leap.nvim";
    flake = false;
  };
  inputs.colorschemes = {
    url = "github:flazz/vim-colorschemes";
    flake = false;
  };
  inputs.tcomment = {
    url = "github:tomtom/tcomment_vim";
    flake = false;
  };

  outputs = {
    nixpkgs,
    neovim-flake,
    flake-utils,
    ...
  } @ inputs: let
    sys = {
      x86_64-linux = "x86_64-linux";
      aarch64-linux = "aarch64-linux";
      aarch64-darwin = "aarch64-darwin";
    };
    systems = [
      sys.aarch64-linux
      sys.aarch64-darwin
      sys.x86_64-linux
    ];
  in
    flake-utils.lib.eachSystem systems (system: let
      configModule = {
        build.viAlias = false;
        build.vimAlias = true;
        build.rawPlugins = {
          leap-nvim = {
            src = inputs.leap-nvim;
          };
          tcomment = {
            src = inputs.tcomment;
          };
          colorschemes = {
            src = inputs.colorschemes;
          };
        };
        vim.visuals.enable = true;
        vim.preventJunkFiles = true;
        vim.git = {
          enable = true;
          gitsigns.enable = true;
          gitsigns.codeActions = true;
        };
        vim.languages = {
          enableLSP = true;
          enableFormat = true;
          enableTreesitter = true;
          nix.enable = true;
          markdown.enable = true;
          html.enable = true;
          python.enable = true;
          ts = {
            enable = true;
            format.enable = true;
          };
          rust.enable = true;
          rust.lsp.enable = true;
        };
        vim.lsp = {
          formatOnSave = true;
          lightbulb.enable = true;
          lspsaga.enable = false;
          nvimCodeActionMenu.enable = true;
          trouble.enable = true;
          lspSignature.enable = true;
        };
        vim.statusline.lualine = {
          enable = true;
          theme = "gruvbox";
          icons = true;
        };
        vim.theme = {
          enable = true;
          name = "catppuccin";
          style = "macchiato";
        };
        vim.autopairs.enable = true;
        vim.autocomplete = {
          enable = true;
          type = "nvim-cmp";
        };
        vim.filetree.nvimTreeLua.enable = true;
        vim.treesitter.context.enable = true;
        vim.keys = {
          enable = true;
          whichKey.enable = true;
        };
        vim.telescope.enable = true;
        vim.luaConfigRC = {
          a = "${builtins.readFile ./rc.lua}";
        };
      };

      pkgs = nixpkgs.legacyPackages.${system};

      base = neovim-flake.lib.neovimConfiguration {
        inherit pkgs;
        modules = [configModule];
      };

      extended = base.extendConfiguration {
        modules = [
          {
            vim.startPlugins = [
              "leap-nvim"
              "colorschemes"
              "tcomment"
            ];
            vim.optPlugins = [
            ];
          }
        ];
      };
    in rec {
      packages.neovim = extended;
      devShells.default = pkgs.mkShell {
        buildInputs = [
          packages.neovim
        ];
        shellHook = ''
        '';
      };
    });
}
