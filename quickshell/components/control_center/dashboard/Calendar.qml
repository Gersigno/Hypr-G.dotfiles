import QtQuick
import Quickshell

import qs.services
import "../../../utils"
import "../../../services"
import "../../common/interface"

Item {
    id: root

    readonly property color fg:       Colors.on_background
    readonly property color fgSub:    Colors.on_surface_variant
    readonly property color fgMuted:  Colors.outline
    readonly property color accent:   Colors.primary
    readonly property color accentFg: Colors.on_primary
    readonly property string fontName: Settings.fontFamily
    readonly property string font: Settings.fontFamily

    property int viewYear:  new Date().getFullYear()
    property int viewMonth: new Date().getMonth()

    readonly property int todayDay:   new Date().getDate()
    readonly property int todayMonth: new Date().getMonth()
    readonly property int todayYear:  new Date().getFullYear()

    function daysInMonth(y, m)  { return new Date(y, m + 1, 0).getDate() }
    function firstWeekDay(y, m) { return new Date(y, m, 1).getDay() }   // 0 = Sun

    function prevMonth() {
        if (viewMonth === 0) { viewMonth = 11; viewYear -= 1 }
        else viewMonth -= 1
    }
    function nextMonth() {
        if (viewMonth === 11) { viewMonth = 0; viewYear += 1 }
        else viewMonth += 1
    }
    function goToToday() {
        viewYear  = todayYear
        viewMonth = todayMonth
    }

    BackgroundLayer {
        id: background
        anchors.fill: parent
    }

    Column {
        id: column
        anchors.top:   parent.top
        anchors.left:  parent.left
        anchors.right: parent.right
        anchors.margins: 8
        spacing: 4

        // ── Header ───────────────────────────────────────────────────────
        Item {
            width: parent.width
            height: 32

            // ‹ Prev
            Rectangle {
                id: prevBtn
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 28; height: 28; radius: 14
                color: prevMa.containsMouse ? Qt.rgba(1,1,1,0.10) : "transparent"
                Behavior on color { ColorAnimation { duration: 140 } }

                Text {
                    anchors.centerIn: parent
                    text: "‹"
                    color: root.fgSub
                    font.family: root.fontName
                    font.pixelSize: 22
                    font.weight: Font.Light
                    leftPadding: -1
                    topPadding: -2
                }
                MouseArea {
                    id: prevMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.prevMonth()
                }
            }

            // Month + Year — tap to return to today
            Item {
                anchors.centerIn: parent
                width: monthLabel.implicitWidth + 8
                height: parent.height

                Text {
                    id: monthLabel
                    anchors.centerIn: parent
                    text: Qt.locale().standaloneMonthName(root.viewMonth) + "  " + root.viewYear
                    color: root.fg
                    font.family: root.fontName
                    font.pixelSize: 15
                    font.bold: true
                    font.letterSpacing: 0.3
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.goToToday()
                }
            }

            // › Next
            Rectangle {
                id: nextBtn
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 28; height: 28; radius: 14
                color: nextMa.containsMouse ? Qt.rgba(1,1,1,0.10) : "transparent"
                Behavior on color { ColorAnimation { duration: 140 } }

                Text {
                    anchors.centerIn: parent
                    text: "›"
                    color: root.fgSub
                    font.family: root.fontName
                    font.pixelSize: 22
                    font.weight: Font.Light
                    leftPadding: 1
                    topPadding: -2
                }
                MouseArea {
                    id: nextMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.nextMonth()
                }
            }
        }

        // ── Weekday labels ────────────────────────────────────────────────
        Row {
            width: parent.width
            topPadding: 2

            Repeater {
                model: ["S","M","T","W","T","F","S"]
                Text {
                    width: column.width / 7
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    color: root.fgMuted
                    font.family: root.fontName
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    font.letterSpacing: 1.2
                }
            }
        }

        // ── Divider ───────────────────────────────────────────────────────
        Rectangle {
            width: parent.width; height: 1
            color: Colors.outline_variant
            opacity: 0.45
        }

        // ── Days grid ─────────────────────────────────────────────────────
        Grid {
            id: dayGrid
            width: parent.width
            columns: 7
            rowSpacing: 2

            Repeater {
                model: 42   // 6 rows × 7 cols

                delegate: Item {
                    id: cell
                    width: dayGrid.width / 7
                    height: 36

                    readonly property int offset:  index - root.firstWeekDay(root.viewYear, root.viewMonth)
                    readonly property int day:     offset + 1
                    readonly property bool valid:  day >= 1 && day <= root.daysInMonth(root.viewYear, root.viewMonth)
                    readonly property bool isToday: valid
                        && day              === root.todayDay
                        && root.viewMonth   === root.todayMonth
                        && root.viewYear    === root.todayYear

                    Rectangle {
                        anchors.centerIn: parent
                        width: 32; height: 32; radius: 16
                        color: cell.isToday
                            ? root.accent
                            : (cellMa.containsMouse && cell.valid
                                ? Qt.rgba(1,1,1,0.08)
                                : "transparent")
                        Behavior on color { ColorAnimation { duration: 130 } }

                        Text {
                            anchors.centerIn: parent
                            text: cell.valid ? cell.day : ""
                            color: cell.isToday ? root.accentFg
                                 : cell.valid   ? root.fg
                                 : "transparent"
                            font.family:    root.fontName
                            font.pixelSize: 14
                            font.weight:    cell.isToday ? Font.DemiBold : Font.Normal
                        }

                        MouseArea {
                            id: cellMa
                            anchors.fill: parent
                            hoverEnabled: cell.valid
                            cursorShape: cell.valid ? Qt.PointingHandCursor : Qt.ArrowCursor
                        }
                    }
                }
            }
        }
    }
}