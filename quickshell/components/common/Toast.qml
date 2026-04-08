import QtQuick
import QtQuick.Layouts

import "../../config"
import "../../utils"
import "../../services"

Item {
    id: root

    property string message: ""
    property string icon: ""
    property int duration: 3000

    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight

    opacity: 0
    visible: opacity > 0

    y: 0

    function show(msg, dur, ico) {
        root.message = msg
        root.duration = dur ?? 3000
        root.icon = ico ?? ""
        root.opacity = 1
        hideTimer.restart()
    }

    Timer {
        id: hideTimer
        interval: root.duration
        running: false
        repeat: false
        onTriggered: root.opacity = 0
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on y {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        id: container
        implicitWidth: row.implicitWidth + 24
        implicitHeight: row.implicitHeight + 16
        radius: HyprlandConfig.radius
        color: Colors.surface_container_high

        layer.enabled: true
        layer.effect: null

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 8

            Image {
                source: root.icon || ""
                width: 16
                height: 16
                visible: root.icon !== ""
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: root.message
                font.pixelSize: 13
                font.family: Config.fontFamily
                color: Colors.on_surface
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }
}
