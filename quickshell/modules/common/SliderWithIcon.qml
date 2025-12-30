import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root
    property string icon: ""
    
    property alias value: slider.value
    property alias from: slider.from
    property alias to: slider.to
    property alias stepSize: slider.stepSize
    property alias pressed: slider.pressed

    signal moved()
    

    width: 250
    height: 12
    color: "transparent"

    RowLayout {
        anchors.fill: parent
        spacing: GlobalStates.gapsOut

        Rectangle {
            width: 20
            height: parent.height
            color: "transparent"

            Text {
                text: root.icon
                font.pixelSize: 14
                color: "white"
                font.family: "Symbols Nerd Font"
                visible: root.icon !== ""
            }
        }

        Slider {
            id: slider
            from: 0
            to: 1
            value: 0
            onMoved: root.moved()
            Layout.fillWidth: true
            //onValueChanged: root.value = slider.value

            background: Rectangle {
                implicitHeight: root.height
                color: "#2e2e2e"
                radius: GlobalStates.cornerRadius
            }

            contentItem: Item { // Utilise un Item ici
                implicitHeight: root.height
                Rectangle {
                    // Utilise slider.visualPosition pour le dessin
                    width: slider.visualPosition * parent.width 
                    height: parent.height
                    color: "white"
                    radius: GlobalStates.cornerRadius 
                }
            }
            handle: Item {
                opacity: 0  // Invisible handle
            }
        }
    }
}