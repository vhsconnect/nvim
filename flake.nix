{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    master.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    nil.url = "github:oxalica/nil";
    nil.inputs.nixpkgs.follows = "nixpkgs";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    ## Plugins (must begin with plugin-)

    # 3rd party LLM Plugins
    plugin-codeium = {
      url = "github:exafunction/codeium.vim";
      flake = false;
    };

    # utility plugins
    plugin-sqlite.url = "github:kkharji/sqlite.lua";
    plugin-sqlite.flake = false;

    # tresitter plugins
    plugin-nvim-treesitter-context.url = "github:nvim-treesitter/nvim-treesitter-context";
    plugin-nvim-treesitter-context.flake = false;

    plugin-nvim-treesitter-textobjects.url = "github:nvim-treesitter/nvim-treesitter-textobjects";
    plugin-nvim-treesitter-textobjects.flake = false;

    # LSP plugins
    plugin-nvim-lspconfig.url = "github:neovim/nvim-lspconfig";
    plugin-nvim-lspconfig.flake = false;

    plugin-lspsaga.url = "github:nvimdev/lspsaga.nvim";
    plugin-lspsaga.flake = false;

    plugin-lspkind.url = "github:onsails/lspkind-nvim";
    plugin-lspkind.flake = false;

    plugin-trouble.url = "github:folke/trouble.nvim";
    plugin-trouble.flake = false;

    plugin-nvim-lightbulb.url = "github:kosayoda/nvim-lightbulb";
    plugin-nvim-lightbulb.flake = false;

    plugin-fidget.url = "github:j-hui/fidget.nvim";
    plugin-fidget.flake = false;

    plugin-lsp-signature.url = "github:ray-x/lsp_signature.nvim";
    plugin-lsp-signature.flake = false;

    plugin-null-ls.url = "github:nvimtools/none-ls.nvim";
    plugin-null-ls.flake = false;

    # needed for eslint_d
    plugin-none-ls-extras.url = "github:nvimtools/none-ls-extras.nvim";
    plugin-none-ls-extras.flake = false;

    plugin-sqls-nvim.url = "github:nanotee/sqls.nvim";
    plugin-sqls-nvim.flake = false;

    plugin-rust-tools.url = "github:simrat39/rust-tools.nvim";
    plugin-rust-tools.flake = false;

    # Not primary repo, waiting on PR
    plugin-ccls-nvim.url = "github:MCGHH/ccls.nvim";
    plugin-ccls-nvim.flake = false;

    # Debugger
    plugin-nvim-dap.url = "github:mfussenegger/nvim-dap";
    plugin-nvim-dap.flake = false;

    plugin-nvim-dap-ui.url = "github:rcarriga/nvim-dap-ui";
    plugin-nvim-dap-ui.flake = false;

    plugin-nvim-dap-virtual-text.url = "github:theHamsta/nvim-dap-virtual-text";
    plugin-nvim-dap-virtual-text.flake = false;

    # Copying/Registers
    plugin-registers.url = "github:tversteeg/registers.nvim";
    plugin-registers.flake = false;

    plugin-nvim-neoclip.url = "github:AckslD/nvim-neoclip.lua";
    plugin-nvim-neoclip.flake = false;

    # Telescope
    plugin-telescope.url = "github:nvim-telescope/telescope.nvim";
    plugin-telescope.flake = false;

    plugin-telescope-file-browser.url = "github:nvim-telescope/telescope-file-browser.nvim";
    plugin-telescope-file-browser.flake = false;

    plugin-telescope-live-grep-args.url = "github:nvim-telescope/telescope-live-grep-args.nvim";
    plugin-telescope-live-grep-args.flake = false;

    plugin-telescope-all-recent.url = "github:prochri/telescope-all-recent.nvim";
    plugin-telescope-all-recent.flake = false;

    plugin-telescope-cmdline.url = "github:jonarrien/telescope-cmdline.nvim";
    plugin-telescope-cmdline.flake = false;

    # Filetrees
    plugin-nvim-tree-lua.url = "github:kyazdani42/nvim-tree.lua";
    plugin-nvim-tree-lua.flake = false;

    # Tablines
    plugin-nvim-bufferline-lua.url = "github:akinsho/nvim-bufferline.lua?ref=v4.3.0";
    plugin-nvim-bufferline-lua.flake = false;

    # Statuslines
    plugin-lualine.url = "github:hoob3rt/lualine.nvim";
    plugin-lualine.flake = false;

    # Autocompletes
    plugin-nvim-cmp.url = "github:hrsh7th/nvim-cmp";
    plugin-nvim-cmp.flake = false;

    plugin-cmp-buffer.url = "github:hrsh7th/cmp-buffer";
    plugin-cmp-buffer.flake = false;

    plugin-cmp-nvim-lsp.url = "github:hrsh7th/cmp-nvim-lsp";
    plugin-cmp-nvim-lsp.flake = false;

    plugin-cmp-vsnip.url = "github:hrsh7th/cmp-vsnip";
    plugin-cmp-vsnip.flake = false;

    plugin-cmp-path.url = "github:hrsh7th/cmp-path";
    plugin-cmp-path.flake = false;

    plugin-cmp-cmdline.url = "github:hrsh7th/cmp-cmdline";
    plugin-cmp-cmdline.flake = false;

    plugin-cmp-treesitter.url = "github:ray-x/cmp-treesitter";
    plugin-cmp-treesitter.flake = false;

    plugin-cmp-dap.url = "github:rcarriga/cmp-dap";
    plugin-cmp-dap.flake = false;

    # snippets
    plugin-vim-vsnip.url = "github:hrsh7th/vim-vsnip";
    plugin-vim-vsnip.flake = false;

    # Autopairs
    plugin-nvim-autopairs.url = "github:windwp/nvim-autopairs";
    plugin-nvim-autopairs.flake = false;

    plugin-nvim-ts-autotag.url = "github:windwp/nvim-ts-autotag";
    plugin-nvim-ts-autotag.flake = false;

    # AI
    plugin-chatgpt-nvim.url = "github:jackMort/ChatGPT.nvim";
    plugin-chatgpt-nvim.flake = false;

    plugin-copilot-vim.url = "github:github/copilot.vim";
    plugin-copilot-vim.flake = false;

    plugin-copilot-chat-nvim.url = "github:CopilotC-Nvim/CopilotChat.nvim";
    plugin-copilot-chat-nvim.flake = false;

    # Commenting
    plugin-kommentary.url = "github:b3nj5m1n/kommentary";
    plugin-kommentary.flake = false;

    plugin-todo-comments.url = "github:folke/todo-comments.nvim";
    plugin-todo-comments.flake = false;

    # Buffer tools
    plugin-bufdelete-nvim.url = "github:famiu/bufdelete.nvim";
    plugin-bufdelete-nvim.flake = false;

    plugin-onedark.url = "github:navarasu/onedark.nvim";
    plugin-onedark.flake = false;

    plugin-catppuccin.url = "github:catppuccin/nvim";
    plugin-catppuccin.flake = false;

    plugin-dracula-nvim.url = "github:Mofiqul/dracula.nvim";
    plugin-dracula-nvim.flake = false;

    plugin-dracula.url = "github:dracula/vim";
    plugin-dracula.flake = false;

    plugin-gruvbox.url = "github:ellisonleao/gruvbox.nvim";
    plugin-gruvbox.flake = false;

    # Rust crates
    plugin-crates-nvim.url = "github:Saecki/crates.nvim";
    plugin-crates-nvim.flake = false;

    # Visuals
    plugin-nvim-cursorline.url = "github:yamatsum/nvim-cursorline";
    plugin-nvim-cursorline.flake = false;

    plugin-indent-blankline.url = "github:lukas-reineke/indent-blankline.nvim";
    plugin-indent-blankline.flake = false;

    # nui - UI Component Library for Neovim - required by ChatGPT.nvim
    plugin-nui-nvim.url = "github:MunifTanjim/nui.nvim";
    plugin-nui-nvim.flake = false;

    plugin-nvim-web-devicons.url = "github:kyazdani42/nvim-web-devicons";
    plugin-nvim-web-devicons.flake = false;

    plugin-gitsigns-nvim.url = "github:lewis6991/gitsigns.nvim";
    plugin-gitsigns-nvim.flake = false;

    # Key binding help
    plugin-which-key.url = "github:folke/which-key.nvim";
    plugin-which-key.flake = false;

    # Markdown
    plugin-glow-nvim.url = "github:ellisonleao/glow.nvim";
    plugin-glow-nvim.flake = false;

    # SCNvim
    plugin-scnvim.url = "github:davidgranstrom/scnvim";
    plugin-scnvim.flake = false;

    # Plenary (required by crates-nvim)
    plugin-plenary-nvim.url = "github:nvim-lua/plenary.nvim";
    plugin-plenary-nvim.flake = false;

    plugin-open-browser.url = "github:tyru/open-browser.vim";
    plugin-open-browser.flake = false;

    plugin-plantuml-syntax.url = "github:aklt/plantuml-syntax";
    plugin-plantuml-syntax.flake = false;

    plugin-plantuml-previewer.url = "github:weirongxu/plantuml-previewer.vim";
    plugin-plantuml-previewer.flake = false;

    # git
    plugin-neogit.url = "github:NeogitOrg/neogit";
    plugin-neogit.flake = false;

    plugin-dressing.url = "github:stevearc/dressing.nvim";
    plugin-dressing.flake = false;

    plugin-render-markdown.url = "github:MeanderingProgrammer/render-markdown.nvim";
    plugin-render-markdown.flake = false;

    plugin-avante-nvim.url = "github:yetone/avante.nvim";
    plugin-avante-nvim.flake = false;

    plugin-noice.url = "github:folke/noice.nvim";
    plugin-noice.flake = false;

    plugin-nvim-notify.url = "github:rcarriga/nvim-notify";
    plugin-nvim-notify.flake = false;

    oil = {
      url = "github:stevearc/oil.nvim";
      flake = false;
    };

    oxocarbon = {
      url = "github:nyoom-engineering/oxocarbon.nvim";
      flake = false;
    };

    tshjkl = {
      url = "github:gsuuon/tshjkl.nvim";
      flake = false;
    };

    emmet = {
      url = "github:mattn/emmet-vim";
      flake = false;
    };

    mustache = {
      url = "github:mustache/vim-mustache-handlebars";
      flake = false;
    };

    tmux-nav = {
      url = "github:christoomey/vim-tmux-navigator";
      flake = false;
    };
    gen = {
      url = "github:David-Kunz/gen.nvim";
      flake = false;
    };
    leap-nvim = {
      url = "github:ggandor/leap.nvim";
      flake = false;
    };
    colorschemes = {
      url = "github:flazz/vim-colorschemes";
      flake = false;
    };
    tcomment = {
      url = "github:tomtom/tcomment_vim";
      flake = false;
    };
    gitgutter = {
      url = "github:airblade/vim-gitgutter";
      flake = false;
    };
    themed-tabs = {
      url = "github:vhsconnect/themed-tabs.nvim";
      flake = false;
    };
    nvim-surround = {
      url = "github:kylechui/nvim-surround";
      flake = false;
    };
    tokyonight = {
      url = "github:folke/tokyonight.nvim";
      flake = false;
    };
    vim-terraform = {
      url = "github:hashivim/vim-terraform";
      flake = false;
    };
    diffview = {
      url = "github:sindrets/diffview.nvim";
      flake = false;
    };

    dadbod = {
      url = "github:tpope/vim-dadbod";
      flake = false;
    };
    dadbod-ui = {
      url = "github:kristijanhusak/vim-dadbod-ui";
      flake = false;
    };
    dadbod-completion = {
      url = "github:kristijanhusak/vim-dadbod-completion";
      flake = false;
    };
    vim-prettier = {
      url = "github:prettier/vim-prettier";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      master,
      ...
    }@inputs:
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
      useNightly = false;
    in
    flake-utils.lib.eachSystem systems (
      system:
      let
        nightly = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
        configModule = {
          build = {
            viAlias = true;
            vimAlias = true;
            rawPlugins = {
              oil = {
                src = inputs.oil;
              };
              oxocarbon = {
                src = inputs.oxocarbon;
              };
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
              tokyonight = {
                src = inputs.tokyonight;
              };
              vim-terraform = {
                src = inputs.vim-terraform;
              };
              diffview = {
                src = inputs.diffview;
              };
              dadbod = {
                src = inputs.dadbod;
              };
              dadbod-ui = {
                src = inputs.dadbod-ui;
              };
              dadbod-completion = {
                src = inputs.dadbod-completion;
              };
              vim-prettier = {
                src = inputs.vim-prettier;
              };
            };
          } // (if useNightly then { build.package = nightly; } else { });
          vim = {
            visuals = {
              enable = true;
              nvimWebDevicons.enable = true;
              cursorWordline.enable = true;
            };
            preventJunkFiles = true;
            useSystemClipboard = true;
            showSignColumn = true;
            codeium.enable = false;
            lsp = {
              enable = true;
              lspkind.enable = true;
            };
            splitBelow = false;
            tabline.nvimBufferline = {
              enable = false;
            };
            git = {
              enable = true;
              neogit.enable = true;
              gitsigns.enable = false;
              gitsigns.codeActions = false;
            };
            languages = {
              enableLSP = true;
              enableFormat = true;
              enableTreesitter = true;
              nix = {
                enable = true;
                extraDiagnostics.enable = false;
                format.enable = true;
                format.type = "nixfmt";
              };
              markdown.enable = false;
              html.enable = false;
              html.treesitter.enable = true;
              python.enable = true;
              python.format.enable = false;
              lua = {
                enable = true;
                lsp.enable = true;
                treesitter.enable = true;
                extraDiagnostics.enable = false;
                format.enable = true;
              };
              bash = {
                enable = true;
                lsp.enable = true;
                extraDiagnostics.enable = false;
                format.enable = true;
              };
              fish = {
                enable = true;
                extraDiagnostics.enable = true;
                format.enable = true;
                treesitter.enable = true;
              };
              ts = {
                enable = true;
                treesitter.enable = true;
                format.type = "eslint_d";
                format.enable = true;
                extraDiagnostics.enable = true;
              };
              rust.enable = true;
              rust.lsp.enable = true;
              css.enable = false;
              css.lsp.enable = true;
              tailwindcss.enable = false;
              tailwindcss.lsp.enable = false;
              haskell = {
                enable = false;
                lsp.enable = true;
                format.enable = true;
              };
              angular.enable = false;
              angular.lsp.enable = false;
              scala.enable = false;
              scala.lsp.enable = false;
              sql.enable = false;
              sql.lsp.enable = false;

            };
            lsp = {
              formatOnSave = true;
              lightbulb.enable = true;
              lspsaga.enable = true;
              trouble.enable = true;
              lspSignature.enable = false;
            };
            statusline.lualine = {
              enable = false;
              icons = false;
            };
            theme = {
              enable = false;
              name = "oxocarbon";
            };
            avante.enable = true;
            copilot.enable = true;
            noice.enable = true;
            autopairs.enable = true;
            autocomplete = {
              enable = true;
              type = "nvim-cmp";
              enableCmdline = false;
              sources = [
                {
                  name = "path";
                  priority = "200";
                  format = "[Path]";
                }
                {
                  name = "nvim_lsp";
                  priority = "100";
                  format = "[LSP]";
                }
                {
                  name = "buffer";
                  priority = "50";
                  format = "[Buffer]";
                }
                {
                  name = "vsnip";
                  priority = "50";
                  format = "[Vsnip]";
                }

              ];
            };
            filetree.nvimTreeLua.enable = true;
            treesitter = {
              enable = true;
              context.enable = false;
              textobjects.enable = true;
              highlight = false;
            };
            keys = {
              enable = true;
              whichKey.enable = true;
            };
            telescope.enable = true;
            telescope.recency-bias.enable = true;
            telescope.cmdline.enable = true;
            telescope.liveGrepArgs.enable = true;
            telescope.advanced-git-search.enable = true;
            debugger = {
              enable = false;
              ui.enable = true;
              virtualText.enable = true;
            };
            luaConfigRC = {
              a = "${builtins.readFile ./rc.lua}";
              b = "${builtins.readFile ./cheat_sheet.lua}";
              # b = "${builtins.readFile ./diffview.lua}";
            };
          };
        };

        overlays.default = _: __: { eslint_d = master.eslint_d; };

        pkgs = nixpkgs.legacyPackages.${system}.appendOverlays [ ];

        neovim = (import ./neovim.nix) { inherit inputs; };

        base = neovim.lib.neovimConfiguration {
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
                #  "diffview"
                "nvim-surround"
                "gen"
                "tmux-nav"
                "mustache"
                "emmet"
                "tshjkl"
                "oxocarbon"
                "oil"
                "tokyonight"
                "vim-terraform"
                "dadbod"
                "dadbod-ui"
                "dadbod-completion"
                "vim-prettier"
              ];
              vim.optPlugins = [ "codeium" ];
            }
          ];
        };
      in
      rec {
        packages.neovim = extended;
        devShells.default = pkgs.mkShell {
          buildInputs = [ packages.neovim ];
          shellHook = '''';
        };
      }
    );
}
