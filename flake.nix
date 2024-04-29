{
  inputs.neovim-flake.url = "github:vhsconnect/neovim-flake";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  inputs.tshjkl = {
    url = "github:gsuuon/tshjkl.nvim";
    flake = false;
  };

  inputs.emmet = {
    url = "github:mattn/emmet-vim";
    flake = false;
  };

  inputs.mustache = {
    url = "github:mustache/vim-mustache-handlebars";
    flake = false;
  };

  inputs.tmux-nav = {
    url = "github:christoomey/vim-tmux-navigator";
    flake = false;
  };
  inputs.gen = {
    url = "github:David-Kunz/gen.nvim";
    flake = false;
  };
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
  inputs.gitgutter = {
    url = "github:airblade/vim-gitgutter";
    flake = false;
  };
  inputs.themed-tabs = {
    url = "github:vhsconnect/themed-tabs.nvim";
    flake = false;
  };
  inputs.nvim-surround = {
    url = "github:kylechui/nvim-surround";
    flake = false;
  };

  outputs =
    { nixpkgs
    , neovim-flake
    , flake-utils
    , ...
    } @ inputs:
    let
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
    flake-utils.lib.eachSystem systems (system:
    let
      configModule = {
        build.viAlias = true;
        build.vimAlias = true;
        build.rawPlugins = {
          tshjkl = {
            src = inputs.tshjkl;
          };
          emmet = {
            src = inputs.emmet;
          };
          mustache = {
            src = inputs.mustache;
          };
          tmux-nav = {
            src = inputs.tmux-nav;
          };
          gen = {
            src = inputs.gen;
          };
          leap-nvim = {
            src = inputs.leap-nvim;
          };
          tcomment = {
            src = inputs.tcomment;
          };
          colorschemes = {
            src = inputs.colorschemes;
          };
          gitgutter = {
            src = inputs.gitgutter;
          };
          themed-tabs = {
            src = inputs.themed-tabs;
          };
          nvim-surround = {
            src = inputs.nvim-surround;
          };
        };
        vim.visuals.enable = true;
        vim.visuals.nvimWebDevicons.enable = true;
        vim.preventJunkFiles = true;
        vim.useSystemClipboard = true;
        vim.showSignColumn = true;
        vim.codeium.enable = true;

        vim.splitBelow = false;
        vim.tabline.nvimBufferline = {
          enable = true;
        };
        vim.git = {
          enable = false;
          gitsigns.enable = true;
          gitsigns.codeActions = true;
        };
        vim.languages = {
          enableLSP = true;
          enableFormat = true;
          enableTreesitter = false;
          nix.enable = true;
          nix.format.enable = true;
          nix.format.type = "nixpkgs-fmt";
          markdown.enable = true;
          html.enable = true;
          html.treesitter.enable = true;
          python.enable = true;
          ts = {
            enable = true;
            treesitter.enable = true;
            format.enable = true;
          };
          rust.enable = true;
          rust.lsp.enable = true;
          css.enable = true;
          css.lsp.enable = true;
          tailwindcss.enable = true;
          tailwindcss.lsp.enable = true;
          haskell.enable = true;
          haskell.lsp.enable = true;
          haskell.format.enable = true;
          angular.enable = true;
          angular.lsp.enable = true;
          scala.enable = true;
          scala.lsp.enable = true;
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
          enable = false;
          icons = false;
        };
        vim.theme = {
          enable = true;
          name = "oxocarbon";
        };
        vim.autopairs.enable = true;
        vim.autocomplete = {
          enable = true;
          type = "nvim-cmp";
        };
        vim.filetree.nvimTreeLua.enable = true;
        vim.treesitter.context.enable = false;
        vim.treesitter.enable = true;
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
        modules = [ configModule ];
      };

      extended = base.extendConfiguration {
        modules = [
          {
            vim.startPlugins = [
              "leap-nvim"
              "colorschemes"
              "tcomment"
              "gitgutter"
              "themed-tabs"
              "nvim-surround"
              "gen"
              "tmux-nav"
              "mustache"
              "emmet"
              "tshjkl"
            ];
            vim.optPlugins = [
              "codeium"
            ];
          }
        ];
      };
    in
    rec {
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
