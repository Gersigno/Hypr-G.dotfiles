import QtQuick
import QtQuick.Controls
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

import "../services"
import "../components/common/interface"
import "../config"
import "../utils"
//import "../components/control_center" as ControlCenterComponents

Item {
    id: root

    property string openedScreenName: ""
    readonly property bool opened: openedScreenName !== ""
    readonly property int animationDuration: 450

    property var topBarComponent: null
    readonly property real clockWidth: topBarComponent ? topBarComponent.clockWidth : 0
    readonly property real clockHeight: topBarComponent ? topBarComponent.barHeight : 0
    readonly property int radius: HyprlandConfig.radius
    readonly property int fullRadius: HyprlandConfig.radiusFull
    readonly property color backgroundColor: Config.isOled ? "#000" : Colors.background
    readonly property string familyFont: Config.fontFamily

    readonly property real defaultWidth: clockWidth + (radius * 2)
    readonly property real defaultHeight: clockHeight

    Component.onCompleted: {
        console.info("Loaded component: [ControlCenter]")
    }

    FolderListModel {
        id: ccFilesModel
        folder: Qt.resolvedUrl("../components/control_center")
        nameFilters: ["*.qml"]
        showDirs: false
    }

    //Set the Clock component from the  top bar opacity to zero when the control center is opened to avoid having two clocks visible during the animation
    /*Binding {
        target: topBarComponent
        property: "clockComponent.visible"
        value: root.opened ? false : true
        restoreMode: Binding.RestoreBindingOrValue
    }*/
    
    Variants {
        model: Quickshell.screens

    PanelWindow {
        id: controlCenterRoot

        property var modelData
        screen: modelData

        readonly property bool isOpened: root.openedScreenName === modelData.name
        readonly property bool localFullyClosed: !(container.height === root.defaultHeight)
        property bool modelInitialized: false

        WlrLayershell.namespace: "quickshell:controlCenter"
        WlrLayershell.layer: localFullyClosed ? WlrLayer.Top : WlrLayer.Bottom
        WlrLayershell.exclusiveZone: 0
        WlrLayershell.keyboardFocus: isOpened ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        margins { 
            top: (clockHeight * -1) 
        }

        Component.onCompleted: {
            const activeScreen = modelData;
            if (activeScreen) {
                controlCenterRoot.implicitWidth = activeScreen.width
                controlCenterRoot.implicitHeight = activeScreen.height
            } else {
                console.warn("No active screen found. Control Center may not display correctly.");
            }
        }

        anchors {
            top: true
        }

        HyprlandFocusGrab {
            windows: [ controlCenterRoot ]
            active: isOpened
            onCleared: if (!active) root.close()
        }

        Item {
            focus: isOpened
            Keys.onEscapePressed: root.close()
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
                cornerRadius: isOpened ? root.fullRadius : root.radius
                cornerColor: root.backgroundColor

                opacity: isOpened ? 1.0 : 0.0 //todo: fix

                Behavior on cornerRadius {
                    NumberAnimation { 
                        duration: root.animationDuration; 
                        easing.type: Easing.InOutQuint 
                    }
                }
            }

            Rectangle {
                id: contentContainer
                width: isOpened
                    ? Math.max(carousel.currentItem && carousel.currentItem.item ? carousel.currentItem.item.implicitWidth : root.defaultWidth, root.defaultWidth)
                    : root.defaultWidth
                height: isOpened
                    ? (carousel.currentItem && carousel.currentItem.item ? carousel.currentItem.item.implicitHeight : 0) + tabBar.height
                    : root.defaultHeight
                color: root.backgroundColor
                bottomLeftRadius: isOpened ? root.fullRadius : root.radius
                bottomRightRadius: isOpened ? root.fullRadius : root.radius
                clip: true

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
                /*FolderListModel {
                    id: ccFilesModel
                    folder: Qt.resolvedUrl("../components/control_center")
                    nameFilters: ["*.qml"]
                    showDirs: false
                }*/

                SwipeView {
                    id: carousel
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: tabBar.top
                    visible: isOpened
                    clip: true
                    currentIndex: 1 //! Clock (alphabetical: Calendar=0, Clock=1, Media=2, Wallpaper=3)

                    Component.onCompleted: {
                        contentItem.highlightMoveDuration = 0
                        contentItem.cacheBuffer = 0
                    }

                    Repeater {
                        model: ccFilesModel

                        Loader {
                            width: carousel.width
                            height: carousel.height
                            source: model.fileUrl
                        }
                    }
                }

                // Tab navigation bar - carousel style (prev2 | prev1 | current | next1 | next2)
                Item {
                    id: tabBar
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 40
                    visible: isOpened

                    Repeater {
                        model: ccFilesModel

                        delegate: Item {
                            id: tabDelegate

                            readonly property int n: ccFilesModel.count
                            readonly property int cur: carousel.currentIndex
                            readonly property bool isCurrent: cur === index
                            readonly property bool isPrev1: n > 1 && (cur - 1 + n) % n === index
                            readonly property bool isPrev2: n > 2 && (cur - 2 + n) % n === index
                            readonly property bool isNext1: n > 1 && (cur + 1) % n === index
                            readonly property bool isNext2: n > 2 && (cur + 2) % n === index
                            // slots: 0=far-left, 1=left, 2=center, 3=right, 4=far-right
                            // hidden items park at center (slot 2), invisible
                            readonly property int slot: isCurrent ? 2
                                : (isPrev1 ? 1 : (isPrev2 ? 0 : (isNext1 ? 3 : (isNext2 ? 4 : 2))))

                            width: tabBar.width / 5
                            height: tabBar.height
                            // x follows displaySlot (no Behavior) so width changes never trigger animations
                            x: displaySlot * (tabBar.width / 5)
                            opacity: (isCurrent || isPrev1 || isPrev2 || isNext1 || isNext2) ? 1.0 : 0.0
                            z: isCurrent ? 1 : 0

                            // displaySlot is the animated proxy — only moves when slot changes
                            property real displaySlot: slot
                            property int previousSlot: slot

                            Component.onCompleted: {
                                previousSlot = slot
                                displaySlot = slot
                            }

                            onSlotChanged: {
                                if (Math.abs(slot - previousSlot) > 2) {
                                    // Wrap-around: teleport instantly
                                    slotAnim.stop()
                                    tabDelegate.displaySlot = slot
                                } else {
                                    slotAnim.from = tabDelegate.displaySlot
                                    slotAnim.to = slot
                                    slotAnim.restart()
                                }
                                previousSlot = slot
                            }

                            NumberAnimation {
                                id: slotAnim
                                target: tabDelegate
                                property: "displaySlot"
                                duration: root.animationDuration
                                easing.type: Easing.InOutQuad
                            }

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: root.animationDuration
                                    easing.type: Easing.InOutQuad
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 4
                                radius: root.fullRadius - 4
                                color: "transparent"//isCurrent ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                                /*Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }*/
                            }

                            Text {
                                anchors.centerIn: parent
                                text: {
                                    const fileName = model.fileName.replace(".qml", "")
                                    if (fileName === "_Debug") return "   Debug"
                                    return fileName
                                }
                                color: {
                                    const fileName = model.fileName.replace(".qml", "")
                                    if (fileName === "_Debug") return Colors.primary
                                    return "white"
                                }
                                opacity: isCurrent ? 1.0 : 0.4
                                font.pixelSize: 14
                                //font.bold: isCurrent ? true : false
                                font.weight: Font.DemiBold
                                font.family: root.familyFont
                                Behavior on opacity {
                                    NumberAnimation { 
                                        duration: root.animationDuration
                                        easing.type: Easing.InOutQuad
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: !isCurrent ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: if (!isCurrent) carousel.currentIndex = index
                            }
                        }
                    }

                    Rectangle {
                        height: parent.height
                        width: parent.width / 4
                        bottomLeftRadius: root.fullRadius
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: root.backgroundColor }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }
                    Rectangle {
                        anchors.right: parent.right
                        height: parent.height
                        width: parent.width / 4
                        bottomRightRadius: root.fullRadius
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 1.0; color: root.backgroundColor }
                        }
                    }
                }
            }

            InvertedCorner {
                id: topRightCorner
                corner: InvertedCorner.Corner.TopLeft
                cornerRadius: isOpened ? root.fullRadius : root.radius
                cornerColor: root.backgroundColor
                opacity: isOpened ? 1.0 : 0.0 //todo: fix
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

        Connections {
            target: ccFilesModel
            function onCountChanged() {
                if (!controlCenterRoot.modelInitialized && ccFilesModel.count > 1) {
                    carousel.currentIndex = 1
                    controlCenterRoot.modelInitialized = true
                }
            }
        }
    }

    } // Variants

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
        const name = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : ""
        root.openedScreenName === name ? root.close() : root.open()
    }
    function close() {
        console.log("Closing Control Center")
        root.openedScreenName = ""
    }
    function open() {
        console.log("Opening Control Center")
        root.openedScreenName = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : ""
    }

    GlobalShortcut {
        name: "controlCenterToggle"
        description: "Toggle Control Center"
        onPressed: {
            root.toggle()
        }
    }
}