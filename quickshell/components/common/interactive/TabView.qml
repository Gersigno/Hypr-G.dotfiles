import QtQuick
import QtQuick.Layouts
import Quickshell

import "../../../utils"
import "../../../services"

/*
 * TabView réutilisable, avec une page par fichier.
 *
 *     TabView {
 *         baseUrl: Qt.resolvedUrl("debug")
 *         model: [
 *             { title: "Infos",      source: "InfosPage.qml" },
 *             { title: "Réglages",   source: "SettingsPage.qml", icon: "󰒓" }
 *         ]
 *     }
 *
 * Chaque page est chargée au premier affichage de son onglet, puis conservée
 * en mémoire pour garder son état. Utiliser `cache: false` pour détruire les
 * pages lorsqu'elles ne sont plus visibles, ou `preload: true` pour charger
 * toutes les pages en tâche de fond dès le départ.
 *
 * `asynchronous: true` charge les pages en arrière-plan (utile pour les pages
 * lourdes). Désactivé par défaut pour que `currentPage` soit disponible
 * immédiatement au changement d'onglet.
 *
 * Le modèle est un tableau d'objets { title, icon, source }.
 * `source` peut être relatif à `baseUrl`, ou une URL absolue.
 *
 * `orientation` vaut `TabView.Orientation.Horizontal` (onglets en haut) ou
 * `TabView.Orientation.Vertical` (onglets à gauche).
 */
Item {
    id: root

    enum Orientation { Horizontal, Vertical }

    // --- API ---
    property var model: []
    property url baseUrl: ""

    property int orientation: TabView.Orientation.Horizontal

    property alias currentIndex: stack.currentIndex

    property bool lazy: true
    property bool cache: true
    property bool preload: false

    // Chargement asynchrone des pages. Désactivé par défaut : les pages locales
    // sont rapides à charger et `currentPage` est disponible immédiatement.
    // Activer pour les pages lourdes, au prix d'un court instant vide.
    property bool asynchronous: false

    property int tabSpacing: 4
    property int contentSpacing: 12

    // Taille de la barre d'onglets : hauteur en mode horizontal, largeur en
    // mode vertical.
    property real tabBarHeight: 40
    property real tabBarWidth: 140

    // Marge interne de la zone de contenu (utile quand `contentBackground` est
    // défini, pour écarter les pages du bord de la carte).
    property int contentMargin: 0

    // Composant optionnel affiché derrière la zone de contenu.
    property Component contentBackground: null

    property Item currentPage: null

    readonly property int count: model ? (model.length ?? model.count ?? 0) : 0
    readonly property bool vertical: orientation === TabView.Orientation.Vertical

    signal tabClicked(int index)
    signal pageLoaded(int index, Item page)
    signal pageLoadFailed(int index, url source)

    implicitWidth: 400
    implicitHeight: 300

    function tabTitle(data, index) {
        if (typeof data === "string")
            return data
        if (data && data.title !== undefined)
            return data.title
        if (data && data.name !== undefined)
            return data.name
        return "Tab " + (index + 1)
    }

    function tabIcon(data) {
        return (data && typeof data === "object" && data.icon) ? data.icon : ""
    }

    function pageSource(data) {
        if (!data || typeof data !== "object")
            return ""

        var source = data.source ?? data.file ?? ""
        if (source === null || source === undefined)
            return ""
        source = source.toString()
        if (source === "")
            return ""

        // URL absolue ou chemin absolu : on ne touche à rien
        if (/^[a-z][a-z0-9+.-]*:/i.test(source) || source.charAt(0) === "/")
            return source

        var base = root.baseUrl.toString()
        if (base === "")
            return source
        return base.replace(/\/+$/, "") + "/" + source
    }

    function pageAt(index) {
        var slot = pageRepeater.itemAt(index)
        return slot ? slot.pageItem : null
    }

    function isPageLoaded(index) {
        return pageAt(index) !== null
    }

    function updateCurrentPage() {
        root.currentPage = root.pageAt(root.currentIndex)
    }

    onCurrentIndexChanged: updateCurrentPage()
    Component.onCompleted: updateCurrentPage()

    // --- Barre d'onglets horizontale ---
    Row {
        id: horizontalTabBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: root.tabBarHeight
        spacing: root.tabSpacing
        visible: !root.vertical

        Repeater {
            model: root.model

            TabButton {
                text: root.tabTitle(modelData, index)
                icon: root.tabIcon(modelData)
                selected: root.currentIndex === index
                onClicked: {
                    root.currentIndex = index
                    root.tabClicked(index)
                }
            }
        }
    }

    // --- Barre d'onglets verticale ---
    Column {
        id: verticalTabBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: root.tabBarWidth
        spacing: root.tabSpacing
        visible: root.vertical

        Repeater {
            model: root.model

            TabButton {
                width: verticalTabBar.width
                text: root.tabTitle(modelData, index)
                icon: root.tabIcon(modelData)
                selected: root.currentIndex === index
                vertical: true
                onClicked: {
                    root.currentIndex = index
                    root.tabClicked(index)
                }
            }
        }
    }

    // --- Zone de contenu ---
    Item {
        id: contentArea
        anchors.top: root.vertical ? parent.top : horizontalTabBar.bottom
        anchors.left: root.vertical ? verticalTabBar.right : parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: root.vertical ? 0 : root.contentSpacing
        anchors.leftMargin: root.vertical ? root.contentSpacing : 0

        Loader {
            anchors.fill: parent
            sourceComponent: root.contentBackground
        }

        StackLayout {
            id: stack
            anchors.fill: parent
            anchors.margins: root.contentMargin

            Repeater {
                id: pageRepeater
                model: root.model

                Item {
                    id: pageSlot

                    readonly property Item pageItem: pageLoader.item
                    readonly property bool shouldLoad: !root.lazy || root.preload || index === root.currentIndex
                                                       || (modelData && modelData.preload === true)
                                                       || (root.cache && pageSlot.loadedOnce)

                    property bool loadedOnce: false

                    Loader {
                        id: pageLoader
                        anchors.fill: parent
                        asynchronous: root.asynchronous
                        source: pageSlot.shouldLoad ? root.pageSource(modelData) : ""

                        onLoaded: {
                            pageSlot.loadedOnce = true
                            root.pageLoaded(index, item)
                            if (index === root.currentIndex)
                                root.currentPage = item
                        }

                        onItemChanged: {
                            if (index === root.currentIndex)
                                root.currentPage = pageLoader.item
                        }

                        onStatusChanged: {
                            if (status === Loader.Error)
                                root.pageLoadFailed(index, pageLoader.source)
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        width: parent.width - 32
                        visible: pageLoader.status === Loader.Error
                        text: "Error: Unable to load page\n" + pageLoader.source
                        color: Colors.error
                        font.pixelSize: 13
                        font.family: Settings.fontFamily
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap

                        Component.onCompleted: {
                            if (pageLoader.status === Loader.Error)
                                console.error("TabView: Unable to load page", pageLoader.source)
                        }
                    }
                }
            }
        }
    }
}
