import QtQuick
import Quickshell

import qs.services
import "../../utils"

Item {
    id: root

    implicitWidth: 800
    implicitHeight: 450

    readonly property color backgroundColor: Settings.isOled ? "#000" : Colors.background
    readonly property color foregroundColor: Colors.on_background

    Text {
        text: "Performances"
        color: foregroundColor
        font.pixelSize: 24
    }
}