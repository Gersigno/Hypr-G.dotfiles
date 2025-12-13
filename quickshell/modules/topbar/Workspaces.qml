import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../.."

Item {
    id: root
    
    property var screen
    
    // Determine workspace range based on screen
    property var workspaceIds: {
        if (!screen) return [1, 2, 3, 4];
        
        const screenName = screen.name;
        if (screenName.includes("eDP")) return [1, 2, 3, 4];
        if (screenName.includes("HDMI")) return [5, 6, 7, 8];
        if (screenName.includes("DP")) return [9, 10, 11, 12];
        return [1, 2, 3, 4];
    }
    
    implicitWidth: container.width
    height: parent.height
    
    Item {
        id: container
        width: workspaceRow.width + 8 + GlobalStates.cornerRadius
        height: parent.height
        
        // Main background rectangle
        Rectangle {
            x: 0
            y: 0
            width: workspaceRow.width + 8
            height: parent.height - GlobalStates.cornerRadius
            color: GlobalStates.backgroundColor
        }
        
        // Bottom section with normal corner
        Canvas {
            x: 0
            y: parent.height - GlobalStates.cornerRadius
            width: workspaceRow.width + 8
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
                ctx.lineTo(0, h);
                ctx.closePath();
                ctx.fill();
            }
        }
        
        // Inverse corner on the right
        Canvas {
            x: workspaceRow.width + 8
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
        
        // Workspaces row
        Row {
            id: workspaceRow
            height: parent.height
            spacing: 1
            x: 4
            
            Repeater {
                model: root.workspaceIds
                
                Item {
                    width: 18
                    height: workspaceRow.height
                    
                    property int workspaceId: modelData
                    property bool isActive: Hyprland.focusedWorkspace?.id === workspaceId
                    property bool hasWindowsValue: false
                    
                    function updateHasWindows() {
                        const workspace = Hyprland.workspaces.values.find(ws => ws.id === workspaceId);
                        hasWindowsValue = workspace ? workspace.lastWindow !== null && workspace.lastWindow !== undefined : false;
                    }
                    
                    Component.onCompleted: updateHasWindows()
                    
                    Connections {
                        target: Hyprland.workspaces
                        function onValuesChanged() {
                            updateHasWindows();
                        }
                    }
                    
                    // Workspace indicator
                    Text {
                        anchors.centerIn: parent
                        text: {
                            if (parent.isActive) return "●";
                            if (parent.hasWindowsValue) return "◉";
                            return "○";
                        }
                        color: "white"
                        font.pixelSize: 10
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            Hyprland.dispatch(`workspace ${workspaceId}`);
                        }
                    }
                }
            }
        }
    }
}
