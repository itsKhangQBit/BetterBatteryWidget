import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ScrollView {
    anchors.fill: root
    Layout.fillHeight: true
    Layout.fillWidth: true
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical.policy: ScrollBar.AsNeeded
    clip: true
    id: root

    property alias cfg_padMin: padMin.checked
    property alias cfg_padHr: padHr.checked
    property alias cfg_simpleTime: simpleTime.checked
    property alias cfg_timeLeft: timeLeft.checked
    property alias cfg_healthLeft: healthLeft.checked
    property alias cfg_showPeripherals: showPeripherals.checked

    // pinned is toggled from the popup's pin button, not exposed here,
    // but still needs to be declared so the KCM doesn't warn about it
    property bool cfg_pinned
    property bool cfg_pinnedDefault

    property bool cfg_padMinDefault
    property bool cfg_padHrDefault
    property bool cfg_simpleTimeDefault
    property bool cfg_timeLeftDefault
    property bool cfg_healthLeftDefault
    property bool cfg_showPeripheralsDefault

    Kirigami.FormLayout {
        id: formLayout
        anchors.fill: parent
        property string title: "" // shut up QML
        anchors.margins: Kirigami.Units.smallSpacing

        // ---- Time display ----

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Time display")
        }

        CheckBox {
            id: simpleTime
            Kirigami.FormData.label: i18n("Format:")
            text: i18n("Simplified time (omit leading zero hour)")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Add leading zero before:")
            CheckBox {
                id: padHr
                text: i18n("Hours")
            }
            CheckBox {
                id: padMin
                text: i18n("Minutes")
            }
        }

        // ---- Popup info ----

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Popup info")
        }

        CheckBox {
            id: timeLeft
            Kirigami.FormData.label: i18n("Time remaining:")
            text: i18n("Show estimated time remaining")
        }

        CheckBox {
            id: healthLeft
            Kirigami.FormData.label: i18n("Battery health:")
            text: i18n("Show battery health")
        }

        // ---- Peripheral batteries ----

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Peripheral batteries")
        }

        CheckBox {
            id: showPeripherals
            Kirigami.FormData.label: i18n("Peripherals:")
            text: i18n("Show battery level of connected Bluetooth devices (mouse, headphones, etc.)")
        }
    }
}
