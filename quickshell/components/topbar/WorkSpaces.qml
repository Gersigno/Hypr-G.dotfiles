import QtQuick
import Quickshell
import Quickshell.Hyprland

import "../../services"
import qs.services
import "../../utils"
import "../common/interface"

Item {
    id: root

    readonly property color backgroundColor: (Settings.isOled && Theme.isDarkMode) ? "#000" : Colors.background 
    readonly property color foregroundColor: Colors.on_background
    readonly property color primary: (Settings.isOled && Theme.isDarkMode) ? "#fff" : Colors.primary
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
        width: workspaceRow.width + 18 + HyprlandConfig.radius
        height: parent.height

        Rectangle {
            x: 0
            y: 0
            width: workspaceRow.width + 12 + osLogo.width
            height: parent.height
            color: root.backgroundColor
            bottomRightRadius: HyprlandConfig.radius
        }

        InvertedCorner {
            corner: InvertedCorner.Corner.TopLeft
            cornerRadius: HyprlandConfig.radius
            cornerColor: root.backgroundColor
            x: workspaceRow.width + 12 + osLogo.width
            y: 0
        }

        //OS logo
        Text {
            id: osLogo
            verticalAlignment: Text.AlignVCenter
            anchors {
                left: parent.left
                leftMargin: 4
                top: parent.top
                bottom: parent.bottom
            }
            color: root.primary
            text: SystemInfo.distroIcon
            font.pixelSize: 12
        }

        Row {
            id: workspaceRow
            height: parent.height
            spacing: 0
            x: 8 + osLogo.width

            Repeater {
                model: root.workspaceIds

                Item {
                    id: wsItem
                    width: itemWidth
                    height: workspaceRow.height

                    property int workspaceId: modelData
                    property var workspace: Hyprland.workspaces.values.find(ws => ws.id === workspaceId) ?? null
                    property bool isActive: Hyprland.focusedWorkspace?.id === workspaceId
                    property bool hasWindowsValue: workspace !== null && workspace.toplevels.values.length > 0
                    property int itemWidth: isActive ? 26 : 12

                    Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }

                    

                    /*Text {
                        anchors.centerIn: parent
                        text: {
                            if (parent.isActive) return "●";
                            if (parent.hasWindowsValue) return "◉";
                            return "○";
                        }
                        color: parent.isActive ? root.primary : root.foregroundColor
                        font.pixelSize: 12
                    }*/
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.isActive ? 20 : 8
                        height: 8
                        radius: 4
                        color: parent.isActive ? root.primary : (parent.hasWindowsValue ? root.foregroundColor : root.foregroundColor)
                        opacity: parent.isActive ? 1 : (parent.hasWindowsValue ? 1 : 0.3)

                        Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                        Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            Hyprland.dispatch('hl.dsp.focus({ workspace = "' + workspaceId + '" })')
                        }
                    }
                }
            }
        }
    }
}