import QtQuick
import Quickshell

import "../common/interface"
import qs.services
import "../../services"
import "../../utils"

Item {
    id: root
    //readonly property var controlCenterComponent: null
    readonly property color backgroundColor: (Settings.isOled && Theme.isDarkMode) ? "#000" : Colors.background
    readonly property color foregroundColor: Colors.on_background
    readonly property int radius: HyprlandConfig.radius
    readonly property string font: Settings.fontFamily

    implicitWidth: container.width
    height: parent.height



    Item {
        id: container

        width: clockRow.width
        height: parent.height

        Row {
            height: parent.height
            anchors.centerIn: parent

            InvertedCorner {
                id: topLeftCorner
                corner: InvertedCorner.Corner.TopRight
                cornerRadius: root.radius
                cornerColor: root.backgroundColor
            }
            Rectangle {
                id: clockContent
                width: clockRow.width + (root.radius * 2)
                height: parent.height
                color: root.backgroundColor
                bottomLeftRadius: root.radius
                bottomRightRadius: root.radius

                Row {
                    id: clockRow
                    height: parent.height
                    spacing: 4
                    anchors.centerIn: parent

                    Text {
                        id: dateText
                        text: new Date().toLocaleTimeString(Qt.locale(), "HH:mm")
                        color: root.foregroundColor
                        font.pixelSize: 12
                        font.bold: true
                        font.family: root.font
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        id: separatorText
                        color: root.foregroundColor
                        font.pixelSize: 12
                        font.bold: true
                        font.family: root.font
                        text: "·"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        id: timeText
                        text: new Date().toLocaleDateString(Qt.locale(), "dddd, d MMM")
                        color: root.foregroundColor
                        font.pixelSize: 12
                        font.family: root.font

                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Timer {
                        interval: 100
                        running: true
                        repeat: true
                        onTriggered: {
                            dateText.text = new Date().toLocaleTimeString(Qt.locale(), "HH:mm");
                            timeText.text = new Date().toLocaleDateString(Qt.locale(), "dddd, d MMM");
                        }
                    }
                }
            }
            InvertedCorner {
                id: topRightCorner
                corner: InvertedCorner.Corner.TopLeft
                cornerRadius: root.radius
                cornerColor: root.backgroundColor
            }
        }
    }
}