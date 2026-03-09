import QtQuick
import Quickshell
import Quickshell.Wayland
import "../.."

Scope {
    id: root
    
    property int cornerRadius: GlobalStates.cornerRadius
    property int gapsOut: GlobalStates.gapsOut
    property color cornerColor: GlobalStates.backgroundColor
    // Effective corner radius that should visually match Hyprland window rounding plus outer gap
    property int effectiveRadius: cornerRadius + gapsOut
    
    Component.onCompleted: {
        console.log("[ScreenCorners] Component loaded")
    }
    
    // Top-left corners
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            property var modelData
            screen: modelData
            
            visible: true
            color: "transparent"
            
            WlrLayershell.namespace: "quickshell:screenCorners-topLeft"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusiveZone: 0
                implicitWidth: effectiveRadius
                implicitHeight: effectiveRadius
            // PanelWindow sizing uses implicitWidth/implicitHeight to avoid deprecation warnings
            
            anchors {
                top: true
                left: true
            }
            
            Canvas {
                anchors.fill: parent
                onPaint: {
                    const ctx = getContext("2d");
                    const w = width;
                    const h = height;
                    const r = effectiveRadius;
                    ctx.reset();
                    ctx.fillStyle = cornerColor;
                    // Top-left L-shape
                    ctx.beginPath();
                    ctx.moveTo(0, 0);
                    ctx.lineTo(r, 0);
                    ctx.arc(r, r, r, 1.5 * Math.PI, Math.PI, true);
                    ctx.lineTo(0, 0);
                    ctx.closePath();
                    ctx.fill();
                }
            }
        }
    }
    
    // Top-right corners
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            property var modelData
            screen: modelData
            
            visible: true
            color: "transparent"
            
            WlrLayershell.namespace: "quickshell:screenCorners-topRight"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusiveZone: 0
                implicitWidth: effectiveRadius
                implicitHeight: effectiveRadius
            
            // PanelWindow sizing uses implicitWidth/implicitHeight to avoid deprecation warnings
            
            anchors {
                top: true
                right: true
            }
            
            Canvas {
                anchors.fill: parent
                onPaint: {
                    const ctx = getContext("2d");
                    const w = width;
                    const h = height;
                    const r = effectiveRadius;
                    ctx.reset();
                    ctx.fillStyle = cornerColor;
                    // Top-right L-shape
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
    }
    
    // Bottom-left corners
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            property var modelData
            screen: modelData
            
            visible: true
            color: "transparent"
            
            WlrLayershell.namespace: "quickshell:screenCorners-bottomLeft"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusiveZone: 0
                implicitWidth: effectiveRadius
                implicitHeight: effectiveRadius
            
            // PanelWindow sizing uses implicitWidth/implicitHeight to avoid deprecation warnings
            
            anchors {
                bottom: true
                left: true
            }
            
            Canvas {
                anchors.fill: parent
                onPaint: {
                    const ctx = getContext("2d");
                    const w = width;
                    const h = height;
                    const r = effectiveRadius;
                    ctx.reset();
                    ctx.fillStyle = cornerColor;
                    // Bottom-left L-shape
                    ctx.beginPath();
                    ctx.moveTo(0, h);
                    ctx.lineTo(0, h - r);
                    ctx.arc(r, h - r, r, Math.PI, 0.5 * Math.PI, true);
                    ctx.lineTo(0, h);
                    ctx.closePath();
                    ctx.fill();
                }
            }
        }
    }
    
    // Bottom-right corners
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            property var modelData
            screen: modelData
            
            visible: true
            color: "transparent"
            
            WlrLayershell.namespace: "quickshell:screenCorners-bottomRight"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusiveZone: 0
                implicitWidth: effectiveRadius
                implicitHeight: effectiveRadius
            
            // PanelWindow sizing uses implicitWidth/implicitHeight to avoid deprecation warnings
            
            anchors {
                bottom: true
                right: true
            }
            
            Canvas {
                anchors.fill: parent
                onPaint: {
                    const ctx = getContext("2d");
                    const w = width;
                    const h = height;
                    const r = effectiveRadius;
                    ctx.reset();
                    ctx.fillStyle = cornerColor;
                    // Bottom-right L-shape
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
    }
}
