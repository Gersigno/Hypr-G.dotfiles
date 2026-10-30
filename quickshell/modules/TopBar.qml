import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

import qs.services

import "../components/topbar"

Item {
    id: root

    property bool opened: true
    property int targetOpacity: 1
    property int barHeight: 24
    property real statusWidth: 0
    property real clockWidth: 0
    property string controlCenterOpenedScreenName: ""
    property int mouseHoverAreaMargin: 8
    property bool isHovered: false
    // true si la barre a été ouverte par un survol (et non via le raccourci)
    property bool hoverOpened: false
    // Références injectées depuis shell.qml pour ouvrir les panneaux
    property var controlCenterComponent: null
    property var notificationsCenterComponent: null

    // Un panneau (Control Center / Notifications Center) est-il ouvert ?
    // Tant que c'est le cas, la barre doit rester ouverte quoi qu'il arrive.
    readonly property bool panelOpened: (controlCenterComponent?.opened ?? false)
                                        || (notificationsCenterComponent?.opened ?? false)

    onPanelOpenedChanged: {
        if (panelOpened) {
            root.opened = true
        } else if (!root.isHovered && root.hoverOpened) {
            // La barre avait été ouverte par survol : on la referme quand le
            // panneau se ferme si la souris n'est plus dessus.
            root.opened = false
            root.hoverOpened = false
        }
    }

    Component.onCompleted: {
        console.info("Loaded component: [TopBar]")
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData


            WlrLayershell.namespace: "quickshell:topBar"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusiveZone: Math.round(opened || isHovered ? root.barHeight : 0)//Math.round(root.barHeight)
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            

            mask: Region {
                Region { item: content }    // barre : hors écran quand fermée, donc inactif
                Region { item: hoverStrip } // bande de 8px pour rouvrir la barre au survol
            }

            implicitHeight: root.barHeight + mouseHoverAreaMargin//+ (root.opened ? 0 : mouseHoverAreaMargin)//(!opened ?? mouseHoverAreaMargin)

            anchors {
                top: true
                left: true
                right: true
                
            } 

            //topMargin: 10

            color: "transparent"

            // Bande invisible utilisée uniquement par le mask pour détecter
            // le survol quand la barre est fermée.
            Item {
                id: hoverStrip
                height: root.mouseHoverAreaMargin

                anchors {
                    right: parent.right
                    top: parent.top
                    left: parent.left
                }
            }

            // Déclaré AVANT content => il est EN DESSOUS : les clics arrivent
            // d'abord aux composants de la barre, et le hover traverse les
            // items sans hoverEnabled (containsMouse reste donc vrai même
            // au-dessus de Clock/Status/WorkSpaces).
            MouseArea {
                id: hoverArea
                anchors.fill: parent
                hoverEnabled: true

                onEntered: {
                    root.isHovered = true;
                    if (!root.opened) {
                        root.opened = true;
                        root.hoverOpened = true;
                    }
                }
                onExited: {
                    root.isHovered = false;
                    // Ne jamais refermer la barre tant qu'un panneau est ouvert
                    if (root.hoverOpened && !root.panelOpened) {
                        root.opened = false;
                        root.hoverOpened = false;
                    }
                }
            }

            Item {
                id: content

                anchors {
                    right: parent.right
                    top: parent.top
                    left: parent.left

                    topMargin: opened ? 0 : -32

                    Behavior on topMargin {
                        NumberAnimation { duration: Settings.animDuration(250); easing.type: Easing.InOutQuad }
                    }
                }
                //bottomMargin: 10

                height: root.barHeight //parent.height - mouseHoverAreaMargin//- (!opened ? 8 : mouseHoverAreaMargin)

                WorkSpaces {
                    id: workspacesComponent
                    screen: modelData
                }
                ActiveWindowTitle {
                    id: activeWindowTitleComponent
                    screen: modelData
                    x: workspacesComponent.width
                }

                Clock {
                    id: clockComponent

                    opacity: root.controlCenterOpenedScreenName === modelData.name ? 0 : 1
                    //visible: opened
                    Behavior on opacity {
                        NumberAnimation { duration: Settings.animDuration(250); easing.type: Easing.InOutQuad }
                    }

                    Component.onCompleted: root.clockWidth = width
                    onWidthChanged: root.clockWidth = width

                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                    }
                }

                Status {
                    id: statusComponent
                    //visible: opened

                    Component.onCompleted: root.statusWidth = width
                    onWidthChanged: root.statusWidth = width

                    anchors {
                        right: parent.right
                        top: parent.top
                    }
                }

                // Zones cliquables pour le Control Center et le Notifications Center.
                // Les PanelWindow de ces modules sont SOUS la TopBar (layer Bottom/Top
                // vs Overlay) : quand le masque de la TopBar couvre la barre, seuls
                // ces relais peuvent ouvrir les panneaux.
                // Une fois un panneau ouvert il détient un focus grab : le clic
                // suivant lui est routé directement (cf. MouseArea de fermeture
                // dans ControlCenter/NotificationsCenter). Ce n'est donc pas un
                // toggle ici qui referme, mais ce relais qui ouvre.
                // Déclarées en dernier => au-dessus des composants. Surtout PAS de
                // hoverEnabled, sinon le hover de hoverArea serait bloqué et la
                // barre se refermerait dessus.
                MouseArea {
                    anchors.fill: clockComponent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (root.controlCenterComponent) root.controlCenterComponent.toggle()
                }
                MouseArea {
                    anchors.fill: statusComponent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (root.notificationsCenterComponent) root.notificationsCenterComponent.toggle()
                }
            }

        }
    }

    GlobalShortcut {
        name: "topBarToggle"
        description: "Toggles top bar on press"
        
        onPressed: {
            // Tant qu'un panneau est ouvert, la barre reste ouverte
            if (root.panelOpened) {
                root.opened = true
                return
            }
            root.opened = !root.opened;
            root.hoverOpened = false;
        }
    }
}