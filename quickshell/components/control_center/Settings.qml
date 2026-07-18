import QtQuick
import Quickshell

import "../../config"
import "../../utils"
import "../common/interface"
import "../common/interactive"
import qs.services

Item {
    id: root

    implicitWidth: 700
    implicitHeight: 500

    readonly property color backgroundColor: Config.isOled ? "#000" : Colors.background
    readonly property color foregroundColor: Config.isOled ? "#fff" : Colors.on_background

    property int currentIndex: 0

    readonly property var pages: [
        { name: "System",     file: "settings/SystemPage.qml" },
        { name: "Network",    file: "settings/NetworkPage.qml" },
        { name: "Bluetooth",  file: "settings/BluetoothPage.qml" },
        { name: "Audio",      file: "settings/AudioPage.qml" },
        { name: "Display",    file: "settings/DisplayPage.qml" },
        { name: "Customize",  file: "settings/CustomizePage.qml" }
    ]

    Component.onCompleted: {
        handleNavigationRequest()
    }

    Connections {
        target: NavigationState
        function onRequestedSettingsPageChanged() {
            handleNavigationRequest()
        }
    }

    function handleNavigationRequest() {
        var page = NavigationState.requestedSettingsPage
        if (page === "network") {
            currentIndex = 1
        } else if (page === "bluetooth") {
            currentIndex = 2
        }
        NavigationState.requestedSettingsPage = ""
    }

    Item {
        anchors.fill: parent

        Row {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8

            Item {
                id: navBar
                width: 130
                height: parent.height

                Column {
                    spacing: 4
                    anchors.topMargin: 10

                    Repeater {
                        model: pages

                        delegate: Button {
                            width: navBar.width
                            text: modelData.name
                            severity: currentIndex === index ? Button.Severity.Primary : Button.Severity.Secondary
                            onClicked: currentIndex = index
                        }
                    }
                }
            }

            BackgroundLayer {
                height: parent.height
                width: parent.width - navBar.width - parent.spacing

                Loader {
                    anchors.fill: parent
                    anchors.margins: 8
                    source: pages[currentIndex].file
                }
            }
        }
    }
}
