local M = {}

---@class Options
---@field omarchy_current_dir ?string

---@type Options
local options = {
  omarchy_current_dir = "~/.config/omarchy/current"
}

local theme_file_contents = function()
  local _, contents = pcall(dofile, vim.fn.expand(vim.fs.joinpath(options.omarchy_current_dir, "theme/neovim.lua")))

  return contents
end

local parse_plugin_and_theme = function(theme_contents)
  local plugin_name, theme_name = "", ""
  local plugins, plugin_config = {}, {}

  for _, config in ipairs(theme_contents) do
    -- There should be 2 configs, one is the theme plugin and the other is LazyVim
    local which_is_it = config[1]
    if which_is_it == "LazyVim/LazyVim" then
      theme_name = config.opts.colorscheme
    else
      plugins = { which_is_it }
      -- handle dependencies
      if config.dependencies and #config.dependencies > 0 then
        plugins = config.dependencies
        table.insert(plugins, which_is_it)
      end
      plugin_config = config.opts or {}
      plugin_name = config.name

      -- handle some special cases
      if plugins[1] == "folke/tokyonight.nvim" then
        plugin_name = "tokyonight"
      elseif plugins[1] == "kepano/flexoki-neovim" then
        plugin_name = "flexoki"
      end
    end
  end

  plugin_name = plugin_name or theme_name

  return plugins, plugin_name, plugin_config, theme_name
end

local load_current_theme = function()
  local theme_contents = theme_file_contents()
  if not theme_contents then
    return
  end

  local plugins, plugin_name, plugin_config, theme_name = parse_plugin_and_theme(theme_contents)
  -- pack add all the required theme plugins
  for _, plugin in ipairs(plugins) do
    vim.pack.add({ "https://github.com/" .. plugin })
  end

  -- if the module exists, call its setup
  local ok, module = pcall(require, plugin_name)
  if ok and module.setup then
    module.setup(plugin_config)
  end

  -- reset nvim theme
  vim.cmd.colorscheme(theme_name)
end

M.setup = function(opts)
  opts = opts or {}
  options = vim.tbl_deep_extend("force", options, opts)

  -- check if pack is available
  if not vim.fn.exists("pack") then
    vim.notify("omarchy-pack-theme.nvim requires Neovim 0.12+", vim.log.levels.ERROR)

    return
  end

  load_current_theme()

  -- watch theme directory
  local watcher = vim.loop.new_fs_event()
  if watcher then
    watcher:start(vim.fn.expand(options.omarchy_current_dir), {}, function(err, filename)
      if err then
        vim.notify("Error while watching Omarchy current theme: " .. err, vim.log.levels.ERROR)

        return
      end

      if filename == "theme" then
        vim.schedule(load_current_theme)
      end
    end)
  else
    vim.notify("Unable to watch Omarchy current theme", vim.log.levels.WARNING)
  end
end

return M
