vim.keymap.set('n', '<space>n', ':NvimTreeToggle<CR>', {noremap = true})
vim.keymap.set('n', '<space><leader>', ':tabnext<CR>', {noremap = true})
vim.keymap.set('n', '<leader><space>', ':tabprevious<cr>', {noremap = true})
vim.keymap.set('n', '<space>s', ':set spell<cr>', {noremap = true})
vim.keymap.set('n', '<space><space>s', ':set nospell<cr>', {noremap = true})
vim.keymap.set('n', '<space>l', ':PrettierAsync<cr>', {noremap = true})


vim.keymap.set('n', 'K', '5k', {noremap = true})
vim.keymap.set('n', 'J', '5j', {noremap = true})
vim.keymap.set('n', 'L', '10l', {noremap = true})
vim.keymap.set('n', 'H', '10h', {noremap = true})

-- move visual block up and down
vim.keymap.set('x', 'J', ':move \'>+1<CR>gv-gv', { noremap = true })
vim.keymap.set('x', 'K', ':move \'<-2<CR>gv-gv', { noremap = true })


-- move split into own tab
vim.keymap.set('n', '<leader><leader>', '<C-W>T',  { noremap = true })

-- leap
vim.keymap.set('n', 's', '<Plug>(leap-forward)',  { noremap = true })
vim.keymap.set('n', 'S', '<Plug>(leap-backward)',  { noremap = true })

-- todo
vim.keymap.set('n', '<space>u', ':tabdo e<CR>', {noremap = true})
vim.keymap.set('n', '<space>e', ':ALEDetail<CR>', {noremap = true})

function interop(str)
   local outer_env = _ENV
   return (str:gsub("%b{}", function(block)
      local code = block:match("{(.*)}")
      local exp_env = {}
      setmetatable(exp_env, { __index = function(_, k)
         local stack_level = 5
         while debug.getinfo(stack_level, "") ~= nil do
            local i = 1
            repeat
               local name, value = debug.getlocal(stack_level, i)
               if name == k then
                  return value
               end
               i = i + 1
            until name == nil
            stack_level = stack_level + 1
         end
         return rawget(outer_env, k)
      end })
      local fn, err = load("return "..code, "expression `"..code.."`", "t", exp_env)
      if fn then
         return tostring(fn())
      else
         error(err, 0)
      end
   end))
end
local x = os.getenv("VIM_THEME")


------------------
-- markdown
------------------

vim.g["mkdp_auto_start"] = 0
vim.g["mkdp_refresh_slow"] = 1
vim.g["mkdp_browser"] = 'firefox'

------------------
-- colorscheme
------------------
vim.keymap.set('n', '<space>1', ':colorscheme OceanicNext<CR>', {noremap = true})
vim.keymap.set('n', '<space>2', ':colorscheme gruvbox<CR>', {noremap = true})
vim.keymap.set('n', '<space>3', ':colorscheme horseradish256<CR>', {noremap = true})
vim.keymap.set('n', '<space>4', ':colorscheme softblue<CR>', {noremap = true})
vim.keymap.set('n', '<space>5', ':colorscheme railscasts<CR>', {noremap = true})
vim.keymap.set('n', '<space>6', ':colorscheme Tomorrow<CR>', {noremap = true})
vim.keymap.set('n', '<space>7', ':colorscheme lightning<CR>', {noremap = true})
vim.keymap.set('n', '<space>8', ':colorscheme seoul256-light<CR>', {noremap = true})
vim.keymap.set('n', '<space>9', ':colorscheme summerfruit256<CR>', {noremap = true})
vim.keymap.set('n', '<space>0', ':colorscheme PaperColor<CR>', {noremap = true})

------------------
-- navigation
------------------
vim.keymap.set('n', '<C-J>', '<C-W><C-J>', {noremap = true})
vim.keymap.set('n', '<C-K>', '<C-W><C-K>', {noremap = true})
vim.keymap.set('n', '<C-L>', '<C-W><C-L>', {noremap = true})
vim.keymap.set('n', '<C-H>', '<C-W><C-H>', {noremap = true})

------------------
-- leap
------------------
--
require('leap').setup {
      case_insensitive = true,
    }

------------------
-- git gutter
------------------

vim.g["gitgtter_signs"] = 1
vim.g["gitgutter_sign_added"] = ''
vim.g["gitgutter_sign_modified"] = ''
vim.g["gitgutter_sign_removed"] =  ''
vim.g["gitgutter_sign_removed_first_line"] = ''
vim.g["gitgutter_sign_removed_above_and_below"] = ''
vim.g["gitgutter_sign_modified_removed"] = ''
