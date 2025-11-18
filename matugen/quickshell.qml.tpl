pragma Singleton
import QtQuick

QtObject {
    id: colors
    <* for name, value in colors *>
    property color {{name}}: "{{value.default.hex}}"
    <* endfor *>
}