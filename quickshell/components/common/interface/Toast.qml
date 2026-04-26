import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import "../../../config"
import "../../../utils"
import "../../../services"

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

    transform: Translate {
        id: slideTranslate
        y: 16
    }

    function show(msg, dur, ico) {
        root.message = msg
        root.duration = dur ?? 3000
        root.icon = ico ?? ""
        root.opacity = HyprlandConfig.inactiveOpacity
        hideTimer.restart()
        showAnimation.restart()
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

    ParallelAnimation {
        id: showAnimation

        NumberAnimation {
            target: slideTranslate
            property: "y"
            from: 16
            to: 0
            duration: 350
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: container
            property: "scale"
            from: 0.88
            to: 1.0
            duration: 350
            easing.type: Easing.OutBack
            easing.overshoot: 1.2
        }
    }

    Rectangle {
        id: container
        implicitWidth: row.implicitWidth + 24
        implicitHeight: row.implicitHeight + 16
        radius: HyprlandConfig.radius
        color: Colors.surface_container_high

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Colors.shadows //"red"//HyprlandConfig.shadowColor
            shadowBlur: 2
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 8
            //radius: container.radius
            //paddingEnabled: true
        }
 
        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 8

            Rectangle {
                width: 32
                height: 32
                radius: 2
                color: "transparent" //Colors.primary

                visible: root.icon !== ""

                Image {
                    anchors.fill: parent
                    source: root.icon
                    fillMode: Image.PreserveAspectFit

                    visible: root.icon !== ""
                }
            }

            /*Image {
                source: root.icon || ""
                width: 16
                height: 16
                fillMode: Image.PreserveAspectFit

                visible: root.icon !== ""
                Layout.alignment: Qt.AlignVCenter
            }*/

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
