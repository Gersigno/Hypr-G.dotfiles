import QtQuick
import Quickshell

import "../../config"
import "../../utils"

Item {
    id: root

    implicitWidth: 420
    implicitHeight: 160

    readonly property color backgroundColor: Config.isOled ? "#000" : Colors.background
    readonly property color foregroundColor: Config.isOled ? "#fff" : Colors.on_background
    readonly property color foregroundSecondaryColor: Config.isOled ? "#fff" : Colors.on_surface_variant
    readonly property color accentColor: Colors.primary

    // Content
    Column {
        anchors.centerIn: parent
        spacing: 4
        
        // Hour
        Text {
            id: expandedHour
            anchors.horizontalCenter: parent.horizontalCenter
            text: new Date().toLocaleTimeString(Qt.locale(), "HH")
            color: root.foregroundColor
            font.pixelSize: 80
            font.family: "StretchPro"
            font.preferTypoLineMetrics: true
            leftPadding: -60
        }

        // Minutes
        Text {
            id: expandedMinutes
            anchors.horizontalCenter: parent.horizontalCenter
            text: new Date().toLocaleTimeString(Qt.locale(), "mm")
            color: root.foregroundSecondaryColor
            font.pixelSize: 60
            font.family: "StretchPro"
            font.bold: true
            font.preferTypoLineMetrics: true
            rightPadding: -30
            topPadding: -20
        }
        
        Text {
            id: dateText
            anchors.horizontalCenter: parent.horizontalCenter
            text: new Date().toLocaleDateString(Qt.locale(), "dddd d MMMM")
            color: root.accentColor
            font.family: Config.fontFamily
            font.bold: true
            font.pixelSize: 18
            topPadding: -10
        }
    }
    
    // Timer to update time
    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            expandedHour.text = new Date().toLocaleTimeString(Qt.locale(), "HH");
            expandedMinutes.text = new Date().toLocaleTimeString(Qt.locale(), "mm");
            dateText.text = new Date().toLocaleDateString(Qt.locale(), "dddd d MMMM");
        }
    }
} 