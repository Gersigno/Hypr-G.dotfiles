import QtQuick
import Quickshell
import QtQuick.Layouts

import "../notifications_center"
import "../../services"

Item {
    id: root

    property int topBarHeight: 0
    readonly property int fullRadius: HyprlandConfig.radiusFull

    Rectangle {
        id: content
        anchors.fill: parent
        
        color: "transparent"

        ColumnLayout {
            anchors.fill: parent

            spacing: 8

            UserLayout { 
                id: userLayout
                width: content.width
            }

            Actions {
                id: actions
                width: content.width
            }

            Item {
                //TODO: remplacer par la liste des notifs
                Layout.fillHeight: true
            }
        }
    }
}