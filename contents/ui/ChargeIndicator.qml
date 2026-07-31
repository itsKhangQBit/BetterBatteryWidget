import QtQuick
import QtQuick.Shapes
import org.kde.plasma.plasmoid

Rectangle { // only this would work with the scaling
    id: chargeIndicator
    property alias color: boltPath.fillColor
    property int iconheight: 24
    property int iconwidth: 24
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
                path: "M0.39 -3.0 a0.3 0.3 0 0 0 -0.55 -0.2 l-1.71 3.43 a0.2 0.2 0 0 0 0.2 0.27 h1.45 l-0.3 2.34 a0.3 0.3 0 0 0 0.55 0.2 l1.71 -3.43 a0.2 0.2 0 0 0 -0.2 -0.27 h-1.45 z"//"M10.4 2a0.7 0.7 0 0 0 -1.17 0l-5.2 10.4a0.5 0.5 0 0 0 0.5 0.7h 4.4  l -0.9 7.1a 0.7 0.7 0 0 0 1.17 0l5.2 -10.4a 0.5 0.5 0 0 0 -0.5 -0.7h -4.4z" //wait, what is this shape? M9 5a3 3 0 0 0-2.826 2H5v2h1.176A3 3 0 0 0 9 11v-1h2V9H9V7h2V6H9z is a plug... and this is a bolt!
            }
        }
    }
}
