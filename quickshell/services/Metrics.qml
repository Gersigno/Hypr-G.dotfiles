pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ── Configuration ──────────────────────────────────────────────────────
    property int interval: 1000        // sampling period (ms)
    property int historyLength: 60     // samples kept for the graphs
    property bool active: true         // pause the polling when false

    // ── CPU ────────────────────────────────────────────────────────────────
    property real cpuUsage: 0          // 0..1
    property var cpuHistory: []
    property real cpuFrequency: 0      // MHz
    property string cpuModel: ""
    property int cpuCores: 0
    property int cpuThreads: 0

    // ── Memory (bytes) ─────────────────────────────────────────────────────
    property real memTotal: 0
    property real memUsed: 0
    property real memAvailable: 0
    property real memPercent: 0
    property var memHistory: []
    property real swapTotal: 0
    property real swapUsed: 0
    property real swapPercent: 0

    // ── GPU ────────────────────────────────────────────────────────────────
    property bool gpuAvailable: false
    property real gpuUsage: 0          // 0..1
    property var gpuHistory: []
    property real gpuVramUsed: 0
    property real gpuVramTotal: 0
    property real gpuTemp: -1          // °C
    property real gpuFan: -1           // RPM

    // ── Temperatures ───────────────────────────────────────────────────────
    // Raw: [{ hwmon, name, label, value, crit }]
    property var temperatures: []
    // One entry per sensor chip: [{ id, name, label, value, crit, percent }]
    property var temperatureSummary: []

    // ── Network (bytes/s) ──────────────────────────────────────────────────
    property real netRxRate: 0
    property real netTxRate: 0
    property real netRxTotal: 0
    property real netTxTotal: 0
    property var netRxHistory: []
    property var netTxHistory: []
    property string netInterface: ""

    // ── Storage ────────────────────────────────────────────────────────────
    property real diskUsed: 0
    property real diskTotal: 0
    property real diskPercent: 0

    // ── System ─────────────────────────────────────────────────────────────
    property string hostname: ""
    property string kernel: ""
    property real uptime: 0            // seconds
    property real load1: 0
    property real load5: 0
    property real load15: 0

    // ── Internal state ─────────────────────────────────────────────────────
    property real _prevCpuTotal: -1
    property real _prevCpuIdle: -1
    property real _prevNetRx: -1
    property real _prevNetTx: -1
    property double _prevNetTime: 0
    property var _tempBuffer: []

    readonly property var _deviceNames: ({
        "k10temp": "CPU",
        "zenpower": "CPU",
        "coretemp": "CPU",
        "amdgpu": "GPU",
        "nouveau": "GPU",
        "nvidia": "GPU",
        "nvme": "NVMe",
        "iwlwifi_1": "WiFi",
        "acpitz": "System",
        "gigabyte_wmi": "Motherboard",
        "pch": "Chipset"
    })

    readonly property var _preferredLabels: ({
        "k10temp": ["Tctl", "Tccd1", ""],
        "zenpower": ["Tdie", "Tctl", ""],
        "coretemp": ["Package id 0", "Core 0", ""],
        "amdgpu": ["edge", "junction", ""],
        "nvme": ["Composite", "Sensor 1", ""]
    })

    readonly property var _blocklist: ["acpitz", "hidpp_battery_0"]

    readonly property var _devicePriority: ({
        "k10temp": 0,
        "zenpower": 0,
        "coretemp": 0,
        "amdgpu": 1,
        "nouveau": 1,
        "nvidia": 1,
        "nvme": 2,
        "iwlwifi_1": 3
    })

    // ── Formatting helpers ─────────────────────────────────────────────────
    function formatBytes(bytes, decimals) {
        if (!isFinite(bytes) || bytes <= 0)
            return "0 B";
        const units = ["B", "KB", "MB", "GB", "TB", "PB"];
        const i = Math.min(units.length - 1, Math.floor(Math.log(bytes) / Math.log(1024)));
        const value = bytes / Math.pow(1024, i);
        const d = (decimals === undefined) ? (i >= 3 ? 1 : 0) : decimals;
        return value.toFixed(d) + " " + units[i];
    }

    function formatRate(bytesPerSecond) {
        return formatBytes(bytesPerSecond, 1) + "/s";
    }

    function formatFrequency(mhz) {
        if (!isFinite(mhz) || mhz <= 0)
            return "--";
        if (mhz >= 1000)
            return (mhz / 1000).toFixed(2) + " GHz";
        return Math.round(mhz) + " MHz";
    }

    function formatUptime(seconds) {
        const s = Math.max(0, Math.floor(seconds));
        const days = Math.floor(s / 86400);
        const hours = Math.floor((s % 86400) / 3600);
        const minutes = Math.floor((s % 3600) / 60);
        if (days > 0)
            return days + "d " + hours + "h";
        if (hours > 0)
            return hours + "h " + String(minutes).padStart(2, "0") + "m";
        return minutes + "m";
    }

    // ── History helper ─────────────────────────────────────────────────────
    function _push(history, value) {
        const out = history.slice();
        out.push(value);
        if (out.length > root.historyLength)
            out.splice(0, out.length - root.historyLength);
        return out;
    }

    // ── Polling ────────────────────────────────────────────────────────────
    Timer {
        interval: root.interval
        repeat: true
        running: root.active
        triggeredOnStart: true
        onTriggered: {
            statFile.reload();
            memFile.reload();
            netFile.reload();
            loadFile.reload();
            uptimeFile.reload();
        }
    }

    FileView {
        id: statFile
        path: "/proc/stat"
        blockLoading: true
        printErrors: false
        onTextChanged: root._updateCpu(statFile.text())
    }

    FileView {
        id: memFile
        path: "/proc/meminfo"
        blockLoading: true
        printErrors: false
        onTextChanged: root._updateMemory(memFile.text())
    }

    FileView {
        id: netFile
        path: "/proc/net/dev"
        blockLoading: true
        printErrors: false
        onTextChanged: root._updateNetwork(netFile.text())
    }

    FileView {
        id: loadFile
        path: "/proc/loadavg"
        blockLoading: true
        printErrors: false
        onTextChanged: root._updateLoad(loadFile.text())
    }

    FileView {
        id: uptimeFile
        path: "/proc/uptime"
        blockLoading: true
        printErrors: false
        onTextChanged: root.uptime = parseFloat(uptimeFile.text()) || 0
    }

    FileView {
        id: cpuInfoFile
        path: "/proc/cpuinfo"
        blockLoading: true
        printErrors: false
        onTextChanged: root._updateCpuInfo(cpuInfoFile.text())
    }

    FileView {
        id: hostnameFile
        path: "/etc/hostname"
        blockLoading: true
        printErrors: false
        onTextChanged: root.hostname = hostnameFile.text().trim()
    }

    FileView {
        id: kernelFile
        path: "/proc/sys/kernel/osrelease"
        blockLoading: true
        printErrors: false
        onTextChanged: root.kernel = kernelFile.text().trim()
    }

    // ── Parsers ────────────────────────────────────────────────────────────
    function _updateCpu(text) {
        const line = text.split("\n")[0];
        const parts = line.trim().split(/\s+/);
        if (parts.length < 5 || parts[0] !== "cpu")
            return;
        let idle = 0;
        let total = 0;
        for (let i = 1; i < parts.length && i <= 10; i++) {
            const v = Number(parts[i]);
            if (!isFinite(v))
                continue;
            total += v;
            if (i === 4 || i === 5) // idle + iowait
                idle += v;
        }
        if (root._prevCpuTotal >= 0) {
            const dTotal = total - root._prevCpuTotal;
            const dIdle = idle - root._prevCpuIdle;
            if (dTotal > 0) {
                root.cpuUsage = Math.max(0, Math.min(1, 1 - dIdle / dTotal));
                root.cpuHistory = root._push(root.cpuHistory, root.cpuUsage);
            }
        }
        root._prevCpuTotal = total;
        root._prevCpuIdle = idle;
    }

    function _updateMemory(text) {
        const read = (key) => {
            const match = text.match(new RegExp("^" + key + ":\\s+(\\d+)\\s+kB", "m"));
            return match ? Number(match[1]) * 1024 : 0;
        };
        const total = read("MemTotal");
        const available = read("MemAvailable");
        root.memTotal = total;
        root.memAvailable = available;
        root.memUsed = Math.max(0, total - available);
        root.memPercent = total > 0 ? root.memUsed / total : 0;
        root.memHistory = root._push(root.memHistory, root.memPercent);
        root.swapTotal = read("SwapTotal");
        root.swapUsed = Math.max(0, root.swapTotal - read("SwapFree"));
        root.swapPercent = root.swapTotal > 0 ? root.swapUsed / root.swapTotal : 0;
    }

    function _updateNetwork(text) {
        const lines = text.split("\n");
        let rx = 0;
        let tx = 0;
        let iface = "";
        for (let i = 2; i < lines.length; i++) {
            const parts = lines[i].trim().split(/[:\s]+/);
            if (parts.length < 10 || parts[0] === "lo")
                continue;
            const r = Number(parts[1]);
            const t = Number(parts[9]);
            if (!isFinite(r) || !isFinite(t))
                continue;
            rx += r;
            tx += t;
            if (iface === "" && (r > 0 || t > 0))
                iface = parts[0];
        }
        const now = Date.now();
        if (root._prevNetTime > 0) {
            const dt = (now - root._prevNetTime) / 1000;
            if (dt > 0) {
                root.netRxRate = Math.max(0, (rx - root._prevNetRx) / dt);
                root.netTxRate = Math.max(0, (tx - root._prevNetTx) / dt);
                root.netRxHistory = root._push(root.netRxHistory, root.netRxRate);
                root.netTxHistory = root._push(root.netTxHistory, root.netTxRate);
            }
        }
        if (iface !== "")
            root.netInterface = iface;
        root.netRxTotal = rx;
        root.netTxTotal = tx;
        root._prevNetRx = rx;
        root._prevNetTx = tx;
        root._prevNetTime = now;
    }

    function _updateLoad(text) {
        const parts = text.trim().split(/\s+/);
        root.load1 = Number(parts[0]) || 0;
        root.load5 = Number(parts[1]) || 0;
        root.load15 = Number(parts[2]) || 0;
    }

    function _updateCpuInfo(text) {
        const model = text.match(/^model name\s*:\s*(.+)$/m);
        root.cpuModel = model ? model[1].trim() : "";
        const threads = text.match(/^processor\s*:/gm);
        root.cpuThreads = threads ? threads.length : 0;
        const cores = text.match(/^cpu cores\s*:\s*(\d+)$/m);
        root.cpuCores = cores ? Number(cores[1]) : root.cpuThreads;
    }

    // ── Sensor polling (sysfs, no external dependency) ─────────────────────
    readonly property string sensorScript: [
        "while :; do",
        "  for f in /sys/class/hwmon/hwmon*/temp*_input; do",
        "    [ -r \"$f\" ] || continue",
        "    d=${f%/*}",
        "    n=\"\"",
        "    read -r n < \"$d/name\" 2>/dev/null",
        "    b=${f##*/}",
        "    b=${b%_input}",
        "    l=\"\"",
        "    [ -r \"$d/${b}_label\" ] && read -r l < \"$d/${b}_label\"",
        "    c=\"\"",
        "    [ -r \"$d/${b}_crit\" ] && read -r c < \"$d/${b}_crit\"",
        "    [ -n \"$c\" ] || { [ -r \"$d/${b}_max\" ] && read -r c < \"$d/${b}_max\"; }",
        "    v=\"\"",
        "    read -r v < \"$f\"",
        "    echo \"T|${d##*/}|$n|$l|$v|$c\"",
        "  done",
        "  best=\"\"",
        "  bestmem=0",
        "  for d in /sys/class/drm/card*/device; do",
        "    [ -r \"$d/mem_info_vram_total\" ] || continue",
        "    m=\"\"",
        "    read -r m < \"$d/mem_info_vram_total\"",
        "    [ -n \"$m\" ] || continue",
        "    if [ \"$m\" -gt \"$bestmem\" ]; then bestmem=$m; best=$d; fi",
        "  done",
        "  if [ -n \"$best\" ]; then",
        "    busy=\"\"",
        "    [ -r \"$best/gpu_busy_percent\" ] && read -r busy < \"$best/gpu_busy_percent\"",
        "    used=\"\"",
        "    [ -r \"$best/mem_info_vram_used\" ] && read -r used < \"$best/mem_info_vram_used\"",
        "    echo \"G|$busy|$used|$bestmem\"",
        "    for h in \"$best\"/hwmon/hwmon*; do",
        "      if [ -r \"$h/temp1_input\" ]; then",
        "        t=\"\"",
        "        read -r t < \"$h/temp1_input\"",
        "        echo \"H|temp|$t\"",
        "      fi",
        "      if [ -r \"$h/fan1_input\" ]; then",
        "        fa=\"\"",
        "        read -r fa < \"$h/fan1_input\"",
        "        echo \"H|fan|$fa\"",
        "      fi",
        "    done",
        "  fi",
        "  s=0",
        "  n=0",
        "  for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq; do",
        "    [ -r \"$f\" ] || continue",
        "    v=\"\"",
        "    read -r v < \"$f\"",
        "    [ -n \"$v\" ] || continue",
        "    s=$((s + v))",
        "    n=$((n + 1))",
        "  done",
        "  [ \"$n\" -gt 0 ] && echo \"C|$((s / n))\"",
        "  df -B1 --output=used,size / 2>/dev/null | { read -r hdr; read -r u t; [ -n \"$u\" ] && echo \"D|$u|$t\"; }",
        "  echo \"END\"",
        "  sleep 1",
        "done"
    ].join("\n")

    Process {
        id: sensorProcess
        command: ["/bin/sh", "-c", root.sensorScript]
        running: root.active
        stdout: SplitParser {
            onRead: (line) => root._handleSensorLine(line)
        }
        onRunningChanged: {
            if (!running && root.active)
                restartTimer.start();
        }
    }

    Timer {
        id: restartTimer
        interval: 2000
        repeat: false
        onTriggered: {
            if (root.active && !sensorProcess.running)
                sensorProcess.running = true;
        }
    }

    function _handleSensorLine(line) {
        if (!line || line.length < 2)
            return;
        const tag = line.charAt(0);
        if (tag === "T") {
            const p = line.split("|");
            if (p.length < 6)
                return;
            const value = Number(p[4]) / 1000;
            if (!isFinite(value) || value <= 0 || value > 200)
                return;
            const crit = Number(p[5]) / 1000;
            root._tempBuffer.push({
                hwmon: p[1],
                name: p[2],
                label: p[3],
                value: value,
                crit: (isFinite(crit) && crit > 0) ? crit : 100
            });
        } else if (tag === "G") {
            const p = line.split("|");
            if (p.length < 4)
                return;
            const busy = p[1] === "" ? NaN : Number(p[1]);
            root.gpuAvailable = isFinite(busy);
            if (root.gpuAvailable) {
                root.gpuUsage = Math.max(0, Math.min(1, busy / 100));
                root.gpuHistory = root._push(root.gpuHistory, root.gpuUsage);
                root.gpuVramUsed = Number(p[2]) || 0;
                root.gpuVramTotal = Number(p[3]) || 0;
            }
        } else if (tag === "H") {
            const p = line.split("|");
            if (p.length < 3)
                return;
            const value = Number(p[2]) / 1000;
            if (!isFinite(value) || value <= 0)
                return;
            if (p[1] === "temp")
                root.gpuTemp = value;
            else if (p[1] === "fan")
                root.gpuFan = value;
        } else if (tag === "C") {
            const value = Number(line.slice(2));
            if (isFinite(value) && value > 0)
                root.cpuFrequency = value / 1000;
        } else if (tag === "D") {
            const p = line.split("|");
            if (p.length < 3)
                return;
            root.diskUsed = Number(p[1]) || 0;
            root.diskTotal = Number(p[2]) || 0;
            root.diskPercent = root.diskTotal > 0 ? root.diskUsed / root.diskTotal : 0;
        } else if (tag === "E") {
            root._commitSensors();
        }
    }

    function _commitSensors() {
        const raw = root._tempBuffer;
        root.temperatures = raw;

        const counts = ({});
        const seen = ({});
        for (let i = 0; i < raw.length; i++) {
            const sensor = raw[i];
            if (root._blocklist.indexOf(sensor.name) !== -1)
                continue;
            const key = sensor.name + "|" + sensor.hwmon;
            if (seen[key])
                continue;
            seen[key] = true;
            counts[sensor.name] = (counts[sensor.name] ?? 0) + 1;
        }

        const groups = ({});
        const order = [];
        for (let i = 0; i < raw.length; i++) {
            const sensor = raw[i];
            if (root._blocklist.indexOf(sensor.name) !== -1)
                continue;
            if (!groups[sensor.hwmon]) {
                groups[sensor.hwmon] = [];
                order.push(sensor.hwmon);
            }
            groups[sensor.hwmon].push(sensor);
        }

        const counters = ({});
        const summary = [];
        for (let i = 0; i < order.length; i++) {
            const list = groups[order[i]];
            const name = list[0].name;
            const preferred = root._preferredLabels[name] ?? [""];
            let chosen = list[0];
            for (let p = 0; p < preferred.length; p++) {
                const match = list.find(s => s.label === preferred[p]);
                if (match) {
                    chosen = match;
                    break;
                }
            }
            const idx = (counters[name] ?? 0) + 1;
            counters[name] = idx;
            const base = root._deviceNames[name] ?? name;
            summary.push({
                id: order[i],
                name: name,
                label: base + (counts[name] > 1 ? " " + idx : ""),
                value: chosen.value,
                crit: chosen.crit,
                percent: Math.max(0, Math.min(1, chosen.value / chosen.crit))
            });
        }
        summary.sort((a, b) => {
            const byPriority = (root._devicePriority[a.name] ?? 9) - (root._devicePriority[b.name] ?? 9);
            return byPriority !== 0 ? byPriority : a.id.localeCompare(b.id);
        });
        root.temperatureSummary = summary;
        root._tempBuffer = [];
    }

    // Find the CPU temperature from the summary (k10temp, zenpower, coretemp)
    readonly property var cpuSensor: temperatureSummary.find(s => s.name === "k10temp" || s.name === "zenpower" || s.name === "coretemp") ?? null
    readonly property real cpuTemp: cpuSensor ? cpuSensor.value : -1
}
