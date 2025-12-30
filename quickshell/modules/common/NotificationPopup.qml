import QtQuick
import QtQuick.Controls
import "../.."

Item {
    id: root 
    anchors.fill: parent

    // Connect to the notify signal
    Connections {
        target: Notifications
        function onNotify(notification) {
            if (notification.popup) {
                showPopup(notification)
            }
        }
    }

    function showPopup(notification) {
        var popup = popupComponent.createObject(root, { notification: notification })
        popup.open()
    }

    Component {
        id: popupComponent
        Popup {
            id: popup
            property var notification 
            width: 300
            height: 80
            x: parent.width - width - 20
            y: 50
            modal: false
            focus: false
            closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape

            background: Rectangle {
                color: "#2e2e2e"
                radius: GlobalStates.cornerRadius
                border.color: "white"
                border.width: 1
            }

            contentItem: Item {
                Row {
                    anchors.fill: parent
                    anchors.margins: GlobalStates.gapsOut
                    spacing: GlobalStates.gapsOut

                    // App icon
                    Text {
                        text: notification.appIcon || "󰵅"
                        font.pixelSize: 24
                        color: "white"
                        font.family: "Symbols Nerd Font"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Content
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4

                        Text {
                            text: notification.summary
                            font.pixelSize: 14
                            color: "white"
                            font.family: "SF Pro Display"
                            font.bold: true
                            elide: Text.ElideRight
                            width: 200
                        }

                        Text {
                            text: notification.body
                            font.pixelSize: 12
                            color: "lightgray"
                            font.family: "SF Pro Display"
                            elide: Text.ElideRight
                            width: 200
                            maximumLineCount: 2
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }

            // Auto close after timeout
            Timer {
                interval: 5000 // 5 seconds
                running: true
                onTriggered: popup.close()
            }

            onClosed: {
                notification.popup = false
                destroy()
            }
        }
    }
}