import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    property string percent: "--"
    property bool isCharge: false
    property bool isFull: false
    property string icon: "battery-000"
    property string health: "100%"
    property string timeleft: "0"
    property alias getBatHealth: getBatHealth //need the alias so that we can call getBatHealth from FullPopup

    Plasma5Support.DataSource {
        id: batterySrc
        engine: "powermanagement"
        connectedSources: ["Battery"]
        interval: 1000
        onDataChanged: updateData()
    }

    hideOnWindowDeactivate: !Plasmoid.configuration.pinned // had to link with the xml so that it works

    // we have to set a timer so that it actually updates fast
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: updateData()
    }

    // make a func so that the code looks neater
    function updateData() {
        let data = batterySrc.data["Battery"]
        if (data) {
            root.percent = data["Percent"].toString() || "--"
            root.isCharge = (data["State"] === "Charging" || data["State"] === "FullyCharged" || data["PluggedIn"] === true)

            root.isFull = (data["State"] === "FullyCharged")
            root.timeleft = data["Smoothed Remaining msec"] || ""
            root.timeleft = formatTime(root.timeleft)
        }
    }

    Plasma5Support.DataSource {
        id: getBatHealth
        engine: "executable"
        connectedSources: []
        interval: 60000
        onNewData: (sourceName, data) => {
            var output = data["stdout"].trim() || "";
            // split the line to read the values
            var line = output.trim().split('\n');

            if (line.length >= 2) {
                let chargeFull = parseInt(line[0]);
                let chargeNew = parseInt(line[1]);

                let bathealth = parseFloat(((chargeFull / chargeNew) * 100).toFixed(2)); // Make the calcs, cut the decimals, throw the unnecessary 0s away
                // instead of root.health = bathealth + "%";, which might display "110%"
                // we use this!
                root.health = (bathealth > 100) ? "100%" : bathealth + "%";
            }
        }

        function get(cmd) {
            connectSource(cmd);
        }
    }

    // Plasmoid
    compactRepresentation: MouseArea {

        Layout.preferredWidth: plasmoidRow.implicitWidth + Kirigami.Units.smallSpacing
        Layout.preferredHeight: Plasmoid.configuration.paneliconSize
        // get the click action to open the popup
        property bool wasExpanded: false
        onPressed: wasExpanded = root.expanded
        onClicked: root.expanded = !wasExpanded

        RowLayout {
            id: plasmoidRow
            // Offset the percentage to the right or left, its your choice
            layoutDirection: Plasmoid.configuration.panelfontPosR ? Qt.RightToLeft : Qt.LeftToRight
            anchors.fill: parent
            spacing: plasmoid.configuration.panelfontPad
            height: parent.height

            PlasmaComponents.Label {
                id: percent
                text: root.percent + "%"
                font.pixelSize: Plasmoid.configuration.panelfontSize
                color: Plasmoid.configuration.panelpercentColor || Kirigami.Theme.textColor
                font.bold: Plasmoid.configuration.panelfontBold
                font.italic: Plasmoid.configuration.panelfontItalic
                font.underline: Plasmoid.configuration.panelfontUnderline
                font.family: Plasmoid.configuration.panelfontFamily || Kirigami.Theme.defaultFont.family
            }

            Kirigami.Icon {
                id: icon
                source: {
                    let intpercent = parseInt(root.percent, 10) || 0
                    let percent = (Math.floor(intpercent / 10) *  10).toString().padStart(3, '0');
                    let base = "battery-" + percent
                    root.icon = root.isCharge ? base + "-charging" : base;
                    return root.icon;
                }

                // Use config from settings
                Layout.preferredWidth: Plasmoid.configuration.paneliconSize
                Layout.preferredHeight: Plasmoid.configuration.paneliconSize
            }
        }
    }

    // Popup
    fullRepresentation: FullPopup {
        widgetdata: root
    }

    function formatTime(msec) {
        if (msec < 0 || isNaN(msec) || msec === "") {
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
}
