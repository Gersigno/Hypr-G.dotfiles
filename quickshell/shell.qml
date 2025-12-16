import QtQuick
import Quickshell
import Quickshell.Wayland
import "./modules/controlcenter/"
import "./modules/screencorners/"
import "./modules/topbar/"

ShellRoot {
    id: rootShell

    ControlCenter {
        id: controlCenterComponent
    }
    ScreenCorners {
        id: screenCornersComponent
    }
    TopBar {
        id: topBarComponent
    }
}