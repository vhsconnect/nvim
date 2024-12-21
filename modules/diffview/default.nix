{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.diffview;
in
{

  config = {
    vim.startPlugins = [
      "diffview"
    ];
    vim.optPlugins = [ ];
    vim.luaConfigRC.diffview = nvim.dag.entryAfter [ "plenary-nvim" ] (
      builtins.readFile ../../diffview.lua
    );
  };
}
