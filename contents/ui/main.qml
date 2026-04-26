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
    property string icon: battery-70
    property string health: "100%"
    property string timeleft: "0"

    Plasma5Support.DataSource {
        id: batterySrc
        engine: "powermanagement"
        connectedSources: ["Battery"]
        interval: 1000
        onDataChanged: {
            let data = batterySrc.data["Battery"]
            if (data) {
                root.percent = data["Percent"] || 0
                root.isCharge = (data["State"] === "Charging" || data["State"] === "FullyCharged" || data["PluggedIn"] === true)

                root.isFull = (data["State"] === "FullyCharged")
                root.timeleft = data["Smoothed Remaining msec"] || ""
                root.timeleft = formatTime(root.timeleft)
            }
        }
    }

    Plasma5Support.DataSource {
        id: exec
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            var output = data["stdout"].trim() || "";
            // split the line to read the values
            var line = output.trim().split('\n');

            if (line.length >= 2) {
                let chargeFull = parseInt(line[0]);
                let chargeNew = parseInt(line[1]);

                let bathealth = parseFloat(((chargeFull / chargeNew) * 100).toFixed(2)); // Make the calcs, cut de decimals, throw the unnecessary 0s away
                root.health = bathealth + <= 100 ? bathealth + "%" : "100%";
            }
            disconnectSource(sourceName);
        }

        function runCMD(cmd) {
            connectSource(cmd);
        }
    }

    // Plasmoid
    compactRepresentation: MouseArea {

        Layout.preferredWidth: plasmoidRow.implicitWidth + Kirigami.Units.smallSpacing
        Layout.preferredHeight: Plasmoid.configuration.iconSize
        // get the click action to open the popup
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
                    root.icon = root.isCharge ? base + "-charging" : base;
                    return root.icon;
                }
                // Use config from settings
                Layout.preferredWidth: Plasmoid.configuration.iconSize
                Layout.preferredHeight: Plasmoid.configuration.iconSize
            }
        }
    }

    // Popup
    fullRepresentation: FullPopup {
        widgetdata: root
    }

    function formatTime(msec) {
        if (msec < 0 || isNaN(msec) || msec === null) {
            return i18n("Calculating...");
        } else {
            let tMin = Math.floor(msec / 60000);
            let hr = Math.floor(tMin / 60);
            let m = tMin % 60;
            let s = Math.floor((msec % 60000) / 1000)
            // get the padded time
            let hrpadded = hr.toString().padStart(2, '0');
            let mpadded = m.toString().padStart(2, '0');
            let spadded = s.toString().padStart(2, '0');
            // not simplified or there's more than 1 hour left?
            if (hr > 0 || Plasmoid.configuration.simpleTime === false) {
                // user enabled padding?
                let hour =  Plasmoid.configuration.padHr ? hrpadded : hr
                return hour + ":" + mpadded + ":" + spadded;
            }
            let min = Plasmoid.configuration.padMin ? mpadded : m
            return min + ":" + spadded;
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: {
            exec.runCMD("cat /sys/class/power_supply/BAT*/charge_full /sys/class/power_supply/BAT*/charge_full_design");
        }
    }
}
