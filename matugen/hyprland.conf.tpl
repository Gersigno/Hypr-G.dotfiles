<* for name, value in colors *>
${{name}} = rgba({{value.default.hex_stripped}}ff)
<* endfor *>

# Custom values
$shadow_active = rgba({{colors.shadow.default.hex_stripped}}4d)
$shadow_inactive = rgba({{colors.shadow.default.hex_stripped}}26)

$border_active = rgba({{colors.primary.default.hex_stripped}}d0)
$border_inactive = rgba({{colors.on_primary.default.hex_stripped}}ff)
$border_secondary = rgba({{colors.shadow.default.hex_stripped}}8e)