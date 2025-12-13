import QtQuick
import Quickshell
import Quickshell.Wayland
import "../.."

Scope {
    id: root
    
    property bool expanded: false
    property int expandedWidth: 420
    property int expandedHeight: 180
    property int collapsedWidth: 50
    property int topBarHeight: 24
    
    // Animated widths and heights
    property real animatedWidth: root.expanded ? expandedWidth : collapsedWidth
    property real animatedHeight: root.expanded ? expandedHeight : topBarHeight
    property real contentOpacity: root.expanded ? 1.0 : 0.0
    
    onExpandedChanged: {
        console.log("[ClockExpanded] expanded changed to:", expanded)
    }
    
    onAnimatedWidthChanged: {
        console.log("[ClockExpanded] animatedWidth changed to:", animatedWidth)
    }
    
    onContentOpacityChanged: {
        console.log("[ClockExpanded] contentOpacity changed to:", contentOpacity)
    }
    
    onAnimatedHeightChanged: {
        console.log("[ClockExpanded] animatedHeight changed to:", animatedHeight)
    }
    
    Behavior on animatedWidth {
        NumberAnimation {
            duration: 1000
            easing.type: Easing.Bezier
            easing.bezierCurve: [0.18, 0.95, 0.2, 1.08]
        }
    }
    
    Behavior on animatedHeight {
        NumberAnimation {
            duration: 1000
            easing.type: Easing.Bezier
            easing.bezierCurve: [0.18, 0.95, 0.2, 1.08]
        }
    }
    
    Behavior on contentOpacity {
        NumberAnimation {
            duration: 1000
            easing.type: Easing.Bezier
            easing.bezierCurve: [0.18, 0.95, 0.2, 1.08]
        }
    }
    
    // Floating panel window for each screen
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            property var modelData
            screen: modelData
            
            visible: root.expanded
            color: "transparent"
            
            WlrLayershell.namespace: "quickshell:clockExpanded"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusiveZone: 0
            
            implicitWidth: root.animatedWidth
            implicitHeight: root.animatedHeight
            margins {
                top: (topBarHeight * -1)
            }

            anchors {
                top: true
            }
            
            // Top-left inverse corner
            Canvas {
                x: 0
                y: 0
                width: GlobalStates.cornerRadius
                height: GlobalStates.cornerRadius
                visible: root.expanded
                opacity: root.contentOpacity
                
                onPaint: {
                    const ctx = getContext("2d");
                    const w = width;
                    const h = height;
                    const r = GlobalStates.cornerRadius;
                    
                    ctx.reset();
                    ctx.fillStyle = GlobalStates.backgroundColor;
                    
                    // Top-left inverse corner (L-shape)
                    ctx.beginPath();
                    ctx.moveTo(r, 0);
                    ctx.lineTo(w, 0);
                    ctx.arc(0, r, r, 0, 1.5 * Math.PI, true);
                    ctx.closePath();
                    ctx.fill();
                }
            }
            
            // Top-right inverse corner
            Canvas {
                x: root.animatedWidth - GlobalStates.cornerRadius
                y: 0
                width: GlobalStates.cornerRadius
                height: GlobalStates.cornerRadius
                visible: root.expanded
                opacity: root.contentOpacity
                
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
            
            // Main background rectangle
            Rectangle {
                x: GlobalStates.cornerRadius
                y: 0
                width: root.animatedWidth - GlobalStates.cornerRadius * 2
                height: root.animatedHeight - 2 * GlobalStates.cornerRadius + GlobalStates.cornerRadius
                color: GlobalStates.backgroundColor
                opacity: root.contentOpacity
            }
            
            // Bottom-left corner (normal)
            Canvas {
                x: GlobalStates.cornerRadius
                y: root.animatedHeight - GlobalStates.cornerRadius
                width: GlobalStates.cornerRadius
                height: GlobalStates.cornerRadius
                visible: root.expanded
                opacity: root.contentOpacity
                
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
            Canvas {
                x: root.animatedWidth - (GlobalStates.cornerRadius * 2)
                y: root.animatedHeight - GlobalStates.cornerRadius
                width: GlobalStates.cornerRadius
                height: GlobalStates.cornerRadius
                visible: root.expanded
                opacity: root.contentOpacity
                
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
            
            // Bottom rectangle strip between corners
            Rectangle {
                x: GlobalStates.cornerRadius + GlobalStates.cornerRadius
                y: root.animatedHeight - GlobalStates.cornerRadius
                width: root.animatedWidth - 2 * GlobalStates.cornerRadius - (GlobalStates.cornerRadius * 2)
                height: GlobalStates.cornerRadius
                color: GlobalStates.backgroundColor
                opacity: root.contentOpacity
            }
            
            // Content
            Column {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -8
                spacing: 4
                opacity: root.contentOpacity
                visible: root.contentOpacity > 0
                
                // Hour
                Text {
                    id: expandedHour
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: new Date().toLocaleTimeString(Qt.locale(), "HH")
                    color: "white"
                    font.pixelSize: 80
                    font.family: "StretchPro"
                    font.preferTypoLineMetrics: true
                    leftPadding: -60
                }

                // Minutes
                Text {
                    id: expandedMinutes
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: new Date().toLocaleTimeString(Qt.locale(), "mm")
                    color: "white"
                    font.pixelSize: 60
                    font.family: "StretchPro"
                    font.bold: true
                    font.preferTypoLineMetrics: true
                    rightPadding: -30
                    topPadding: -20
                }
                
                Text {
                    id: dateText
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: new Date().toLocaleDateString(Qt.locale(), "dddd d MMMM")
                    color: "white"
                    font.family: "SF Pro Display"
                    font.bold: true
                    font.pixelSize: 18
                    topPadding: -10
                }
            }
            
            // Timer to update time
            Timer {
                interval: 100
                running: root.expanded
                repeat: true
                onTriggered: {
                    expandedHour.text = new Date().toLocaleTimeString(Qt.locale(), "HH");
                    expandedMinutes.text = new Date().toLocaleTimeString(Qt.locale(), "mm");
                    dateText.text = new Date().toLocaleDateString(Qt.locale(), "dddd d MMMM");
                }
            }
            
            // Close on click outside
            MouseArea {
                anchors.fill: parent
                z: -1
                enabled: root.expanded
                
                onEntered: {
                    console.log("[ClockExpanded MouseArea] Entered (enabled:", enabled, ")")
                }
                
                onClicked: {
                    console.log("[ClockExpanded] MouseArea clicked, closing panel (enabled was:", enabled, ")")
                    root.expanded = false;
                }
            }
        }
    }
}
