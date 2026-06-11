import QtQuick
import Quickshell
import QtCore

import "../../../config"
import "../../../utils"
import "../../../services"

Item {
    id: root

    readonly property color surface_container_highest: Config.isOled ? "#fff" : Colors.surface_container_highest
    readonly property color surface_variant: Config.isOled ? "#000" : Colors.surface_variant
    readonly property string font: Config.fontFamily

    Rectangle {
        id: background
        anchors.fill: parent
        color: root.surface_container_highest
        radius: HyprlandConfig.radius
        border.color: root.surface_variant
        border.width: 1
    }
}