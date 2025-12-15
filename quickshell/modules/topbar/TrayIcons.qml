import QtQuick
import Quickshell.Services.SystemTray

Row {
    spacing: 8

    Repeater {
        model: SystemTray.items.values

        Item {
            width: 16
            height: 16

            anchors.verticalCenter: parent.verticalCenter

            Image {
                anchors.fill: parent
                source: model.icon
                smooth: true
                antialiasing: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: model.activate()
            }
        }
    }
}
