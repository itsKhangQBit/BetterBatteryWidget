import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.14 as Kirigami
import "."

Item {
    id: popupRoot

    property string pwrmgrBackend: none
    property var ispwrSave: false
    property var widgetdata: root

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight

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
                    popupRoot.ispwrSave = true;
                } else if (output.includes("AC")) {
                    popupRoot.ispwrSave = false;
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
        // is there TLP or power-profiles-deamon
        exec.runCMD("which tlp");
        exec.runCMD("which powerprofilesctl");
        sleepBlockerRoot.chkCafeStat()
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

    ColumnLayout {
        id: mainLayout
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            margins: Kirigami.Units.largeSpacing
        }
        spacing: Kirigami.Units.largeSpacing

        // headers
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop

            PlasmaComponents.Label {
                text: i18n("Battery percentage")
                font.bold: true
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.2
                Layout.fillWidth: true
            }
            // small icon for fun :)
            PlasmaCore.IconItem {
                source: widgetdata.icon
                width: 22
                height: 22
            }
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
            }

            PlasmaComponents.Label {
                text: widgetdata.percent + "%"
                font.pixelSize: 48
                font.weight: Font.Bold
                Layout.topMargin: -5
            }

            GridLayout {
                Layout.fillWidth: true
                Layout.topMargin: 3
                columns: 2

                PlasmaComponents.Label {
                    text: widgetdata.isCharge ? i18n("Charge time left: ") : i18n("Battery time left: ");
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
                    text: i18n("Battery health: ")
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
                text: i18n("Block sleep")
                checked:sleepBlockerRoot.blockSleep
                onToggled: {
                    sleepBlockerRoot.runCafe()
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

                    PlasmaCore.SvgItem {
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22
                        svg: svg
                        elementId: "profile-performance"
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
                    PlasmaCore.SvgItem {
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22
                        svg: svg
                        elementId: "profile-powersave"
                        opacity: popupRoot.ispwrSave === 0 ? 1.0 : 0.4
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }

                    Item { Layout.fillWidth: true }

                    // powersave
                    PlasmaCore.SvgItem {
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22
                        svg: svg
                        elementId: "profile-performance"
                        opacity: popupRoot.ispwrSave === 2 ? 1.0 : 0.4
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }
                }
            }

            // battery bar
            PlasmaComponents.ProgressBar {
                Layout.fillWidth: true
                from: 0
                to: 100
                value: widgetdata.percent
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
}
