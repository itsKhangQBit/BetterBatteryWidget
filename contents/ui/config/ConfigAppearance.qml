import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami as Kirigami
import QtQuick.Dialogs // for the font dialog
import "../libs" as LibConfig

Item {
    id: root

    property alias cfg_fontSize: fontSizeSpinBox.value
    property alias cfg_fontBold: fontBoldCheckBox.checked
    property alias cfg_iconSize: iconSizeSpinBox.value
    property alias cfg_fontPad: fontPadSpinBox.value
    property alias cfg_fontposR: fontposRCheckBox.checked
    property alias cfg_padHr: padHrChkBox.checked
    property alias cfg_padMin: padMinChkBox.checked
    property alias cfg_simpleTime: simpleTimeChkBox.checked
    property alias cfg_timeLeft: timeLeftChkBox.checked

    Kirigami.FormLayout {

        LibConfig.FontFamily {
            Kirigami.FormData.label: i18n("Font family:")
            configKey: 'fontFamily'
        }

        anchors.fill: parent

        SpinBox {
            id: fontSizeSpinBox
            Kirigami.FormData.label: i18n("Font size:")
            from: 6
            to: 72
            value: root.cfg_fontSize
        }

        CheckBox {
            id: fontBoldCheckBox
            Kirigami.FormData.label: i18n("Font formatting:")
            text: i18n("Bold")
        }

        SpinBox {
            id: iconSizeSpinBox
            Kirigami.FormData.label: i18n("Icon size:")
            from: 16
            to: 128
        }

        CheckBox {
            id: fontposRCheckBox
            Kirigami.FormData.label: i18n("Percentage position:")
            text: i18n("On the right")
        }

        SpinBox {
            id: fontPadSpinBox
            Kirigami.FormData.label: i18n("Font padding:")
            from: -100
            to: 100
        }

        CheckBox {
            id: padHrChkBox
            Kirigami.FormData.label: i18n("Add leading zero before:")
            text: i18n("Hours")
        }

        CheckBox {
            id: padMinChkBox
            text: i18n("Minutes")
        }

        CheckBox {
            id: simpleTimeChkBox
            Kirigami.FormData.label: i18n("Simplified time")
        }


        CheckBox {
            id: timeLeftChkBox
            Kirigami.FormData.label: i18n("Enable time remaining")
        }
    }
}
