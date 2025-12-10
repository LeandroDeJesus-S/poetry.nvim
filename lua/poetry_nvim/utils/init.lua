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

M.nvim_011 = vim.version.ge(vim.version(), { 0, 11, 0 })

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
