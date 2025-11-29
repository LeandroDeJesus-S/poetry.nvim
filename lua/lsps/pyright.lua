local M = {}
local state = {}

local utils = require("utils.utils")

M.restart = function()
	vim.cmd.LspRestart()
end

---@param opts poetry.LSPOptions
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
			if utils.nvim_011 then
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

--- Remove the poetry environment from the pythonPath option and then restart the lsp
M.reset = function()
	if utils.nvim_011 then
		vim.lsp.config("pyright", state.org_pyright_config)
	else
		require("lspconfig").pyright.setup(state.org_pyright_config)
	end
	M.restart()
end

return M
