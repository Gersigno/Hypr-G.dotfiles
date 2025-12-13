import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import "../.."

Scope {
    id: root
    
    property int barHeight: 24
    property bool barVisible: true
    property bool clockExpanded: false
    
    onClockExpandedChanged: {
        console.log("[TopBar] root.clockExpanded changed to:", clockExpanded)
    }
    
    Component.onCompleted: {
        console.log("[TopBar] Component loaded")
        console.log("[TopBar] Initial clockExpanded state:", root.clockExpanded)
    }


    
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            property var modelData
            property int panelHeight: root.barHeight
            screen: modelData
            
            visible: root.barVisible
            color: "transparent"
            
            WlrLayershell.namespace: "quickshell:topBar"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusiveZone: root.barVisible ? panelHeight : 0
            
            implicitHeight: panelHeight
            
            anchors {
                top: true
                left: true
                right: true
            }
            
            Workspaces {
                id: workspaces
                screen: modelData
                anchors {
                    left: parent.left
                    top: parent.top
                }
                height: panelHeight
            }
            
            Clock {
                id: clock
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                }
                height: panelHeight
                width: implicitWidth
                z: 10
                
                Component.onCompleted: {
                    console.log("[TopBar Clock] Width after layout:", width, "Height:", height)
                }
                
                onExpandedChanged: {
                    console.log("[Clock] expanded changed to:", expanded)
                    root.clockExpanded = expanded
                }
            }
            
            Connections {
                target: clockExpanded
                function onExpandedChanged() {
                    console.log("[TopBar] ClockExpanded.onExpandedChanged signal received, clockExpanded.expanded:", clockExpanded.expanded)
                    clock.expanded = clockExpanded.expanded
                }
            }
            
            ActiveWindowTitle {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    leftMargin: Math.max(workspaces.width + 8, clock.width / 2 + 60)
                    rightMargin: 8
                }
                height: panelHeight
                
                Component.onCompleted: {
                    console.log("[ActiveWindowTitle] Width:", width, "X position:", x, "LeftMargin:", Math.max(workspaces.width + 8, clock.width / 2 + 60))
                }
            }
        }
    }

    // Clock panel (floating)
    ClockExpanded {
        id: clockExpanded
        expanded: root.clockExpanded
        topBarHeight: root.barHeight
        
        Component.onCompleted: {
            console.log("[ClockExpanded] Component completed")
        }
    }
    
    GlobalShortcut {
        name: "topBarToggle"
        description: "Toggles top bar on press"
        
        onPressed: {
            root.barVisible = !root.barVisible;
        }
    }
}
