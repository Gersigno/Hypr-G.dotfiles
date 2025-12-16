import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.services
import "../.."


Item {
    id: root

    property real animProgress: 0.0
    property bool isDarkMode: true
    
    anchors.fill: parent 

    onAnimProgressChanged: {
        bottomLeftInvert.requestPaint()
        bottomSection.requestPaint()
        bottomLeftCorner.requestPaint()
    }

    FileView {
        id: themeFile
        path: "/home/gersigno/.config/hypr/hypr-g/hyprland/env.conf"
        onTextChanged: readTheme()
    }

    function readTheme() {
        var lines = themeFile.text().split('\n');
        for (var i = 0; i < lines.length; i++) {
            if (lines[i].startsWith("env = THEME_MODE")) {
                var mode = lines[i].split(',')[1];
                isDarkMode = (mode === "dark");
                break;
            }
        }
    }

    Component.onCompleted: {
        console.log("[ControlCenterContent] Component loaded")
        readTheme()
    }

    Row {
        width: parent.width
        height: parent.height 

        //Inverted corner radius
        Column {
            width: GlobalStates.cornerRadius
            height: parent.height

            //Top left invert corner
            Canvas {
                width: GlobalStates.cornerRadius
                height: GlobalStates.cornerRadius
                
                onPaint: {
                    const ctx = getContext("2d");
                    const w = width;
                    const h = height;
                    const r = GlobalStates.cornerRadius + (GlobalStates.gapsOut * root.animProgress / 100);
                    
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

            //Filler
            Rectangle {
                width: GlobalStates.cornerRadius
                height: parent.height - GlobalStates.cornerRadius * 2
                color: "transparent"
            }

            //Bottom left invert corner
            Canvas {
                id: bottomLeftInvert
                width: GlobalStates.cornerRadius
                height: GlobalStates.cornerRadius
                
                onPaint: {
                    const ctx = getContext("2d");
                    const w = width;
                    const h = height;
                    const factor = Math.min(2.0, Math.max(1.0, root.animProgress / 50)) - 1
                    const r = GlobalStates.cornerRadius * factor //(GlobalStates.cornerRadius + (GlobalStates.gapsOut * root.animProgress / 100)) * factor;
                    
                    ctx.reset();
                    ctx.fillStyle = GlobalStates.backgroundColor;
                    ctx.beginPath();
                    ctx.moveTo(w, h);
                    ctx.lineTo(w - r, h);
                    ctx.arc(w - r, h - r, r, 0.5 * Math.PI, 0, true);
                    ctx.lineTo(w, h);
                    ctx.closePath();
                    ctx.fill();
                }
            }
        }

        Rectangle {
            id: container
            width: parent.width 
            height: parent.height - GlobalStates.cornerRadius
            color: GlobalStates.backgroundColor;
        }
    }

    Canvas {
        id: bottomSection
        width: parent.width - GlobalStates.cornerRadius
        height: GlobalStates.cornerRadius

        x: GlobalStates.cornerRadius
        y: parent.height - GlobalStates.cornerRadius

        onPaint: {
            const ctx = getContext("2d");
            const w = width;
            const h = height;
            const factor = Math.min(root.animProgress / 50, 1.0);
            const r = GlobalStates.cornerRadius * (1 - factor);

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

    Canvas {
        id: bottomLeftCorner
        readonly property real initialSize: GlobalStates.cornerRadius + GlobalStates.gapsOut
        
        width: initialSize
        height: initialSize
        x: parent.width - initialSize
        y: parent.height 
        
        transform: Scale {
            yScale: 1.0 - (root.animProgress / 100) 
            //origin: Transform.Bottom
        }
        
        onPaint: {
            const ctx = getContext("2d");
            const w = width; 
            const h = height; 
            const r = initialSize; 
            
            ctx.reset();
            ctx.fillStyle = GlobalStates.backgroundColor;
            
            ctx.beginPath();
            ctx.moveTo(w, 0);
            ctx.lineTo(w, r);
            ctx.arc(w - r, r, r, 0, 1.5 * Math.PI, true);
            ctx.lineTo(w, 0);
            ctx.closePath();
            ctx.fill();
        }
    }
}