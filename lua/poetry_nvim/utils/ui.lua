local M = {}
local fs = require("poetry_nvim.utils.fs")

--- Prompts the user to select a Python executable from automatically found candidates.
--- Searches the current working directory for Python executables using `find`.
--- If candidates are found, shows a vim.ui.select picker; otherwise prompts for manual input.
---
--- @param set_env fun(path: string): Callback function to receive the selected Python path
M.input_user_python = function(set_env)
	local wd = vim.fn.getcwd()
	-- Search for Python executables in the current working directory
	local py_exe_candidates = vim.fn.systemlist(
		"find "
			.. vim.fn.shellescape(wd)
			.. ' -readable \\( -regex ".*/bin/python[0-9\\.]*" -o -regex ".*/Scripts/python[0-9\\.]*\\.exe" \\) 2>/dev/null'
	)

	-- No candidates found - use manual input
	if not py_exe_candidates or py_exe_candidates == "" or #py_exe_candidates == 0 then
		M.prompt_manual_python_path(set_env)
		return
	end

	vim.ui.select(py_exe_candidates, {
		prompt = "Select Python executable:",
		format_item = function(item)
			return item
		end,
	}, function(item, idx)
		if idx then
			set_env(item)
			return
		end
		M.prompt_manual_python_path(set_env)
	end)
end

--- Prompts the user to manually enter a Python path via vim.ui.input.
--- Validates the input using fs.validate_and_resolve_python_path.
--- Calls set_env with the validated path or shows an error if invalid.
---
--- @param set_env fun(path: string): Callback function to receive the validated Python path
M.prompt_manual_python_path = function(set_env)
	vim.ui.input({
		prompt = "Python path not found. Enter path manually (leave empty to skip): ",
		default = "",
		completion = "file",
	}, function(user_path)
		if not user_path or user_path == "" then
			vim.notify("Unable to find python environment", vim.log.levels.ERROR, {})
			return
		end
		local validated = fs.validate_and_resolve_python_path(user_path)
		if validated == "" then
			vim.notify("Invalid python environment", vim.log.levels.ERROR, {})
			return
		end
		set_env(validated)
	end)
end

return M
