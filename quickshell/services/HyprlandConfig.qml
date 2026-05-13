pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    //Hyprland decoration:rounding
    property int radius: 0
    //Hyprland general:gaps_out
    property int gapsOut: 0
    property int radiusFull: radius + gapsOut
    //Hyprland window opacity:active
    property real activeOpacity: 1.0
    property real inactiveOpacity: 0.8

    //Hyprland decoration:shadow
    property int shadowRange: 16
    property int shadowRenderPower: 2
    //property color shadowColor: Qt.rgba(0, 0, 0, 0.46)

    function argbIntToColor(value) {
        const u = value >>> 0;
        const a = ((u >>> 24) & 0xFF) / 255;
        const r = ((u >>> 16) & 0xFF) / 255;
        const g = ((u >>>  8) & 0xFF) / 255;
        const b = ( u         & 0xFF) / 255;
        return Qt.rgba(r, g, b, a);
    }

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
                let raw;
                if (data.css !== undefined)
                    raw = data.css;
                else if (data.custom !== undefined)
                    raw = data.custom;
                else
                    raw = String(data.int);
                root.gapsOut = parseInt(raw.trim().split(/\s+/)[0]);
            }
        }
    }

    Process {
        command: ["hyprctl", "getoption", "decoration:active_opacity", "-j"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.activeOpacity = JSON.parse(text).float;
            }
        }
    }

    Process {
        command: ["hyprctl", "getoption", "decoration:inactive_opacity", "-j"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.inactiveOpacity = JSON.parse(text).float;
            }
        }
    }

    Process {
        command: ["hyprctl", "getoption", "decoration:shadow:range", "-j"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.shadowRange = JSON.parse(text).int;
            }
        }
    }

    Process {
        command: ["hyprctl", "getoption", "decoration:shadow:render_power", "-j"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.shadowRenderPower = JSON.parse(text).int;
            }
        }
    }

    /*Process {
        command: ["hyprctl", "getoption", "decoration:shadow:color", "-j"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.shadowColor = root.argbIntToColor(JSON.parse(text).int);
            }
        }
    }*/

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
