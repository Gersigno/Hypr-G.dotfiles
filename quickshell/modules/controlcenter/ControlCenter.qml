import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland

Scope {
    id: root
    property int controlCenterWidth: 340
    property int hyprlandGapsOut: 8
    property int elevationMargin: 8

    Component.onCompleted: {
        console.log("[ControlCenter] Component loaded")
    }

    // États globaux temporaires
    property bool controlCenterOpen: false

    PanelWindow {
        id: controlCenterRoot
        visible: root.controlCenterOpen

        function hide() {
            root.controlCenterOpen = false
        }

        exclusiveZone: 0
        implicitWidth: controlCenterWidth
        WlrLayershell.namespace: "quickshell:controlCenter"
        WlrLayershell.layer: WlrLayer.Top
        color: "transparent"

        anchors {
            top: true
            right: true
            bottom: true
        }

        HyprlandFocusGrab {
            id: grab
            windows: [ controlCenterRoot ]
            active: root.controlCenterOpen
            onCleared: () => {
                if (!active) controlCenterRoot.hide()
            }
        }

        Loader {
            id: controlCenterContentLoader
            active: root.controlCenterOpen
            anchors {
                fill: parent
                margins: hyprlandGapsOut
                leftMargin: elevationMargin
            }
            width: controlCenterWidth - hyprlandGapsOut - elevationMargin
            height: parent.height - hyprlandGapsOut * 2

            focus: root.controlCenterOpen
            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape) {
                    controlCenterRoot.hide();
                }
            }

            sourceComponent: ControlCenterContent {
            }
        }
    }

    IpcHandler {
        target: "controlCenter"

        function toggle(): void {
            root.controlCenterOpen = !root.controlCenterOpen;
        }

        function close(): void {
            root.controlCenterOpen = false;
        }

        function open(): void {
            root.controlCenterOpen = true;
        }
    }

    GlobalShortcut {
        name: "controlCenterToggle"
        description: "Toggles control center on press"

        onPressed: {
            root.controlCenterOpen = !root.controlCenterOpen;
        }
    }

    GlobalShortcut {
        name: "controlCenterOpen"
        description: "Opens control center on press"

        onPressed: {
            root.controlCenterOpen = true;
        }
    }

    GlobalShortcut {
        name: "controlCenterClose"
        description: "Closes control center on press"

        onPressed: {
            root.controlCenterOpen = false;
        }
    }
}