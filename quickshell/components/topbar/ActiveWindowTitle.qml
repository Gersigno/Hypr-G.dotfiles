import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects

import qs.services
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
        color: Colors.on_background
        font.pixelSize: 12
        font.weight: Font.Mediums
        verticalAlignment: Text.AlignVCenter
        
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
    }

    DropShadow {
        anchors.fill: windowTitle
        source: windowTitle
        horizontalOffset: 0
        verticalOffset: 1
        radius: 5.0
        samples: 10
        color: "#A0000000"
    }
}