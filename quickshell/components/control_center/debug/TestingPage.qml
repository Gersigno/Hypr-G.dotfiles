import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell
import QtCore as Core

import "../../../utils"
import qs.services
import "../../common/interactive"
import "../../common/interface"

Rectangle {
    id: page

    color: "transparent"
    clip: true

    BackgroundLayer {
        anchors.fill: parent
    }

    readonly property string home: Core.StandardPaths.standardLocations(Core.StandardPaths.HomeLocation)[0]
    readonly property string userName: home.split('/').pop().charAt(0).toUpperCase() + home.split('/').pop().slice(1)
    readonly property color textColor: Colors.on_surface_variant

    readonly property var toastVariants: [
        { label: "Show toast", message: "Hello world!", duration: 3000 },
        { label: "Show toast multi-lines", message: "Toast notification\nwith two lines", duration: 3000 },
        { label: "Show toast (icon)", message: "Toast with icon", duration: 4000, icon: Qt.resolvedUrl("../../../assets/default_face.png") },
        { label: "Show welcome notification", message: "Welcome back, " + page.userName + " !", duration: 6000, icon: page.home + "/.face.png" }
    ]

    readonly property var notificationVariants: [
        { label: "Simple", severity: Button.Severity.Primary, args: ["Simple notification", "This is a basic notification body."] },
        { label: "Low urgency", severity: Button.Severity.Secondary, args: ["Low urgency", "This notification has low urgency.", "-u", "low"] },
        { label: "Critical", severity: Button.Severity.Danger, args: ["Critical!", "Something went critically wrong.", "-u", "critical"] },
        { label: "With icon", severity: Button.Severity.Secondary, args: ["Icon notification", "This one has an app icon.", "-i", "dialog-information"] },
        { label: "Long body", severity: Button.Severity.Secondary, args: ["Long notification", "This is a much longer notification body to test how the popup handles wrapping and overflow with multiple lines of text."] }
    ]

    Flickable {
        anchors.fill: parent
        anchors.margins: 16
        contentHeight: testingColumn.implicitHeight
        clip: true

        ColumnLayout {
            id: testingColumn
            width: parent.width
            spacing: 12

            Button {
                text: "Force reload quickshell config"
                severity: Button.Severity.Warning
                onClicked: {
                    //notifProcess.sendNotif("Quickshell Debug", "Quickshell config reloaded successfully at " + new Date().toLocaleTimeString())
                    //ToastService.show("Config reloaded", 3000)
                    Quickshell.reload(true)
                }
            }
            Button {
                text: "Refetch hyprland config"
                severity: Button.Severity.Warning
                onClicked: {
                    HyprlandConfig.markRead()
                    ToastService.show("  Debug: Hyprland config reloaded", 3000)
                }
            }

            Text {
                text: "Debug settings"
                color: page.textColor
                font.pixelSize: 18
                font.bold: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: "Slow animations (x20)"
                    color: page.textColor
                    font.pixelSize: 14
                }

                Item {
                    Layout.fillWidth: true
                }

                Switch {
                    checked: Settings.debugSlowAnimations
                    onToggled: (value) => Settings.debugSlowAnimations = value
                }
            }

            Text {
                text: "Toast Service Testing"
                color: page.textColor
                font.pixelSize: 18
                font.bold: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Repeater {
                    model: page.toastVariants

                    delegate: Button {
                        text: modelData.label
                        severity: Button.Severity.Primary
                        onClicked: ToastService.show(modelData.message, modelData.duration, modelData.icon)
                    }
                }
            }

            Text {
                text: "System notifications testing"
                color: page.textColor
                font.pixelSize: 18
                font.bold: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Repeater {
                    model: page.notificationVariants

                    delegate: Button {
                        text: modelData.label
                        severity: modelData.severity
                        onClicked: notifProcess.sendNotif(modelData.args)
                    }
                }
            }

            Process {
                id: notifProcess

                function sendNotif(args) {
                    notifProcess.command = ["notify-send"].concat(args)
                    notifProcess.running = true
                }
            }
        }
    }
}
