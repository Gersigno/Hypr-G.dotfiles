import QtQuick
import Quickshell

import "../../../utils"

Item {
    id: slider
    
    property real value: 0.5
    property color fillColor:               Colors.primary
    property color backgroundColor:         Colors.primary_container
    readonly property color fgSub:          Colors.on_surface_variant

    signal moved(real newValue)

    implicitHeight: 12

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        function updateValue(mouseEvent) {
            let ratio = mouseEvent.x / width;
            let newValue = Math.max(0.0, Math.min(1.0, ratio));
            slider.moved(newValue);
        }

        onPressed: (mouse) => updateValue(mouse)
        
        onPositionChanged: (mouse) => {
            if (pressed) {
                updateValue(mouse)
            }
        }
    }

    Rectangle {
        color: slider.fgSub
        opacity: 0.4    
        radius: height / 2
        height: 5
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
    }

    Rectangle {
        width: Math.max(0, slider.value * parent.width)
        height: 5
        color: slider.fillColor
        radius: height / 2
        anchors.verticalCenter: parent.verticalCenter
    }

    Rectangle {
        id: handle
        width: (mouseArea.containsMouse || mouseArea.pressed) ? 12 : 5
        height: width
        color: slider.fillColor
        radius: width / 2
        anchors.verticalCenter: parent.verticalCenter
        
        anchors.left: parent.left
        anchors.leftMargin: Math.max(0, slider.value * parent.width) - (width / 2)

        Behavior on width {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }
}