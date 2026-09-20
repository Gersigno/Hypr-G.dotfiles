import QtQuick

import qs.services
import "../../../utils"

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property color iconColor: Colors.primary
    property color textColor: Colors.on_surface_variant
    property string fontFamily: Settings.fontFamily

    implicitWidth: row.implicitWidth + 20
    implicitHeight: 26
    radius: height / 2
    color: Qt.rgba(Colors.on_background.r, Colors.on_background.g, Colors.on_background.b, 0.05)
    border.width: 1
    border.color: Qt.rgba(Colors.on_background.r, Colors.on_background.g, Colors.on_background.b, 0.06)

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.icon
            color: root.iconColor
            font.family: root.fontFamily
            font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.label
            color: root.textColor
            font.family: root.fontFamily
            font.pixelSize: 11
            font.weight: Font.DemiBold
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
