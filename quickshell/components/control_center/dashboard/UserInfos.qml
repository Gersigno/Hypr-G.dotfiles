import QtQuick
import Quickshell
import QtCore as Core
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import QtQuick.Effects
import Quickshell.Io

import qs.services
import "../../../utils"
import "../../../services"
import "../../common/interface"

Item {
    id: root

    readonly property string home: Core.StandardPaths.standardLocations(Core.StandardPaths.HomeLocation)[0]
    readonly property string userName: home.split('/').pop().charAt(0).toUpperCase() + home.split('/').pop().slice(1)
    
    readonly property color foregroundColor: Colors.on_background
    readonly property string font: Settings.fontFamily

    BackgroundLayer {
        id: background
        anchors.fill: parent
    }

    Row {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 16

        ClippingRectangle {
            width: parent.height
            height: parent.height
            color: "transparent"
            radius: HyprlandConfig.radius
            clip:true 

            Image {
                anchors.fill: parent
                source: root.home + "/.face.png" //TODO: update/refresh when the user changes their profile picture 
                fillMode: Image.PreserveAspectCrop

                asynchronous: true
                smooth: true
                mipmap: true
                sourceSize.width: 128
                sourceSize.height: 128

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
                text: "   "
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
                            uptimeText.text = "   " + uptimeText.formatUptime(uptimeSeconds);
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