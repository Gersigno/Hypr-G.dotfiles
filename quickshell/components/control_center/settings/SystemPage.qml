import QtQuick
import Quickshell

import "../../../config"
import "../../../utils"

Item {
    id: root

    readonly property color foregroundColor: Config.isOled ? "#fff" : Colors.on_background

    Column {
        spacing: 8

        Row {
            spacing: 6
            Text {
                text: "󰍹"
                width: 22
                horizontalAlignment: Text.AlignHCenter
                color: foregroundColor
                font.pixelSize: 20
                font.family: Config.fontFamily
                font.bold: true
            }
            Text {
                text: "System"
                color: foregroundColor
                font.pixelSize: 20
                font.family: Config.fontFamily
                font.bold: true
            }
        }

        Text {
            text: "System settings and information"
            color: foregroundColor
            font.pixelSize: 13
            font.family: Config.fontFamily
            opacity: 0.7
        }
    }
}
