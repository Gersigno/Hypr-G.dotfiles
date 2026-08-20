import QtQuick
import Quickshell

import "../../../utils"

Item {
    id: root

    property bool checked: false
    property bool enabled: true

    signal toggled(bool checked)

    implicitWidth: 48
    implicitHeight: 28

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: {
            if (!root.enabled) return Colors.surface_variant
            if (root.checked)
                return mouseArea.containsMouse ? Qt.lighter(Colors.primary, 1.15) : Colors.primary
            else
                return mouseArea.containsMouse ? Qt.lighter(Colors.surface_container_highest, 1.1) : Colors.surface_variant
        }
        border.color: root.checked && root.enabled ? Colors.primary : Colors.outline
        border.width: 1

        Behavior on color {
            ColorAnimation { duration: 150; easing.type: Easing.InOutQuad }
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 22
            height: 22
            radius: 11
            color: {
                if (!root.enabled) return Colors.on_surface_variant
                return mouseArea.containsMouse ? "#fff" : (root.checked ? Colors.on_primary : Colors.on_surface_variant)
            }
            x: root.checked ? parent.width - width - 2 : 2

            Behavior on x {
                NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
            }
            Behavior on color {
                ColorAnimation { duration: 150; easing.type: Easing.InOutQuad }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (root.enabled) {
                root.checked = !root.checked
                root.toggled(root.checked)
            }
        }
    }
}
