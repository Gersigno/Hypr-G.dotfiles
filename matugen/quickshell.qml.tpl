pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: colors
    <* for name, value in colors *>
    readonly property color {{name}}: "{{value.default.hex}}"
    <* endfor *>
}