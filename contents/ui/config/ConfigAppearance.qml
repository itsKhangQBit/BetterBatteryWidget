import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kquickcontrols as KQuickControls
import QtQuick.Dialogs // for the font dialog

ScrollView {
    anchors.fill: root
    Layout.fillHeight: true
    Layout.fillWidth: true
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical.policy: ScrollBar.AsNeeded
    clip: true
    id: root

    property alias cfg_panelfontSize: panelfontSize.value
    property alias cfg_panelfontBold: panelfontBold.checked
    property alias cfg_panelpercentColor: panelcolorPicker.color
    property alias cfg_panelfontItalic: panelfontItalic.checked
    property alias cfg_panelfontUnderline: panelfontUnderline.checked
    property alias cfg_paneliconSize: paneliconSize.value
    property alias cfg_panelfontPad: panelfontPad.value
    property alias cfg_panelfontPosR: panelfontPosR.checked
    property var cfg_panelfontFamily

    property alias cfg_popupfontSize: popupfontSize.value
    property alias cfg_popupfontBold: popupfontBold.checked
    property alias cfg_popuppercentColor: popupcolorPicker.color
    property alias cfg_popupfontItalic: popupfontItalic.checked
    property alias cfg_popupfontUnderline: popupfontUnderline.checked
    property alias cfg_popupfontPos: popupposSlider.value
    property var cfg_popupfontFamily

    // this is just for QML engine to not throw any warnings
    property bool cfg_padMin
    property bool cfg_padHr
    property bool cfg_simpleTime
    property bool cfg_timeLeft
    property bool cfg_healthLeft
    property bool cfg_pinned

    // OMG shut up QML!!!
    property bool cfg_padMinDefault
    property bool cfg_padHrDefault
    property bool cfg_simpleTimeDefault
    property bool cfg_timeLeftDefault
    property bool cfg_healthLeftDefault
    property bool cfg_pinnedDefault

    property int cfg_panelfontSizeDefault
    property bool cfg_panelfontBoldDefault
    property string cfg_panelpercentColorDefault
    property bool cfg_panelfontItalicDefault
    property bool cfg_panelfontUnderlineDefault
    property int cfg_paneliconSizeDefault
    property int cfg_panelfontPadDefault
    property string cfg_panelfontFamilyDefault
    property bool cfg_panelfontPosRDefault

    property int cfg_popupfontSizeDefault
    property bool cfg_popupfontBoldDefault
    property string cfg_popuppercentColorDefault
    property bool cfg_popupfontItalicDefault
    property bool cfg_popupfontUnderlineDefault
    property string cfg_popupfontFamilyDefault
    property int cfg_popuppercentPosDefault


    Kirigami.FormLayout {

        PlasmaComponents.Label {
            text: i18n("Panel appearance")
            font.pixelSize: 18
        }

        FontDialog {
            id: panelfontDiag
            onSelectedFontChanged: {
                plasmoid.configuration.panelfontFamily = selectedFont.family
                panelfontDropdown.displayText = selectedFont.family
            }
        }

        RowLayout {
            PlasmaComponents.Label {
                text: i18n("Panel percentage font family:")
            }

            PlasmaComponents.Button {
                id: panelfontDropdown
                Layout.fillWidth: true
                text: plasmoid.configuration.panelfontFamily || i18n("Default")
                onClicked: {
                    panelfontDiag.selectedFont.family = plasmoid.configuration.panelfontFamily
                    panelfontDiag.open()
                }
            }
        }

        SpinBox {
            id: panelfontSize
            Kirigami.FormData.label: i18n("Panel font size:")
            from: 6
            to: 72
            value: root.cfg_panelfontSize
        }

        RowLayout {
            Label {
                text: i18n("Percentage color on panel:")
            }

            KQuickControls.ColorButton {
                id: panelcolorPicker
                color: cfg_panelpercentColor

                // save my color pls
                onColorChanged: cfg_panelpercentColor = color.toString()
            }
        }

        CheckBox {
            id: panelfontBold
            Kirigami.FormData.label: i18n("Panel font formatting:")
            text: i18n("Bold")
        }

        CheckBox {
            id: panelfontItalic
            text: i18n("Italic")
        }

        CheckBox {
            id: panelfontUnderline
            text: i18n("Underline")
        }

        SpinBox {
            id: paneliconSize
            Kirigami.FormData.label: i18n("Panel icon size:")
            from: 16
            to: 128
        }

        CheckBox {
            id: panelfontPosR
            Kirigami.FormData.label: i18n("Panel percentage position:")
            text: i18n("Right")
        }

        SpinBox {
            id: panelfontPad
            Kirigami.FormData.label: i18n("Font padding:")
            from: -100
            to: 100
        }

        PlasmaComponents.Label {
            text: i18n("Popup appearance")
            font.pixelSize: 18
        }

        FontDialog {
            id: popupfontDiag
            onSelectedFontChanged: {
                plasmoid.configuration.popupfontFamily = selectedFont.family
                popupfontDropdown.displayText = selectedFont.family
            }
        }

        RowLayout {
            PlasmaComponents.Label {
                text: i18n("Popup percentage font family:")
            }

            PlasmaComponents.Button {
                id: popupfontDropdown
                Layout.fillWidth: true
                text: plasmoid.configuration.popupfontFamily || i18n("Default")
                onClicked: {
                    popupfontDiag.selectedFont.family = plasmoid.configuration.popupfontFamily
                    popupfontDiag.open()
                }
            }
        }

        SpinBox {
            id: popupfontSize
            Kirigami.FormData.label: i18n("Popup font size:")
            from: 6
            to: 72
            value: root.cfg_popupfontSize
        }

        RowLayout {
            Label {
                text: i18n("Percentage color on popup:")
            }

            KQuickControls.ColorButton {
                id: popupcolorPicker
                color: cfg_popuppercentColor

                // save my color pls
                onColorChanged: cfg_popuppercentColor = color.toString()
            }
        }

        CheckBox {
            id: popupfontBold
            Kirigami.FormData.label: i18n("Popup font formatting:")
            text: i18n("Bold")
        }

        CheckBox {
            id: popupfontItalic
            text: i18n("Italic")
        }

        CheckBox {
            id: popupfontUnderline
            text: i18n("Underline")
        }

        ColumnLayout {
            Layout.fillWidth: true

            PlasmaComponents.Label {
                text: i18n("Position:")
            }


            PlasmaComponents.Slider { // lol, a freaking slider just for the position
                id: popupposSlider
                Layout.fillWidth: true
                from: 0
                to: 2
                value: plasmoid.configuration.popuppercentPos
                stepSize: 1
                onMoved: {
                    plasmoid.configuration.popuppercentPos = value;
                }
            }

            RowLayout {
                id: popupposLabel
                Layout.fillWidth: true
                // space each icon equally.. or let it space itself!

                PlasmaComponents.Label {
                    Layout.alignment: Qt.AlignLeft
                    text: i18n("Left")
                }

                Item { Layout.fillWidth: true }

                PlasmaComponents.Label {
                    Layout.alignment: Qt.AlignCenter
                    text: i18n("Center")
                }

                Item { Layout.fillWidth: true }

                PlasmaComponents.Label {
                    Layout.alignment: Qt.AlignRight
                    text: i18n("Right")
                }
            }
        }
    }
}
