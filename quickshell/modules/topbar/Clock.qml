import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import QtQuick.Effects
import "../.." 

Item {
    id: root
    
    property bool expanded: false
    property int collapsedWidth: 50
    
    implicitWidth: collapsedWidth
    implicitHeight: parent.height
    
    Component.onCompleted: {
        console.log("[Clock] Component completed.")
    }

    // Container for centered background
    Item {
        id: bgContainer
        anchors.centerIn: parent
        width: compactRow.width + (GlobalStates.cornerRadius * 2)
        height: parent.height
        enabled: false

        // Inverse corner on the left
        Canvas {
            x: (GlobalStates.cornerRadius * -1)
            y: 0
            width: GlobalStates.cornerRadius
            height: GlobalStates.cornerRadius
            
            onPaint: {
                const ctx = getContext("2d");
                const w = width;
                const h = height;
                const r = GlobalStates.cornerRadius;
                
                ctx.reset();
                ctx.fillStyle = GlobalStates.backgroundColor;
                
                // Top-left inverse corner (L-shape)
                ctx.beginPath();
                ctx.moveTo(w, 0);
                ctx.lineTo(w, r);
                ctx.arc(w - r, r, r, 0, 1.5 * Math.PI, true);
                ctx.lineTo(w, 0);
                ctx.closePath();
                ctx.fill();
            }
        }

        // Main background rectangle
        Rectangle {
            x: 0
            y: 0
            width: bgContainer.width
            height: parent.height - GlobalStates.cornerRadius
            color: GlobalStates.backgroundColor
        }

        // Bottom section with normal left corner
        Canvas {
            x: 0
            y: parent.height - GlobalStates.cornerRadius
            width: bgContainer.width / 2
            height: GlobalStates.cornerRadius
            onPaint: {
                const ctx = getContext("2d");
                const w = width;
                const h = height;
                const r = GlobalStates.cornerRadius;
                
                ctx.reset();
                ctx.fillStyle = GlobalStates.backgroundColor;
                
                ctx.beginPath();
                ctx.moveTo(0, 0);
                ctx.lineTo(w, 0);
                ctx.lineTo(w, h);
                ctx.lineTo(r, h);
                ctx.arc(r, h - r, r, 0.5 * Math.PI, Math.PI, false);
                ctx.lineTo(0, 0);
                ctx.closePath();
                ctx.fill();
            }
        }

        // Bottom section with normal right corner
        Canvas {
            x: bgContainer.width / 2 - 1
            y: parent.height - GlobalStates.cornerRadius
            width: bgContainer.width / 2 + 1
            height: GlobalStates.cornerRadius
            
            onPaint: {
                const ctx = getContext("2d");
                const w = width;
                const h = height;
                const r = GlobalStates.cornerRadius;
                
                ctx.reset();
                ctx.fillStyle = GlobalStates.backgroundColor;
                
                ctx.beginPath();
                ctx.moveTo(0, 0);
                ctx.lineTo(w, 0);
                ctx.arc(w - r, 0, r, 0, 0.5 * Math.PI, false);
                ctx.lineTo(w - r, h);
                ctx.lineTo(0, h);
                ctx.closePath();
                ctx.fill();
            }
        }

        // Inverse corner on the right
        Canvas {
            x: bgContainer.width
            y: 0
            width: GlobalStates.cornerRadius
            height: GlobalStates.cornerRadius
            
            onPaint: {
                const ctx = getContext("2d");
                const w = width;
                const h = height;
                const r = GlobalStates.cornerRadius;
                
                ctx.reset();
                ctx.fillStyle = GlobalStates.backgroundColor;
                
                // Top-right inverse corner (L-shape)
                ctx.beginPath();
                ctx.moveTo(0, 0);
                ctx.lineTo(r, 0);
                ctx.arc(r, r, r, 1.5 * Math.PI, Math.PI, true);
                ctx.closePath();
                ctx.fill();
            }
        }

        Row {
            id: compactRow

            anchors.centerIn: parent
            height: parent.height
            spacing: 4

            // Media play icon
            Text {
                id: mediaIcon
                text: ""
                color: "white"
                font.pixelSize: 12
                font.family: "SF Pro Display"
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
                width: Media.isPlaying ? implicitWidth : 0
                opacity: Media.isPlaying ? 1 : 0
                
                layer.enabled: true
                layer.effect: MultiEffect {
                    blurEnabled: !Media.isPlaying
                    source: mediaIcon
                    blur: Media.isPlaying ? 0 : 1
                    Behavior on blur {
                        NumberAnimation { duration: 300 }
                    }
                }

                Behavior on width {
                    NumberAnimation { 
                        duration: 300
                        easing.type: Easing.InOutQuint 
                    }
                }

                Behavior on opacity {
                    NumberAnimation { 
                        duration: 300
                    }
                }
            }

            // Compact time display
            Text {
                id: compactTime

                text: new Date().toLocaleTimeString(Qt.locale(), "HH:mm")
                color: "white"
                font.pixelSize: 12
                font.family: "SF Pro Display"
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }

            // Cut
            Text {
                text: "·"
                color: "white"
                font.pixelSize: 12
                font.family: "SF Pro Display"
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }

            //Compact date
            Text {
                id: compactDate

                font.family: "SF Pro Display"
                text: new Date().toLocaleDateString(Qt.locale(), "dddd, d MMM")
                color: "white"
                font.pixelSize: 12

                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: micInUseIcon
                text: " "
                color: "white"
                font.pixelSize: 12
                font.family: "SF Pro Display"
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter

                width: InputsUsage.micInUse ? implicitWidth : 0
                opacity: InputsUsage.micInUse ? 1 : 0
                
                layer.enabled: true
                layer.effect: MultiEffect {
                    blurEnabled: !InputsUsage.micInUse
                    source: micInUseIcon
                    blur: InputsUsage.micInUse ? 0 : 1
                    Behavior on blur {
                        NumberAnimation { duration: 300 }
                    }
                }

                Behavior on width {
                    NumberAnimation { 
                        duration: 300
                        easing.type: Easing.InOutQuint 
                    }
                }

                Behavior on opacity {
                    NumberAnimation { 
                        duration: 300
                    }
                }
            }
            Text {
                id: cameraInUseIcon
                text: " "
                color: "white"
                font.pixelSize: 12
                font.family: "SF Pro Display"
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
                //visible: InputsUsage.cameraInUse

                width: InputsUsage.cameraInUse ? implicitWidth : 0
                opacity: InputsUsage.cameraInUse ? 1 : 0
                
                layer.enabled: true
                layer.effect: MultiEffect {
                    blurEnabled: !InputsUsage.cameraInUse
                    source: cameraInUseIcon
                    blur: InputsUsage.cameraInUse ? 0 : 1
                    Behavior on blur {
                        NumberAnimation { duration: 300 }
                    }
                }

                Behavior on width {
                    NumberAnimation { 
                        duration: 300
                        easing.type: Easing.InOutQuint 
                    }
                }

                Behavior on opacity {
                    NumberAnimation { 
                        duration: 300
                    }
                }
            }

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }
    }
    
    // Timer to update compact time
    Timer {
        interval: 1000
        running: !root.expanded
        repeat: true
        onTriggered: {
            compactTime.text = new Date().toLocaleTimeString(Qt.locale(), "HH:mm");
            compactDate.text = new Date().toLocaleDateString(Qt.locale(), "dddd, d MMM");
        }
    }
    
    // Click handler
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        
        onEntered: {
            //console.log("[Clock MouseArea] Mouse entered")
        }
        
        onExited: {
            //console.log("[Clock MouseArea] Mouse exited")
        }
        
        onClicked: {
            //console.log("[Clock] Clicked! current expanded:", root.expanded, "will toggle to:", !root.expanded)
            root.expanded = true;
            //console.log("[Clock] After toggle, expanded is now:", root.expanded)
        }
    }
}

