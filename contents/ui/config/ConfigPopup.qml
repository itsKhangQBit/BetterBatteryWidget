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

    property alias cfg_popupfontSize: popupfontSize.value
    property alias cfg_popupfontBold: popupfontBold.checked
    property alias cfg_popuppercentColor: popupcolorPicker.color
    property alias cfg_popupfontItalic: popupfontItalic.checked
    property alias cfg_popupfontUnderline: popupfontUnderline.checked
    property alias cfg_popuppercentPos: popupposSlider.value
    property alias cfg_popupfontFamily: popupfontDiag.selectedFont.family
    property alias cfg_popupcustomcolor: popupcustomcolor.checked
    property alias cfg_popupdynamicHighcolor: popupdynamicHighcolor.color
    property alias cfg_popupdynamicMidcolor: popupdynamicMidcolor.color
    property alias cfg_popupdynamicLowcolor: popupdynamicLowcolor.color
    property alias cfg_popupMidpercent: popupMidpercent.value
    property alias cfg_popupLowpercent: popupLowpercent.value

    property alias cfg_nosleepTitleFontsize: nosleepTitleFontsize.value //goddamn variable too long :(((
    property alias cfg_nosleepAppFontsize: nosleepAppFontsize.value

    // just pasting so KCM doesn't warn
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

    property int cfg_popupfontSizeDefault
    property bool cfg_popupfontBoldDefault
    property string cfg_popuppercentColorDefault
    property bool cfg_popupfontItalicDefault
    property bool cfg_popupfontUnderlineDefault
    property string cfg_popupfontFamilyDefault
    property int cfg_popuppercentPosDefault
    property bool cfg_popupcustomcolorDefault
    property string cfg_popupdynamicLowcolorDefault
    property string cfg_popupdynamicMidcolorDefault
    property string cfg_popupdynamicHighcolorDefault
    property int cfg_popupMidpercentDefault
    property int cfg_popupLowpercentDefault

    property int cfg_nosleepTitleFontsizeDefault
    property int cfg_nosleepAppFontsizeDefault

    property int cfg_panelfontSize
    property bool cfg_panelfontBold
    property string cfg_panelpercentColor
    property bool cfg_panelfontItalic
    property bool cfg_panelfontUnderline
    property int cfg_paneliconSize
    property int cfg_panelfontPad
    property string cfg_panelfontFamily
    property bool cfg_panelfontPosR
    property bool cfg_panelcustomcolor
    property bool cfg_paneliconRotate
    property bool cfg_chargeIndicatorCustomColor
    property string cfg_chargeIndicatorColor
    property string cfg_paneldynamicLowcolor
    property string cfg_paneldynamicMidcolor
    property string cfg_paneldynamicHighcolor
    property int cfg_panelMidpercent
    property int cfg_panelLowpercent
    property bool cfg_panelshowPercent
    property bool cfg_panelshowIcon
    property string title: "" // shut up QML

    property bool cfg_padMinDefault
    property bool cfg_padHrDefault
    property bool cfg_simpleTimeDefault
    property bool cfg_timeLeftDefault
    property bool cfg_healthLeftDefault

    property bool cfg_padMin
    property bool cfg_padHr
    property bool cfg_simpleTime
    property bool cfg_timeLeft
    property bool cfg_healthLeft

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

        FontDialog {
            id: popupfontDiag
            onSelectedFontChanged: {
                plasmoid.configuration.popupfontFamily = selectedFont.family
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Font family:")
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
            Kirigami.FormData.label: i18n("Font size:")
            from: 6
            to: 72
            value: root.cfg_popupfontSize
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Font style:")
            CheckBox {
                id: popupfontBold
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
        }

        ColumnLayout {
            Kirigami.FormData.label: i18n("Position:")
            Layout.fillWidth: true

            PlasmaComponents.Slider { // lol, a freaking slider just for the position
                id: popupposSlider
                Layout.fillWidth: true
                from: 0
                to: 2
                value: plasmoid.configuration.popuppercentPos
                stepSize: 1
                snapMode: Slider.SnapOnRelease
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

        // ---- Percentage color ----

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Percentage color")
        }

        CheckBox {
            id: popupcustomcolor
            Kirigami.FormData.label: i18n("Dynamic color:")
            text: i18n("Change color based on battery level")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Fixed color:")
            visible: opacity > 0
            opacity: plasmoid.configuration.popupcustomcolor ? 0 : 1
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            KQuickControls.ColorButton {
                id: popupcolorPicker
                color: plasmoid.configuration.popuppercentColor
                onColorChanged: cfg_popuppercentColor = color.toString()
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignLeft
            visible: opacity > 0
            opacity: plasmoid.configuration.popupcustomcolor ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Colors:")
                PlasmaComponents.Label {
                    text: i18n("High")
                }
                KQuickControls.ColorButton {
                    id: popupdynamicHighcolor
                    color: plasmoid.configuration.popupdynamicHighcolor
                    onColorChanged: cfg_popupdynamicHighcolor = color.toString()
                }

                PlasmaComponents.Label {
                    text: i18n("Mid")
                }
                KQuickControls.ColorButton {
                    id: popupdynamicMidcolor
                    color: plasmoid.configuration.popupdynamicMidcolor
                    onColorChanged: cfg_popupdynamicMidcolor = color.toString()
                }

                PlasmaComponents.Label {
                    text: i18n("Low")
                }
                KQuickControls.ColorButton {
                    id: popupdynamicLowcolor
                    color: plasmoid.configuration.popupdynamicLowcolor
                    onColorChanged: cfg_popupdynamicLowcolor = color.toString()
                }
            }

            RowLayout {
                PlasmaComponents.Label {
                    text: i18n("Switch to Mid color below:")
                }
                SpinBox {
                    id: popupMidpercent
                    from: 0
                    to: 100
                    value: root.cfg_popupMidpercent
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
                    id: popupLowpercent
                    from: 0
                    to: 100
                    value: root.cfg_popupLowpercent
                }
                PlasmaComponents.Label {
                    text: i18n("%")
                }
            }
        }

        // ---- Sleep blocker tab ----

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Sleep blocker tab")
        }

        SpinBox {
            id: nosleepTitleFontsize
            Kirigami.FormData.label: i18n("Title font size:")
            from: 1
            to: 100
            value: root.cfg_nosleepTitleFontsize
        }

        SpinBox {
            id: nosleepAppFontsize
            Kirigami.FormData.label: i18n("App list font size:")
            from: 1
            to: 100
            value: root.cfg_nosleepAppFontsize
        }
    }
}
