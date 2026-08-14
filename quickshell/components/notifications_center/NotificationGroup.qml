import QtQuick
import QtQuick.Layouts
import Quickshell

import "."
import "../../config"
import "../../utils"
import "../../services"
import "../common/interactive"

Item {
    id: root

    required property var modelData
    readonly property string appName: root.modelData ?? ""
    property var group: Notifications.groupsByAppName[root.appName] ?? null

    readonly property color textColor: Colors.on_surface
    readonly property color textVariantColor: Colors.on_surface_variant
    readonly property color badgeColor: Colors.primary
    readonly property color badgeTextColor: Colors.on_primary
    readonly property string font: Config.fontFamily

    implicitWidth: 300
    implicitHeight: column.implicitHeight

    function formatTime(timestamp) {
        const date = new Date(timestamp)
        const now = new Date()
        const sameDay = date.toDateString() === now.toDateString()
        const fmt = sameDay ? "HH:mm"
                 : date.getFullYear() === now.getFullYear() ? "ddd d MMM"
                 : "d MMM yyyy"
        return Qt.formatDateTime(date, fmt)
    }

    function iconSource(icon) {
        if (!icon) return ""
        if (icon.startsWith("/")) return "file://" + icon
        if (icon.startsWith("image://qsimage/")) return ""
        if (icon.startsWith("image://icon/")) {
            const name = icon.slice("image://icon/".length)
            if (name.startsWith("/")) return "file://" + name
            const res = Quickshell.iconPath(name, 24)
            return res ? (res.startsWith("image://") ? res : "file://" + res) : ""
        }
        const res = Quickshell.iconPath(icon, 24)
        return res ? (res.startsWith("image://") ? res : "file://" + res) : ""
    }

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 6

        // Header
        RowLayout {
            width: parent.width
            spacing: 8

            // App icon
            Item {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                Layout.alignment: Qt.AlignVCenter

                Image {
                    id: groupIcon
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: root.group ? root.iconSource(root.group.appIcon) : ""
                    visible: status === Image.Ready
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰵅"
                    visible: groupIcon.status !== Image.Ready
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 13
                    color: root.textVariantColor
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.appName || "Unknown"
                color: root.textColor
                font.family: root.font
                font.pixelSize: 12
                font.bold: true
                elide: Text.ElideRight
            }

            // Count badge
            Rectangle {
                visible: root.group && root.group.notifications.length > 1
                Layout.preferredWidth: countText.implicitWidth + 12
                Layout.preferredHeight: 16
                Layout.alignment: Qt.AlignVCenter
                radius: 8
                color: root.badgeColor

                Text {
                    id: countText
                    anchors.centerIn: parent
                    text: root.group ? root.group.notifications.length : 0
                    color: root.badgeTextColor
                    font.family: root.font
                    font.pixelSize: 10
                    font.bold: true
                }
            }

            Text {
                visible: root.group !== null
                text: root.group ? root.formatTime(root.group.time) : ""
                color: root.textVariantColor
                font.family: root.font
                font.pixelSize: 10
                opacity: 0.7
            }

            Button {
                text: "Clear"
                severity: Button.Severity.Secondary
                onClicked: {
                    const ids = root.group?.notifications.map((notif) => notif.notificationId) ?? []
                    ids.forEach((id) => Notifications.discardNotification(id))
                }
            }
        }

        // Notifications of the group
        Repeater {
            model: root.group?.notifications ?? []

            delegate: NotificationCard {
                width: column.width
            }
        }
    }
}
