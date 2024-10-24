{ lib }:
with lib;
let
  diagnosticSubmodule =
    { ... }:
    {
      options = {
        type = mkOption {
          description = "Type of diagnostic to enable";
          type = attrNames diagnostics;
        };
        package = mkOption {
          description = "Diagnostics package";
          type = types.package;
        };
      };
    };
in
{
  mkDiagnosticsOption =
    {
      langDesc,
      diagnostics,
      defaultDiagnostics,
    }:
    mkOption {
      description = "List of ${langDesc} diagnostics to enable";
      type = with types; listOf (either (enum (attrNames diagnostics)) (submodule diagnosticSubmodule));
      default = defaultDiagnostics;
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
