import QtQuick
import Quickshell

import "../../config"
import "../../utils"
import "../common"

Item {
    id: root

    implicitWidth: 420
    implicitHeight: 160

    readonly property color fg:     Colors.on_background
    readonly property color fgSub:  Colors.on_surface_variant
    readonly property color accent: Colors.primary
    readonly property string fontFamily: Config.fontFamily
    readonly property string title: "Stopwatch"

    property int elapsed: 0   // milliseconds
    property bool running: false

    function format(ms) {
        const h   = Math.floor(ms / 3600000)
        const m   = Math.floor((ms % 3600000) / 60000)
        const s   = Math.floor((ms % 60000) / 1000)
        const cs  = Math.floor((ms % 1000) / 10)
        const pad = n => n < 10 ? "0" + n : "" + n
        return (h > 0 ? h + ":" : "") + pad(m) + ":" + pad(s) + "." + pad(cs)
    }

    Timer {
        interval: 10
        running: root.running
        repeat: true
        onTriggered: root.elapsed += 10
    }

    Column {
        anchors.centerIn: parent
        spacing: 18

        // ── Time display ────────────────────────────────────────────────
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.format(root.elapsed)
            color: root.fg
            font.family: root.fontFamily
            font.pixelSize: 52
            font.weight: Font.Light
            font.letterSpacing: 2
        }

        // ── Buttons ─────────────────────────────────────────────────────
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 14

            // Reset
            Button {
                text: "Reset"
                severity: Button.Severity.Secondary
                fullRounded: true
                onClicked: { root.running = false; root.elapsed = 0 }
            }

            // Start / Stop
            Button {
                text: root.running ? " Pause" : (root.elapsed > 0 ? "  Resume" : "  Start")
                severity: Button.Severity.Primary
                fullRounded: true
                onClicked: root.running = !root.running
            }
        }
    }
}