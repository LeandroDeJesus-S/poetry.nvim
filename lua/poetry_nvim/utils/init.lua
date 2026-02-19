local fs = require("poetry_nvim.utils.fs")

local M = {
	nvim_version = vim.version(),
}

--- Executes `poetry env info -e` to get the current Poetry virtual environment path.
--- Returns an empty string if Poetry is not installed or no environment is found.
---
--- @return string: Path to the Python executable in the Poetry environment, or empty string
M.getPoetryEnv = function()
	if vim.fn.executable("poetry") == 0 then
		vim.notify("poetry not found, please install it", vim.log.levels.ERROR, {})
		return ""
	end

	local envPythonPath = vim.fn.trim(vim.fn.system("poetry env info -e"))
	if string.find(envPythonPath, "could not find") then
		return ""
	end

	return envPythonPath
end

--- Returns true if the current version of neovim is greater than or equal to the specified version
--- @param majon integer major version
--- @param minor? integer minor version
M.nvim_ge = function(majon, minor)
	minor = minor or 0
	return M.nvim_version.major > majon or (M.nvim_version.major == majon and M.nvim_version.minor >= minor)
end

--- Searches for a Python executable in common virtual environment directories.
--- Checks each fallback directory name in the current working directory and validates
--- the path using the fs module. Returns the first valid Python executable found.
---
--- @param fallbacks string[]: List of directory names to search (e.g., {".venv", "venv"})
--- @return string: Path to Python executable, or empty string if not found
M.getFallbackEnv = function(fallbacks)
	local envNameCandidates = fallbacks or {}
	local wd = vim.fn.getcwd()

	for _, envName in ipairs(envNameCandidates) do
		local envPath = vim.fn.glob(vim.fs.joinpath(wd, envName, "bin"))
		local path = fs.validate_and_resolve_python_path(envPath)

		if path ~= "" then
			return path
		end
	end

	return ""
end

return M
