import QtQuick
import Quickshell

import qs.services
import "../../../utils"
import "../../common/interface"

Item {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property color iconColor: Colors.primary
    property color titleColor: Colors.on_background
    property color subtitleColor: Colors.on_surface_variant
    property string fontFamily: Settings.fontFamily

    property alias headerRight: headerRightItem.data
    default property alias content: body.data

    BackgroundLayer {
        anchors.fill: parent
    }

    Item {
        id: inner
        anchors.fill: parent
        anchors.margins: 10

        Item {
            id: header
            width: parent.width
            height: 20

            Text {
                id: iconText
                text: root.icon
                color: root.iconColor
                font.family: root.fontFamily
                font.pixelSize: 13
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: titleText
                text: root.title
                color: root.titleColor
                font.family: root.fontFamily
                font.pixelSize: 13
                font.weight: Font.DemiBold
                anchors.verticalCenter: parent.verticalCenter
                x: root.icon !== "" ? iconText.width + 6 : 0
            }

            Text {
                id: subtitleText
                text: root.subtitle
                color: root.subtitleColor
                font.family: root.fontFamily
                font.pixelSize: 10
                anchors.verticalCenter: parent.verticalCenter
                x: titleText.x + titleText.width + 8
                width: Math.max(0, parent.width - x - headerRightItem.width - 8)
                elide: Text.ElideRight
                visible: text !== ""
            }

            Item {
                id: headerRightItem
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height
                width: childrenRect.width
            }
        }

        Item {
            id: body
            anchors.top: header.bottom
            anchors.topMargin: 8
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }
    }
}
