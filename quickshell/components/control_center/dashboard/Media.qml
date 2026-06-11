import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets
import QtQuick.Shapes
import QtQuick.Effects

import "../../../config"
import "../../../utils"
import "../../common/interface"
import qs.services

Item {
    id: root

    readonly property color background:     Colors.background
    readonly property color fg:             Colors.on_background
    readonly property color fgSub:          Colors.on_surface_variant
    readonly property color accent:         Colors.primary
    readonly property color surfaceHigh:    Colors.surface_container_high
    readonly property color surfaceHighest: Colors.surface_container_highest
    readonly property color onAccent:       Colors.on_primary
    readonly property string font:          Config.fontFamily

    readonly property MprisPlayer player: Media.activePlayer
    readonly property bool hasPlayer: player !== null

    property real localPosition: 0

    Timer {
        interval: 500
        running: root.player?.isPlaying ?? false
        repeat: true
        onTriggered: {
            //console.log("[Media] Timer tick, root.player.position =", root.player?.position, "converted time =", root.formatTime(root.player?.position ?? 0))
            //if (root.player) elapsedText.text = root.formatTime(root.player?.position ?? 0)
            if (root.player) root.localPosition = root.player.position
        }
    }

    // Reset on track change
    Connections {
        target: root.player
        function onTrackTitleChanged() {
            root.localPosition = root.player?.position ?? 0
        }
    }

    // ── Helpers ─────────────────────────────────────────────────────────────
    function formatTime(sec) {
        if (sec <= 0) return "0:00"
        const totalSec = Math.floor(sec)
        const h   = Math.floor(totalSec / 3600)
        const min = Math.floor((totalSec % 3600) / 60)
        const s   = totalSec % 60
        const mm  = min < 10 ? "0" + min : "" + min
        const ss  = s   < 10 ? "0" + s   : "" + s
        return h > 0 ? h + ":" + mm + ":" + ss : min + ":" + ss
    }

    function prettySource(p) {
        if (!p) return ""
        const id = (p.identity ?? "").toLowerCase()
        if (id.includes("spotify"))     return "   Spotify"
        if (id.includes("firefox"))     return "󰈹   Firefox"
        if (id.includes("zen"))         return "󰈹   Zen"
        if (id.includes("chromium"))    return "   Chromium"
        if (id.includes("chrome"))      return "   Chrome"
        if (id.includes("vlc"))         return "嗢 VLC"
        if (id.includes("youtube"))     return "   YouTube"
        return p.identity ?? ""
    }

    onPlayerChanged: {
        localPosition = player?.position ?? 0
    }

    BackgroundLayer {
        id: background
        anchors.fill: parent
    }

    /*Text {
        visible: !root.hasPlayer
        anchors.centerIn: parent
        text: "No active media player"
        color: root.fgSub
        font.family: root.font
        font.pixelSize: 15
    }*/

    Item {
        id: backgroundArtLayer
        anchors.fill: parent
        z: -1
        clip: true

        visible: status === Image.Ready

        Image {
            id: backgroundArt
            anchors.fill: parent
            source: root.player?.trackArtUrl ?? ""
            fillMode: Image.PreserveAspectCrop
            opacity: root.player?.isPlaying ?? false ? 0.7 : 0
            //blur
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                source: backgroundArt
                blur: 2.5
            }
            Behavior on opacity { 
                NumberAnimation { 
                    duration: 300 
                } 
            }
        }

        //Circular gradient overlay for better text contrast
        Shape {
            id: overlayShape
            anchors.fill: parent

            ShapePath {
                strokeColor: "transparent"
                strokeWidth: 0
                fillRule: ShapePath.WindingFill
                startX: 0; startY: 0
                PathLine { x: overlayShape.width;  y: 0 }
                PathLine { x: overlayShape.width;  y: overlayShape.height }
                PathLine { x: 0;                   y: overlayShape.height }
                PathLine { x: 0;                   y: 0 }

                fillGradient: RadialGradient {
                    centerX: overlayShape.width / 2
                    centerY: -overlayShape.height / 4
                    centerRadius: Math.max(overlayShape.width, overlayShape.height)
                    focalX: centerX
                    focalY: centerY
                    focalRadius: 0
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.5; color: root.background }
                }
            }
        }
    }

    // ── Player view ──────────────────────────────────────────────────────────
    Item {
        //visible: root.hasPlayer
        anchors.fill: parent
        anchors.margins: 8

        // Cover art ────────────────────────────────────────────────────────
        ClippingRectangle {
            id: coverRect
            width: 120; height: 120
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            radius: 14
            color: root.surfaceHigh
            clip: true

            Image {
                id: artImage
                anchors.fill: parent
                source: root.player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                visible: status === Image.Ready
            }

            // Fallback icon
            Text {
                anchors.centerIn: parent
                visible: artImage.status !== Image.Ready
                color: root.fgSub
                text: ""
                font.pixelSize: 52
                transform: Translate { x: -2 }
            }

            // Subtle inner border
            Rectangle {
                anchors.fill: parent
                radius: 14
                color: "transparent"
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.07)
            }
        }

        Rectangle {
            id: sourceBadge
            height: 20
            width: sourceText.implicitWidth + 16
            radius: 10
            color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.18)
            anchors.right: parent.right
            anchors.top: parent.top

            visible: root.player?.identity !== undefined && root.player?.identity !== ""

            Text {
                id: sourceText
                anchors.centerIn: parent
                text: root.prettySource(root.player)
                color: root.accent
                font.family: Config.fontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
                font.letterSpacing: 0.4
            }
        }

        // Info + controls column ───────────────────────────────────────────
        Column {
            anchors.left: coverRect.right
            anchors.leftMargin: 18
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            // Track title
            Text {
                width: parent.width - sourceBadge.width - 8
                text: root.player?.trackTitle ?? "Not playing"
                color: root.fg
                font.family: Config.fontFamily
                font.pixelSize: 16
                font.weight: Font.Bold
                elide: Text.ElideRight
            }

            // Artist
            Text {
                id: artistText
                width: parent.width
                text: root.player?.trackArtist ?? ""
                color: root.fgSub
                font.family: Config.fontFamily
                font.pixelSize: 13
                elide: Text.ElideRight
            }

            Item { width: 1; height: 2 }

            // Transport controls ───────────────────────────────────────────
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Rectangle {
                    width: 30; height: 30;
                    color: "transparent"//prevHov.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: root.fg
                        font.pixelSize: 16
                        opacity: root.player?.canGoPrevious ? 1 : 0.4
                    }
                    MouseArea {
                        id: prevHov
                        anchors.fill: parent
                        hoverEnabled: root.player?.canGoPrevious ?? false
                        cursorShape: root.player?.canGoPrevious ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (!root.player) return
                            if (root.localPosition > 3000) {
                                root.player.seek(-root.localPosition)
                                root.localPosition = 0
                            } else {
                                if (root.player?.canGoPrevious) root.player.previous()
                            }
                        }
                    }
                }

                Rectangle {
                    width: 30; height: 30; radius: 15
                    color: root.hasPlayer ? root.accent : "transparent"

                    Text {
                        anchors.centerIn: parent
                        // Slight optical nudge for the play triangle
                        x: (root.player?.isPlaying ?? false) ? 0 : 1
                        text: (root.player?.isPlaying ?? false) ? "" : ""
                        color: root.hasPlayer ? root.onAccent : root.fgSub
                        font.pixelSize: 18
                        opacity: root.hasPlayer ? 1 : 0.6
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: root.hasPlayer ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (!root.player) return
                            root.player.isPlaying ? root.player.pause() : root.player.play()
                        }
                    }
                }

                Rectangle {
                    width: 30; height: 30;
                    color: "transparent"//nextHov.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: root.fg
                        font.pixelSize: 16
                        opacity: root.player?.canGoNext ? 1 : 0.4
                    }
                    MouseArea {
                        id: nextHov
                        anchors.fill: parent
                        hoverEnabled: root.player?.canGoNext ?? false
                        cursorShape: root.player?.canGoNext ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (!root.player) return
                            if (root.player?.canGoNext) root.player.next()
                        }
                    }
                }
            }

            Item { width: 1; height: 2 }

            // Progress bar ─────────────────────────────────────────────────
            Item {
                id: progressBar
                width: parent.width
                height: 5

                readonly property real pct: root.player && (root.player.length ?? 0) > 0
                    ? Math.max(0, Math.min(1, root.localPosition / root.player.length))
                    : 0

                // Track background
                Rectangle {
                    anchors.fill: parent
                    radius: 3
                    color: root.fgSub
                    opacity: 0.4
                }
                // Fill
                Rectangle {
                    width: progressBar.width * progressBar.pct
                    height: parent.height
                    radius: 3
                    color: root.accent
                }
                // Click-to-seek
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.SizeHorCursor
                    onClicked: {
                        if (!root.player || !(root.player.length > 0)) return
                        const target = (mouseX / width) * root.player.length
                        root.player.seek(target - root.localPosition)
                        root.localPosition = target
                    }
                }
            }

            // Time labels: elapsed / remaining ────────────────────────────
            Item {
                width: parent.width
                height: 13

                Text {
                    id: elapsedText
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.hasPlayer ? root.formatTime(root.localPosition) : "-:--"
                    color: root.fgSub
                    font.family: Config.fontFamily
                    font.pixelSize: 11
                }
                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.hasPlayer ? "−" + root.formatTime(Math.max(0, (root.player?.length ?? 0) - root.localPosition)) : "-:--"
                    color: root.fgSub
                    font.family: Config.fontFamily
                    font.pixelSize: 11
                }
            }
        }
    }
}