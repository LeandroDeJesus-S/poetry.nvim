--- State module for poetry.nvim.
--- Contains runtime state variables used across the plugin.
---
---@class poetry.State
---@field ready boolean: Whether the Python environment has been configured
---@field manual_path_prompted boolean: Whether the user has been prompted for manual Python path
---@field org_pyright_config table: Original Pyright configuration before modifications

---@type poetry.State
return {
	ready = false,
	manual_path_prompted = false,
	org_pyright_config = nil,
}
