import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: sliderItem
    property string icon: ""
    property real value: 0.5
    property real min: 0
    property real max: 1
    signal sliderValueChanged(real value)

    Layout.fillWidth: true
    Layout.fillHeight: true

    // Icône en position absolue par dessus le slider
    Text {
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        text: sliderItem.icon
        color: "black"  // Couleur contrastante
        font.pixelSize: 20
        font.family: "Symbols Nerd Font"
        z: 1  // Au dessus du slider
    }

    Slider {
        id: slider
        anchors.fill: parent
        from: sliderItem.min
        to: sliderItem.max
        value: sliderItem.value
        onValueChanged: sliderItem.sliderValueChanged(slider.value)

        leftPadding: 0 
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0

        background: Rectangle {
            x: slider.leftPadding
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            width: slider.availableWidth
            height: slider.availableHeight
            radius: 12
            color: Qt.rgba(0.5, 0.5, 0.5, 0.5)

            // Barre de progression qui part de la gauche jusqu'à la valeur
            Rectangle {
                width: slider.visualPosition * parent.width
                height: parent.height
                color: "white"
                radius: 12
            }
        }

        // Handle invisible pour l'interaction
        handle: Item {
            x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            width: 20
            height: 20
            opacity: 0  // Invisible
        }
    }
}