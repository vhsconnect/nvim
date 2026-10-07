{ lib }:
with lib;
let
  sourceSubmodule =
    { kind, sources }:
    { ... }:
    {
      options = {
        type = mkOption {
          description = "Type of ${kind} to enable";
          type = types.enum (attrNames sources);
        };
        package = mkOption {
          description = "${kind} package";
          type = types.package;
        };
      };
    };

  mkSourcesOption =
    {
      kind,
      langDesc,
      sources,
      defaults,
    }:
    mkOption {
      description = "List of ${langDesc} ${kind}s to enable";
      type =
        with types;
        listOf (either (enum (attrNames sources)) (submodule (sourceSubmodule { inherit kind sources; })));
      default = defaults;
    };
in
{
  mkDiagnosticsOption =
    {
      langDesc,
      diagnostics,
      defaultDiagnostics,
    }:
    mkSourcesOption {
      kind = "diagnostic";
      inherit langDesc;
      sources = diagnostics;
      defaults = defaultDiagnostics;
    };

  mkFormatsOption =
    {
      langDesc,
      formats,
      defaultFormats,
    }:
    mkSourcesOption {
      kind = "formatter";
      inherit langDesc;
      sources = formats;
      defaults = defaultFormats;
    };

  mkGrammarOption =
    pkgs: language:
    mkPackageOption pkgs [ "${language} treesitter" ] {
      default = [
        "tree-sitter-grammars"
        "tree-sitter-${language}"
      ];
    };

  mkCommandOption =
    pkgs:
    { description, package }:
    mkPackageOption pkgs [ description ] {
      extraDescription = "Providing null will use command in $PATH.";
      default = package;
      nullable = true;
    };
}
