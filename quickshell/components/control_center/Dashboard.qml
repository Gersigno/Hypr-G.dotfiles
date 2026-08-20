import QtQuick
import Quickshell

import qs.services as Services
import "../../utils"
import "./dashboard"

Item {
    id: root

    implicitWidth: 900
    implicitHeight: 400

    readonly property color backgroundColor: (Services.Settings.isOled && Theme.isDarkMode) ? "#000" : Colors.background
    readonly property color foregroundColor: Colors.on_background

    Row {
        id: row
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        readonly property real availableWidth: row.width - (row.spacing * 2)

        Column {
            id: left_column
            height: parent.height
            width: row.availableWidth * 0.27
            spacing: 8

            readonly property real availablHeight: left_column.height - (left_column.spacing)

            UserInfos {
                width: parent.width
                height: left_column.availablHeight * 0.2
            }
            Calendar {
                width: parent.width
                height: left_column.availablHeight * 0.8
            }
        }
        QuickSettings {
            height: parent.height
            width: row.availableWidth * 0.32
        }
        Column {
            id: right_column
            height: parent.height
            width: row.availableWidth * 0.41
            spacing: 8

            readonly property real availablHeight: left_column.height - (left_column.spacing)

            Media {
                width: parent.width
                height: right_column.availablHeight * 0.4
            }
            AudioSettings {
                width: parent.width
                height: right_column.availablHeight * 0.6
            }
        }
    }
}