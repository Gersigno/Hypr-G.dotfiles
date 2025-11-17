import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: sliderItem
    property string icon: ""
    property real value: 0.5
    signal sliderValueChanged(real value)

    spacing: 10

    Text {
        text: sliderItem.icon
        color: "white"
        font.pixelSize: 20
        font.family: "Symbols Nerd Font"
        Layout.preferredWidth: 30
    }

    Slider {
        id: slider
        Layout.fillWidth: true
        from: 0
        to: 1
        value: sliderItem.value
        onValueChanged: sliderItem.sliderValueChanged(slider.value)

        background: Rectangle {
            x: slider.leftPadding
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            implicitWidth: 200
            implicitHeight: 4
            width: slider.availableWidth
            height: implicitHeight
            radius: 2
            color: Qt.rgba(0.5, 0.5, 0.5, 0.5)

            Rectangle {
                width: slider.visualPosition * parent.width
                height: parent.height
                color: "white"
                radius: 2
            }
        }

        handle: Rectangle {
            x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            implicitWidth: 20
            implicitHeight: 20
            radius: 10
            color: "white"
            border.color: Qt.rgba(0.3, 0.3, 0.3, 0.8)
            border.width: 2
        }
    }
}