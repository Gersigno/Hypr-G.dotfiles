import QtQuick
import Quickshell
import Quickshell.Hyprland

import "../../services"
import "../../config"
import "../../utils"
import "../"

Item {
    id: root

    readonly property color backgroundColor: Config.isOled ? "#000" : Colors.background 
    readonly property color foregroundColor: Config.isOled ? "#fff" : Colors.on_background
    property var screen
    property var workspaceIds: HyprlandConfig.workspacesByMonitor[screen?.name ?? ""] ?? []

    Connections {
        target: HyprlandConfig
        function onWorkspacesByMonitorChanged() {
            const ids = HyprlandConfig.workspacesByMonitor[screen?.name ?? ""] ?? [];
            //console.log("[WorkSpaces] onWorkspacesByMonitorChanged for screen:", screen?.name, "-> ids:", JSON.stringify(ids));
            root.workspaceIds = ids;
        }
    }

    Component.onCompleted: {
        //console.log("Loaded component: [WorkSpaces] for screen:", screen?.name, "with workspaces:", workspaceIds)
    }

    height: parent.height
    implicitWidth: container.width

    Item {
        id: container
        width: workspaceRow.width + 8 + HyprlandConfig.radius
        height: parent.height

        Rectangle {
            x: 0
            y: 0
            width: workspaceRow.width + 8
            height: parent.height
            color: root.backgroundColor
            bottomRightRadius: HyprlandConfig.radius
        }

        InvertedCorner {
            corner: InvertedCorner.Corner.TopLeft
            cornerRadius: HyprlandConfig.radius
            cornerColor: root.backgroundColor
            x: workspaceRow.width + 8
            y: 0
        }

        Row {
            id: workspaceRow
            height: parent.height
            spacing: 1
            x: 4

            Repeater {
                model: root.workspaceIds

                Item {
                    width: 18
                    height: workspaceRow.height

                    property int workspaceId: modelData
                    property bool isActive: Hyprland.focusedWorkspace?.id === workspaceId
                    property bool hasWindowsValue: false

                    function updateHasWindows() {
                        const workspace = Hyprland.workspaces.values.find(ws => ws.id === workspaceId);
                        hasWindowsValue = workspace ? workspace.lastWindow !== null && workspace.lastWindow !== undefined : false;
                    }

                    Component.onCompleted: updateHasWindows()

                    Connections {
                        target: Hyprland.workspaces
                        function onValuesChanged() { updateHasWindows(); }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: {
                            if (parent.isActive) return "●";
                            if (parent.hasWindowsValue) return "◉";
                            return "○";
                        }
                        color: root.foregroundColor
                        font.pixelSize: 12
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Hyprland.dispatch(`workspace ${workspaceId}`)
                    }
                }
            }
        }
    }
}