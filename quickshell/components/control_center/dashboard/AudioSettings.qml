import QtQuick
import Quickshell
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import QtQuick.Effects
import Quickshell.Io

import qs.services
import "../../../utils"
import "../../../services"
import "../../common/interface"

Item {
    id: root

    
    readonly property color foregroundColor: Colors.on_background
    readonly property string font: Settings.fontFamily

    BackgroundLayer {
        id: background
        anchors.fill: parent
    }
}