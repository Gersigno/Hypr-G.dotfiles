import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import "../../config"
import "../../utils"
import "../../services"
import "../common/interactive"

Item {
    id: root

    required property var modelData

    readonly property color backgroundColor: Colors.surface_container
    readonly property color hoverColor: Colors.surface_container_high
    readonly property color borderColor: Colors.surface_variant
    readonly property color textColor: Colors.on_surface
    readonly property color textVariantColor: Colors.on_surface_variant
    readonly property color criticalColor: Colors.error
    readonly property string font: Config.fontFamily

    implicitWidth: 300
    implicitHeight: mainColumn.implicitHeight + 24

    function iconSource(icon) {
        if (!icon) return ""
        if (icon.startsWith("/")) return "file://" + icon
        if (icon.startsWith("image://qsimage/")) return ""
        if (icon.startsWith("image://icon/")) {
            const name = icon.slice("image://icon/".length)
            if (name.startsWith("/")) return "file://" + name
            const res = Quickshell.iconPath(name, 48)
            return res ? (res.startsWith("image://") ? res : "file://" + res) : ""
        }
        const res = Quickshell.iconPath(icon, 48)
        return res ? (res.startsWith("image://") ? res : "file://" + res) : ""
    }

    readonly property bool bodyImageVisible: {
        const img = root.modelData.image
        if (img === "") return false
        if (img.startsWith("image://qsimage/")) return false
        if (img.startsWith("image://icon/")) return img.startsWith("image://icon//")
        return true
    }

    function formatTime(timestamp) {
        const date = new Date(timestamp)
        const now = new Date()
        const sameDay = date.toDateString() === now.toDateString()
        const fmt = sameDay ? "HH:mm"
                 : date.getFullYear() === now.getFullYear() ? "ddd d MMM"
                 : "d MMM yyyy"
        return Qt.formatDateTime(date, fmt)
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: HyprlandConfig.radius
        color: hoverArea.containsMouse ? root.hoverColor : root.backgroundColor
        border.color: root.borderColor
        border.width: 1

        Behavior on color {
            ColorAnimation { duration: 120; easing.type: Easing.InOutQuad }
        }

        // Accent color for critical notifications
        Rectangle {
            visible: root.modelData.urgency === "critical"
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: 3
            radius: 1.5
            color: root.criticalColor
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            // Icon
            Item {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignTop

                Image {
                    id: notifIcon
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: root.iconSource(root.modelData.appIcon || root.modelData.image)
                    visible: status === Image.Ready
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰵅"
                    visible: notifIcon.status !== Image.Ready
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 22
                    color: root.textVariantColor
                }
            }

            // Content
            ColumnLayout {
                id: mainColumn
                Layout.fillWidth: true
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        Layout.fillWidth: true
                        text: root.modelData.appName || ""
                        color: root.textVariantColor
                        font.family: root.font
                        font.pixelSize: 11
                        elide: Text.ElideRight
                        visible: text !== ""
                    }

                    Text {
                        text: root.formatTime(root.modelData.time)
                        color: root.textVariantColor
                        font.family: root.font
                        font.pixelSize: 10
                        opacity: 0.7
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: root.modelData.summary || ""
                    color: root.textColor
                    font.family: root.font
                    font.pixelSize: 13
                    font.bold: true
                    elide: Text.ElideRight
                    visible: text !== ""
                }

                Text {
                    Layout.fillWidth: true
                    text: root.modelData.body || ""
                    color: root.textVariantColor
                    font.family: root.font
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                    maximumLineCount: 5
                    elide: Text.ElideRight
                    visible: text !== ""
                }

                // Body image
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 96
                    visible: bodyImage.visible
                    radius: HyprlandConfig.radius - 2
                    color: "transparent"
                    clip: true

                    Image {
                        id: bodyImage
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        source: root.iconSource(root.modelData.image)
                        visible: root.bodyImageVisible && status !== Image.Error
                    }
                }

                // Actions
                Flow {
                    Layout.fillWidth: true
                    visible: root.modelData.actions.length > 0
                    spacing: 6

                    Repeater {
                        model: root.modelData.actions

                        delegate: Button {
                            required property var modelData
                            text: modelData.text
                            severity: Button.Severity.Secondary
                            onClicked: Notifications.attemptInvokeAction(root.modelData.notificationId, modelData.identifier)
                        }
                    }
                }
            }

            // Dismiss button
            Item {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                Layout.alignment: Qt.AlignTop

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Notifications.discardNotification(root.modelData.notificationId)

                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        color: parent.containsMouse ? root.textColor : root.textVariantColor
                        font.family: root.font
                        font.pixelSize: 18
                    }
                }
            }
        }
    }
}
