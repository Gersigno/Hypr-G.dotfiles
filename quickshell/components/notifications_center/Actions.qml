import QtQuick
import QtQuick.Layouts
import Quickshell

import "../../config"
import "../../utils"
import "../../services"
import "../common/interactive"

Item {
    id: root

    property bool groupByApp: false

    implicitWidth: 300
    implicitHeight: 60

    readonly property color textColor: Config.isOled ? "#fff" : Colors.on_surface
    readonly property color textVariantColor: Config.isOled ? "#fff" : Colors.on_surface_variant
    readonly property color badgeColor: Colors.primary
    readonly property color badgeTextColor: Colors.on_primary
    readonly property string font: Config.fontFamily

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "Notifications"
                color: root.textColor
                font.family: root.font
                font.pixelSize: 14
                font.bold: true
            }

            // Count badge
            Rectangle {
                visible: Notifications.list.length > 0
                Layout.preferredWidth: countText.implicitWidth + 12
                Layout.preferredHeight: 18
                Layout.alignment: Qt.AlignVCenter
                radius: 9
                color: root.badgeColor

                Text {
                    id: countText
                    anchors.centerIn: parent
                    text: Notifications.list.length
                    color: root.badgeTextColor
                    font.family: root.font
                    font.pixelSize: 11
                    font.bold: true
                }
            }

            Item {
                Layout.fillWidth: true
            }

            // Do Not Disturb toggle
            RowLayout {
                spacing: 6

                Text {
                    text: Notifications.silent ? "󰂛" : ""
                    color: Notifications.silent ? Colors.primary : root.textVariantColor
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 15
                }

                Switch {
                    checked: Notifications.silent
                    onToggled: (value) => {
                        Notifications.silent = value
                        ToastService.show(value ? "󰂛   Do not disturb enabled" : "   Do not disturb disabled", 2000, "")
                    }
                }
            }

            Button {
                text: "Clear All"
                severity: Button.Severity.Secondary
                onClicked: Notifications.discardAllNotifications()
            }
        }

        // Sort selector
        Item {
            id: sortSelector
            Layout.alignment: Qt.AlignLeft
            width: sortRow.width + 4
            height: 24

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: Colors.surface_container_high
                border.color: Colors.surface_variant
                border.width: 1
            }

            Row {
                id: sortRow
                anchors.centerIn: parent
                spacing: 2

                Repeater {
                    model: [
                        { "label": "Time", "group": false },
                        { "label": "App", "group": true },
                    ]

                    delegate: Item {
                        required property var modelData
                        width: sortOptionText.implicitWidth + 16
                        height: 20

                        Rectangle {
                            anchors.fill: parent
                            radius: 10
                            color: (root.groupByApp === modelData.group) ? Colors.primary : "transparent"

                            Behavior on color {
                                ColorAnimation { duration: 120; easing.type: Easing.InOutQuad }
                            }
                        }

                        Text {
                            id: sortOptionText
                            anchors.centerIn: parent
                            text: modelData.label
                            color: (root.groupByApp === modelData.group) ? Colors.on_primary : Colors.on_surface_variant
                            font.family: root.font
                            font.pixelSize: 11
                            font.bold: root.groupByApp === modelData.group
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.groupByApp = modelData.group
                        }
                    }
                }
            }
        }
    }
}
