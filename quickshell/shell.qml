//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import Quickshell
import QtQuick

import "modules"

ShellRoot {
    id: rootShell

    property var topBarComponent: topBar

    ScreenCorners {
        id: screenCorners
    }

    TopBar {
        id: topBar
        //controlCenterComponent: controlCenter
    }

    NotificationsCenter {
        id: notificationsCenter
        topBarComponent: rootShell.topBarComponent
    }

    ControlCenter {
        id: controlCenter
        topBarComponent: rootShell.topBarComponent
    }

    ToastOverlay {
        id: toastOverlay
    }

    Binding {
        target: topBar
        property: "controlCenterOpenedScreenName"
        value: controlCenter.openedScreenName
    }
}