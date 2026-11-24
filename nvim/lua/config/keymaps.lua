-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local layout = vim.g.keymap_layout or "default"
local available = { default = true, vscode = true }

if not available[layout] then
  vim.notify("Unknown keymap layout: " .. layout .. ". Using default.", vim.log.levels.WARN)
  layout = "default"
end

require("config.keymaps." .. layout)

vim.api.nvim_create_user_command("KeymapLayout", function(opts)
  require("config.keymaps._switch").switch(opts.args)
end, {
  nargs = 1,
  complete = function()
    return { "default", "vscode" }
  end,
  desc = "Switch keymap layout (requires restart)",
})
