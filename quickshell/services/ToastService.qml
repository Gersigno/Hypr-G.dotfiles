pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    property string message: ""
    property string icon: ""
    property int duration: 3000
    property real progress: -1

    signal toastRequested(string message, string icon, int duration, real progress)
    signal editRequested(string message, string icon, int duration, real progress)

    function show(msg, dur, ico, prog) {
        root.message = msg ?? root.message
        root.duration = dur ?? 3000
        root.icon = ico ?? ""
        root.progress = prog ?? -1
        root.toastRequested(root.message, root.icon, root.duration, root.progress)
    }

    function edit(msg, dur, ico, prog) {
        root.message = msg ?? root.message
        root.duration = dur ?? 3000
        root.icon = ico ?? ""
        root.progress = prog ?? -1
        root.editRequested(root.message, root.icon, root.duration, root.progress)
    }
}