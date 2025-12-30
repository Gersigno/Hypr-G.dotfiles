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
    property bool buttonPressed: false
    property var options: []
    signal clicked()
    signal arrowClicked()

    width: 250
    height: 32
    color: (active ? "white" : "#2e2e2e")
    opacity: buttonPressed ? 0.7 : 1.0

    topLeftRadius: GlobalStates.cornerRadius
    topRightRadius: GlobalStates.cornerRadius
    bottomLeftRadius: menuPopup.opened ? 0 : GlobalStates.cornerRadius
    bottomRightRadius: menuPopup.opened ? 0 : GlobalStates.cornerRadius

    Behavior on bottomLeftRadius {
        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
    }

    Behavior on bottomRightRadius {
        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: GlobalStates.gapsOut
        anchors.rightMargin: GlobalStates.gapsOut
        spacing: GlobalStates.gapsOut

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                anchors.fill: parent
                spacing: GlobalStates.gapsOut

                Text {
                    id: iconText
                    text: root.icon
                    font.pixelSize: 14
                    color: root.active ? "black" : "white"
                    font.family: "Symbols Nerd Font"
                    width: 20
                    horizontalAlignment: Text.AlignHCenter
                    visible: root.icon !== ""
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
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.clicked()
            }
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
                id: mouseArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onPressed: root.buttonPressed = true
                onReleased: root.buttonPressed = false
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
        property int menuHeight: 0
        property real menuWidth: root.width - (GlobalStates.cornerRadius * 2)
        property real menuX: GlobalStates.cornerRadius * 1

        id: menuPopup
        x: menuX
        y: root.height
        width: menuWidth
        height: menuHeight
        modal: false
        focus: true
        clip: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: 0

        Behavior on menuHeight {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        Behavior on menuWidth {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        Behavior on menuX {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        onOpened: {
            menuHeight = root.options.length * root.height
            menuWidth = root.width
            menuX = 0
        }

        onClosed: {
            menuHeight = 0
            menuWidth = root.width - (GlobalStates.cornerRadius * 2)
            menuX = GlobalStates.cornerRadius * 1; 
        }

        exit: Transition {
            NumberAnimation { 
                property: "menuHeight"; 
                to: 0; 
                duration: 200; 
                easing.type: Easing.InOutQuad 
            }
            NumberAnimation { 
                property: "menuWidth"; 
                to: root.width - (GlobalStates.cornerRadius * 2); 
                duration: 200; 
                easing.type: Easing.InOutQuad 
            }
            NumberAnimation { 
                property: "menuX"; 
                to: GlobalStates.cornerRadius * 1; 
                duration: 200; 
                easing.type: Easing.InOutQuad 
            }
        }

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
                    opacity: menuPopup.menuHeight / (root.options.length * root.height)

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
                                commandProcess.running = false;
                                commandProcess.running = true;
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