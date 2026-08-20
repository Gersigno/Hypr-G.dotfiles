pragma Singleton

import QtQuick
import QtCore
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property string homePath: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0].toString().replace(/^file:\/\//, "")
    readonly property string configPath: homePath + "/.config/hypr/hypr-g/hyprland/env.lua"
    readonly property string toggleScript: homePath + "/.config/quickshell/scripts/toggle-theme.sh"

    property bool isDarkMode: true

    FileView {
        id: configFile
        path: root.configPath
        watchChanges: true

        function parseTheme(text) {
            if (!text) return;
            const match = text.match(/hl\.env\s*\(\s*["']THEME_MODE["']\s*,\s*["'](dark|light)["']\s*\)/);
            if (match && match[1]) {
                root.isDarkMode = (match[1] === "dark");
            }
        }

        onTextChanged: parseTheme(configFile.text())
        Component.onCompleted: parseTheme(configFile.text())
    }

    Process {
        id: toggler
        command: ["/bin/bash", root.toggleScript]
        /*stdout: StdioCollector {
            onStreamFinished: (text) => console.log("[Theme] stdout:", text)
        }
        onExited: (exitCode) => console.log("[Theme] toggle script exited with code:", exitCode)*/
    }

    function toggle() {
        isDarkMode = !isDarkMode;
        toggler.running = false;
        toggler.running = true;
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "configreloaded") {
                configFile.reload();
            }
        }
    }
}