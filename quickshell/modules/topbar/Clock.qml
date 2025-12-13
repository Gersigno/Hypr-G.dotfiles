import QtQuick
import Quickshell
import "../.."

Item {
    id: root
    
    property bool expanded: false
    property int collapsedWidth: 50
    
    implicitWidth: collapsedWidth
    implicitHeight: parent.height
    
    Component.onCompleted: {
        console.log("[Clock] Component completed. Width:", width, "Height:", height, "Implicit width:", implicitWidth)
    }

    // Container for centered background
    Item {
        id: bgContainer
        anchors.centerIn: parent
        width: compactTime.width + (GlobalStates.cornerRadius * 2)
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
            x: bgContainer.width / 2
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
        
        // Compact time display
        Text {
            id: compactTime
            anchors.centerIn: parent
            text: new Date().toLocaleTimeString(Qt.locale(), "HH:mm")
            color: "white"
            font.pixelSize: 10
            opacity: root.expanded ? 0 : 1
            
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
        }
    }
    
    // Click handler
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        
        onEntered: {
            console.log("[Clock MouseArea] Mouse entered")
        }
        
        onExited: {
            console.log("[Clock MouseArea] Mouse exited")
        }
        
        onClicked: {
            console.log("[Clock] Clicked! current expanded:", root.expanded, "will toggle to:", !root.expanded)
            root.expanded = !root.expanded;
            console.log("[Clock] After toggle, expanded is now:", root.expanded)
        }
    }
}

