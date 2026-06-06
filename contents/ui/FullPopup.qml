import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.14 as Kirigami
import "."

Item {
    id: popupRoot

    property bool inBlockingMenu: false
    property string pwrmgrBackend: "none"
    property int ispwrSave: 0 // we can also use int for bool: false is 0, true is 1 (this will be used for the TLP switch)
    property var widgetdata: root
    property alias exec: exec

    implicitWidth: Math.max(headers.implicitWidth, mainLayout.implicitWidth)
    implicitHeight: mainLayout.implicitHeight + headers.implicitHeight
    anchors.margins: Kirigami.Units.largeSpacing
    clip: true

    Layout.preferredWidth: popupRoot.implicitWidth + (Kirigami.Units.largeSpacing * 5)
    Layout.preferredHeight: popupRoot.implicitHeight + (Kirigami.Units.largeSpacing * 5)
    Layout.minimumWidth: popupRoot.implicitWidth + (Kirigami.Units.largeSpacing * 5)
    Layout.minimumHeight: popupRoot.implicitHeight + (Kirigami.Units.largeSpacing * 5)

    SleepBlocker {
        id: sleepBlockerRoot
    }

    PlasmaCore.DataSource {
        id: pwrSaveSwitch
        engine: "powermanagement"
        connectedSources: ["Battery"]
        onDataChanged: {
            popupRoot.ispwrSave = data["Battery"]["Power Save Mode"] || false;
        }
    }

    PlasmaCore.DataSource {
        id: exec
        engine: "executable"
        connectedSources: []
        interval: 5000
        onNewData: {
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

        function runCMD(cmd) {
            connectSource(cmd);
        }
    }

    PlasmaCore.DataSource {
        id: execdisconn
        engine: "executable"
        connectedSources: []
        interval: 2000
        onNewData: {
            disconnectSource(sourceName);
        }

        function runCMD(cmd) {
            connectSource(cmd);
        }
    }

    PlasmaCore.DataSource {
        id: batStatus
        engine: "executable"
        connectedSources: []
        interval: 2000
        onNewData: {
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

    Component.onCompleted: {
        // is there TLP or power-profiles-daemon
        popupRoot.exec.runCMD("which tlp");
        popupRoot.exec.runCMD("which powerprofilesctl");
        sleepBlockerRoot.chkCafeStat();
        sleepBlockerRoot.getBlockerList();
        widgetdata.exec.runCMD("cat /sys/class/power_supply/BAT*/charge_full /sys/class/power_supply/BAT*/charge_full_design");
    }

    Component.onDestruction: {
        popupRoot.exec.connectedSources = [];
        batStatus.connectedSources = [];
        sleepBlockerRoot.exec.connectedSources = [];
        sleepBlockerRoot.sleepchk.connectedSources = [];
        widgetdata.exec.connectedSources = [];
    }

    function batSaver(state) {
        if (pwrmgrBackend === "tlp") {
            let cmd = state ? "pkexec tlp bat" : "pkexec tlp ac";
            execdisconn.runCMD(cmd);
        }
        else if (pwrmgrBackend === "ppd") {
            let profile = ["power-saver", "balanced", "performance"]
            execdisconn.runCMD("powerprofilesctl set " + profile[state]);
        }
        // if no pwrmgrBackend, just log cause we can't set anything
        else {
            console.log("Oops, no power manager!");
        }
    }

    //headers
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
            Kirigami.Icon {
                source: widgetdata.icon
                width: 22
                height: 22
            }

            PlasmaComponents.ToolButton {
                icon.name: plasmoid.configuration.pinned ? "window-unpin" : "window-pin"
                checkable: true
                checked: plasmoid.configuration.pinned
                visible: plasmoid.location !== 0
                onToggled: {
                    plasmoid.configuration.pinned = !plasmoid.configuration.pinned
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
                Layout.alignment: {
                    let alignlist = [Qt.AlignLeft, Qt.AlignHCenter, Qt.AlignRight]
                    let pos = plasmoid.configuration.popuppercentPos || 0
                    return alignlist[pos]
                }
                text: {
                    if (widgetdata.isFull) {
                        return i18n("Fully charged");
                    }
                    return widgetdata.isCharge ? i18n("Charging") : i18n("Discharging")
                }
                opacity: 0.7
            }

            PlasmaComponents.Label {
                text: widgetdata.percent + "%"
                font.pixelSize: plasmoid.configuration.popupfontSize
                opacity: {
                    let percentInt = parseInt(widgetdata.percent, 10)
                    if (isNaN(percentInt)) return 0.8;
                    return 1
                }
                color: {
                    if (!plasmoid.configuration.popupcustomcolor) return plasmoid.configuration.popuppercentColor || Kirigami.Theme.textColor;
                    let percentInt = parseInt(widgetdata.percent, 10)
                    if (isNaN(percentInt)) return "#FFFFFF" // what the hell is the percentage
                        if (percentInt >= plasmoid.configuration.popupMidpercent) return plasmoid.configuration.popupdynamicHighcolor // still going strong
                            if (percentInt >= plasmoid.configuration.popupLowpercent) return plasmoid.configuration.popupdynamicMidcolor
                                return plasmoid.configuration.popupdynamicLowcolor // go charge, emergencyyyyyy
                }
                font.bold: plasmoid.configuration.popupfontBold
                font.italic: plasmoid.configuration.popupfontItalic
                font.underline: plasmoid.configuration.popupfontUnderline
                font.family: plasmoid.configuration.popupfontFamily || Kirigami.Theme.defaultFont.family
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
                    visible: plasmoid.configuration.timeLeft && !widgetdata.isFull
                    Layout.fillWidth: true
                }

                PlasmaComponents.Label {
                    text: widgetdata.timeleft
                    opacity: 0.7
                    Layout.topMargin: 3
                    visible: plasmoid.configuration.timeLeft && !widgetdata.isFull
                }

                PlasmaComponents.Label {
                    text: i18n("Battery health:")
                    opacity: 0.7
                    Layout.fillWidth: true
                    visible: plasmoid.configuration.healthLeft
                }

                PlasmaComponents.Label {
                    text: widgetdata.health
                    visible: plasmoid.configuration.healthLeft
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
                color: "white"
                opacity: !sleepBlockerRoot.hasBlocker ? 0 :  (clickArea.pressed ? 0.5 : (clickArea.containsMouse ? 0.7 : 1.0))
                visible: opacity > 0

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
                icon.name: "profile-performance"
                checked: (typeof ispwrSave === "boolean") ? popupRoot.ispwrSave : false;
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
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22
                        source: "battery-profile-performance"
                    }

                    PlasmaComponents.Label {
                        text: i18n("Power saving mode")
                    }
                }

                PlasmaComponents.Slider {
                    Layout.fillWidth: true
                    enabled: popupRoot.pwrmgrBackend === "ppd"
                    from: 0
                    to: 2
                    value: (typeof ispwrSave === "number") ? popupRoot.ispwrSave : 0;
                    stepSize: 1
                    onMoved: {
                        popupRoot.batSaver(value);
                    }
                }

                RowLayout {
                    id: profIcons
                    Layout.fillWidth: true
                    PlasmaCore.Svg {
                        id: svg
                        imagePath: "icons/battery"
                    }
                    // space each icon equally.. or let it space itself!

                    // code is taken straight and fresh :)) from KDE Plasma 5.27's battery applet
                    // performance
                    Kirigami.Icon {
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22
                        source: "battery-profile-powersave"
                        opacity: popupRoot.ispwrSave === 0 ? 1.0 : 0.4
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }

                    Item { Layout.fillWidth: true }

                    // powersave
                    Kirigami.Icon {
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22
                        source: "battery-profile-performance"
                        opacity: popupRoot.ispwrSave === 2 ? 1.0 : 0.4
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }
                }
            }

            // settings button
            PlasmaComponents.Button {
                text: i18n("Power settings...")
                icon.name: "configure"
                Layout.fillWidth: true
                onClicked: {
                    Qt.openUrlExternally("systemsettings://kcm_powerdevilprofilesconfig")
                }
            }
        }
    }

    ColumnLayout {
        // some really interesting stuff
        id: blockingListTab
        spacing: Kirigami.Units.largeSpacing
        height: mainLayout.height
        width: popupRoot.width
        anchors.top: headers.bottom
        x: popupRoot.inBlockingMenu ? (popupRoot.width - width) / 2 : popupRoot.width
        opacity: popupRoot.inBlockingMenu === true ? 1 : 0
        visible: opacity > 0

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

            PlasmaComponents.Label {
                id: applabel
                text: i18n("Apps blocking sleep / screen lock:")
                font.pixelSize: plasmoid.configuration.nosleepTitleFontsize
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
                        property real yoff: -10

                        transform: Translate {
                            y: delegateRoot.yoff // we have to translate so y of our app stays at the correct pos
                        }

                        Component.onCompleted: {
                            opacity = Qt.binding(() => bye ? 0 : 1)
                            height = Qt.binding(() => bye ? 0 : implicitHeight)
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
