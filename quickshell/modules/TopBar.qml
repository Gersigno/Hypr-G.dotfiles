import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

import "../components/topbar"

Item {
    id: root

    property bool opened: true
    property int targetOpacity: 1
    property int barHeight: opened ? 24 : 0
    property real statusWidth: 0
    property real clockWidth: 0
    property string controlCenterOpenedScreenName: ""

    Component.onCompleted: {
        console.info("Loaded component: [TopBar]")
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData


            WlrLayershell.namespace: "quickshell:topBar"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusiveZone: Math.round(root.barHeight)
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            

            mask: Region {
                item: workspacesComponent
            }

            implicitHeight: root.barHeight

            anchors {
                top: true
                left: true
                right: true 
            }

            color: "transparent"

            WorkSpaces {
                id: workspacesComponent
                screen: modelData
            }
            ActiveWindowTitle {
                id: activeWindowTitleComponent
                screen: modelData
                x: workspacesComponent.width
            }

            Clock {
                id: clockComponent

                opacity: root.controlCenterOpenedScreenName === modelData.name ? 0 : 1
                visible: opened
                Behavior on opacity {
                    NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
                }

                Component.onCompleted: root.clockWidth = width
                onWidthChanged: root.clockWidth = width

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                }
            }

            Status {
                id: statusComponent
                visible: opened
                
                Component.onCompleted: root.statusWidth = width
                onWidthChanged: root.statusWidth = width

                anchors {
                    right: parent.right
                    top: parent.top
                }
            }
        }
    }

    GlobalShortcut {
        name: "topBarToggle"
        description: "Toggles top bar on press"
        
        onPressed: {
            root.opened = !root.opened;
        }
    }
}