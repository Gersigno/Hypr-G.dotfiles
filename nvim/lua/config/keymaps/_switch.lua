local M = {}

function M.switch(layout)
  if layout ~= "default" and layout ~= "vscode" then
    vim.notify("Invalid layout. Use 'default' or 'vscode'.", vim.log.levels.ERROR)
    return
  end

  local current = vim.g.keymap_layout or "default"
  if layout == current then
    vim.notify("Keymap layout is already '" .. layout .. "'.", vim.log.levels.INFO)
    return
  end

  local path = vim.fn.stdpath("config") .. "/lua/config/options.lua"
  local lines = vim.fn.readfile(path)
  local found = false

  for i, line in ipairs(lines) do
    if line:match("^vim%.g%.keymap_layout%s*=%s*['\"].-['\"]") then
      lines[i] = 'vim.g.keymap_layout = "' .. layout .. '"'
      found = true
      break
    end
  end

  if not found then
    vim.notify("Could not find 'vim.g.keymap_layout' in options.lua", vim.log.levels.ERROR)
    return
  end

  local ok, err = pcall(vim.fn.writefile, lines, path)
  if not ok then
    vim.notify("Failed to write options.lua: " .. err, vim.log.levels.ERROR)
    return
  end

  vim.g.keymap_layout = layout
  vim.notify("Keymap layout set to '" .. layout .. "'. Restart Neovim to apply.", vim.log.levels.INFO)
end

return M
