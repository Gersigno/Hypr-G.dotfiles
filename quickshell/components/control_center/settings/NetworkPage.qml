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

    property var passwordTarget: null
    property string passwordInputText: ""
    property bool showPassword: false
    property bool passwordDialogVisible: false

    property var deleteTarget: null
    property bool deleteDialogVisible: false
    property bool vpnDialogVisible: false
    property string vpnFilePath: ""
    property string vpnType: "openvpn"

    function getSignalIcon(strength) {
        if (strength > 75) return "󰤨"
        if (strength > 50) return "󰤥"
        if (strength > 25) return "󰤢"
        return "󰤟"
    }

    function getSignalLabel(strength) {
        if (strength > 75) return "Excellent"
        if (strength > 50) return "Good"
        if (strength > 25) return "Weak"
        return "Very weak"
    }

    function openPasswordDialog(ap) {
        passwordTarget = ap
        passwordInputText = ""
        showPassword = false
        passwordDialogVisible = true
    }

    function submitPassword() {
        if (passwordTarget && passwordInputText.length > 0) {
            Network.connectToNetworkWithPassword(passwordTarget, passwordInputText)
            passwordDialogVisible = false
            passwordTarget = null
        }
    }

    function connectionTypeIcon(type) {
        if (type.indexOf("wireless") !== -1) return "󰖩"
        if (type.indexOf("ethernet") !== -1) return "󰈀"
        if (type === "wireguard" || type.indexOf("vpn") !== -1) return "󰦝"
        if (type === "bridge") return "󰡄"
        return "󰛳"
    }

    function connectionTypeLabel(type) {
        if (type.indexOf("wireless") !== -1) return "Wi-Fi"
        if (type.indexOf("ethernet") !== -1) return "Ethernet"
        if (type === "wireguard") return "WireGuard"
        if (type.indexOf("vpn") !== -1) return "VPN"
        if (type === "bridge") return "Bridge"
        return type
    }

    function openVpnDialog() {
        vpnFilePath = ""
        vpnType = "openvpn"
        vpnDialogVisible = true
    }

    function submitVpnImport() {
        if (vpnFilePath.length === 0) return
        Network.importVpnConnection(vpnType, vpnFilePath)
        vpnDialogVisible = false
    }

    function openDeleteDialog(conn) {
        deleteTarget = conn
        deleteDialogVisible = true
    }

    function confirmDelete() {
        if (deleteTarget) Network.deleteConnection(deleteTarget.name)
        deleteDialogVisible = false
        deleteTarget = null
    }

    Flickable {
        anchors.fill: parent
        contentHeight: contentColumn.height + 16
        clip: true

        Column {
            id: contentColumn
            width: parent.width
            spacing: 10

            // ========== HEADER ==========
            Column {
                width: parent.width
                spacing: 8

                Column {
                    spacing: 8

                    Row {
                        spacing: 6
                        Text {
                            text: "󰖩"
                            width: 22
                            horizontalAlignment: Text.AlignHCenter
                            color: foregroundColor
                            font.pixelSize: 20
                            font.family: root.font
                            font.bold: true
                        }
                        Text {
                            text: "Network"
                            color: foregroundColor
                            font.pixelSize: 20
                            font.family: root.font
                            font.bold: true
                        }
                    }

                    Text {
                        text: "Wi-Fi and network configuration"
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
                        id: rescanBtn
                        anchors.right: toggleSwitch.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: 36
                        height: 32
                        enabled: !Network.wifiScanning && Network.wifiEnabled

                        readonly property color bg: Colors.surface_container_high
                        readonly property color fg: Colors.on_surface

                        Rectangle {
                            anchors.fill: parent
                            color: Qt.tint(rescanBtn.bg, "#40000000")
                            radius: HyprlandConfig.radius
                            opacity: rescanBtn.enabled ? 1 : 0.5

                            Rectangle {
                                anchors.fill: parent
                                anchors.bottomMargin: btnMouse.containsMouse ? 2 : 1
                                color: Qt.hsla(rescanBtn.bg.hslHue, rescanBtn.bg.hslSaturation, Math.min(rescanBtn.bg.hslLightness + 0.1, 1.0), rescanBtn.bg.a)
                                radius: parent.radius > 0 ? parent.radius - 1 : 0

                                Behavior on anchors.bottomMargin {
                                    NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    anchors.topMargin: 1
                                    color: btnMouse.containsMouse
                                        ? Qt.hsla(rescanBtn.bg.hslHue, rescanBtn.bg.hslSaturation, Math.min(rescanBtn.bg.hslLightness + 0.05, 1.0), rescanBtn.bg.a)
                                        : rescanBtn.bg
                                    radius: parent.radius > 0 ? parent.radius - 1 : 0

                                    Behavior on color {
                                        ColorAnimation { duration: 150; easing.type: Easing.InOutQuad }
                                    }

                                    Text {
                                        id: rescanIcon
                                        anchors.centerIn: parent
                                        text: ""
                                        font.pixelSize: 13
                                        font.family: root.font
                                        color: rescanBtn.fg

                                        transform: Rotation {
                                            id: rescanRotation
                                            origin.x: rescanIcon.width / 2
                                            origin.y: rescanIcon.height / 2
                                        }
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: btnMouse
                            anchors.fill: parent
                            hoverEnabled: rescanBtn.enabled
                            cursorShape: rescanBtn.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: { if (rescanBtn.enabled) Network.rescanWifi() }
                        }
                    }

                    RotationAnimation {
                        target: rescanRotation
                        property: "angle"
                        running: Network.wifiScanning
                        from: 0; to: 360; duration: 800; loops: Animation.Infinite
                        direction: RotationAnimation.Clockwise
                    }

                    Switch {
                        id: toggleSwitch
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        checked: Network.wifiEnabled
                        onToggled: Network.toggleWifi()
                    }
                }
            }

            // ========== STATUS CARD ==========
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
                            text: Network.ethernet
                                ? "󰈀"
                                : (Network.wifiEnabled
                                    ? (Network.wifiStatus === "connected"
                                        ? getSignalIcon(Network.networkStrength)
                                        : "󰤬")
                                    : "󰤮")
                            color: {
                                if (Network.ethernet || Network.wifiStatus === "connected") return Colors.primary
                                if (Network.wifiStatus === "connecting") return Colors.tertiary
                                return mutedColor
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
                                    if (Network.ethernet) return "Connected (Ethernet)"
                                    if (Network.wifiStatus === "connected") {
                                        if (Network.networkName) return "Connected to " + Network.networkName
                                        return "Connected"
                                    }
                                    if (Network.wifiStatus === "connecting") return "Connecting..."
                                    if (Network.wifiStatus === "limited") return "Connected (No Internet)"
                                    if (!Network.wifiEnabled) return "Wi-Fi is off"
                                    if (Network.wifiStatus === "disabled") return "Wi-Fi unavailable"
                                    return "Disconnected"
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
                                    if (Network.ethernet) return "Wired connection"
                                    if (Network.wifiStatus === "connected" && Network.networkStrength > 0)
                                        return "Signal: " + getSignalLabel(Network.networkStrength) + " (" + Network.networkStrength + "%)"
                                    if (Network.wifiScanning) return "Scanning..."
                                    return ""
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
                        visible: Network.wifiStatus === "connected" || Network.ethernet

                        /*Button {
                            text: Network.ethernet ? "  IP Config" : "󰌘  Disconnect"
                            severity: Button.Severity.Secondary
                            implicitHeight: 28
                            onClicked: {
                                if (Network.ethernet)
                                    Quickshell.execDetached(["nm-connection-editor"])
                                else
                                    Network.disconnectWifiNetwork()
                            }
                        }*/

                        Button {
                            text: "󰚃  Forget"
                            severity: Button.Severity.Danger
                            implicitHeight: 28
                            visible: !Network.ethernet && Network.networkName.length > 0
                            onClicked: Network.forgetNetwork(Network.networkName)
                        }

                        Button {
                            text: "󱛃  Portal"
                            severity: Button.Severity.Secondary
                            implicitHeight: 28
                            visible: Network.wifiStatus === "limited"
                            onClicked: Network.openPublicWifiPortal()
                        }
                    }
                }
            }

            // ========== AVAILABLE NETWORKS HEADER ==========
            Item {
                width: parent.width
                height: 24

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Available Networks"
                    color: foregroundColor
                    font.pixelSize: 13
                    font.family: root.font
                    font.bold: true
                }

                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: Network.wifiNetworks.length + " networks"
                    color: mutedColor
                    font.pixelSize: 11
                    font.family: root.font
                    visible: Network.wifiEnabled
                }
            }

            // ========== NETWORK LIST ==========
            Repeater {
                model: Network.friendlyWifiNetworks

                delegate: Rectangle {
                    id: netDelegate
                    required property var modelData
                    width: parent.width
                    height: netRow.height + 12
                    radius: HyprlandConfig.radius
                    color: netMouse.containsMouse
                        ? Qt.rgba(1, 1, 1, 0.05)
                        : (modelData.active
                            ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.1)
                            : "transparent")
                    border.color: modelData.active ? Colors.primary : "transparent"
                    border.width: modelData.active ? 1 : 0

                    Behavior on color {
                        ColorAnimation { duration: 100; easing.type: Easing.InOutQuad }
                    }

                    Row {
                        id: netRow
                        x: 10
                        y: 6
                        width: parent.width - 20
                        spacing: 6

                        Text {
                            text: modelData.active ? "●" : "○"
                            color: modelData.active ? Colors.primary : mutedColor
                            font.pixelSize: 10
                            font.family: root.font
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: getSignalIcon(modelData.strength)
                            color: modelData.active ? Colors.primary : foregroundColor
                            font.pixelSize: 18
                            font.family: root.font
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Text {
                                text: modelData.ssid
                                color: foregroundColor
                                font.pixelSize: 12
                                font.family: root.font
                                font.bold: modelData.active
                                elide: Text.ElideRight
                                width: Math.min(implicitWidth, netDelegate.width - 170)
                            }

                            Text {
                                text: {
                                    var parts = []
                                    if (modelData.active) parts.push("Connected")
                                    parts.push(getSignalLabel(modelData.strength) + " (" + modelData.strength + "%)")
                                    if (modelData.frequency > 4000) parts.push("5 GHz")
                                    else if (modelData.frequency > 2400) parts.push("2.4 GHz")
                                    return parts.join("  ·  ")
                                }
                                color: mutedColor
                                font.pixelSize: 10
                                font.family: root.font
                                elide: Text.ElideRight
                                width: Math.min(implicitWidth, netDelegate.width - 170)
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.security ? "" : ""
                            color: modelData.security ? Colors.tertiary : Colors.secondary
                            font.pixelSize: 12
                            font.family: root.font
                            visible: !modelData.active
                        }

                        Button {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.active
                                ? "Connected"
                                : (Network.wifiConnecting && Network.wifiConnectTarget === modelData
                                    ? "Connecting..."
                                    : "Connect")
                            implicitHeight: 26
                            implicitWidth: 82
                            severity: modelData.active ? Button.Severity.Secondary : Button.Severity.Primary
                            disabled: modelData.active || (Network.wifiConnecting && Network.wifiConnectTarget === modelData)
                            onClicked: {
                                if (modelData.active) return
                                if (modelData.security) {
                                    openPasswordDialog(modelData)
                                } else {
                                    Network.connectToWifiNetwork(modelData)
                                }
                            }
                        }

                        Button {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Forget"
                            implicitHeight: 26
                            implicitWidth: 60
                            severity: Button.Severity.Danger
                            visible: modelData.active
                            onClicked: Network.forgetNetwork(modelData.ssid)
                        }
                    }

                    MouseArea {
                        id: netMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.active) return
                            if (modelData.security) {
                                openPasswordDialog(modelData)
                            } else {
                                Network.connectToWifiNetwork(modelData)
                            }
                        }
                    }
                }
            }

            // ========== EMPTY STATES ==========
            Rectangle {
                width: parent.width
                height: 60
                radius: HyprlandConfig.radius
                color: surfaceColor
                border.color: surfaceBorder
                border.width: 1
                visible: Network.wifiEnabled && Network.wifiNetworks.length === 0

                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Network.wifiScanning ? "󰤬  Scanning..." : "󰤮  No networks found"
                        color: mutedColor
                        font.pixelSize: 12
                        font.family: root.font
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Click the refresh button to scan again"
                        color: mutedColor
                        font.pixelSize: 10
                        font.family: root.font
                        opacity: 0.7
                        visible: !Network.wifiScanning
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 60
                radius: HyprlandConfig.radius
                color: surfaceColor
                border.color: surfaceBorder
                border.width: 1
                visible: !Network.wifiEnabled

                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰤮  Wi-Fi is turned off"
                        color: mutedColor
                        font.pixelSize: 12
                        font.family: root.font
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Turn on Wi-Fi to see available networks"
                        color: mutedColor
                        font.pixelSize: 10
                        font.family: root.font
                        opacity: 0.7
                    }
                }
            }

            // ========== VPN HEADER ==========
            Item {
                width: parent.width
                height: 30

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "VPN Connections"
                    color: foregroundColor
                    font.pixelSize: 13
                    font.family: root.font
                    font.bold: true
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Network.vpnConnections.length + " saved"
                        color: mutedColor
                        font.pixelSize: 11
                        font.family: root.font
                    }

                    Button {
                        text: "󰐕  Add VPN"
                        severity: Button.Severity.Secondary
                        implicitHeight: 26
                        onClicked: root.openVpnDialog()
                    }
                }
            }

            // ========== VPN LIST ==========
            Repeater {
                model: Network.vpnConnections

                delegate: Rectangle {
                    id: connDelegate
                    required property var modelData
                    width: parent.width
                    height: connRow.height + 12
                    radius: HyprlandConfig.radius
                    color: connMouse.containsMouse
                        ? Qt.rgba(1, 1, 1, 0.05)
                        : (modelData.active
                            ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.1)
                            : "transparent")
                    border.color: modelData.active ? Colors.primary : "transparent"
                    border.width: modelData.active ? 1 : 0

                    Behavior on color {
                        ColorAnimation { duration: 100; easing.type: Easing.InOutQuad }
                    }

                    MouseArea {
                        id: connMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.active) Network.deactivateConnection(modelData.name)
                            else Network.activateConnection(modelData.name)
                        }
                    }

                    Row {
                        id: connRow
                        x: 10
                        y: 6
                        width: parent.width - 20
                        spacing: 6

                        Text {
                            text: modelData.active ? "●" : "○"
                            color: modelData.active ? Colors.primary : mutedColor
                            font.pixelSize: 10
                            font.family: root.font
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: root.connectionTypeIcon(modelData.type)
                            color: modelData.active ? Colors.primary : (modelData.vpn ? Colors.tertiary : foregroundColor)
                            font.pixelSize: 18
                            font.family: root.font
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1
                            width: connDelegate.width - 250

                            Text {
                                text: modelData.name
                                color: foregroundColor
                                font.pixelSize: 12
                                font.family: root.font
                                font.bold: modelData.active
                                elide: Text.ElideRight
                                width: parent.width
                            }

                            Text {
                                text: {
                                    var parts = [root.connectionTypeLabel(modelData.type)]
                                    if (modelData.device.length > 0) parts.push(modelData.device)
                                    parts.push(modelData.active ? "Connected" : "Disconnected")
                                    return parts.join("  ·  ")
                                }
                                color: mutedColor
                                font.pixelSize: 10
                                font.family: root.font
                                elide: Text.ElideRight
                                width: parent.width
                            }
                        }

                        Button {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.active ? "Disconnect" : "Connect"
                            implicitHeight: 26
                            implicitWidth: 90
                            severity: modelData.active ? Button.Severity.Secondary : Button.Severity.Primary
                            disabled: Network.connectionBusy
                            onClicked: {
                                if (modelData.active) Network.deactivateConnection(modelData.name)
                                else Network.activateConnection(modelData.name)
                            }
                        }

                        Button {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Delete"
                            implicitHeight: 26
                            implicitWidth: 60
                            severity: Button.Severity.Danger
                            disabled: Network.connectionBusy
                            onClicked: root.openDeleteDialog(modelData)
                        }
                    }
                }
            }

            // ========== VPN EMPTY STATE ==========
            Rectangle {
                width: parent.width
                height: 60
                radius: HyprlandConfig.radius
                color: surfaceColor
                border.color: surfaceBorder
                border.width: 1
                visible: Network.vpnConnections.length === 0

                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰦝  No VPN connections"
                        color: mutedColor
                        font.pixelSize: 12
                        font.family: root.font
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Use \"Add VPN\" to import a configuration file"
                        color: mutedColor
                        font.pixelSize: 10
                        font.family: root.font
                        opacity: 0.7
                    }
                }
            }

            // ========== DIVIDER ==========
            /*Rectangle {
                width: parent.width
                height: 1
                color: surfaceBorder
                visible: Network.wifiEnabled
            }

            // ========== ADVANCED ==========
            Text {
                text: "󰑨  Advanced Network Settings"
                color: foregroundColor
                font.pixelSize: 13
                font.family: root.font
                font.bold: true
            }

            // DNS
            Rectangle {
                width: parent.width
                height: 40
                radius: HyprlandConfig.radius
                color: adv1Mouse.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"

                Behavior on color {
                    ColorAnimation { duration: 100; easing.type: Easing.InOutQuad }
                }

                Text { x: 8; anchors.verticalCenter: parent.verticalCenter; text: "󰦝"; color: foregroundColor; font.pixelSize: 16; font.family: root.font }
                Column { x: 32; anchors.verticalCenter: parent.verticalCenter; spacing: 1
                    Text { text: "DNS Configuration"; color: foregroundColor; font.pixelSize: 12; font.family: root.font }
                    Text { text: "Custom DNS servers, DHCP options"; color: mutedColor; font.pixelSize: 10; font.family: root.font }
                }
                Text { anchors.right: parent.right; anchors.rightMargin: 8; anchors.verticalCenter: parent.verticalCenter; text: ">"; color: mutedColor; font.pixelSize: 14; font.family: root.font }
                MouseArea { id: adv1Mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Quickshell.execDetached(["nm-connection-editor"]) }
            }

            // Proxy
            Rectangle {
                width: parent.width
                height: 40
                radius: HyprlandConfig.radius
                color: adv2Mouse.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"

                Behavior on color {
                    ColorAnimation { duration: 100; easing.type: Easing.InOutQuad }
                }

                Text { x: 8; anchors.verticalCenter: parent.verticalCenter; text: "󰒓"; color: foregroundColor; font.pixelSize: 16; font.family: root.font }
                Column { x: 32; anchors.verticalCenter: parent.verticalCenter; spacing: 1
                    Text { text: "Proxy"; color: foregroundColor; font.pixelSize: 12; font.family: root.font }
                    Text { text: "HTTP/HTTPS/SOCKS proxy settings"; color: mutedColor; font.pixelSize: 10; font.family: root.font }
                }
                Text { anchors.right: parent.right; anchors.rightMargin: 8; anchors.verticalCenter: parent.verticalCenter; text: ">"; color: mutedColor; font.pixelSize: 14; font.family: root.font }
                MouseArea { id: adv2Mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Quickshell.execDetached(["nm-connection-editor"]) }
            }

            // MAC
            Rectangle {
                width: parent.width
                height: 40
                radius: HyprlandConfig.radius
                color: adv3Mouse.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"

                Behavior on color {
                    ColorAnimation { duration: 100; easing.type: Easing.InOutQuad }
                }

                Text { x: 8; anchors.verticalCenter: parent.verticalCenter; text: ""; color: foregroundColor; font.pixelSize: 16; font.family: root.font }
                Column { x: 32; anchors.verticalCenter: parent.verticalCenter; spacing: 1
                    Text { text: "MAC Address"; color: foregroundColor; font.pixelSize: 12; font.family: root.font }
                    Text { text: "Spoof or clone MAC address"; color: mutedColor; font.pixelSize: 10; font.family: root.font }
                }
                Text { anchors.right: parent.right; anchors.rightMargin: 8; anchors.verticalCenter: parent.verticalCenter; text: ">"; color: mutedColor; font.pixelSize: 14; font.family: root.font }
                MouseArea { id: adv3Mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Quickshell.execDetached(["nm-connection-editor"]) }
            }

            // IP
            Rectangle {
                width: parent.width
                height: 40
                radius: HyprlandConfig.radius
                color: adv4Mouse.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"

                Behavior on color {
                    ColorAnimation { duration: 100; easing.type: Easing.InOutQuad }
                }

                Text { x: 8; anchors.verticalCenter: parent.verticalCenter; text: "󰇘"; color: foregroundColor; font.pixelSize: 16; font.family: root.font }
                Column { x: 32; anchors.verticalCenter: parent.verticalCenter; spacing: 1
                    Text { text: "IP Settings"; color: foregroundColor; font.pixelSize: 12; font.family: root.font }
                    Text { text: "Static IP, DHCP, routing"; color: mutedColor; font.pixelSize: 10; font.family: root.font }
                }
                Text { anchors.right: parent.right; anchors.rightMargin: 8; anchors.verticalCenter: parent.verticalCenter; text: ">"; color: mutedColor; font.pixelSize: 14; font.family: root.font }
                MouseArea { id: adv4Mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Quickshell.execDetached(["nm-connection-editor"]) }
            }

            // Portal
            Rectangle {
                width: parent.width
                height: 40
                radius: HyprlandConfig.radius
                color: adv5Mouse.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"

                Behavior on color {
                    ColorAnimation { duration: 100; easing.type: Easing.InOutQuad }
                }

                Text { x: 8; anchors.verticalCenter: parent.verticalCenter; text: "󱛃"; color: foregroundColor; font.pixelSize: 16; font.family: root.font }
                Column { x: 32; anchors.verticalCenter: parent.verticalCenter; spacing: 1
                    Text { text: "Captive Portal"; color: foregroundColor; font.pixelSize: 12; font.family: root.font }
                    Text { text: "Open browser for network login"; color: mutedColor; font.pixelSize: 10; font.family: root.font }
                }
                Text { anchors.right: parent.right; anchors.rightMargin: 8; anchors.verticalCenter: parent.verticalCenter; text: ">"; color: mutedColor; font.pixelSize: 14; font.family: root.font }
                MouseArea { id: adv5Mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Network.openPublicWifiPortal() }
            }

            // Reset
            Rectangle {
                width: parent.width
                height: 40
                radius: HyprlandConfig.radius
                color: adv6Mouse.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"

                Behavior on color {
                    ColorAnimation { duration: 100; easing.type: Easing.InOutQuad }
                }

                Text { x: 8; anchors.verticalCenter: parent.verticalCenter; text: "󰅟"; color: Colors.error; font.pixelSize: 16; font.family: root.font }
                Column { x: 32; anchors.verticalCenter: parent.verticalCenter; spacing: 1
                    Text { text: "Network Reset"; color: Colors.error; font.pixelSize: 12; font.family: root.font }
                    Text { text: "Forget all networks and reset settings"; color: mutedColor; font.pixelSize: 10; font.family: root.font }
                }
                MouseArea { id: adv6Mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: {
                    if (Network.networkName) Network.forgetNetwork(Network.networkName)
                    if (Network.active) Network.disconnectWifiNetwork()
                }}
            }

            Item { width: 1; height: 16 }*/
        }
    }

    // ========== PASSWORD OVERLAY ==========
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6)
        z: 100
        visible: passwordDialogVisible

        MouseArea {
            anchors.fill: parent
            onClicked: {} // block clicks
        }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width - 32
            height: pwdCol.height + 24
            radius: HyprlandConfig.radius
            color: Colors.surface_container_high
            border.color: Colors.surface_variant
            border.width: 1

            Column {
                id: pwdCol
                x: 12
                y: 12
                width: parent.width - 24
                spacing: 10

                Text {
                    text: "  Wi-Fi Password Required"
                    color: foregroundColor
                    font.pixelSize: 15
                    font.family: root.font
                    font.bold: true
                }

                Text {
                    text: "Enter the password for " + (passwordTarget ? passwordTarget.ssid : "the network")
                    color: mutedColor
                    font.pixelSize: 11
                    font.family: root.font
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                Rectangle {
                    width: parent.width
                    height: 34
                    radius: 6
                    color: Colors.surface
                    border.color: Colors.outline
                    border.width: 1

                    TextInput {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        verticalAlignment: Text.AlignVCenter
                        color: foregroundColor
                        font.pixelSize: 13
                        font.family: root.font
                        echoMode: root.showPassword ? TextInput.Normal : TextInput.Password
                        passwordCharacter: "●"
                        text: root.passwordInputText
                        focus: visible
                        onTextChanged: root.passwordInputText = text
                        onAccepted: root.submitPassword()
                    }
                }

                Row {
                    spacing: 6
                    width: parent.width

                    Text {
                        text: root.showPassword ? "󰛨  Hide" : "󰛩  Show"
                        color: mutedColor
                        font.pixelSize: 11
                        font.family: root.font
                        anchors.verticalCenter: parent.verticalCenter

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.showPassword = !root.showPassword
                        }
                    }

                    Item { width: 1; height: 1 }

                    Button {
                        text: "Cancel"
                        severity: Button.Severity.Secondary
                        implicitHeight: 30
                        implicitWidth: 72
                        onClicked: {
                            passwordDialogVisible = false
                            passwordTarget = null
                        }
                    }

                    Button {
                        text: "Connect"
                        severity: Button.Severity.Primary
                        implicitHeight: 30
                        implicitWidth: 80
                        disabled: passwordInputText.length === 0
                        onClicked: root.submitPassword()
                    }
                }
            }
        }
    }

    // ========== DELETE CONNECTION OVERLAY ==========
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6)
        z: 100
        visible: root.deleteDialogVisible

        MouseArea {
            anchors.fill: parent
            onClicked: {} // block clicks
        }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width - 32
            height: delCol.height + 24
            radius: HyprlandConfig.radius
            color: Colors.surface_container_high
            border.color: Colors.surface_variant
            border.width: 1

            Column {
                id: delCol
                x: 12
                y: 12
                width: parent.width - 24
                spacing: 10

                Text {
                    text: "󰅖  Delete Connection"
                    color: foregroundColor
                    font.pixelSize: 15
                    font.family: root.font
                    font.bold: true
                }

                Text {
                    text: "Delete \"" + (root.deleteTarget ? root.deleteTarget.name : "") + "\"? The saved connection profile will be removed."
                    color: mutedColor
                    font.pixelSize: 11
                    font.family: root.font
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                Row {
                    spacing: 6
                    width: parent.width

                    Item { width: 1; height: 1 }

                    Button {
                        text: "Cancel"
                        severity: Button.Severity.Secondary
                        implicitHeight: 30
                        implicitWidth: 72
                        onClicked: {
                            root.deleteDialogVisible = false
                            root.deleteTarget = null
                        }
                    }

                    Button {
                        text: "Delete"
                        severity: Button.Severity.Danger
                        implicitHeight: 30
                        implicitWidth: 80
                        onClicked: root.confirmDelete()
                    }
                }
            }
        }
    }

    // ========== ADD VPN OVERLAY ==========
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6)
        z: 100
        visible: root.vpnDialogVisible

        MouseArea {
            anchors.fill: parent
            onClicked: {} // block clicks
        }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width - 32
            height: vpnCol.height + 24
            radius: HyprlandConfig.radius
            color: Colors.surface_container_high
            border.color: Colors.surface_variant
            border.width: 1

            Column {
                id: vpnCol
                x: 12
                y: 12
                width: parent.width - 24
                spacing: 10

                Text {
                    text: "󰦝  Add VPN Connection"
                    color: foregroundColor
                    font.pixelSize: 15
                    font.family: root.font
                    font.bold: true
                }

                Text {
                    text: "Import an OpenVPN (.ovpn) or WireGuard (.conf) configuration file."
                    color: mutedColor
                    font.pixelSize: 11
                    font.family: root.font
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                Row {
                    spacing: 6

                    Button {
                        text: "OpenVPN"
                        severity: root.vpnType === "openvpn" ? Button.Severity.Primary : Button.Severity.Secondary
                        implicitHeight: 28
                        implicitWidth: 90
                        onClicked: root.vpnType = "openvpn"
                    }

                    Button {
                        text: "WireGuard"
                        severity: root.vpnType === "wireguard" ? Button.Severity.Primary : Button.Severity.Secondary
                        implicitHeight: 28
                        implicitWidth: 90
                        onClicked: root.vpnType = "wireguard"
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 34
                    radius: 6
                    color: Colors.surface
                    border.color: Colors.outline
                    border.width: 1

                    TextInput {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        verticalAlignment: Text.AlignVCenter
                        color: foregroundColor
                        font.pixelSize: 13
                        font.family: root.font
                        clip: true
                        text: root.vpnFilePath
                        focus: visible
                        onTextChanged: root.vpnFilePath = text
                        onAccepted: root.submitVpnImport()
                    }

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        verticalAlignment: Text.AlignVCenter
                        visible: root.vpnFilePath.length === 0
                        text: "/path/to/config." + (root.vpnType === "openvpn" ? "ovpn" : "conf")
                        color: mutedColor
                        opacity: 0.6
                        font.pixelSize: 12
                        font.family: root.font
                    }
                }

                Row {
                    spacing: 6
                    width: parent.width

                    Item { width: 1; height: 1 }

                    Button {
                        text: "Cancel"
                        severity: Button.Severity.Secondary
                        implicitHeight: 30
                        implicitWidth: 72
                        onClicked: root.vpnDialogVisible = false
                    }

                    Button {
                        text: "Import"
                        severity: Button.Severity.Primary
                        implicitHeight: 30
                        implicitWidth: 80
                        disabled: root.vpnFilePath.length === 0
                        onClicked: root.submitVpnImport()
                    }
                }
            }
        }
    }
}
