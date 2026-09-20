import QtQuick

import qs.services
import "../../../utils"

Item {
    id: root

    property string label: ""
    property real value: 0
    property real percent: 0
    property color barColor: Colors.primary
    property color labelColor: Colors.on_surface_variant
    property color valueColor: Colors.on_background
    property string fontFamily: Settings.fontFamily
    property string suffix: "°C"

    implicitHeight: 24

    Text {
        id: labelText
        anchors.left: parent.left
        anchors.top: parent.top
        text: root.label
        color: root.labelColor
        font.family: root.fontFamily
        font.pixelSize: 10
    }

    Text {
        anchors.right: parent.right
        anchors.top: parent.top
        text: root.value.toFixed(0) + root.suffix
        color: root.valueColor
        font.family: root.fontFamily
        font.pixelSize: 10
        font.weight: Font.DemiBold
    }

    Rectangle {
        id: track
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 4
        radius: 2
        color: Qt.rgba(Colors.on_background.r, Colors.on_background.g, Colors.on_background.b, 0.08)

        Rectangle {
            width: Math.max(4, track.width * Math.max(0, Math.min(1, root.percent)))
            height: parent.height
            radius: 2
            color: root.barColor

            Behavior on width {
                NumberAnimation {
                    duration: 600
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}
