import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import "../services"
import "../utils"
import qs.services
import "../utils"
import "../components/common/interface"

Scope {
    id: root

    readonly property int globalRadius: HyprlandConfig.radiusFull
    readonly property int innerRadius: HyprlandConfig.radius > 0 ? HyprlandConfig.radius : 12

    readonly property color backgroundColor: (Settings.isOled && Theme.isDarkMode) ? "#000000" : Colors.background
    readonly property color foregroundColor: Colors.on_surface
    readonly property color foregroundVariantColor: Colors.on_surface_variant

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
                anchors.topMargin: root.globalRadius * 2
                anchors.right: parent.right
                //anchors.rightMargin: 12
                width: 340

                model: Notifications.popupList
                spacing: root.innerRadius * 2
                implicitHeight: contentHeight
                verticalLayoutDirection: ListView.BottomToTop

                /*add: Transition {
                    NumberAnimation { property: "scale"; from: 0; to: 1; duration: 250; easing.type: Easing.OutCubic }
                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 250; easing.type: Easing.OutCubic }
                }

                displaced: Transition {
                    NumberAnimation { 
                        properties: "y"; 
                        duration: 250; 
                        easing.type: Easing.OutCubic 
                    }
                }*/

                delegate: Item {
                    id: delegateItem

                    //transformOrigin: Item.CenterRight

                    ListView.delayRemove: false
                    ListView.onRemove: removeAnimation.start()

                    /*SequentialAnimation {
                        id: removeAnimation
                        PropertyAction { target: delegateItem; property: "ListView.delayRemove"; value: true }
                        ParallelAnimation {
                            //NumberAnimation { target: delegateItem; property: "scale"; to: 0; duration: 2000; easing.type: Easing.InCubic }
                            //NumberAnimation { target: delegateItem; property: "opacity"; to: 0; duration: 2000; easing.type: Easing.InCubic }
                        }
                        PropertyAction { target: delegateItem; property: "ListView.delayRemove"; value: false }
                    }*/

                    width: notifList.width
                    height: bubble.height + bottomRightCorner.height // Account for corner radius

                    //Bottom
                    InvertedCorner {
                        id: bottomRightCorner
                        corner: InvertedCorner.Corner.TopRight
                        cornerRadius: index > 0 ? root.innerRadius : root.globalRadius
                        cornerColor: root.backgroundColor
                        anchors.top: bubble.bottom
                        anchors.right: parent.right
                    }

                    //Top
                    InvertedCorner {
                        id: topRightCorner
                        corner: InvertedCorner.Corner.BottomRight
                        cornerRadius: index < notifList.count - 1 ? root.innerRadius : root.globalRadius
                        cornerColor: root.backgroundColor
                        anchors.bottom: bubble.top
                        anchors.right: parent.right
                    }

                    Rectangle {
                        id: bubble
                        width: notifList.width
                        height: innerRow.implicitHeight + 20
                        //radius: HyprlandConfig.radius > 0 ? HyprlandConfig.radius : 12
                        topLeftRadius: root.globalRadius
                        bottomLeftRadius: root.globalRadius
                        color: root.backgroundColor
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
                                        if (icon.startsWith("image://qsimage/")) return ""
                                        if (icon.startsWith("image://icon/")) {
                                            const name = icon.slice("image://icon/".length)
                                            if (name.startsWith("/")) return "file://" + name
                                            const res = Quickshell.iconPath(name, 32)
                                            return res ? (res.startsWith("image://") ? res : "file://" + res) : ""
                                        }
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
                                    color: root.foregroundVariantColor
                                }
                            }

                            // Text content
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 3

                                Text {
                                    text: modelData.appName || modelData.summary || ""
                                    color: root.foregroundVariantColor
                                    font.family: Settings.fontFamily
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    visible: text !== ""
                                }

                                Text {
                                    text: modelData.summary || ""
                                    color: root.foregroundColor
                                    font.family: Settings.fontFamily
                                    font.pixelSize: 13
                                    font.bold: true
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    visible: text !== ""
                                }

                                Text {
                                    text: modelData.body || ""
                                    color: root.foregroundVariantColor
                                    font.family: Settings.fontFamily
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
                                        color: foregroundVariantColor
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
}
