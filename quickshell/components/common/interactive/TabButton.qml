import QtQuick

import "../../../utils"
import "../../../services"

Item {
    id: root

    property alias text: label.text
    property string icon: ""
    property bool selected: false
    property bool disabled: false

    // Onglets empilés verticalement : le contenu est aligné à gauche et
    // l'indicateur d'accent est une barre verticale.
    property bool vertical: false

    signal clicked

    implicitWidth: root.vertical ? Math.ceil(content.implicitWidth) + 40
                                 : Math.ceil(content.implicitWidth) + 36
    implicitHeight: 40

    opacity: disabled ? 0.45 : 1.0
    Behavior on opacity {
        NumberAnimation { duration: 120; easing.type: Easing.InOutQuad }
    }

    // Fond discret au survol, l'indicateur se charge de l'état actif
    Rectangle {
        anchors.fill: parent
        anchors.rightMargin: root.vertical ? 4 : 0
        anchors.bottomMargin: root.vertical ? 0 : 4
        radius: HyprlandConfig.radius
        color: Colors.surface_container_high
        opacity: mouseArea.containsMouse && !root.selected && !root.disabled ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 120; easing.type: Easing.InOutQuad }
        }
    }

    Row {
        id: content
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: root.vertical ? undefined : parent.horizontalCenter
        anchors.left: root.vertical ? parent.left : undefined
        anchors.leftMargin: root.vertical ? 16 : 0
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

    // Barre d'accentuation sous l'onglet actif (horizontal)
    Rectangle {
        visible: !root.vertical
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

    // Barre d'accentuation à gauche de l'onglet actif (vertical)
    Rectangle {
        visible: root.vertical
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 3
        height: root.selected ? Math.ceil(content.implicitHeight) + 12 : 0
        radius: width / 2
        color: Colors.primary
        opacity: root.selected ? 1.0 : 0.0

        Behavior on height {
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
