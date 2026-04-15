import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {
    id: popupRoot
    property int percent: 0
    property bool charging: false
    property bool full: false

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
                source: "battery-charging"
                width: 22
                height: 22
            }
        }

        // battery percentage
        ColumnLayout {
            anchors.fill: parent
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
