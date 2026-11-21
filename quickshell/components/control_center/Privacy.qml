import QtQuick
import Quickshell

import qs.services as Services
import "../../utils"
import "../control_center/metrics"
import "./privacy"

Item {
    id: root

    implicitWidth: 900
    implicitHeight: 400

    readonly property color fg: Colors.on_background
    readonly property color muted: Services.Settings.isOled && Services.Theme.isDarkMode ? "#9aa0a6" : Colors.on_surface_variant
    readonly property string font: Services.Settings.fontFamily

    readonly property int activeCount:
        (Services.Privacy.microphoneActive ? 1 : 0) +
        (Services.Privacy.cameraActive ? 1 : 0) +
        (Services.Privacy.screenActive ? 1 : 0)

    Column {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        // ── Header ─────────────────────────────────────────────────────────
        Item {
            id: header
            width: parent.width
            height: 36

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0

                    Text {
                        text: "Privacy"
                        color: root.fg
                        font.family: root.font
                        font.pixelSize: 17
                        font.weight: Font.Bold
                    }

                    Text {
                        text: Services.Privacy.ready
                            ? (activeCount === 0 ? "No usage detected" : activeCount + " active usage" + (activeCount > 1 ? "s" : ""))
                            : "Loading..."
                        color: root.muted
                        font.family: root.font
                        font.pixelSize: 10
                    }
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                HeaderChip {
                    icon: ""
                    label: Services.Privacy.microphoneActive ? (Services.Privacy.microphoneApps.length + " app" + (Services.Privacy.microphoneApps.length > 1 ? "s" : "")) : "Inactive"
                    iconColor: Services.Privacy.microphoneActive ? Colors.primary : root.muted
                    textColor: Services.Privacy.microphoneActive ? root.fg : root.muted
                }
                HeaderChip {
                    icon: ""
                    label: Services.Privacy.cameraActive ? (Services.Privacy.cameraApps.length + " app" + (Services.Privacy.cameraApps.length > 1 ? "s" : "")) : "Inactive"
                    iconColor: Services.Privacy.cameraActive ? Colors.tertiary : root.muted
                    textColor: Services.Privacy.cameraActive ? root.fg : root.muted
                }
                HeaderChip {
                    icon: "󱣵"
                    label: Services.Privacy.screenActive ? (Services.Privacy.screenApps.length + " app" + (Services.Privacy.screenApps.length > 1 ? "s" : "")) : "Inactive"
                    iconColor: Services.Privacy.screenActive ? Colors.error : root.muted
                    textColor: Services.Privacy.screenActive ? root.fg : root.muted
                }
            }
        }

        // ── Cards ──────────────────────────────────────────────────────────
        Row {
            id: grid
            width: parent.width
            height: parent.height - header.height - parent.spacing
            spacing: 8

            PrivacyCard {
                width: (parent.width - parent.spacing * 2) / 3
                height: parent.height
                icon: ""
                title: "Microphone"
                iconColor: Colors.primary
                apps: Services.Privacy.microphoneApps
                active: Services.Privacy.microphoneActive
            }
            PrivacyCard {
                width: (parent.width - parent.spacing * 2) / 3
                height: parent.height
                icon: ""
                title: "Camera"
                iconColor: Colors.tertiary
                apps: Services.Privacy.cameraApps
                active: Services.Privacy.cameraActive
            }
            PrivacyCard {
                width: (parent.width - parent.spacing * 2) / 3
                height: parent.height
                icon: "󱣵"
                title: "Screen capture"
                iconColor: Colors.error
                apps: Services.Privacy.screenApps
                active: Services.Privacy.screenActive
            }
        }
    }
}
