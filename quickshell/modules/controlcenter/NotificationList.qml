import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    property var globalNotifications: null

    // Liste temporaire - TODO: Implémenter les vraies notifications quand disponible
    property var notifications: []

    Component.onCompleted: {
        console.log("[NotificationList] Composant chargé")
        console.log("[NotificationList] globalNotifications:", globalNotifications)
        console.log("[NotificationList] globalNotifications.list:", globalNotifications ? globalNotifications.list : "null")
        console.log("[NotificationList] Nombre de notifications:", globalNotifications ? globalNotifications.list.length : "null")
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        ColumnLayout {
            anchors.fill: parent
            spacing: 10

            // Zone de scroll pour les notifications
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ListView {
                    id: notificationsList
                    model: globalNotifications ? globalNotifications.list : []
                    spacing: 8

                    delegate: NotificationItem {
                        notificationObject: modelData
                        expanded: true // Toujours étendu dans le control center
                        onlyNotification: false
                        globalNotifications: root.globalNotifications
                    }
                }
            }

            // Message quand pas de notifications
            Text {
                visible: globalNotifications ? globalNotifications.list.length === 0 : true
                Layout.alignment: Qt.AlignHCenter
                text: "No notifications\n(Waiting for Quickshell services)"
                color: "#6c7086"
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    // Barre de contrôle
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 36
        color: "#2a2a2a"
        radius: 8

        RowLayout {
            anchors.fill: parent
            anchors.margins: 4
            spacing: 4

            // Bouton mode silencieux
            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 28
                color: globalNotifications && globalNotifications.silent ? "#ff6b6b" : "#4a4a4a"
                radius: 6

                Text {
                    anchors.centerIn: parent
                    text: globalNotifications && globalNotifications.silent ? "🔕" : "🔔"
                    font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (globalNotifications) {
                            globalNotifications.silent = !globalNotifications.silent
                        }
                    }
                }
            }

            // Compteur de notifications
            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                text: (globalNotifications ? globalNotifications.list.length : 0) + " notification" + ((globalNotifications ? globalNotifications.list.length : 0) !== 1 ? "s" : "")
                color: "white"
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
            }

            // Bouton vider
            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 28
                color: "#4a4a4a"
                radius: 6

                Text {
                    anchors.centerIn: parent
                    text: "🗑️"
                    font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (globalNotifications) {
                            globalNotifications.discardAllNotifications()
                        }
                    }
                }
            }
        }
    }
}