-- Keep the editor's existing navigation outside Herdr.
if vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= "" then
  local config = vim.env.XDG_CONFIG_HOME or vim.fn.expand("~/.config")
  local plugins = vim.json.decode(table.concat(vim.fn.readfile(config .. "/herdr/plugins.json"), "\n"))
  for _, plugin in ipairs(plugins) do
    if plugin.plugin_id == "vim-herdr-navigation" then
      dofile(plugin.plugin_root .. "/editor/nvim.lua")
      break
    end
  end
end
