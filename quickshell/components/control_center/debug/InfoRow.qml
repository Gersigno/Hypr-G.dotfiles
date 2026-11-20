import QtQuick

import "../../../utils"

Row {
    id: root

    property string label: ""
    property string value: ""

    width: parent.width
    spacing: 12

    Text {
        width: 260
        text: root.label
        color: Colors.on_surface_variant
        font.pixelSize: 12
        elide: Text.ElideRight
    }

    Text {
        width: Math.max(0, root.width - 260 - root.spacing)
        text: root.value
        color: Colors.on_surface
        font.pixelSize: 12
        wrapMode: Text.WrapAnywhere
    }
}
