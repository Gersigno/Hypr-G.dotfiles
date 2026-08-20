import QtQuick
import QtQuick.Layouts
import Quickshell

import "../notifications_center"
import "../../services"
import qs.services
import "../../utils"

Item {
    id: root

    property int topBarHeight: 0
    readonly property int fullRadius: HyprlandConfig.radiusFull

    readonly property color foregroundColor:Colors.on_background
    readonly property color variantColor: Settings.isOled ? "#fff" : Colors.on_surface_variant
    readonly property string font: Settings.fontFamily

    // Flat list of all notifications, newest first
    readonly property var chronologicalList: Notifications.list.slice().sort((a, b) => b.time - a.time)

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        Actions {
            id: actions
            Layout.fillWidth: true
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: listView
                anchors.fill: parent
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                model: actions.groupByApp ? Notifications.appNameList : root.chronologicalList
                spacing: 8

                header: Item { width: 1; height: 2 }
                footer: Item { width: 1; height: 12 }

                add: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                displaced: Transition {
                    NumberAnimation {
                        properties: "y"
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                delegate: actions.groupByApp ? groupedDelegate : flatDelegate
            }

            Component {
                id: flatDelegate
                NotificationCard {
                    width: listView.width
                }
            }

            Component {
                id: groupedDelegate
                NotificationGroup {
                    width: listView.width
                }
            }

            // Empty state
            Item {
                anchors.fill: parent
                visible: Notifications.list.length === 0

                Column {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰂛"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 40
                        color: root.variantColor
                        opacity: 0.6
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "No notifications"
                        font.family: root.font
                        font.pixelSize: 13
                        color: root.variantColor
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "You're all caught up"
                        font.family: root.font
                        font.pixelSize: 11
                        color: root.variantColor
                        opacity: 0.7
                    }
                }
            }
        }
    }
}
