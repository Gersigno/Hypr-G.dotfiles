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
import "quicksettings"

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
            Item {
                property bool isOverlayHost: true
                width: parent.width
                implicitHeight: quickSettingsGrid.implicitHeight

                GridLayout {
                    id: quickSettingsGrid
                    width: parent.width
                    columns: 3
                    rowSpacing: 4

                    QSButton {
                        id: wifiButton
                        topIcon: Network.wifiEnabled ? "" : "󰤮"
                        text: "Wifi"
                        severity: Network.wifiEnabled ? QSButton.Severity.Primary : QSButton.Severity.Secondary
                        expandIcon: ""
                        overrideAction: () => NavigationState.requestedSettingsPage = "network"
                        onClicked: Network.toggleWifi()
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        Layout.fillHeight: true
                    }
                    QSButton {
                        id: bluetoothButton
                        topIcon: Bluetooth.connected ? "󰂱" : (Bluetooth.enabled ? "󰂯" : "󰂲")
                        text: "Bluetooth"
                        severity: Bluetooth.enabled ? QSButton.Severity.Primary : QSButton.Severity.Secondary
                        expandIcon: ""
                        overrideAction: () => NavigationState.requestedSettingsPage = "bluetooth"
                        onClicked: Bluetooth.toggleBluetooth()
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        Layout.fillHeight: true
                    }
                    QSButton {
                        id: airplaneModeButton
                        topIcon: "󰀝"
                        text: "Airplane"
                        severity: QSButton.Severity.Secondary
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        Layout.fillHeight: true
                    }
                    QSButton {
                        id: darkModeButton
                        topIcon: Theme.isDarkMode ? "󰖙" : "󰖚"
                        text: "Dark theme" //Theme.isDarkMode ? "Dark theme" : "Light theme"
                        severity: Theme.isDarkMode ? QSButton.Severity.Primary : QSButton.Severity.Secondary
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        onClicked: Theme.toggle()
                    }
                    QSButton {
                        id: nightModeButton
                        topIcon: "󱩌"
                        text: "Night mode"
                        severity: QSButton.Severity.Secondary
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                    }
                    QSButton {
                        id: oledButton
                        topIcon: "󰌫"
                        text: "Oled mode"
                        severity: QSButton.Severity.Secondary
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                    }
                    QSButton {
                        id: batterySaverButton
                        topIcon: "󰊗"
                        text: "Performance"
                        severity: QSButton.Severity.Secondary
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                    }
                    QSButton {
                        id: screenshotButton
                        topIcon: "󱣴"
                        text: "Screenshot"
                        //description: "Connected"
                        severity: QSButton.Severity.Secondary
                        options: ["Section", "Window", "Screen"]
                        //onOptionSelected: (opt) => print("Pair with", opt)
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        Layout.fillHeight: true
                    }
                    QSButton {
                        id: screenrecordButton
                        topIcon: "󰑊"
                        text: "Record"
                        //description: "Connected"
                        severity: QSButton.Severity.Secondary
                        //options: ["Section", "Window", "Screen"]
                        //onOptionSelected: (opt) => print("Pair with", opt)
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        Layout.fillHeight: true
                    }
                    QSButton {
                        id: doNotDisturbButton
                        topIcon: ""
                        text: "Caffeine"
                        severity: QSButton.Severity.Secondary
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                    }
                }
            }
        }
    }
}