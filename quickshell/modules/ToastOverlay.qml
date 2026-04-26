import QtQuick
import Quickshell
import Quickshell.Wayland
import QtCore


import "../components/common/interface"
import "../services"
import "../config"
import "../utils"


Scope {
    id: root

    readonly property string home: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
    readonly property string userName: home.split('/').pop().charAt(0).toUpperCase() + home.split('/').pop().slice(1)


    Component.onCompleted: {
        console.info("Loaded component: [ToastOverlay]")
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panelRoot
            property var modelData
            screen: modelData

            color: "transparent"

            WlrLayershell.namespace: "quickshell:toast"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusiveZone: 0
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            mask: Region { item: null }

            implicitWidth: modelData.width
            implicitHeight: toastItem.implicitHeight + 64

            anchors {
                bottom: true
                left: true
                right: true
            }

            Toast {
                id: toastItem
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 24

                y: 200//toastItem.opacity > 0 ? 0 : 12
                opacity: 0
            }

            Connections {
                target: ToastService
                function onToastRequested(message, icon, duration) {
                    toastItem.show(message, duration, icon)
                    //console.log("Toast requested: " + message + ", duration: " + duration + ", icon: " + icon)
                }
            }

            Component.onCompleted: {
                ToastService.show("Welcome back, " + userName + " !", 6000)
            }
        }
    }
}
