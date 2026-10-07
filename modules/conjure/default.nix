{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.conjure;
in
{
  options.vim.conjure = {
    enable = mkEnableOption "Enable conjure";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = [ "conjure" ];
    vim.luaConfigRC.conjure =
      nvim.dag.entryAnywhere # lua
        ''
          vim.g["conjure#mapping#enable_defaults"] = true
          vim.g["conjure#mapping#doc_word"] = false
          vim.g["conjure#mapping#prefix"] = "<leader>c"
          vim.g["conjure#mapping#eval_current_form"] = "c"
          vim.g["conjure#mapping#eval_buf"] = "f"
          -- vim.g["conjure#mapping#log_split"] = "s"
          -- vim.g["conjure#mapping#log_vsplit"] = "v"

          -- conjure's default list minus javascript, typescript, lua, rust, python, ruby, sql and php
          vim.g["conjure#filetypes"] = {
            "clojure",
            "elixir",
            "fennel",
            "janet",
            "hy",
            "julia",
            "racket",
            "scheme",
            "lisp",
            "r",
            "picolisp",
          }
        '';
  };
}
