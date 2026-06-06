{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.languages.tailwindcss;

  defaultServer = "tailwindcss-language-server";
  servers = {
    tailwindcss-language-server = {
      package = [ "tailwindcss-language-server" ];

      lspConfig = # lua
        ''
          vim.lsp.config('tailwindcss', {
            cmd = {"${nvim.languages.commandOptToCmd cfg.lsp.package "tailwindcss-language-server"}", "--stdio"},
            filetypes = {
              "aspnetcorerazor", "astro", "astro-markdown", "blade", "clojure",
              "django-html", "htmldjango", "edge", "eelixir", "elixir", "ejs",
              "erb", "eruby", "gohtml", "gohtmltmpl", "haml", "handlebars", "hbs",
              "html", "html-eex", "heex", "jade", "leaf", "liquid", "markdown",
              "mdx", "mustache", "njk", "nunjucks", "php", "razor", "slim",
              "twig", "css", "less", "sass", "scss", "stylus", "sugarss",
              "javascript", "javascriptreact", "typescript", "typescriptreact",
              "vue", "svelte",
            },
            root_markers = { "tailwind.config.js", "tailwind.config.cjs", "tailwind.config.mjs", "tailwind.config.ts", "postcss.config.js", "postcss.config.cjs", "postcss.config.mjs", "postcss.config.ts", ".git" },
          })

          vim.lsp.enable('tailwindcss')

          vim.api.nvim_create_autocmd('LspAttach', {
            callback = function(args)
              local client = vim.lsp.get_client_by_id(args.data.client_id)
              if client.name ~= 'tailwindcss' then return end
              default_on_attach(client, args.buf)
            end,
          })
        '';
    };
  };
in
{
  options.vim.languages.tailwindcss = {
    enable = mkEnableOption "TailwindCSS language support";

    lsp = {
      enable = mkOption {
        description = "Enable TailwindCSS LSP support";
        type = types.bool;
        default = config.vim.languages.enableLSP;
      };
      server = mkOption {
        description = "TailwindCSS LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };
      package = nvim.options.mkCommandOption pkgs {
        description = "TailwindCSS LSP server";
        inherit (servers.${cfg.lsp.server}) package;
      };
    };

    treesitter = {
      enable = mkOption {
        description = "Enable Tailwind treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      package = nvim.options.mkGrammarOption pkgs "tailwindcss";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.tailwindcss-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
