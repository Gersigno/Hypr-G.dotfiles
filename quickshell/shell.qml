import QtQuick
import Quickshell
import Quickshell.Wayland
import "./modules/controlcenter/"
import "./modules/screencorners/"
import "./modules/topbar/"
import "./modules/common/"

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
    NotificationPopup {
        id: notificationPopup
    }
}