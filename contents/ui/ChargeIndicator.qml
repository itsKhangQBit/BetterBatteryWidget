import QtQuick
import QtQuick.Shapes
import org.kde.plasma.plasmoid

Rectangle { // only this would work with the scaling
    id: chargeIndicator
    property alias color: boltPath.fillColor
    property int iconheight: 24
    property int iconwidth: 24
    // y'all got custom icons - itsKhangQBit
    property string icon: Plasmoid.configuration.chargeIndicatorCustomSVG ? (Plasmoid.configuration.chargeIndicatorCustomSVGpath != "" ? Plasmoid.configuration.chargeIndicatorCustomSVGpath : "M1 -3.5 a3 3 0 0 0 -2.826 2 H-3 v2 h1.176 A3 3 0 0 0 1 2.5 v-1 h2 V0.5 H1 V-1.5 h2 V-2.5 H1 z
    ") : (Plasmoid.configuration.chargeIndicatorUseBolt ? "M0.39 -3.0 a0.3 0.3 0 0 0 -0.55 -0.2 l-1.71 3.43 a0.2 0.2 0 0 0 0.2 0.27 h1.45 l-0.3 2.34 a0.3 0.3 0 0 0 0.55 0.2 l1.71 -3.43 a0.2 0.2 0 0 0 -0.2 -0.27 h-1.45 z" : "M1 -3.5 a3 3 0 0 0 -2.826 2 H-3 v2 h1.176 A3 3 0 0 0 1 2.5 v-1 h2 V0.5 H1 V-1.5 h2 V-2.5 H1 z")
    color: "transparent"

    Shape {
        preferredRendererType: Shape.CurveRenderer

        // the path below is authored on a 16x16 grid, so scale it to fit whatever size we're given
        // actually this has to scale with the icon size - itsKhangQBit
        // but... the icon does not scale with icon size, it changes step by step (16 -> 24 -> 32 -> 48, etc) so we have to use paintedHeight and width
        transform: Scale {
            xScale: Math.max(chargeIndicator.iconwidth / 32, 1)
            yScale: Math.max(chargeIndicator.iconheight / 32, 1)
            origin.x: 0
            origin.y: 0
        }

        ShapePath {
            id: boltPath
            strokeWidth: 0
            fillColor: "#27ae60" // KDE stock color??

            startX: 0.39
            startY: -3

            PathSvg {
                path: chargeIndicator.icon // if your path fails it's up to you
            }
        }
    }
}
