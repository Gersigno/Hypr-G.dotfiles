import QtQuick

/**
 * Service de notifications personnalisé inspiré d'end-4
 * Utilise NotificationServer pour tracker les notifications D-Bus
 */
QtObject {
    id: root

    // Propriétés principales
    property bool silent: false
    property var list: []

    // Fonctions de contrôle (comme end-4)
    function discardNotification(id) {
        console.log("[Notifications] Suppression notification ID:", id)
        const index = root.list.findIndex(notif => notif.notificationId === id)

        if (index !== -1) {
            root.list.splice(index, 1)
            root.list = root.list.slice(0) // Trigger change
        }
    }

    function discardAllNotifications() {
        console.log("[Notifications] Suppression de toutes les notifications")
        root.list = []
    }

    Component.onCompleted: {
        console.log("[Notifications] Service initialisé (style end-4)")
        console.log("[Notifications] Instance créée:", root)
        console.log("[Notifications] Liste initiale:", root.list)

        // Ajouter une notification de test
        const testNotif = {
            "notificationId": 1,
            "appName": "Test App",
            "summary": "Notification de test",
            "body": "Ceci est une notification de test pour vérifier l'interface",
            "urgency": "normal",
            "time": Date.now()
        };
        root.list = [testNotif];
        console.log("[Notifications] Notification de test ajoutée, liste:", root.list)
    }
}