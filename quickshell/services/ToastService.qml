pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    property string message: ""
    property string icon: ""
    property int duration: 3000

    signal toastRequested(string message, string icon, int duration)

    function show(msg, dur, ico) {
        root.message = msg ?? root.message
        root.duration = dur ?? 3000
        root.icon = ico ?? ""
        root.toastRequested(root.message, root.icon, root.duration)
    }
}