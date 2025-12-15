import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland

Scope {
    id: root
    
    // --- Configuration et États ---
    property bool controlCenterOpen: false
    readonly property int animationDuration: 250
    
    // Valeurs par défaut
    readonly property real defaultQsWidth: 50 
    readonly property real defaultQsHeight: 100
    
    // --- Références TopBar/QuickSettings ---
    property int topBarHeight: topBarComponent.barVisible ? topBarComponent.barHeight : 0
    property var qsQsObject: topBarComponent.quickSettingsRef 
    
    // --- Propriétés de Taille ---
    
    readonly property int finalWidth: 340
    
    // Hauteur de l'écran (Corrigé précédemment)
    readonly property real finalHeight: Quickshell.screens.length > 0 ? Quickshell.screens[0].height : 1080 

    // Initialisation aux valeurs lues ou par défaut
    property real quickSettingsHeight: root.defaultQsHeight
    property real quickSettingsWidth: root.defaultQsWidth

    // Gère l'initialisation asynchrone des tailles
    onQsQsObjectChanged: {
        if (qsQsObject) {
            root.quickSettingsWidth = qsQsObject.renderedWidth
            root.quickSettingsHeight = qsQsObject.renderedHeight
            
            console.log("DEBUG: E-02 QuickSettings object LINKED. Final Width (read from QS):", root.quickSettingsWidth);
        } else {
            console.log("DEBUG: E-02 QuickSettings object UNLINKED (null/undefined).");
        }
    }

    Component.onCompleted: {
        console.log("--- DEBUG INITIALISATION COMPLETE ---");
        console.log("DEBUG: E-01 ControlCenter ROOT Component loaded.");
        console.log("DEBUG: E-01 PanelWindow Anchor Height (100px issue):", controlCenterRoot.height);
        console.log("DEBUG: E-01 Final Height (Screen Target):", finalHeight);
        console.log("DEBUG: E-01 QuickSettings initial Width (source):", quickSettingsWidth);
        console.log("-----------------------------------");
    }

    PanelWindow {
        id: controlCenterRoot
        
        visible: root.controlCenterOpen
        
        function hide() { root.controlCenterOpen = false }
        exclusiveZone: 0

        WlrLayershell.namespace: "quickshell:controlCenter"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: 0
        color: "transparent"
        
        margins { top: (topBarHeight * -1) }
        
        // CORRECTION DE LA LARGEUR TEMPORAIRE: Maintenue pour forcer le PanelWindow à la taille finale
        implicitWidth: root.finalWidth
        implicitHeight: root.finalHeight 
        
        anchors { top: true; right: true; bottom: true }

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
            
            onActiveChanged: {
                if (active) {
                    console.log(`DEBUG: E-03 Loader ACTIVATED. Target Width: ${width} Target Height: ${height}`);
                    console.log(`DEBUG: E-03 Current quickSettingsWidth: ${root.quickSettingsWidth}`);
                }
            }
            
            anchors { top: parent.top; right: parent.right }
            
            // --- NOUVELLE LOGIQUE D'ÉTAT ET DE TRANSITION ---
            
            // L'état du Loader suit l'état d'ouverture/fermeture
            state: root.controlCenterOpen ? "Opened" : "Closed"

            // Définition des propriétés de chaque état
            states: [
                State {
                    name: "Closed"
                    // On définit animProgress à 0 quand c'est fermé
                    PropertyChanges { 
                        target: controlCenterContentLoader.item
                        animProgress: 0 
                    }
                    PropertyChanges { 
                        target: controlCenterContentLoader
                        width: root.quickSettingsWidth
                        height: root.quickSettingsHeight 
                    }
                },
                State {
                    name: "Opened"
                    // On définit animProgress à 100 quand c'est ouvert
                    PropertyChanges { 
                        target: controlCenterContentLoader.item
                        animProgress: 100 
                    }
                    PropertyChanges { 
                        target: controlCenterContentLoader
                        width: root.finalWidth
                        height: root.finalHeight 
                    }
                }
            ]
            
            // Définition des animations entre les états
            transitions: [
                Transition {
                    from: "Closed"; to: "Opened"
                    // On anime width, height ET animProgress
                    NumberAnimation { 
                        properties: "width,height,animProgress" 
                        duration: root.animationDuration 
                        easing.type: Easing.InOutQuad
                        //easing.type: Easing.Bezier 
                        //easing.bezierCurve: [0.18, 0.95, 0.2, 1.08] 
                    }
                },
                Transition {
                    from: "Opened"; to: "Closed"
                    // Snap-back instantané (ou tu peux ajouter une durée si tu veux)
                    NumberAnimation { 
                        properties: "width,height,animProgress" 
                        duration: 0 
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

            sourceComponent: ControlCenterContent {
                id: controlCenterContent
                Component.onCompleted: { console.log("DEBUG: ControlCenterContent loaded"); }
            }
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