<* for name, value in colors *>
${{name}} = rgba({{value.default.hex_stripped}}ff)
<* endfor *>

# Custom values
$shadow_active = rgba({{colors.shadow.default.hex_stripped}}4d)
$shadow_inactive = rgba({{colors.shadow.default.hex_stripped}}26)

$border_active = rgba({{colors.primary.default.hex_stripped}}4d)
$border_inactive = rgba({{colors.on_tertiary.default.hex_stripped}}bb)