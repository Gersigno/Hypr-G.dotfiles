-- VSCode-like keymap layout for LazyVim
-- Designed to be used with Kitty (or any terminal supporting the kitty keyboard protocol)
-- so that extended key combinations like <C-Enter>, <C-BS>, <C-/> etc. are transmitted correctly.

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  opts.desc = opts.desc or "VSCode: " .. lhs
  vim.keymap.set(mode, lhs, rhs, opts)
end

local function picker(name, opts)
  return function()
    local ok, Snacks = pcall(require, "snacks")
    if ok and Snacks.picker and Snacks.picker[name] then
      Snacks.picker[name](opts)
    else
      vim.notify("Snacks.picker not available", vim.log.levels.WARN)
    end
  end
end

-- ───────────────────────────────────────────────────────────────
-- File operations
-- ───────────────────────────────────────────────────────────────
map({ "n", "i" }, "<C-n>", "<cmd>enew<cr>", { desc = "New file" })
map({ "n", "i" }, "<C-o>", picker("files"), { desc = "Open file" })
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr>", { desc = "Save" })
map({ "n", "i", "v" }, "<C-S-s>", "<cmd>wa<cr>", { desc = "Save all" })
map({ "n", "i" }, "<C-w>", "<cmd>bd<cr>", { desc = "Close editor" })

-- Window navigation (replaces the default <C-h/j/k/l> Vim window maps that we
-- override with VSCode shortcuts like <C-h> for replace-in-file).
map("n", "<A-h>", "<C-w>h", { desc = "Window left" })
map("n", "<A-j>", "<C-w>j", { desc = "Window down" })
map("n", "<A-k>", "<C-w>k", { desc = "Window up" })
map("n", "<A-l>", "<C-w>l", { desc = "Window right" })

-- ───────────────────────────────────────────────────────────────
-- Edit / clipboard
-- ───────────────────────────────────────────────────────────────
map({ "n", "i" }, "<C-z>", "<cmd>undo<cr>", { desc = "Undo" })
map({ "n", "i" }, "<C-S-z>", "<cmd>redo<cr>", { desc = "Redo" })
map({ "n", "i" }, "<C-y>", "<cmd>redo<cr>", { desc = "Redo" })

map("n", "<C-x>", '"+dd', { desc = "Cut line" })
map("v", "<C-x>", '"+d', { desc = "Cut selection" })
map("i", "<C-x>", "<C-o>\"+dd", { desc = "Cut line" })

map("n", "<C-c>", '"+yy', { desc = "Copy line" })
map("v", "<C-c>", '"+y', { desc = "Copy selection" })
map("i", "<C-c>", "<C-o>\"+yy", { desc = "Copy line" })

map("n", "<C-v>", '"+p', { desc = "Paste" })
map("v", "<C-v>", '"+P', { desc = "Paste over selection" })
map("i", "<C-v>", "<C-r>+", { desc = "Paste" })

map({ "n", "i", "v" }, "<C-a>", "<Esc>ggVG", { desc = "Select all" })

-- ───────────────────────────────────────────────────────────────
-- Line manipulation
-- ───────────────────────────────────────────────────────────────
map("n", "<A-Up>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("n", "<A-Down>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("v", "<A-Up>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })
map("v", "<A-Down>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })

map("n", "<A-S-Up>", "<cmd>t .-1<cr>==", { desc = "Copy line up" })
map("n", "<A-S-Down>", "<cmd>t .<cr>==", { desc = "Copy line down" })
map("v", "<A-S-Up>", "yP`[V`]=gv", { desc = "Copy selection up" })
map("v", "<A-S-Down>", "yP`[V`]=gv", { desc = "Copy selection down" })

map("n", "<C-S-k>", "dd", { desc = "Delete line" })
map("i", "<C-S-k>", "<C-o>dd", { desc = "Delete line" })
map("v", "<C-S-k>", "d", { desc = "Delete selection" })
map("n", "<C-CR>", "o<Esc>", { desc = "Insert line below" })
map("i", "<C-CR>", "<C-o>o", { desc = "Insert line below" })
map("n", "<C-S-CR>", "O<Esc>", { desc = "Insert line above" })
map("i", "<C-S-CR>", "<C-o>O", { desc = "Insert line above" })

-- ───────────────────────────────────────────────────────────────
-- Word deletion
-- ───────────────────────────────────────────────────────────────
map("i", "<C-BS>", "<C-w>", { desc = "Delete word backward" })
map("i", "<C-Del>", "<C-o>de", { desc = "Delete word forward" })
map("n", "<C-BS>", "db", { desc = "Delete word backward" })
map("n", "<C-Del>", "de", { desc = "Delete word forward" })

-- ───────────────────────────────────────────────────────────────
-- Comments
-- ───────────────────────────────────────────────────────────────
map("n", "<C-/>", "gcc", { desc = "Toggle comment", remap = true })
map("v", "<C-/>", "gc", { desc = "Toggle comment", remap = true })
map("i", "<C-/>", "<C-o>gcc", { desc = "Toggle comment", remap = true })
-- Alternative key code for Ctrl+/ on some layouts
map("n", "<C-_>", "gcc", { desc = "Toggle comment", remap = true })
map("v", "<C-_>", "gc", { desc = "Toggle comment", remap = true })
map("i", "<C-_>", "<C-o>gcc", { desc = "Toggle comment", remap = true })

-- ───────────────────────────────────────────────────────────────
-- Search / replace
-- ───────────────────────────────────────────────────────────────
map({ "n", "i" }, "<C-f>", picker("lines"), { desc = "Find in file" })
map({ "n", "i" }, "<C-h>", "<cmd>GrugFarWithin<cr>", { desc = "Replace in file" })
map({ "n", "i" }, "<C-S-f>", picker("grep"), { desc = "Search across files" })
map({ "n", "i" }, "<C-S-h>", "<cmd>GrugFar<cr>", { desc = "Replace across files" })

-- ───────────────────────────────────────────────────────────────
-- Navigation / symbols
-- ───────────────────────────────────────────────────────────────
map({ "n", "i" }, "<C-g>", picker("lines"), { desc = "Go to line" })
map({ "n", "i" }, "<C-S-o>", picker("lsp_symbols"), { desc = "Go to symbol" })
map("n", "<F12>", picker("lsp_definitions"), { desc = "Go to definition" })
map("n", "<S-F12>", picker("lsp_references"), { desc = "Find references" })

-- ───────────────────────────────────────────────────────────────
-- Command palette / quick open
-- ───────────────────────────────────────────────────────────────
map({ "n", "i" }, "<C-p>", picker("files"), { desc = "Quick open" })
map({ "n", "i" }, "<C-S-p>", picker("commands"), { desc = "Command palette" })

-- ───────────────────────────────────────────────────────────────
-- Sidebar / explorer / terminal
-- ───────────────────────────────────────────────────────────────
map({ "n", "i" }, "<C-b>", picker("explorer"), { desc = "Toggle explorer" })
map({ "n", "i" }, "<C-S-e>", picker("explorer"), { desc = "Focus explorer" })

map({ "n", "i" }, "<C-`>", function()
  local ok, Snacks = pcall(require, "snacks")
  if ok and Snacks.terminal then
    Snacks.terminal()
  else
    vim.cmd("terminal")
  end
end, { desc = "Toggle terminal" })

-- ───────────────────────────────────────────────────────────────
-- Tabs / buffers
-- ───────────────────────────────────────────────────────────────
map({ "n", "i" }, "<C-Tab>", "<cmd>bnext<cr>", { desc = "Next editor" })
map({ "n", "i" }, "<C-S-Tab>", "<cmd>bprev<cr>", { desc = "Previous editor" })

for i = 1, 9 do
  map({ "n", "i" }, "<C-" .. i .. ">", "<cmd>buffer " .. i .. "<cr>", { desc = "Go to editor " .. i })
end

-- ───────────────────────────────────────────────────────────────
-- Notes / limitations
-- ───────────────────────────────────────────────────────────────
-- Multi-cursor (VSCode Ctrl+D / Ctrl+Shift+L) is not mapped because
-- there is no built-in equivalent in LazyVim. You can install a plugin
-- like `mg979/vim-visual-multi` or `smoka7/multicursors.nvim` and map
-- Ctrl+D / Ctrl+Shift+L to it here.
