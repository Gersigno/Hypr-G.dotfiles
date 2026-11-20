import Quickshell
import QtQuick
import QtQuick.Effects

import "../../../utils"
import "../../../services"
import qs.services

Item {
    id: root

    // --- ENUMS & PROPERTIES ---
    enum Severity { Primary, Secondary, Warning, Danger }
    property int severity: 0
    property bool disabled: false
    property bool fullRounded: false

    property alias text: label.text

    signal clicked

    // --- COLORS MANAGEMENT ---
    property color backgroundColor:
        severity === 0 ? Colors.primary :
        severity === 1 ? Colors.surface_container_high :
        severity === 2 ? Colors.error :
        severity === 3 ? Colors.error_container :
        Colors.primary

    property color textColor:
        severity === 0 ? Colors.on_primary :
        severity === 1 ? Colors.on_surface :
        severity === 2 ? Colors.on_error :
        severity === 3 ? Colors.on_error_container :
        Colors.on_primary

    // Couleurs dynamiques des bordures et états
    readonly property color borderTopColor: Qt.hsla(
        backgroundColor.hslHue,
        backgroundColor.hslSaturation,
        Math.min(backgroundColor.hslLightness + 0.1, 1.0),
        backgroundColor.a
    )

    readonly property color borderBottomColor: Qt.tint(backgroundColor, "#40000000")

    readonly property color hoverBackgroundColor: Qt.hsla(
        backgroundColor.hslHue,
        backgroundColor.hslSaturation,
        Math.min(backgroundColor.hslLightness + 0.05, 1.0),
        backgroundColor.a
    )

    // --- DIMENSIONS ---
    implicitWidth: label.implicitWidth + 32
    implicitHeight: 32


    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Colors.shadow
        shadowBlur: 0.2
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 1
        shadowOpacity: 0.15
    }

    // --- GRAPHICAL STRUCTURE ---
    // 1. TOUT AU FOND : Bordure du bas
    Rectangle {
        id: externalBorder
        anchors.fill: parent
        color: root.borderBottomColor
        radius: root.fullRounded ? height / 2 : HyprlandConfig.radius
        opacity: root.disabled ? 0.5 : 1.0

        // 2. AU MILIEU : Reflet du haut
        Rectangle {
            id: topBorderLayer
            anchors.fill: parent
            anchors.bottomMargin: 1.5//mouseArea.containsMouse ? 2 : 1
            color: root.borderTopColor
            radius: externalBorder.radius > 0 ? externalBorder.radius - 1 : 0

            //Behavior on anchors.bottomMargin {
            //    NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
            //}

            // 3. DEVANT : Fond du bouton
            Rectangle {
                id: innerBackground
                anchors.fill: parent
                anchors.topMargin: 1.5
                anchors.bottomMargin: 0
                color: mouseArea.containsMouse ? root.hoverBackgroundColor : root.backgroundColor
                radius: topBorderLayer.radius > 0 ? topBorderLayer.radius - 1 : 0

                //opacity: 0.2

                Behavior on color {
                    ColorAnimation { duration: 150; easing.type: Easing.InOutQuad }
                }

                // 4. LE CONTENU (TEXTE)
                Text {
                    id: label
                    anchors.centerIn: parent

                    font.pixelSize: 12
                    font.family: Settings.fontFamily
                    color: root.textColor
                    font.bold: true//(root.severity === 0)
                    //font.weight: Font.Medium
                }
            }
        }

        // --- INTERACTION ---
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: !root.disabled
            cursorShape: !root.disabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: if (!root.disabled) root.clicked()
        }
    }
}
