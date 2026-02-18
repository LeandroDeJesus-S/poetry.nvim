local M = {}

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

M.nvim_version = vim.version()

--- Returns true if the current version of neovim is greater than or equal to the specified version
--- @param majon integer major version
--- @param minor? integer minor version
M.nvim_ge = function(majon, minor)
	minor = minor or 0
	return M.nvim_version.major > majon or (M.nvim_version.major == majon and M.nvim_version.minor >= minor)
end

--- Gets the path to a Python executable.
--- Prioritizes a Poetry environment if found.
--- Otherwise, searches for common Python environment paths based on provided fallbacks.
--- @param fallbacks table|nil A list of directory names to search for Python environments.
--- @return string The path to the Python executable, or an empty string if not found.
M.getPython = function(fallbacks)
	local poetryEnv = M.getPoetryEnv()
	if poetryEnv ~= "" then
		return poetryEnv
	end

	-- try to find common python env paths
	local envNameCandidates = fallbacks or {}
	local wd = vim.fn.getcwd()

	for _, envName in ipairs(envNameCandidates) do
		local envPath = vim.fn.glob(vim.fs.joinpath(wd, envName, "bin", "python3"))
			or vim.fn.glob(vim.fs.joinpath(wd, envName, "bin", "python"))

		if envPath ~= "" then
			return envPath
		end
	end

	vim.notify("Unable to find python environment", vim.log.levels.ERROR, {})
	return ""
end

return M
