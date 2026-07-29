import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kquickcontrols as KQuickControls
import QtQuick.Dialogs // for the color dialog

ScrollView {
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
    property alias cfg_panelfontFamily: panelfontDiag.selectedFont.family
    property alias cfg_panelcustomcolor: panelcustomcolor.checked
    property alias cfg_paneliconRotate: paneliconRotate.checked
    property alias cfg_chargeIndicatorCustomColor: chargeIndicatorCustomColor.checked
    property alias cfg_chargeIndicatorColor: chargeIndicatorColorPicker.color
    property alias cfg_paneldynamicHighcolor: paneldynamicHighcolor.color
    property alias cfg_paneldynamicMidcolor: paneldynamicMidcolor.color
    property alias cfg_paneldynamicLowcolor: paneldynamicLowcolor.color
    property alias cfg_panelMidpercent: panelMidpercent.value
    property alias cfg_panelLowpercent: panelLowpercent.value
    property alias cfg_panelshowPercent: panelshowPercent.checked
    property alias cfg_panelshowIcon: panelshowIcon.checked

    property int cfg_panelfontSizeDefault
    property bool cfg_panelfontBoldDefault
    property string cfg_panelpercentColorDefault
    property bool cfg_panelfontItalicDefault
    property bool cfg_panelfontUnderlineDefault
    property int cfg_paneliconSizeDefault
    property int cfg_panelfontPadDefault
    property string cfg_panelfontFamilyDefault
    property bool cfg_panelfontPosRDefault
    property bool cfg_panelcustomcolorDefault
    property bool cfg_paneliconRotateDefault
    property bool cfg_chargeIndicatorCustomColorDefault
    property string cfg_chargeIndicatorColorDefault
    property string cfg_paneldynamicLowcolorDefault
    property string cfg_paneldynamicMidcolorDefault
    property string cfg_paneldynamicHighcolorDefault
    property int cfg_panelMidpercentDefault
    property int cfg_panelLowpercentDefault
    property bool cfg_panelshowPercentDefault
    property bool cfg_panelshowIconDefault

    Kirigami.FormLayout {
        id: formLayout
        anchors.fill: parent
        property string title: "" // shut up QML
        anchors.margins: Kirigami.Units.smallSpacing

        // ---- Percentage text ----

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Percentage text")
        }

        CheckBox {
            id: panelshowPercent
            Kirigami.FormData.label: i18n("Show percentage:")
            text: i18n("Show")
        }

        FontDialog {
            id: panelfontDiag
            onSelectedFontChanged: {
                plasmoid.configuration.panelfontFamily = selectedFont.family
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Font family:")
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
            Kirigami.FormData.label: i18n("Font size:")
            from: 6
            to: 72
            value: root.cfg_panelfontSize
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Font style:")
            CheckBox {
                id: panelfontBold
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
        }

        CheckBox {
            id: panelfontPosR
            Kirigami.FormData.label: i18n("Position:")
            text: i18n("Align to the right")
        }

        SpinBox {
            id: panelfontPad
            Kirigami.FormData.label: i18n("Padding:")
            from: -100
            to: 100
        }

        // ---- Percentage color ----

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Percentage color")
        }

        CheckBox {
            id: panelcustomcolor
            Kirigami.FormData.label: i18n("Dynamic color:")
            text: i18n("Change color based on battery level")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Fixed color:")
            visible: opacity > 0
            opacity: plasmoid.configuration.panelcustomcolor ? 0 : 1
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            KQuickControls.ColorButton {
                id: panelcolorPicker
                color: plasmoid.configuration.panelpercentColor

                // save my color pls
                onColorChanged: cfg_panelpercentColor = color.toString()
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignLeft
            visible: opacity > 0
            opacity: plasmoid.configuration.panelcustomcolor ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Colors:")
                PlasmaComponents.Label {
                    text: i18n("High")
                }
                KQuickControls.ColorButton {
                    id: paneldynamicHighcolor
                    color: plasmoid.configuration.paneldynamicHighcolor
                    onColorChanged: cfg_paneldynamicHighcolor = color.toString()
                }

                PlasmaComponents.Label {
                    text: i18n("Mid")
                }
                KQuickControls.ColorButton {
                    id: paneldynamicMidcolor
                    color: plasmoid.configuration.paneldynamicMidcolor
                    onColorChanged: cfg_paneldynamicMidcolor = color.toString()
                }

                PlasmaComponents.Label {
                    text: i18n("Low")
                }
                KQuickControls.ColorButton {
                    id: paneldynamicLowcolor
                    color: plasmoid.configuration.paneldynamicLowcolor
                    onColorChanged: cfg_paneldynamicLowcolor = color.toString()
                }
            }

            RowLayout {
                PlasmaComponents.Label {
                    text: i18n("Switch to Mid color below:")
                }
                SpinBox {
                    id: panelMidpercent
                    from: 0
                    to: 100
                    value: root.cfg_panelMidpercent
                }
                PlasmaComponents.Label {
                    text: i18n("%")
                }
            }

            RowLayout {
                PlasmaComponents.Label {
                    text: i18n("Switch to Low color below:")
                }
                SpinBox {
                    id: panelLowpercent
                    from: 0
                    to: 100
                    value: root.cfg_panelLowpercent
                }
                PlasmaComponents.Label {
                    text: i18n("%")
                }
            }
        }

        // ---- Icon ----

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Icon")
        }

        CheckBox {
            id: panelshowIcon
            Kirigami.FormData.label: i18n("Show icon:")
            text: i18n("Show")
        }

        SpinBox {
            id: paneliconSize
            Kirigami.FormData.label: i18n("Icon size:")
            from: 16
            to: 128
        }

        CheckBox {
            id: paneliconRotate
            Kirigami.FormData.label: i18n("Orientation:")
            text: i18n("Vertical battery icon")
        }

        // ---- Charging indicator ----

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Charging indicator")
        }

        CheckBox {
            id: chargeIndicatorCustomColor
            Kirigami.FormData.label: i18n("Custom color:")
            text: i18n("Use a custom charging indicator color")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Color:")
            visible: opacity > 0
            opacity: plasmoid.configuration.chargeIndicatorCustomColor ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            KQuickControls.ColorButton {
                id: chargeIndicatorColorPicker
                color: plasmoid.configuration.chargeIndicatorColor
                onColorChanged: cfg_chargeIndicatorColor = color.toString()
            }

            PlasmaComponents.Label {
                text: i18n("(also used in the popup)")
                opacity: 0.7
            }
        }
    }
}
