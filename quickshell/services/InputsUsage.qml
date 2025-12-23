pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io

Singleton {
    id: root

    // Traduction de l'état Pipewire en texte pour le debug
    function stateToString(state) {
        switch (state) {
            case PwNode.Suspended: return "Suspended (Inactif)";
            case PwNode.Idle:      return "Idle (En attente)";
            case PwNode.Running:   return "Running (ACTIF/ENREGISTRE)";
            case PwNode.Error:     return "Error";
            default:               return "Unknown (" + state + ")";
        }
    }

    function correctType(node, isSink) {
        return (node.isSink === isSink) && node.audio
    }

    // Liste de TOUS les flux micro (pour le debug complet)
    readonly property var allMicNodes: {
        if (!Pipewire.nodes) return []
        return Pipewire.nodes.values.filter(node => root.correctType(node, false) && node.isStream)
    }

    // Propriété qui ne filtre que les flux réellement en train de tourner
    readonly property var runningMicNodes: allMicNodes.filter(node => node.state === PwNode.Running)

    // Log de debug amélioré
    onAllMicNodesChanged: {
        if (allMicNodes.length > 0) {
            console.log("--- Debug Micro State ---")
            allMicNodes.forEach(node => {
                console.log(`> Process: ${root.appNodeDisplayName(node)} | State: ${root.stateToString(node.state)}`)
            })
        }
    }

    function appNodeDisplayName(node) {
        return (node.properties["application.name"] || node.description || node.name)
    }

    // On base micInUse uniquement sur les flux "Running"
    property bool micInUse: runningMicNodes.length > 0
    property string micProcess: micInUse ? root.appNodeDisplayName(runningMicNodes[0]) : ""
    
    property bool cameraInUse: false

    Process {
        id: cameraCheck
        command: ["lsof", "/dev/video0"]
        running: false
        onExited: function(exitCode, exitStatus) {
            root.cameraInUse = (exitCode == 0);
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: cameraCheck.running = true
    }
}