import QtQuick
import Quickshell
import Quickshell.Wayland
import "./modules/controlcenter/"

ShellRoot {
    // Enable/disable modules here
    property bool enableControlCenter: true

    ControlCenter {
    }


    /*PanelLoader { identifier: "ControlCenter"; component: ControlCenter {} }

    component PanelLoader: LazyLoader {
        required property string identifier
        property bool extraCondition: true
        active: Config.ready && Config.options.enabledPanels.includes(identifier) && extraCondition
    }*/
}