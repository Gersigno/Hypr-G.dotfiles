import qs.services
import QtCore
import QtQuick
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import QtQuick.Effects
import "../.." 
import "../common" 

Item {
    id: root
    anchors.fill: parent
    width: parent.width

    property real animProgress: 0.0
    property real animDuration: 250
    property bool isDarkMode: true

    enabled: animProgress > 20

    readonly property string userName: home.split('/').pop().charAt(0).toUpperCase() + home.split('/').pop().slice(1)

    readonly property real profilePictureSize: 50
    readonly property string home: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]

    Column {
        id: mainColumn
        anchors.fill: parent
        spacing: (GlobalStates.gapsOut * 2)

        opacity: animationProgress / 100
        layer.enabled: true
        layer.effect: MultiEffect {
            source: mainColumn
            anchors.fill: mainColumn
            blurEnabled: true
            blur: 1 - (animationProgress / 100)
        }

        // Top section
        Item {
            width: parent.width
            height: profilePictureSize

            //Profile picture
            Rectangle {
                id: profilePicture
                width: profilePictureSize
                height: profilePictureSize
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                radius: GlobalStates.cornerRadius
                clip: true
                /*Rectangle {
                    anchors.fill: parent
                    color: "yellow"
                }*/
                Image {
                    anchors.fill: parent
                    source: home + "/.face.png"
                    fillMode: Image.PreserveAspectCrop
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: profilePictureSize
                            height: profilePictureSize
                            radius: GlobalStates.cornerRadius
                        }
                    }
                    onStatusChanged: {
                        if (status == Image.Error) {
                            source = home + "/.config/quickshell/assets/default_face.png"
                        }
                    }
                    Component.onCompleted: {
                        console.log("GlobalStates.cornerRadius: ", GlobalStates.cornerRadius);
                    }
                }
            }

            //User infos
            Column {
                id: userInfoColumn
                anchors.left: profilePicture.right
                anchors.leftMargin: 4
                anchors.right: powerMenu.left
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    text: userName.charAt(0).toUpperCase() + userName.slice(1)
                    font.pixelSize: 16
                    font.family: "SF Pro Display"
                    font.bold: true
                    color: "white"
                }
                Text {
                    id: uptimeText
                    text: "Up time: "
                    font.pixelSize: 13
                    font.family: "SF Pro Display"
                    color: "lightgray"

                    function formatUptime(seconds) {
                        let h = Math.floor(seconds / 3600);
                        let m = Math.floor((seconds % 3600) / 60);
                        return h.toString().padStart(2, '0') + "h " + 
                            m.toString().padStart(2, '0') + "m";
                    }

                    Process {
                        id: uptimeProcess
                        command: ["cat", "/proc/uptime"]
                        running: true
                        stdout: SplitParser {
                            onRead: (data) => {
                                // data contient la ligne de /proc/uptime
                                const uptimeSeconds = parseFloat(data.split(" ")[0]);
                                uptimeText.text = "Uptime: " + uptimeText.formatUptime(uptimeSeconds);
                            }
                        }
                    }

                    // On rafraîchit toutes les minutes
                    Timer {
                        interval: 60000
                        running: true
                        repeat: true
                        triggeredOnStart: true
                        onTriggered: uptimeProcess.start()
                    }
                }
            }

            //Power menu
            Row {
                id: powerMenu
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                property bool expanded: false

                // Lock button
                Rectangle {
                    width: powerMenu.expanded ? 26 : 0
                    height: 26
                    color: "white"
                    radius: 50
                    opacity: powerMenu.expanded ? 1 : 0
                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.pixelSize: 14
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: console.log("Lock clicked")
                    }
                    Behavior on width { 
                        NumberAnimation { 
                            duration: animDuration 
                            easing.type: Easing.InOutQuint
                        } 
                    }
                    Behavior on opacity { 
                        NumberAnimation { 
                            duration: animDuration 
                            easing.type: Easing.InOutQuint
                        } 
                    }
                }

                // Logout button
                Rectangle {
                    width: powerMenu.expanded ? 26 : 0
                    height: 26
                    color: "white"
                    radius: 50
                    opacity: powerMenu.expanded ? 1 : 0
                    Text {
                        anchors.centerIn: parent
                        text: "󰍂"
                        color: "black"
                        font.pixelSize: 14
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: console.log("Logout clicked")
                    }
                    Behavior on width { 
                        NumberAnimation { 
                            duration: animDuration 
                            easing.type: Easing.InOutQuint
                        }
                    }
                    Behavior on opacity { 
                        NumberAnimation { 
                            duration: animDuration 
                            easing.type: Easing.InOutQuint
                        }
                    }
                }

                // Restart button
                Rectangle {
                    width: powerMenu.expanded ? 26 : 0
                    height: 26
                    color: "white"
                    radius: 50
                    opacity: powerMenu.expanded ? 1 : 0
                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.pixelSize: 14
                        color: "black"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: console.log("Restart clicked")
                    }
                    Behavior on width { 
                        NumberAnimation { 
                            duration: animDuration
                            easing.type: Easing.InOutQuint 
                        } 
                    }
                    Behavior on opacity { 
                        NumberAnimation { 
                            duration: animDuration
                            easing.type: Easing.InOutQuint 
                        } 
                    }
                }

                // Shutdown button
                Rectangle {
                    width: powerMenu.expanded ? 26 : 0
                    height: 26
                    color: "white"
                    radius: 50
                    opacity: powerMenu.expanded ? 1 : 0
                    Text {
                        anchors.centerIn: parent
                        text: "⏻"
                        font.pixelSize: 14
                        color: "black"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: console.log("Shutdown clicked")
                    }
                    Behavior on width { 
                        NumberAnimation { 
                            duration: animDuration 
                            easing.type: Easing.InOutQuint 
                        } 
                    }
                    Behavior on opacity { 
                        NumberAnimation { 
                            duration: animDuration 
                            easing.type: Easing.InOutQuint 
                        } 
                    }
                }

                // Menu toggle button
                Rectangle {
                    width: 26
                    height: 26
                    color: powerMenu.expanded ? "gray" : "white"
                    radius: 50
                    Text {
                        id: toggleIcon
                        anchors.centerIn: parent
                        text: powerMenu.expanded ? "×" : "⏻"
                        font.pixelSize: 14
                        color: "black"
                        transform: 
                        Rotation {
                            origin.x: toggleIcon.width / 2
                            origin.y: toggleIcon.height / 2
                            angle: powerMenu.expanded ? 180 : 0
                            Behavior on angle {
                                NumberAnimation {
                                    duration: root.animDuration
                                    easing.type: Easing.InOutQuint
                                }
                            }
                        }
                        Scale {
                            origin.x: toggleIcon.width / 2
                            origin.y: toggleIcon.height / 2
                            xScale: 1.0
                            yScale: 1.0
                            Behavior on xScale {
                                NumberAnimation {
                                    duration: root.animDuration
                                    easing.type: Easing.InOutQuint
                                }
                            }
                            Behavior on yScale {
                                NumberAnimation {
                                    duration: root.animDuration
                                    easing.type: Easing.InOutQuint
                                }
                            }
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: root.animDuration
                            easing.type: Easing.InOutQuint
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            powerMenu.expanded = !powerMenu.expanded
                            toggleIcon.transform[1].xScale = 0
                            toggleIcon.transform[1].yScale = 0
                        }
                    }
                }
            }
        }

        Column {
            width: parent.width
            spacing: GlobalStates.gapsOut

            // Network and bluetooth toggles
            Item {
                width: parent.width
                height: 32

                Row {
                    anchors.fill: parent
                    spacing: 8

                    // WiFi toggle
                    DetailedToggle {
                        id: wifiToggle
                        active: Network.wifi                    
                        useArrow: true                    
                        icon: Network.wifi ? "󰤨" : "󰤭"
                        text: Network.wifi ? (Network.networkName || "Connected") : (Network.wifiEnabled ? "Connecting..." : "WiFi Off")
                        onClicked: console.log("WiFi menu opened")
                        width: parent.width / 2 - GlobalStates.gapsOut / 2
                        options: Network.wifiScanning ? 
                        [{text: "Loading...", icon: "󰇚", action: function() {}}] : 
                        (Network.friendlyWifiNetworks.length > 0 ? 
                            Network.friendlyWifiNetworks.map(function(n) { return {
                                text: n.ssid,
                                icon: n.active ? "" : n.strength > 75 ? "󰤨" : n.strength > 50 ? "󰤥" : n.strength > 25 ? "󰤢" : "󰤟",
                                action: function() { Network.connectToWifiNetwork(n) }
                            }}) : 
                            [{text: "No networks found", icon: "󰤮", action: function() {}}])
                    }

                    DetailedToggle {
                        active: Bluetooth.enabled                    
                        useArrow: true                    
                        icon: {
                            if (!Bluetooth.available) return "󰂲";
                            if (Bluetooth.connected) return "󰂱";
                            if (Bluetooth.enabled) return "󰂯";
                            return "󰂲";
                        }
                        text: Bluetooth.connected ? "Connected" : (Bluetooth.enabled ? "On" : "Bluetooth Off")
                        width: parent.width / 2 - GlobalStates.gapsOut / 2
                        options: Bluetooth.friendlyDeviceList.length > 0 ? Bluetooth.friendlyDeviceList.map(function(d) { 
                            return {
                                text: d.name + (d.connected ? " (Connected)" : ""),
                                icon: d.connected ? "󰂱" : "󰂯",
                                action: function() { if (d.connected) { d.disconnect() } else { d.connect() } }
                            }}) : 
                            [{text: "No devices found", icon: "󰂲", action: function() {}}]
                        onClicked: console.log("Bluetooth menu opened")
                    }
                }
            }

            //Dnd and light mode toggles
            Item {
                width: parent.width
                height: 32
                
                Row {
                    anchors.fill: parent
                    spacing: 8

                    DetailedToggle {
                        id: dndToggle
                        active: Notifications.dnd
                        useArrow: false
                        icon: Notifications.dnd ? "󰂛" : ""
                        text: "Do Not Disturb"
                        width: parent.width / 2 - GlobalStates.gapsOut / 2
                        onClicked: console.log("DND menu opened")
                    }

                    DetailedToggle {
                        id: airplaneModeToggle
                        active: false
                        useArrow: false
                        icon: "󰀝"
                        text: "Airplane Mode"
                        width: parent.width / 2 - GlobalStates.gapsOut / 2
                        onClicked: console.log("Airplane mode clicked")
                    }
                }
            }

            // Screenshot and ?
            Item {
                width: parent.width
                height: 32
                
                Row {
                    anchors.fill: parent
                    spacing: 8

                    DetailedToggle {
                        id: lightModeToggle
                        active: GlobalStates.lightMode
                        useArrow: false
                        icon: GlobalStates.lightMode ? "󰖙" : "󰖚"
                        text: "Light Mode"
                        width: parent.width / 2 - GlobalStates.gapsOut / 2
                        onClicked: console.log("Light mode toggled")
                    }

                    DetailedToggle {
                        id: screenshotToggle
                        active: false
                        useArrow: true
                        icon: ""
                        text: "Screenshot"
                        width: parent.width / 2 - GlobalStates.gapsOut / 2
                        options: [
                            {text: "Region", icon: "󰹑", command: ["hyprshot", "-m", "region"]},
                            {text: "Window", icon: "󰖯", command: ["hyprshot", "-m", "window"]},
                            {text: "Monitor", icon: "󰍹", command: ["hyprshot", "-m", "output"]},
                            {text: "Active Window", icon: "󰖲", command: ["hyprshot", "-m", "active"]}
                        ]
                        onClicked: console.log("Screenshot menu opened")
                    }
                }
            }
        }
    }
}