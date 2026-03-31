import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

import "./"

import "../services"
import "../components"
import "../config"
import "../utils"

Item {
    id: root

    readonly property int animationDuration: 450

    property string openedScreenName: ""
    readonly property bool opened: openedScreenName !== ""
    property bool fullyClosed: false

    property var topBarComponent: null
    readonly property real statusWidth: topBarComponent ? topBarComponent.statusWidth : 0
    readonly property real statusHeight: topBarComponent ? topBarComponent.barHeight : 0
    readonly property int radius: HyprlandConfig.radius
    readonly property int fullRadius: HyprlandConfig.radiusFull
    readonly property color backgroundColor: Config.isOled ? "#000000" : Colors.background

    //Default properties for our animations
    readonly property real defaultWidth: statusWidth
    readonly property real defaultHeight: statusHeight
    readonly property real finalWidth: 340

    Component.onCompleted: {
        console.info("Loaded component: [NotificationsCenter]")
        //console.log("-------------------------------------------------  -->", Screen.height) // Debugging line to check if notificationsCenterRoot is defined
    }

    //Set the Clock component from the  top bar opacity to zero when the control center is opened to avoid having two clocks visible during the animation

    Variants {
        model: Quickshell.screens

    PanelWindow {
        id: notificationsCenterRoot

        property var modelData
        screen: modelData

        readonly property bool isOpened: root.openedScreenName === modelData.name
        readonly property bool localFullyClosed: !(layer.width === root.defaultWidth && layer.height === root.defaultHeight)

        WlrLayershell.namespace: "quickshell:notificationsCenter"
        WlrLayershell.layer: localFullyClosed ? WlrLayer.Top : WlrLayer.Bottom
        WlrLayershell.exclusiveZone: 0
        WlrLayershell.keyboardFocus: isOpened ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        margins { 
            top: (statusHeight * -1) 
        }

        implicitWidth: 340

        visible: true
        color: "transparent"

        anchors {
            top: true
            right: true
            bottom: true
        }

        HyprlandFocusGrab {
            id: grab
            windows: [ notificationsCenterRoot ]
            active: isOpened
            onCleared: {
                console.log("Focus grab cleared, closing Notifications Center")
                root.close()
            }
        }

        Item {
            focus: isOpened
            Keys.onEscapePressed: root.close()
        }

        Item {
            id: layer

            width: isOpened ? root.finalWidth : root.defaultWidth
            height: isOpened ? modelData.height : root.defaultHeight

            Behavior on width { 
                NumberAnimation { 
                    duration: root.animationDuration; 
                    easing.type: Easing.InOutQuint 
                } 
            }
            Behavior on height { 
                NumberAnimation { 
                    duration: root.animationDuration; 
                    easing.type: Easing.InOutQuint 
                } 
            }

            anchors {
                top: parent.top
                right: parent.right
            }

            Row {
                id: horizontalContent

                width: parent.width
                height: parent.height

                InvertedCorner {
                    id: invertedCorner
                    corner: InvertedCorner.Corner.TopRight
                    cornerRadius: isOpened ? root.fullRadius : root.radius
                    cornerColor: root.backgroundColor
                    Behavior on cornerRadius { 
                        NumberAnimation { 
                            duration: root.animationDuration; 
                            easing.type: Easing.InOutQuint 
                        } 
                    }
                }

                Rectangle {
                    id: container
                    width: parent.width
                    height: parent.height
                    //from 0% to 50% of animation, increase radios from root.radius to (root.radius * 10), then, from 50 to 100%, decrease to zero
                    bottomLeftRadius: 
                        isOpened ?
                            (layer.width < root.finalWidth / 2) ?
                                350 : 0
                            :
                            root.radius
                        /*(layer.width < root.finalWidth / 2) ?
                            root.opened ?
                                (root.finalWidth / 2 - layer.width) :
                                (root.finalWidth / 2 - layer.width)
                            :
                            (layer.width > root.finalWidth / 2) ?
                                0 :
                                root.radius */
                    color: root.backgroundColor
                    Behavior on bottomLeftRadius { 
                        NumberAnimation { 
                            duration: root.animationDuration; 
                            easing.type: Easing.InOutQuint 
                        } 
                    }
                }
            }

            InvertedCorner {
                corner: InvertedCorner.Corner.TopRight
                cornerRadius: root.fullRadius
                cornerColor: root.backgroundColor
                anchors.top: parent.top
                anchors.right: parent.right
            }

            InvertedCorner {
                id: invertedCornerBottomLeft
                corner: InvertedCorner.Corner.BottomRight
                cornerRadius: root.fullRadius
                cornerColor: root.backgroundColor
                anchors.bottom: parent.bottom
                opacity: (layer.width == root.finalWidth)
                x: (layer.width == root.finalWidth) ? 0 : root.fullRadius
                //anchors.right: layer.x
                Behavior on x { 
                    NumberAnimation { 
                        duration: (root.animationDuration / 4); 
                        easing.type: Easing.InOutQuint 
                    } 
                }
            }
        }

        //Click area to toggle opened state for testing (on top right)
        MouseArea {
            width: root.statusWidth - root.radius
            height: root.statusHeight
            cursorShape: Qt.PointingHandCursor
            anchors {
                top: parent.top
                right: parent.right
            }
            onClicked: {
                console.log("Toggling Notifications Center from status area click")
                root.toggle()
            }
        }
    
        //TODO: escape key close
        /*Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) {
                console.log("Closing Notifications Center from Escape key")
                controlCenterRoot.hide();
            }
        }*/
    } // end PanelWindow

    } // Variants

    function toggle() {
        //console.log("Toggling Notifications Center state")
        !root.opened ? root.open() : root.close()
    }
    function close() {
        console.log("Closing Notifications Center")
        root.openedScreenName = ""
    }
    function open() {
        console.log("Opening Notifications Center")
        root.openedScreenName = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : ""
    }

    IpcHandler { 
        target: "notificationsCenter"; 
        function toggle(): void { 
            root.toggle(); 
        }
        function close(): void { 
            root.close(); 
        }
        function open(): void { 
            root.open(); 
        } 
    }
    
    GlobalShortcut {
        name: "notificationsCenterToggle"
        description: "Toggle Notifications Center"
        onPressed: {
            //console.log("Toggling Notifications Center")
            //call the toggle ipc function to ensure consistent behavior
            root.toggle()
        }
    }
    /*GlobalShortcut {
        name: "notificationsCenterOpen"
        description: "Open Notifications Center"
        onPressed: {
            //console.log("Opening Notifications Center")
            root.open()
        }
    }
    GlobalShortcut {
        name: "notificationsCenterClose"
        description: "Close Notifications Center"
        onPressed: {
            //console.log("Closing Notifications Center")
            root.close()
        }
    }*/
}