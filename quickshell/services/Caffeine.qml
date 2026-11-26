pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool enabled: false

    // Whether the saved state has been restored yet
    property bool _stateRestored: false

    function toggle() {
        root.enabled = !root.enabled;
    }

    onEnabledChanged: {
        if (_stateRestored)
            Settings.caffeineEnabled = enabled;
    }

    // Restore the saved state once settings are available
    function restoreSavedState() {
        if (_stateRestored || !Settings.ready)
            return;
        _stateRestored = true;
        root.enabled = Settings.caffeineEnabled;
    }

    Component.onCompleted: restoreSavedState()

    Connections {
        target: Settings
        function onReadyChanged() { root.restoreSavedState() }
    }

    Process {
        id: inhibitProc
        running: root.enabled
        command: ["systemd-inhibit", "--what=idle:sleep", "--why=Caffeine mode enabled", "--mode=block", "sleep", "infinity"]
    }
}
