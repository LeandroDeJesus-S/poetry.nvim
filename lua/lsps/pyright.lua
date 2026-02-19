local M = {}
local state = require("poetry_nvim.utils.state")

local utils = require("poetry_nvim.utils")
local ui = require("poetry_nvim.utils.ui")
local log = require("poetry_nvim.utils.log")

--- Configures the Pyright LSP client to automatically detect and use a Python environment.
--- Creates an LspAttach autocmd that triggers when a Python file is opened.
--- Priority: Poetry env -> fallback envs -> manual user input.
--- For Neovim 0.12+, silences progress notifications to prevent popup spam.
---
--- @param opts poetry.LSPOptions: Options containing fallback_envs to search for Python environments
M.configure = function(opts)
	log.info("Configuring Pyright LSP with fallback_envs: " .. vim.inspect(opts.fallback_envs))
	vim.api.nvim_create_autocmd({ "LspAttach" }, {
		pattern = { "*.py" },
		group = vim.api.nvim_create_augroup("PoetryNvimLSP", { clear = true }),
		callback = function(ev)
			log.debug(string.format("LspAttach triggered for client_id: %d, buffer: %d", ev.data.client_id, ev.buf))

			if state.ready then
				local current_pyright_config
				if utils.nvim_ge(0, 11) then
					current_pyright_config = vim.lsp.config["pyright"]
					log.debug(string.format("using Neovim 0.11+ builtin lsp config approach"))
				else
					current_pyright_config = require("lspconfig").pyright
					log.debug(string.format("using lspconfig package for config"))
				end
				local python_path = current_pyright_config
					and current_pyright_config.settings
					and current_pyright_config.settings.python
					and current_pyright_config.settings.python.pythonPath
				log.debug(
					string.format("Skipping: state.ready is true, current pythonPath: '%s'", python_path or "not set")
				)

				return
			end
			if vim.bo.filetype ~= "python" then
				log.debug(string.format("Skipping: filetype is '%s' not 'python'", vim.bo.filetype))
				return
			end
			if state.manual_path_prompted then
				log.debug("Skipping: manual_path_prompted is true")
				return
			end

			local client = vim.lsp.get_client_by_id(ev.data.client_id)
			if client == nil or client.name ~= "pyright" then
				client = client or {}
				log.debug(string.format("Skipping: client name is '%s' not 'pyright'", client.name or "unknown"))
				return
			end

			local poetryEnv = utils.getPoetryEnv()
			log.debug(string.format("Poetry env result: '%s'", poetryEnv))
			if poetryEnv ~= "" then
				M.update_python_path(poetryEnv)
				return
			end

			local envpath = utils.getFallbackEnv(opts.fallback_envs)
			log.debug(string.format("Fallback env result: '%s'", envpath))
			if envpath ~= "" then
				M.update_python_path(envpath)
				return
			end

			log.warn("No Python environment found, prompting user for manual input")
			state.manual_path_prompted = true
			ui.input_user_python(M.update_python_path)
		end,
	})
	log.info("Pyright LSP configure: autocmd created for *.py files")
end

--- Updates the Pyright configuration with a new Python environment path.
--- Sets the pythonPath in the LSP config and restarts Pyright to apply changes.
--- For Neovim 0.11+, uses vim.lsp.config API; for older versions, uses lspconfig.
--- For Neovim 0.12+, adds a handler to suppress $/progress notifications.
---
--- @param envpath string: Full path to the Python executable or virtual environment
M.update_python_path = function(envpath)
	log.info(string.format("update_python_path called with envpath: '%s'", envpath))
	if utils.nvim_ge(0, 11) then
		log.debug("Using Neovim 0.11+ vim.lsp.config API")
		state.org_pyright_config = vim.lsp.config["pyright"]
		local config = {
			settings = {
				python = {
					pythonPath = envpath,
				},
			},
		}
		-- HACK: silence the progress notifications to avoid pyright flooding
		if utils.nvim_ge(0, 12) then
			config.handlers = { ["$/progress"] = function() end }
		end
		vim.lsp.config("pyright", config)
	else
		log.debug("Using lspconfig.setup API (Neovim < 0.11)")
		state.org_pyright_config = require("lspconfig").pyright
		require("lspconfig").pyright.setup({
			settings = {
				python = {
					pythonPath = envpath,
				},
			},
		})
	end

	state.ready = true
	log.debug("state.ready set to true")
	M.restart()
	vim.notify(string.format("Pyright using python from: %s", envpath), vim.log.levels.INFO, {})
end

--- Restarts the Pyright LSP client to apply configuration changes.
--- For Neovim 0.12+, uses vim.lsp.enable to disable/re-enable the client.
--- For older versions, falls back to vim.cmd.LspRestart.
M.restart = function()
	log.debug("restart called")
	if utils.nvim_ge(0, 12) then
		log.info("Using built-in vim.lsp.enable API (Neovim >= 0.12)")
		vim.lsp.enable("pyright", false)
		vim.lsp.enable("pyright", true)
		return
	end
	log.info("Using legacy vim.cmd.LspRestart('pyright')")
	vim.cmd.LspRestart("pyright")
end

--- Resets the Pyright configuration to its original state and restarts the client.
--- Restores the saved original config and restarts Pyright to apply it.
M.reset = function()
	log.info("reset called - restoring original pyright config")
	if utils.nvim_ge(0, 11) then
		log.debug("Using Neovim 0.11+ vim.lsp.config API to reset")
		vim.lsp.config("pyright", state.org_pyright_config)
	else
		log.debug("Using legacy lspconfig.setup to reset")
		require("lspconfig").pyright.setup(state.org_pyright_config)
	end
	M.restart()
end

return M
