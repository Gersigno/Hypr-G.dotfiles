import QtQuick
import Quickshell
import Qt5Compat.GraphicalEffects
import Quickshell.Widgets
import Quickshell.Wayland

import "../common/interface"
import "../../services"
import "../../config"
import "../../utils"

Item {
    id: root 

    readonly property color backgroundColor: Config.isOled ? "#000" : Colors.background
    readonly property color foregroundColor: Config.isOled ? "#fff" : Colors.on_background
    readonly property string fontFamily: Config.fontFamily

    readonly property var chargeState: Battery.chargeState
    readonly property bool isCharging: Battery.isCharging
    readonly property bool isPluggedIn: Battery.isPluggedIn
    readonly property real percentage: Battery.percentage
    readonly property bool isLow: percentage <= 20
    readonly property bool isCritical: percentage <= 10
    readonly property bool isSuspending: percentage <= 5
    readonly property bool isFull: percentage >= 100
    readonly property var chargingBatteryIcons: ["", "", "", "", ""]
    property int chargingBatteryFrame: 0


    readonly property string batteryIconText: {
        if (!Battery.available) return "";
        if (isCharging) return chargingBatteryIcons[chargingBatteryFrame];
        if (percentage > 80) return "";
        if (percentage > 60) return "";
        if (percentage > 40) return "";
        if (percentage > 20) return "";
        return ""; // low
    }

    readonly property string audioIconText: {
        if (!Audio.ready) return "";
        if (Audio.sink?.audio?.muted ?? false) return "";
        if (Audio.value > 0.66) return "";
        if (Audio.value > 0.33) return "";
        return "";
    }
        
    readonly property string bluetoothIconText: {
        if (!Bluetooth.available) return "";
        if (Bluetooth.connected) return "󰂱";
        if (Bluetooth.enabled) return "󰂯";
        return "";
    }

    readonly property string networkIconText: {
        if (Network.ethernet) return "󰈀";
        if (Network.wifi) {
            if (Network.networkStrength > 75) return "󰤨";
            if (Network.networkStrength > 50) return "󰤥";
            if (Network.networkStrength > 25) return "󰤢";
            return "󰤟";
        }
        if (Network.wifiStatus === "connecting") return "󰤬"
        if (Network.wifiEnabled) return "󰤭";
        return "󰤮";
    }

    readonly property color batteryTextColor: (isLow && !isCharging) ? (isCritical ? "red" : "orange") : foregroundColor

    onIsChargingChanged: {
        if (!isCharging) chargingBatteryFrame = 0;
    }

    Timer {
        interval: 600
        repeat: true
        running: Battery.available && root.isCharging
        onTriggered: {
            root.chargingBatteryFrame = (root.chargingBatteryFrame + 1) % root.chargingBatteryIcons.length;
        }
    }

    implicitWidth: invertedCorner.width + container.width
    height: parent.height

    

    Item {
        height: parent.height
        width: 200

        antialiasing: true

        //WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        InvertedCorner {
            id: invertedCorner
            corner: InvertedCorner.Corner.TopRight
            cornerRadius: HyprlandConfig.radius
            cornerColor: backgroundColor
        }

        Rectangle {
            id: container
            x: invertedCorner.width
            width: content.width + HyprlandConfig.radius + 8
            height: parent.height
            bottomLeftRadius: HyprlandConfig.radius
            color: backgroundColor


            Row {
                id: content
                spacing: 10
                height: parent.height
                anchors.centerIn: parent

                Text {
                    id: bluetooth
                    text: root.bluetoothIconText
                    color: foregroundColor
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    id: network
                    text: root.networkIconText
                    color: foregroundColor
                    font.family: root.fontFamily
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    id: volume
                    text: root.audioIconText
                    font.pixelSize: 14
                    font.family: root.fontFamily
                    opacity: Audio.sink?.audio?.muted ?? false ? 0.7 : 1.0
                    color: foregroundColor
                    anchors.verticalCenter: parent.verticalCenter
                }
                /*Row {
                    id: battery
                    height: parent.height
                    visible: Battery.available
                    spacing: 4

                    Text {
                        text: Battery.available ? root.batteryIconText : ""
                        color: root.batteryTextColor
                    }
                    Text {
                        text: Battery.available ? Math.round(root.percentage) + "%" : ""
                        color: root.batteryTextColor
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        font.family: root.fontFamily
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }*/
                Item {
                    id: battery
                    height: parent.height
                    //width: batteryIcon.width
                    width: 22
                    visible: Battery.available

                    //Background
                    ClippingRectangle {
                        id: batteryBackground
                        color: "grey"
                        height: 12
                        radius: 4
                        width: parent.width
                        //opacity: 0.3
                        //x: batteryIcon.x + batteryEnd.width
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            id: batteryProgress
                            color: root.batteryTextColor
                            height: batteryBackground.height
                            width: Math.max(2, batteryBackground.width * root.percentage / 100)
                            //x: batteryBackground.x
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    //Battery end
                    Rectangle {
                        id: batteryEnd
                        color: "grey"
                        height: 4
                        width: 2
                        //opacity: 0.3
                        topRightRadius: 8
                        bottomRightRadius: 8
                        x: batteryBackground.x + batteryBackground.width
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        color: "transparent"
                        height: batteryBackground.height
                        width: batteryBackground.width
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: Battery.available ? ( Battery.isCharging ? "󱐋" + Math.round(root.percentage) : Math.round(root.percentage)) : ""
                            color: "black"
                            width: battery.width
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            font.family: root.fontFamily
                        }
                    }

                    //Black text
                    ClippingRectangle {
                        width: batteryProgress.width
                        height: batteryBackground.height
                        anchors.verticalCenter: parent.verticalCenter
                        color: "transparent"
                        Text {
                            text: Battery.available ? ( Battery.isCharging ? "󱐋" + Math.round(root.percentage) : Math.round(root.percentage)) : ""
                            color: "black"
                            width: battery.width
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            font.family: root.fontFamily
                        }
                    }
                }
                Item {
                    id: notificationBell
                    height: parent.height
                    width: bellText.implicitWidth
                    visible: Notifications.list.length > 0

                    Text {
                        id: bellText
                        text: ""
                        font.pixelSize: 14
                        font.family: root.fontFamily
                        color: foregroundColor
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        id: bellBadgeText
                        text: Notifications.list.length > 99 ? "99+" : Notifications.list.length
                        color: Colors.backgroundColor
                        font.bold: true
                        font.family: root.fontFamily
                        font.pixelSize: Notifications.list.length > 99 ? 7 : 10
                        anchors.horizontalCenter: bellText.horizontalCenter
                        anchors.bottom: bellText.bottom
                        anchors.bottomMargin: 3.5
                        textAlignment: Text.AlignHCenter
                    }

                    /*Rectangle {
                        id: bellBadge
                        height: 13
                        width: Math.max(13, bellBadgeText.implicitWidth + 6)
                        radius: 6.5
                        color: Colors.primary
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.topMargin: 2

                        Text {
                            id: bellBadgeText
                            anchors.centerIn: parent
                            text: Notifications.list.length > 99 ? "99+" : Notifications.list.length
                            color: Colors.on_primary
                            font.family: root.fontFamily
                            font.pixelSize: 8
                            font.weight: Font.Bold
                        }
                    }*/
                }
            }
        }
    }
}