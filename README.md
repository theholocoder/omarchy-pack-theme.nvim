# Omarchy Pack Theme

A Neovim plugin that automatically installs and enables the Omarchy Quattro theme, if you don't use LazyVim.

## Requirements

This plugins uses `vim.pack.add()` so it requires Neovim 0.12+

## Installation

```lua
vim.pack.add({ "https://github.com/theholocoder/omarchy-pack-theme.nvim" })
require("omarchy-pack-theme").setup()
```

## Configuration

You shouldn't need any configuration, but just in case here are the default values:

```lua
require("omarchy-pack-theme").setup({
    -- if, for some reason, the Omarchy current theme directory is not the default one
    omarchy_current_dir = "~/.local/state/omarchy/current"
})
```
