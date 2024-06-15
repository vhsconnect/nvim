{ pkgs
, config
, lib
, ...
}:
with lib;
with builtins; let
  cfg = config.vim.codeium;
in
{
  options.vim.codeium = {
    enable = mkEnableOption "Enable codeium.vim";
    config = mkOption {
      description = "Codeium.vim configuration: 
      https://github.com/Exafunction/codeium.vim#%EF%B8%8F-configuration";
      type = with types;
        nullOr lines;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    vim.optPlugins = [ "codeium" ];
    vim.luaConfigRC.codeium = nvim.dag.entryAnywhere /* lua */ ''
      vim.keymap.set('i', '<C-a>', function() return vim.fn['codeium#Accept']() end, { expr = true })
      vim.keymap.set('i', '<c-a><c-a>', function() return vim.fn['codeium#CycleCompletions'](3) end, { expr = true })
      vim.keymap.set('i', '<c-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true })
      vim.keymap.set('i', '<c-q>', function() return vim.fn['codeium#Clear']() end, { expr = true })
    '';
  };
}
