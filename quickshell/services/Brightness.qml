pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    /*property real value: 0.0
    property bool ready: false

    // Cette fonction reproduit le comportement de end4 :
    // Elle met à jour la propriété interne ET lance la commande système.
    function setBrightness(newValue) {
        newValue = Math.max(0.01, Math.min(1.0, newValue)); // Sécurité 1% min
        root.value = newValue;
        
        const percent = Math.round(newValue * 100);
        setProc.command = ["brightnessctl", "s", percent + "%", "-q"];
        setProc.running = false;
        setProc.running = true;
    }

    // Initialisation : on lit la valeur RÉELLE au démarrage
    Process {
        id: initProc
        command: ["brightnessctl", "-m"]
        running: true
        stdout: SplitParser {
            onRead: (data) => {
                const parts = data.split(",");
                if (parts.length >= 4) {
                    root.value = parseFloat(parts[3].replace("%", "")) / 100;
                    root.ready = true;
                }
            }
        }
    }

    Process {
        id: setProc
        running: false
    }

    // Raccourcis globaux (Comme dans le code de end4)
    // Cela permet au service de mettre à jour le slider du Control Center 
    // instantanément quand tu utilises ton clavier.
    GlobalShortcut {
        name: "brightnessIncrease"
        onPressed: root.setBrightness(root.value + 0.05)
    }

    GlobalShortcut {
        name: "brightnessDecrease"
        onPressed: root.setBrightness(root.value - 0.05)
    }*/
}