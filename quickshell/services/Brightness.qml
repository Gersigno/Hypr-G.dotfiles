pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real value: 0.0
    property bool ready: false

    function setBrightness(newValue) {
        newValue = Math.max(0.01, Math.min(1.0, newValue));
        root.value = newValue;
        
        const percent = Math.round(newValue * 100);
        setProc.command = ["brightnessctl", "s", percent + "%", "-q"];
        setProc.running = false;
        setProc.running = true;
    }

    Process {
        id: updateProc
        command: ["brightnessctl", "-m"]
        running: false
        stdout: SplitParser {
            onRead: (data) => {
                const parts = data.split(",");
                if (parts.length >= 4) {
                    let currentVal = parseFloat(parts[3].replace("%", "")) / 100;
                    if (Math.abs(root.value - currentVal) > 0.01) {
                        root.value = currentVal;
                    }
                    root.ready = true;
                }
            }
        }
    }

    Timer {
        interval: 500 //! Ugly methode, have to find a better way to listen to brightness changes
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            updateProc.running = false;
            updateProc.running = true;
        }
    }

    Process {
        id: setProc
        running: false
    }
}