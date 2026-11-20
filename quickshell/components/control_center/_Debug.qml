import QtQuick

import "../common/interactive"

Item {
    id: root

    implicitWidth: 800
    implicitHeight: 600

    TabView {
        anchors.fill: parent
        anchors.margins: 20
        baseUrl: Qt.resolvedUrl("debug")
        model: [
            { title: "Infos", source: "InfosPage.qml" },
            { title: "Components", source: "ComponentsPage.qml" },
            { title: "Color Scheme", source: "ColorSchemePage.qml" },
            { title: "Testing", source: "TestingPage.qml" }
        ]
    }
}
