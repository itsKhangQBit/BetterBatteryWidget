import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.14 as Kirigami

Item {
    id: root

    property int percent: 0
    property bool isCharge: false
    property bool isFull: false
    property string icon: "battery-070"
    property string health: "100%"
    property string timeleft: "0"
    property bool expanded: false
    property alias exec: exec
    property bool horizontal: plasmoid.location === 5 || plasmoid.location === 6 // make sure that it's left/right, no quick shi like >= 5

    PlasmaCore.DataSource {
        id: batterySrc
        engine: "powermanagement"
        connectedSources: ["Battery"]
        interval: 1000
        onDataChanged: updateData()
    }

    Plasmoid.hideOnWindowDeactivate: !plasmoid.configuration.pinned // had to link with the xml so that it works

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
            root.timeleft = data["Smoothed Remaining msec"] || "idk"
            root.timeleft = formatTime(root.timeleft)
        }
    }

    PlasmaCore.DataSource {
        id: exec
        engine: "executable"
        connectedSources: []
        interval: 60000
        onNewData: {
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

        function runCMD(cmd) {
            connectSource(cmd);
        }
    }

    // Plasmoid
    Plasmoid.compactRepresentation: MouseArea {

        Layout.preferredWidth: plasmoidRow.implicitWidth + Kirigami.Units.smallSpacing
        Layout.preferredHeight: plasmoid.configuration.paneliconSize
        // get the click action to open the popup
        property bool wasExpanded
        onPressed: wasExpanded = root.expanded
        onClicked: Plasmoid.expanded = !wasExpanded

        GridLayout {
            id: plasmoidRow
            // Offset the percentage to the right or left
            layoutDirection: plasmoid.configuration.panelfontPosR ? Qt.RightToLeft : Qt.LeftToRight
            anchors.fill: parent
            rowSpacing: Plasmoid.configuration.panelfontPad
            columnSpacing: Plasmoid.configuration.panelfontPad
            height: parent.height

            rows: horizontal ? -1 : 1
            columns: horizontal ? 1 : -1

            PlasmaComponents.Label {
                id: percent
                text: root.percent + "%"
                font.pixelSize: plasmoid.configuration.panelfontSize
                color: {
                    if (!plasmoid.configuration.panelcustomcolor) return plasmoid.configuration.panelpercentColor || Kirigami.Theme.textColor;
                    let percentInt = parseInt(root.percent, 10)
                    if (isNaN(percentInt)) return "#FFFFFF" // what the hell is the percentage
                        if (percentInt >= plasmoid.configuration.panelMidpercent) return plasmoid.configuration.paneldynamicHighcolor // still going strong
                            if (percentInt >= plasmoid.configuration.popupLowpercent) return plasmoid.configuration.paneldynamicMidcolor
                                return plasmoid.configuration.paneldynamicLowcolor // go charge, emergencyyyyyy
                }
                font.italic: plasmoid.configuration.panelfontItalic
                font.underline: plasmoid.configuration.panelfontUnderline
                font.bold: plasmoid.configuration.panelfontBold
                font.family: plasmoid.configuration.panelfontFamily || Kirigami.Theme.defaultFont.family
                width: opacity > 0 ? implicitWidth : 0
                z: 1
                visible: opacity > 0
                opacity: {
                    let percentInt = parseInt(root.percent, 10)
                    if (isNaN(percentInt)) return plasmoid.configuration.panelshowPercent ? 0.8 : 0;
                    return plasmoid.configuration.panelshowPercent ? 1 : 0
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.InOutCubic
                    }
                }
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
                rotation: Plasmoid.configuration.paneliconRotate ? -90 : 0
                // for some god who knows reason, i love animations
                Behavior on rotation {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.InOutQuad
                    }
                }

                width: opacity > 0 ? implicitWidth : 0
                z: 0
                visible: opacity > 0
                opacity: {
                    let percentInt = parseInt(root.percent, 10)
                    if (isNaN(percentInt)) return plasmoid.configuration.panelshowIcon ? 0.8 : 0;
                    return plasmoid.configuration.panelshowIcon ? 1 : 0
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.InOutCubic
                    }
                }
                Layout.preferredWidth: plasmoid.configuration.paneliconSize
                Layout.preferredHeight: plasmoid.configuration.paneliconSize
            }
        }
    }

    // Popup
    Plasmoid.fullRepresentation: FullPopup {
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
            if (hr > 0 || plasmoid.configuration.simpleTime === false) {
                // user enabled padding?
                let hour =  plasmoid.configuration.padHr ? hrpadded : hr
                return hour + ":" + mpadded + ":" + spadded;
            }
            let min = plasmoid.configuration.padMin ? mpadded : m
            return min + ":" + spadded;
        }
    }
}
