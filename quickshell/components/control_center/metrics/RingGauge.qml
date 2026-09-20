import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property real value: 0                 // 0..1
    property real startAngle: 135          // 0 = 3 o'clock, clockwise
    property real sweepAngle: 270
    property real lineWidth: 9
    property color trackColor: Qt.rgba(1, 1, 1, 0.08)
    property color progressColor: "#a6c8ff"
    property real glowOpacity: 0.16
    property real glowWidth: 2.0           // glow stroke width, relative to lineWidth
    property int animationDuration: 700

    implicitWidth: 140
    implicitHeight: 140

    readonly property real _clamped: Math.max(0, Math.min(1, value))
    // Keep the glow (and the round caps) inside the item bounds: the Shape is
    // rendered through a layer, which would otherwise clip them.
    readonly property real _padding: lineWidth * (glowWidth / 2) + 1
    readonly property real _radius: Math.max(1, Math.min(width, height) / 2 - _padding)
    property real _displayValue: _clamped

    default property alias content: contentItem.data

    Behavior on _displayValue {
        NumberAnimation {
            duration: root.animationDuration
            easing.type: Easing.OutCubic
        }
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        layer.enabled: true
        layer.samples: 4

        // Track
        ShapePath {
            strokeColor: root.trackColor
            strokeWidth: root.lineWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root._radius
                radiusY: root._radius
                startAngle: root.startAngle
                sweepAngle: root.sweepAngle
            }
        }

        // Soft glow behind the progress
        ShapePath {
            strokeColor: Qt.rgba(root.progressColor.r, root.progressColor.g, root.progressColor.b, root.glowOpacity)
            strokeWidth: root.lineWidth * root.glowWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root._radius
                radiusY: root._radius
                startAngle: root.startAngle
                sweepAngle: root.sweepAngle * root._displayValue
            }
        }

        // Progress
        ShapePath {
            strokeColor: root.progressColor
            strokeWidth: root.lineWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root._radius
                radiusY: root._radius
                startAngle: root.startAngle
                sweepAngle: root.sweepAngle * root._displayValue
            }
        }
    }

    Item {
        id: contentItem
        anchors.fill: parent
    }
}
