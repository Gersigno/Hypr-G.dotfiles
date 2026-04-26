import Quickshell
import QtQuick

import "../../../utils"
import "../../../services"
import "../../../config"

Item {
    id: root

    enum Severity { Primary, Secondary, Warning, Danger }
    property int severity: 0 
    property bool disabled: false
    property bool fullRounded: false

    signal clicked

    property alias text: label.text

    // Couleur de fond selon la sévérité
    property color backgroundColor: 
        severity === 0 ? Colors.primary :                   // Primary
        severity === 1 ? Colors.surface_container_high :    // Secondary
        severity === 2 ? Colors.error :                     // Warning
        severity === 3 ? Colors.error_container :           // Danger
        Colors.primary
    
    property color textColor: 
        severity === 0 ? Colors.on_primary :                // Primary
        severity === 1 ? Colors.on_surface :                // Secondary
        severity === 2 ? Colors.on_error :                  // Warning
        severity === 3 ? Colors.on_error_container :        // Danger
        Colors.on_primary

    implicitWidth: row.implicitWidth + 32
    implicitHeight: 32

    Behavior on opacity {
        NumberAnimation { 
            duration: 150 
            easing.type: Easing.InOutQuad
        }
    }

    Rectangle {
        anchors.fill: parent
        color: root.backgroundColor
        radius: root.fullRounded ? height / 2 : HyprlandConfig.radius
        opacity: root.disabled ? 0.5 : 1.0

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 8

            Text {
                id: label
                font.pixelSize: 13
                font.family: Config.fontFamily
                color: root.textColor
                font.bold: (root.severity === 0)
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: !root.disabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: if (!root.disabled) root.clicked()
            onEntered: !root.disabled ? root.opacity = 0.8 : null
            onExited: !root.disabled ? root.opacity = 1.0 : null
        }
    }
}