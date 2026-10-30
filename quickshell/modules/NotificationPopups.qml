import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

import qs.services
import "../utils"
import "../components/common/interface"

Scope {
    id: root

    // Same pattern as ControlCenter / NotificationsCenter
    property var topBarComponent: null
    readonly property real topBarHeight: topBarComponent ? topBarComponent.barHeight : 0

    readonly property int outerRadius: HyprlandConfig.radiusFull
    readonly property int innerRadius: HyprlandConfig.radius > 0 ? HyprlandConfig.radius : 12

    readonly property int bubbleWidth: 340
    readonly property int bubblePadding: 12
    readonly property int iconSize: 36

    // Same base pattern as ControlCenter / NotificationsCenter
    readonly property int animationDuration: Settings.animDuration(450)

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

            // The list fills the whole surface, but only the area actually covered by
            // notifications should take clicks (see interactiveArea below).
            mask: Region { item: interactiveArea }

            implicitWidth: root.bubbleWidth * 1.2
            // The surface covers the whole area below the top bar, but the input
            // region stays limited to the list itself (see mask above). This way the
            // bubbles are never clipped by the surface while they animate out.
            implicitHeight: screen.height - root.topBarHeight

            anchors {
                top: true
                right: true
            }

            // Notifications.popupList is rebuilt on every change, so wrapping it in a
            // ScriptModel turns those rebuilds into proper insert/remove operations.
            // Without it, ListView destroys and recreates every delegate each time.
            // Newest first, so the newest bubble sits at the top of the list.
            ScriptModel {
                id: popupModel
                values: [...Notifications.popupList].reverse()
            }

            ListView {
                id: notifList
                anchors.top: parent.top
                anchors.topMargin: root.outerRadius * 2
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                width: root.bubbleWidth
                clip: false

                model: popupModel
                spacing: root.innerRadius * 2
                // TopToBottom (the default) anchors the content to the top and keeps
                // contentY at 0, so shrinking the content does not move the delegates
                // that are currently animating out.
                verticalLayoutDirection: ListView.TopToBottom

                // Opening: the bubble itself grows with an elastic bump, while its
                // content fades in and gets unblurred.
                add: Transition {
                    ParallelAnimation {
                        NumberAnimation {
                            property: "openProgress"
                            from: 0
                            to: 1
                            duration: root.animationDuration * 1.5
                            easing.type: Easing.OutElastic
                            easing.period: 0.6
                            easing.amplitude: 0.2
                        }
                        NumberAnimation {
                            property: "contentOpacity"
                            from: 0
                            to: 1
                            duration: root.animationDuration / 1.2
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            property: "contentBlur"
                            from: 2
                            to: 0
                            duration: root.animationDuration / 1.2
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                // Closing: same properties, reversed, with a softer curve.
                remove: Transition {
                    ParallelAnimation {
                        NumberAnimation {
                            property: "openProgress"
                            to: 0
                            duration: root.animationDuration / 1.5
                            easing.type: Easing.InOutCubic
                        }
                        NumberAnimation {
                            property: "contentOpacity"
                            to: 0
                            duration: root.animationDuration / 1.5
                            easing.type: Easing.InOutCubic
                        }
                        NumberAnimation {
                            property: "contentBlur"
                            to: 2
                            duration: root.animationDuration / 1.5
                            easing.type: Easing.InOutCubic
                        }
                    }
                }

                delegate: Item {
                    id: delegateItem

                    required property var modelData
                    required property int index

                    // Driven by the add/remove transitions above.
                    // 0 = collapsed (pill), 1 = fully open.
                    property real openProgress: 1
                    property real contentOpacity: 1
                    property real contentBlur: 0

                    // index 0 is the newest bubble, at the top of the list
                    readonly property bool isTopmost: index === 0
                    readonly property bool isBottommost: index === notifList.count - 1

                    width: notifList.width
                    // The bottom corner sits below the bubble and is part of the item's height
                    height: bubble.height + bottomRightCorner.height

                    // Bottom
                    InvertedCorner {
                        id: bottomRightCorner
                        corner: InvertedCorner.Corner.TopRight
                        cornerRadius: (delegateItem.isBottommost ? root.outerRadius : root.innerRadius) * delegateItem.openProgress
                        cornerColor: root.backgroundColor
                        anchors.top: bubble.bottom
                        anchors.right: parent.right
                        opacity: 1
                    }

                    // Top
                    InvertedCorner {
                        id: topRightCorner
                        corner: InvertedCorner.Corner.BottomRight
                        cornerRadius: (delegateItem.isTopmost ? root.outerRadius : root.innerRadius) * delegateItem.openProgress
                        cornerColor: root.backgroundColor
                        anchors.bottom: bubble.top
                        anchors.right: parent.right
                        opacity: 1
                    }

                    Rectangle {
                        id: bubble

                        readonly property real fullHeight: innerRow.implicitHeight + root.bubblePadding * 2
                        // A radius of half the (final) height is a perfect pill
                        readonly property real pillRadius: fullHeight / 2
                        readonly property real currentRadius: pillRadius + (root.outerRadius - pillRadius) * delegateItem.openProgress

                        width: parent.width * delegateItem.openProgress
                        height: fullHeight * delegateItem.openProgress
                        clip: true

                        topLeftRadius: Math.max(0, Math.min(currentRadius, height / 2))
                        bottomLeftRadius: Math.max(0, Math.min(currentRadius, height / 2))

                        color: root.backgroundColor
                        anchors.right: parent.right

                        RowLayout {
                            id: innerRow
                            anchors {
                                left: parent.left
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                margins: root.bubblePadding
                            }
                            spacing: 10

                            opacity: delegateItem.contentOpacity

                            layer.enabled: true
                            layer.effect: MultiEffect {
                                blurEnabled: true
                                blurMax: 16
                                blur: delegateItem.contentBlur
                            }

                            // App icon
                            Item {
                                Layout.preferredWidth: root.iconSize
                                Layout.preferredHeight: root.iconSize
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
                                    onClicked: Notifications.timeoutNotification(delegateItem.modelData.notificationId)

                                    Text {
                                        anchors.centerIn: parent
                                        text: "×"
                                        color: root.foregroundVariantColor
                                        font.pixelSize: 18
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Input region: exactly the area covered by the notification bubbles, so
            // clicks anywhere else go through to the windows below.
            Item {
                id: interactiveArea
                x: notifList.x
                y: notifList.y
                width: notifList.width
                height: notifList.contentHeight
            }
        }
    }
}
