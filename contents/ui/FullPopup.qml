import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami
import "."

Item {
    id: popupRoot

    property bool inBlockingMenu: false
    property string pwrmgrBackend: "none"
    property int ispwrSave: 0 // we can also use int for bool: false is 0, true is 1 (this will be used for the TLP switch)
    property var widgetdata: root
    property alias batMgr: batMgr

    implicitWidth: Math.max(headers.implicitWidth, mainLayout.implicitWidth)
    implicitHeight: mainLayout.implicitHeight + headers.implicitHeight
    anchors.margins: Kirigami.Units.largeSpacing
    clip: true

    Layout.preferredWidth: implicitWidth + (Kirigami.Units.largeSpacing * 5)
    Layout.preferredHeight: implicitHeight + (Kirigami.Units.largeSpacing * 5)
    Layout.minimumWidth: implicitWidth + (Kirigami.Units.largeSpacing * 5)
    Layout.minimumHeight: implicitHeight + (Kirigami.Units.largeSpacing * 5)

    SleepBlocker {
        id: sleepBlockerRoot
    }

    Plasma5Support.DataSource {
        id: batMgr
        engine: "executable"
        connectedSources: []
        interval: 5000
        onNewData: (sourceName, data) => {
            var output = data["stdout"] || "";
            // if TLP, choose pwrmgrBackend as tlp, otherwise choose power-profiles-deamon
            if (output.includes("/usr/sbin/tlp") || output.includes("/usr/bin/tlp")) {
                pwrmgrBackend = "tlp";
                batStatus.runCMD("tlp-stat -s | grep 'Mode'");
            } else if (output.includes("/usr/bin/powerprofilesctl")) {
                pwrmgrBackend = "ppd";
                batStatus.runCMD("powerprofilesctl list | grep '*'");
            }
        }

        function check(cmd) {
            connectSource(cmd);
        }
    }

    Plasma5Support.DataSource {
        id: batStatus
        engine: "executable"
        connectedSources: []
        interval: 2000
        onNewData: (sourceName, data) => {
            var output = (data["stdout"] || "");
            // if TLP, choose pwrmgrBackend as tlp, otherwise choose power-profiles-daemon
            if (sourceName.includes("tlp-stat")) {
                if (output.includes("battery")) {
                    popupRoot.ispwrSave = 1;
                } else if (output.includes("AC")) {
                    popupRoot.ispwrSave = 0;
                }
            } else if (sourceName.includes("powerprofilesctl")) {
                if (output.includes("power-saver")) {
                    popupRoot.ispwrSave = 0;
                } else if (output.includes("balanced")) {
                    popupRoot.ispwrSave = 1;
                } else if (output.includes("performance")) {
                    popupRoot.ispwrSave = 2;
                }
            }
        }

        function runCMD(cmd) {
            connectSource(cmd);
        }
    }

    Plasma5Support.DataSource {
        id: batSet
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            disconnectSource(sourceName);
        }

        function set(cmd) {
            connectSource(cmd);
        }
    }

    Component.onCompleted: {
        // is there TLP or power-profiles-daemon
        popupRoot.batMgr.check("which tlp");
        popupRoot.batMgr.check("which powerprofilesctl");
        widgetdata.getBatHealth.get("upower -i $(upower -e | grep battery | head -n 1) | awk '/capacity/ {print $2}' | tr -d ' %' | tr ',' '.'");
        sleepBlockerRoot.chkCafeStat();
        sleepBlockerRoot.getBlockerList();
    }

    Component.onDestruction: {
        popupRoot.batMgr.connectedSources = [];
        batStatus.connectedSources = [];
        sleepBlockerRoot.sleepstat.connectedSources = [];
        sleepBlockerRoot.sleepchk.connectedSources = [];
        widgetdata.getBatHealth.connectedSources = [];
    }

    function batSaver(state) {
        if (pwrmgrBackend === "tlp") {
            let cmd = state ? "pkexec tlp bat" : "pkexec tlp ac";
            batSet.set(cmd);
        }
        else if (pwrmgrBackend === "ppd") {
            let profile = ["power-saver", "balanced", "performance"]
            batSet.set("powerprofilesctl set " + profile[state]);
        }
        // if no pwrmgrBackend, just log cause we can't set anything
        else {
            console.log("Oops, no power manager!");
        }
    }

    // headers
    RowLayout {
        id: headers
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        RowLayout {
            width: mainLabel.width

            PlasmaComponents.Label {
                id: mainLabel
                text: i18n("Battery percentage")
                font.bold: true
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.2
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                visible: opacity > 0
                opacity: popupRoot.inBlockingMenu ? 0 : 1
                Layout.preferredWidth: popupRoot.inBlockingMenu ? 0 : implicitWidth
                clip: true
                horizontalAlignment: Text.AlignRight

                Behavior on opacity {
                    NumberAnimation { duration: 400 }
                }
                Behavior on Layout.preferredWidth {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.InOutCubic
                    }
                }
            }

            // headers
            RowLayout {
                Layout.preferredWidth: popupRoot.inBlockingMenu ? blockmenucontent.implicitWidth : 0 // don't take my precious space
                visible: opacity > 0
                opacity: popupRoot.inBlockingMenu ? 1 : 0
                clip: true

                Behavior on opacity {
                    NumberAnimation { duration: 400 }
                }

                Behavior on Layout.preferredWidth {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.InOutCubic
                    }
                }

                RowLayout {
                    id: blockmenucontent
                    width: implicitWidth
                    PlasmaComponents.ToolButton {
                        icon.name: "arrow-left"
                        onClicked: popupRoot.inBlockingMenu = !popupRoot.inBlockingMenu

                        PlasmaComponents.ToolTip {
                            text: i18n("Back")
                        }
                    }

                    PlasmaComponents.Label {
                        text: widgetdata.percent + "%"
                        font.bold: true
                        font.pixelSize: 16
                    }
                }
            }
        }

        RowLayout {
            id: toolnstatus

            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            // small icon for fun :)
            Item {
                width: 22
                height: 22

                Kirigami.Icon {
                    id: popupHeaderIcon
                    anchors.fill: parent
                    source: widgetdata.icon
                }

                ChargeIndicator {
                    anchors.centerIn: popupHeaderIcon
                    visible: opacity > 0
                    opacity: widgetdata.isCharge && Plasmoid.configuration.chargeIndicatorCustomColor ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
                    color: Plasmoid.configuration.chargeIndicatorColor
                }
            }

            PlasmaComponents.ToolButton {
                icon.name: Plasmoid.configuration.pinned ? "window-unpin" : "window-pin"
                checkable: true
                checked: Plasmoid.configuration.pinned
                visible: Plasmoid.location !== 0
                onToggled: {
                    Plasmoid.configuration.pinned = !Plasmoid.configuration.pinned
                }
                PlasmaComponents.ToolTip {
                    text: i18n("Keep applet popup open")
                }
            }
        }
    }

    ColumnLayout {
        id: mainLayout
        anchors {
            left: parent.left
            right: parent.right
            top: headers.bottom
            bottom: parent.bottom
        }
        spacing: Kirigami.Units.largeSpacing

        opacity: popupRoot.inBlockingMenu === true ? 0 : 1
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation { duration: 400 }
        }

        // battery percentage
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            PlasmaComponents.Label {
                text: {
                    if (widgetdata.isFull) {
                        return i18n("Fully charged");
                    }
                    return widgetdata.isCharge ? i18n("Charging") : i18n("Discharging")
                }
                opacity: 0.7
                Layout.alignment: {
                    let alignlist = [Qt.AlignLeft, Qt.AlignHCenter, Qt.AlignRight]
                    let pos = Plasmoid.configuration.popuppercentPos || 0
                    return alignlist[pos]
                }
            }

            PlasmaComponents.Label {
                text: widgetdata.percent + "%"
                font.pixelSize: Plasmoid.configuration.popupfontSize
                opacity: {
                    let percentInt = parseInt(widgetdata.percent, 10)
                    if (isNaN(percentInt)) return 0.8;
                    return 1
                }
                color: {
                    if (!Plasmoid.configuration.popupcustomcolor) return Plasmoid.configuration.popuppercentColor || Kirigami.Theme.textColor;
                    let percentInt = parseInt(widgetdata.percent, 10)
                    if (isNaN(percentInt)) return Kirigami.Theme.textColor // what the hell is the percentage
                        if (percentInt >= Plasmoid.configuration.popupMidpercent) return Plasmoid.configuration.popupdynamicHighcolor // still going strong
                            if (percentInt >= Plasmoid.configuration.popupLowpercent) return Plasmoid.configuration.popupdynamicMidcolor
                                return Plasmoid.configuration.popupdynamicLowcolor // go charge, emergencyyyyyy
                }
                font.bold: Plasmoid.configuration.popupfontBold
                font.italic: Plasmoid.configuration.popupfontItalic
                font.underline: Plasmoid.configuration.popupfontUnderline
                font.family: Plasmoid.configuration.popupfontFamily || Kirigami.Theme.defaultFont.family
                Layout.topMargin: -5
                Layout.alignment: {
                    let alignlist = [Qt.AlignLeft, Qt.AlignHCenter, Qt.AlignRight]
                    let pos = plasmoid.configuration.popuppercentPos || 0
                    return alignlist[pos]
                }
            }

            // battery bar
            PlasmaComponents.ProgressBar {
                Layout.fillWidth: true
                from: 0
                to: 100
                value: parseInt(widgetdata.percent, 10) || 0
            }

            GridLayout {
                Layout.fillWidth: true
                Layout.topMargin: 3
                columns: 2

                PlasmaComponents.Label {
                    text: widgetdata.isCharge ? i18n("Charge time left:") : i18n("Battery time left:");
                    opacity: 0.7
                    Layout.topMargin: 3
                    visible: Plasmoid.configuration.timeLeft && !widgetdata.isFull
                    Layout.fillWidth: true
                }

                PlasmaComponents.Label {
                    text: widgetdata.timeleft
                    opacity: 0.7
                    Layout.topMargin: 3
                    visible: Plasmoid.configuration.timeLeft && !widgetdata.isFull
                }

                PlasmaComponents.Label {
                    text: i18n("Battery health:")
                    opacity: 0.7
                    Layout.fillWidth: true
                    visible: Plasmoid.configuration.healthLeft
                }

                PlasmaComponents.Label {
                    text: widgetdata.health
                    visible: Plasmoid.configuration.healthLeft
                    opacity: 0.7
                    color: {
                        let healthInt = parseInt(widgetdata.health);

                        if (healthInt >= 90) return "#64EB1C" // it's new!!!
                            if (healthInt >= 70) return "#5ED61C" // still going strong
                                if (healthInt >= 50) return "#E5F21B" // degrading
                                    return "#FF361C" // god bless your battery
                    }
                }
            }

        }

        ColumnLayout {
            // pin those shits to the bottom
            Layout.alignment: Qt.AlignBottom

            // caffeine mode
            PlasmaComponents.Switch {
                id: caffeineButton
                icon.name: sleepBlockerRoot.blockSleep ? "system-suspend-inhibited" : "system-suspend-uninhibited"
                text: i18n("Block sleep & screen lock")
                checked:sleepBlockerRoot.blockSleep
                onToggled: {
                    sleepBlockerRoot.runCafe()
                }
            }

            PlasmaComponents.Label {
                text: i18n("Apps blocking sleep / screen lock")
                opacity: !sleepBlockerRoot.hasBlocker ? 0 : (clickArea.pressed ? 0.5 : (clickArea.containsMouse ? 0.7 : 1.0))
                visible: opacity > 0
                clip: true

                MouseArea {
                    id: clickArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        popupRoot.inBlockingMenu = !popupRoot.inBlockingMenu
                    }
                }

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
            }

            // switch for power saving (tlp)
            PlasmaComponents.Switch {
                id: pwrSave
                text: i18n("Power saving mode")
                icon.name: "battery-profile-performance-symbolic"
                checked: popupRoot.pwrmgrBackend === "tlp" ? popupRoot.ispwrSave : false
                onToggled: {
                    batSaver(checked)
                }
                visible: popupRoot.pwrmgrBackend === "tlp"
                enabled: popupRoot.pwrmgrBackend === "tlp"
            }

            // slider for pwr profiles (ppd)
            ColumnLayout {
                visible: popupRoot.pwrmgrBackend === "ppd"

                Layout.fillWidth: true

                RowLayout {
                    Layout.fillWidth: true

                    Kirigami.Icon {
                        Layout.alignment: Qt.AlignRight
                        Layout.preferredWidth: 16 // make it in sync with tlp switch
                        Layout.preferredHeight: 16
                        source: "battery-profile-performance-symbolic"
                    }

                    PlasmaComponents.Label {
                        text: i18n("Power saving mode")
                    }
                }

                PlasmaComponents.Slider {
                    id: pwrpflevel
                    Layout.fillWidth: true
                    enabled: popupRoot.pwrmgrBackend === "ppd"
                    from: 0
                    to: 2
                    value: popupRoot.pwrmgrBackend === "ppd" ? popupRoot.ispwrSave : 0;
                    stepSize: 1
                    snapMode: Slider.SnapOnRelease
                    onMoved: {
                        popupRoot.batSaver(value);
                    }
                }

                RowLayout {
                    id: profIcons
                    Layout.fillWidth: true
                    // space each icon equally.. or let it space itself!

                    // powersave
                    Kirigami.Icon {
                        Layout.alignment: Qt.AlignRight
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22
                        source: "battery-profile-powersave-symbolic"
                        opacity: popupRoot.ispwrSave === 0 ? 1.0 : 0.4
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }

                    Item { Layout.fillWidth: true }

                    // performance
                    Kirigami.Icon {
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22
                        source: "battery-profile-performance-symbolic"
                        opacity: popupRoot.ispwrSave === 2 ? 1.0 : 0.4
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }

                }
            }

            // settings button
            PlasmaComponents.Button {
                PlasmaComponents.ToolTip {
                    text: i18n("Power settings...")
                }
                icon.name: "configure"
                Layout.alignment: Qt.AlignLeft
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Qt.openUrlExternally("systemsettings://kcm_powerdevilprofilesconfig")
                    }
                }
            }
        }
    }

    ColumnLayout {
        // some really interesting stuff
        id: blockingListTab
        spacing: Kirigami.Units.largeSpacing
        width: popupRoot.width
        x: popupRoot.inBlockingMenu ? (popupRoot.width - width) / 2 : popupRoot.width
        opacity: popupRoot.inBlockingMenu === true ? 1 : 0
        visible: opacity > 0
        anchors.top: headers.bottom
        height: mainLayout.height

        Behavior on opacity {
            NumberAnimation { duration: 400 }
        }

        Behavior on x {
            NumberAnimation {
                duration: 400
                easing.type: popupRoot.inBlockingMenu ? Easing.InCubic : Easing.OutCubic
            }
        }

        ColumnLayout {
            id: sleepblockerlist
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop

            PlasmaComponents.Label {
                id: applabel
                text: i18n("Apps blocking sleep / screen lock:")
                font.pixelSize: Plasmoid.configuration.nosleepTitleFontsize
                font.bold: true
            }

            // scroll for you
            PlasmaComponents.ScrollView {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.maximumHeight: sleepblockerlist.height - applabel.height
                clip: true
                contentWidth: availableWidth
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                // display the results from [SleepBlocker] file
                ListView {
                    id: blockingListView
                    implicitHeight: sleepblockerlist.height - applabel.height
                    interactive: false
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    boundsBehavior: Flickable.StopAtBounds
                    spacing: 0

                    model: sleepBlockerRoot.sharedList

                    // fancy ahh animations

                    // remove is not here because it has a bug (for me):
                    // when there's more than 2 apps displaying then the animation won't play.
                    // add is also the same, how unfortunate

                    displaced: Transition {
                        NumberAnimation { properties: "y"; duration: 250; easing.type: Easing.OutCubic }
                    }

                    delegate: PlasmaComponents.Label {
                        id: delegateRoot

                        text: model.appName
                        font.pixelSize: plasmoid.configuration.nosleepAppFontsize
                        wrapMode: Text.WordWrap
                        ListView.delayRemove: true
                        //clip: true // looks nicer without clip, i've changed my mind :)))

                        readonly property bool bye: model.removing === true // want cool sliding

                        // so... we fix the bug by animating it ourselves!
                        opacity: 0
                        height: 0
                        width: ListView.view.width
                        property int yoff: -10

                        transform: Translate {
                            y: delegateRoot.yoff // we have to translate so y of our app stays at the correct pos
                        }

                        Component.onCompleted: {
                            opacity = Qt.binding(() => bye ? 0 : 1)
                            height = Qt.binding(() => bye ? 0 : 72)
                            yoff = Qt.binding(() => bye ? -10 : 0)
                        }

                        Behavior on opacity { NumberAnimation { duration: 250 } } // fades faster than be clipped

                        Behavior on height {
                            NumberAnimation {
                                duration: 250
                                easing.type: bye ? Easing.InQuad : Easing.OutQuad
                                onRunningChanged: {
                                    if (!running && delegateRoot.bye) {
                                        sleepBlockerRoot.removeapp(model.appName);
                                    }
                                }
                            }
                        }

                        Behavior on yoff {
                            NumberAnimation {
                                duration: 250
                                easing.type: bye ? Easing.InQuad : Easing.OutQuad
                            }
                        }
                    }
                }
            }
        }

        // Push everything up top
        Item { Layout.fillHeight: true }

    }
}
