import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import "../.."

Item {
    id: root
    
    property int barHeight: 24
    property bool barVisible: true
    property bool clockExpanded: false

    // Auto-hide bar when any window goes fullscreen
    property bool wasVisibleBeforeFullscreen: true

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "fullscreen") {
                const isFs = parseInt(event.data) !== 0;
                console.log("[TopBar] fullscreen event:", event.data, "->", isFs);
                if (isFs) {
                    root.wasVisibleBeforeFullscreen = root.barVisible;
                    root.barVisible = false;
                } else {
                    root.barVisible = root.wasVisibleBeforeFullscreen;
                }
            }
        }
    }

    // Property expose references
    property var quickSettingsRef: null
    
    onClockExpandedChanged: {
        //console.log("[TopBar] root.clockExpanded changed to:", clockExpanded)
    }
    
    Component.onCompleted: {
        console.log("[TopBar] Component loaded")
        //console.log("[TopBar] Initial clockExpanded state:", root.clockExpanded)
    }


    
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            property var modelData
            property int panelHeight: root.barHeight
            property real animatedExclusiveZone: root.barVisible ? panelHeight : 0
            //property real slideY: root.barVisible ? 0 : -panelHeight
            screen: modelData
            
            visible: true
            color: "transparent"
            
            WlrLayershell.namespace: "quickshell:topBar"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusiveZone: Math.round(animatedExclusiveZone)
            
            implicitHeight: panelHeight
            
            Behavior on animatedExclusiveZone {
                NumberAnimation {
                    duration: 0
                    easing.type: Easing.Bezier
                    easing.bezierCurve: [0.18, 0.95, 0.2, 1.08]
                }
            }
            
            /*Behavior on slideY {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.Bezier
                    easing.bezierCurve: [0.18, 0.95, 0.2, 1.08]
                }
            }*/
            
            anchors {
                top: true
                left: true
                right: true 
            }
            
            //clip: true
            
            Item {
                id: contentContainer
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: animatedExclusiveZone - panelHeight
                height: panelHeight
                opacity: 1.0
                
            Workspaces {
                id: workspaces
                screen: modelData
                anchors {
                    left: parent.left
                    top: parent.top
                }
                height: panelHeight
            }

            Rectangle {
                color: "transparent"
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                }
            }
            
            Clock {
                id: clock
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                }
                height: panelHeight
                width: implicitWidth
                z: 10
                
                Component.onCompleted: {
                    //console.log("[TopBar Clock] Width after layout:", width, "Height:", height)
                }
                
                onExpandedChanged: {
                    //console.log("[Clock] expanded changed to:", expanded)
                    root.clockExpanded = expanded
                }
            }
            
            Connections {
                target: clockExpanded
                function onExpandedChanged() {
                    //console.log("[TopBar] ClockExpanded.onExpandedChanged signal received, clockExpanded.expanded:", clockExpanded.expanded)
                    clock.expanded = clockExpanded.expanded
                }
            }
            
            ActiveWindowTitle {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    leftMargin: workspaces.width
                    rightMargin: 8
                }
                height: panelHeight
                
                Component.onCompleted: {
                    //console.log("[ActiveWindowTitle] Width:", width, "X position:", x, "LeftMargin:", Math.max(workspaces.width + 8, clock.width / 2 + 60))
                }
            }

            TrayIcons {
                id: trayIcons

                Component.onCompleted: {
                    //var offset = controlCenterComponent.controlCenterContentRef;
                    //console.log("############ ControlCenterContent: ", offset);
                }

                anchors {
                    right: parent.right
                    top: parent.top
                    rightMargin : (quicksettings.width + 8)
                    //rightMargin: controlCenterComponent.controlCenterContentRef ? (controlCenterComponent.controlCenterContentRef.width + 8) : (quicksettings.width + 8)
                }
                height: panelHeight
            }

            QuickSettings {
                id: quicksettings
                anchors {
                    right: parent.right
                    top: parent.top
                }
                height: panelHeight

                Component.onCompleted: {
                    root.quickSettingsRef = quicksettings
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("QuickSettings clicked, toggling ControlCenter");
                        controlCenterComponent.controlCenterOpen = true;
                    }
                }
            }
            }  // Fin de contentContainer
        }
    }

    // Clock panel (floating)
    ClockExpanded {
        id: clockExpanded
        expanded: root.clockExpanded
        topBarHeight: root.barHeight
        
        Component.onCompleted: {
            //console.log("[ClockExpanded] Component completed")
        }

        onExpandedChanged: {
            //console.log("[ClockExpanded from TopBar] onExpandedChanged fired, expanded is now:", expanded)
            root.clockExpanded = expanded
        }
    }
    
    GlobalShortcut {
        name: "topBarToggle"
        description: "Toggles top bar on press"
        
        onPressed: {
            root.barVisible = !root.barVisible;
        }
    }
}
