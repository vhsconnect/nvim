{
  pkgs,
  lib,
  check ? true,
}:
let
  modules = [
    ./avante
    ./chatgpt
    ./completion
    ./codeium
    ./theme
    ./core
    ./basic
    ./statusline
    ./tabline
    ./filetree
    ./visuals
    ./lsp
    ./languages
    ./treesitter
    ./autopairs
    ./snippets
    ./keys
    ./telescope
    ./git
    ./build
    ./debugger
  ];

  pkgsModule =
    { config, ... }:
    {
      config = {
        _module.args.baseModules = modules;
        _module.args.pkgsPath = lib.mkDefault pkgs.path;
        _module.args.pkgs = lib.mkDefault pkgs;
        _module.check = check;
      };
    };
in
modules ++ [ pkgsModule ]
