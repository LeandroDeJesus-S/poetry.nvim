---@class poetry.LSPOptions
---@field fallback_envs string[]: python environments to try to find if poetry env is not found

---@class poetry.LSP
---@field configure fun(opts: poetry.LSPOptions): nil setup the LSP config to work properly.
---@field restart function()nil restart the LSP
---@field reset function() nil disable the LSP config
