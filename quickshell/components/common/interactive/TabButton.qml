import QtQuick

import "../../../utils"
import "../../../services"

Item {
    id: root

    property alias text: label.text
    property string icon: ""
    property bool selected: false
    property bool disabled: false

    signal clicked

    implicitWidth: Math.ceil(content.implicitWidth) + 36
    implicitHeight: 40

    opacity: disabled ? 0.45 : 1.0
    Behavior on opacity {
        NumberAnimation { duration: 120; easing.type: Easing.InOutQuad }
    }

    // Fond discret au survol, l'indicateur se charge de l'état actif
    Rectangle {
        anchors.fill: parent
        anchors.bottomMargin: 4
        radius: HyprlandConfig.radius
        color: Colors.surface_container_high
        opacity: mouseArea.containsMouse && !root.selected && !root.disabled ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 120; easing.type: Easing.InOutQuad }
        }
    }

    Row {
        id: content
        anchors.centerIn: parent
        spacing: root.icon.length > 0 ? 7 : 0

        Text {
            visible: text.length > 0
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            color: root.disabled ? Colors.on_surface_variant
                 : root.selected ? Colors.primary
                 : Colors.on_surface_variant
            font.pixelSize: 15
            font.family: Settings.fontFamily

            Behavior on color {
                ColorAnimation { duration: 140; easing.type: Easing.InOutQuad }
            }
        }

        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            color: root.disabled ? Colors.on_surface_variant
                 : root.selected ? Colors.primary
                 : mouseArea.containsMouse ? Colors.on_surface
                 : Colors.on_surface_variant
            font.pixelSize: 13
            font.family: Settings.fontFamily
            font.weight: root.selected ? Font.DemiBold : Font.Medium

            Behavior on color {
                ColorAnimation { duration: 140; easing.type: Easing.InOutQuad }
            }
        }
    }

    // Barre d'accentuation sous l'onglet actif
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.selected ? Math.ceil(content.implicitWidth) + 12 : 0
        height: 3
        radius: height / 2
        color: Colors.primary
        opacity: root.selected ? 1.0 : 0.0

        Behavior on width {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }
        Behavior on opacity {
            NumberAnimation { duration: 140; easing.type: Easing.InOutQuad }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: !root.disabled
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}
