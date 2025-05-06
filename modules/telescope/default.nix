{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.telescope;
in
{
  options.vim.telescope = {
    enable = mkEnableOption "telescope";

    fileBrowser = {
      enable = mkEnableOption "telescope file browser";

      hijackNetRW = mkOption {
        default = true;
        description = "Disables netrw and use telescope-file-browser in its place.";
        type = types.bool;
      };
    };

    recency-bias = {
      enable = mkEnableOption "recent-all";
    };

    cmdline = {
      enable = mkEnableOption "cmdline";
    };

    advanced-git-search = {
      enable = mkEnableOption "advanced_git_search";
    };

    liveGrepArgs = {
      enable = mkEnableOption "telescope live grep with args";
      autoQuoting = mkOption {
        default = true;
        description = ''If the prompt value does not begin with ', " or - the entire prompt is treated as a single argument.'';
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.liveGrepArgs.enable {
      vim.startPlugins = [ "telescope-live-grep-args" ];

      vim.nnoremap = {
        "<leader>fl" = "<cmd> Telescope live_grep_args<CR>";
      };
      # vim.inoremap = {
      #   "<C-k>" = "lga_actions.quote_prompt()";
      #   "<C-i>" = ''lga_actions.quote_prompt({ postfix = " --iglob " })'';
      # };

      vim.luaConfigRC.telescope-live-grep-args-setup =
        nvim.dag.entryBefore [ "telescope" ] # lua
          ''
            local lga_actions = require("telescope-live-grep-args.actions")

            require("telescope").setup {
              extensions = {
                live_grep_args = {
                  auto_quoting = ${boolToString cfg.liveGrepArgs.autoQuoting},
                }
              }
            }
          '';

      vim.luaConfigRC.telescope-live-grep-args-load =
        nvim.dag.entryAfter [ "telescope" ] # lua
          ''
            require("telescope").load_extension "live_grep_args"
          '';
    })
    (mkIf cfg.advanced-git-search.enable {
      vim.startPlugins = [
        pkgs.vimPlugins.vim-fugitive
        pkgs.vimPlugins.vim-rhubarb
        pkgs.vimPlugins.advanced-git-search-nvim
      ];

      vim.nnoremap = {
        "<leader>fa" = "<cmd>AdvancedGitSearch<CR>";
      };

      vim.luaConfigRC.telescope-advanced-git-search-setup =
        nvim.dag.entryBefore [ "telescope" ] # lua
          ''

            require("telescope").setup {
              extensions = {
                advanced_git_search = {

                  -- Browse command to open commits in browser. Default fugitive GBrowse.
                  -- {commit_hash} is the placeholder for the commit hash.
                  browse_command = "GBrowse {commit_hash}",
                  -- when {commit_hash} is not provided, the commit will be appended to the specified command seperated by a space
                  -- browse_command = "GBrowse",
                  -- => both will result in calling `:GBrowse commit`

                  -- fugitive or diffview
                  diff_plugin = "diffview",
                  -- customize git in previewer
                  -- e.g. flags such as { "--no-pager" }, or { "-c", "delta.side-by-side=false" }
                  git_flags = {},
                  -- customize git diff in previewer
                  -- e.g. flags such as { "--raw" }
                  git_diff_flags = {},
                  git_log_flags = {},
                  -- Show builtin git pickers when executing "show_custom_functions" or :AdvancedGitSearch
                  show_builtin_git_pickers = false,
                  entry_default_author_or_date = "date", -- one of "author" or "date"
                  keymaps = {
                    -- following keymaps can be overridden
                    toggle_date_author = "<C-w>",
                    open_commit_in_browser = "<C-o>",
                    copy_commit_hash = "<C-y>",
                    show_entire_commit = "<C-e>",
                  },

                  telescope_theme = {
                    function_name_1 = {
                      -- Theme options
                    },
                    function_name_2 = "dropdown",
                    -- e.g. realistic example
                    show_custom_functions = {
                      layout_config = { width = 0.4, height = 0.4 },
                    },
                  },
                }
              }
            }
          '';

      vim.luaConfigRC.telescope-advanced-git-search-load =
        nvim.dag.entryAfter [ "telescope" "diffview" ] # lua
          ''
            require("telescope").load_extension("advanced_git_search")
          '';
    })
    (mkIf cfg.cmdline.enable {
      vim.startPlugins = [ "telescope-cmdline" ];

      vim.nnoremap = {
        "Q" = "<cmd> Telescope cmdline<CR>";
      };

      vim.luaConfigRC.telescope-cmdline-setup =
        nvim.dag.entryBefore [ "telescope" ] # lua
          ''
            require("telescope").setup({
              extensions = {
                cmdline = {
                  -- Adjust telescope picker size and layout
                  picker = {
                    layout_config = {
                      width  = 120,
                      height = 25,
                    }
                  },
                  mappings    = {
                    complete      = '<Tab>',
                    run_selection = '<C-CR>',
                    run_input     = '<CR>',
                  },
                  -- Triggers any shell command using overseer.nvim (`:!`)
                  overseer    = {
                    enabled = true,
                  },
                },
              }
            })
          '';

    })
    (mkIf cfg.recency-bias.enable {
      vim.startPlugins = [
        "telescope-all-recent"
        "sqlite"
      ];

      vim.luaConfigRC.telescope-all-recent-setup =
        nvim.dag.entryBefore
          [
            "telescope"
            "telescope-live-grep-args"
            "telescope-file-browser"
          ] # lua
          ''
            -- require('sqlite').setup()
            vim.g.sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.so'
            require('sqlite')


            local stdpath_data = vim.fn.stdpath("data")
            if type(stdpath_data) ~= "string" and vim.isarray(stdpath_data) then
              stdpath_data = stdpath_data[1]
            end
            ---@cast stdpath_data string
            local data_folder = stdpath_data

            ---@type AllRecentConfig
            local default_config = {
              database = {
                folder = data_folder,
                file = "telescope-all-recent.sqlite3",
                max_timestamps = 10,
              },
              scoring = {
                recency_modifier = {
                  [1] = { age = 240, value = 100 }, -- past 4 hours
                  [2] = { age = 1440, value = 80 }, -- past day
                  [3] = { age = 4320, value = 60 }, -- past 3 days
                  [4] = { age = 10080, value = 40 }, -- past week
                  [5] = { age = 43200, value = 20 }, -- past month
                  [6] = { age = 129600, value = 10 }, -- past 90 days
                },
                boost_factor = 0.0001,
              },
              default = {
                disable = true,
                use_cwd = true,
                sorting = "recent",
              },
              debug = false,
              -- does not make sense for:
              -- grep string
              -- live grep (too many results)
              -- TODO: buffers: might be useful for project/session, but: we must allow preprocesseing the string
              --
              -- oldfiles: are per definition already recent. If you need frecency files: use telescope-frecency
              -- command history: already recent
              -- search history: already recent
              --
              pickers = {
                -- pickers explicitly enabled
                -- not using cwd
                man_pages = {
                  disable = false,
                  use_cwd = false,
                },
                vim_options = {
                  disable = false,
                  use_cwd = false,
                },
                pickers = {
                  disable = false,
                  use_cwd = false,
                },
                builtin = {
                  disable = false,
                  use_cwd = false,
                },
                planets = {
                  disable = false,
                  use_cwd = false,
                },
                commands = {
                  disable = false,
                  use_cwd = false,
                },
                help_tags = {
                  disable = false,
                  use_cwd = false,
                },
                -- using cwd
                find_files = {
                  disable = false,
                  sorting = "frecency",
                },
                git_files = {
                  disable = false,
                  sorting = "frecency",
                },
                tags = {
                  disable = false,
                },
                git_commits = {
                  disable = false,
                },
                git_branches = {
                  disable = false,
                },
                -- some explicitly disabled pickers: I consider them not useful.
                oldfiles = { disable = true },
                live_grep = { disable = true },
                grep_string = { disable = true },
                command_history = { disable = true },
                search_history = { disable = true },
                current_buffer_fuzzy_find = { disable = true },
              },
              -- support for telescope invoked through vim.ui.select, e.g. using dressing.nvim
              -- Specify the kind.
              -- Potentially fix to a specific prompt only.
              -- Other than that, all options are the same as for normal pickers
              vim_ui_select = {
                kinds = {},
                prompts = {},
              },
            }

            require('telescope-all-recent').setup(default_config)

          '';

    })

    (mkIf cfg.fileBrowser.enable {
      vim.startPlugins = [ "telescope-file-browser" ];

      vim.nnoremap = {
        "<leader>fd" = "<cmd> Telescope file_browser<CR>";
      };

      vim.luaConfigRC.telescope-file-browser-setup =
        nvim.dag.entryBefore [ "telescope" ] # lua
          ''
            require("telescope").setup {
              extensions = {
                file_browser = {
                  hijack_netrw = ${boolToString cfg.fileBrowser.hijackNetRW},
                }
              }
            }
          '';

      vim.luaConfigRC.telescope-file-browser-load =
        nvim.dag.entryAfter [ "telescope" ] # lua
          ''
            require("telescope").load_extension "file_browser"
          '';
    })
    (mkIf config.vim.treesitter.enable {
      vim.nnoremap = {
        # "<leader>fs" = "<cmd> Telescope treesitter<CR>";
      };
    })
    (mkIf config.vim.lsp.enable {
      vim.nnoremap = {
        "<leader>fs" = "<cmd> Telescope lsp_document_symbols<CR>";
        "<leader>fw" = "<cmd> Telescope lsp_workspace_symbols<CR>";
        "<leader>fd" = "<cmd> Telescope diagnostics<CR>";

        # "<leader>flr" = "<cmd> Telescope lsp_references<CR>";
        # "<leader>fli" = "<cmd> Telescope lsp_implementations<CR>";
        # "<leader>flD" = "<cmd> Telescope lsp_definitions<CR>";
        # "<leader>flt" = "<cmd> Telescope lsp_type_definitions<CR>";
      };
    })
    {
      vim.startPlugins = [ "telescope" ];

      vim.nnoremap = {
        "<leader>ff" = "<cmd> Telescope find_files<CR>";
        "<leader>fg" = "<cmd> Telescope live_grep<CR>";
        "<leader>fb" = "<cmd> Telescope buffers<CR>";
        "<leader>fh" = "<cmd> Telescope help_tags<CR>";
        "<leader>ft" = "<cmd> Telescope<CR>";

        "<leader>fvcw" = "<cmd> Telescope git_commits<CR>";
        "<leader>fvcb" = "<cmd> Telescope git_bcommits<CR>";
        "<leader>fvb" = "<cmd> Telescope git_branches<CR>";
        "<leader>fvs" = "<cmd> Telescope git_status<CR>";
        "<leader>fvx" = "<cmd> Telescope git_stash<CR>";
      };

      vim.luaConfigRC.telescope =
        nvim.dag.entryAnywhere # lua
          ''
            local telescope = require('telescope')
            telescope.setup({
            	defaults = {
            		vimgrep_arguments =  {
                   "${pkgs.ripgrep}/bin/rg",
                   "--color=never",
                   "--no-heading",
                   "--hidden",
                   "--with-filename",
                   "--line-number",
                   "--column",
                   "--smart-case",
                   "--glob",
                   "!**/.git/*"
                }
            	},
            	pickers = {
            		find_files = {
            			find_command = { "${pkgs.ripgrep}/bin/rg", "--files", "--hidden", "--glob", "!**/.git/*" },
            		},
                colorscheme = { enable_preview = true }
            	},
            })
          '';
    }
  ]);
}
