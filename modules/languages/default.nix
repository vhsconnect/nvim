{ lib, ... }:
with lib; let
  mkEnable = desc:
    mkOption {
      description = "Turn on ${desc} for enabled languages by default";
      type = types.bool;
      default = false;
    };
in
{
  imports = [
    ./angular.nix
    ./bash.nix
    ./clang.nix
    ./css.nix
    ./go.nix
    ./haskell.nix
    ./html.nix
    ./java.nix
    ./kotlin.nix
    ./markdown.nix
    ./nix.nix
    ./plantuml.nix
    ./python.nix
    ./rust.nix
    ./scala.nix
    ./sclang.nix
    ./sql.nix
    ./tailwindcss.nix
    ./terraform.nix
    ./ts.nix
    ./zig.nix
  ];

  options.vim.languages = {
    enableLSP = mkEnable "LSP";
    enableTreesitter = mkEnable "treesitter";
    enableFormat = mkEnable "formatting";
    enableExtraDiagnostics = mkEnable "extra diagnostics";
    enableDebugger = mkEnable "debuggers";
  };
}
