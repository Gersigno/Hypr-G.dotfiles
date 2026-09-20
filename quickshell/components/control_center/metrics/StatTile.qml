import QtQuick

import qs.services
import "../../../utils"

Rectangle {
    id: root

    property string value: ""
    property string label: ""
    property color valueColor: Colors.on_background
    property color labelColor: Colors.on_surface_variant
    property string fontFamily: Settings.fontFamily

    implicitHeight: 38
    radius: 8
    color: Qt.rgba(Colors.on_background.r, Colors.on_background.g, Colors.on_background.b, 0.05)
    border.width: 1
    border.color: Qt.rgba(Colors.on_background.r, Colors.on_background.g, Colors.on_background.b, 0.06)

    Column {
        anchors.centerIn: parent
        spacing: 0

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.value
            color: root.valueColor
            font.family: root.fontFamily
            font.pixelSize: 13
            font.weight: Font.DemiBold
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.label
            color: root.labelColor
            font.family: root.fontFamily
            font.pixelSize: 9
        }
    }
}
