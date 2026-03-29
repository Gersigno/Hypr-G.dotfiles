pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Hyprland decoration:rounding
    property int radius: 0
    // Hyprland general:gaps_out (premier côté)
    property int gapsOut: 0
    // Rayon effectif pour les screen corners
    property int radiusFull: radius + gapsOut

    // { "eDP-1": [1,2,3,4], "HDMI-A-1": [5,6,7,8], ... }
    property var workspacesByMonitor: ({})

    function workspacesForScreen(screenName) {
        return workspacesByMonitor[screenName] ?? [];
    }

    // --- Loaders ---

    Process {
        command: ["hyprctl", "getoption", "decoration:rounding", "-j"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.radius = JSON.parse(text).int;
            }
        }
    }

    Process {
        command: ["hyprctl", "getoption", "general:gaps_out", "-j"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const data = JSON.parse(text);
                const raw = data.custom !== undefined ? data.custom : String(data.int);
                root.gapsOut = parseInt(raw.trim().split(/\s+/)[0]);
            }
        }
    }

    Process {
        command: ["hyprctl", "workspacerules"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                //console.log("[HyprlandConfig] workspacerules raw output:\n" + text);
                const result = {};
                const allBlocks = text.split(/Workspace rule (\d+):\n/);
                //console.log("[HyprlandConfig] allBlocks count:", allBlocks.length);
                for (let i = 1; i < allBlocks.length; i += 2) {
                    const wsId = parseInt(allBlocks[i]);
                    const body = allBlocks[i + 1] ?? "";
                    const monitorMatch = body.match(/\tmonitor:\s*(\S+)/);
                    if (!monitorMatch) {
                        //console.log("[HyprlandConfig] no monitor match for ws", wsId, "body:", body);
                        continue;
                    }
                    const monitor = monitorMatch[1];
                    if (!result[monitor]) result[monitor] = [];
                    result[monitor].push(wsId);
                }
                //console.log("[HyprlandConfig] parsed workspacesByMonitor:", JSON.stringify(result));
                root.workspacesByMonitor = result;
            }
        }
    }
}
