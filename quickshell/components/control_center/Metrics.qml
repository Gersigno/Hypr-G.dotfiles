import QtQuick
import Quickshell

Item {
    id: root

    implicitWidth: 800
    implicitHeight: 400

    readonly property color backgroundColor: Config.isOled ? "#000" : Colors.background
    readonly property color foregroundColor: Config.isOled ? "#fff" : Colors.on_background

    Text {
        text: "Performances"
        color: foregroundColor
        font.pixelSize: 24
    }
}