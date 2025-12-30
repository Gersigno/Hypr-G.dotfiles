import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../" // Pour accéder à GlobalStates si besoin

Scope {
    PanelWindow {
        id: root
        // La fenêtre n'est visible que s'il y a des notifs dans la popupList
        visible: Notifications.popupList.length > 0
        
        // On se place en haut à droite
        anchors {
            top: true
            right: true
        }

        WlrLayershell.namespace: "quickshell:notifications"
        WlrLayershell.layer: WlrLayer.Overlay
        
        // Transparent pour ne voir que les bulles
        color: "transparent"
        width: 270
        // La hauteur s'adapte au contenu de la liste
        height: listview.contentHeight + 20

        ListView {
            id: listview
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10
            
            // On utilise la liste filtrée pour les popups
            model: Notifications.popupList
            
            // Animation quand une bulle apparaît/disparaît
            add: Transition {
                NumberAnimation { properties: "x"; from: 400; duration: 300; easing.type: Easing.OutQuint }
                NumberAnimation { property: "opacity"; from: 0; duration: 300 }
            }
            remove: Transition {
                NumberAnimation { properties: "x"; to: 400; duration: 300; easing.type: Easing.InQuint }
                NumberAnimation { property: "opacity"; to: 0; duration: 300 }
            }

            delegate: Column {
                width: 270
                height: 120

                Canvas {
                    id: topCorner
                    anchors.right: parent.right
                    anchors.margins: {
                        right: GlobalStates.cornerRadius
                    }
                    width: GlobalStates.cornerRadius + GlobalStates.gapsOut
                    height: GlobalStates.cornerRadius + GlobalStates.gapsOut
                    onPaint: {
                        const ctx = getContext("2d");
                        const w = width;
                        const h = height;
                        const r = GlobalStates.cornerRadius + GlobalStates.gapsOut;
                        ctx.reset();
                        ctx.fillStyle = GlobalStates.backgroundColor;
                        ctx.beginPath();
                        ctx.moveTo(w, h);
                        ctx.lineTo(w - r, h);
                        ctx.arc(w - r, h - r, r, 0.5 * Math.PI, 0, true);
                        ctx.lineTo(w, h);
                        ctx.closePath();
                        ctx.fill();
                    }
                }

                Rectangle {
                    id: bubble
                    width: parent.width
                    height: (parent.height - topCorner.height * 2)

                    color: GlobalStates.backgroundColor

                    topLeftRadius: GlobalStates.cornerRadius + GlobalStates.gapsOut
                    bottomLeftRadius: GlobalStates.cornerRadius + GlobalStates.gapsOut

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        // L'icône (On réutilise la logique qui marche !)
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

                        // Bouton pour fermer la bulle manuellement
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

                Canvas {
                    id: bottomCorner
                    anchors.right: parent.right
                    anchors.margins: {
                        right: GlobalStates.cornerRadius
                    }
                    width: GlobalStates.cornerRadius + GlobalStates.gapsOut
                    height: GlobalStates.cornerRadius + GlobalStates.gapsOut
                    onPaint: {
                        const ctx = getContext("2d");
                        const w = width;
                        const h = height;
                        const r = GlobalStates.cornerRadius + GlobalStates.gapsOut;
                        ctx.reset();
                        ctx.fillStyle = GlobalStates.backgroundColor;
                        ctx.beginPath();
                        ctx.moveTo(w, 0);
                        ctx.lineTo(w, r);
                        ctx.arc(w - r, r, r, 0, 1.5 * Math.PI, true);
                        ctx.lineTo(w, 0);
                        ctx.closePath();
                        ctx.fill();
                    }
                }
            }
        }
    }
}