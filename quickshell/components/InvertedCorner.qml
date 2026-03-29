import QtQuick

Item {
    id: root

    enum Corner {
        TopLeft,
        TopRight,
        BottomLeft,
        BottomRight
    }

    property int corner: InvertedCorner.Corner.TopLeft
    property int cornerRadius: 20
    property color cornerColor: "red"

    implicitWidth: cornerRadius
    implicitHeight: cornerRadius

    Canvas {
        anchors.fill: parent

        onPaint: {
            const ctx = getContext("2d");
            const r = cornerRadius;
            ctx.reset();
            ctx.fillStyle = cornerColor;
            ctx.beginPath();

            switch (corner) {
            case InvertedCorner.Corner.TopLeft:
                // Fill wedge in top-left, leaving the inner quarter-circle transparent
                ctx.moveTo(0, 0);
                ctx.lineTo(r, 0);
                ctx.arc(r, r, r, 1.5 * Math.PI, Math.PI, true);
                ctx.lineTo(0, 0);
                break;
            case InvertedCorner.Corner.TopRight:
                ctx.moveTo(r, 0);
                ctx.lineTo(r, r);
                ctx.arc(0, r, r, 0, 1.5 * Math.PI, true);
                ctx.lineTo(r, 0);
                break;
            case InvertedCorner.Corner.BottomLeft:
                ctx.moveTo(0, r);
                ctx.lineTo(0, 0);
                ctx.arc(r, 0, r, Math.PI, 0.5 * Math.PI, true);
                ctx.lineTo(0, r);
                break;
            case InvertedCorner.Corner.BottomRight:
                ctx.moveTo(r, r);
                ctx.lineTo(0, r);
                ctx.arc(0, 0, r, 0.5 * Math.PI, 0, true);
                ctx.lineTo(r, r);
                break;
            }

            ctx.closePath();
            ctx.fill();
        }

        onCornerRadiusChanged: requestPaint()
        onCornerColorChanged:  requestPaint()
        onCornerChanged:       requestPaint()
        //onWidthChanged:        requestPaint()
        //onHeightChanged:       requestPaint()

        // Expose parent properties to the canvas context
        property int cornerRadius: root.cornerRadius
        property color cornerColor: root.cornerColor
        property int corner: root.corner
    }
}