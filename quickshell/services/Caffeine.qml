pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool enabled: false

    function toggle() {
        root.enabled = !root.enabled;
    }

    Process {
        id: inhibitProc
        running: root.enabled
        command: ["systemd-inhibit", "--what=idle:sleep", "--why=Caffeine mode enabled", "--mode=block", "sleep", "infinity"]
    }
}
