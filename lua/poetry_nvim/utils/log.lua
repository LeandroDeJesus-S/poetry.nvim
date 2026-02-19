--- Logging utility for poetry.nvim.
--- Writes log messages to vim.fn.stdpath("state") .. "/poetry_nvim.log".
--- Log level can be set via POETRY_NVIM_LOGLEVEL environment variable (DEBUG, INFO, WARN, ERROR).
--- Default level is WARN.
---
---@class poetry.Log
---@field log_level string: Current log level (DEBUG, INFO, WARN, ERROR)
---@field info fun(message: string): nil Log an info message
---@field debug fun(message: string): nil Log a debug message
---@field warn fun(message: string): nil Log a warning message
---@field error fun(message: string): nil Log an error message

---@type poetry.Log
local M = {
	log_level = vim.env.POETRY_NVIM_LOGLEVEL or "WARN",
}

local levels = {
	DEBUG = 1,
	INFO = 2,
	WARN = 3,
	ERROR = 4,
}

local log_file_path = vim.fn.stdpath("state") .. "/poetry_nvim.log"

local function log_message(level, message)
	if levels[level:upper()] and levels[level:upper()] < levels[M.log_level:upper()] then
		return
	end

	local file = io.open(log_file_path, "a")
	if file then
		local timestamp = os.date("[%Y-%m-%d %H:%M:%S]")
		file:write(string.format("%s [%s] %s\n", timestamp, string.upper(level), message))
		file:close()
	end
end

function M.info(message)
	log_message("info", message)
end

function M.debug(message)
	log_message("debug", message)
end

function M.warn(message)
	log_message("warn", message)
end

function M.error(message)
	log_message("error", message)
end

return M
