import QtQuick

Item {
    id: root

    property var values: []           // history, oldest first
    property real maxValue: 1         // used when autoScale is false
    property bool autoScale: false
    property real minScale: 1
    property int maxSamples: 48       // slots used to lay the bars out
    property color barColor: "#a6c8ff"
    property real barGap: 1.2
    property real barRadius: 4        // clamped to half the bar width (pill shape)
    property real minBarHeight: 2
    property bool highlightLast: true
    property int animationDuration: 450

    readonly property real scaleMax: {
        if (!autoScale)
            return Math.max(maxValue, 0.000001);
        let max = 0;
        for (let i = 0; i < values.length; i++) {
            if (values[i] > max)
                max = values[i];
        }
        return Math.max(max * 1.25, minScale);
    }

    readonly property var visibleValues: {
        if (!values)
            return [];
        if (values.length <= maxSamples)
            return values;
        return values.slice(values.length - maxSamples);
    }

    readonly property real slotWidth: width / Math.max(1, maxSamples)

    Repeater {
        model: root.visibleValues.length

        delegate: Rectangle {
            required property int index

            readonly property real ratio: Math.max(0, Math.min(1, (root.visibleValues[index] ?? 0) / root.scaleMax))
            readonly property bool isLast: index === root.visibleValues.length - 1

            x: index * root.slotWidth
            width: Math.max(1, root.slotWidth - root.barGap)
            height: Math.max(root.minBarHeight, ratio * root.height)
            y: root.height - height
            radius: Math.min(root.barRadius, width / 2)
            color: root.barColor
            opacity: (root.highlightLast && isLast) ? 1.0 : 0.35 + 0.55 * ratio

            Behavior on height {
                NumberAnimation {
                    duration: root.animationDuration
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}
