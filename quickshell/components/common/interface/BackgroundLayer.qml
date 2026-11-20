import QtQuick
import Quickshell

import qs.services
import "../../../utils"
import "../../../services"

Item {
    id: root

    readonly property color color_background: Colors.surface_container
    readonly property color color_outline: Colors.surface_container_high
    readonly property string font: Settings.fontFamily

    Rectangle {
        id: background
        anchors.fill: parent
        color: root.color_background
        radius: HyprlandConfig.radius
        border.color: root.color_outline
        border.width: 1
    }
}