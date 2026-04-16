import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami

Item {
    id: popupRoot
    property int percent: 0
    property bool charging: false
    property bool full: false
    property string icon: battery-70
    property string pwrmgrBackend: none
    property bool ispwrSave: false

    Plasma5Support.DataSource {
        id: pwrSaveSwitch
        engine: "powermanagement"
        connectedSources: ["Battery"]
        onDataChanged: {
            popupRoot.ispwrSave = data["Battery"]["Power Save Mode"] || false;
            console.log(ispwrSave)
        }
    }

    Plasma5Support.DataSource {
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
    }

    function batSaver(state) {
        if (pwrmgrBackend === "tlp") {
            console.log(state)
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

    // popup size
    width: Kirigami.Units.gridUnit * 16
    height: mainLayout.implicitHeight + Kirigami.Units.largeSpacing * 2

    ColumnLayout {
        id: mainLayout
        anchors {
            fill: parent
            margins: Kirigami.Units.largeSpacing
        }
        spacing: Kirigami.Units.largeSpacing

        // headers
        RowLayout {
            Layout.fillWidth: true
            PlasmaComponents.Label {
                text: i18n("Battery percentage")
                font.bold: true
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.2
                Layout.fillWidth: true
            }
            // small icon for fun :)
            Kirigami.Icon {
                source: popupRoot.icon
                width: 22
                height: 22
            }
        }

        // battery percentage
        ColumnLayout {
            PlasmaComponents.Label {
                id: labelpercent
                text: popupRoot.percent + "%"
                font.pixelSize: 48
                font.weight: Font.Bold
            }

            PlasmaComponents.Label {
                text: {
                    if (popupRoot.full === true) {
                        return i18n("Fully charged");
                    }
                    return popupRoot.charging ? i18n("Charging") : i18n("Discharging")
                }
                opacity: 0.7
                anchors.bottom: labelpercent.top
            }

            // switch for power saving
            PlasmaComponents.Switch {
                id: pwrSave
                text: i18n("Power saving mode")
                checked: popupRoot.ispwrSave
                onToggled: {
                    batSaver(checked)
                }
            }
        }

        // battery bar
        ColumnLayout {
            PlasmaComponents.ProgressBar {
                Layout.fillWidth: true
                from: 0
                to: 100
                value: popupRoot.percent
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
