import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.batterymonitor

PlasmoidItem {
    id: root

    property string percent: "--"
    property bool isCharge: false
    property bool isFull: false
    property string state: ""
    property string icon: "battery-000"
    property string health: "100%"
    property string timeleft: "0" // string because it'll say "Error: Cannot assign QString to int"
    readonly property bool horizontal: Plasmoid.location === 5 || Plasmoid.location === 6 // make sure that it's left/right, no quick shi like >= 5
    property alias getBatHealth: getBatHealth //need the alias so that we can call getBatHealth from FullPopup

    Plasma5Support.DataSource {
        id: batterySrc
        engine: "powermanagement"
        connectedSources: ["Battery"]
        interval: 1000
        onDataChanged: updateData()
    }

    hideOnWindowDeactivate: !Plasmoid.configuration.pinned // had to link with the xml so that it works

    toolTipMainText: root.percent + "%"
    toolTipSubText: {
        let lines = [stateText()]
        if (root.state !== "FullyCharged") lines.push(timeText())
        lines.push(i18n("Health: %1", root.health))
        return lines.join("\n")
    }

    function stateText() {
        switch (root.state) {
            case "Charging": return i18n("Charging")
            case "FullyCharged": return i18n("Fully charged")
            case "Discharging": return i18n("Discharging")
            case "NotCharging": return i18n("Not charging")
            case "PendingCharge": return i18n("Pending charge")
            case "PendingDischarge": return i18n("Pending discharge")
            default: return root.isCharge ? i18n("Charging") : i18n("Discharging")
        }
    }

    function timeText() {
        if (root.timeleft === i18n("Calculating...")) return root.timeleft
        return root.isCharge ? i18n("Time until full: %1", root.timeleft) : i18n("Time remaining: %1", root.timeleft)
    }

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
        //getBatTime.get("qdbus --system org.freedesktop.UPower /org/freedesktop/UPower/devices/battery_BAT0 org.freedesktop.UPower.Device.TimeToEmpty") // raw fallback

        let data = batterySrc.data["Battery"]
        if (data) {
            root.percent = data["Percent"].toString() || "--"
            root.isCharge = (data["State"] === "Charging" || data["State"] === "FullyCharged" || data["PluggedIn"] === true)

            root.isFull = (data["State"] === "FullyCharged")
            root.state = data["State"] || ""

            root.timeleft = data["Smoothed Remaining msec"] || ""
            //console.log(root.rawTimeleft, root.timeleft) // unimplemented stuff, working on
            //if (root.timeleft === "") root.timeleft = root.rawTimeleft // fallback if undefied
            root.timeleft = formatTime(root.timeleft)
        }
    }

    /*
    Plasma5Support.DataSource {
        id: getBatTime
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            root.rawTimeleft = parseInt(getBatTime.data["stdout"]) || ""
            disconnectSource(sourceName)
        }

        function get(cmd) {
            connectSource(cmd);
        }
    }
    */

    Plasma5Support.DataSource {
        id: getBatHealth
        engine: "executable"
        connectedSources: []
        interval: 60000
        onNewData: (sourceName, data) => {
            var output = data["stdout"].trim() || "";

            // take the raw stuff, it's already processed
            let bathealth = parseFloat(output).toFixed(2) || "broken"; // just convert :)))
            // instead of root.health = bathealth + "%";, which might display "110%"
            // we use this!
            root.health = isNaN(bathealth) ? "--" : (bathealth > 100) ? "100%" : bathealth + "%";
        }

        function get(cmd) {
            connectSource(cmd);
        }
    }

    // Plasmoid
    compactRepresentation: MouseArea {

        Layout.preferredWidth: plasmoidRow.implicitWidth + Kirigami.Units.smallSpacing
        Layout.preferredHeight: plasmoidRow.implicitHeight + Kirigami.Units.smallSpacing
        Layout.minimumWidth: plasmoidRow.implicitWidth + Kirigami.Units.smallSpacing
        Layout.minimumHeight: plasmoidRow.implicitHeight + Kirigami.Units.smallSpacing
        // get the click action to open the popup
        property bool wasExpanded: false
        onPressed: wasExpanded = root.expanded
        onClicked: root.expanded = !wasExpanded

        GridLayout {
            id: plasmoidRow
            // Offset the percentage to the right or left, its your choice
            layoutDirection: Plasmoid.configuration.panelfontPosR ? Qt.RightToLeft : Qt.LeftToRight
            anchors.fill: parent
            rowSpacing: Plasmoid.configuration.panelfontPad
            columnSpacing: Plasmoid.configuration.panelfontPad
            height: parent.height

            rows: horizontal ? -1 : 1
            columns: horizontal ? 1 : -1

            PlasmaComponents.Label {
                id: percent
                text: root.percent + "%"
                font.pixelSize: Plasmoid.configuration.panelfontSize
                color: {
                    if (!Plasmoid.configuration.panelcustomcolor) return Plasmoid.configuration.panelpercentColor || Kirigami.Theme.textColor;
                    let percentInt = parseInt(root.percent, 10)
                    if (isNaN(percentInt)) return "#FFFFFF" // what the hell is the percentage
                            if (percentInt >= Plasmoid.configuration.panelMidpercent) return Plasmoid.configuration.paneldynamicHighcolor // still going strong
                                if (percentInt >= Plasmoid.configuration.panelLowpercent) return Plasmoid.configuration.paneldynamicMidcolor
                                    return Plasmoid.configuration.paneldynamicLowcolor // go charge, emergencyyyyyy
                }
                font.bold: Plasmoid.configuration.panelfontBold
                font.italic: Plasmoid.configuration.panelfontItalic
                font.underline: Plasmoid.configuration.panelfontUnderline
                font.family: Plasmoid.configuration.panelfontFamily || Kirigami.Theme.defaultFont.family
                width: opacity > 0 ? implicitWidth : 0
                z: 1
                visible: opacity > 0
                opacity: {
                    let percentInt = parseInt(root.percent, 10)
                    if (isNaN(percentInt)) return Plasmoid.configuration.panelshowPercent ? 0.8 : 0;
                    return Plasmoid.configuration.panelshowPercent ? 1 : 0
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.InOutCubic
                    }
                }
            }

            Item {
                id: iconContainer
                rotation: Plasmoid.configuration.paneliconRotate ? -90 : 0
                // for some god who knows reason, i love animations
                Behavior on rotation {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.InOutQuad
                    }
                }
                visible: opacity > 0
                opacity: {
                    let percentInt = parseInt(root.percent, 10)
                    if (isNaN(percentInt)) return Plasmoid.configuration.panelshowIcon ? 0.8 : 0;
                    return Plasmoid.configuration.panelshowIcon ? 1 : 0
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.InOutCubic
                    }
                }
                width: opacity > 0 ? icon.implicitWidth : 0
                z: 0
                Layout.preferredWidth: Plasmoid.configuration.paneliconSize
                Layout.preferredHeight: Plasmoid.configuration.paneliconSize

                Kirigami.Icon {
                    id: icon
                    anchors.fill: parent
                    source: {
                        let intpercent = parseInt(root.percent, 10) || 0
                        let percent = (Math.floor(intpercent / 10) *  10).toString().padStart(3, '0');
                        let base = "battery-" + percent
                        let useCustomCharge = root.isCharge && Plasmoid.configuration.chargeIndicatorCustomColor
                        root.icon = root.isCharge && !useCustomCharge ? base + "-charging" : base;
                        return root.icon;
                    }
                }

                ChargeIndicator {
                    anchors.fill: icon
                    visible: root.isCharge && Plasmoid.configuration.chargeIndicatorCustomColor
                    color: Plasmoid.configuration.chargeIndicatorColor
                    z: 1
                }
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
