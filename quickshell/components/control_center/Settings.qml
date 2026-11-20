import QtQuick
import Quickshell

import "../../utils"
import "../common/interface"
import "../common/interactive"
import qs.services
// Non utilisé directement : rend le dossier `settings/` visible au scanner de
// Quickshell, pour que ses sous-pages (chargées dynamiquement par Loader)
// soient surveillées et bénéficient du hot reload.
import "./settings" as SettingsPages

Item {
    id: root

    implicitWidth: 700
    implicitHeight: 500

    readonly property alias currentIndex: tabs.currentIndex

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
            tabs.currentIndex = 1
        } else if (page === "bluetooth") {
            tabs.currentIndex = 2
        } else if (page === "audio") {
            tabs.currentIndex = 3
        }
        Qt.callLater(() => {
            NavigationState.requestedSettingsPage = ""
        })
    }

    TabView {
        id: tabs
        anchors.fill: parent
        anchors.margins: 8

        orientation: TabView.Orientation.Vertical
        contentSpacing: 8
        contentMargin: 8

        baseUrl: Qt.resolvedUrl("settings")
        contentBackground: Component { BackgroundLayer {} }

        model: [
            { title: "System",    source: "SystemPage.qml" },
            { title: "Network",   source: "NetworkPage.qml" },
            { title: "Bluetooth", source: "BluetoothPage.qml" },
            { title: "Audio",     source: "AudioPage.qml" },
            { title: "Display",   source: "DisplayPage.qml" },
            { title: "Customize", source: "CustomizePage.qml" }
        ]
    }
}
