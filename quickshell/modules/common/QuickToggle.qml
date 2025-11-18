import QtQuick
import QtQuick.Controls

Rectangle {
    id: toggle
    property string icon: ""
    property bool checked: false
    property bool autoToggle: true
    signal clicked()

    width: 60
    height: 60
    color: mouseArea.containsPress ? Qt.rgba(0.8, 0.8, 0.8, 0.2) : "transparent"
    radius: 12
    border.color: checked ? "white" : Qt.rgba(0.5, 0.5, 0.5, 0.5)
    border.width: 2

    Text {
        anchors.centerIn: parent
        text: toggle.icon
        color: "white"
        font.pixelSize: 24
        font.family: "Symbols Nerd Font"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            if (toggle.autoToggle) {
                toggle.checked = !toggle.checked
            }
            toggle.clicked()
        }
    }
}