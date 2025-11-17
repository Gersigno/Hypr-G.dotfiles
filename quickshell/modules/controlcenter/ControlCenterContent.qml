import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    property int controlCenterWidth: 400
    property int controlCenterPadding: 10
    property var globalNotifications: null

    Component.onCompleted: {
        console.log("[ControlCenterContent] Composant chargé")
        console.log("[ControlCenterContent] globalNotifications:", globalNotifications)
    }

    implicitHeight: contentColumn.implicitHeight
    implicitWidth: controlCenterWidth

    ColumnLayout {
        id: contentColumn
            anchors.fill: parent
            anchors.margins: controlCenterPadding
            spacing: controlCenterPadding

            // Section des contrôles (boutons + sliders)
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // Section boutons (rouge)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    color: Qt.rgba(0.85, 0.29, 0.31, 0.4) // red avec alpha
                    radius: 16
                    border.color: Qt.rgba(0.58, 0.56, 0.56, 0.4)
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
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            icon: "󰖩"
                            onClicked: console.log("WiFi toggled")
                        }

                        // Bluetooth
                        QuickToggle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            icon: "󰂯"
                            onClicked: console.log("Bluetooth toggled")
                        }

                        // Airplane Mode
                        QuickToggle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            icon: "󰀝"
                            onClicked: console.log("Airplane Mode toggled")
                        }

                        // Dark Mode
                        QuickToggle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            icon: "󰖔"
                            onClicked: console.log("Dark Mode toggled")
                        }
                    }
                }

                // Section sliders (vert)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    color: Qt.rgba(0.62, 0.85, 0.29, 0.4) // green avec alpha
                    radius: 16
                    border.color: Qt.rgba(0.58, 0.56, 0.56, 0.4)
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        // Brightness slider
                        SliderItem {
                            Layout.fillWidth: true
                            icon: "󰃠"
                            onSliderValueChanged: (val) => console.log("Brightness:", val)
                        }

                        // Volume slider
                        SliderItem {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            icon: "󰕾"
                            onSliderValueChanged: (val) => console.log("Volume:", val)
                        }
                    }
                }
            }

            // Section notifications (avec le système de notifications Quickshell)
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Qt.rgba(0.29, 0.57, 0.85, 0.4) // blue avec alpha
                radius: 16
                border.color: Qt.rgba(0.58, 0.56, 0.56, 0.4)
                border.width: 1

                NotificationList {
                    anchors.fill: parent
                    anchors.margins: 10
                    globalNotifications: root.globalNotifications
                }
            }
    }
}