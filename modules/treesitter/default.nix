{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./treesitter.nix
    ./context.nix
    ./textobjects.nix
  ];
}
