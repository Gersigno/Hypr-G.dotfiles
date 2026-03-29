import QtQuick
import Quickshell
import Quickshell.Wayland

import "../components"
import "../config"
import "../services"
import "../utils"

Scope {
    id: root

    property int globalRadius: HyprlandConfig.radiusFull
    property color globalColor: Config.isOled ? "#000000" : Colors.background

    Component.onCompleted: {
        console.info("Loaded component: [ScreenCorners]")
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData

            visible: true
            color: "transparent"

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusiveZone: 0
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            mask: Region {
                item: null
            }

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            // Top-left
            InvertedCorner {
                corner: InvertedCorner.Corner.TopLeft
                cornerRadius: root.globalRadius
                cornerColor: root.globalColor
                anchors.top: parent.top
                anchors.left: parent.left
            }

            // Top-right
            InvertedCorner {
                corner: InvertedCorner.Corner.TopRight
                cornerRadius: root.globalRadius
                cornerColor: root.globalColor
                anchors.top: parent.top
                anchors.right: parent.right
            }

            // Bottom-left
            InvertedCorner {
                corner: InvertedCorner.Corner.BottomLeft
                cornerRadius: root.globalRadius
                cornerColor: root.globalColor
                anchors.bottom: parent.bottom
                anchors.left: parent.left
            }

            // Bottom-right
            InvertedCorner {
                corner: InvertedCorner.Corner.BottomRight
                cornerRadius: root.globalRadius
                cornerColor: root.globalColor
                anchors.bottom: parent.bottom
                anchors.right: parent.right
            }
        }
    }
}