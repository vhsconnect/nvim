{ config
, lib
, pkgs
, ...
}:
with lib;
with builtins; let
  cfg = config.vim.lsp;
  usingNvimCmp = config.vim.autocomplete.enable && config.vim.autocomplete.type == "nvim-cmp";
in
{
  imports = [
    ./lspconfig.nix
    ./null-ls.nix

    ./lspkind.nix
    ./lspsaga.nix
    ./nvim-code-action-menu.nix
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
    vim.startPlugins = optional usingNvimCmp "cmp-nvim-lsp";

    vim.autocomplete.sources = { "nvim_lsp" = "[LSP]"; };

    vim.luaConfigRC.lsp-setup = /* lua */ ''
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

        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader><leader>D', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader><leader>d', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader><leader>f', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader><leader>t', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader><leader>p', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '"', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)

        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lwa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lwr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lwl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)

        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader><leader>s', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader><leader>r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
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
      format_callback = function(client, bufnr)
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = augroup,
          buffer = bufnr,
          callback = function()
            if vim.g.formatsave then
              if client.supports_method("textDocument/formatting") then
                local params = require'vim.lsp.util'.make_formatting_params({})
                client.request('textDocument/formatting', params, nil, bufnr)
              end
            end
          end
        })
      end

      default_on_attach = function(client, bufnr)
        attach_keymaps(client, bufnr)
        format_callback(client, bufnr)
      end

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      ${optionalString usingNvimCmp "capabilities = require('cmp_nvim_lsp').default_capabilities()"}
    '';
  };
}
