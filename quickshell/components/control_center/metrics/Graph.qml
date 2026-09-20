import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property var values: []           // history, oldest first
    property real maxValue: 1         // used when autoScale is false
    property bool autoScale: false    // scale to the highest visible sample
    property real minScale: 1         // floor for the auto scale
    property int maxSamples: 60       // slots used to lay the samples out
    property color lineColor: "#a6c8ff"
    property real lineWidth: 2
    property bool fill: true
    property bool curved: true
    property bool showLastPoint: false

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

    readonly property point lastPoint: (values && values.length > 0)
        ? Qt.point(_x(values.length - 1), _y(values[values.length - 1]))
        : Qt.point(0, 0)

    function _x(index) {
        return (index / Math.max(1, maxSamples - 1)) * width;
    }

    function _y(value) {
        const ratio = Math.max(0, Math.min(1, value / scaleMax));
        return height - ratio * height;
    }

    function _buildPath() {
        const vals = values;
        const w = width;
        const h = height;
        if (!vals || vals.length < 2 || w <= 0 || h <= 0)
            return "";

        const points = [];
        for (let i = 0; i < vals.length; i++)
            points.push({ x: _x(i), y: _y(vals[i]) });

        let d = "M " + points[0].x.toFixed(2) + " " + points[0].y.toFixed(2);
        if (curved) {
            for (let i = 0; i < points.length - 1; i++) {
                const p0 = i > 0 ? points[i - 1] : points[i];
                const p1 = points[i];
                const p2 = points[i + 1];
                const p3 = (i + 2 < points.length) ? points[i + 2] : p2;
                const c1x = p1.x + (p2.x - p0.x) / 6;
                const c1y = p1.y + (p2.y - p0.y) / 6;
                const c2x = p2.x - (p3.x - p1.x) / 6;
                const c2y = p2.y - (p3.y - p1.y) / 6;
                d += " C " + c1x.toFixed(2) + " " + c1y.toFixed(2)
                    + " " + c2x.toFixed(2) + " " + c2y.toFixed(2)
                    + " " + p2.x.toFixed(2) + " " + p2.y.toFixed(2);
            }
        } else {
            for (let i = 1; i < points.length; i++)
                d += " L " + points[i].x.toFixed(2) + " " + points[i].y.toFixed(2);
        }

        if (fill) {
            const last = points[points.length - 1];
            d += " L " + last.x.toFixed(2) + " " + h
                + " L " + points[0].x.toFixed(2) + " " + h + " Z";
        }
        return d;
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        layer.enabled: true
        layer.samples: 4

        ShapePath {
            strokeColor: root.lineColor
            strokeWidth: root.lineWidth
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            fillGradient: LinearGradient {
                x1: 0
                y1: 0
                x2: 0
                y2: root.height
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(root.lineColor.r, root.lineColor.g, root.lineColor.b, root.fill ? 0.28 : 0.0)
                }
                GradientStop {
                    position: 1.0
                    color: Qt.rgba(root.lineColor.r, root.lineColor.g, root.lineColor.b, 0.0)
                }
            }
            PathSvg {
                path: root._buildPath()
            }
        }
    }

    Item {
        id: lastPointItem
        visible: root.showLastPoint && root.values && root.values.length > 1
        x: root.lastPoint.x
        y: root.lastPoint.y
        width: 1
        height: 1

        Rectangle {
            anchors.centerIn: parent
            width: 6
            height: 6
            radius: 3
            color: root.lineColor
        }

        Rectangle {
            anchors.centerIn: parent
            width: 8
            height: 8
            radius: 4
            color: "transparent"
            border.width: 1.5
            border.color: root.lineColor

            SequentialAnimation on scale {
                loops: Animation.Infinite
                running: lastPointItem.visible
                NumberAnimation {
                    from: 1.0
                    to: 3.0
                    duration: 1500
                    easing.type: Easing.OutCubic
                }
                PauseAnimation { duration: 150 }
            }

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: lastPointItem.visible
                NumberAnimation {
                    from: 0.55
                    to: 0.0
                    duration: 1500
                    easing.type: Easing.OutCubic
                }
                PauseAnimation { duration: 150 }
            }
        }
    }
}
