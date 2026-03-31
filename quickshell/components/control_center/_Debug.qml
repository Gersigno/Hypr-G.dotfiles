import QtQuick
import Quickshell

import "../../config"
import "../../utils"

Item {
    id: root

    implicitWidth: 800
    implicitHeight: 600

    Text {
        anchors.centerIn: parent
        text: "Debug info will go here"
        color: Colors.on_background
        font.family: Config.fontFamily
        font.pixelSize: 18
    }
} 