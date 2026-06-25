{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ ./vsnip.nix ./luasnip.nix ];
}
