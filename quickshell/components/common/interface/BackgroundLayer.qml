import QtQuick
import Quickshell

import qs.services
import "../../../utils"
import "../../../services"

Item {
    id: root

    readonly property color color_background: Colors.surface_container_highest
    readonly property color color_outline: Colors.outline_variant
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