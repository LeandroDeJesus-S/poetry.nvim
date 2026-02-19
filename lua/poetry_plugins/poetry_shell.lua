--- Poetry Shell plugin for poetry.nvim.
--- Provides a keymap to toggle a Poetry shell terminal using snacks.nvim.
---
---@class poetry.PoetryShellOpts
---@field keymaps? table: Additional keymaps to add to the plugin

---@class poetry.PoetryShell
---@field setup fun(opts: poetry.PoetryShellOpts): nil Set up the poetry shell plugin
---@field check fun(): boolean Check if the poetry-plugin-shell is installed

---@type poetry.PoetryShell
local M = {}
local state = {}

-- TODO: create options to:
-- - [un]install packages
-- - configure poetry settings
-- - ...

--- Sets up keymaps for the poetry shell plugin using `which-key.nvim`.
---
--- This function defines a default keymap to toggle a poetry shell terminal
--- and allows for merging additional custom keymaps provided by the caller.
---
--- @param extra_keymaps table|nil Optional table of additional keymap definitions.
---   Each entry should be a table following the `which-key` API format
---   (e.g., `{ "<leader>k", "action", desc = "Description" }`).
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
	-- Merge any additional keymaps provided by the user with the default keymaps.
	-- `vim.list_extend` prepends `extra_keymaps` to `maps`, effectively giving
	-- precedence to user-defined keymaps if there are overlaps.
	maps = vim.list_extend(extra_keymaps or {}, maps)
	wk.add(maps)
end

--- Sets up the poetry shell plugin.
-- This function performs initial checks, configures keymaps,
-- and sends a notification to indicate that the plugin is active.
--- @param opts poetry.PoetryShellOpts Configuration options for the plugin.
M.setup = function(opts)
	if not M.check() then
		return
	end
	setup_keymaps(opts.keymaps or {})
	vim.notify("Poetry Shell enabled", vim.log.levels.INFO, {})
end

--- Checks if the "poetry-plugin-shell" is installed globally for Poetry.
--- This function caches the result in `state.pshel_installed` to avoid repeated system calls.
---
--- @returns boolean True if the plugin is installed, false otherwise.
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
