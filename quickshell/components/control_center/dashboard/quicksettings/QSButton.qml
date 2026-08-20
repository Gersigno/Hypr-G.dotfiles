import Quickshell
import QtQuick

import "../../../../utils"
import "../../../../services"
import qs.services

Item {
    id: root

    enum Severity { Primary, Secondary, Warning, Danger }
    property int severity: 0
    property bool disabled: false

    property alias topIcon: topIcon.text
    property alias text: label.text
    property alias description: desc.text

    property var options: []
    property bool expanded: false
    property var overrideAction: undefined
    property string expandIcon: "⋯"

    signal clicked
    signal optionSelected(string option)

    property color backgroundColor:
        severity === 0 ? Colors.primary :
        severity === 1 ? Colors.surface_container_high :
        severity === 2 ? Colors.error :
        severity === 3 ? Colors.error_container :
        Colors.primary

    property color textColor:
        severity === 0 ? Colors.on_primary :
        severity === 1 ? Colors.on_surface :
        severity === 2 ? Colors.on_error :
        severity === 3 ? Colors.on_error_container :
        Colors.on_primary

    readonly property color borderTopColor: Qt.hsla(
        backgroundColor.hslHue,
        backgroundColor.hslSaturation,
        Math.min(backgroundColor.hslLightness + 0.1, 1.0),
        backgroundColor.a
    )

    readonly property color borderBottomColor: Qt.tint(backgroundColor, "#40000000")

    readonly property color hoverBackgroundColor: Qt.hsla(
        backgroundColor.hslHue,
        backgroundColor.hslSaturation,
        Math.min(backgroundColor.hslLightness + 0.05, 1.0),
        backgroundColor.a
    )

    readonly property bool hasOptions: options.length > 0
    readonly property bool showExpandButton: hasOptions || overrideAction !== undefined

    implicitWidth: content.implicitWidth + 16
    implicitHeight: content.implicitHeight + 16

    Rectangle {
        id: externalBorder
        anchors.fill: parent
        color: root.borderBottomColor
        radius: HyprlandConfig.radius
        opacity: root.disabled ? 0.5 : 1.0

        Rectangle {
            id: topBorderLayer
            anchors.fill: parent
            anchors.bottomMargin: mouseArea.containsMouse ? 2 : 1
            color: root.borderTopColor
            radius: externalBorder.radius > 0 ? externalBorder.radius - 1 : 0

            Behavior on anchors.bottomMargin {
                NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
            }

            Rectangle {
                id: innerBackground
                anchors.fill: parent
                anchors.topMargin: 1
                anchors.bottomMargin: 0
                color: mouseArea.containsMouse ? root.hoverBackgroundColor : root.backgroundColor
                radius: topBorderLayer.radius > 0 ? topBorderLayer.radius - 1 : 0

                Behavior on color {
                    ColorAnimation { duration: 150; easing.type: Easing.InOutQuad }
                }

                Column {
                    id: content
                    spacing: 4

                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 8
                    anchors.leftMargin: 8
                    anchors.rightMargin: 28

                    Text {
                        id: topIcon
                        font.pixelSize: 13
                        font.family: Settings.fontFamily
                        color: root.textColor
                        font.bold: (root.severity === 0)
                    }

                    Text {
                        id: label
                        font.pixelSize: 13
                        font.family: Settings.fontFamily
                        color: root.textColor
                        font.bold: (root.severity === 0)
                    }

                    Text {
                        id: desc
                        font.pixelSize: 11
                        font.family: Settings.fontFamily
                        color: root.textColor
                        opacity: 0.7
                        font.bold: (root.severity === 0)
                    }
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: !root.disabled
            cursorShape: !root.disabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: if (!root.disabled) root.clicked()
        }

        Text {
            id: expandArrow
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 6
            anchors.topMargin: root.expandIcon === "⋯" ? 0 : 6
            text: root.expanded ? "✕" : root.expandIcon
            font.pixelSize: expandArea.containsMouse ? 13 : 11
            font.family: Settings.fontFamily
            color: root.textColor
            visible: root.showExpandButton
        }

        MouseArea {
            id: expandArea
            anchors.right: parent.right
            //anchors.verticalCenter: parent.verticalCenter
            width: 20
            height: 20
            anchors.rightMargin: 2
            visible: root.showExpandButton
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (!root.disabled) {
                    if (root.overrideAction !== undefined) {
                        root.overrideAction()
                    } else {
                        root.expanded = !root.expanded
                    }
                }
            }
            z: 1
        }
    }

    Item {
        id: overlay
        z: 1000
        visible: root.expanded && root.hasOptions

        property Item hostParent: null
        property real hostX: 0
        property real hostY: 0

        Component.onCompleted: {
            var p = root.parent
            while (p) {
                if (p.isOverlayHost) {
                    hostParent = p
                    overlay.parent = p
                    var g = root.parent.mapToItem(p, 0, 0)
                    hostX = g.x
                    hostY = g.y
                    break
                }
                p = p.parent
            }
        }

        anchors.fill: parent

        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = false
        }

        Rectangle {
            id: menuPanel
            x: root.x//absolute position of button x
            y: (overlay.hostParent ? overlay.hostY + root.y : root.y) 
            width: root.width + 2
            height: 0
            color: Colors.surface_container_high
            radius: HyprlandConfig.radius

            states: [
                State {
                    name: "expanded"
                    when: root.expanded && root.hasOptions
                    PropertyChanges { 
                        target: menuPanel; 
                        y: overlay.hostParent ? overlay.hostY + root.y : root.y; 
                        x: overlay.hostParent ? overlay.hostX - 1 : 0;
                        height: menuContent.height + 16 
                        width: root.parent ? root.parent.width + 2 : 0
                    }
                }
            ]

            /*Behavior on width {
                NumberAnimation { 
                    duration: 600; 
                    easing.type: Easing.OutElastic; 
                    easing.period: 0.6; 
                    easing.amplitude: 0.2 
                }
            }*/

            transitions: [
                Transition {
                    to: "expanded"
                    /*NumberAnimation { 
                        property: "y"; 
                        duration: 600; 
                        easing.type: Easing.OutElastic; 
                        easing.period: 0.6; 
                        easing.amplitude: 0.2 
                    }*/
                    NumberAnimation { 
                        property: "x"; 
                        duration: 600; 
                        easing.type: Easing.OutElastic; 
                        easing.period: 0.6; 
                        easing.amplitude: 0.2 
                    }
                    NumberAnimation { 
                        property: "height"; 
                        duration: 600; 
                        easing.type: Easing.OutElastic; 
                        easing.period: 0.6; 
                        easing.amplitude: 0.2 
                    }
                    NumberAnimation { 
                        property: "width"; 
                        duration: 600; 
                        easing.type: Easing.OutElastic; 
                        easing.period: 0.6; 
                        easing.amplitude: 0.2 
                    }
                }
            ]

            Column {
                id: menuContent
                x: 8
                y: 8
                width: parent.width - 16
                spacing: 4

                Item {
                    height: 20
                    width: parent.width

                    Text {
                        id: menuIcon
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.topIcon
                        font.pixelSize: 13
                        font.family: Settings.fontFamily
                        color: root.textColor
                        font.bold: (root.severity === 0)
                    }

                    Text {
                        anchors.left: menuIcon.right
                        anchors.leftMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        text: label.text
                        font.pixelSize: 13
                        font.family: Settings.fontFamily
                        color: root.textColor
                        font.bold: true
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: "✕"
                        font.pixelSize: 12
                        font.family: Settings.fontFamily
                        color: root.textColor
                        opacity: 0.7

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.expanded = false
                        }
                    }
                }

                Rectangle {
                    height: 1
                    width: parent.width
                    color: Qt.rgba(1, 1, 1, 0.15)
                }

                Repeater {
                    model: options

                    delegate: Item {
                        height: 32
                        width: parent.width

                        Rectangle {
                            anchors.fill: parent
                            radius: HyprlandConfig.radius - 2
                            color: optMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData
                                font.pixelSize: 13
                                font.family: Settings.fontFamily
                                color: root.textColor
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: optMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.optionSelected(modelData)
                                root.expanded = false
                            }
                        }
                    }
                }
            }
        }
    }
}
