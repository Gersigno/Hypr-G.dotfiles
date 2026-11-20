import QtQuick

import "../../../utils"

import "../../common/interface"

Rectangle {
    id: page

    color: "transparent"
    clip: true

    BackgroundLayer {
        anchors.fill: parent
    }

    readonly property color textColor: Colors.on_surface_variant

    readonly property var colorKeys: [
        "background",        "error",                    "error_container",
        "inverse_on_surface","inverse_primary",          "inverse_surface", 
        "on_background",     "on_error",                 "on_error_container",
        "on_primary",        "on_primary_container",     "on_primary_fixed",
        "on_primary_fixed_variant",
        "on_secondary",      "on_secondary_container",   "on_secondary_fixed",
        "on_secondary_fixed_variant",
        "on_surface",        "on_surface_variant",
        "on_tertiary",       "on_tertiary_container",    "on_tertiary_fixed",
        "on_tertiary_fixed_variant",
        "outline",           "outline_variant",
        "primary",           "primary_container",        "primary_fixed",
        "primary_fixed_dim",
        "scrim",             "secondary",                "secondary_container",
        "secondary_fixed",   "secondary_fixed_dim",      "shadow",
        "source_color",      "surface",                  "surface_bright",
        "surface_container", "surface_container_high",   "surface_container_highest",
        "surface_container_low","surface_container_lowest","surface_dim",
        "surface_tint",      "surface_variant",
        "tertiary",          "tertiary_container",       "tertiary_fixed",
        "tertiary_fixed_dim"
    ]

    Flickable {
        anchors.fill: parent
        anchors.margins: 16
        contentHeight: colorColumn.implicitHeight
        clip: true

        Column {
            id: colorColumn
            width: parent.width
            spacing: 6

            Repeater {
                model: page.colorKeys

                Row {
                    width: colorColumn.width
                    height: 28
                    spacing: 12

                    Text {
                        width: 250
                        height: parent.height
                        text: modelData
                        color: page.textColor
                        font.pixelSize: 12
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        width: 180
                        height: parent.height
                        radius: 4
                        color: Colors[modelData]

                        Text {
                            anchors.centerIn: parent
                            text: Colors[modelData].toString().toUpperCase()
                            font.pixelSize: 11
                            color: {
                                const c = Colors[modelData]
                                return (0.299 * c.r + 0.587 * c.g + 0.114 * c.b) > 0.5 ? "#000000" : "#ffffff"
                            }
                        }
                    }
                }
            }
        }
    }
}
