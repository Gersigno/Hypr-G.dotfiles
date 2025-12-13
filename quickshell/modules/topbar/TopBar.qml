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
    
    Component.onCompleted: {
        console.log("[TopBar] Component loaded")
    }

    // Clock panel (floating)
    ClockExpanded {
        expanded: root.clockExpanded
        topBarHeight: root.barHeight
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
                onExpandedChanged: root.clockExpanded = expanded
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
            }
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
