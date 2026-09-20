pragma Singleton

import QtQuick
import QtCore as Core
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string homePath: Core.StandardPaths.standardLocations(Core.StandardPaths.HomeLocation)[0].toString().replace(/^file:\/\//, "")
    readonly property string toggleScript: homePath + "/.config/quickshell/scripts/toggle-theme.sh"

    // Theme mode is stored in settings.json (gitignored) via the Settings service
    readonly property bool isDarkMode: Settings.isDarkMode

    Process {
        id: toggler
        command: ["/bin/bash", root.toggleScript]
    }

    function toggle() {
        Settings.isDarkMode = !Settings.isDarkMode;
        toggler.command = ["/bin/bash", root.toggleScript, Settings.isDarkMode ? "dark" : "light"];
        toggler.running = false;
        toggler.running = true;
    }
}
