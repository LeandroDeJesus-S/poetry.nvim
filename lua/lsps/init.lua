---@class poetry.LSPOptions
---@field fallback_envs string[]: python environments to try to find if poetry env is not found

--- @class poetry.LSP
--- @field configure function(): setup the LSP config to work properly. It has type [poetry.LSPOptions]
--- @field restart function(): restart the LSP
--- @field reset function(): disable the LSP config
