import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    property int percent: 0
    property bool isCharge: false
    property bool isFull: false

    Plasma5Support.DataSource {
        id: batterySource
        engine: "powermanagement"
        connectedSources: ["Battery"]
        onDataChanged: {
            let data = batterySource.data["Battery"]
            if (data) {
                root.percent = data["Percent"] || 0
                root.isCharge = (data["State"] === "Charging" || data["State"] === "FullyCharged" || data["PluggedIn"] === true)

                root.isFull = (data["State"] === "FullyCharged")
            }
        }
    }

    // Plasmoid
    compactRepresentation: MouseArea {

        Layout.preferredWidth: plasmoidRow.implicitWidth + Kirigami.Units.smallSpacing
        Layout.preferredHeight: Plasmoid.configuration.iconSize
        // nhận click
        property bool wasExpanded
        onPressed: wasExpanded = root.expanded
        onClicked: root.expanded = !wasExpanded

        RowLayout {
            id: plasmoidRow
            // Offset the percentage to the right or left
            layoutDirection: Plasmoid.configuration.fontposR ? Qt.RightToLeft : Qt.LeftToRight
            anchors.fill: parent
            spacing: plasmoid.configuration.fontPad
            height: parent.height

            PlasmaComponents.Label {
                id: percent
                text: root.percent + "%"
                font.pixelSize: Plasmoid.configuration.fontSize
                font.bold: Plasmoid.configuration.fontBold
                font.family: Plasmoid.configuration.fontFamily || Kirigami.Theme.defaultFont.family
            }

            Kirigami.Icon {
                id: icon
                source: {
                    let base = "battery-" + (Math.floor(root.percent / 10) * 10).toString().padStart(3, '0');
                    return root.isCharge ? base + "-charging" : base;
                }
                // Use config from settings
                Layout.preferredWidth: Plasmoid.configuration.iconSize
                Layout.preferredHeight: Plasmoid.configuration.iconSize
            }
        }
    }

    // Popup
    fullRepresentation: FullPopup {
        percent: root.percent
        charging: root.isCharge
        full: root.isFull
    }
}
