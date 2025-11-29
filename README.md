# `poetry.nvim`

A lightweight [Neovim](https://neovim.io/) plugin to manage Python packages using [Poetry](https://python-poetry.org/).

This plugin helps you to seamlessly integrate your Poetry environment with Neovim and the Pyright LSP.

> Note
I built this plugin just to learn how to create and modify Neovim plugins. Feel free to use and modify it as you need.

## ✨ Features

- Automatically detects and uses the Poetry environment for your project.
- Easily extend the plugin with custom plugins.
- Automatically configures the Pyright LSP to use the Poetry environment.
- Toggles a terminal with a Poetry shell.
- Easy to install and configure.

## 📋 Requirements

-   [Neovim](https://neovim.io/) >= 0.8.0
-   [Poetry](https://python-poetry.org/)
-   [Pyright](https://github.com/microsoft/pyright)
-   [which-key.nvim](https://github.com/folke/which-key.nvim)
-   [snacks.nvim](https://github.com/folke/snacks.nvim) (optional, for use with poetry shell plugin)

## 📦 Installation

This plugin was build and tested using `lazy.nvim`, but you can install using your favorite plugin manager.

```lua
return {
	{ "folke/which-key.nvim" },
	{ "folke/snacks.nvim" },
	{
		"LeandroDeJesus-S/poetry.nvim",
		---@type poetry.Options
		opts = {
			---@type poetry.PluginSpec[]
			plugins = {
				-- optional (false by default)
				poetry_shell = { -- just poetry_shell is supported for now
					enabled = true,
					opts = {
						keymaps = { -- default keymaps
							{
								"<c-p>",
								function()
									Snacks.terminal("poetry shell")
								end,
								mode = { "n", "t" },
								desc = "Toggle Poetry Shell",
							},
						},
					},
				},
			},
            keymaps = {
                {
                    mode = "n",
                    "<leader>pd",
                    lsp.reset,
                    desc = "Disable Poetry LSP Environment setup",
                },
            },
            lsp = "pyright", -- just pyright is supported for now
            -- a list of custom python environments to try to find if poetry env is not found.
            -- the list with the default can be found here https://github.com/LeandroDeJesus-S/poetry.nvim/blob/main/lua/poetry_nvim.lua#L15
            fallback_envs = { "my_custom_env" }, 
		},
	},
}
```

### ⌨️ Keymaps

The plugin sets up the following keymaps using `which-key.nvim`:

| Keymap      | Description                     |
| ----------- | ------------------------------- |
| `<leader>ps` | Toggle Poetry Shell             |
| `<leader>pd` | Disable Poetry Environment setup|

## 🙌 Contributing

Contributions are welcome! Please feel free to open an issue or a pull request.

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
