import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import "../../../config"
import "../../../utils"
import "../../../services"

Item {
    id: root

    property string message: ""
    property string icon: ""
    property int duration: 3000
    property int anim_duration: 8000

    readonly property color surface_container_high: Colors.surface_container_high
    readonly property color shadow: Colors.shadow
    readonly property color on_surface: Colors.on_surface

    readonly property color backgroundColor: Config.isOled ? "#000" : Colors.background
    readonly property color foregroundColor: Config.isOled ? "#fff" : Colors.on_background
    readonly property int radius: HyprlandConfig.radius
    readonly property string font: Config.fontFamily

    //width: 400//main.implicitWidth
    height: 400//main.implicitHeight

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    //anchors.bottomMargin: 24

    opacity: 0
    visible: opacity > 0




    /*transform: Translate {
        id: slideTranslate
        x: 16
    }*/ 

    function show(msg, dur, ico) {
        root.message = msg
        root.duration = dur ?? 3000
        root.icon = ico ?? ""
        root.opacity = HyprlandConfig.inactiveOpacity
        bottomRectangle.width = 0
        //bottomRectangle.height = row.implicitWidth + 16 - (HyprlandConfig.radiusFull * 2)
        container.implicitWidth = 0
        container.implicitHeight = 0
        bottomLeftCorner.cornerRadius = 0
        bottomRightCorner.cornerRadius = 0
        showAnimation.restart()
    }

    readonly property int quarterDuration: anim_duration / 4
    readonly property int halfDuration: anim_duration / 2

    Component.onCompleted: {
        console.log("----------------------------")
        console.log("Parent : " + parent)
        /*bottomLeftCorner  .cornerRadius = 0
        bottomRightCorner .cornerRadius = 0
        b_topRightCorner    .cornerRadius = 0
        b_bottomLeftCorner  .cornerRadius = 0
        b2_topRightCorner   .cornerRadius = 0
        b2_bottomLeftCorner .cornerRadius = 0
        bottomRectangle.height = 0
        bottomRectangle.width = row.implicitWidth + 16 - (HyprlandConfig.radiusFull * 2)*/ 
    }

    Timer {
        id: hideTimer
        interval: root.duration 
        running: false
        repeat: false
        onTriggered: root.opacity = 0
    }

    /*Behavior on opacity {
        NumberAnimation {
            duration: root.anim_duration
            easing.type: Easing.InOutQuad
        }
    }*/

    ParallelAnimation {
        id: showAnimation

        //Corner sequence (bottom corners grow then shrink)
        SequentialAnimation {
            //Step 1: bottom corners grow from 0 to radiusFull
            ParallelAnimation {
                NumberAnimation {
                    target: bottomLeftCorner
                    property: "cornerRadius"
                    from: 0 
                    to: HyprlandConfig.radiusFull
                    duration: root.quarterDuration / 2
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: bottomRightCorner
                    property: "cornerRadius"
                    from: 0
                    to: HyprlandConfig.radiusFull
                    duration: root.quarterDuration / 2
                    easing.type: Easing.OutCubic
                }
            }

            //Step 2: bottom corners shrink back to 0
            ParallelAnimation { 
                NumberAnimation {
                    target: bottomLeftCorner
                    property: "cornerRadius"
                    from: HyprlandConfig.radiusFull
                    to: 0
                    duration: root.quarterDuration
                    easing.type: Easing.InCubic
                }
                NumberAnimation {
                    target: bottomRightCorner
                    property: "cornerRadius"
                    from: HyprlandConfig.radiusFull
                    to: 0
                    duration: root.quarterDuration
                    easing.type: Easing.InCubic
                }
            }

            //Step 3: bottom corners grow back to radiusFull
            ParallelAnimation {
                NumberAnimation {
                    target: container
                    property: "bottomLeftRadius"
                    from: 0
                    to: HyprlandConfig.radiusFull
                    duration: root.quarterDuration / 2
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: container
                    property: "bottomRightRadius"
                    from: 0
                    to: HyprlandConfig.radiusFull
                    duration: root.quarterDuration / 2
                    easing.type: Easing.OutCubic
                }
            } 

            //Steop 4 
            
        }

        //Container growth, run in parallel (asynchronous)
        ParallelAnimation {
            NumberAnimation {
                target: container
                property: "implicitHeight"
                from: 0
                to: row.implicitHeight + 16
                duration: root.halfDuration
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: container
                property: "implicitWidth"
                from: 0
                to: row.implicitWidth + 16
                duration: root.halfDuration
                easing.type: Easing.OutCubic
            }

            //Commence apres un délai de 1/4 de la durée totale de l'animation 
            SequentialAnimation {
                PauseAnimation {
                    duration: root.halfDuration / 1.5
                }
                ParallelAnimation {
                    NumberAnimation {
                        target: bottomRectangle
                        property: "height"
                        from: 0
                        to: 32
                        duration: root.halfDuration
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: bottomRectangle
                        property: "width"
                        from: row.implicitWidth + 16 - (HyprlandConfig.radiusFull * 2)
                        to: 0
                        duration: root.halfDuration
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }

    //Main layer (vertical)
    Item {
        id: main
        width: 400//Math.max(toastRow.width, bottomRow.width)
        height: 800//toastRow.height + bottomRow.height
        anchors.bottom: root.bottom
        anchors.horizontalCenter: root.horizontalCenter

        Rectangle {
            id: background
            anchors.fill: parent
            color: "blue"
        }

        //Toast layer (bottom corners grow/shrink)
        RowLayout {
            id: toastRow
            spacing: 0

            anchors.bottom: bottomRow.top
            anchors.horizontalCenter: parent.horizontalCenter

            InvertedCorner {
                id: bottomLeftCorner
                corner: InvertedCorner.Corner.BottomRight
                cornerColor: "red"
                Layout.alignment: Qt.AlignBottom
            }
            Rectangle {
                id: container
                topLeftRadius: HyprlandConfig.radiusFull
                topRightRadius: HyprlandConfig.radiusFull
                color: "red"//root.backgroundColor

                /*layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: root.shadow //"red"//HyprlandConfig.shadowColor
                    shadowBlur: 2
                    shadowHorizontalOffset: 0
                    shadowVerticalOffset: 8
                    //radius: container.radius
                    //paddingEnabled: true
                }*/
        
                RowLayout {
                    id: row
                    anchors.centerIn: parent
                    spacing: 8

                    Rectangle {
                        width: 32
                        height: 32
                        color: "transparent" //Colors.primary

                        visible: root.icon !== ""

                        Image {
                            anchors.fill: parent
                            source: root.icon
                            fillMode: Image.PreserveAspectFit

                            visible: root.icon !== ""
                        }
                    }
                    Text {
                        text: root.message
                        font.pixelSize: 13
                        font.family: root.font
                        color: root.foregroundColor
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }
            InvertedCorner {
                id: bottomRightCorner
                corner: InvertedCorner.Corner.BottomLeft
                cornerRadius: HyprlandConfig.radiusFull
                cornerColor: "red"
                Layout.alignment: Qt.AlignBottom
            }
        }

        //Bottom section with the inverted corner radius for the 2nd part of the animation
        Item {
            id: bottomRow
            width: bottomRectangle.width
            height: bottomRectangle.height

            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                id: bottomRectangle
                //center empty layout
                color: "yellow"
                width: row.implicitWidth + 16 - (HyprlandConfig.radiusFull * 2)
                //height: 32
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom

            } 

            //left inverted corners, don't affect size 
            InvertedCorner {
                id: b_topRightCorner
                corner: InvertedCorner.Corner.TopRight
                cornerColor: "blue"
                anchors.top: bottomRectangle.top
                anchors.left: bottomRectangle.left
            }
            InvertedCorner {
                id: b_bottomLeftCorner
                corner: InvertedCorner.Corner.BottomRight
                cornerColor: "green"
                anchors.top: bottomRectangle.top
                anchors.left: bottomRectangle.left
            }
            InvertedCorner {
                id: b2_topRightCorner
                corner: InvertedCorner.Corner.TopLeft
                cornerColor: "blue"
                anchors.top: bottomRectangle.top
                anchors.right: bottomRectangle.right
            }
            InvertedCorner {
                id: b2_bottomLeftCorner
                corner: InvertedCorner.Corner.BottomLeft
                cornerColor: "green"
                anchors.top: bottomRectangle.top
                anchors.right: bottomRectangle.right
            }
        }
    }
}
 
