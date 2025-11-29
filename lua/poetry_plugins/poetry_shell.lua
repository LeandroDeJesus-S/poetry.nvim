---@class poetry.PoetryShellOpts
---@field keymaps table: keymaps to add to the poetry shell plugin

local M = {}
local state = {}

-- TODO: create options to:
-- - [un]install packages
-- - configure poetry settings
-- - ...

-- Setup the keymaps for the poetry shell plugin
local function setup_keymaps(extra_keymaps)
	local wk = require("which-key")
	local maps = {
		{
			"<leader>ps",
			function()
				Snacks.terminal("poetry shell")
			end,
			mode = { "n", "t" },
			desc = "Toggle Poetry Shell",
		},
	}
	maps = vim.list_extend(extra_keymaps, maps)
	wk.add(maps)
end

-- Setup the poetry shell plugin
--- @param opts poetry.PoetryShellOpts
M.setup = function(opts)
	if not M.check() then
		return
	end
	setup_keymaps(opts.keymaps or {})
	vim.notify("Poetry Shell enabled", vim.log.levels.INFO, {})
end

-- Check if the poetry shell plugin is installed
M.check = function()
	if state.pshel_installed then
		return true
	end
	local plugin_name = "poetry%-plugin%-shell"

	local result = vim.system({ "poetry", "self", "show", "plugins" }, { text = true }):wait()
	if not result.stdout or not result.stdout:find(plugin_name) then
		local msg = string.format("Poetry plugin not found. Please install %s", plugin_name)
		vim.notify(msg, vim.log.levels.ERROR, {})
		return false
	end
	state.pshel_installed = true
	return true
end

return M
