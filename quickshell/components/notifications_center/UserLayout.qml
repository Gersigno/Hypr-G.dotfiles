import QtQuick
import Quickshell
import QtCore
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import QtQuick.Effects
import Quickshell.Io

import "../../services"
import "../../config"
import "../../utils"

Item {
    id: root

    implicitHeight: userLayout.height

    readonly property string home: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
    readonly property string userName: home.split('/').pop().charAt(0).toUpperCase() + home.split('/').pop().slice(1)
    readonly property color foregroundColor: Config.isOled ? "#fff" : Colors.on_background
    readonly property string font: Config.fontFamily

    Rectangle {
        id: userLayout
        width: parent.width
        height: contentColumn.height
        color: "transparent"

        Row {
            id: contentColumn
            width: parent.width
            //height: childrenRect.height
            spacing: 8

            ClippingRectangle {
                width: 50
                height: 50
                color: "transparent"
                radius: HyprlandConfig.radius
                clip:true 

                Image {
                    anchors.fill: parent
                    source: root.home + "/.face.png" //TODO: update/refresh when the user changes their profile picture 
                    fillMode: Image.PreserveAspectCrop

                    onStatusChanged: {
                        if (status == Image.Error) {
                            source = root.home + "/.config/quickshell/assets/default_face.png"
                        }
                    }
                }
            }

            //Username and uptime
            Column {
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    text: root.userName
                    font.pixelSize: 16
                    font.bold: true
                    color: root.foregroundColor
                    font.family: root.font
                }
                Text {
                    id: uptimeText
                    text: "Up time: "
                    font.pixelSize: 13
                    font.family: root.font
                    color: root.foregroundColor

                    function formatUptime(seconds) {
                        let h = Math.floor(seconds / 3600);
                        let m = Math.floor((seconds % 3600) / 60);
                        return h.toString().padStart(2, '0') + "h " + 
                            m.toString().padStart(2, '0') + "m";
                    }

                    Process {
                        id: uptimeProcess
                        command: ["cat", "/proc/uptime"]
                        running: true
                        stdout: SplitParser {
                            onRead: (data) => {
                                const uptimeSeconds = parseFloat(data.split(" ")[0]);
                                uptimeText.text = "Uptime: " + uptimeText.formatUptime(uptimeSeconds);
                            }
                        }
                    }

                    Timer {
                        interval: 60000
                        running: true
                        repeat: true
                        triggeredOnStart: true
                        onTriggered: {
                            uptimeProcess.running = false;
                            uptimeProcess.running = true;
                        }
                    }
                }
            }
        }
    }
}