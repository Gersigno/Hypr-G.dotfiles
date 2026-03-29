import QtQuick
import QtQuick.Controls
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

import "../services"
import "../components"
import "../config"
import "../components/control_center" as ControlCenterComponents

Item {
    id: root

    property bool opened: false
    property bool fullyClosed: false
    readonly property int animationDuration: 450

    property var topBarComponent: null
    readonly property real clockWidth: topBarComponent ? topBarComponent.clockWidth : 0
    readonly property real clockHeight: topBarComponent ? topBarComponent.barHeight : 0
    readonly property int radius: HyprlandConfig.radius
    readonly property int fullRadius: HyprlandConfig.radiusFull
    readonly property color backgroundColor: Config.isOled ? "#000" : Colors.background

    readonly property real defaultWidth: clockWidth + (radius * 2)
    readonly property real defaultHeight: clockHeight

    Component.onCompleted: {
        console.info("Loaded component: [ControlCenter]")
    }

    Binding {
        target: root
        property: "fullyClosed"
        value: !(container.height === root.defaultHeight)
        restoreMode: Binding.RestoreBindingOrValue
    }

    //Set the Clock component from the  top bar opacity to zero when the control center is opened to avoid having two clocks visible during the animation
    /*Binding {
        target: topBarComponent
        property: "clockComponent.visible"
        value: root.opened ? false : true
        restoreMode: Binding.RestoreBindingOrValue
    }*/
    
    PanelWindow {
        id: controlCenterRoot

        property var modelData
        screen: modelData

        WlrLayershell.namespace: "quickshell:controlCenter"
        WlrLayershell.layer: root.fullyClosed ? WlrLayer.Top : WlrLayer.Bottom
        WlrLayershell.exclusiveZone: 0
        //WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        margins { 
            top: (clockHeight * -1) 
        }

        Component.onCompleted: {
            const activeScreen = Hyprland.focusedMonitor;
            console.log(activeScreen)
            if (activeScreen) {
                controlCenterRoot.implicitWidth = activeScreen.width
                controlCenterRoot.implicitHeight = activeScreen.height
                console.log("Active screen dimensions:", activeScreen.width, "x", activeScreen.height);
            } else {
                console.warn("No active screen found. Control Center may not display correctly.");
            }
        }

        anchors {
            top: true
        }

        mask: Region {
            item: container
        }

        color: "transparent"
        
        Row {
            id: container

            width: topLeftCorner.width + contentContainer.width + topRightCorner.width
            //align row to center of control center root
            anchors.horizontalCenter: parent.horizontalCenter
            //height: parent.height

            InvertedCorner {
                id: topLeftCorner
                corner: InvertedCorner.Corner.TopRight
                cornerRadius: root.opened ? root.fullRadius : root.radius
                cornerColor: root.backgroundColor

                Behavior on cornerRadius {
                    NumberAnimation { 
                        duration: root.animationDuration; 
                        easing.type: Easing.InOutQuint 
                    }
                }
            }

            Rectangle {
                id: contentContainer
                width: root.opened
                    ? Math.max(carousel.currentItem && carousel.currentItem.item ? carousel.currentItem.item.implicitWidth : root.defaultWidth, root.defaultWidth)
                    : root.defaultWidth
                height: root.opened
                    ? (carousel.currentItem && carousel.currentItem.item ? carousel.currentItem.item.implicitHeight : 0) + tabBar.height
                    : root.defaultHeight
                color: root.backgroundColor
                bottomLeftRadius: root.opened ? root.fullRadius : root.radius
                bottomRightRadius: root.opened ? root.fullRadius : root.radius
                //clip: true

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
                Behavior on bottomLeftRadius {
                    NumberAnimation { 
                        duration: root.animationDuration; 
                        easing.type: Easing.InOutQuint 
                    }
                }
                Behavior on bottomRightRadius {
                    NumberAnimation { 
                        duration: root.animationDuration; 
                        easing.type: Easing.InOutQuint 
                    }
                }

                //Content
                FolderListModel {
                    id: ccFilesModel
                    folder: Qt.resolvedUrl("../components/control_center")
                    nameFilters: ["*.qml"]
                    showDirs: false
                }

                SwipeView {
                    id: carousel
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: tabBar.top
                    visible: root.opened
                    clip: true

                    Repeater {
                        model: ccFilesModel

                        Loader {
                            width: carousel.width
                            height: carousel.height
                            source: model.fileUrl
                        }
                    }
                }

                // Separator
                Rectangle {
                    anchors.bottom: tabBar.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: visible ? 1 : 0
                    visible: root.opened
                    color: Qt.rgba(1, 1, 1, 0.08)
                }

                // Tab navigation bar
                Row {
                    id: tabBar
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 40
                    visible: root.opened

                    Repeater {
                        model: ccFilesModel

                        delegate: Item {
                            width: tabBar.width / Math.max(ccFilesModel.count, 1)
                            height: tabBar.height

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 4
                                radius: root.fullRadius - 4
                                color: carousel.currentIndex === index ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: model.fileName.replace(".qml", "")
                                color: "white"
                                opacity: carousel.currentIndex === index ? 1.0 : 0.45
                                font.pixelSize: 12
                                Behavior on opacity {
                                    NumberAnimation { duration: 150 }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: carousel.currentIndex = index
                            }
                        }
                    }
                }
            }

            InvertedCorner {
                id: topRightCorner
                corner: InvertedCorner.Corner.TopLeft
                cornerRadius: root.opened ? root.fullRadius : root.radius
                cornerColor: root.backgroundColor
                x: contentContainer.width + topLeftCorner.width
                Behavior on cornerRadius {
                    NumberAnimation { 
                        duration: root.animationDuration; 
                        easing.type: Easing.InOutQuint 
                    }
                }
            }
        }

        MouseArea {
            width: container.width
            height: root.defaultHeight
            x: container.x
            y: container.y

            cursorShape: Qt.PointingHandCursor

            onClicked: root.toggle()
        }
    }
    

    IpcHandler {
        target: "controlCenter"
        function toggle(): void {
            root.toggle()
        }
        function open(): void {
            root.open()
        }
        function close(): void {
            root.close()
        }
    }

    function toggle() {
        !root.opened ? root.open() : root.close()
    }
    function close() {
        console.log("Closing Control Center")
        root.opened = false
    }
    function open() {
        console.log("Opening Control Center")
        root.opened = true
    }

    GlobalShortcut {
        name: "controlCenterToggle"
        description: "Toggle Control Center"
        onPressed: {
            root.toggle()
        }
    }
}