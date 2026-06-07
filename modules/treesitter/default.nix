{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./treesitter.nix
    ./textobjects.nix
  ];
}
