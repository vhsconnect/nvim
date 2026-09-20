{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.codeboomer;
in
{
  options.vim.codeboomer = {
    enable = mkEnableOption "Enable codeboomer.nvim";
    config = mkOption {
      description = "codeboomer.nvim configuration, passed to setup()";
      type = with types; nullOr lines;
      default = ''
        keybindings = {
          send_prompt = "<leader>cs",
          send_selection = "<leader>cr",
          ask_one_off = "<leader>cc",
          flush_with_directive = "<leader>cd",
          pane = "<leader>cp",
          session = "<leader>cS",
          review = "<leader>cR",
          review_worktree = "<leader>cW",
          review_side = "<leader>ct",
          post_review = "<leader>cP",
          pull_review = "<leader>cL",
          annotate = "<leader>ca",
          comments = "<leader>cm",
          enter_pane = "<leader>ce",
        },
        prompting = {
          directives = {
            { label = "vanilla", text = "Review my comments, pushback if you need to" },
            { label = "Post as drafts", text = "Each section is one of my review comments. Post them verbatim on the PR I am reviewing as draft review comments via gh — one draft comment per section, anchored to the file and line range given in its 'regarding ...' header. Do not publish or submit the review, and do not reword the comments; leave everything as drafts for me to submit." },
          },
          one_off_commands = {
            {
              label = "claude-code (llm-agents)",
              argv = {
                "nix",
                "run",
                "github:numtide/llm-agents.nix#claude-code",
                "--",
                "--model",
                "haiku",
                "--output-format",
                "json",
                "--permission-mode",
                "acceptEdits",
                "-p",
              },
            },
          },
        },
      '';
    };
  };

  config = mkIf cfg.enable {
    build.nixpkgsPlugins.sqlite = "sqlite-lua";

    vim.startPlugins = [
      "codeboomer"
      "sqlite"
      "fzf-lua"
    ];
    vim.luaConfigRC.codeboomer =
      nvim.dag.entryAnywhere # lua
        ''
          require("codeboomer").setup({
            ${cfg.config}
          })
        '';
  };
}
