import QtQuick
import Quickshell
import QtCore as Core
import Quickshell.Io
import QtQuick.Layouts

import qs.services
import "../../../utils"
import "../../common/interface"
import "quicksettings"

Item {
    id: root

    // --- Confirmation via zenity ---
    property var pendingCommand: null

    function askConfirmation(title, message, okLabel, command) {
        if (zenityProcess.running)
            return
        pendingCommand = command
        zenityProcess.exec([
            "zenity", "--question",
            "--title", title,
            "--text", message,
            "--ok-label", okLabel,
            "--cancel-label", "Cancel",
            "--icon=dialog-question",
            "--width=340"
        ])
    }

    Process {
        id: zenityProcess
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0 && root.pendingCommand !== null)
                Quickshell.execDetached(root.pendingCommand)
            root.pendingCommand = null
        }
    }

    BackgroundLayer {
        id: background
        anchors.fill: parent
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4

        Rectangle {
            width: parent.width
            height: parent.height
            color: "red"
            opacity: 0.1
        }

        QSButton {
            id: shutdownButton
            topIcon: ""
            text: "Shutdown"
            severity: QSButton.Severity.Secondary//QSButton.Severity.Danger
            onClicked: {
                root.askConfirmation(
                    "Shutdown",
                    "Are you sure you want to shut down the system?\nUnsaved work may be lost.",
                    "Shutdown",
                    ["bash", "-c", "systemctl poweroff || loginctl poweroff"]
                )
            }
            onHover: {
                shutdownButton.severity = QSButton.Severity.Danger
            }
            onUnhover: {
                shutdownButton.severity = QSButton.Severity.Secondary
            }
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            Layout.fillHeight: true
        }
        QSButton {
            id: restartButton
            topIcon: ""
            text: "Restart"
            severity: QSButton.Severity.Secondary//QSButton.Severity.Warning
            onClicked: {
                root.askConfirmation(
                    "Restart",
                    "Are you sure you want to restart the system?\nUnsaved work may be lost.",
                    "Restart",
                    ["bash", "-c", "systemctl reboot || loginctl reboot"]
                )
            }
            onHover: {
                restartButton.severity = QSButton.Severity.Warning
            }
            onUnhover: {
                restartButton.severity = QSButton.Severity.Secondary
            }
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            Layout.fillHeight: true
        }
        QSButton {
            id: lockButton
            topIcon: ""
            text: "Lock"
            severity: QSButton.Severity.Secondary
            onClicked: {
                root.askConfirmation(
                    "Lock",
                    "Lock the session now?\nYou will need your password to unlock it.",
                    "Lock",
                    ["hyprlock"]
                )
            }
            onHover: {
                lockButton.severity = QSButton.Severity.Warning
            }
            onUnhover: {
                lockButton.severity = QSButton.Severity.Secondary
            }
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            Layout.fillHeight: true
        }
        /*QSButton {
            id: logOutButton
            topIcon: ""
            text: "Log Out"
            severity: QSButton.Severity.Secondary
            onClicked: {
                //todo
            }
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            Layout.fillHeight: true
        }*/
    }
}