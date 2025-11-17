import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications as QsNotifications
import qs.modules.controlcenter

ShellRoot {
    // Enable/disable modules here
    property bool enableControlCenter: true
    property bool enableNotificationPopup: true

    // Instance globale des notifications
    QtObject {
        id: globalNotifications

        // Propriétés principales
        property bool silent: false
        property var list: []

        // Fonctions de contrôle (comme end-4)
        function discardNotification(id) {
            console.log("[Notifications] Suppression notification ID:", id)
            const index = globalNotifications.list.findIndex(notif => notif.notificationId === id)

            if (index !== -1) {
                globalNotifications.list.splice(index, 1)
                globalNotifications.list = globalNotifications.list.slice(0) // Trigger change
            }
        }

        function discardAllNotifications() {
            console.log("[Notifications] Suppression de toutes les notifications")
            globalNotifications.list = []
        }

        Component.onCompleted: {
            console.log("[Notifications] Service initialisé (style end-4)")
            console.log("[Notifications] Instance créée:", globalNotifications)
            console.log("[Notifications] Liste initiale:", globalNotifications.list)

            // Ajouter une notification de test
            const testNotif = {
                "notificationId": 1,
                "appName": "Test App",
                "summary": "Notification de test",
                "body": "Ceci est une notification de test pour vérifier l'interface",
                "urgency": "normal",
                "time": Date.now()
            };
            globalNotifications.list = [testNotif];
            console.log("[Notifications] Notification de test ajoutée, liste:", globalNotifications.list)
        }
    }

    // Server de notifications global
    QsNotifications.NotificationServer {
        id: globalNotificationServer

        onNotification: (notification) => {
            console.log("[Global] Nouvelle notification D-Bus reçue:", notification.summary)
            console.log("[Global] Notification complète:", JSON.stringify(notification))

            // Marquer comme trackée
            notification.tracked = true

            const newNotif = {
                "notificationId": notification.id,
                "appName": notification.appName || "Application",
                "summary": notification.summary || "",
                "body": notification.body || "",
                "urgency": notification.urgency?.toString() || "normal",
                "time": Date.now()
            };

            console.log("[Global] Nouvelle notification créée:", JSON.stringify(newNotif))
            console.log("[Global] Liste avant ajout:", globalNotifications.list.length, "éléments")

            globalNotifications.list = [...globalNotifications.list, newNotif];

            console.log("[Global] Liste mise à jour, total:", globalNotifications.list.length)
            console.log("[Global] Contenu de la liste:", JSON.stringify(globalNotifications.list))
        }
    }

    // ControlCenter avec notifications
    ControlCenter {
        globalNotifications: globalNotifications
    }

    LazyLoader { active: enableNotificationPopup; component: NotificationPopup {} }
}