import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami
import "."

Item {
    id: popupRoot
    /*
    property int percent: 0
    property bool charging: false
    property bool full: false
    property string icon: battery-70
    */
    property string pwrmgrBackend: none
    property bool ispwrSave: false
    /*
    property string health: "100%"
    property string timeleft: "0"
    */
    property var widgetdata: root

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight

    Layout.preferredWidth: implicitWidth + (Kirigami.Units.largeSpacing * 5)
    Layout.preferredHeight: implicitHeight + (Kirigami.Units.largeSpacing * 5)

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
        onNewData: {
            var output = data["stdout"] || "";
            // if TLP, choose pwrmgrBackend as tlp, otherwise choose power-profiles-deamon
            if (output.includes("/usr/sbin/tlp") || output.includes("/usr/bin/tlp")) {
                pwrmgrBackend = "tlp";
            } else if (output.includes("/usr/bin/powerprofilesctl")) {
                pwrmgrBackend = "ppd";
            }
            disconnectSource(sourceName);
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
            exec.runCMD(cmd);
        }
        else if (pwrmgrBackend === "ppd") {
            let profile = state ? "power-saver" : "balanced";
            exec.runCMD("powerprofilesctl set " + profile);
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
            Kirigami.Icon {
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
                    text: i18n("Battery health: ")
                    opacity: 0.7
                    Layout.fillWidth: true
                }
                PlasmaComponents.Label {
                    text: widgetdata.health
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
            // switch for power saving
            PlasmaComponents.Switch {
                id: pwrSave
                text: i18n("Power saving mode")
                icon.name: "battery-profile-performance-symbolic"
                checked: popupRoot.ispwrSave
                onToggled: {
                    batSaver(checked)
                }
            }

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
