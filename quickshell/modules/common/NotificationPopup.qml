import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../"

Scope {
    property var animatedNotifications: ({})

    PanelWindow {
        id: root
        visible: Notifications.popupList.length > 0
        
        anchors {
            top: true
            right: true
        }

        WlrLayershell.namespace: "quickshell:notifications"
        WlrLayershell.layer: WlrLayer.Overlay
        
        
        color: "transparent"
        implicitWidth: 270
        
        implicitHeight: listview.contentHeight + 50

        ListView {
            id: listview
            anchors.fill: parent
            //anchors.margins: 10
            anchors.topMargin: 50
            
            model: Notifications.popupList

            onCountChanged: console.log("[NotifPopup] ListView count changed:", count)

            populate: Transition {
                NumberAnimation { properties: "x,y"; duration: 300 }
            }

            delegate: Column {
                id: delegateRoot
                anchors.right: parent.right
                width: animWidth
                height: bubble.height + topRadius + bottomRadius
                clip: true
                readonly property int notifId: modelData.notificationId
                property real animWidth: root.implicitWidth

                Behavior on animWidth {
                    enabled: !animatedNotifications[notifId]
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }

                Timer {
                    id: startAnim
                    interval: 50
                    running: false
                    onTriggered: {
                        if (!animatedNotifications[delegateRoot.notifId]) {
                            console.log("[NotifPopup] Starting animation for notification ID:", delegateRoot.notifId)
                            delegateRoot.animWidth = root.implicitWidth
                            animatedNotifications[delegateRoot.notifId] = true
                        }
                    }
                }

                Component.onCompleted: {
                    console.log("[NotifPopup] Delegate created, index:", index, "ID:", notifId, "already animated:", !!animatedNotifications[notifId])
                    if (!animatedNotifications[notifId]) {
                        animWidth = 0
                        startAnim.start()
                    }
                }
                Component.onDestruction: console.log("[NotifPopup] Delegate destroyed, index:", index, "ID:", notifId)

                readonly property bool isFirst: index === 0
                readonly property bool isLast: index === listview.count - 1
                readonly property bool isOnly: listview.count === 1

                property real topRadius: isFirst ? (GlobalStates.cornerRadius + GlobalStates.gapsOut) : GlobalStates.cornerRadius
                property real bottomRadius: isLast ? (GlobalStates.cornerRadius + GlobalStates.gapsOut) : GlobalStates.cornerRadius

                onTopRadiusChanged: topCorner.requestPaint()
                onBottomRadiusChanged: bottomCorner.requestPaint()

                // Top invert corner radius
                Canvas {
                    id: topCorner
                    anchors.right: parent.right
                    width: Math.max(topRadius, 0.1)
                    height: width
                    onPaint: {
                        const ctx = getContext("2d");
                        const r = delegateRoot.topRadius;
                        ctx.reset();
                        ctx.fillStyle = GlobalStates.backgroundColor;
                        ctx.beginPath();
                        ctx.moveTo(width, height);
                        ctx.lineTo(width - r, height);
                        ctx.arc(width - r, height - r, r, 0.5 * Math.PI, 0, true);
                        ctx.lineTo(width, height);
                        ctx.closePath();
                        ctx.fill();
                    }
                }

                // Notification bubble
                Rectangle {
                    id: bubble
                    width: parent.width
                    height: 70
                    color: GlobalStates.backgroundColor

                    topLeftRadius: GlobalStates.cornerRadius + GlobalStates.gapsOut
                    bottomLeftRadius: GlobalStates.cornerRadius + GlobalStates.gapsOut

                    //topLeftRadius: delegateRoot.topRadius
                    //bottomLeftRadius: delegateRoot.bottomRadius

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        //Icon
                        Item {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            Image {
                                id: img
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectFit
                                source: {
                                    let icon = modelData.appIcon
                                    if (!icon) return ""
                                    if (icon.startsWith("/")) return "file://" + icon
                                    let res = Quickshell.iconPath(icon, 32)
                                    return res ? (res.startsWith("image://") ? res : "file://" + res) : ""
                                }
                                visible: status === Image.Ready
                            }
                            Text {
                                anchors.centerIn: parent
                                text: "󰵅"
                                visible: img.status !== Image.Ready
                                font.family: "Symbols Nerd Font"
                                color: "white"
                            }
                        }

                        //Texts
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                text: modelData.summary
                                color: "white"
                                font.bold: true
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Text {
                                text: modelData.body
                                color: "lightgray"
                                font.pixelSize: 12
                                elide: Text.ElideRight
                                maximumLineCount: 2
                                wrapMode: Text.Wrap
                                Layout.fillWidth: true
                            }
                        }

                        //Close notification button
                        MouseArea {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            onClicked: Notifications.timeoutNotification(modelData.notificationId)
                            Text {
                                anchors.centerIn: parent
                                text: "×"
                                color: "gray"
                                font.pixelSize: 18
                            }
                        }
                    }
                }

                // Bottom invert corner radius
                Canvas {
                    id: bottomCorner
                    anchors.right: parent.right
                    width: Math.max(bottomRadius, 0.1)
                    height: Math.max(bottomRadius, 0.1)
                    onPaint: {
                        const ctx = getContext("2d");
                        const r = delegateRoot.bottomRadius;
                        ctx.reset();
                        ctx.fillStyle = GlobalStates.backgroundColor;
                        ctx.beginPath();
                        ctx.moveTo(width, 0);
                        ctx.lineTo(width, r);
                        ctx.arc(width - r, r, r, 0, 1.5 * Math.PI, true);
                        ctx.lineTo(width, 0);
                        ctx.closePath();
                        ctx.fill();
                    }
                }
            }
        }
    }
}