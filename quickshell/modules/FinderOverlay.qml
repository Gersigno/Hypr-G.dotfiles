import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

import "../components/common/interface"
import "../services"
import qs.services
import "../utils"

Scope {
    id: root

    property string openedScreenName: ""
    readonly property bool opened: openedScreenName !== ""

    Component.onCompleted: {
        console.info("Loaded component: [FinderOverlay]")
    }

    Connections {
        target: FinderService

        function onOpenRequested() {
            root.openedScreenName = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : ""
        }
        function onCloseRequested() {
            root.openedScreenName = ""
        }
    }

    IpcHandler {
        target: "finder"
        function toggle(): void {
            FinderService.toggle()
        }
        function open(): void {
            FinderService.open()
        }
        function close(): void {
            FinderService.close()
        }
        function setQuery(query: string): void {
            FinderService.query = query
            FinderService.open()
        }
    }

    GlobalShortcut {
        name: "launcherToggle"
        description: "Toggle Finder"
        onPressed: FinderService.toggle()
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panelRoot
            property var modelData
            screen: modelData

            readonly property bool isOpened: root.openedScreenName === modelData.name

            WlrLayershell.namespace: "quickshell:finder"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusiveZone: 0
            WlrLayershell.keyboardFocus: isOpened ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

            color: "transparent"

            mask: Region {
                item: isOpened ? finderUI : null
            }

            implicitWidth: modelData ? modelData.width : 0
            implicitHeight: modelData ? modelData.height : 0

            anchors {
                bottom: true
                left: true
                right: true
            }

            HyprlandFocusGrab {
                windows: [ panelRoot ]
                active: isOpened
                onCleared: if (active) FinderService.close()
            }

            FinderUI {
                id: finderUI
                opacity: 0
            }

            Binding {
                target: finderUI
                property: "results"
                value: FinderService.results
            }
            Binding {
                target: finderUI
                property: "query"
                value: FinderService.query
                restoreMode: Binding.RestoreBindingOrValue
            }
            Binding {
                target: finderUI
                property: "screenHeight"
                value: modelData ? modelData.height : 1080
            }

            function searchTextChangedHook(text) {
                FinderService.query = text
            }
            function submittedHook(result) {
                FinderService.execute(result)
            }
            function canceledHook() {
                FinderService.close()
            }

            Component.onCompleted: {
                finderUI.searchTextChanged.connect(searchTextChangedHook)
                finderUI.submitted.connect(submittedHook)
                finderUI.canceled.connect(canceledHook)
            }

            onIsOpenedChanged: {
                if (isOpened)
                    finderUI.show()
                else
                    finderUI.hide()
            }
        }
    }
}
