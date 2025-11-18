import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../../utils/" as Utils
import "../common/"

Item {
    id: root
    property int controlCenterWidth: 340
    property int controlCenterPadding: 10
    property bool advancerSettingsOpened: false
    property bool isDarkMode: true  // default to dark

    FileView {
        id: themeFile
        path: "/home/gersigno/.config/hypr/hypr-g/hyprland/env.conf"
        onTextChanged: readTheme()
    }

    function readTheme() {
        var lines = themeFile.text().split('\n');
        for (var i = 0; i < lines.length; i++) {
            if (lines[i].startsWith("env = THEME_MODE")) {
                var mode = lines[i].split(',')[1];
                isDarkMode = (mode === "dark");
                break;
            }
        }
    }

    Component.onCompleted: {
        console.log("[ControlCenterContent] Component loaded")
        readTheme()
    }

    implicitHeight: contentColumn.implicitHeight
    implicitWidth: controlCenterWidth

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: controlCenterPadding
        spacing: controlCenterPadding

        // Controls section
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Buttons section
            Rectangle {
                id: buttonsRectangle
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                color: Utils.Colors.background
                radius: 16
                border.color: Utils.Colors.on_tertiary
                border.width: 1

                GridLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    columns: 2
                    rows: 2
                    columnSpacing: 10
                    rowSpacing: 10

                    // WiFi
                    QuickToggle {
                        visible: !advancerSettingsOpened
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        icon: "󰖩"
                        ToolTip.text: "Network"
                        onClicked: console.log("WiFi toggled")
                    }

                    // Bluetooth
                    QuickToggle {
                        visible: !advancerSettingsOpened
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        icon: "󰂯"
                        ToolTip.text: "Bluetooth"
                        onClicked: console.log("Bluetooth toggled")
                    }

                    // Dark Mode
                    QuickToggle {
                        visible: !advancerSettingsOpened
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        checked: root.isDarkMode
                        icon: root.isDarkMode ? "󰖔" : "󰖙"
                        autoToggle: false
                        ToolTip.text: "Light / Dark Mode"
                        onClicked: {
                            root.isDarkMode = !root.isDarkMode
                            Hyprland.dispatch("exec ~/.config/hypr/hypr-g/scripts/toggle-theme.sh")
                        }
                    }                

                    //---Advanced settings---  
                    
                    // Advanced1 (dans layout quand ouvert)
                    QuickToggle {
                        visible: advancerSettingsOpened
                        opacity: visible ? 1 : 0
                        scale: visible ? 1 : 0
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        icon: "󰀝"
                        ToolTip.text: "Airplane Mode"
                        onClicked: console.log("Airplane Mode toggled")

                        Behavior on opacity {
                            NumberAnimation { duration: 300; easing.bezierCurve: [0.18, 0.95, 0.2, 1.08] }
                        }
                        Behavior on scale {
                            NumberAnimation { duration: 300; easing.bezierCurve: [0.18, 0.95, 0.2, 1.08] }
                        }
                    }

                    // Advanced2 (dans layout quand ouvert)
                    QuickToggle {
                        visible: advancerSettingsOpened
                        opacity: visible ? 1 : 0
                        scale: visible ? 1 : 0
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        icon: "󱈏"
                        ToolTip.text: "Low Power Mode"
                        onClicked: console.log("Low power mode toggled")

                        Behavior on opacity {
                            NumberAnimation { duration: 300; easing.bezierCurve: [0.18, 0.95, 0.2, 1.08] }
                        }
                        Behavior on scale {
                            NumberAnimation { duration: 300; easing.bezierCurve: [0.18, 0.95, 0.2, 1.08] }
                        }
                    }

                    // Advanced3 (dans layout quand ouvert)
                    QuickToggle {
                        visible: advancerSettingsOpened
                        opacity: visible ? 1 : 0
                        scale: visible ? 1 : 0
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        icon: "C"
                        ToolTip.text: "TBD"
                        onClicked: console.log("Advanced3 toggled")

                        Behavior on opacity {
                            NumberAnimation { duration: 300; easing.bezierCurve: [0.18, 0.95, 0.2, 1.08] }
                        }
                        Behavior on scale {
                            NumberAnimation { duration: 300; easing.bezierCurve: [0.18, 0.95, 0.2, 1.08] }
                        }
                    }

                    // Advanced Settings
                    QuickToggle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        icon: advancerSettingsOpened ? "-" : "+"
                        ToolTip.text: "Advanced settings"
                        onClicked: advancerSettingsOpened = !advancerSettingsOpened
                    }
                }
            }

            // Sliders section
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                color: Utils.Colors.background
                radius: 16
                border.color: Utils.Colors.on_tertiary
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    // Brightness slider
                    SliderItem {
                        Layout.fillWidth: true
                        icon: "󰃠"
                        min: 0
                        max: 1
                        onSliderValueChanged: (val) => console.log("Brightness:", val)
                    }

                    // Volume slider
                    SliderItem {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        icon: "󰕾"
                        min: 0
                        max: 1
                        onSliderValueChanged: (val) => console.log("Volume:", val)
                    }
                }
            }
        }

        //Medias controller section
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            color: Utils.Colors.background
            radius: 16
            border.color: Utils.Colors.on_tertiary
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Text {
                    text: "TODO: Media controls"
                    color: "white"
                }
            }
        }

        // Notifications section 
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 180
            color: Utils.Colors.background
            radius: 16
            border.color: Utils.Colors.on_tertiary
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Text {
                    text: "TODO: Notifications list"
                    color: "white"
                }
            }
        }
    }
}