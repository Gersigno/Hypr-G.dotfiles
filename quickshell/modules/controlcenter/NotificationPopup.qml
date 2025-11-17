import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    id: notificationPopup

    // Pour l'instant, on désactive les bulles de notifications
    // Elles nécessitent des modules Quickshell avancés qui ne sont pas disponibles
    visible: false

    PanelWindow {
        id: root
        visible: false // Désactivé pour l'instant
        screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null

        WlrLayershell.namespace: "quickshell:notificationPopup"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusiveZone: 0

        anchors {
            top: true
            right: true
            bottom: true
        }

        color: "transparent"
        implicitWidth: 400

        // Placeholder pour les futures bulles de notifications
        Rectangle {
            anchors.fill: parent
            color: "red"
            opacity: 0.5

            Text {
                anchors.centerIn: parent
                text: "Notification Popup\n(En développement)"
                color: "white"
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}