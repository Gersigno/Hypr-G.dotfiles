import QtQuick
import Quickshell

import qs.services
import "../../../utils"
import "../../common/interface"

Item {
    id: root

    property string icon: ""
    property string title: ""
    property color iconColor: Colors.primary
    property color titleColor: Colors.on_background
    property var apps: []
    property bool active: false
    property string fontFamily: Settings.fontFamily

    BackgroundLayer {
        anchors.fill: parent
    }

    Item {
        id: inner
        anchors.fill: parent
        anchors.margins: 10

        Item {
            id: header
            width: parent.width
            height: 20

            Text {
                id: iconText
                text: root.icon
                color: root.active ? root.iconColor : Colors.on_surface_variant
                font.family: root.fontFamily
                font.pixelSize: 13
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: titleText
                text: root.title
                color: root.titleColor
                font.family: root.fontFamily
                font.pixelSize: 13
                font.weight: Font.DemiBold
                anchors.verticalCenter: parent.verticalCenter
                x: iconText.width + 6
            }

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: 16
                width: badgeText.width + 10
                radius: height / 2
                color: root.active
                    ? Qt.rgba(root.iconColor.r, root.iconColor.g, root.iconColor.b, 0.15)
                    : Qt.rgba(Colors.on_background.r, Colors.on_background.g, Colors.on_background.b, 0.05)

                Text {
                    id: badgeText
                    anchors.centerIn: parent
                    text: root.active ? "Active" : "Inactive"
                    color: root.active ? root.iconColor : Colors.on_surface_variant
                    font.family: root.fontFamily
                    font.pixelSize: 9
                    font.weight: Font.DemiBold
                }
            }
        }

        Item {
            anchors.top: header.bottom
            anchors.topMargin: 12
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            Column {
                anchors.fill: parent
                spacing: 6
                visible: root.apps.length > 0

                Repeater {
                    model: root.apps

                    delegate: Rectangle {
                        required property var modelData

                        width: parent.width
                        height: 28
                        radius: 6
                        color: Qt.rgba(Colors.on_background.r, Colors.on_background.g, Colors.on_background.b, 0.04)

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            Text {
                                text: ""
                                color: root.iconColor
                                font.family: root.fontFamily
                                font.pixelSize: 11
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: modelData
                                color: Colors.on_background
                                font.family: root.fontFamily
                                font.pixelSize: 12
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.parent.width - x - 10
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: root.apps.length === 0
                text: "No usage"
                color: Colors.on_surface_variant
                font.family: root.fontFamily
                font.pixelSize: 12
            }
        }
    }
}
