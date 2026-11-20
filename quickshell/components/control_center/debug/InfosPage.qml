import QtQuick

import qs.services

import "../../../utils"
import "../../common/interface"

Rectangle {
    id: page

    color: "transparent"
    clip: true

    BackgroundLayer {
        anchors.fill: parent
    }

    Flickable {
        anchors.fill: parent
        anchors.margins: 16
        contentHeight: infosColumn.implicitHeight
        clip: true

        Column {
            id: infosColumn
            width: parent.width
            spacing: 6

            Text {
                text: "Hyprland config debug"
                color: Colors.on_surface_variant
                font.pixelSize: 18
                font.bold: true
            }

            InfoRow {
                label: "Last read"
                value: HyprlandConfig.lastReadText()
            }

            InfoRow {
                label: "decoration:rounding (radius)"
                value: HyprlandConfig.radius
            }

            InfoRow {
                label: "radiusFull (radius + gapsOut)"
                value: HyprlandConfig.radiusFull
            }

            InfoRow {
                label: "general:gaps_out (gapsOut)"
                value: HyprlandConfig.gapsOut
            }

            InfoRow {
                label: "decoration:active_opacity"
                value: HyprlandConfig.activeOpacity
            }

            InfoRow {
                label: "decoration:inactive_opacity"
                value: HyprlandConfig.inactiveOpacity
            }

            InfoRow {
                label: "decoration:shadow:range"
                value: HyprlandConfig.shadowRange
            }

            InfoRow {
                label: "decoration:shadow:render_power"
                value: HyprlandConfig.shadowRenderPower
            }

            InfoRow {
                label: "workspacesByMonitor"
                value: JSON.stringify(HyprlandConfig.workspacesByMonitor)
            }
        }
    }
}
