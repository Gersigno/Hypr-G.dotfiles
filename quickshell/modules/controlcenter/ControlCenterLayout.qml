import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Qt5Compat.GraphicalEffects
import qs.services
import "../.."


Item {
    id: root

    property real animProgress: 0.0
    property real finalHeight: Hyprland.focusedMonitor.height
    
    anchors.fill: parent 
    signal animValueChanged(real animProgress)

    onAnimProgressChanged: {
        bottomLeftInvert.requestPaint()
        bottomLeftCorner.requestPaint()
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
                width: parent.width
                height: finalHeight - GlobalStates.cornerRadius * 2
                color: "transparent"
            }

            Canvas {
                id: bottomLeftInvert
                width: GlobalStates.cornerRadius
                height: GlobalStates.cornerRadius
                //y: finalHeight - (GlobalStates.cornerRadius + GlobalStates.gapsOut)
                //x: 0 - width

                
                onPaint: {
                    const ctx = getContext("2d");
                    const w = width;
                    const h = height;
                    //const baseToMiddle = GlobalStates.cornerRadius + (Math.min(1.0, Math.max(0.0, root.animProgress / 50) * 2)) * 20;
                    //const final = baseToMiddle * ((Math.min(2.0, Math.max(1.0, root.animProgress / 50))) - 2) * -1;
                    //console.log(middleToEnd);
                    const limit = 95;
                    let factor = 0;
                    if (root.animProgress >= limit) {
                        factor = (root.animProgress - limit) / 20;
                    }
                    
                    const r = (GlobalStates.cornerRadius + GlobalStates.gapsOut) * factor //(GlobalStates.cornerRadius + (GlobalStates.gapsOut * root.animProgress / 100)) * factor;
                    
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

        // Body
        Rectangle {
            id: container
            width: parent.width
            height: parent.height
            color: GlobalStates.backgroundColor;

            property real factor: 200;
            property real firstHalf: (GlobalStates.cornerRadius + (Math.min(1.0, Math.max(0.0, root.animProgress / 100) * 2)) * 200);
            property real full: firstHalf * ((Math.min(2.0, Math.max(1.0, root.animProgress / 50))) - 2) * -1

            bottomLeftRadius: full;

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: container.width
                    height: container.height
                    bottomLeftRadius: container.bottomLeftRadius;
                }
            }


            Rectangle {
                width: parent.width - (GlobalStates.cornerRadius * 3)
                height: parent.height - (GlobalStates.cornerRadius * 3)
                x: GlobalStates.cornerRadius
                y: GlobalStates.cornerRadius * 2
                color: "transparent"
                clip: true

                ControlCenterContent {
                    anchors.fill: parent
                    animProgress: root.animProgress
                }
            }
        }
    }
                
    //Bottom left invert corner

    /*Canvas {
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
    }*/

    Canvas {
        id: bottomLeftCorner
        readonly property real initialSize: GlobalStates.cornerRadius + GlobalStates.gapsOut
        
        width: initialSize
        height: initialSize
        x: parent.width - initialSize
        y: parent.height 
        
        transform: Scale {
            yScale: 1.0 - (root.animProgress / 100)
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