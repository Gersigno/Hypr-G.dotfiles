import QtQuick
import Quickshell
import QtCore
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import QtQuick.Effects
import Quickshell.Io
import QtQuick.Layouts
import Quickshell.Hyprland

import "../../../config"
import "../../../utils"
import "../../common/interface"
import "../../common/interactive"
import qs.services

Item {
    id: root

    readonly property color foregroundColor: Config.isOled ? "#fff" : Colors.on_background
    readonly property string font: Config.fontFamily

    BackgroundLayer {
        id: background
        anchors.fill: parent
    }

    Item {
        id: content
        anchors.fill: parent
        anchors.margins: 12

        Column {
            id: column
            anchors.fill: parent
            spacing: 4

            Item {
                height: 24
                anchors.left: parent.left
                anchors.right: parent.right

                Text {
                    text: "Brightness"
                    color: root.foregroundColor
                    font.family: root.font
                    font.pixelSize: 14
                }
                Text {
                    id: brightness_value
                    text: Math.round(Brightness.value * 100) + "%"
                    color: root.foregroundColor
                    font.family: root.font
                    font.pixelSize: 14
                    anchors.right: parent.right
                }
            }
            Row {
                id: sliderRow
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 8
                height: 30

                Text {
                    id: iconMin
                    text: "󰃞"
                    color: root.foregroundColor
                    font.family: root.font
                    font.pixelSize: 16
                    anchors.verticalCenter: parent.verticalCenter
                }

                Slider {
                    id: brightnessSlider
                    value: Brightness.value

                    anchors.verticalCenter: parent.verticalCenter

                    width: parent.width - iconMin.width - iconMax.width - (sliderRow.spacing * 2)

                    Connections {
                        target: Brightness
                        function onValueChanged() {
                            if (!brightnessSlider.isBindingBlocked) {
                                brightnessSlider.value = Brightness.value;
                            }
                        }
                    }

                    property bool isBindingBlocked: false

                    onMoved: (newValue) => {
                        isBindingBlocked = true;
                        brightnessSlider.value = newValue;
                        Brightness.setBrightness(newValue);
                        isBindingBlocked = false;
                    }
                }

                Text {
                    id: iconMax
                    text: "󰃠"
                    color: root.foregroundColor
                    font.family: root.font
                    font.pixelSize: 16
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            GridLayout {
                width: parent.width
                columns: 3
                rowSpacing: 2

                Button {
                    id: wifiButton
                    topIcon: ""
                    text: "Wifi"
                    severity: Button.Severity.Secondary
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                }
                Button {
                    id: bluetoothButton
                    topIcon: "󰂯"
                    text: "Bluetooth"
                    severity: Button.Severity.Secondary
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                }
                Button {
                    id: airplaneModeButton
                    topIcon: "󰀝"
                    text: "Airplane"
                    severity: Button.Severity.Secondary
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                }

                Button {
                    id: darkModeButton
                    topIcon: Theme.isDarkMode ? "󰖙" : "󰖚"
                    text: Theme.isDarkMode ? "Dark theme" : "Light theme"
                    severity: Theme.isDarkMode ? Button.Severity.Primary : Button.Severity.Secondary
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                    onClicked: Theme.toggle()
                }
                Button {
                    id: nightModeButton
                    topIcon: "󱩌"
                    text: "Night mode"
                    severity: Button.Severity.Secondary
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                }
                Button {
                    id: doNotDisturbButton
                    topIcon: ""
                    text: "Caffeine"
                    severity: Button.Severity.Secondary
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                }
            }
        }
    }
}