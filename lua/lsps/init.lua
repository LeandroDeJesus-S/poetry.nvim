--- LSP module type definitions for poetry.nvim.
--- Defines the interface that LSP plugins (like pyright) must implement.
---
---@class poetry.LSPOptions
---@field fallback_envs string[]: Python virtual environment directory names to search if Poetry env is not found

---@class poetry.LSP
---@field configure fun(opts: poetry.LSPOptions): nil Configure the LSP to work with Poetry environments
---@field restart fun(): nil Restart the LSP client
---@field reset fun(): nil Reset the LSP configuration to original state
