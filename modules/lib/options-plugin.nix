{ lib }:
with lib;
let
  pluginsType =
    rawPlugins: nixpkgsPlugins:
    with types;
    listOf (
      nullOr (
        either (enum ((attrNames rawPlugins) ++ (attrNames nixpkgsPlugins) ++ [ "nvim-treesitter" ])) package
      )
    );
in
{
  mkPluginsOption =
    {
      rawPlugins,
      nixpkgsPlugins ? { },
      description,
      default ? [ ],
    }:
    mkOption {
      inherit description default;
      type = pluginsType rawPlugins nixpkgsPlugins;
    };
}
