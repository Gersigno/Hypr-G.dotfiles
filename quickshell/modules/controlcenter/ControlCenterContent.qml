import qs.services
import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
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

    signal requestClose()

    property real animProgress: 0.0
    property real animDuration: 250
    
    onAnimProgressChanged: {
        // Ferme tous les menus quand le control center se ferme
        if (animProgress < 10) {
            powerMenu.expanded = false
            if (wifiToggle.menuPopup && wifiToggle.menuPopup.opened) {
                wifiToggle.menuPopup.close()
            }
            if (bluetoothToggle.menuPopup && bluetoothToggle.menuPopup.opened) {
                bluetoothToggle.menuPopup.close()
            }
            if (screenshotToggle.menuPopup && screenshotToggle.menuPopup.opened) {
                screenshotToggle.menuPopup.close()
            }
        }
    }
    property bool isDarkMode: true
    property bool airplaneMode: false
    property string themeMode: "dark"

    onAirplaneModeChanged: {
        rfkillProcess.command = airplaneMode ? ["rfkill", "block", "all"] : ["rfkill", "unblock", "all"]
        rfkillProcess.running = false
        rfkillProcess.running = true
    }

    Process {
        id: checkAirplane
        command: ["bash", "-c", "rfkill list | grep -q 'Soft blocked: yes' && echo 'true' || echo 'false'"]
        running: true
        stdout: SplitParser {
            onRead: (data) => {
                const isBlocked = data.trim() === "true"
                root.airplaneMode = isBlocked
            }
        }
    }

    Process {
        id: getThemeModeProcess
        command: ["bash", "-c", "grep 'THEME_MODE' /home/gersigno/.config/hypr/hypr-g/hyprland/env.conf | awk -F',' '{print $NF}' | tr -d ' '"]
        running: true
        stdout: SplitParser {
            onRead: (data) => {
                root.themeMode = data.trim()
            }
        }
    }

    Process {
        id: rfkillProcess
        running: false
    }

    Process {
        id: bluetoothProcess
        running: false
    }

    Process {
        id: wifiProcess
        running: false
    }

    Process {
        id: screenshotProcess
        running: false
    }

    Process {
        id: brightnessSetProcess
        running: true
    }

    Process {
        id: brightnessGetProcess
        command: ["bash", "-c", "brightnessctl -m | awk -F, '{print $4}' | tr -d '%'"]
        running: true
        stdout: SplitParser {
            onRead: (data) => {
                const val = parseFloat(data.trim()) / 100;
                // On ne met à jour le slider que si l'utilisateur n'est pas en train de le manipuler
                if (!brightnessSlider.pressed) {
                    brightnessSlider.value = val;
                }
            }
        }
    }

    Timer {
        id: brightnessSyncTimer
        interval: 300 // Vérifie toutes les secondes
        running: true
        repeat: true
        triggeredOnStart: true 
        onTriggered: {
            brightnessGetProcess.running = false;
            brightnessGetProcess.running = true;
        }
    }

    Process {
        id: shutdownConfirmProcess
        command: ["zenity", "--question", "--title=Shutdown", "--text=Are you sure you want to shut down the computer?", "--no-wrap"]
        running: false
        onExited: (code) => {
            if (code === 0) { // 0 = Yes button clicked
                shutdownProcess.running = true
            }
        }
    }

    Process {
        id: shutdownProcess
        command: ["systemctl", "poweroff"]
        running: false
    }

    Process {
        id: rebootConfirmProcess
        command: ["zenity", "--question", "--title=Reboot", "--text=Are you sure you want to reboot the computer?", "--no-wrap"]
        running: false
        onExited: (code) => {
            if (code === 0) {
                rebootProcess.running = true
            }
        }
    }

    Process {
        id: rebootProcess
        command: ["systemctl", "reboot"]
        running: false
    }

    Process {
        id: lockProcess
        command: ["hyprlock"]
        running: false
    }

    Process {
        id: logoutConfirmProcess
        command: ["zenity", "--question", "--title=Logout", "--text=Are you sure you want to log out?", "--no-wrap"]
        running: false
        onExited: (code) => {
            if (code === 0) {
                logoutProcess.running = true
            }
        }
    }

    Process {
        id: logoutProcess
        command: ["hyprctl", "dispatch", "exit"]
        running: false
    }

    Process {
        id: toggleThemeProcess
        command: ["/home/gersigno/.config/hypr/hypr-g/scripts/toggle-theme.sh"]
        running: false
        onExited: {
            // Relis la variable THEME_MODE après que le script se soit exécuté
            getThemeModeProcess.running = false
            getThemeModeProcess.running = true
        }
    }

    enabled: animProgress > 20

    readonly property string userName: home.split('/').pop().charAt(0).toUpperCase() + home.split('/').pop().slice(1)

    readonly property real profilePictureSize: 50
    readonly property string home: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]

    ColumnLayout {
        id: mainColumn
        anchors.fill: parent
        spacing: (GlobalStates.gapsOut * 3)

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
            Layout.fillWidth: true 
            implicitHeight: profilePictureSize

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
                        onTriggered: {
                            uptimeProcess.running = false;
                            uptimeProcess.running = true;
                        }
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
                        color: "black"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log("[DEBUG] Lock button clicked")
                            lockProcess.running = true
                            root.requestClose()
                        }
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
                        onClicked: {
                            console.log("[DEBUG] Logout button clicked")
                            logoutConfirmProcess.running = true
                            root.requestClose()
                        }
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
                        onClicked: {
                            console.log("[DEBUG] Reboot button clicked")
                            rebootConfirmProcess.running = true
                            root.requestClose()
                        }
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
                        onClicked: {
                            console.log("[DEBUG] Shutdown button clicked")
                            shutdownConfirmProcess.running = true
                            console.log("[DEBUG] Emitting requestClose signal")
                            root.requestClose()
                            console.log("[DEBUG] requestClose signal emitted")
                        }
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
                        text: powerMenu.expanded ? "" : "󰍜"
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
                            console.log("[DEBUG] Power menu toggle clicked")
                            powerMenu.expanded = !powerMenu.expanded
                            // Removed invalid transform access - Scale already has Behavior animations
                        }
                    }
                }
            }
        }

        // Actions buttons
        ColumnLayout {
            Layout.fillWidth: true
            spacing: GlobalStates.gapsOut

            // Network and bluetooth toggles
            Item {
                Layout.fillWidth: true
                implicitHeight: 32

                Row {
                    anchors.fill: parent
                    spacing: GlobalStates.gapsOut

                    // WiFi toggle
                    DetailedToggle {
                        id: wifiToggle
                        active: Network.wifi                    
                        useArrow: true                    
                        icon: Network.wifi ? "󰤨" : "󰤭"
                        text: Network.wifi ? (Network.networkName || "Connected") : (Network.wifiEnabled ? "Not connected" : "WiFi Off")
                        onClicked: {
                            Network.scan()
                            wifiProcess.command = Network.wifiEnabled ? ["rfkill", "block", "wifi"] : ["rfkill", "unblock", "wifi"]
                            wifiProcess.running = false
                            wifiProcess.running = true
                        }
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
                        id: bluetoothToggle
                        active: Bluetooth.enabled                    
                        useArrow: true                    
                        icon: {
                            if (!Bluetooth.available) return "󰂲";
                            if (Bluetooth.connected) return "󰂱";
                            if (Bluetooth.enabled) return "󰂯";
                            return "󰂲";
                        }
                        text: Bluetooth.connected ? "Connected" : (Bluetooth.enabled ? "On" : "Bluetooth Off")
                        onClicked: {
                            Bluetooth.scan()
                            bluetoothProcess.command = Bluetooth.enabled ? ["rfkill", "block", "bluetooth"] : ["rfkill", "unblock", "bluetooth"]
                            bluetoothProcess.running = false
                            bluetoothProcess.running = true
                        }
                        width: parent.width / 2 - GlobalStates.gapsOut / 2
                        options: Bluetooth.friendlyDeviceList.length > 0 ? Bluetooth.friendlyDeviceList.map(function(d) { 
                            return {
                                text: d.name + (d.connected ? " (Connected)" : ""),
                                icon: d.connected ? "󰂱" : "󰂯",
                                action: function() { if (d.connected) { d.disconnect() } else { d.connect() } }
                            }}) : 
                            [{text: "No devices found", icon: "󰂲", action: function() {}}]
                    }
                }
            }

            //Dnd and light mode toggles
            Item {
                Layout.fillWidth: true
                implicitHeight: 32
                
                Row {
                    anchors.fill: parent
                    spacing: GlobalStates.gapsOut

                    DetailedToggle {
                        id: dndToggle
                        active: Notifications.silent
                        useArrow: false
                        icon: Notifications.silent ? "󰂛" : ""
                        text: "Do Not Disturb"
                        width: parent.width / 2 - GlobalStates.gapsOut / 2
                        onClicked: Notifications.silent = !Notifications.silent
                    }

                    DetailedToggle {
                        id: airplaneModeToggle
                        active: root.airplaneMode
                        useArrow: false
                        icon: "󰀝"
                        text: "Airplane Mode"
                        width: parent.width / 2 - GlobalStates.gapsOut / 2
                        onClicked: root.airplaneMode = !root.airplaneMode
                    }
                }
            }

            // Screenshot and ?
            Item {
                Layout.fillWidth: true
                implicitHeight: 32
                
                Row {
                    anchors.fill: parent
                    spacing: GlobalStates.gapsOut

                    DetailedToggle {
                        id: lightModeToggle
                        active: root.themeMode === "light"
                        useArrow: false
                        icon: root.themeMode === "light" ? "󰖙" : "󰖚"
                        text: "Light Mode"
                        width: parent.width / 2 - GlobalStates.gapsOut / 2
                        onClicked: {
                            toggleThemeProcess.running = false
                            toggleThemeProcess.running = true
                        }
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
                            //{text: "Active Window", icon: "󰖲", command: ["hyprshot", "-m", "active"]}
                        ]
                        onClicked: {
                            screenshotProcess.command = ["hyprshot", "-m", "region"]
                            screenshotProcess.running = false
                            screenshotProcess.running = true
                        }
                    }
                }
            }
        }

        //Sliders section
        ColumnLayout { 
            Layout.fillWidth: true
            spacing: GlobalStates.gapsOut * 1

            // Volume slider
            SliderWithIcon {
                id: volumeSlider
                icon: {
                    if (Audio.sink?.audio.muted || value === 0) return "󰝟";
                    if (value > 0.6) return "󰕾";
                    if (value > 0.3) return "󰖀";
                    return "󰕿"; 
                }
                onMoved: {
                    if (Audio.sink && Audio.sink.audio) {
                        Audio.sink.audio.volume = value
                    }
                }
                Connections {
                    target: Audio
                    function onValueChanged() {
                        if (!volumeSlider.pressed) {
                            volumeSlider.value = Audio.value
                        }
                    }
                    function onSinkChanged() {
                        if (Audio.sink && Audio.sink.audio) {
                            volumeSlider.value = Audio.sink.audio.volume
                        }
                    }
                }
                Component.onCompleted: {
                    if (Audio.value !== undefined) {
                        volumeSlider.value = Audio.value;
                    }
                }
                Layout.fillWidth: true
            }

            /*Binding {
                target: Audio.sink?.audio
                property: "volume"
                value: volumeSlider.value
            }*/

            // Brightness slider
            SliderWithIcon {
                id: brightnessSlider 
                icon: "󰃟"
                onMoved: {
                    const percent = Math.round(value * 100);
                    brightnessSetProcess.command = ["brightnessctl", "set", percent + "%"];
                    brightnessSetProcess.running = false;
                    brightnessSetProcess.running = true;
                }
                Layout.fillWidth: true
            }
        }

        //Notifications section
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                spacing: GlobalStates.gapsOut

                // Header with count and clear button
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32

                    Text {
                        text: Notifications.list.length + " notifications"
                        font.pixelSize: 14
                        color: "white"
                        font.family: "SF Pro Display"
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        width: 60
                        height: 24
                        color: "#2e2e2e"
                        radius: GlobalStates.cornerRadius
                        Text {
                            anchors.centerIn: parent
                            text: "Clear all"
                            font.pixelSize: 12
                            color: "white"
                            font.family: "SF Pro Display"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Notifications.discardAllNotifications()
                        }
                    }
                }

                // Notifications list
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    ListView {
                        anchors.fill: parent
                        model: Notifications.list
                        spacing: GlobalStates.gapsOut

                        delegate: Rectangle {
                            width: parent.width
                            height: 60
                            color: "#2e2e2e"
                            radius: GlobalStates.cornerRadius

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: GlobalStates.gapsOut
                                spacing: GlobalStates.gapsOut

                                // App icon
                                Item {
                                    Layout.preferredWidth: 35
                                    Layout.preferredHeight: 35

                                    Image {
                                        id: notifImage
                                        anchors.fill: parent
                                        fillMode: Image.PreserveAspectFit
                                        
                                        source: {
                                            let icon = modelData.appIcon;
                                            if (!icon) return "";

                                            // 1. Si c'est un chemin absolu (ex: Arch logo ou Screenshot)
                                            if (icon.startsWith("/")) {
                                                return "file://" + icon;
                                            }

                                            // 2. On demande à Quickshell comment charger cette icône
                                            let resolved = Quickshell.iconPath(icon, 32);
                                            
                                            if (resolved) {
                                                // SI le résultat contient déjà "image://", on l'utilise TEL QUEL
                                                if (resolved.startsWith("image://")) {
                                                    return resolved;
                                                }
                                                // SINON, c'est un chemin de fichier, on ajoute file://
                                                return "file://" + resolved;
                                            }

                                            return "";
                                        }

                                        // On ne montre l'image que si elle est prête (Ready)
                                        visible: status === Image.Ready
                                    }

                                    // Icône de secours Nerd Font si l'image échoue ou est absente
                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰵅" 
                                        font.pixelSize: 22
                                        color: "white"
                                        font.family: "Symbols Nerd Font"
                                        visible: notifImage.status !== Image.Ready
                                    }
                                }

                                // Notification content
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text: modelData.summary
                                        font.pixelSize: 13
                                        color: "white"
                                        font.family: "SF Pro Display"
                                        font.bold: true
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: modelData.body
                                        font.pixelSize: 12
                                        color: "lightgray"
                                        font.family: "SF Pro Display"
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                        maximumLineCount: 2
                                        wrapMode: Text.Wrap
                                    }
                                }

                                // Dismiss button
                                Rectangle {
                                    width: 20
                                    height: 20
                                    color: "transparent"
                                    radius: 10
                                    Text {
                                        anchors.centerIn: parent
                                        text: "×"
                                        font.pixelSize: 14
                                        color: "white"
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: Notifications.discardNotification(modelData.notificationId)
                                    }
                                }
                            }
                        }

                        // No notifications message
                        Text {
                            anchors.centerIn: parent
                            text: "No notifications"
                            font.pixelSize: 16
                            color: "lightgray"
                            font.family: "SF Pro Display"
                            visible: Notifications.list.length === 0
                        }
                    }
                }
            }
        }
    }
}