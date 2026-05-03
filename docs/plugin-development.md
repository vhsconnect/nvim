# Plugin Development with nvim-extra

## Directory Structure

Define a path to append to your runtimepath - ../dynamic_path.lua . Any Lua module placed there is loadable via `require()` without rebuilding your Nix config.

## Module Resolution

`require()` maps `.` to `/` under `lua/` directories:

```
require("foo")              → lua/foo.lua
require("foo")              → lua/foo/init.lua   (if foo is a directory)
require("foo.bar")          → lua/foo/bar.lua
require("foo.bar.baz")      → lua/foo/bar/baz.lua
```

## Multi-File Plugin Layout

```
~/.config/nvim-extra/
└── lua/
    ├── myplugin/
    │   ├── init.lua          ← require("myplugin") loads this
    │   ├── utils.lua         ← require("myplugin.utils")
    │   ├── highlight.lua     ← require("myplugin.highlight")
    │   └── config.lua        ← require("myplugin.config")
    └── load-myplugin.lua     ← auto-loaded entry point, calls require("myplugin").setup()
```

`init.lua` is the implicit entry point when you require a directory name.

## Patterns

### Module Template

Every module returns a table:

```lua
local M = {}

M.some_function = function()
  -- ...
end

return M
```

### Setup Pattern

```lua
-- lua/myplugin/init.lua
local config = require("myplugin.config")

local M = {}

M.setup = function(opts)
  config.apply(opts or {})
end

return M
```

### Config Module

```lua
-- lua/myplugin/config.lua
local M = {}
M.values = {}

M.apply = function(opts)
  M.values = vim.tbl_deep_extend("force", M.values, opts)
end

return M
```

### Entry Point (auto-loaded)

```lua
-- lua/load-myplugin.lua
require("myplugin").setup({ style = "dark" })
```

Only top-level `.lua` files in `~/.config/nvim-extra/lua/` are auto-loaded by the loader. Use one entry point file per plugin.

## Reloading During Development

Neovim caches `require()` results. To reload a module without restarting:

```vim
:lua package.loaded["myplugin.utils"] = nil
:lua require("myplugin.utils")
```

Or add a convenience command in your plugin:

```lua
vim.api.nvim_create_user_command("MypluginReload", function()
  for k, _ in pairs(package.loaded) do
    if k:find("^myplugin") then
      package.loaded[k] = nil
    end
  end
  require("myplugin").setup()
end, {})
```

## How the Auto-Loader Works

The loader was added in `flake.nix` as part of the `c` entry in `luaConfigRC`:

1. Prepends `~/.config/nvim-extra` to `runtimepath`
2. Globs `~/.config/nvim-extra/lua/*.lua`
3. Calls `require()` on each file with `pcall` (errors are shown as warnings, not crashes)

Subdirectories are NOT auto-scanned — they are loaded on demand via `require()` from your entry point file.
