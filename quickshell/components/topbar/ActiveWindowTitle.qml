import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

import "../../config"
import "../../utils"

Item {
    id: root

    property var screen
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel
    
    height: parent.height
    implicitWidth: windowTitle.width

    Text {
        id: windowTitle
        text: {
            const name = root.activeWindow?.appId || "Desktop";
            return name.charAt(0).toUpperCase() + name.slice(1);
        }
        color: Config.isOled ? "#fff" : Colors.on_background
        font.pixelSize: 12
        style: Text.Raised
        font.weight: Font.Medium
        verticalAlignment: Text.AlignVCenter
        
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
    }
}