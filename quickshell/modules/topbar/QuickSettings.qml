import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.services
import QtQuick.Effects
import "../.."

Item {
    id: root

    readonly property var chargeState: Battery.chargeState
    readonly property bool isCharging: Battery.isCharging
    readonly property bool isPluggedIn: Battery.isPluggedIn
    readonly property real percentage: Battery.percentage
    readonly property bool isLow: percentage <= 20

    // Exposed properties for our ControlCenter animation
    readonly property real containerWidth: root.width
    readonly property real containerHeight: root.height

    readonly property real renderedWidth: container.width + GlobalStates.cornerRadius
    readonly property real renderedHeight: root.height

    readonly property string batteryIconText: {
        if (!Battery.available) return "";
        if (isCharging) return "󰂄";
        if (percentage > 80) return "󰁹";
        if (percentage > 60) return "󰂀";
        if (percentage > 40) return "󰁾";
        if (percentage > 20) return "󰁻";
        return "󰁺"; // low
    }

    readonly property color batteryTextColor: isLow ? "red" : "white"

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

    readonly property string audioIconText: {
        if (!Audio.ready) return "󰖁";
        if (Audio.sink?.audio?.muted ?? false) return "󰖁";
        if (Audio.value > 0.66) return "󰕾";
        if (Audio.value > 0.33) return "󰖀";
        return "󰕿";
    }

    readonly property string bluetoothIconText: {
        if (!Bluetooth.available) return "";
        if (Bluetooth.connected) return "󰂱";
        if (Bluetooth.enabled) return "󰂯";
        return "";
    }

    implicitWidth: container.width
    height: parent.height

    Item {
        id: container

        width: settingsRow.width + GlobalStates.cornerRadius + 8
        height: parent.height


        // Inverse corner on the left
        Canvas {
            x: (GlobalStates.cornerRadius * -1)
            y: 0
            width: GlobalStates.cornerRadius
            height: GlobalStates.cornerRadius
            
            onPaint: {
                const ctx = getContext("2d");
                const w = width;
                const h = height;
                const r = GlobalStates.cornerRadius;
                
                ctx.reset();
                ctx.fillStyle = GlobalStates.backgroundColor;
                
                // Top-left inverse corner (L-shape)
                ctx.beginPath();
                ctx.moveTo(w, 0);
                ctx.lineTo(w, r);
                ctx.arc(w - r, r, r, 0, 1.5 * Math.PI, true);
                ctx.lineTo(w, 0);
                ctx.closePath();
                ctx.fill();
            }
        }

        // Main background rectangle
        Rectangle {
            x: 0
            y: 0
            width: container.width
            height: parent.height - GlobalStates.cornerRadius
            color: GlobalStates.backgroundColor
        }

        // Bottom section with normal corner
        Canvas {
            x: 0
            y: parent.height - GlobalStates.cornerRadius
            width: container.width
            height: GlobalStates.cornerRadius

            onPaint: {
                const ctx = getContext("2d");
                const w = width;
                const h = height;
                const r = GlobalStates.cornerRadius;

                ctx.reset();
                ctx.fillStyle = GlobalStates.backgroundColor;
                
                ctx.beginPath();
                ctx.moveTo(0, 0);
                ctx.lineTo(w, 0);
                ctx.lineTo(w, h);
                ctx.lineTo(r, h);
                ctx.arc(r, h - r, r, 0.5 * Math.PI, Math.PI, false);
                ctx.lineTo(0, 0);
                ctx.closePath();
                ctx.fill();
            }
        }

        // Settings row
        Row {
            id: settingsRow
            x: 12
            y: 0
            height: parent.height

            spacing: 12

            readonly property bool isCurrentScreen: {
                if (!Quickshell.screens || !Hyprland.focusedMonitor) return false;
                return screen.name === Hyprland.focusedMonitor.name
            }

            opacity: isCurrentScreen 
                     ? 1.0 - (controlCenterComponent.animationProgress / 100) 
                     : 1.0

            layer.enabled: isCurrentScreen && controlCenterComponent.animationProgress > 0
            layer.effect: MultiEffect {
                source: settingsRow
                anchors.fill: settingsRow
                blurEnabled: true
                blur: (controlCenterComponent.animationProgress / 20)
            }


            //Bluetooth
            Text {
                id: settingsText
                text: root.bluetoothIconText
                font.pixelSize: 14
                color: "white"
                verticalAlignment: Text.AlignVCenter
            }

            //Network
            Text {
                id: networkText
                text: root.networkIconText
                font.pixelSize: 14
                color: Network.wifi || Network.ethernet ? "white" : "gray"
                verticalAlignment: Text.AlignVCenter
            }

            //Volume
            Text {
                id: volumeText
                text: root.audioIconText
                font.pixelSize: 14
                color: Audio.sink?.audio?.muted ?? false ? "gray" : "white"
                verticalAlignment: Text.AlignVCenter
            }

            Row {
                width: batteryText.width + batteryIcon.width + 4
                height: parent.height
                spacing: 4

                //Battery Icon
                Text {
                    id: batteryIcon
                    text: Battery.available ? root.batteryIconText : ""
                    font.pixelSize: 14
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                }

                //Battery Percentage
                Text {
                    id: batteryText
                    text: Battery.available ? Math.round(root.percentage) + "%" : ""
                    font.pixelSize: 12
                    font.family: "SF Pro Display"
                    color: root.batteryTextColor
                    verticalAlignment: Text.AlignVCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}