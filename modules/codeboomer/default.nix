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
      description = "Lua run at startup to configure codeboomer.nvim";
      type = with types; nullOr lines;
      default = ''
      local function with(base, extra)
        return vim.list_extend(vim.deepcopy(base), extra)
      end

      local claude = { "nix", "run", "github:numtide/llm-agents.nix#claude-code", "--" }
      local pi = { "nix", "run", "github:numtide/llm-agents.nix#pi", "--" }

      require("codeboomer").setup({
        debug = false,
        keybindings = {
          send_prompt = "<leader>cs",
          send_last_prompt = "<leader>cl",
          send_selection = "<leader>cr",
          ask_one_off = "<leader>cc",
          flush_with_directive = "<leader>cd",
          pane = "<leader>cp",
          launch_reviewer = "<leader>cA",
          reset_session = "<leader>cS",
          review = "<leader>cR",
          post_review = "<leader>cP",
          pull_review = "<leader>cL",
          annotate = "<leader>ca",
        },
        prompting = {
          one_off_commands = {
            {
              label = "claude-code (llm-agents)",
              argv = with(claude, {
                "--model", "haiku",
                "--output-format", "json",
                "--permission-mode", "acceptEdits",
                "-p",
              }),
            },
          },
          review_agents = {
            { label = "claude", argv = with(claude, { "--dangerously-skip-permissions" }) },
            { label = "pi", argv = pi },
          },
        },
      })
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
        (optionalString (cfg.config != null) cfg.config);
  };
}
