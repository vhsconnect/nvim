{ config, lib, ... }:
with lib;
with builtins;
let
  cfg = config.vim.lsp;
  usingNvimCmp = config.vim.autocomplete.enable && config.vim.autocomplete.type == "nvim-cmp";
in
{
  imports = [
    ./lspconfig.nix
    ./null-ls.nix
    ./lspkind.nix
    ./lspsaga.nix
    ./trouble.nix
    ./lsp-signature.nix
    ./lightbulb.nix
    ./fidget.nix
  ];

  options.vim.lsp = {
    enable = mkEnableOption "LSP, also enabled automatically through null-ls and lspconfig options";
    formatOnSave = mkEnableOption "format on save";
  };

  config = mkIf cfg.enable {
    vim = {
      startPlugins = optional usingNvimCmp "cmp-nvim-lsp";

      autocomplete.sources = [
        # {
        #   name = "nvim_lsp";
        #   priority = "200";
        #   format = "[LSP]";
        # }

      ];

      luaConfigRC.lsp-setup = # lua
        ''
          vim.api.nvim_create_autocmd({ "ColorScheme" }, {
            callback = function()
              vim.api.nvim_set_hl(0, "DiagnosticFloatingError", {})
              vim.api.nvim_set_hl(0, "DiagnosticFloatingWarn", {})
              vim.api.nvim_set_hl(0, "DiagnosticFloatingInfo", {})
              vim.api.nvim_set_hl(0, "DiagnosticFloatingHint", {})
            end
          })

          vim.api.nvim_set_hl(0, "FloatBorder", {})
          vim.api.nvim_set_hl(0,"DiagnosticFloatingError", {})
          vim.api.nvim_set_hl(0,"DiagnosticFloatingWarn", {})
          vim.api.nvim_set_hl(0,"DiagnosticFloatingHint", {})
          vim.api.nvim_set_hl(0,"DiagnosticFloatingInfo", {})

          vim.g.formatsave = ${boolToString cfg.formatOnSave};
          vim.cmd [[ autocmd! CursorHold,CursorHoldI ]]

           function noFloatingWins()
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                  local width = vim.api.nvim_win_get_width(win)
                  local height = vim.api.nvim_win_get_height(win)
                  
                  if width > 0 and height > 0 then
                      return true 
                  end

              end
              return false
          end


          vim.diagnostic.config({
            underline = true,
            virtual_text = false,
            signs = true,
            update_in_insert = false,
            severity_sort = false,
          })

          local attach_keymaps = function(client, bufnr)
            local opts = { noremap=true, silent=true }

            vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ld', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lp', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', '"', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)

            vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lwa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lwr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lwl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)

            vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ls', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
            vim.api.nvim_create_autocmd("CursorHold", {
              buffer = bufnr,
              callback = function()
                local opts = {
                  focusable = false,
                  close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                  border = 'rounded',
                  source = 'always',
                  prefix = ' ',
                  scope = 'cursor',
                }
                local wins = vim.api.nvim_list_wins()

                if noFloatingWins() then
                 vim.diagnostic.open_float(nil, opts)
                end
              end
            })
          end

          -- Enable formatting
          -- Single global, SYNCHRONOUS format-on-save autocmd.
          -- NOTE: this used to be one autocmd per attached client, each doing
          -- async formatting. Multiple async formatters applied TextEdits
          -- computed against stale buffer states after the file was already
          -- written, which produced duplicated/missing text. Formatting now
          -- blocks in BufWritePre so edits land before the write.
          local format_onsave = vim.api.nvim_create_augroup("lsp_format_onsave", { clear = true })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = format_onsave,
            callback = function(args)
              if not vim.g.formatsave then
                return
              end
              if vim.bo[args.buf].buftype ~= "" then
                return
              end
              -- only format when at least one attached client can format
              local clients = vim.lsp.get_clients({
                bufnr = args.buf,
                method = "textDocument/formatting",
              })
              if #clients == 0 then
                return
              end
              vim.lsp.buf.format({
                bufnr = args.buf,
                async = false,
                timeout_ms = 3000,
              })
            end,
          })

          default_on_attach = function(client, bufnr)
            attach_keymaps(client, bufnr)
          end

          local capabilities = vim.lsp.protocol.make_client_capabilities()
          ${optionalString usingNvimCmp "capabilities = require('cmp_nvim_lsp').default_capabilities()"}
        '';
    };
  };
}
