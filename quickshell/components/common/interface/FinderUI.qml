import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets

import qs.services
import "../../../utils"
import "../../../services"

/**
 * Finder UI: a faithful copy of Toast.qml's structure and animations
 * (inverted corners, bottom row, grow/shadow/blur sequence) with only
 * two differences:
 *   - content: search bar + results list instead of message/icon/progress
 *   - final position: centered on screen (not bottom-anchored)
 *
 * Fully passive: FinderOverlay wires it to FinderService.
 */
Item {
    id: root

    property string query: ""
    property var results: []
    property real growRatio: 0
    property int anim_duration: 500
    property real shadow_pacity: 0
    property real blur_level: 0
    property bool active: false
    property real screenHeight: 1080
    property real socleGrow: 0

    signal searchTextChanged(string text)
    signal submitted(var result)
    signal canceled()
    signal hidden()

    readonly property color backgroundColor: (Settings.isOled && Theme.isDarkMode) ? "#000" : Colors.background
    readonly property color foregroundColor: Colors.on_background
    readonly property color subText: Colors.on_surface_variant
    readonly property color shadowColor: Colors.shadow
    readonly property int radius: HyprlandConfig.radius
    readonly property int radiusFull: HyprlandConfig.radiusFull
    readonly property string font: Settings.fontFamily

    readonly property real contentWidth: 560
    readonly property real rowHeight: 46
    readonly property real maxListHeight: 336

    readonly property real pillHeight: columnLayout.height + 16
    readonly property real bottomHeight: Math.max(16, (root.screenHeight - root.pillHeight) / 2)

    // Full-height layout is deterministic: the root never changes size,
    // so nothing can be cropped when the results list grows.
    readonly property real maxPillHeight: 48 + 1 + root.maxListHeight + 28 + 16
    readonly property real bottomHeightFull: Math.max(16, (root.screenHeight - root.maxPillHeight) / 2)

    width: main.width
    height: main.height

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom

    clip: true

    opacity: 0
    visible: opacity > 0

    readonly property int quarterDuration: anim_duration / 4
    readonly property int halfDuration: anim_duration / 2
    readonly property int tierDuration: anim_duration / 3

    // ----------------------------------------------------------------
    //      API (show/hide)
    // ----------------------------------------------------------------
    function show() {
        console.log("[F] show() called")
        showAnimation.stop()
        hideAnimation.stop()
        container.y = 0
        root.growRatio = 0
        root.opacity = 1//HyprlandConfig.inactiveOpacity
        root.shadow_pacity = 0
        root.blur_level = 1.5
        bottomRectangle.width = columnLayout.width + 16 - (root.radiusFull * 2)
        root.socleGrow = 0
        bottomLeftCorner.cornerRadius = 0
        bottomRightCorner.cornerRadius = 0
        b_topRightCorner.cornerRadius = 0
        b_bottomLeftCorner.cornerRadius = 0
        b2_topRightCorner.cornerRadius = 0
        b2_bottomLeftCorner.cornerRadius = 0
        container.bottomLeftRadius = 0
        container.bottomRightRadius = 0
        showAnimation.restart()
        focusTimer.start()
    }

    function hide() {
        console.log("[F] hide() called")
        showAnimation.stop()
        hideAnimation.restart()
    }

    function resetState() {
        root.growRatio = 0
        root.blur_level = 0
        root.shadow_pacity = 0
        root.opacity = 0
        bottomLeftCorner.cornerRadius = 0
        bottomRightCorner.cornerRadius = 0
        b_topRightCorner.cornerRadius = 0
        b_bottomLeftCorner.cornerRadius = 0
        b2_topRightCorner.cornerRadius = 0
        b2_bottomLeftCorner.cornerRadius = 0
        container.bottomLeftRadius = 0
        container.bottomRightRadius = 0
        container.y = 0
        root.socleGrow = 0
        bottomRectangle.width = columnLayout.width + 16 - (root.radiusFull * 2)
    }

    Timer {
        id: focusTimer
        interval: 40
        repeat: false
        onTriggered: searchInput.forceActiveFocus()
    }

    function trySubmit(result) {
        const r = result ?? (listView.count > 0 && listView.currentIndex >= 0 ? listView.currentItem?.modelData : null)
        console.log("[F] trySubmit: direct=" + (result != null) + " resolved=" + (r != null) + " idx=" + listView.currentIndex)
        if (r != null)
            root.submitted(r)
    }

    // Single, imperative keyboard handler: receives any key not consumed
    // by the search field (arrows/escape/etc. bubble up here).
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Down) {
            if (listView.count > 0)
                listView.currentIndex = Math.min(listView.count - 1, listView.currentIndex + 1)
            event.accepted = true
        } else if (event.key === Qt.Key_Up) {
            if (listView.count > 0)
                listView.currentIndex = Math.max(0, listView.currentIndex - 1)
            event.accepted = true
        } else if (event.key === Qt.Key_Escape) {
            root.canceled()
            event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (!searchInput.activeFocus)
                root.trySubmit()
            event.accepted = true
        } else if (event.key === Qt.Key_Home) {
            if (listView.count > 0) listView.currentIndex = 0
            event.accepted = true
        } else if (event.key === Qt.Key_End) {
            if (listView.count > 0) listView.currentIndex = listView.count - 1
            event.accepted = true
        } else if (event.key === Qt.Key_Tab) {
            const item = listView.currentItem
            if (root.results.length > 0 && item)
                searchInput.text = item.modelData.name
            event.accepted = true
        } else if (!searchInput.activeFocus && event.text && event.text.length === 1
                && event.key !== Qt.Key_Enter && event.key !== Qt.Key_Return
                && event.key !== Qt.Key_Escape && event.key !== Qt.Key_Tab
                && event.text.charCodeAt(0) >= 0x20) {
            searchInput.forceActiveFocus()
            searchInput.text += event.text
            event.accepted = true
        }
    }

    Component.onCompleted: {
        bottomLeftCorner.cornerRadius = 0
        bottomRightCorner.cornerRadius = 0
        b_topRightCorner.cornerRadius = 0
        b_bottomLeftCorner.cornerRadius = 0
        b2_topRightCorner.cornerRadius = 0
        b2_bottomLeftCorner.cornerRadius = 0
        root.shadow_pacity = 0
        root.socleGrow = 0
        bottomRectangle.width = columnLayout.width + 16 - (root.radiusFull * 2)
    }

    // ----------------------------------------------------------------
    //      Animations (identical to Toast.qml)
    // ----------------------------------------------------------------
    ParallelAnimation {
        id: hideAnimation

        NumberAnimation {
            target: root
            property: "growRatio"
            from: 1
            to: 0
            duration: root.halfDuration / 0.9
            easing.type: Easing.InOutCubic
        }
        NumberAnimation {
            target: root
            property: "blur_level"
            from: 0
            to: 1.5
            duration: root.halfDuration / 0.9
        }
        NumberAnimation {
            target: root
            property: "shadow_pacity"
            from: root.shadow_pacity
            to: 0
            duration: root.halfDuration / 2
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: root
            property: "opacity"
            from: root.opacity
            to: 0
            duration: root.halfDuration / 0.9
            easing.type: Easing.InOutQuad
        }

        onFinished: {
            resetState()
            root.hidden()
        }
    }

    ParallelAnimation {
        id: showAnimation

        // Corner sequence
        SequentialAnimation {
            // Step 1: bottom corners grow from 0 to radiusFull
            ParallelAnimation {
                NumberAnimation {
                    target: bottomLeftCorner
                    property: "cornerRadius"
                    from: 0
                    to: root.radiusFull
                    duration: root.quarterDuration / 2
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: bottomRightCorner
                    property: "cornerRadius"
                    from: 0
                    to: root.radiusFull
                    duration: root.quarterDuration / 2
                    easing.type: Easing.OutCubic
                }
            }

            // Step 2: bottom corners shrink back to 0
            ParallelAnimation {
                NumberAnimation {
                    target: bottomLeftCorner
                    property: "cornerRadius"
                    from: root.radiusFull
                    to: 0
                    duration: root.quarterDuration / 2
                    easing.type: Easing.InCubic
                }
                NumberAnimation {
                    target: bottomRightCorner
                    property: "cornerRadius"
                    from: root.radiusFull
                    to: 0
                    duration: root.quarterDuration / 2
                    easing.type: Easing.InCubic
                }
            }

            // Step 3: bottom corners grow back onto the container
            ParallelAnimation {
                NumberAnimation {
                    target: container
                    property: "bottomLeftRadius"
                    from: 0
                    to: root.radiusFull
                    duration: root.quarterDuration / 2
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: container
                    property: "bottomRightRadius"
                    from: 0
                    to: root.radiusFull
                    duration: root.quarterDuration / 2
                    easing.type: Easing.OutCubic
                }
            }
        }

        // Container growth, parallel
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

            // Bottom row unfolds after a quarter of the total duration
            SequentialAnimation {
                PauseAnimation {
                    duration: root.halfDuration / 1.5
                }
                ParallelAnimation {
                    NumberAnimation {
                        target: root
                        property: "socleGrow"
                        from: 0
                        to: 1
                        duration: root.halfDuration
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: bottomRectangle
                        property: "width"
                        from: columnLayout.width + 16 - (root.radiusFull * 2)
                        to: 0
                        duration: root.tierDuration
                        easing.type: Easing.InOutQuad
                    }
                    SequentialAnimation {
                        // First, grow the 4 bottom angles from 0 to radiusFull
                        ParallelAnimation {
                            NumberAnimation {
                                target: b_topRightCorner
                                property: "cornerRadius"
                                from: 0
                                to: root.radiusFull
                                duration: root.halfDuration / 2
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                target: b_bottomLeftCorner
                                property: "cornerRadius"
                                from: 0
                                to: root.radiusFull
                                duration: root.halfDuration / 2
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                target: b2_topRightCorner
                                property: "cornerRadius"
                                from: 0
                                to: root.radiusFull
                                duration: root.halfDuration / 2
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                target: b2_bottomLeftCorner
                                property: "cornerRadius"
                                from: 0
                                to: root.radiusFull
                                duration: root.halfDuration / 2
                                easing.type: Easing.OutCubic
                            }
                        }
                        // Then, shrink the 4 bottom angles back to 0
                        ParallelAnimation {
                            NumberAnimation {
                                target: b_topRightCorner
                                property: "cornerRadius"
                                from: root.radiusFull
                                to: 0
                                duration: root.halfDuration / 2
                                easing.type: Easing.InCubic
                            }
                            NumberAnimation {
                                target: b_bottomLeftCorner
                                property: "cornerRadius"
                                from: root.radiusFull
                                to: 0
                                duration: root.halfDuration / 2
                                easing.type: Easing.InCubic
                            }
                            NumberAnimation {
                                target: b2_topRightCorner
                                property: "cornerRadius"
                                from: root.radiusFull
                                to: 0
                                duration: root.halfDuration / 2
                                easing.type: Easing.InCubic
                            }
                            NumberAnimation {
                                target: b2_bottomLeftCorner
                                property: "cornerRadius"
                                from: root.radiusFull
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
        }
    }

    // ----------------------------------------------------------------
    //      Layout (mirrors Toast.qml but centered)
    // ----------------------------------------------------------------
    Item {
        id: main
        width: columnLayout.width + (root.radiusFull * 2) + 16
        height: root.maxPillHeight + root.bottomHeightFull

        anchors.bottom: root.bottom
        anchors.horizontalCenter: root.horizontalCenter

        // Toast layer (bottom corners grow/shrink)
        RowLayout {
            id: toastRow
            spacing: 0

            anchors.bottom: bottomRow.top
            anchors.horizontalCenter: parent.horizontalCenter

            InvertedCorner {
                id: bottomLeftCorner
                corner: InvertedCorner.Corner.BottomRight
                cornerColor: root.backgroundColor
                Layout.alignment: Qt.AlignVCenter
            }
            ClippingRectangle {
                id: container
                topLeftRadius: root.radiusFull
                topRightRadius: root.radiusFull
                color: root.backgroundColor
                implicitWidth: root.growRatio * (columnLayout.width + 16)
                implicitHeight: root.growRatio * (columnLayout.height + 16)

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: root.shadowColor
                    shadowBlur: 2
                    shadowHorizontalOffset: 0
                    shadowVerticalOffset: 8
                    shadowOpacity: shadow_pacity
                }

                ColumnLayout {
                    id: columnLayout
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 0

                    width: root.contentWidth
                    height: searchBar.height + separator.height
                        + (listView.count > 0 ? listView.height + hintBar.height : 0)

                    opacity: 1 + (root.blur_level * -1)

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blur: blur_level
                    }

                    // ------------------------------------------------
                    //      Search bar
                    // ------------------------------------------------
                    Item {
                        id: searchBar
                        Layout.fillWidth: true
                        height: 48

                        RowLayout {
                            anchors.fill: parent
                            spacing: 10
                            anchors.leftMargin: 20
                            anchors.rightMargin: 20

                            Text {
                                text: "\uF40D"
                                font.pixelSize: 14
                                font.family: root.font
                                color: root.subText
                                Layout.alignment: Qt.AlignVCenter
                            }

                            TextField {
                                id: searchInput
                                Layout.fillWidth: true
                                height: 46
                                Layout.alignment: Qt.AlignVCenter

                                font.pixelSize: 13
                                font.family: root.font
                                color: root.foregroundColor
                                horizontalAlignment: Text.AlignLeft
                                placeholderText: "Search, calculate or run..."
                                placeholderTextColor: Qt.rgba(root.subText.r, root.subText.g, root.subText.b, 0.7)
                                selectByMouse: true
                                background: null

                                onTextChanged: root.searchTextChanged(text)

                                onActiveFocusChanged: console.log("[F] field focus=" + searchInput.activeFocus)

                                onAccepted: root.trySubmit()
                            }

                            Text {
                                id: resultCount
                                visible: false
                                text: listView.count > 0 ? listView.count + "" : ""
                            }
                        }
                    }

                    Rectangle {
                        id: separator
                        Layout.fillWidth: true
                        visible: listView.count > 0
                        color: Qt.rgba(root.foregroundColor.r, root.foregroundColor.g, root.foregroundColor.b, 0.12)
                        implicitHeight: visible ? 1 : 0
                    }

                    // ------------------------------------------------
                    //      Results list
                    // ------------------------------------------------
                    ListView {
                        id: listView
                        Layout.fillWidth: true

                        implicitHeight: Math.min(listView.count * root.rowHeight + 8, root.maxListHeight)

                        visible: count > 0
                        clip: true
                        spacing: 2
                        boundsBehavior: Flickable.StopAtBounds
                        highlightMoveDuration: 100
                        currentIndex: 0

                        highlight: Rectangle {
                            radius: 12
                            anchors.margins: 4
                            color: Colors.primary_container
                            visible: listView.currentIndex >= 0
                        }

                        topMargin: 4
                        bottomMargin: 4

                        model: ScriptModel {
                            id: resultModel
                            objectProp: "key"
                            values: root.results
                        }

                        onCountChanged: if (listView.currentIndex < 0 || listView.currentIndex >= count) listView.currentIndex = 0

                        onCurrentIndexChanged: {
                            console.log("[F] currentIndex=" + listView.currentIndex + " count=" + listView.count)
                            if (count > 0 && currentIndex >= 0)
                                listView.positionViewAtIndex(currentIndex, ListView.Contain)
                        }

                        Connections {
                            target: root
                            function onResultsChanged() {
                                if (listView.count > 0)
                                    listView.currentIndex = 0
                            }
                        }

                        delegate: Item {
                            id: resultItem
                            required property var modelData
                            required property int index

                            readonly property bool selected: listView.currentIndex === index

                            onSelectedChanged: if (selected) console.log("[F] row selected idx=" + index)

                            implicitHeight: root.rowHeight
                            width: listView.width

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 4
                                radius: 12
                                color: resultItem.selected
                                    ? Colors.primary_container
                                    : (hoverHandler.hovered ? Colors.surface_container_high : "transparent")

                                Behavior on color {
                                    ColorAnimation { duration: 100 }
                                }

                                HoverHandler {
                                    id: hoverHandler
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14
                                    anchors.rightMargin: 14
                                    spacing: 12

                                    ClippingRectangle {
                                        id: iconContainer
                                        width: 30
                                        height: 30
                                        radius: 8
                                        color: resultItem.selected
                                            ? Colors.primary
                                            : Colors.surface_container_high

                                        Behavior on color {
                                            ColorAnimation { duration: 100 }
                                        }

                                        Layout.alignment: Qt.AlignVCenter

                                        IconImage {
                                            id: appIcon
                                            anchors.centerIn: parent
                                            width: 22
                                            height: 22
                                            source: resultItem.modelData.iconName
                                                ? Quickshell.iconPath(resultItem.modelData.iconName, "image-missing")
                                                : ""
                                            visible: resultItem.modelData.iconName != ""
                                        }

                                        Text {
                                            id: glyphIcon
                                            anchors.centerIn: parent
                                            text: resultItem.modelData.iconGlyph ?? ""
                                            font.pixelSize: 14
                                            font.family: root.font
                                            color: root.foregroundColor
                                            visible: resultItem.modelData.iconName == "" && text !== ""
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1

                                        Text {
                                            Layout.fillWidth: true
                                            text: resultItem.modelData.name
                                            font.pixelSize: 13
                                            font.family: root.font
                                            color: resultItem.selected ? Colors.on_primary_container : root.foregroundColor
                                            opacity: resultItem.selected ? 1.0 : 0.9
                                            horizontalAlignment: Text.AlignLeft
                                            elide: Text.ElideRight
                                            maximumLineCount: 1
                                        }
                                        Text {
                                            Layout.fillWidth: true
                                            text: resultItem.modelData.hint ?? ""
                                            font.pixelSize: 10
                                            font.family: root.font
                                            color: resultItem.selected ? Colors.on_primary_container : root.subText
                                            horizontalAlignment: Text.AlignLeft
                                            visible: text !== ""
                                            elide: Text.ElideRight
                                            maximumLineCount: 1
                                        }
                                    }

                                    Text {
                                        text: resultItem.modelData.verb ?? ""
                                        font.pixelSize: 12
                                        font.family: root.font
                                        color: resultItem.selected ? Colors.on_primary_container : root.subText
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true

                                    onClicked: {
                                        listView.currentIndex = index
                                        root.trySubmit(resultItem.modelData)
                                    }
                                }
                            }
                        }
                    }

                    // ------------------------------------------------
                    //      Hint bar
                    // ------------------------------------------------
                    Item {
                        id: hintBar
                        Layout.fillWidth: true
                        height: 28
                        visible: listView.count > 0

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            text: (listView.count > 0 ? listView.count + " results     " : "") + "↑↓  select    ↵  run    esc  close"
                            font.pixelSize: 10
                            font.family: root.font
                            color: root.subText
                            opacity: 0.6
                            horizontalAlignment: Text.AlignLeft
                        }
                    }
                }
            }
            InvertedCorner {
                id: bottomRightCorner
                corner: InvertedCorner.Corner.BottomLeft
                cornerRadius: root.radiusFull
                cornerColor: root.backgroundColor
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // Bottom section with inverted corner radius (2nd part of the animation)
        Item {
            id: bottomRow
            width: bottomRectangle.width
            height: bottomRectangle.height

            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                id: bottomRectangle
                color: root.backgroundColor
                width: columnLayout.width + 16 - (root.radiusFull * 2)
                height: root.socleGrow * root.bottomHeight
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
            }

            // left inverted corners
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
