vim.cmd("highlight clear")
vim.g.colors_name = "matugen"

local ok, c = pcall(require, "matugen.palette")
if not ok then
  c = {
    mode = "dark",
    bg = "#121318",
    bg_alt = "#0d0e13",
    surface = "#1f2026",
    surface_lowest = "#0d0e13",
    surface_low = "#2a2b31",
    surface_container = "#272a31",
    surface_high = "#373840",
    surface_highest = "#42434a",
    surface_bright = "#3f4249",
    surface_dim = "#14151b",
    fg = "#e2e2e9",
    fg_dim = "#c4c5d0",
    fg_muted = "#8e909d",
    primary = "#b1c5ff",
    on_primary = "#162e60",
    primary_container = "#2f4578",
    on_primary_container = "#d9e2ff",
    primary_fixed = "#dae2ff",
    primary_fixed_dim = "#b1c5ff",
    secondary = "#c2c5dd",
    on_secondary = "#2b3042",
    secondary_container = "#424659",
    on_secondary_container = "#e1e2f9",
    secondary_fixed = "#e1e2f9",
    secondary_fixed_dim = "#c5c6e0",
    tertiary = "#e2bbdb",
    on_tertiary = "#442740",
    tertiary_container = "#5d3d57",
    on_tertiary_container = "#ffd7f5",
    tertiary_fixed = "#ffd7f5",
    tertiary_fixed_dim = "#e5bcdc",
    error = "#ffb4ab",
    on_error = "#690005",
    error_container = "#93000a",
    on_error_container = "#ffdad6",
    outline = "#8e909d",
    outline_variant = "#45464f",
    shadow = "#000000",
    scrim = "#000000",
    base00 = "#0f1624",
    base01 = "#262e3c",
    base02 = "#3e4554",
    base03 = "#555d6c",
    base04 = "#6d7483",
    base05 = "#858c9b",
    base06 = "#9ca4b3",
    base07 = "#b4bbcb",
    base08 = "#ff6199",
    base09 = "#d181a7",
    base0a = "#7f99d9",
    base0b = "#00b243",
    base0c = "#c186c1",
    base0d = "#6997ff",
    base0e = "#e762f4",
    base0f = "#61646f",
  }
end

local is_dark = c.mode == "dark"
vim.o.background = is_dark and "dark" or "light"

-- color utilities
local function hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

local function rgb_to_hex(r, g, b)
  return string.format("#%02x%02x%02x", math.floor(r + 0.5), math.floor(g + 0.5), math.floor(b + 0.5))
end

local function blend(fg, bg, ratio)
  local fr, fgv, fb = hex_to_rgb(fg)
  local br, bgv, bb = hex_to_rgb(bg)
  return rgb_to_hex(
    br + (fr - br) * ratio,
    bgv + (fgv - bgv) * ratio,
    bb + (fb - bb) * ratio
  )
end

local function adjust(hex, amount)
  local r, g, b = hex_to_rgb(hex)
  r, g, b = r / 255, g / 255, b / 255
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local l = (max + min) / 2
  local s = 0
  if max ~= min then
    s = l > 0.5 and (max - min) / (2 - max - min) or (max - min) / (max + min)
  end
  l = math.max(0, math.min(1, l + amount))
  if s == 0 then
    return rgb_to_hex(l * 255, l * 255, l * 255)
  end
  local function hue2rgb(p, q, t)
    if t < 0 then t = t + 1 end
    if t > 1 then t = t - 1 end
    if t < 1 / 6 then return p + (q - p) * 6 * t end
    if t < 1 / 2 then return q end
    if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
    return p
  end
  local q = l < 0.5 and l * (1 + s) or l + s - l * s
  local p = 2 * l - q
  local h = 0
  if max == r then
    h = ((g - b) / (max - min)) % 6
  elseif max == g then
    h = ((b - r) / (max - min)) + 2
  else
    h = ((r - g) / (max - min)) + 4
  end
  h = h / 6
  return rgb_to_hex(hue2rgb(p, q, h + 1 / 3) * 255, hue2rgb(p, q, h) * 255, hue2rgb(p, q, h - 1 / 3) * 255)
end

local s = {
  red = is_dark and c.base08 or adjust(c.base08, -0.12),
  orange = is_dark and c.base09 or adjust(c.base09, -0.12),
  yellow = is_dark and c.base0a or adjust(c.base0a, -0.12),
  green = is_dark and c.base0b or adjust(c.base0b, -0.12),
  cyan = is_dark and c.base0c or adjust(c.base0c, -0.12),
  blue = is_dark and c.base0d or adjust(c.base0d, -0.12),
  purple = is_dark and c.base0e or adjust(c.base0e, -0.12),
  brown = is_dark and c.base0f or adjust(c.base0f, -0.12),
}

-- intermediate foreground for dimmed explorer items (hidden / ignored)
local fg_hidden = c.fg_muted

local h = vim.api.nvim_set_hl
local function set(group, opts)
  h(0, group, opts)
end
local function link(from, to)
  set(from, { link = to })
end

-- editor
set("Normal", { fg = c.fg, bg = c.bg })
set("NormalNC", { fg = c.fg_dim, bg = c.bg })
set("NormalFloat", { fg = c.fg, bg = c.surface_container })
set("FloatBorder", { fg = c.outline_variant, bg = c.surface_container })
set("FloatTitle", { fg = c.primary, bg = c.surface_container, bold = true })
set("FloatFooter", { fg = c.fg_dim, bg = c.surface_container })
set("Cursor", { fg = c.bg, bg = c.fg })
link("CursorIM", "Cursor")
set("CursorLine", { bg = c.surface_low })
link("CursorColumn", "CursorLine")
set("ColorColumn", { bg = c.surface_low })
set("LineNr", { fg = c.surface_high, bg = c.bg })
set("CursorLineNr", { fg = c.primary, bg = c.bg, bold = true })
set("SignColumn", { bg = c.bg })
set("FoldColumn", { fg = c.fg_muted, bg = c.bg })
set("Folded", { fg = c.fg_dim, bg = c.surface_low })
set("Visual", { fg = c.on_primary_container, bg = c.primary_container })
link("VisualNOS", "Visual")
set("Search", { fg = c.bg, bg = s.yellow })
set("IncSearch", { fg = c.bg, bg = s.orange })
link("CurSearch", "IncSearch")
link("Substitute", "Search")
set("MatchParen", { fg = c.primary, bg = "NONE", bold = true, underline = true })
set("Whitespace", { fg = c.surface_high })
set("NonText", { fg = c.surface_high })
link("EndOfBuffer", "NonText")
link("SpecialKey", "NonText")
set("Pmenu", { fg = c.fg, bg = c.surface_container })
set("PmenuSel", { fg = c.on_primary, bg = c.primary })
set("PmenuSbar", { bg = c.surface_low })
set("PmenuThumb", { bg = c.fg_muted })
set("PmenuKind", { fg = s.cyan, bg = c.surface_container })
link("PmenuKindSel", "PmenuSel")
set("PmenuExtra", { fg = c.fg_dim, bg = c.surface_container })
link("PmenuExtraSel", "PmenuSel")
set("WildMenu", { fg = c.on_primary, bg = c.primary })
set("StatusLine", { fg = c.fg, bg = c.surface_low })
set("StatusLineNC", { fg = c.fg_dim, bg = c.surface_lowest })
link("StatusLineTerm", "StatusLine")
link("StatusLineTermNC", "StatusLineNC")
set("WinBar", { fg = c.fg, bg = c.bg, bold = true })
set("WinBarNC", { fg = c.fg_dim, bg = c.bg })
set("WinSeparator", { fg = c.surface_high })
link("VertSplit", "WinSeparator")
set("TabLine", { fg = c.fg_dim, bg = c.surface_low })
set("TabLineFill", { bg = c.bg })
set("TabLineSel", { fg = c.fg, bg = c.surface_container, bold = true })
set("Title", { fg = c.primary, bold = true })
set("Directory", { fg = c.primary })
set("Conceal", { fg = c.fg_muted })
set("Question", { fg = c.primary })
set("MoreMsg", { fg = c.primary })
set("ModeMsg", { fg = c.fg, bold = true })
set("WarningMsg", { fg = s.orange })
set("ErrorMsg", { fg = c.error })
set("QuickFixLine", { bg = c.surface_low })
link("qfLineNr", "LineNr")
set("SpellBad", { sp = c.error, undercurl = true })
set("SpellCap", { sp = s.yellow, undercurl = true })
set("SpellLocal", { sp = s.cyan, undercurl = true })
set("SpellRare", { sp = s.purple, undercurl = true })

-- syntax
set("Comment", { fg = c.fg_muted, italic = true })
set("Constant", { fg = s.purple })
set("String", { fg = s.green })
link("Character", "String")
set("Number", { fg = s.orange })
link("Boolean", "Number")
link("Float", "Number")
set("Identifier", { fg = c.fg })
set("Function", { fg = s.blue })
set("Statement", { fg = s.purple })
link("Conditional", "Statement")
link("Repeat", "Statement")
set("Label", { fg = c.primary })
set("Operator", { fg = c.fg_dim })
set("Keyword", { fg = s.purple })
link("Exception", "Statement")
set("PreProc", { fg = s.cyan })
link("Include", "PreProc")
link("Define", "PreProc")
link("Macro", "PreProc")
link("PreCondit", "PreProc")
set("Type", { fg = s.yellow })
link("StorageClass", "Type")
link("Structure", "Type")
link("Typedef", "Type")
set("Special", { fg = s.cyan })
link("SpecialChar", "Special")
set("Tag", { fg = s.purple })
set("Delimiter", { fg = c.fg_dim })
set("SpecialComment", { fg = c.primary, italic = true })
set("Debug", { fg = s.orange })
set("Underlined", { fg = s.blue, underline = true })
set("Ignore", { fg = c.fg_muted })
set("Error", { fg = c.error })
set("Todo", { fg = c.bg, bg = c.primary, bold = true })
set("Added", { fg = s.green })
set("Changed", { fg = s.orange })
set("Removed", { fg = s.red })

-- diff
set("DiffAdd", { fg = s.green, bg = blend(s.green, c.bg, 0.12) })
set("DiffChange", { fg = s.orange, bg = blend(s.orange, c.bg, 0.12) })
set("DiffDelete", { fg = s.red, bg = blend(s.red, c.bg, 0.12) })
set("DiffText", { fg = c.bg, bg = s.orange })

-- treesitter
link("@variable", "Identifier")
set("@variable.builtin", { fg = s.purple, italic = true })
set("@variable.parameter", { fg = c.fg_dim })
set("@variable.member", { fg = c.fg_dim })
link("@constant", "Constant")
link("@constant.builtin", "Constant")
link("@constant.macro", "Macro")
link("@module", "Type")
link("@module.builtin", "Type")
link("@label", "Label")
link("@string", "String")
set("@string.documentation", { fg = c.fg_dim })
link("@string.escape", "Special")
link("@string.special", "Special")
link("@string.regex", "Special")
link("@character", "String")
link("@character.special", "Special")
link("@number", "Number")
link("@number.float", "Float")
link("@boolean", "Boolean")
link("@function", "Function")
link("@function.builtin", "Function")
link("@function.call", "Function")
link("@function.macro", "Macro")
link("@function.method", "Function")
link("@function.method.call", "Function")
link("@constructor", "Type")
link("@operator", "Operator")
link("@keyword", "Keyword")
link("@keyword.coroutine", "Keyword")
link("@keyword.function", "Keyword")
link("@keyword.operator", "Keyword")
link("@keyword.import", "Keyword")
link("@keyword.type", "Keyword")
link("@keyword.modifier", "Keyword")
link("@keyword.return", "Keyword")
link("@keyword.debug", "Keyword")
link("@keyword.exception", "Keyword")
link("@keyword.conditional", "Keyword")
link("@keyword.repeat", "Keyword")
link("@keyword.storage", "Keyword")
link("@keyword.directive", "PreProc")
link("@keyword.directive.define", "Macro")
link("@type", "Type")
link("@type.builtin", "Type")
link("@type.definition", "Type")
link("@type.qualifier", "Keyword")
link("@attribute", "Type")
link("@attribute.builtin", "Type")
set("@property", { fg = c.fg_dim })
link("@punctuation.delimiter", "Delimiter")
link("@punctuation.bracket", "Delimiter")
link("@punctuation.special", "Special")
link("@comment", "Comment")
link("@comment.error", "DiagnosticError")
link("@comment.warning", "DiagnosticWarn")
link("@comment.todo", "Todo")
link("@comment.note", "DiagnosticInfo")
link("@diff.plus", "Added")
link("@diff.minus", "Removed")
link("@diff.delta", "Changed")
link("@tag", "Tag")
link("@tag.builtin", "Tag")
link("@tag.attribute", "@property")
link("@tag.delimiter", "Delimiter")
set("@markup.heading", { fg = c.primary, bold = true })
link("@markup.heading.1", "@markup.heading")
link("@markup.heading.2", "@markup.heading")
link("@markup.heading.3", "@markup.heading")
link("@markup.heading.4", "@markup.heading")
link("@markup.heading.5", "@markup.heading")
link("@markup.heading.6", "@markup.heading")
set("@markup.italic", { italic = true })
set("@markup.bold", { bold = true })
set("@markup.strikethrough", { strikethrough = true })
set("@markup.underline", { underline = true })
set("@markup.quote", { fg = c.fg_dim, italic = true })
set("@markup.math", { fg = s.blue })
set("@markup.link", { fg = s.blue, underline = true })
set("@markup.link.label", { fg = s.purple })
set("@markup.link.url", { fg = s.blue, underline = true })
set("@markup.raw", { fg = s.orange })
set("@markup.raw.block", { bg = c.surface_low })
set("@markup.list", { fg = c.primary })
set("@markup.list.checked", { fg = s.green })
set("@markup.list.unchecked", { fg = c.fg_dim })
set("@text", { fg = c.fg })
link("@reference", "Identifier")

-- lsp semantic tokens
link("@lsp.type.class", "Type")
link("@lsp.type.enum", "Type")
link("@lsp.type.interface", "Type")
link("@lsp.type.struct", "Type")
link("@lsp.type.typeParameter", "Type")
link("@lsp.type.enumMember", "Constant")
link("@lsp.type.function", "Function")
link("@lsp.type.method", "Function")
link("@lsp.type.macro", "Function")
link("@lsp.type.namespace", "Type")
link("@lsp.type.parameter", "Identifier")
link("@lsp.type.property", "@property")
link("@lsp.type.variable", "Identifier")
link("@lsp.type.decorator", "Function")
link("@lsp.type.event", "Type")
link("@lsp.type.modifier", "Keyword")
link("@lsp.type.string", "String")
link("@lsp.type.number", "Number")
link("@lsp.type.regexp", "@string.regex")
link("@lsp.type.operator", "Operator")
link("@lsp.type.builtinType", "@type.builtin")
link("@lsp.type.escapeSequence", "@string.escape")
link("@lsp.type.formatSpecifier", "@string.special")
link("@lsp.type.lifetime", "Keyword")
link("@lsp.type.generic", "Type")
link("@lsp.type.selfKeyword", "Keyword")
link("@lsp.type.selfTypeKeyword", "Keyword")
link("@lsp.typemod.class.defaultLibrary", "Type")
link("@lsp.typemod.function.defaultLibrary", "Function")
link("@lsp.typemod.method.defaultLibrary", "Function")
link("@lsp.typemod.variable.defaultLibrary", "@variable.builtin")

-- diagnostics
set("DiagnosticError", { fg = s.red })
set("DiagnosticWarn", { fg = s.orange })
set("DiagnosticInfo", { fg = s.blue })
set("DiagnosticHint", { fg = c.fg_dim })
set("DiagnosticOk", { fg = s.green })
set("DiagnosticVirtualTextError", { fg = s.red, bg = blend(s.red, c.bg, 0.08), italic = true })
set("DiagnosticVirtualTextWarn", { fg = s.orange, bg = blend(s.orange, c.bg, 0.08), italic = true })
set("DiagnosticVirtualTextInfo", { fg = s.blue, bg = blend(s.blue, c.bg, 0.08), italic = true })
set("DiagnosticVirtualTextHint", { fg = c.fg_dim, bg = c.surface_low, italic = true })
set("DiagnosticVirtualTextOk", { fg = s.green, bg = blend(s.green, c.bg, 0.08), italic = true })
set("DiagnosticUnderlineError", { sp = s.red, undercurl = true })
set("DiagnosticUnderlineWarn", { sp = s.orange, undercurl = true })
set("DiagnosticUnderlineInfo", { sp = s.blue, undercurl = true })
set("DiagnosticUnderlineHint", { sp = c.fg_dim, underline = true })
set("DiagnosticUnderlineOk", { sp = s.green, undercurl = true })
set("DiagnosticSignError", { fg = s.red })
set("DiagnosticSignWarn", { fg = s.orange })
set("DiagnosticSignInfo", { fg = s.blue })
set("DiagnosticSignHint", { fg = c.fg_dim })
set("DiagnosticSignOk", { fg = s.green })
set("DiagnosticFloatingError", { fg = s.red })
set("DiagnosticFloatingWarn", { fg = s.orange })
set("DiagnosticFloatingInfo", { fg = s.blue })
set("DiagnosticFloatingHint", { fg = c.fg_dim })

-- lsp
set("LspReferenceText", { bg = c.surface_high })
set("LspReferenceRead", { bg = c.surface_high })
set("LspReferenceWrite", { bg = c.surface_high })
set("LspSignatureActiveParameter", { fg = c.primary, bold = true, underline = true })
set("LspInlayHint", { fg = c.fg_muted, bg = c.surface_low, italic = true })
set("LspCodeLens", { fg = c.fg_dim, italic = true })
set("LspInfoBorder", { fg = c.outline_variant, bg = c.surface_container })

-- snacks
link("SnacksNormal", "Normal")
link("SnacksNormalNC", "NormalNC")
set("SnacksWinBar", { fg = c.fg, bg = c.bg, bold = true })
set("SnacksWinBarNC", { fg = c.fg_dim, bg = c.bg })
set("SnacksPickerTitle", { fg = c.primary, bg = c.surface_container, bold = true })
set("SnacksPickerBorder", { fg = c.outline_variant, bg = c.surface_container })
link("SnacksPickerBoxTitle", "SnacksPickerTitle")
link("SnacksPickerInputTitle", "SnacksPickerTitle")
link("SnacksPickerPreviewTitle", "SnacksPickerTitle")
set("SnacksPickerList", { bg = c.surface_container })
set("SnacksPickerListCursorLine", { bg = c.surface_low })
set("SnacksPickerInput", { bg = c.surface_container })
set("SnacksPickerPrompt", { fg = c.primary, bold = true })
set("SnacksPickerMatch", { fg = c.primary, bold = true })
set("SnacksPickerSelected", { fg = c.on_primary, bg = c.primary })
set("SnacksPickerFlags", { fg = c.fg_dim })
set("SnacksDashboardHeader", { fg = c.primary })
set("SnacksDashboardIcon", { fg = c.primary })
set("SnacksDashboardKey", { fg = c.primary, bold = true })
set("SnacksDashboardDesc", { fg = c.fg_dim })
set("SnacksDashboardDir", { fg = c.primary })
set("SnacksDashboardFooter", { fg = c.fg_dim })
set("SnacksDashboardSpecial", { fg = s.purple })
set("SnacksDashboardFile", { fg = c.fg })
set("SnacksDashboardTerminal", { fg = c.fg_dim })
set("SnacksIndent", { fg = c.surface_high })
set("SnacksIndentScope", { fg = c.primary })
set("SnacksIndentChunk", { fg = c.secondary })
set("SnacksNotifierError", { fg = s.red })
set("SnacksNotifierWarn", { fg = s.orange })
set("SnacksNotifierInfo", { fg = s.blue })
set("SnacksNotifierDebug", { fg = s.purple })
set("SnacksNotifierTrace", { fg = c.fg_dim })
set("SnacksNotifierTitle", { fg = c.fg, bold = true })
set("SnacksNotifierFooter", { fg = c.fg_dim })
set("SnacksNotifierBorder", { fg = c.outline_variant, bg = c.surface_container })
set("SnacksNotifierIconError", { fg = s.red })
set("SnacksNotifierIconWarn", { fg = s.orange })
set("SnacksNotifierIconInfo", { fg = s.blue })
set("SnacksNotifierIconDebug", { fg = s.purple })
set("SnacksNotifierIconTrace", { fg = c.fg_dim })
set("SnacksNotifierBorderError", { fg = s.red, bg = c.surface_container })
set("SnacksNotifierBorderWarn", { fg = s.orange, bg = c.surface_container })
set("SnacksNotifierBorderInfo", { fg = s.blue, bg = c.surface_container })
set("SnacksNotifierBorderDebug", { fg = s.purple, bg = c.surface_container })
set("SnacksNotifierBorderTrace", { fg = c.fg_dim, bg = c.surface_container })

-- explorer / picker file states
set("SnacksPickerPathIgnored", { fg = fg_hidden, italic = true })
set("SnacksPickerPathHidden", { fg = fg_hidden, italic = true })
set("SnacksPickerTree", { fg = c.surface_high })
set("SnacksPickerGitStatus", { fg = c.fg_dim })
set("SnacksPickerGitStatusAdded", { fg = s.green })
set("SnacksPickerGitStatusModified", { fg = s.orange })
set("SnacksPickerGitStatusDeleted", { fg = s.red })
set("SnacksPickerGitStatusRenamed", { fg = s.purple })
set("SnacksPickerGitStatusCopied", { fg = s.blue })
set("SnacksPickerGitStatusChanged", { fg = s.yellow })
set("SnacksPickerGitStatusUntracked", { fg = s.cyan })
set("SnacksPickerGitStatusIgnored", { fg = fg_hidden })
set("SnacksPickerGitStatusUnmerged", { fg = s.red })
set("SnacksPickerGitStatusStaged", { fg = s.green })

-- noice
set("NoiceCmdline", { bg = c.surface_container })
set("NoiceCmdlineIcon", { fg = c.primary })
set("NoiceCmdlineIconSearch", { fg = s.yellow })
set("NoiceCmdlinePrompt", { fg = c.primary, bold = true })
set("NoiceCmdlinePopup", { bg = c.surface_container })
set("NoiceCmdlinePopupBorder", { fg = c.outline_variant, bg = c.surface_container })
set("NoiceCmdlinePopupTitle", { fg = c.primary, bg = c.surface_container })
set("NoiceCompletionItemKindDefault", { fg = c.fg_dim })
local noice_kinds = {
  Text = c.fg,
  Method = s.blue,
  Function = s.blue,
  Constructor = s.yellow,
  Field = c.fg_dim,
  Variable = c.fg,
  Class = s.yellow,
  Interface = s.yellow,
  Module = s.yellow,
  Property = c.fg_dim,
  Unit = s.orange,
  Value = s.purple,
  Enum = s.yellow,
  Keyword = s.purple,
  Snippet = s.green,
  Color = s.orange,
  File = c.primary,
  Reference = s.purple,
  Folder = c.primary,
  EnumMember = s.orange,
  Constant = s.purple,
  Struct = s.yellow,
  Event = s.orange,
  Operator = c.fg_dim,
  TypeParameter = s.yellow,
  Copilot = s.green,
}
for kind, col in pairs(noice_kinds) do
  set("NoiceCompletionItemKind" .. kind, { fg = col })
end

-- bufferline
set("BufferLineFill", { bg = c.bg })
set("BufferLineBackground", { fg = c.fg_dim, bg = c.surface_low })
set("BufferLineBuffer", { fg = c.fg_dim, bg = c.surface_low })
set("BufferLineBufferVisible", { fg = c.fg_dim, bg = c.surface_low })
set("BufferLineBufferSelected", { fg = c.fg, bg = c.surface_container, bold = true })
set("BufferLineTab", { fg = c.fg_dim, bg = c.surface_low })
set("BufferLineTabSelected", { fg = c.fg, bg = c.primary })
set("BufferLineTabClose", { fg = c.fg_dim, bg = c.surface_low })
set("BufferLineCloseButton", { fg = c.fg_dim, bg = c.surface_low })
set("BufferLineCloseButtonVisible", { fg = c.fg_dim, bg = c.surface_low })
set("BufferLineCloseButtonSelected", { fg = c.fg, bg = c.surface_container })
set("BufferLineModified", { fg = s.green, bg = c.surface_low })
set("BufferLineModifiedSelected", { fg = s.green, bg = c.surface_container })
set("BufferLineModifiedVisible", { fg = s.green, bg = c.surface_low })
set("BufferLineDuplicate", { fg = c.fg_muted, bg = c.surface_low, italic = true })
set("BufferLineDuplicateSelected", { fg = c.fg_muted, bg = c.surface_container, italic = true })
set("BufferLineSeparator", { fg = c.bg, bg = c.surface_low })
set("BufferLineSeparatorSelected", { fg = c.bg, bg = c.surface_container })
set("BufferLineSeparatorVisible", { fg = c.bg, bg = c.surface_low })
set("BufferLineIndicatorSelected", { fg = c.primary, bg = c.surface_container })

-- which-key
set("WhichKey", { fg = c.primary })
set("WhichKeyGroup", { fg = s.blue })
set("WhichKeyDesc", { fg = c.fg })
set("WhichKeySeparator", { fg = c.fg_dim })
set("WhichKeyValue", { fg = c.fg_dim })
set("WhichKeyFloat", { bg = c.surface_container })
set("WhichKeyBorder", { fg = c.outline_variant, bg = c.surface_container })

-- trouble
set("TroubleNormal", { bg = c.surface_container })
set("TroubleText", { fg = c.fg })
set("TroubleCount", { fg = c.primary, bg = c.surface_low, bold = true })
set("TroubleIcon", { fg = c.fg })
set("TroubleIndent", { fg = c.surface_high })
set("TroubleLocation", { fg = c.fg_dim, italic = true })
set("TroubleFoldIcon", { fg = c.primary })
set("TroublePreview", { bg = c.surface_low })
set("TroubleSignError", { fg = s.red })
set("TroubleSignWarning", { fg = s.orange })
set("TroubleSignInformation", { fg = s.blue })
set("TroubleSignHint", { fg = c.fg_dim })
set("TroubleSignOther", { fg = c.fg_dim })

-- gitsigns
set("GitSignsAdd", { fg = s.green })
set("GitSignsChange", { fg = s.orange })
set("GitSignsDelete", { fg = s.red })
set("GitSignsChangedelete", { fg = s.orange })
set("GitSignsTopdelete", { fg = s.red })
set("GitSignsUntracked", { fg = c.fg_dim })
set("GitSignsAddNr", { fg = s.green })
set("GitSignsChangeNr", { fg = s.orange })
set("GitSignsDeleteNr", { fg = s.red })
set("GitSignsAddLn", { bg = blend(s.green, c.bg, 0.08) })
set("GitSignsChangeLn", { bg = blend(s.orange, c.bg, 0.08) })
set("GitSignsDeleteLn", { bg = blend(s.red, c.bg, 0.08) })
link("GitGutterAdd", "GitSignsAdd")
link("GitGutterChange", "GitSignsChange")
link("GitGutterDelete", "GitSignsDelete")

-- mason
set("MasonNormal", { bg = c.surface_container })
set("MasonHeader", { fg = c.bg, bg = c.primary, bold = true })
set("MasonHeaderSecondary", { fg = c.bg, bg = c.secondary, bold = true })
set("MasonHighlight", { fg = c.primary })
set("MasonHighlightBlock", { fg = c.on_primary, bg = c.primary })
set("MasonHighlightBlockBold", { fg = c.on_primary, bg = c.primary, bold = true })
set("MasonMuted", { fg = c.fg_dim })
set("MasonMutedBlock", { fg = c.fg_dim, bg = c.surface_low })
set("MasonError", { fg = c.error })
set("MasonHeading", { fg = c.primary, bold = true })
set("MasonLink", { fg = s.blue, underline = true })

-- lazy
set("LazyButton", { fg = c.fg, bg = c.surface_low })
set("LazyButtonActive", { fg = c.on_primary, bg = c.primary })
set("LazyComment", { fg = c.fg_muted, italic = true })
set("LazyCommit", { fg = s.green })
set("LazyDimmed", { fg = c.fg_dim })
set("LazyDir", { fg = c.primary })
set("LazyH1", { fg = c.on_primary, bg = c.primary, bold = true })
set("LazyProp", { fg = c.fg_dim })
set("LazyReasonCmd", { fg = s.orange })
set("LazyReasonFt", { fg = s.purple })
set("LazyReasonPlugin", { fg = s.blue })
set("LazyReasonRuntime", { fg = s.yellow })
set("LazyReasonSource", { fg = s.cyan })
set("LazyTaskDone", { fg = s.green })
set("LazyTaskError", { fg = c.error })
set("LazyUrl", { fg = s.blue, underline = true })
set("LazyValue", { fg = s.orange })
set("LazyLocal", { fg = s.purple })
set("LazyProgressDone", { fg = c.primary })
set("LazyProgressTodo", { fg = c.surface_high })

-- blink.cmp
set("BlinkCmpMenu", { bg = c.surface_container })
set("BlinkCmpMenuBorder", { fg = c.outline_variant, bg = c.surface_container })
set("BlinkCmpMenuSelection", { fg = c.on_primary, bg = c.primary })
set("BlinkCmpLabel", { fg = c.fg })
set("BlinkCmpLabelDeprecated", { fg = c.fg_muted, strikethrough = true })
set("BlinkCmpLabelMatch", { fg = c.primary, bold = true })
local blink_kinds = {
  Text = c.fg,
  Method = s.blue,
  Function = s.blue,
  Constructor = s.yellow,
  Field = c.fg_dim,
  Variable = c.fg,
  Class = s.yellow,
  Interface = s.yellow,
  Module = s.yellow,
  Property = c.fg_dim,
  Unit = s.orange,
  Value = s.purple,
  Enum = s.yellow,
  Keyword = s.purple,
  Snippet = s.green,
  Color = s.orange,
  File = c.primary,
  Reference = s.purple,
  Folder = c.primary,
  EnumMember = s.orange,
  Constant = s.purple,
  Struct = s.yellow,
  Event = s.orange,
  Operator = c.fg_dim,
  TypeParameter = s.yellow,
}
for kind, col in pairs(blink_kinds) do
  set("BlinkCmpKind" .. kind, { fg = col })
end

-- mini.hipatterns
set("MiniHipatternsFixme", { fg = c.on_error, bg = c.error, bold = true })
set("MiniHipatternsTodo", { fg = c.on_primary, bg = c.primary, bold = true })
set("MiniHipatternsHack", { fg = c.bg, bg = s.orange, bold = true })
set("MiniHipatternsNote", { fg = c.bg, bg = s.blue, bold = true })
set("MiniHipatternsPerf", { fg = c.bg, bg = s.purple, bold = true })

-- notify
set("NotifyERRORBody", { fg = c.fg, bg = c.surface_container })
set("NotifyWARNBody", { fg = c.fg, bg = c.surface_container })
set("NotifyINFOBody", { fg = c.fg, bg = c.surface_container })
set("NotifyDEBUGBody", { fg = c.fg, bg = c.surface_container })
set("NotifyTRACEBody", { fg = c.fg, bg = c.surface_container })
set("NotifyERRORBorder", { fg = c.error, bg = c.surface_container })
set("NotifyWARNBorder", { fg = s.orange, bg = c.surface_container })
set("NotifyINFOBorder", { fg = s.blue, bg = c.surface_container })
set("NotifyDEBUGBorder", { fg = s.purple, bg = c.surface_container })
set("NotifyTRACEBorder", { fg = c.fg_dim, bg = c.surface_container })
set("NotifyERRORIcon", { fg = c.error })
set("NotifyWARNIcon", { fg = s.orange })
set("NotifyINFOIcon", { fg = s.blue })
set("NotifyDEBUGIcon", { fg = s.purple })
set("NotifyTRACEIcon", { fg = c.fg_dim })
set("NotifyERRORTitle", { fg = c.error, bold = true })
set("NotifyWARNTitle", { fg = s.orange, bold = true })
set("NotifyINFOTitle", { fg = s.blue, bold = true })
set("NotifyDEBUGTitle", { fg = s.purple, bold = true })
set("NotifyTRACETitle", { fg = c.fg_dim, bold = true })

-- todo-comments
set("TodoFgTODO", { fg = c.primary })
set("TodoFgFIX", { fg = c.error })
set("TodoFgWARN", { fg = s.orange })
set("TodoFgHACK", { fg = s.orange })
set("TodoFgNOTE", { fg = s.blue })
set("TodoFgPERF", { fg = s.purple })
set("TodoBgTODO", { fg = c.on_primary, bg = c.primary, bold = true })
set("TodoBgFIX", { fg = c.on_error, bg = c.error, bold = true })
set("TodoBgWARN", { fg = c.bg, bg = s.orange, bold = true })
set("TodoBgHACK", { fg = c.bg, bg = s.orange, bold = true })
set("TodoBgNOTE", { fg = c.bg, bg = s.blue, bold = true })
set("TodoBgPERF", { fg = c.bg, bg = s.purple, bold = true })

-- render-markdown
set("RenderMarkdownH1", { fg = c.primary, bold = true })
set("RenderMarkdownH2", { fg = s.blue, bold = true })
set("RenderMarkdownH3", { fg = s.green, bold = true })
set("RenderMarkdownH4", { fg = s.orange, bold = true })
set("RenderMarkdownH5", { fg = s.purple, bold = true })
set("RenderMarkdownH6", { fg = c.fg_dim, bold = true })
set("RenderMarkdownCode", { bg = c.surface_low })
set("RenderMarkdownCodeInline", { fg = s.orange, bg = c.surface_low })
set("RenderMarkdownQuote", { fg = c.fg_dim, italic = true })
set("RenderMarkdownDash", { fg = c.primary })
set("RenderMarkdownLink", { fg = s.blue, underline = true })
set("RenderMarkdownMath", { fg = s.purple })
set("RenderMarkdownBullet", { fg = c.primary })

-- treesitter-context / indent-blankline
set("TreesitterContext", { bg = c.surface_low })
set("TreesitterContextBottom", { sp = c.surface_high, underline = true })
set("TreesitterContextLineNumber", { fg = c.primary, bg = c.surface_low })
set("TreesitterContextSeparator", { fg = c.surface_high })
set("IblIndent", { fg = c.surface_high })
set("IblScope", { fg = c.primary })
set("IblWhitespace", { fg = c.surface_high })

-- terminal colors
vim.g.terminal_color_0 = c.surface_lowest
vim.g.terminal_color_1 = s.red
vim.g.terminal_color_2 = s.green
vim.g.terminal_color_3 = s.yellow
vim.g.terminal_color_4 = s.blue
vim.g.terminal_color_5 = s.purple
vim.g.terminal_color_6 = s.cyan
vim.g.terminal_color_7 = c.fg
vim.g.terminal_color_8 = c.surface_high
vim.g.terminal_color_9 = adjust(s.red, is_dark and 0.1 or -0.1)
vim.g.terminal_color_10 = adjust(s.green, is_dark and 0.1 or -0.1)
vim.g.terminal_color_11 = adjust(s.yellow, is_dark and 0.1 or -0.1)
vim.g.terminal_color_12 = c.primary
vim.g.terminal_color_13 = c.tertiary
vim.g.terminal_color_14 = adjust(s.cyan, is_dark and 0.1 or -0.1)
vim.g.terminal_color_15 = c.fg_dim

-- auto-reload when matugen regenerates the palette
local palette_dir = vim.fn.stdpath("config") .. "/lua/matugen"
local palette_path = palette_dir .. "/palette.lua"

local function watch_palette()
  if _G.__matugen_watcher then
    return
  end
  local ok_fs, fs = pcall(vim.uv.new_fs_event)
  if not ok_fs then
    return
  end
  _G.__matugen_watcher = fs
  fs:start(palette_dir, {}, function(err)
    if err then
      return
    end
    vim.schedule(function()
      if _G.__matugen_debounce then
        return
      end
      _G.__matugen_debounce = true
      vim.defer_fn(function()
        _G.__matugen_debounce = nil
        if vim.fn.filereadable(palette_path) == 1 then
          package.loaded["matugen.palette"] = nil
          vim.cmd("colorscheme matugen")
        end
      end, 100)
    end)
  end)
end

watch_palette()
