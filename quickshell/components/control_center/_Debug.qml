import QtQuick
import Quickshell
import QtQuick.Layouts

import "../../config"
import "../../utils"
import qs.services
import "../common"

Item {
    id: root

    implicitWidth: 800
    implicitHeight: 600

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 0

        // --- Barre d'onglets ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 5
            
            Repeater {
                model: ["Components", "Color Scheme", "Testing"]
                
                /*Rectangle {
                    implicitWidth: 100
                    implicitHeight: 40
                    color: mainStack.currentIndex === index ? "#333" : "#111"
                    
                    Text {
                        anchors.centerIn: parent
                        font.family: Config.fontFamily
                        text: modelData
                        color: "white"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: mainStack.currentIndex = index
                    }
                    
                    // Petite barre d'accentuation sous l'onglet actif
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 2
                        color: "cyan"
                        visible: mainStack.currentIndex === index
                    }
                }*/
                Button {
                    text: modelData
                    severity: mainStack.currentIndex === index ? Button.Severity.Primary : Button.Severity.Secondary
                    onClicked: mainStack.currentIndex = index
                }
            }
        }

        StackLayout {
            id: mainStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: 0 

            //?Components
            Rectangle { 
                color: "transparent";
                Column {
                    spacing: 23
                    anchors.margins: 16
                    Text { 
                        text: "Buttons :"; 
                        color: "white"; 
                        font.pixelSize: 18; 
                        font.family: Config.fontFamily
                        font.bold: true;
                    }
                    Row {
                        spacing: 12
                        Column {
                            spacing: 8
                            Text {
                                text: "Default buttons";
                                color: Colors.on_surface_variant;
                                font.family: Config.fontFamily;
                                font.pixelSize: 12;
                            }
                            Button { 
                                text: "Primary button";
                                severity: Button.Severity.Primary;
                            }
                            Button { 
                                text: "Secondary button";
                                severity: Button.Severity.Secondary;
                            }
                            Button { 
                                text: "Warning button";
                                severity: Button.Severity.Warning;
                            }
                            Button { 
                                text: "Danger button";
                                severity: Button.Severity.Danger;
                            }
                        }
                        Column {
                            spacing: 8
                            Text {
                                text: "Disabled buttons";
                                color: Colors.on_surface_variant;
                                font.family: Config.fontFamily;
                                font.pixelSize: 12;
                            }
                            Button { 
                                text: "Primary button";
                                severity: Button.Severity.Primary;
                                disabled: true;
                            }
                            Button { 
                                text: "Secondary button";
                                severity: Button.Severity.Secondary;
                                disabled: true;
                            }
                            Button { 
                                text: "Warning button";
                                severity: Button.Severity.Warning;
                                disabled: true;
                            }
                            Button { 
                                text: "Danger button";
                                severity: Button.Severity.Danger;
                                disabled: true;
                            }
                        }
                        Column {
                            spacing: 8
                            Text {
                                text: "Full rounded buttons";
                                color: Colors.on_surface_variant;
                                font.family: Config.fontFamily;
                                font.pixelSize: 12;
                            }
                            Button { 
                                text: "Primary button";
                                severity: Button.Severity.Primary;
                                fullRounded: true;
                            }
                            Button { 
                                text: "Secondary button";
                                severity: Button.Severity.Secondary;
                                fullRounded: true;
                            }
                            Button { 
                                text: "Warning button";
                                severity: Button.Severity.Warning;
                                fullRounded: true;
                            }
                            Button { 
                                text: "Danger button";
                                severity: Button.Severity.Danger;
                                fullRounded: true;
                            }
                        }
                    }
                }
            }

            //?Color Scheme
            Rectangle {
                color: "#222"
                clip: true

                Flickable {
                    anchors.fill: parent
                    anchors.margins: 16
                    contentHeight: colorColumn.implicitHeight
                    clip: true

                    Column {
                        id: colorColumn
                        width: parent.width
                        spacing: 6

                        Repeater {
                            model: [
                                "background",        "error",                    "error_container",
                                "inverse_on_surface","inverse_primary",          "inverse_surface",
                                "on_background",     "on_error",                 "on_error_container",
                                "on_primary",        "on_primary_container",     "on_primary_fixed",
                                "on_primary_fixed_variant",
                                "on_secondary",      "on_secondary_container",   "on_secondary_fixed",
                                "on_secondary_fixed_variant",
                                "on_surface",        "on_surface_variant",
                                "on_tertiary",       "on_tertiary_container",    "on_tertiary_fixed",
                                "on_tertiary_fixed_variant",
                                "outline",           "outline_variant",
                                "primary",           "primary_container",        "primary_fixed",
                                "primary_fixed_dim",
                                "scrim",             "secondary",                "secondary_container",
                                "secondary_fixed",   "secondary_fixed_dim",      "shadow",
                                "source_color",      "surface",                  "surface_bright",
                                "surface_container", "surface_container_high",   "surface_container_highest",
                                "surface_container_low","surface_container_lowest","surface_dim",
                                "surface_tint",      "surface_variant",
                                "tertiary",          "tertiary_container",       "tertiary_fixed",
                                "tertiary_fixed_dim"
                            ]

                            Row {
                                width: colorColumn.width
                                spacing: 12
                                height: 28

                                Text {
                                    width: 250
                                    height: parent.height
                                    text: modelData
                                    color: Colors.on_surface_variant
                                    font.family: Config.fontFamily
                                    font.pixelSize: 12
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }

                                Rectangle {
                                    width: 180
                                    height: parent.height
                                    radius: 4
                                    color: Colors[modelData]

                                    Text {
                                        anchors.centerIn: parent
                                        text: Colors[modelData].toString().toUpperCase()
                                        font.family: Config.fontFamily
                                        font.pixelSize: 11
                                        color: {
                                            const c = Colors[modelData]
                                            return (0.299 * c.r + 0.587 * c.g + 0.114 * c.b) > 0.5 ? "#000000" : "#ffffff"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            //?Appearance
            Rectangle { 
                color: "transparent"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12

                    Button {
                        text: "Show toast"
                        severity: Button.Severity.Primary
                        onClicked: {
                            console.log("Requesting toast normal from debug page...")
                            ToastService.show("Hello world!", 3000)
                        }
                    }

                    Button {
                        text: "Show toast (short)"
                        severity: Button.Severity.Secondary
                        onClicked: {
                            console.log("Requesting short toast from debug page...")
                            ToastService.show("Short toast", 1000)
                        }
                    }

                    Button {
                        text: "Show toast multi-lines"
                        severity: Button.Severity.Secondary
                        onClicked: {
                            console.log("Requesting short toast from debug page...")
                            ToastService.show("Short toast\nallo", 1000)
                        }
                    }

                    Button {
                        text: "Show toast (icon)"
                        severity: Button.Severity.Warning
                        onClicked: {
                            console.log("Requesting warning toast from debug page...")
                            ToastService.show("Something went wrong", 4000, "../../assets/default_face.png")
                        }
                    }
                }
            }
        }
    }
} 