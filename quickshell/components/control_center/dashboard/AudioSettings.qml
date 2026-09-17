import QtQuick
import Quickshell
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import QtQuick.Effects
import Quickshell.Io

import qs.services
import "../../../utils"
import "../../common/interface"
import "../../common/interactive"

Item {
    id: root

    readonly property color foregroundColor: Colors.on_background
    readonly property color mutedColor: Settings.isOled ? "#aaa" : Colors.on_surface_variant
    readonly property string font: Settings.fontFamily

    BackgroundLayer {
        id: background
        anchors.fill: parent
    }

    Column {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        Item {
            width: parent.width
            height: 22

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Audio"
                color: root.foregroundColor
                font.family: root.font
                font.pixelSize: 14
            }

            Text {
                id: settingsIcon
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: ""
                color: settingsMouse.containsMouse ? Colors.primary : root.foregroundColor
                font.family: root.font
                font.pixelSize: 13

                Behavior on color {
                    ColorAnimation { duration: 120; easing.type: Easing.InOutQuad }
                }
            }

            MouseArea {
                id: settingsMouse
                anchors.fill: settingsIcon
                anchors.topMargin: -4
                anchors.bottomMargin: -4
                anchors.leftMargin: -6
                anchors.rightMargin: -6
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: NavigationState.requestedSettingsPage = "audio"
            }
        }

        // ── Output ──────────────────────────────────────────────────────────
        Column {
            id: outputRow
            width: parent.width

            readonly property bool muted: Audio.sink?.audio?.muted ?? false
            readonly property real volume: Math.min(1, Audio.value)

            Item {
                width: parent.width
                height: 14

                Text {
                    id: outputLabel
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: Audio.ready ? Audio.friendlyDeviceName(Audio.sink) : "No output device"
                    color: root.mutedColor
                    font.family: root.font
                    font.pixelSize: 10
                    elide: Text.ElideRight
                    width: parent.width - outputPercent.width - 8
                }

                Text {
                    id: outputPercent
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: Math.round(outputRow.volume * 100) + "%"
                    color: root.mutedColor
                    font.family: root.font
                    font.pixelSize: 10
                }
            }

            Item {
                width: parent.width
                height: 24

                Text {
                    id: outputIcon
                    x: 0
                    width: 22
                    horizontalAlignment: Text.AlignHCenter
                    anchors.verticalCenter: parent.verticalCenter
                    text: outputRow.muted ? "" : (Audio.value > 0.66 ? "" : (Audio.value > 0.33 ? "" : ""))
                    color: outputRow.muted ? root.mutedColor : Colors.primary
                    font.family: root.font
                    font.pixelSize: 15
                }

                MouseArea {
                    anchors.fill: outputIcon
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Audio.toggleMute()
                }

                Slider {
                    id: outputSlider
                    value: outputRow.volume
                    x: outputIcon.width + 8
                    width: parent.width - x
                    anchors.verticalCenter: parent.verticalCenter

                    property bool isBindingBlocked: false

                    Connections {
                        target: Audio.sink?.audio ?? null
                        function onVolumeChanged() {
                            if (!outputSlider.isBindingBlocked) {
                                outputSlider.value = outputRow.volume
                            }
                        }
                    }

                    onMoved: (newValue) => {
                        isBindingBlocked = true
                        outputSlider.value = newValue
                        if (Audio.sink)
                            Audio.sink.audio.volume = newValue
                        isBindingBlocked = false
                    }
                }
            }
        }

        // ── Input ───────────────────────────────────────────────────────────
        Column {
            id: inputRow
            width: parent.width

            readonly property bool muted: Audio.source?.audio?.muted ?? false
            readonly property real volume: Math.min(1, Audio.source?.audio?.volume ?? 0)

            Item {
                width: parent.width
                height: 14

                Text {
                    id: inputLabel
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: Audio.ready ? Audio.friendlyDeviceName(Audio.source) : "No input device"
                    color: root.mutedColor
                    font.family: root.font
                    font.pixelSize: 10
                    elide: Text.ElideRight
                    width: parent.width - inputPercent.width - 8
                }

                Text {
                    id: inputPercent
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: Math.round(inputRow.volume * 100) + "%"
                    color: root.mutedColor
                    font.family: root.font
                    font.pixelSize: 10
                }
            }

            Item {
                width: parent.width
                height: 24

                Text {
                    id: inputIcon
                    x: 0
                    width: 22
                    horizontalAlignment: Text.AlignHCenter
                    anchors.verticalCenter: parent.verticalCenter
                    text: inputRow.muted ? "󰍭" : "󰍬"
                    color: inputRow.muted ? root.mutedColor : Colors.primary
                    font.family: root.font
                    font.pixelSize: 15
                }

                MouseArea {
                    anchors.fill: inputIcon
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Audio.toggleMicMute()
                }

                Slider {
                    id: inputSlider
                    value: inputRow.volume
                    x: inputIcon.width + 8
                    width: parent.width - x
                    anchors.verticalCenter: parent.verticalCenter

                    property bool isBindingBlocked: false

                    Connections {
                        target: Audio.source?.audio ?? null
                        function onVolumeChanged() {
                            if (!inputSlider.isBindingBlocked) {
                                inputSlider.value = inputRow.volume
                            }
                        }
                    }

                    onMoved: (newValue) => {
                        isBindingBlocked = true
                        inputSlider.value = newValue
                        if (Audio.source)
                            Audio.source.audio.volume = newValue
                        isBindingBlocked = false
                    }
                }
            }
        }
    }
}
