import QtQuick
import QtQuick.Shapes

// Draws the charging bolt ourselves so its color isn't at the mercy of the
// icon theme's color scheme (some themes render it as a barely-visible
// light green on top of a white battery icon).
Shape {
    id: chargeIndicator
    property alias color: boltPath.fillColor

    preferredRendererType: Shape.CurveRenderer

    // the path below is authored on a 16x16 grid, so scale it to fit whatever size we're given
    transform: Scale {
        xScale: chargeIndicator.width / 16
        yScale: chargeIndicator.height / 16
    }

    ShapePath {
        id: boltPath
        strokeWidth: 0
        fillColor: "#27ae60"
        PathSvg {
            path: "M9 5a3 3 0 0 0-2.826 2H5v2h1.176A3 3 0 0 0 9 11v-1h2V9H9V7h2V6H9z"
        }
    }
}
