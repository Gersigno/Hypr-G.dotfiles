import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import "../services"
import "../utils"
import "../config"

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panelRoot
            property var modelData
            screen: modelData

            color: "transparent"

            WlrLayershell.namespace: "quickshell:notif-popups"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusiveZone: 0
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            // Only consume space of the actual notification list
            mask: Region { item: notifList }

            implicitWidth: 360
            implicitHeight: notifList.implicitHeight + notifList.y

            anchors {
                top: true
                right: true
            }

            ListView {
                id: notifList
                anchors.top: parent.top
                anchors.topMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 12
                width: 340

                model: Notifications.popupList
                spacing: 6
                implicitHeight: contentHeight

                add: Transition {
                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 250; easing.type: Easing.OutCubic }
                    NumberAnimation { property: "x"; from: 60; to: 0; duration: 250; easing.type: Easing.OutCubic }
                }

                remove: Transition {
                    NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200; easing.type: Easing.InCubic }
                    NumberAnimation { property: "x"; from: 0; to: 60; duration: 200; easing.type: Easing.InCubic }
                }

                displaced: Transition {
                    NumberAnimation { properties: "y"; duration: 250; easing.type: Easing.OutCubic }
                }

                delegate: Rectangle {
                    id: bubble
                    width: notifList.width
                    height: innerRow.implicitHeight + 20
                    radius: HyprlandConfig.radius > 0 ? HyprlandConfig.radius : 12
                    color: Colors.surface_container
                    anchors.right: parent ? parent.right : undefined

                    RowLayout {
                        id: innerRow
                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            margins: 12
                        }
                        spacing: 10

                        // App icon
                        Item {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            Layout.alignment: Qt.AlignVCenter

                            Image {
                                id: notifIcon
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectFit
                                source: {
                                    const icon = modelData.appIcon || modelData.image
                                    if (!icon) return ""
                                    if (icon.startsWith("/")) return "file://" + icon
                                    const res = Quickshell.iconPath(icon, 32)
                                    return res ? (res.startsWith("image://") ? res : "file://" + res) : ""
                                }
                                visible: status === Image.Ready
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "󰵅"
                                visible: notifIcon.status !== Image.Ready
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 22
                                color: Colors.on_surface_variant
                            }
                        }

                        // Text content
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3

                            Text {
                                text: modelData.appName || modelData.summary || ""
                                color: Colors.on_surface_variant
                                font.family: Config.fontFamily
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                visible: text !== ""
                            }

                            Text {
                                text: modelData.summary || ""
                                color: Colors.on_surface
                                font.family: Config.fontFamily
                                font.pixelSize: 13
                                font.bold: true
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                visible: text !== ""
                            }

                            Text {
                                text: modelData.body || ""
                                color: Colors.on_surface_variant
                                font.family: Config.fontFamily
                                font.pixelSize: 12
                                elide: Text.ElideRight
                                wrapMode: Text.Wrap
                                maximumLineCount: 3
                                Layout.fillWidth: true
                                visible: text !== ""
                            }
                        }

                        // Close button
                        Item {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            Layout.alignment: Qt.AlignTop

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Notifications.timeoutNotification(modelData.notificationId)

                                Text {
                                    anchors.centerIn: parent
                                    text: "×"
                                    color: Colors.on_surface_variant
                                    font.pixelSize: 18
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
