local M = {}
local state = {}

local utils = require("poetry_nvim.utils")

---@brief Restarts the active LSP client(s).
---@details This function attempts to restart the LSP client(s) associated with the current buffer.
--- It first checks if Neovim is version 0.12 or newer, using `vim.cmd.lsp('restart')` for modern LSP commands.
--- If the Neovim version is older, it falls back to the `vim.cmd.LspRestart()` command, typically provided by `nvim-lspconfig`.
--- @return nil
M.restart = function()
	-- uses built-in lsp cmd otherwise fallback to lspconfig
	if utils.nvim_ge(0, 12) then
		vim.cmd.lsp("restart")
		return
	end
	vim.cmd.LspRestart()
end

---Configures the Pyright LSP client to use a specific Python environment.
---It sets the `pythonPath` based on `opts.fallback_envs` when a `pyright` client attaches to a Python buffer.
---@param opts poetry.LSPOptions
---@return nil
M.configure = function(opts)
	vim.api.nvim_create_autocmd({ "LspAttach" }, {
		pattern = { "*.py" },
		callback = function(ev)
			if state.ready or vim.bo.filetype ~= "python" then -- avoid infinite loop
				return
			end

			local client = vim.lsp.get_client_by_id(ev.data.client_id)
			if client == nil or client.name ~= "pyright" then
				return
			end

			local envpath = utils.getPython(opts.fallback_envs)
			if utils.nvim_ge(0, 11) then
				state.org_pyright_config = vim.lsp.config["pyright"]
				vim.lsp.config("pyright", {
					settings = {
						python = {
							pythonPath = envpath,
						},
					},
				})
			else
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
			M.restart()
			vim.notify(string.format("Pyright using python from: %s", envpath), vim.log.levels.INFO, {})
		end,
	})
end

--- Resets the pyright LSP client configuration to its original state and then restarts the client.
--- @return nil
M.reset = function()
	if utils.nvim_ge(0, 11) then
		vim.lsp.config("pyright", state.org_pyright_config)
	else
		require("lspconfig").pyright.setup(state.org_pyright_config)
	end
	M.restart()
end

return M
