import QtQuick
import QtQuick.Effects

/**
 * A single privacy indicator icon with animated opacity, width and blur.
 *
 * When `active` becomes true, the icon fades in while its width expands
 * from 0 to its natural size and the blur clears. When `active` becomes
 * false, it fades out, shrinks and blurs again.
 */
Text {
    id: root

    property bool active: false
    property color iconColor: "white"
    property int animationDuration: 500

    property real visibilityLevel: active ? 1 : 0

    text: ""
    color: iconColor
    font.pixelSize: 12
    font.family: "monospace"
    anchors.verticalCenter: parent.verticalCenter

    width: implicitWidth * visibilityLevel
    opacity: visibilityLevel

    layer.enabled: true
    layer.effect: MultiEffect {
        blurEnabled: true
        blur: 1 - root.visibilityLevel
    }

    Behavior on visibilityLevel {
        NumberAnimation {
            duration: root.animationDuration
            easing.type: Easing.InOutQuad
        }
    }
}
