pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import qs.services

/**
 * Privacy service: detects active microphone, camera and screen-capture usage.
 *
 * This implementation does not require Python. It only uses standard system
 * tools that ship with PipeWire and psmisc (or similar):
 *   - pw-dump  : enumerates PipeWire nodes and links
 *   - fuser    : finds processes holding /dev/video* devices
 *
 * If either tool is missing the corresponding detection gracefully degrades.
 */
Singleton {
    id: root

    // ── Public state ───────────────────────────────────────────────────────
    property bool microphoneActive: false
    property bool cameraActive: false
    property bool screenActive: false

    property var microphoneApps: []
    property var cameraApps: []
    property var screenApps: []

    property bool ready: false

    // Polling interval in milliseconds.
    property int interval: 1000

    // ── Helpers ────────────────────────────────────────────────────────────
    function lower(str) {
        return (str ?? "").toString().toLowerCase();
    }

    function containsAny(str, keywords) {
        const s = lower(str);
        return keywords.some(k => s.includes(k));
    }

    function appName(props) {
        return props["application.name"]
            || props["application.process.binary"]
            || props["node.name"]
            || props["application.process.name"]
            || "unknown";
    }

    readonly property var ignoredMicNames: [
        "pipewire", "pulseaudio", "easyeffects", "pavucontrol",
        "pw-loopback", "alsa-source", "alsa-sink", "libcanberra"
    ]

    function isIgnoredMic(name) {
        const n = lower(name);
        return root.ignoredMicNames.some(ign => n.includes(ign));
    }

    function isCameraDevice(props) {
        const mediaClass = lower(props["media.class"] ?? "");
        if (!mediaClass.includes("video")) return false;

        const nodeName = lower(props["node.name"] ?? "");
        if (nodeName.includes("xdg-desktop-portal")) return false;

        if (containsAny(nodeName, ["camera", "v4l2", "webcam", "video4linux"])) return true;
        if (containsAny(props["device.name"], ["v4l"])) return true;
        if (containsAny(props["media.name"], ["camera", "webcam"])) return true;

        return false;
    }

    function isScreenCaptureSource(props) {
        const mediaClass = lower(props["media.class"] ?? "");
        if (!mediaClass.includes("video")) return false;

        const portalMonitor = lower(props["portal.monitor"] ?? "");
        if (containsAny(portalMonitor, ["screen", "monitor", "window", "display"])) return true;

        const nodeName = lower(props["node.name"] ?? "");
        const mediaName = lower(props["media.name"] ?? "");

        // xdg-desktop-portal-hyprland screen capture streams.
        if (nodeName.includes("xdg-desktop-portal") && mediaName.startsWith("xdph-streaming"))
            return true;

        if (containsAny(nodeName, ["screencast", "desktop", "screen"])) return true;
        if (containsAny(mediaName, ["screencast", "desktop", "screen"])) return true;

        if (nodeName.includes("pipewiresrc") && !containsAny(nodeName, ["camera", "webcam", "v4l2"]))
            return true;

        return false;
    }

    // ── PipeWire parsing ───────────────────────────────────────────────────
    function updateFromPwDump(jsonText) {
        let nodes = [];
        try {
            nodes = JSON.parse(jsonText);
        } catch (e) {
            console.warn("[Privacy] Failed to parse pw-dump output:", e);
            return;
        }

        const nodeProps = {};
        const linksToOutput = {};

        for (const item of nodes) {
            const objId = item.id;
            const objType = item.type;

            if (objType === "PipeWire:Interface:Node") {
                const info = item.info ?? {};
                nodeProps[objId] = info.props ?? {};
            } else if (objType === "PipeWire:Interface:Link") {
                const info = item.info ?? {};
                const state = lower(info.state ?? "");
                if (state !== "active") continue;
                const inputId = info["input-node-id"];
                const outputId = info["output-node-id"];
                if (inputId && outputId) {
                    if (!linksToOutput[inputId]) linksToOutput[inputId] = new Set();
                    linksToOutput[inputId].add(outputId);
                }
            }
        }

        const micApps = new Set();
        const screenApps = new Set();
        const camApps = new Set(root._cameraAppsFromV4l2);

        const linkBased = []; // { app, outputIds }

        for (const item of nodes) {
            if (item.type !== "PipeWire:Interface:Node") continue;

            const info = item.info ?? {};
            const props = info.props ?? {};
            const mediaClass = lower(props["media.class"] ?? "");
            const state = lower(info.state ?? "");

            if (state !== "running" && state !== "idle") continue;

            if (mediaClass === "stream/input/audio") {
                const name = appName(props);
                if (name && !isIgnoredMic(name)) micApps.add(name);
                continue;
            }

            if (mediaClass === "stream/input/video") {
                const name = appName(props);
                const nodeId = item.id;
                const portalMonitor = lower(props["portal.monitor"] ?? "");

                if (portalMonitor.includes("camera")) {
                    camApps.add(name);
                    continue;
                }
                if (containsAny(portalMonitor, ["screen", "monitor", "window", "display"])) {
                    screenApps.add(name);
                    continue;
                }

                const outputIds = linksToOutput[nodeId] ?? new Set();
                if (outputIds.size > 0) {
                    linkBased.push({ app: name, outputIds: Array.from(outputIds) });
                    continue;
                }

                const nodeName = lower(props["node.name"] ?? "");
                if (containsAny(nodeName, ["camera", "v4l2", "webcam", "video4linux"])) {
                    camApps.add(name);
                } else if (containsAny(nodeName, ["monitor", "capture", "screencast", "desktop"])) {
                    screenApps.add(name);
                } else {
                    screenApps.add(name);
                }
            }
        }

        for (const item of linkBased) {
            const name = item.app;
            const nameLower = lower(name);
            let camera = false;
            let screen = false;

            for (const outId of item.outputIds) {
                const outProps = nodeProps[outId] ?? {};
                if (isCameraDevice(outProps)) {
                    camera = true;
                    break;
                }
                if (isScreenCaptureSource(outProps)) {
                    screen = true;
                }
            }

            if (camera) {
                camApps.add(name);
            } else if (screen) {
                screenApps.add(name);
            } else {
                camApps.add(name);
            }
        }

        root.microphoneActive = micApps.size > 0;
        root.cameraActive     = camApps.size > 0;
        root.screenActive     = screenApps.size > 0;
        root.microphoneApps   = Array.from(micApps).sort((a, b) => a.localeCompare(b, undefined, { sensitivity: "base" }));
        root.cameraApps       = Array.from(camApps).sort((a, b) => a.localeCompare(b, undefined, { sensitivity: "base" }));
        root.screenApps       = Array.from(screenApps).sort((a, b) => a.localeCompare(b, undefined, { sensitivity: "base" }));
        root.ready = true;
    }

    // Camera users found by scanning /dev/video*.
    property var _cameraAppsFromV4l2: []

    function updateV4l2Apps(text) {
        const apps = new Set();
        const lines = text.trim().split("\n");
        // fuser -v output: header line then USER PID ACCESS COMMAND
        for (let i = 1; i < lines.length; i++) {
            const parts = lines[i].trim().split(/\s+/);
            if (parts.length < 2) continue;
            const pid = parseInt(parts[1]);
            if (!isFinite(pid)) continue;
            const comm = parts[parts.length - 1];
            if (comm) apps.add(comm);
        }
        root._cameraAppsFromV4l2 = Array.from(apps);
    }

    // ── Polling ────────────────────────────────────────────────────────────
    Timer {
        id: pollTimer
        interval: root.interval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            pwDumpProcess.running = true;
            v4l2Process.running = true;
        }
    }

    Process {
        id: pwDumpProcess
        command: ["pw-dump", "-N"]
        stdout: StdioCollector {
            onStreamFinished: root.updateFromPwDump(text)
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                console.warn("[Privacy] pw-dump exited with code", exitCode);
            }
        }
    }

    Process {
        id: v4l2Process
        command: ["/bin/sh", "-c", "for dev in /dev/video*; do [ -c \"$dev\" ] && fuser -v \"$dev\" 2>&1; done"]
        stdout: StdioCollector {
            onStreamFinished: root.updateV4l2Apps(text)
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                // fuser may not be installed; camera detection falls back to PipeWire only.
                root._cameraAppsFromV4l2 = [];
            }
        }
    }

    Component.onCompleted: {
        console.info("Loaded component: [Privacy]");
    }
}
