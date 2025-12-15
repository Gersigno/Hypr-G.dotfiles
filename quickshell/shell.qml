import QtQuick
import Quickshell
import Quickshell.Wayland
import "./modules/controlcenter/"
import "./modules/screencorners/"
import "./modules/topbar/"

ShellRoot {
    // Enable/disable modules here
    property bool enableControlCenter: true
    property bool enableScreenCorners: true
    property bool enableTopBar: true

    ControlCenter { }
    ScreenCorners { }
    TopBar {
        id: topBarComponent
    }
}