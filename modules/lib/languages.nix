# From home-manager: https://github.com/nix-community/home-manager/blob/master/modules/lib/booleans.nix
{ lib }:
let
  resolveSource =
    sources: v:
    let
      type = if builtins.isString v then v else v.type;
      package = if builtins.isString v then sources.${type}.package else v.package;
    in
    {
      inherit type;
      nullConfig = sources.${type}.nullConfig package;
    };
in
{
  diagnosticsToLua =
    {
      lang,
      config,
      diagnostics,
    }:
    lib.listToAttrs (
      map (
        v:
        let
          source = resolveSource diagnostics v;
        in
        {
          name = "${lang}-diagnostics-${source.type}";
          value = source.nullConfig;
        }
      ) config
    );

  # Emitted as a single entry because none-ls chains formatters in registration order
  formatsToLua =
    {
      lang,
      config,
      formats,
    }:
    {
      "${lang}-format" = lib.concatMapStringsSep "\n" (v: (resolveSource formats v).nullConfig) config;
    };

  # Lua runtime_condition that only lets a source run when a marker exists above the buffer
  rootCondition =
    markers: "null_ls_root_has({ ${lib.concatMapStringsSep ", " (m: ''"${m}"'') markers} })";

  # Converts a command option to an actual command
  commandOptToCmd = pkg: cmd: if pkg == null then cmd else "${pkg}/bin/${cmd}";
}
