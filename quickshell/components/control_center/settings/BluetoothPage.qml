import QtQuick
import Quickshell

import qs.services
import "../../../utils"
import "../../../services"
import "../../common/interactive"
import "../../common/interface"

Item {
    id: root

    readonly property color foregroundColor: Colors.on_background
    readonly property color mutedColor: Settings.isOled ? "#aaa" : Colors.on_surface_variant
    readonly property color surfaceColor: Colors.surface_container_high
    readonly property color surfaceBorder: Colors.surface_variant
    readonly property string font: Settings.fontFamily

    function getDeviceIcon(device) {
        var ic = device.icon || ""
        if (ic === "audio-headset" || ic === "audio-headphones") return "󰋋"
        if (ic === "audio-speaker") return "󰋎"
        if (ic === "input-keyboard") return "󰋊"
        if (ic === "input-mouse" || ic === "input-tablet") return "󰌌"
        if (ic === "phone" || ic === "smartphone") return "󰂱"
        if (ic === "computer" || ic === "laptop") return "󰌢"
        if (ic === "printer") return "󰐪"
        if (ic === "camera") return "󰄀"
        if (ic === "video-display") return "󰍹"
        return "󰂯"
    }

    Flickable {
        anchors.fill: parent
        contentHeight: contentColumn.height + 16
        clip: true

        Column {
            id: contentColumn
            width: parent.width
            spacing: 10

            // ==============================
            // HEADER
            // ==============================
            Column {
                width: parent.width
                spacing: 8

                Column {
                    spacing: 8

                    Row {
                        spacing: 6
                        Text {
                            text: "󰂯"
                            width: 22
                            horizontalAlignment: Text.AlignHCenter
                            color: foregroundColor
                            font.pixelSize: 20
                            font.family: root.font
                            font.bold: true
                        }
                        Text {
                            text: "Bluetooth"
                            color: foregroundColor
                            font.pixelSize: 20
                            font.family: root.font
                            font.bold: true
                        }
                    }

                    Text {
                        text: "Bluetooth devices and settings"
                        color: foregroundColor
                        font.pixelSize: 13
                        font.family: root.font
                        opacity: 0.7
                    }
                }

                Item {
                    width: parent.width
                    height: 34

                    Item {
                        id: scanBtn
                        anchors.right: toggleSwitch.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: 36
                        height: 32
                        enabled: Bluetooth.enabled

                        readonly property color bg: Colors.surface_container_high
                        readonly property color fg: Colors.on_surface

                        Rectangle {
                            anchors.fill: parent
                            color: Qt.tint(scanBtn.bg, "#40000000")
                            radius: HyprlandConfig.radius
                            opacity: scanBtn.enabled ? 1 : 0.5

                            Rectangle {
                                anchors.fill: parent
                                anchors.bottomMargin: btnMouse.containsMouse ? 2 : 1
                                color: Qt.hsla(scanBtn.bg.hslHue, scanBtn.bg.hslSaturation, Math.min(scanBtn.bg.hslLightness + 0.1, 1.0), scanBtn.bg.a)
                                radius: parent.radius > 0 ? parent.radius - 1 : 0

                                Behavior on anchors.bottomMargin {
                                    NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    anchors.topMargin: 1
                                    color: btnMouse.containsMouse
                                        ? Qt.hsla(scanBtn.bg.hslHue, scanBtn.bg.hslSaturation, Math.min(scanBtn.bg.hslLightness + 0.05, 1.0), scanBtn.bg.a)
                                        : scanBtn.bg
                                    radius: parent.radius > 0 ? parent.radius - 1 : 0

                                    Behavior on color {
                                        ColorAnimation { duration: 150; easing.type: Easing.InOutQuad }
                                    }

                                    Text {
                                        id: scanIcon
                                        anchors.centerIn: parent
                                        text: ""
                                        font.pixelSize: 13
                                        font.family: root.font
                                        color: scanBtn.fg

                                        transform: Rotation {
                                            id: scanRotation
                                            origin.x: scanIcon.width / 2
                                            origin.y: scanIcon.height / 2
                                        }
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: btnMouse
                            anchors.fill: parent
                            hoverEnabled: scanBtn.enabled
                            cursorShape: scanBtn.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (scanBtn.enabled) {
                                    if (Bluetooth.discovering)
                                        Bluetooth.stopDiscovery()
                                    else
                                        Bluetooth.startDiscovery()
                                }
                            }
                        }
                    }

                    RotationAnimation {
                        target: scanRotation
                        property: "angle"
                        running: Bluetooth.discovering
                        from: 0; to: 360; duration: 800; loops: Animation.Infinite
                        direction: RotationAnimation.Clockwise
                    }

                    Switch {
                        id: toggleSwitch
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        checked: Bluetooth.enabled
                        onToggled: Bluetooth.toggleBluetooth()
                    }
                }
            }

            // ==============================
            // STATUS CARD
            // ==============================
            Rectangle {
                width: parent.width
                height: statusCol.height + 16
                radius: HyprlandConfig.radius
                color: surfaceColor
                border.color: surfaceBorder
                border.width: 1

                Column {
                    id: statusCol
                    x: 10
                    y: 8
                    width: parent.width - 20
                    spacing: 6

                    Row {
                        width: parent.width
                        spacing: 8

                        Text {
                            text: {
                                if (!Bluetooth.enabled) return "󰂲"
                                if (Bluetooth.connected) return "󰂱"
                                if (Bluetooth.discovering) return "󰥖"
                                return "󰂯"
                            }
                            color: {
                                if (!Bluetooth.enabled) return mutedColor
                                if (Bluetooth.connected) return Colors.primary
                                return foregroundColor
                            }
                            font.pixelSize: 24
                            font.family: root.font
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            spacing: 2
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: {
                                    if (!Bluetooth.available) return "No Bluetooth adapter"
                                    if (!Bluetooth.enabled) return "Bluetooth is off"
                                    if (Bluetooth.discovering) return "Scanning for devices..."
                                    if (Bluetooth.connected)
                                        return "Connected to " + (Bluetooth.firstActiveDevice?.name ?? "a device")
                                    if (Bluetooth.activeDeviceCount > 0)
                                        return Bluetooth.activeDeviceCount + " device(s) connected"
                                    return "Bluetooth is on"
                                }
                                color: foregroundColor
                                font.pixelSize: 12
                                font.family: root.font
                                font.bold: true
                                elide: Text.ElideRight
                                width: parent.parent.width - 40
                            }

                            Text {
                                text: {
                                    if (!Bluetooth.available || !Bluetooth.enabled) return ""
                                    if (Bluetooth.discovering) return "Tap refresh to stop scanning"
                                    var count = Bluetooth.friendlyDeviceList.length
                                    return count + " device" + (count !== 1 ? "s" : "") + " available"
                                }
                                visible: text.length > 0
                                color: mutedColor
                                font.pixelSize: 11
                                font.family: root.font
                                elide: Text.ElideRight
                                width: parent.parent.width - 40
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: 6
                        visible: Bluetooth.enabled

                        Button {
                            text: "Turn Bluetooth Off"
                            severity: Button.Severity.Secondary
                            implicitHeight: 28
                            onClicked: Bluetooth.toggleBluetooth()
                        }
                    }
                }
            }

            // ==============================
            // CONNECTED DEVICES
            // ==============================
            Item {
                width: parent.width
                height: visible ? 24 : 0
                visible: Bluetooth.connectedDevices.length > 0

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰂱  Connected"
                    color: foregroundColor
                    font.pixelSize: 13
                    font.family: root.font
                    font.bold: true
                }
                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: Bluetooth.connectedDevices.length + " device" + (Bluetooth.connectedDevices.length !== 1 ? "s" : "")
                    color: mutedColor
                    font.pixelSize: 11
                    font.family: root.font
                }
            }

            Repeater {
                model: Bluetooth.connectedDevices

                delegate: Rectangle {
                    required property var modelData
                    id: connectedRoot
                    readonly property var dev: modelData
                    width: parent.width
                    height: devRow.height + 12
                    radius: HyprlandConfig.radius
                    color: devMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"

                    Behavior on color { ColorAnimation { duration: 100; easing.type: Easing.InOutQuad } }

                    Row {
                        id: devRow
                        x: 10; y: 6; width: parent.width - 20; spacing: 6

                        Text {
                            text: "●"
                            color: Colors.primary
                            font.pixelSize: 10; font.family: root.font
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: root.getDeviceIcon(dev)
                            color: Colors.primary
                            font.pixelSize: 18; font.family: root.font
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Text {
                                text: (dev.name && dev.name.trim().length > 0) ? dev.name : (dev.address || "Unknown")
                                color: foregroundColor
                                font.pixelSize: 12; font.family: root.font; font.bold: true
                                elide: Text.ElideRight; width: Math.min(implicitWidth, devRow.width - 230)
                            }

                            Text {
                                text: {
                                    var parts = ["Connected"]
                                    if (dev.batteryAvailable && dev.battery >= 0)
                                        parts.push("Battery: " + Math.round(dev.battery * 100) + "%")
                                    if (dev.address) parts.push(dev.address)
                                    return parts.join("  ·  ")
                                }
                                color: mutedColor
                                font.pixelSize: 10; font.family: root.font
                                elide: Text.ElideRight; width: Math.min(implicitWidth, devRow.width - 230)
                            }
                        }

                        Button {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Disconnect"
                            implicitHeight: 26; implicitWidth: 90
                            severity: Button.Severity.Secondary
                            onClicked: { if (dev.disconnect) dev.disconnect() }
                        }

                        Button {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Forget"
                            implicitHeight: 26; implicitWidth: 60
                            severity: Button.Severity.Danger
                            onClicked: { if (dev.forget) dev.forget() }
                        }

                        Button {
                            anchors.verticalCenter: parent.verticalCenter
                            text: dev.trusted ? "Untrust" : "Trust"
                            implicitHeight: 26; implicitWidth: 56
                            severity: Button.Severity.Secondary
                            onClicked: {
                                if (dev.trusted)
                                    Bluetooth.untrustDevice(dev.address)
                                else
                                    Bluetooth.trustDevice(dev.address)
                            }
                        }
                    }

                    MouseArea {
                        id: devMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPressed: (mouse) => mouse.accepted = false
                    }
                }
            }

            // ==============================
            // PAIRED BUT NOT CONNECTED
            // ==============================
            Item {
                width: parent.width
                height: visible ? 24 : 0
                visible: Bluetooth.pairedButNotConnectedDevices.length > 0

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰇙  My Devices"
                    color: foregroundColor
                    font.pixelSize: 13
                    font.family: root.font
                    font.bold: true
                }
                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: Bluetooth.pairedButNotConnectedDevices.length + " device" + (Bluetooth.pairedButNotConnectedDevices.length !== 1 ? "s" : "")
                    color: mutedColor
                    font.pixelSize: 11
                    font.family: root.font
                }
            }

            Repeater {
                model: Bluetooth.pairedButNotConnectedDevices

                delegate: Rectangle {
                    required property var modelData
                    id: pairedRoot
                    readonly property var dev: modelData
                    width: parent.width
                    height: devRowP.height + 12
                    radius: HyprlandConfig.radius
                    color: devMouseP.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"

                    Behavior on color { ColorAnimation { duration: 100; easing.type: Easing.InOutQuad } }

                    Row {
                        id: devRowP
                        x: 10; y: 6; width: parent.width - 20; spacing: 6

                        Text {
                            text: "○"
                            color: mutedColor
                            font.pixelSize: 10; font.family: root.font
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: root.getDeviceIcon(dev)
                            color: foregroundColor
                            font.pixelSize: 18; font.family: root.font
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Text {
                                text: (dev.name && dev.name.trim().length > 0) ? dev.name : (dev.address || "Unknown")
                                color: foregroundColor
                                font.pixelSize: 12; font.family: root.font
                                elide: Text.ElideRight; width: Math.min(implicitWidth, devRowP.width - 230)
                            }

                            Text {
                                text: {
                                    var parts = ["Paired"]
                                    if (dev.batteryAvailable && dev.battery >= 0)
                                        parts.push("Battery: " + Math.round(dev.battery * 100) + "%")
                                    if (dev.address) parts.push(dev.address)
                                    return parts.join("  ·  ")
                                }
                                color: mutedColor
                                font.pixelSize: 10; font.family: root.font
                                elide: Text.ElideRight; width: Math.min(implicitWidth, devRowP.width - 230)
                            }
                        }

                        Button {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Connect"
                            implicitHeight: 26; implicitWidth: 76
                            severity: Button.Severity.Primary
                            onClicked: { if (dev.connect) dev.connect() }
                        }

                        Button {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Forget"
                            implicitHeight: 26; implicitWidth: 60
                            severity: Button.Severity.Danger
                            onClicked: { if (dev.forget) dev.forget() }
                        }

                        Button {
                            anchors.verticalCenter: parent.verticalCenter
                            text: dev.trusted ? "Untrust" : "Trust"
                            implicitHeight: 26; implicitWidth: 56
                            severity: Button.Severity.Secondary
                            onClicked: {
                                if (dev.trusted)
                                    Bluetooth.untrustDevice(dev.address)
                                else
                                    Bluetooth.trustDevice(dev.address)
                            }
                        }
                    }

                        MouseArea {
                        id: devMouseP
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPressed: (mouse) => mouse.accepted = false
                    }
                }
            }

            // ==============================
            // AVAILABLE (UNPAIRED) DEVICES
            // ==============================
            Item {
                width: parent.width
                height: visible ? 24 : 0
                visible: Bluetooth.unpairedDevices.length > 0

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰇙  Available Devices"
                    color: foregroundColor
                    font.pixelSize: 13
                    font.family: root.font
                    font.bold: true
                }
                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: Bluetooth.unpairedDevices.length + " device" + (Bluetooth.unpairedDevices.length !== 1 ? "s" : "")
                    color: mutedColor
                    font.pixelSize: 11
                    font.family: root.font
                }
            }

            Repeater {
                model: Bluetooth.unpairedDevices

                delegate: Rectangle {
                    required property var modelData
                    id: unpairedRoot
                    readonly property var dev: modelData
                    width: parent.width
                    height: devRowU.height + 12
                    radius: HyprlandConfig.radius
                    color: devMouseU.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"

                    Behavior on color { ColorAnimation { duration: 100; easing.type: Easing.InOutQuad } }

                    Row {
                        id: devRowU
                        x: 10; y: 6; width: parent.width - 20; spacing: 6

                        Text {
                            text: "○"
                            color: mutedColor
                            font.pixelSize: 10; font.family: root.font
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: root.getDeviceIcon(dev)
                            color: foregroundColor
                            font.pixelSize: 18; font.family: root.font
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Text {
                                text: (dev.name && dev.name.trim().length > 0) ? dev.name : (dev.address || "Unknown")
                                color: foregroundColor
                                font.pixelSize: 12; font.family: root.font
                                elide: Text.ElideRight; width: Math.min(implicitWidth, devRowU.width - 230)
                            }

                            Text {
                                text: {
                                    var parts = []
                                    if (dev.pairing) parts.push("Pairing...")
                                    if (dev.address) parts.push(dev.address)
                                    return parts.join("  ·  ")
                                }
                                color: mutedColor
                                font.pixelSize: 10; font.family: root.font
                                elide: Text.ElideRight; width: Math.min(implicitWidth, devRowU.width - 230)
                            }
                        }

                        Button {
                            anchors.verticalCenter: parent.verticalCenter
                            text: dev.pairing ? "Pairing..." : "Pair"
                            implicitHeight: 26; implicitWidth: 70
                            severity: Button.Severity.Primary
                            disabled: dev.pairing
                            onClicked: {
                                console.log("[BT] Pair clicked – name:", dev.name, "address:", dev.address, "type:", typeof dev, "hasPair:", typeof dev.pair)
                                if (typeof dev.pair === "function") {
                                    try {
                                        dev.pair()
                                        console.log("[BT] pair() called successfully")
                                    } catch (e) {
                                        console.log("[BT] pair() threw:", e)
                                    }
                                } else {
                                    console.log("[BT] pair() not available, trying adapter lookup...")
                                    var all = Bluetooth.devices.values
                                    for (var i = 0; i < all.length; i++) {
                                        if (all[i].address === dev.address || all[i].name === dev.name) {
                                            console.log("[BT] found match at index", i, "hasPair:", typeof all[i].pair)
                                            if (typeof all[i].pair === "function") {
                                                all[i].pair()
                                                console.log("[BT] adapter lookup pair() called")
                                            }
                                            break
                                        }
                                    }
                                }
                            }
                        }

                        Button {
                            anchors.verticalCenter: parent.verticalCenter
                            text: dev.trusted ? "Untrust" : "Trust"
                            implicitHeight: 26; implicitWidth: 56
                            severity: Button.Severity.Secondary
                            onClicked: {
                                if (dev.trusted)
                                    Bluetooth.untrustDevice(dev.address)
                                else
                                    Bluetooth.trustDevice(dev.address)
                            }
                        }
                    }

                    MouseArea {
                        id: devMouseU
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPressed: (mouse) => mouse.accepted = false
                    }
                }
            }

            // ==============================
            // EMPTY / OFF STATES
            // ==============================
            Rectangle {
                width: parent.width; height: 60; radius: HyprlandConfig.radius
                color: surfaceColor; border.color: surfaceBorder; border.width: 1
                visible: Bluetooth.enabled && Bluetooth.friendlyDeviceList.length === 0

                Column {
                    anchors.centerIn: parent; spacing: 4
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Bluetooth.discovering ? "󰥖  Scanning..." : "󰂲  No devices found"
                        color: mutedColor; font.pixelSize: 12; font.family: root.font
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Bluetooth.discovering ? "Waiting for nearby devices..." : "Click the scan button to discover devices"
                        color: mutedColor; font.pixelSize: 10; font.family: root.font; opacity: 0.7
                    }
                }
            }

            Rectangle {
                width: parent.width; height: 60; radius: HyprlandConfig.radius
                color: surfaceColor; border.color: surfaceBorder; border.width: 1
                visible: !Bluetooth.available || !Bluetooth.enabled

                Column {
                    anchors.centerIn: parent; spacing: 4
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Bluetooth.available ? "󰂲  Bluetooth is turned off" : "󰂲  No Bluetooth adapter"
                        color: mutedColor; font.pixelSize: 12; font.family: root.font
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Bluetooth.available ? "Turn on Bluetooth to see available devices" : "Check your system hardware"
                        color: mutedColor; font.pixelSize: 10; font.family: root.font; opacity: 0.7
                    }
                }
            }

            // ==============================
            // DIVIDER
            // ==============================
            Rectangle {
                width: parent.width; height: 1; color: surfaceBorder; visible: Bluetooth.enabled
            }

            // ==============================
            // ADVANCED
            // ==============================
            /*Text {
                text: "󰑨  Advanced Bluetooth Settings"
                color: foregroundColor; font.pixelSize: 13; font.family: root.font; font.bold: true
            }

            Rectangle {
                width: parent.width; height: 40; radius: HyprlandConfig.radius
                color: a1.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                Behavior on color { ColorAnimation { duration: 100; easing.type: Easing.InOutQuad } }
                Text { x: 8; anchors.verticalCenter: parent.verticalCenter; text: "󰖂"; color: foregroundColor; font.pixelSize: 16; font.family: root.font }
                Column { x: 32; anchors.verticalCenter: parent.verticalCenter; spacing: 1
                    Text { text: "Adapter Settings"; color: foregroundColor; font.pixelSize: 12; font.family: root.font }
                    Text { text: "Name, discoverability, pairing mode"; color: mutedColor; font.pixelSize: 10; font.family: root.font }
                }
                Text { anchors.right: parent.right; anchors.rightMargin: 8; anchors.verticalCenter: parent.verticalCenter; text: ">"; color: mutedColor; font.pixelSize: 14; font.family: root.font }
                MouseArea { id: a1; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Quickshell.execDetached(["bluetoothctl"]) }
            }

            Rectangle {
                width: parent.width; height: 40; radius: HyprlandConfig.radius
                color: a2.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                Behavior on color { ColorAnimation { duration: 100; easing.type: Easing.InOutQuad } }
                Text { x: 8; anchors.verticalCenter: parent.verticalCenter; text: "󰅟"; color: Colors.error; font.pixelSize: 16; font.family: root.font }
                Column { x: 32; anchors.verticalCenter: parent.verticalCenter; spacing: 1
                    Text { text: "Reset Bluetooth"; color: Colors.error; font.pixelSize: 12; font.family: root.font }
                    Text { text: "Forget all paired devices"; color: mutedColor; font.pixelSize: 10; font.family: root.font }
                }
                MouseArea { id: a2; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: {
                    for (var i = 0; i < Bluetooth.friendlyDeviceList.length; i++) {
                        var d = Bluetooth.friendlyDeviceList[i]
                        if (d && d.forget) d.forget()
                    }
                }}
            }

            Item { width: 1; height: 16 }*/
        }
    }
}
