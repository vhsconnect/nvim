{
  pkgs,
  lib,
  check ? true,
}:
let
  modules = [
    ./autopairs
    ./avante
    #./avante-rust
    ./diffview
    ./basic
    ./build
    ./chatgpt
    ./codeboomer
    ./codeium
    ./conjure
    ./copilot
    ./completion
    ./core
    ./debugger
    ./filetree
    ./fzf
    ./git
    ./gitsigns
    ./guess-indent
    ./keys
    ./languages
    ./lsp
    ./noice
    ./nfnl
    ./oil
    ./paraedit
    ./snippets
    ./statusline
    ./tabline
    ./telescope
    ./theme
    ./treesitter
    ./visuals
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
