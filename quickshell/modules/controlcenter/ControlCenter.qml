import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland

Item {
    id: root
    
    property bool controlCenterOpen: false
    property bool isAnimating: false
    readonly property int animationDuration: 450
    readonly property real defaultQsWidth: 50 
    readonly property real defaultQsHeight: 100
    
    property int topBarHeight: topBarComponent.barVisible ? topBarComponent.barHeight : 0
    property var qsQsObject: topBarComponent.quickSettingsRef 
    
    // target sizes
    readonly property int finalWidth: 340
    property real finalHeight: Hyprland.focusedMonitor?.height ?? 1080

    property real quickSettingsHeight: root.defaultQsHeight
    property real quickSettingsWidth: root.defaultQsWidth

    property var animationProgress: 0.0


    Binding {
        target: root
        property: "quickSettingsWidth"
        value: qsQsObject ? qsQsObject.renderedWidth : root.defaultQsWidth
        restoreMode: Binding.RestoreBindingOrValue
    }

    Binding {
        target: root
        property: "quickSettingsHeight"
        value: qsQsObject ? qsQsObject.renderedHeight : root.defaultQsHeight
        restoreMode: Binding.RestoreBindingOrValue
    }

    PanelWindow {
        id: controlCenterRoot
        
        visible: root.controlCenterOpen || root.isAnimating

        function hide() { root.controlCenterOpen = false }
        exclusiveZone: 0

        WlrLayershell.namespace: "quickshell:controlCenter"
        WlrLayershell.layer: (root.controlCenterOpen && controlCenterLayoutLoader.shouldBeOverlay) 
                     ? WlrLayer.Overlay 
                     : WlrLayer.Top
        color: "transparent"
        
        margins { top: (topBarHeight * -1) }
        
        implicitWidth: root.finalWidth
        implicitHeight: root.finalHeight 
        
        anchors { 
            top: true; 
            right: true; 
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
            id: controlCenterLayoutLoader

            width: root.quickSettingsWidth
            height: root.quickSettingsHeight
            
            active: true
            //onItemChanged: { root.controlCenterContentRef = controlCenterLayoutLoader.item }

            Connections {
                target: controlCenterLayoutLoader.item
                ignoreUnknownSignals: true 
                
                function onAnimProgressChanged() {
                    root.animationProgress = controlCenterLayoutLoader.item.animProgress;
                }
            }

            onStateChanged: {
                if (state === "Closed") {
                    root.isAnimating = true;
                    // On laisse le temps à l'animation de se jouer avant de couper la visibilité
                    closeTimer.restart();
                } else {
                    root.isAnimating = false;
                    closeTimer.stop();
                }
            }
            
            onActiveChanged: {
                if (active) {
                    //console.log(`DEBUG: E-03 Loader ACTIVATED. Target Width: ${width} Target Height: ${height}`);
                    //console.log(`DEBUG: E-03 Current quickSettingsWidth: ${root.quickSettingsWidth}`);
                }

                //console.log("============================")
                //console.log("state: ", controlCenterLayoutLoader.item.animProgress)
                //console.log("============================")
            }
            
            anchors { top: parent.top; right: parent.right }
            
            // --- NOUVELLE LOGIQUE D'ÉTAT ET DE TRANSITION ---
            
            // L'état du Loader suit l'état d'ouverture/fermeture
            state: root.controlCenterOpen ? "Opened" : "Closed"

            // Définition des propriétés de chaque état
            states: [
                State { name: "Closed" },
                State {
                    name: "Opened"
                    PropertyChanges { target: controlCenterLayoutLoader; width: root.finalWidth; height: root.finalHeight }
                }
            ]
            
            transitions: [
                Transition {
                    from: "Closed"; to: "Opened"
                    ParallelAnimation {
                        NumberAnimation { 
                            properties: "width,height"; 
                            duration: root.animationDuration; 
                            easing.type: Easing.InOutQuint 
                        }
                        NumberAnimation { 
                            target: controlCenterLayoutLoader.item; 
                            property: "animProgress"; 
                            to: 100; 
                            duration: root.animationDuration; 
                            easing.type: Easing.InOutQuint;
                        }
                    }
                },
                Transition {
                    from: "Opened"; to: "Closed"
                    ParallelAnimation {
                        NumberAnimation { 
                            target: controlCenterLayoutLoader
                            properties: "width"; 
                            to: root.quickSettingsWidth; 
                            duration: root.animationDuration; 
                            easing.type: Easing.InOutQuint 
                        }
                        NumberAnimation { 
                            target: controlCenterLayoutLoader
                            properties: "height"; 
                            to: root.quickSettingsHeight; 
                            duration: root.animationDuration; 
                            easing.type: Easing.InOutQuint 
                        }
                        NumberAnimation {
                            target: controlCenterLayoutLoader.item
                            property: "animProgress"; 
                            to: 0; 
                            duration: root.animationDuration; 
                            easing.type: Easing.InOutQuint
                        }
                    }
                }
            ]
            
            // --- FIN NOUVELLE LOGIQUE ---
            
            // Les propriétés width/height sont maintenant définies dans les states, donc on les retire des bindings

            focus: root.controlCenterOpen
            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape) {
                    controlCenterRoot.hide();
                }
            }

            sourceComponent: ControlCenterLayout {
                id: controlCenterLayout
                Component.onCompleted: { 
                    //console.log("DEBUG: ControlCenterLayout loaded"); 
                }
            }
        }
        Timer {
            id: closeTimer
            interval: root.animationDuration
            onTriggered: root.isAnimating = false
        }
    }

    // --- IPC et Raccourcis Globaux ---
    IpcHandler { target: "controlCenter"; function toggle(): void { root.controlCenterOpen = !root.controlCenterOpen; }
        function close(): void { root.controlCenterOpen = false; }
        function open(): void { root.controlCenterOpen = true; } }

    GlobalShortcut { name: "controlCenterToggle"; description: "Toggles control center on press"; onPressed: { root.controlCenterOpen = !root.controlCenterOpen; } }
    GlobalShortcut { name: "controlCenterOpen"; description: "Opens control center on press"; onPressed: { root.controlCenterOpen = true; } }
    GlobalShortcut { name: "controlCenterClose"; description: "Closes control center on press"; onPressed: { root.controlCenterOpen = false; } }
}