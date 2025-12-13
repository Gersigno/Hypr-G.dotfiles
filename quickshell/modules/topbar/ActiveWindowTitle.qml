import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "../.."

Item {
    id: root
    
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel
    
    Text {
        id: windowTitle
        text: {
            const name = root.activeWindow?.appId || "Desktop";
            return name.charAt(0).toUpperCase() + name.slice(1);
        }
        color: "white"
        font.pixelSize: 12
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
        
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
    }
}