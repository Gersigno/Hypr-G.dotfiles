import QtQuick

import "../../../utils"
import "../../common/interface"
import "../../common/interactive"
import "../dashboard/quicksettings"

Rectangle {
    id: page

    color: "transparent"
    clip: true

    BackgroundLayer {
        anchors.fill: parent
    }

    readonly property color textColor: Colors.on_surface_variant

    readonly property var buttonVariants: [
        { label: "Primary button", severity: Button.Severity.Primary },
        { label: "Secondary button", severity: Button.Severity.Secondary },
        { label: "Warning button", severity: Button.Severity.Warning },
        { label: "Danger button", severity: Button.Severity.Danger }
    ]

    readonly property var buttonGroups: [
        { title: "Default buttons", disabled: false, fullRounded: false },
        { title: "Disabled buttons", disabled: true, fullRounded: false },
        { title: "Full rounded buttons", disabled: false, fullRounded: true }
    ]

    readonly property var qsButtonVariants: [
        { label: "Primary", description: "This is a primary button", severity: QSButton.Severity.Primary, options: ["Option A", "Option B", "Option C"] },
        { label: "Secondary", description: "This is a secondary button", severity: QSButton.Severity.Secondary, options: [] },
        { label: "Warning", description: "This is a warning button", severity: QSButton.Severity.Warning, options: [] },
        { label: "Danger", description: "This is a danger button", severity: QSButton.Severity.Danger, options: [] }
    ]

    readonly property var qsButtonGroups: [
        { title: "Default QSButtons", showDescription: false },
        { title: "Description", showDescription: true }
    ]

    Flickable {
        anchors.fill: parent
        anchors.margins: 16
        contentHeight: componentsColumn.implicitHeight
        clip: true

        Column {
            id: componentsColumn
            width: parent.width
            spacing: 23

            Text {
                text: "Buttons :"
                color: page.textColor
                font.pixelSize: 18
                font.bold: true
            }

            Row {
                spacing: 12

                Repeater {
                    model: page.buttonGroups

                    delegate: Column {
                        id: buttonGroup
                        readonly property bool groupDisabled: modelData.disabled
                        readonly property bool groupRounded: modelData.fullRounded
                        spacing: 8

                        Text {
                            text: modelData.title
                            color: page.textColor
                            font.pixelSize: 12
                        }

                        Repeater {
                            model: page.buttonVariants

                            delegate: Button {
                                text: modelData.label
                                severity: modelData.severity
                                disabled: buttonGroup.groupDisabled
                                fullRounded: buttonGroup.groupRounded
                            }
                        }
                    }
                }
            }

            Text {
                text: "QSButtons (QuickSettings):"
                color: page.textColor
                font.pixelSize: 18
                font.bold: true
            }

            Item {
                property bool isOverlayHost: true
                width: parent.width
                implicitHeight: qsButtonsRow.implicitHeight

                Row {
                    id: qsButtonsRow
                    spacing: 12

                    Repeater {
                        model: page.qsButtonGroups

                        delegate: Column {
                            readonly property bool showDescription: modelData.showDescription
                            spacing: 8

                            Text {
                                text: modelData.title
                                color: page.textColor
                                font.pixelSize: 12
                            }

                            Repeater {
                                model: page.qsButtonVariants

                                delegate: QSButton {
                                    text: modelData.label
                                    description: showDescription ? modelData.description : ""
                                    topIcon: "󰀻"
                                    severity: modelData.severity
                                    options: modelData.options ?? []
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
