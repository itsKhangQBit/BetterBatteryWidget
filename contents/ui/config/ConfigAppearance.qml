import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
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
    }
}
