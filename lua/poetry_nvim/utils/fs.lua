local log = require("poetry_nvim.utils.log")

---@class poetry.Fs
---@field python_bin_dir string: The bin directory name ("bin" on Unix, "Scripts" on Windows)
---@field is_windows boolean: Whether the operating system is Windows
---@field validate_and_resolve_python_path fun(user_path: string): string Validates and resolves a Python path

local M = {
	is_windows = vim.loop.os_uname().version:match("Windows"),
}

M.python_bin_dir = M.is_windows and "Scripts" or "bin"

--- Validates and resolves a user-provided Python path.
--- First checks if the path is a direct executable. If not, checks if it's a directory
--- and searches for Python executables in the bin/Scripts subdirectory.
---
--- @param user_path string: Path to a Python executable or virtual environment directory
--- @return string: Full path to Python executable, or empty string if invalid
function M.validate_and_resolve_python_path(user_path)
	user_path = vim.fn.expand(user_path)

	if vim.fn.filereadable(user_path) and vim.fn.executable(user_path) == 1 then
		return user_path
	end

	if vim.fn.isdirectory(user_path) == 1 then
		log.debug(string.format("user_path is a directory: %s", user_path))
		local python_bin_path = vim.fs.joinpath(user_path, M.python_bin_dir)
		log.debug(string.format("Searching in: %s", python_bin_path))

		local python_glob = vim.fn.globpath(python_bin_path, "python*")
		log.debug(string.format("globpath result: %s", python_glob))

		if python_glob and python_glob ~= "" then
			local matches = vim.fn.split(python_glob, "\n")
			for _, match in ipairs(matches) do
				if vim.fn.executable(match) == 1 then
					log.debug(string.format("Found executable: %s", match))
					return match
				end
			end
		end
	end

	return ""
end

return M
