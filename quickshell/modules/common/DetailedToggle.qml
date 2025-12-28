import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import "../.." 

Rectangle {
    id: root
    property string icon: ""
    property string text: ""
    property string arrowIconClosed: "󰇘"
    property string arrowIconOpened: "󰇘"
    property string arrowIcon: menuPopup.opened ? arrowIconOpened : arrowIconClosed
    property bool useArrow: false
    property bool active: false
    property var options: []
    signal clicked()
    signal arrowClicked()

    width: 250
    height: 32
    color: (active ? "white" : "#2e2e2e")
    opacity: mouseArea.containsPress ? 0.7 : 1.0

    topLeftRadius: GlobalStates.cornerRadius
    topRightRadius: GlobalStates.cornerRadius
    bottomLeftRadius: menuPopup.opened ? 0 : GlobalStates.cornerRadius
    bottomRightRadius: menuPopup.opened ? 0 : GlobalStates.cornerRadius

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: GlobalStates.gapsOut
        anchors.rightMargin: GlobalStates.gapsOut
        spacing: GlobalStates.gapsOut

        Text {
            id: iconText
            text: root.icon
            font.pixelSize: 14
            color: root.active ? "black" : "white"
            font.family: "Symbols Nerd Font"
        }

        Text {
            id: mainText
            text: root.text
            font.pixelSize: 13
            color: root.active ? "black" : "white"
            elide: Text.ElideRight
            font.family: "SF Pro Display"
            Layout.fillWidth: true
        }

        Text {
            id: arrowText
            text: root.arrowIcon
            font.pixelSize: 16
            color: root.active ? "black" : "white"
            font.family: "Symbols Nerd Font"
            visible: root.useArrow
            enabled: !menuPopup.opened

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.arrowClicked();
                    menuPopup.open();
                }
            }
        }
    }

    Process {
        id: commandProcess
        running: false
    }


    Popup {
        id: menuPopup
        x: 0
        y: root.height
        width: root.width
        height: optionsColumn.height
        modal: false
        focus: true
        clip: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: 0

        background: Rectangle {
            color: root.color
            bottomLeftRadius: GlobalStates.cornerRadius
            bottomRightRadius: GlobalStates.cornerRadius
        }

        Column {
            id: optionsColumn
            width: parent.width
            spacing: 0

            Repeater {
                model: root.options
                delegate: Rectangle {
                    width: parent.width
                    height: root.height
                    color: optionMouseArea.containsPress ? "#444" : "transparent"
                    bottomLeftRadius: index == root.options.length - 1 ? GlobalStates.cornerRadius : 0
                    bottomRightRadius: index == root.options.length - 1 ? GlobalStates.cornerRadius : 0

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: GlobalStates.gapsOut
                        anchors.rightMargin: GlobalStates.gapsOut
                        spacing: GlobalStates.gapsOut

                        Text {
                            text: modelData.icon
                            font.pixelSize: 14
                            color: root.active ? "black" : "white"
                            font.family: "Symbols Nerd Font"
                            visible: modelData.icon !== ""
                        }

                        Text {
                            text: modelData.text
                            color: root.active ? "black" : "white"
                            font.pixelSize: 13
                            font.family: "SF Pro Display"
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignLeft                            
                            elide: Text.ElideRight                        }
                    }

                    MouseArea {
                        id: optionMouseArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.command) {
                                commandProcess.command = modelData.command;
                                commandProcess.start();
                            } else if (modelData.action) {
                                modelData.action();
                            }
                            menuPopup.close();
                        }
                    }
                }
            }
        }
    }
}