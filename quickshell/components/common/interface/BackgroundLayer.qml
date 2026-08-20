import QtQuick
import Quickshell

import qs.services
import "../../../utils"
import "../../../services"

Item {
    id: root

    readonly property color surface_container_highest: Colors.surface_container_highest
    readonly property color surface_variant: Colors.surface_variant
    readonly property string font: Settings.fontFamily

    Rectangle {
        id: background
        anchors.fill: parent
        color: root.surface_container_highest
        radius: HyprlandConfig.radius
        border.color: root.surface_variant
        border.width: 1
    }
}