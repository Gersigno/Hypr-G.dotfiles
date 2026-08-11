import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Widgets

import "../../../config"
import "../../../utils"
import "../../../services"

Item {
    id: root

    property string message: ""
    property string icon: ""
    property int duration: 3000
    property real progress: -1
    property real growRatio: 0
    property int anim_duration: 500
    property real shadow_pacity: 0
    property real blur_level: 0

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

    function volumeIcon(prog) {
        if (Audio.sink?.audio?.muted ?? false) return "  ";
        if (prog > 0.75) return " ";
        if (prog > 0.5) return " ";
        if (prog > 0.25) return " ";
        return " ";
    }

    function show(msg, dur, ico, prog) {
        showAnimation.stop()
        hideAnimation.stop()
        container.y = 0
        root.message = msg
        root.duration = dur ?? 3000
        root.icon = ico ?? ""
        root.progress = prog ?? -1
        root.growRatio = 0
        root.opacity = HyprlandConfig.inactiveOpacity
        bottomRectangle     .width = row.implicitWidth + 16 - (HyprlandConfig.radiusFull * 2) 
        bottomRectangle     .height = 0 
        root                .shadow_pacity= 0
        bottomLeftCorner    .cornerRadius = 0
        bottomRightCorner   .cornerRadius = 0
        b2_bottomLeftCorner .cornerRadius = 0
        b2_topRightCorner   .cornerRadius = 0
        hideTimer.stop()
        hideTimer.interval = Math.max(1, root.duration)
        hideTimer.start()
        showAnimation.restart()
    }

    function edit(msg, dur, ico, prog) {
        if(hideTimer.running) {
            //Toast exist, edit it
            showAnimation.stop()
            root.message = msg
            root.duration = dur ?? 3000
            root.icon = ico ?? ""
            root.progress = prog ?? -1
            //reset timer
            hideTimer.stop()
            hideTimer.interval = Math.max(1, root.duration)
            hideTimer.start()
        } else {
            //Toast do not exist, show it 
            show(msg, dur, ico, prog)
        }
    }

    readonly property int quarterDuration: anim_duration / 4
    readonly property int halfDuration: anim_duration / 2

    Component.onCompleted: {
        console.log("----------------------------")
        console.log("Parent : " + parent)
        bottomLeftCorner    .cornerRadius = 0
        bottomRightCorner   .cornerRadius = 0
        b_topRightCorner    .cornerRadius = 0
        b_bottomLeftCorner  .cornerRadius = 0
        b2_topRightCorner   .cornerRadius = 0
        b2_bottomLeftCorner .cornerRadius = 0
        root                .shadow_pacity= 0
        bottomRectangle.height = 0
        bottomRectangle.width = row.implicitWidth + 16 - (HyprlandConfig.radiusFull * 2)
    }

    Timer {
        id: hideTimer
        interval: root.duration
        running: false
        repeat: false
        onTriggered: {
            hideTimer.stop()
            //root.opacity = 0
            hideAnimation.restart()
        }
    }

    ParallelAnimation {
        id: hideAnimation
        NumberAnimation {
            target: container
            property: "y"
            from: 0
            to: 500
            duration: root.halfDuration
        }
    }

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
                    duration: root.quarterDuration / 2
                    easing.type: Easing.InCubic
                }
                NumberAnimation {
                    target: bottomRightCorner
                    property: "cornerRadius"
                    from: HyprlandConfig.radiusFull
                    to: 0
                    duration: root.quarterDuration / 2
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
                target: root
                property: "growRatio"
                from: 0
                to: 1
                duration: root.halfDuration
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: root
                property: "blur_level"
                from: 1.5
                to: 0
                duration: root.halfDuration
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
                        //easing.type: Easing.OutElastic
                        //easing.period: 1.5
                        //easing.amplitude: 0.2 
                    }
                    NumberAnimation {
                        target: bottomRectangle
                        property: "width"
                        from: row.implicitWidth + 16 - (HyprlandConfig.radiusFull * 2)
                        to: 0
                        duration: root.halfDuration //+ (root.quarterDuration /2)
                        easing.type: Easing.InOutQuad
                    }
                    SequentialAnimation {
                        //First, grow the 4 bottom angles from 0 to radiusFull
                        ParallelAnimation {
                            NumberAnimation {
                                target: b_topRightCorner
                                property: "cornerRadius"
                                from: 0
                                to: HyprlandConfig.radiusFull
                                duration: root.halfDuration / 2
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                target: b_bottomLeftCorner
                                property: "cornerRadius"
                                from: 0
                                to: HyprlandConfig.radiusFull
                                duration: root.halfDuration / 2
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                target: b2_topRightCorner
                                property: "cornerRadius"
                                from: 0
                                to: HyprlandConfig.radiusFull
                                duration: root.halfDuration / 2
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                target: b2_bottomLeftCorner
                                property: "cornerRadius"
                                from: 0
                                to: HyprlandConfig.radiusFull
                                duration: root.halfDuration / 2
                                easing.type: Easing.OutCubic
                            }
                        }
                        //Then, shrink the 4 bottom angles back to 0
                        ParallelAnimation {
                            NumberAnimation {
                                target: b_topRightCorner
                                property: "cornerRadius"
                                from: HyprlandConfig.radiusFull
                                to: 0
                                duration: root.halfDuration / 2
                                easing.type: Easing.InCubic
                            }
                            NumberAnimation {
                                target: b_bottomLeftCorner
                                property: "cornerRadius"
                                from: HyprlandConfig.radiusFull
                                to: 0
                                duration: root.halfDuration / 2
                                easing.type: Easing.InCubic
                            }
                            NumberAnimation {
                                target: b2_topRightCorner
                                property: "cornerRadius"
                                from: HyprlandConfig.radiusFull
                                to: 0
                                duration: root.halfDuration / 2
                                easing.type: Easing.InCubic
                            }
                            NumberAnimation {
                                target: b2_bottomLeftCorner
                                property: "cornerRadius"
                                from: HyprlandConfig.radiusFull
                                to: 0
                                duration: root.halfDuration / 2
                                easing.type: Easing.InCubic
                            }
                            NumberAnimation {
                                target: root
                                property: "shadow_pacity"
                                from: 0
                                to: 1
                                duration: root.halfDuration
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            } 
            /*PauseAnimation {
                duration: root.halfDuration
            }
            NumberAnimation {
                target: root
                property: "shadow_pacity"
                from: 0
                to: 8
                duration: root.duration
                easing.type: Easing.OutCubic 
            }*/
        }
    }

    //Main layer (vertical)
    Item {
        id: main
        width: 400//Math.max(toastRow.width, bottomRow.width)
        height: 800//toastRow.height + bottomRow.height
        anchors.bottom: root.bottom
        anchors.horizontalCenter: root.horizontalCenter


        //Toast layer (bottom corners grow/shrink)
        RowLayout {
            id: toastRow
            spacing: 0

            anchors.bottom: bottomRow.top
            anchors.horizontalCenter: parent.horizontalCenter

            InvertedCorner {
                id: bottomLeftCorner
                corner: InvertedCorner.Corner.BottomRight
                cornerColor: root.backgroundColor
                Layout.alignment: Qt.AlignBottom
            }
            ClippingRectangle {
                id: container
                topLeftRadius: HyprlandConfig.radiusFull
                topRightRadius: HyprlandConfig.radiusFull
                color: root.backgroundColor
                implicitWidth: root.growRatio * (row.implicitWidth + 16)
                implicitHeight: root.growRatio * (row.implicitHeight + 16)

                Behavior on implicitWidth {
                    enabled: root.growRatio >= 1
                    NumberAnimation { duration: root.halfDuration / 2; easing.type: Easing.OutCubic }
                }
                Behavior on implicitHeight {
                    enabled: root.growRatio >= 1
                    NumberAnimation { duration: root.halfDuration / 2; easing.type: Easing.OutCubic }
                }

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: root.shadow //"red"
                    shadowBlur: 2
                    shadowHorizontalOffset: 0
                    shadowVerticalOffset: 8
                    shadowOpacity: shadow_pacity
                }
        
                RowLayout {
                    id: row
                    anchors.centerIn: parent
                    spacing: 8
                    opacity: 1 + (root.blur_level * -1) 

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blur: blur_level
                    }
                    

                    ClippingRectangle {
                        width: 32
                        height: 32
                        color: "transparent" //Colors.primary
                        radius: HyprlandConfig.radiusFull - 8 //minus spacing for perfect angle

                        visible: root.icon !== ""

                        Image {
                            anchors.fill: parent
                            source: root.icon
                            fillMode: Image.PreserveAspectFit

                            visible: root.icon !== ""
                        }
                    }
                    Text {
                        text: root.progress >= 0 ? root.volumeIcon(root.progress) + "  " + Math.round(root.progress * 100) + "%" : root.message
                        font.pixelSize: 13
                        font.family: root.font
                        color: root.foregroundColor
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Rectangle { // progress track
                        id: progressTrack
                        visible: root.progress >= 0
                        width: 64
                        height: 4
                        radius: 2
                        color: Qt.rgba(root.foregroundColor.r, root.foregroundColor.g, root.foregroundColor.b, 0.2)
                        Layout.alignment: Qt.AlignVCenter

                        Rectangle { // progress fill
                            width: parent.width * Math.max(0, Math.min(1, root.progress))
                            height: parent.height
                            radius: 2
                            color: Colors.primary

                            Behavior on width {
                                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                            }
                        }
                    }
                }
            }
            InvertedCorner {
                id: bottomRightCorner
                corner: InvertedCorner.Corner.BottomLeft
                cornerRadius: HyprlandConfig.radiusFull
                cornerColor: root.backgroundColor
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
                color: root.backgroundColor
                width: row.implicitWidth + 16 - (HyprlandConfig.radiusFull * 2)
                //height: 32
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom

            } 

            //left inverted corners, don't affect size 
            InvertedCorner {
                id: b_topRightCorner
                corner: InvertedCorner.Corner.TopLeft
                cornerColor: root.backgroundColor
                anchors.top: bottomRectangle.top
                anchors.left: bottomRectangle.right
            }
            InvertedCorner {
                id: b_bottomLeftCorner
                corner: InvertedCorner.Corner.BottomLeft
                cornerColor: root.backgroundColor
                anchors.bottom: bottomRectangle.bottom
                anchors.left: bottomRectangle.right
            }
            InvertedCorner {
                id: b2_topRightCorner
                corner: InvertedCorner.Corner.TopRight
                cornerColor: root.backgroundColor
                anchors.top: bottomRectangle.top
                anchors.right: bottomRectangle.left
            }
            InvertedCorner {
                id: b2_bottomLeftCorner
                corner: InvertedCorner.Corner.BottomRight
                cornerColor: root.backgroundColor
                anchors.bottom: bottomRectangle.bottom
                anchors.right: bottomRectangle.left
            }
        }
    }
}
 
