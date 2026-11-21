import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

import "../services"
import "../components/common/interface"
import qs.services
import "../utils"
// Ces imports ne sont pas utilisés directement : ils rendent les dossiers
// visibles au scanner de Quickshell, qui ne surveille que les fichiers
// atteignables depuis le graphe d'imports statique. Sans eux, les pages du
// carousel (chargées dynamiquement via FolderListModel + Loader) ne sont pas
// surveillées et le hot reload ne fonctionne pas.
import "../components/control_center" as ControlCenterPages
import "../components/control_center/debug" as DebugPages
//import "../components/control_center" as ControlCenterComponents

Item {
    id: root

    property string openedScreenName: ""
    //property bool topBarVisible: true
    readonly property bool opened: openedScreenName !== ""
    readonly property int animationDuration: Settings.animDuration(450)
    property real blur_level: (opened) ? 0 : 1.5
    property real shadowOpacity: opened ? 1 : 0.0

    property var topBarComponent: null
    readonly property real clockWidth: topBarComponent ? topBarComponent.clockWidth : 0
    readonly property real clockHeight: topBarComponent ? topBarComponent.barHeight : 0
    readonly property int radius: HyprlandConfig.radius
    readonly property int fullRadius: HyprlandConfig.radiusFull
    readonly property color backgroundColor: (Settings.isOled && Theme.isDarkMode) ? "#000" : Colors.background
    readonly property color foregroundColor: Colors.on_background
    readonly property string familyFont: Settings.fontFamily

    readonly property real defaultWidth: clockWidth + (radius * 2)
    readonly property real defaultHeight: clockHeight

    Behavior on blur_level {
        NumberAnimation { 
            duration: root.animationDuration / 1.7; 
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on shadowOpacity {
        NumberAnimation { 
            duration: root.animationDuration / 1.7; 
            easing.type: Easing.InOutQuad
        }
    }

    Component.onCompleted: {
        console.info("Loaded component: [ControlCenter]")
    }

    function findPageIndex(pageName) {
        for (var i = 0; i < ccFilesModel.count; i++) {
            if (ccFilesModel.get(i, "fileName") === pageName + ".qml") {
                return i
            }
        }
        return -1
    }

    FolderListModel {
        id: ccFilesModel
        folder: Qt.resolvedUrl("../components/control_center")
        nameFilters: ["*.qml"]
        showDirs: false
    }

    // `_Debug.qml` commence par un underscore : le scanner de Quickshell ne
    // scanne que les fichiers commençant par une majuscule, il ne le surveille
    // donc pas. On le surveille explicitement pour que ses modifications
    // déclenchent aussi un hot reload.
    FileView {
        watchChanges: true
        path: Quickshell.shellPath("components/control_center/_Debug.qml")
        onFileChanged: Quickshell.reload(false)
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

        property bool isOpened: root.openedScreenName === modelData.name
        property bool isFullyOpened: isOpened && (container.height === (carousel.currentItem && carousel.currentItem.item ? carousel.currentItem.item.implicitHeight : 0) + tabBar.height)

        readonly property bool isClosing: !isOpened && localFullyClosed
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
            onCleared: {
                if (!active) root.close()
            }
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

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Colors.shadow
                shadowBlur: 2
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 8
                shadowOpacity: root.shadowOpacity
            }


            InvertedCorner {
                id: topLeftCorner
                corner: InvertedCorner.Corner.TopRight
                cornerRadius: isOpened ? root.fullRadius : (!topBarComponent.opened ? 0 : root.radius)
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
                        duration: root.animationDuration * (!isClosing ? 2.5 : 0.5); 
                        easing.type: !isClosing ? Easing.OutElastic : Easing.InOutQuad
                        easing.period: !isClosing ? 0.6 : 1
                        easing.amplitude: !isClosing ? 0.2 : 1
                    } 
                }
                Behavior on height { 
                    NumberAnimation { 
                        duration: root.animationDuration * (!isClosing ? 2 : 0.5); 
                        easing.type: !isClosing ? Easing.OutElastic : Easing.InOutQuad
                        easing.period: !isClosing ? 0.6 : 1
                        easing.amplitude: !isClosing ? 0.2 : 1
                    } 
                }
                Behavior on bottomLeftRadius {
                    NumberAnimation { 
                        duration: root.animationDuration; 
                        easing.type: Easing.OutElastic
                        easing.period: 0.6
                        easing.amplitude: 0.2
                    }
                }
                Behavior on bottomRightRadius {
                    NumberAnimation { 
                        duration: root.animationDuration; 
                        easing.type: Easing.OutElastic
                        easing.period: 0.6
                        easing.amplitude: 0.2
                    }
                }

                SwipeView {
                    id: carousel
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: tabBar.top
                    //visible: true
                    clip: true 
                    interactive: false
                    //currentIndex: 1 //! Clock (alphabetical: Calendar=0, Clock=1, Media=2, Wallpaper=3)

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blur: blur_level
                    }
                    opacity: isOpened ? 1.0 : 0.0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: root.animationDuration / 1.2
                            easing.type: Easing.InOutQuad
                        }
                    }

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

                    readonly property int n: ccFilesModel.count
                    // -1 means "not initialised yet" so the first index change
                    // (e.g. Dashboard selected once the folder model is ready)
                    // does not trigger a bogus slide from index 0.
                    property int lastIndex: -1
                    property real targetScrollPos: 0
                    property real scrollPos: 0

                    function shortestDelta(from, to, count) {
                        var d = to - from
                        while (d > count / 2) d -= count
                        while (d < -count / 2) d += count
                        return d
                    }

                    function resetScrollPosition() {
                        scrollAnim.stop()
                        lastIndex = carousel.currentIndex
                        targetScrollPos = carousel.currentIndex
                        scrollPos = carousel.currentIndex
                    }

                    Component.onCompleted: {
                        if (tabBar.lastIndex < 0) tabBar.resetScrollPosition()
                    }

                    onNChanged: tabBar.resetScrollPosition()

                    Connections {
                        target: carousel
                        function onCurrentIndexChanged() {
                            if (tabBar.lastIndex < 0 || !controlCenterRoot.isOpened) {
                                // Before the panel is open, snap silently so the first
                                // open does not show a slide from the initial index.
                                tabBar.resetScrollPosition()
                                return
                            }
                            var delta = tabBar.shortestDelta(tabBar.lastIndex, carousel.currentIndex, tabBar.n)
                            tabBar.lastIndex = carousel.currentIndex
                            tabBar.targetScrollPos += delta
                            scrollAnim.from = tabBar.scrollPos
                            scrollAnim.to = tabBar.targetScrollPos
                            // Constant duration: a 2-step jump therefore slides twice
                            // as fast since it covers twice the distance.
                            scrollAnim.duration = root.animationDuration
                            scrollAnim.restart()
                        }
                    }

                    NumberAnimation {
                        id: scrollAnim
                        target: tabBar
                        property: "scrollPos"
                        duration: root.animationDuration
                        easing.type: Easing.InOutQuad
                    }

                    Repeater {
                        model: ccFilesModel

                        delegate: Item {
                            id: tabDelegate

                            readonly property bool isCurrent: carousel.currentIndex === index
                            // Continuous position on the circular list projected onto the
                            // 5 visible lanes (0..4). Anything below 0 or above 4 is
                            // clipped, so the modulo wrap always happens off-screen and
                            // the visible items simply slide uniformly in one direction.
                            readonly property real lane: tabBar.n > 0
                                ? ((((index - tabBar.scrollPos + tabBar.n / 2) % tabBar.n) + tabBar.n) % tabBar.n) - tabBar.n / 2 + 2
                                : 2

                            layer.enabled: true
                            layer.effect: MultiEffect {
                                blurEnabled: true
                                blur: blur_level
                            }

                            width: tabBar.width / 5
                            height: tabBar.height
                            x: lane * (tabBar.width / 5)
                            opacity: isOpened ? 1.0 : 0.0
                            z: isCurrent ? 1 : 0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: root.animationDuration / 2
                                    easing.type: Easing.InOutQuad
                                }
                            }

                            /*Rectangle {
                                anchors.fill: parent
                                anchors.margins: 4
                                radius: root.fullRadius - 4
                                //width: label.width + 20
                                color: "red"//isCurrent ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                            }*/

                            Text {
                                id: label 
                                anchors.centerIn: parent
                                text: {
                                    const fileName = model.fileName.replace(".qml", "")
                                    if (fileName === "Dashboard") return "   Dashboard"
                                    if (fileName === "Metrics") return "   Metrics"
                                    if (fileName === "Wallpaper") return "   Wallpaper"
                                    if (fileName === "Clock") return "    Clock"
                                    if (fileName === "Eureka") return "    Eureka AI"
                                    if (fileName === "_Debug") return "   Debug"
                                    if (fileName === "Settings") return "   Settings"
                                    if (fileName === "Privacy") return "󱖧   Privacy"
                                    return fileName
                                }
                                color: {
                                    const fileName = model.fileName.replace(".qml", "")
                                    if (fileName === "_Debug") return Colors.primary
                                    return foregroundColor 
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
                cornerRadius: isOpened ? root.fullRadius : (!topBarComponent.opened ? 0 : root.radius)
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

            // Le 2e clic sur l'horloge est routé vers cette fenêtre (elle tient le
            // focus grab) : le grab est alors vidé -> onCleared -> close(). Il ne
            // faut donc surtout pas toggle() ici, sinon le panneau se rouvre
            // immédiatement. On se contente de fermer.
            onClicked: root.close()
        }

        Connections {
            target: ccFilesModel
            function onCountChanged() {
                if (!controlCenterRoot.modelInitialized && ccFilesModel.count > 1) {
                    carousel.currentIndex = root.findPageIndex("Dashboard")
                    controlCenterRoot.modelInitialized = true
                }
            }
        }

        Connections {
            target: NavigationState
            function onRequestedSettingsPageChanged() {
                var page = NavigationState.requestedSettingsPage
                if (page !== "") {
                    carousel.currentIndex = root.findPageIndex("Settings")
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
        root.openedScreenName = ""
    }
    function open() {
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