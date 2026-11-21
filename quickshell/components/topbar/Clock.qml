import QtQuick
import Quickshell
import QtQuick.Effects

import "../common/interface"
import qs.services
import "../../services"
import "../../utils"

Item {
    id: root
    //readonly property var controlCenterComponent: null
    readonly property color backgroundColor: (Settings.isOled && Theme.isDarkMode) ? "#000" : Colors.background
    readonly property color foregroundColor: Colors.on_background
    readonly property color lightred: Colors.error_container
    readonly property color red: Colors.on_error
    readonly property int radius: HyprlandConfig.radius
    readonly property string font: Settings.fontFamily

    property color privacyColor: root.lightred

    implicitWidth: container.width
    height: parent.height

    Behavior on privacyColor {
        ColorAnimation {
            duration: 500
        }
    }

    Timer {
        id: privacyTimer
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            if (Privacy.screenActive || Privacy.cameraActive || Privacy.microphoneActive) {
                root.privacyColor = root.privacyColor === root.lightred ? root.red : root.lightred;
            } else {
                root.privacyColor = root.lightred;
            }
        }
    }

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

                    Row {
                        id: privacyIconsRow
                        height: parent.height
                        spacing: 6

                        PrivacyIcon {
                            active: Privacy.screenActive
                            iconColor: root.privacyColor
                            text: "󱣴"
                        }
                        PrivacyIcon {
                            active: Privacy.cameraActive
                            iconColor: root.privacyColor
                            text: ""
                        }
                        PrivacyIcon {
                            active: Privacy.microphoneActive
                            iconColor: root.privacyColor
                            text: ""
                        }

                        Text {
                            id: privacySeparator
                            property real visibilityLevel: (Privacy.screenActive || Privacy.cameraActive || Privacy.microphoneActive) ? 1 : 0
                            text: "·"
                            color: root.foregroundColor
                            font.pixelSize: 12
                            font.bold: true
                            font.family: root.font
                            anchors.verticalCenter: parent.verticalCenter
                            opacity: visibilityLevel
                            width: implicitWidth * visibilityLevel

                            Behavior on visibilityLevel {
                                NumberAnimation {
                                    duration: 500
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }
                    }
                    //󰒃  󱟙  󰈈   󰨒   󱖧   

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