import QtQuick
import qs.services

Item {
    Component.onCompleted: {
        console.log("=== DEBUG NOTIFICATIONS ===")
        console.log("Notifications object:", Notifications)
        console.log("Type of Notifications:", typeof Notifications)

        if (Notifications) {
            console.log("Notifications.list:", Notifications.list)
            console.log("Notifications.list length:", Notifications.list ? Notifications.list.length : "undefined")
            console.log("Notifications.silent:", Notifications.silent)
            console.log("Available methods:")
            for (var prop in Notifications) {
                if (typeof Notifications[prop] === 'function') {
                    console.log("  -", prop)
                }
            }
        } else {
            console.log("Notifications object is null/undefined")
        }
    }
}