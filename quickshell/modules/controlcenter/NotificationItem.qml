import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: notificationItem

    property var notificationObject
    property bool expanded: true
    property bool onlyNotification: false
    property var globalNotifications: null

    width: parent ? parent.width : 300
    height: contentLayout.implicitHeight + 20
    color: notificationObject?.urgency === NotificationUrgency.Critical ? "#f38ba8" : "#2a2a2a"
    radius: 8
    border.width: notificationObject?.urgency === NotificationUrgency.Critical ? 2 : 0
    border.color: notificationObject?.urgency === NotificationUrgency.Critical ? "#f38ba8" : "transparent"

    ColumnLayout {
        id: contentLayout
        anchors {
            fill: parent
            margins: 10
        }
        spacing: 4

        // En-tête avec app et timestamp
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: notificationObject?.appName || "Application"
                color: notificationObject?.urgency === NotificationUrgency.Critical ? "#1e1e2e" : "#cdd6f4"
                font.pixelSize: 12
                font.bold: true
                Layout.fillWidth: true
            }

            Text {
                text: new Date(notificationObject?.time * 1000).toLocaleTimeString(Qt.locale(), "HH:mm")
                color: notificationObject?.urgency === NotificationUrgency.Critical ? "#1e1e2e" : "#6c7086"
                font.pixelSize: 10
            }
        }

        // Titre/Summary
        Text {
            text: notificationObject?.summary || ""
            color: notificationObject?.urgency === NotificationUrgency.Critical ? "#1e1e2e" : "#cdd6f4"
            font.pixelSize: 14
            font.bold: true
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }

        // Corps du message
        Text {
            text: notificationObject?.body || ""
            color: notificationObject?.urgency === NotificationUrgency.Critical ? "#1e1e2e" : "#cdd6f4"
            font.pixelSize: 12
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            visible: expanded
        }
    }

    // Bouton fermer
    Rectangle {
        anchors {
            top: parent.top
            right: parent.right
            margins: 5
        }
        width: 20
        height: 20
        color: "transparent"
        radius: 10

        Text {
            anchors.centerIn: parent
            text: "×"
            color: notificationObject?.urgency === NotificationUrgency.Critical ? "#1e1e2e" : "#cdd6f4"
            font.pixelSize: 16
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (globalNotifications) {
                    globalNotifications.discardNotification(notificationObject.notificationId)
                }
            }
        }
    }

    // Animation d'entrée
    NumberAnimation on opacity {
        from: 0
        to: 1
        duration: 200
        easing.type: Easing.OutQuad
    }

    // Animation au survol
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: notificationItem.scale = 1.02
        onExited: notificationItem.scale = 1.0
    }

    Behavior on scale {
        NumberAnimation { duration: 100 }
    }
}