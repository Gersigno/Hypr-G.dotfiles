import QtQuick
import Quickshell
import QtCore
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import QtQuick.Effects
import Quickshell.Io

import "../../../config"
import "../../../utils"
import "../../../services"
import "../../common/interface"

Item {
    id: root

    
    readonly property color foregroundColor: Config.isOled ? "#fff" : Colors.on_background
    readonly property string font: Config.fontFamily

    BackgroundLayer {
        id: background
        anchors.fill: parent
    }
}