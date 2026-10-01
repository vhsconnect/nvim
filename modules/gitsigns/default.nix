{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.git;
in
{
  options.vim.git.gitsigns = {
    enable = mkEnableOption "gitsigns";

    codeActions = mkEnableOption "gitsigns codeactions through null-ls";
  };

  config = mkIf (cfg.enable && cfg.gitsigns.enable) (mkMerge [
    {
      vim.startPlugins = [ "gitsigns-nvim" ];
      vim.luaConfigRC.gitsigns =
        nvim.dag.entryAnywhere # lua
          ''
            require('gitsigns').setup {
              signs = {
                add          = { text = '' },
                change       = { text = '' },
                delete       = { text = '' },
                topdelete    = { text = '' },
                changedelete = { text = '' },
                untracked    = { text = '' },
              },
              signs_staged = {
                add          = { text = '' },
                change       = { text = '' },
                delete       = { text = '' },
                topdelete    = { text = '' },
                changedelete = { text = '' },
                untracked    = { text = '' },
              },
              sign_priority = 6,
              update_debounce = 500,
              on_attach = function(bufnr)
                local gs = package.loaded.gitsigns

                local function map(mode, l, r, opts)
                  opts = opts or {}
                  opts.buffer = bufnr
                  vim.keymap.set(mode, l, r, opts)
                end

                -- navigation
                map('n', ']c', function()
                    gs.nav_hunk('next')
                end)

                map('n', '[c', function()
                    gs.nav_hunk('prev')
                end)

                -- actions
                map('n', '<leader>hs', gs.stage_hunk)
                map('v', '<leader>hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)

                map('n', '<leader>hu', gs.reset_hunk)
                map('v', '<leader>hu', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)

                map('n', '<leader>hp', gs.preview_hunk)
                map('n', '<leader>hp', gs.undo_stage_hunk)

                map('n', '<leader>hS', gs.stage_buffer)
                map('n', '<leader>hR', gs.reset_buffer)

                map('n', '<leader>hd', gs.diffthis)
                map('n', '<leader>hD', function() gs.diffthis('~') end)

                map('n', '<leader>hb', function() gs.blame_line{full=true} end)

                -- Toggles
                map('n', '<leader>htd', gs.toggle_deleted)
                map('n', '<leader>htb', gs.toggle_current_line_blame)
                map('n', '<leader>hts', gs.toggle_signs)
                map('n', '<leader>htn', gs.toggle_numhl)
                map('n', '<leader>htl', gs.toggle_linehl)
                map('n', '<leader>htw', gs.toggle_word_diff)

                -- Text objects
                map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
              end
            }
          '';
    }

    (mkIf cfg.gitsigns.codeActions {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources.gitsigns-ca = ''
        table.insert(
          ls_sources,
          null_ls.builtins.code_actions.gitsigns
        )
      '';
    })

    (mkIf config.vim.telescope.enable {
      vim.luaConfigRC.gitsigns-telescope-base =
        nvim.dag.entryAfter [ "telescope" ] # lua
          ''
            local function gitsigns_pick_base()
              local actions = require('telescope.actions')
              local action_state = require('telescope.actions.state')
              local conf = require('telescope.config').values
              local finders = require('telescope.finders')
              local make_entry = require('telescope.make_entry')
              local pickers = require('telescope.pickers')
              local previewers = require('telescope.previewers')
              local putils = require('telescope.previewers.utils')

              local opts = { cwd = vim.fs.root(0, '.git') or vim.uv.cwd() }
              opts.entry_maker = make_entry.gen_from_git_commits(opts)

              local function changes_since_to_quickfix(base)
                local files = vim.fn.systemlist({ 'git', '-C', opts.cwd, 'diff', base, '--name-only' })
                if vim.v.shell_error ~= 0 then
                  vim.notify(table.concat(files, '\n'), vim.log.levels.ERROR)
                  return
                end
                vim.fn.setqflist({}, ' ', {
                  title = 'Changes since ' .. base,
                  items = vim.tbl_map(function(f)
                    return { filename = vim.fs.joinpath(opts.cwd, f), lnum = 1 }
                  end, files),
                })
                vim.cmd.copen()
              end

              local function set_base(prompt_bufnr, suffix)
                local entry = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if entry then
                  local base = entry.value .. suffix
                  require('gitsigns').change_base(base, true, vim.schedule_wrap(function(err)
                    if err then
                      vim.notify('gitsigns base ' .. base .. ': ' .. err, vim.log.levels.ERROR)
                    else
                      vim.notify('gitsigns base: ' .. base)
                      changes_since_to_quickfix(base)
                    end
                  end))
                end
              end

              pickers.new(opts, {
                prompt_title = 'Gitsigns base (<CR> commit, <M-p> parent)',
                finder = finders.new_oneshot_job(
                  { 'git', 'log', '--pretty=oneline', '--abbrev-commit' },
                  opts
                ),
                sorter = conf.generic_sorter(opts),
                previewer = previewers.new_buffer_previewer({
                  title = 'git show',
                  get_buffer_by_name = function(_, entry)
                    return entry.value
                  end,
                  define_preview = function(self, entry)
                    putils.job_maker(
                      { 'git', '--no-pager', 'show', '--stat', '--patch', entry.value },
                      self.state.bufnr,
                      {
                        value = entry.value,
                        bufname = self.state.bufname,
                        cwd = opts.cwd,
                        callback = function(bufnr)
                          if vim.api.nvim_buf_is_valid(bufnr) then
                            putils.highlighter(bufnr, 'git', opts)
                          end
                        end,
                      }
                    )
                  end,
                }),
                attach_mappings = function(prompt_bufnr, map)
                  actions.select_default:replace(function()
                    set_base(prompt_bufnr, "")
                  end)
                  map({ 'i', 'n' }, '<M-p>', function()
                    set_base(prompt_bufnr, '^')
                  end)
                  return true
                end,
              }):find()
            end

            vim.keymap.set('n', '<leader>hc', gitsigns_pick_base, { desc = 'gitsigns: pick base commit' })
            vim.keymap.set('n', '<leader>h0', function()
              require('gitsigns').reset_base(true)
              vim.notify('gitsigns base: index')
            end, { desc = 'gitsigns: reset base to index' })
          '';
    })
  ]);
}
