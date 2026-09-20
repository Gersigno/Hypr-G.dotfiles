import QtQuick
import Quickshell

import qs.services
import "../../utils"
import "./metrics"

Item {
    id: root

    implicitWidth: 900
    implicitHeight: 420

    readonly property color fg: Colors.on_background
    readonly property color muted: Settings.isOled && Theme.isDarkMode ? "#9aa0a6" : Colors.on_surface_variant
    readonly property color accent: Colors.primary
    readonly property color accent2: Colors.tertiary
    readonly property color accent3: Colors.secondary
    readonly property string font: Settings.fontFamily

    readonly property color cpuColor: usageColor(Metrics.cpuUsage)
    readonly property color gpuColor: usageColor(Metrics.gpuUsage)

    function usageColor(usage) {
        if (usage < 0.55)
            return accent;
        if (usage < 0.8)
            return "#ffd166";
        return Colors.error;
    }

    function tempColor(temperature) {
        const stops = [
            { t: 30, c: [0.45, 0.72, 1.00] },
            { t: 55, c: [0.50, 0.85, 0.55] },
            { t: 72, c: [1.00, 0.80, 0.35] },
            { t: 88, c: [1.00, 0.42, 0.42] }
        ];
        if (!isFinite(temperature) || temperature <= 0)
            return muted;
        if (temperature <= stops[0].t)
            return Qt.rgba(stops[0].c[0], stops[0].c[1], stops[0].c[2], 1);
        for (let i = 1; i < stops.length; i++) {
            if (temperature <= stops[i].t) {
                const a = stops[i - 1];
                const b = stops[i];
                const k = (temperature - a.t) / (b.t - a.t);
                return Qt.rgba(
                    a.c[0] + (b.c[0] - a.c[0]) * k,
                    a.c[1] + (b.c[1] - a.c[1]) * k,
                    a.c[2] + (b.c[2] - a.c[2]) * k, 1);
            }
        }
        const last = stops[stops.length - 1].c;
        return Qt.rgba(last[0], last[1], last[2], 1);
    }

    Column {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        // ── Header ─────────────────────────────────────────────────────────
        Item {
            id: header
            width: parent.width
            height: 36

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: ""
                    color: root.accent
                    font.family: root.font
                    font.pixelSize: 22
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0

                    Text {
                        text: "Performances"
                        color: root.fg
                        font.family: root.font
                        font.pixelSize: 17
                        font.weight: Font.Bold
                    }

                    Text {
                        text: (Metrics.hostname !== "" ? Metrics.hostname : "localhost")
                            + "   •   " + (Metrics.kernel !== "" ? Metrics.kernel : "Linux")
                        color: root.muted
                        font.family: root.font
                        font.pixelSize: 10
                    }
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                HeaderChip {
                    icon: "󰋊"
                    label: "Disk " + Math.round(Metrics.diskPercent * 100) + "%"
                }
                HeaderChip {
                    icon: "󰅐"
                    label: Metrics.formatUptime(Metrics.uptime)
                }
                HeaderChip {
                    icon: "󰓅"
                    label: "Load " + Metrics.load1.toFixed(2)
                    iconColor: root.accent3
                }
            }
        }

        // ── Cards ──────────────────────────────────────────────────────────
        Row {
            id: grid
            width: parent.width
            height: parent.height - header.height - parent.spacing
            spacing: 8

            // CPU ──────────────────────────────────────────────────────────
            MetricCard {
                id: cpuCard
                width: 300
                height: parent.height
                icon: ""
                title: "Processor"
                subtitle: Metrics.cpuModel
                iconColor: root.accent

                headerRight: Text {
                    text: Metrics.formatFrequency(Metrics.cpuFrequency)
                    color: root.accent
                    font.family: root.font
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }

                Column {
                    anchors.fill: parent
                    spacing: 6

                    Item {
                        width: parent.width
                        height: 170

                        RingGauge {
                            id: cpuGauge
                            anchors.centerIn: parent
                            width: 170
                            height: 170
                            value: Metrics.cpuUsage
                            lineWidth: 10
                            trackColor: Qt.rgba(root.fg.r, root.fg.g, root.fg.b, 0.07)
                            progressColor: root.cpuColor

                            Column {
                                anchors.centerIn: parent
                                spacing: -2

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: Math.round(Metrics.cpuUsage * 100)
                                    color: root.fg
                                    font.family: root.font
                                    font.pixelSize: 36
                                    font.weight: Font.Bold
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "%  CPU"
                                    color: root.muted
                                    font.family: root.font
                                    font.pixelSize: 10
                                    font.letterSpacing: 1
                                }
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: 6

                        StatTile {
                            width: (parent.width - parent.spacing * 2) / 3
                            value: Metrics.cpuCores + "C / " + Metrics.cpuThreads + "T"
                            label: "Cores"
                        }
                        StatTile {
                            width: (parent.width - parent.spacing * 2) / 3
                            value: Metrics.load1.toFixed(2)
                            label: "Load 1m"
                        }
                        StatTile {
                            width: (parent.width - parent.spacing * 2) / 3
                            value: Metrics.cpuTemp > 0 ? Math.round(Metrics.cpuTemp) + "°" : "--"
                            label: "Temp"
                            valueColor: root.tempColor(Metrics.cpuTemp)
                        }
                    }

                    Graph {
                        width: parent.width
                        height: parent.height - y
                        values: Metrics.cpuHistory
                        maxValue: 1
                        maxSamples: Metrics.historyLength
                        lineColor: root.cpuColor
                        showLastPoint: true
                    }
                }
            }

            Column {
                id: rightColumn
                width: parent.width - cpuCard.width - grid.spacing
                height: parent.height
                spacing: 8

                readonly property real rowHeight: (height - spacing) / 2

                Row {
                    width: parent.width
                    height: rightColumn.rowHeight
                    spacing: 8

                    // Memory ───────────────────────────────────────────────
                    MetricCard {
                        id: memCard
                        width: (parent.width - parent.spacing) / 2
                        height: parent.height
                        icon: ""
                        title: "Memory"
                        iconColor: root.accent2

                        headerRight: Text {
                            text: Metrics.formatBytes(Metrics.memUsed, 1) + " / " + Metrics.formatBytes(Metrics.memTotal, 1)
                            color: root.muted
                            font.family: root.font
                            font.pixelSize: 10
                        }

                        Column {
                            anchors.fill: parent
                            spacing: 6

                            Item {
                                width: parent.width
                                height: 40

                                Row {
                                    anchors.left: parent.left
                                    anchors.bottom: parent.bottom
                                    spacing: 2

                                    Text {
                                        text: Math.round(Metrics.memPercent * 100)
                                        color: root.fg
                                        font.family: root.font
                                        font.pixelSize: 30
                                        font.weight: Font.Bold
                                    }

                                    Text {
                                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: 5
                                        text: "%"
                                        color: root.accent2
                                        font.family: root.font
                                        font.pixelSize: 14
                                        font.weight: Font.Bold
                                    }
                                }

                                Column {
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    spacing: 1

                                    Text {
                                        anchors.right: parent.right
                                        text: Metrics.formatBytes(Metrics.memUsed, 1) + " used"
                                        color: root.fg
                                        font.family: root.font
                                        font.pixelSize: 11
                                    }

                                    Text {
                                        anchors.right: parent.right
                                        text: Metrics.formatBytes(Metrics.memAvailable, 1) + " free"
                                        color: root.muted
                                        font.family: root.font
                                        font.pixelSize: 10
                                    }
                                }
                            }

                            BarGraph {
                                width: parent.width
                                height: 44
                                values: Metrics.memHistory
                                maxValue: 1
                                maxSamples: 48
                                barColor: root.accent2
                            }

                            Item {
                                width: parent.width
                                height: 26

                                Text {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    text: "Swap"
                                    color: root.muted
                                    font.family: root.font
                                    font.pixelSize: 10
                                }

                                Text {
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    text: Metrics.swapTotal > 0
                                        ? Metrics.formatBytes(Metrics.swapUsed, 1) + " / " + Metrics.formatBytes(Metrics.swapTotal, 1)
                                        : "Disabled"
                                    color: root.muted
                                    font.family: root.font
                                    font.pixelSize: 10
                                }

                                Rectangle {
                                    id: swapTrack
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    height: 4
                                    radius: 2
                                    color: Qt.rgba(root.fg.r, root.fg.g, root.fg.b, 0.08)

                                    Rectangle {
                                        width: Math.max(0, swapTrack.width * Metrics.swapPercent)
                                        height: parent.height
                                        radius: 2
                                        color: root.accent2

                                        Behavior on width {
                                            NumberAnimation {
                                                duration: 600
                                                easing.type: Easing.OutCubic
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // GPU ──────────────────────────────────────────────────
                    MetricCard {
                        id: gpuCard
                        width: (parent.width - parent.spacing) / 2
                        height: parent.height
                        icon: ""
                        title: "Graphics"
                        iconColor: root.accent3

                        headerRight: Text {
                            visible: Metrics.gpuTemp > 0
                            text: Math.round(Metrics.gpuTemp) + "°C"
                            color: root.tempColor(Metrics.gpuTemp)
                            font.family: root.font
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                        }

                        Item {
                            anchors.fill: parent

                            Row {
                                anchors.fill: parent
                                spacing: 10
                                visible: Metrics.gpuAvailable

                                RingGauge {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 104
                                    height: 104
                                    value: Metrics.gpuUsage
                                    lineWidth: 8
                                    trackColor: Qt.rgba(root.fg.r, root.fg.g, root.fg.b, 0.07)
                                    progressColor: root.gpuColor

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: -2

                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: Math.round(Metrics.gpuUsage * 100)
                                            color: root.fg
                                            font.family: root.font
                                            font.pixelSize: 22
                                            font.weight: Font.Bold
                                        }

                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: "%"
                                            color: root.muted
                                            font.family: root.font
                                            font.pixelSize: 9
                                        }
                                    }
                                }

                                Column {
                                    width: parent.width - 114
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 8

                                    Column {
                                        width: parent.width
                                        spacing: 3

                                        Item {
                                            width: parent.width
                                            height: 12

                                            Text {
                                                anchors.left: parent.left
                                                anchors.top: parent.top
                                                text: "VRAM"
                                                color: root.muted
                                                font.family: root.font
                                                font.pixelSize: 10
                                            }

                                            Text {
                                                anchors.right: parent.right
                                                anchors.top: parent.top
                                                text: Metrics.formatBytes(Metrics.gpuVramUsed, 1) + " / " + Metrics.formatBytes(Metrics.gpuVramTotal, 1)
                                                color: root.fg
                                                font.family: root.font
                                                font.pixelSize: 10
                                                font.weight: Font.DemiBold
                                            }
                                        }

                                        Rectangle {
                                            id: vramTrack
                                            width: parent.width
                                            height: 4
                                            radius: 2
                                            color: Qt.rgba(root.fg.r, root.fg.g, root.fg.b, 0.08)

                                            Rectangle {
                                                width: Metrics.gpuVramTotal > 0
                                                    ? Math.max(4, vramTrack.width * Math.min(1, Metrics.gpuVramUsed / Metrics.gpuVramTotal))
                                                    : 0
                                                height: parent.height
                                                radius: 2
                                                color: root.accent3

                                                Behavior on width {
                                                    NumberAnimation {
                                                        duration: 600
                                                        easing.type: Easing.OutCubic
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    Item {
                                        width: parent.width
                                        height: 12

                                        Text {
                                            anchors.left: parent.left
                                            anchors.top: parent.top
                                            text: "Fan"
                                            color: root.muted
                                            font.family: root.font
                                            font.pixelSize: 10
                                        }

                                        Text {
                                            anchors.right: parent.right
                                            anchors.top: parent.top
                                            text: Metrics.gpuFan >= 0 ? Math.round(Metrics.gpuFan) + " RPM" : "--"
                                            color: root.fg
                                            font.family: root.font
                                            font.pixelSize: 10
                                            font.weight: Font.DemiBold
                                        }
                                    }

                                    Item {
                                        width: parent.width
                                        height: 12

                                        Text {
                                            anchors.left: parent.left
                                            anchors.top: parent.top
                                            text: "Temperature"
                                            color: root.muted
                                            font.family: root.font
                                            font.pixelSize: 10
                                        }

                                        Text {
                                            anchors.right: parent.right
                                            anchors.top: parent.top
                                            text: Metrics.gpuTemp > 0 ? Math.round(Metrics.gpuTemp) + " °C" : "--"
                                            color: root.tempColor(Metrics.gpuTemp)
                                            font.family: root.font
                                            font.pixelSize: 10
                                            font.weight: Font.DemiBold
                                        }
                                    }
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: !Metrics.gpuAvailable
                                text: "No GPU telemetry"
                                color: root.muted
                                font.family: root.font
                                font.pixelSize: 11
                            }
                        }
                    }
                }

                Row {
                    width: parent.width
                    height: rightColumn.rowHeight
                    spacing: 8

                    // Network ──────────────────────────────────────────────
                    MetricCard {
                        id: netCard
                        width: (parent.width - parent.spacing) / 2
                        height: parent.height
                        icon: "󰖟"
                        title: "Network"
                        subtitle: Metrics.netInterface
                        iconColor: root.accent

                        Column {
                            anchors.fill: parent
                            spacing: 4

                            Item {
                                width: parent.width
                                height: 32

                                Row {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 6

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "󰇚"
                                        color: root.accent
                                        font.family: root.font
                                        font.pixelSize: 14
                                    }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: Metrics.formatRate(Metrics.netRxRate)
                                        color: root.fg
                                        font.family: root.font
                                        font.pixelSize: 14
                                        font.weight: Font.DemiBold
                                    }
                                }

                                Graph {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 118
                                    height: 26
                                    values: Metrics.netRxHistory
                                    autoScale: true
                                    minScale: 1024
                                    maxSamples: Metrics.historyLength
                                    lineColor: root.accent
                                    lineWidth: 1.6
                                    fill: false
                                }
                            }

                            Item {
                                width: parent.width
                                height: 32

                                Row {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 6

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "󰕒"
                                        color: root.accent2
                                        font.family: root.font
                                        font.pixelSize: 14
                                    }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: Metrics.formatRate(Metrics.netTxRate)
                                        color: root.fg
                                        font.family: root.font
                                        font.pixelSize: 14
                                        font.weight: Font.DemiBold
                                    }
                                }

                                Graph {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 118
                                    height: 26
                                    values: Metrics.netTxHistory
                                    autoScale: true
                                    minScale: 1024
                                    maxSamples: Metrics.historyLength
                                    lineColor: root.accent2
                                    lineWidth: 1.6
                                    fill: false
                                }
                            }

                            Item {
                                width: parent.width
                                height: parent.height - y

                                Text {
                                    anchors.left: parent.left
                                    anchors.bottom: parent.bottom
                                    text: "Σ  " + Metrics.formatBytes(Metrics.netRxTotal) + " down"
                                        + "   •   " + Metrics.formatBytes(Metrics.netTxTotal) + " up"
                                    color: root.muted
                                    font.family: root.font
                                    font.pixelSize: 10
                                }
                            }
                        }
                    }

                    // Temperatures ──────────────────────────────────────────
                    MetricCard {
                        id: tempCard
                        width: (parent.width - parent.spacing) / 2
                        height: parent.height
                        icon: ""
                        title: "Temperatures"
                        iconColor: root.tempColor(Metrics.cpuTemp)

                        headerRight: Text {
                            text: Metrics.temperatureSummary.length > 0
                                ? Math.round(Metrics.temperatureSummary[0].value) + "°C"
                                : "--"
                            color: Metrics.temperatureSummary.length > 0
                                ? root.tempColor(Metrics.temperatureSummary[0].value)
                                : root.muted
                            font.family: root.font
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                        }

                        Column {
                            anchors.fill: parent
                            spacing: 1

                            Repeater {
                                model: Math.min(5, Metrics.temperatureSummary.length)

                                delegate: SensorRow {
                                    required property int index

                                    readonly property var sensor: Metrics.temperatureSummary[index] ?? ({})

                                    width: parent.width
                                    label: sensor.label ?? ""
                                    value: sensor.value ?? 0
                                    percent: sensor.percent ?? 0
                                    barColor: root.tempColor(value)
                                    valueColor: root.tempColor(value)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: Metrics.active = visible

    onVisibleChanged: Metrics.active = visible
}
