import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kquickcontrols as KQuickControls
import QtQuick.Dialogs // for the font dialog

ScrollView {
    Layout.fillHeight: true
    Layout.fillWidth: true
    ScrollBar.horizontal.policy: ScrollBar.AsNeeded
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
    property alias cfg_paneldynamicHighcolor: paneldynamicHighcolor.color
    property alias cfg_paneldynamicMidcolor: paneldynamicMidcolor.color
    property alias cfg_paneldynamicLowcolor: paneldynamicLowcolor.color
    property alias cfg_panelMidpercent: panelMidpercent.value
    property alias cfg_panelLowpercent: panelLowpercent.value

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

    // this is just for QML engine to not throw any warnings
    property bool cfg_padMin
    property bool cfg_padHr
    property bool cfg_simpleTime
    property bool cfg_timeLeft
    property bool cfg_healthLeft
    property bool cfg_pinned

    // YOU SHADAP! - Bung Moktar at Malaysia Parliament (RIP)
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
    property bool cfg_panelcustomcolorDefault
    property bool cfg_paneliconRotateDefault
    property string cfg_paneldynamicLowcolorDefault
    property string cfg_paneldynamicMidcolorDefault
    property string cfg_paneldynamicHighcolorDefault
    property int cfg_panelMidpercentDefault
    property int cfg_panelLowpercentDefault

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


    Kirigami.FormLayout {
        id: formLayout
        anchors.fill: parent
        property string title: "" // shut up QML
        anchors.margins: Kirigami.Units.smallSpacing

        PlasmaComponents.Label {
            anchors.margins: Kirigami.Units.smallSpacing
            text: i18n("Panel appearance")
            font.pixelSize: 18
            font.bold: true
        }

        FontDialog {
            id: panelfontDiag
            onSelectedFontChanged: {
                plasmoid.configuration.panelfontFamily = selectedFont.family
            }
        }

        RowLayout {
            PlasmaComponents.Label {
                text: i18n("Percentage font family:")
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
            Kirigami.FormData.label: i18n("Percentage font size:")
            from: 6
            to: 72
            value: root.cfg_panelfontSize
        }


        CheckBox {
            id: panelfontBold
            Kirigami.FormData.label: i18n("Percentage font formatting:")
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

        CheckBox {
            id: panelfontPosR
            Kirigami.FormData.label: i18n("Percentage position:")
            text: i18n("Right")
        }

        SpinBox {
            id: panelfontPad
            Kirigami.FormData.label: i18n("Percentage font padding:")
            from: -100
            to: 100
        }

        RowLayout {
            visible: opacity > 0
            opacity: plasmoid.configuration.panelcustomcolor ? 0 : 1
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            Label {
                text: i18n("Percentage fixed color:")
            }

            KQuickControls.ColorButton {
                id: panelcolorPicker
                color: plasmoid.configuration.panelpercentColor

                // save my color pls
                onColorChanged: cfg_panelpercentColor = color.toString()
            }
        }

        CheckBox {
            id: panelcustomcolor
            text: i18n("Enable dynamic percentage color")
        }

        ColumnLayout {
            visible: opacity > 0
            opacity: plasmoid.configuration.panelcustomcolor ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            PlasmaComponents.Label {
                text: i18n("Custom dynamic color:")
            }

            RowLayout {

                PlasmaComponents.Label {
                    text: i18n("High percentage")
                }

                KQuickControls.ColorButton {
                    id: paneldynamicHighcolor
                    color: plasmoid.configuration.paneldynamicHighcolor

                    // save my color pls
                    onColorChanged: cfg_paneldynamicHighcolor = color.toString()
                }
            }

            RowLayout {

                PlasmaComponents.Label {
                    text: i18n("Midrange percentage")
                }

                KQuickControls.ColorButton {
                    id: paneldynamicMidcolor
                    color: plasmoid.configuration.paneldynamicMidcolor

                    // save my color pls
                    onColorChanged: cfg_paneldynamicMidcolor = color.toString()
                }
            }

            RowLayout {

                PlasmaComponents.Label {
                    text: i18n("Low percentage")
                }

                KQuickControls.ColorButton {
                    id: paneldynamicLowcolor
                    color: plasmoid.configuration.paneldynamicLowcolor

                    // save my color pls
                    onColorChanged: cfg_paneldynamicLowcolor = color.toString()
                }
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
                PlasmaComponents.Label {
                    text: i18n("Change color to Midrange when below:")
                }

                SpinBox {
                    id: panelMidpercent
                    from: 0
                    to: 100
                    value: root.cfg_panelMidpercent
                }
            }

            RowLayout {
                PlasmaComponents.Label {
                    text: i18n("Change color to Low when below:")
                }

                SpinBox {
                    id: panelLowpercent
                    from: 0
                    to: 100
                    value: root.cfg_panelLowpercent
                }
            }
        }

        SpinBox {
            id: paneliconSize
            Kirigami.FormData.label: i18n("Icon size:")
            from: 16
            to: 128
        }

        CheckBox {
            id: paneliconRotate
            text: i18n("Vertical battery icon")
        }

        PlasmaComponents.Label {
            anchors.margins: Kirigami.Units.smallSpacing
            text: i18n("Applet popup appearance")
            font.pixelSize: 18
            font.bold: true
        }

        FontDialog {
            id: popupfontDiag
            onSelectedFontChanged: {
                plasmoid.configuration.popupfontFamily = selectedFont.family
            }
        }

        RowLayout {
            PlasmaComponents.Label {
                text: i18n("Percentage font family:")
            }

            PlasmaComponents.Button {
                id: popupfontDropdown
                Layout.fillWidth: true
                text: plasmoid.configuration.popupfontFamily || i18n("Default")
                onClicked: {
                    console.log(plasmoid.configuration.popupfontFamily)
                    popupfontDiag.selectedFont.family = plasmoid.configuration.popupfontFamily
                    popupfontDiag.open()
                }
            }
        }

        SpinBox {
            id: popupfontSize
            Kirigami.FormData.label: i18n("Percentage font size:")
            from: 6
            to: 72
            value: root.cfg_popupfontSize
        }

        CheckBox {
            id: popupfontBold
            Kirigami.FormData.label: i18n("Percentage font formatting:")
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
                text: i18n("Percentage position:")
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

        RowLayout {
            visible: opacity > 0
            opacity: plasmoid.configuration.popupcustomcolor ? 0 : 1
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
            Label {
                text: i18n("Percentage fixed color:")
            }

            KQuickControls.ColorButton {
                id: popupcolorPicker
                color: plasmoid.configuration.popuppercentColor

                // save my color pls
                onColorChanged: cfg_popuppercentColor = color.toString()
            }
        }

        CheckBox {
            id: popupcustomcolor
            text: i18n("Enable dynamic percentage color")
        }

        ColumnLayout {
            visible: opacity > 0
            opacity: plasmoid.configuration.popupcustomcolor ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            PlasmaComponents.Label {
                text: i18n("Custom dynamic color:")
            }

            RowLayout {

                PlasmaComponents.Label {
                    text: i18n("High percentage")
                }

                KQuickControls.ColorButton {
                    id: popupdynamicHighcolor
                    color: plasmoid.configuration.popupdynamicHighcolor

                    // save my color pls
                    onColorChanged: cfg_popupdynamicHighcolor = color.toString()
                }
            }

            RowLayout {

                PlasmaComponents.Label {
                    text: i18n("Midrange percentage")
                }

                KQuickControls.ColorButton {
                    id: popupdynamicMidcolor
                    color: plasmoid.configuration.popupdynamicMidcolor

                    // save my color pls
                    onColorChanged: cfg_popupdynamicMidcolor = color.toString()
                }
            }

            RowLayout {

                PlasmaComponents.Label {
                    text: i18n("Low percentage")
                }

                KQuickControls.ColorButton {
                    id: popupdynamicLowcolor
                    color: plasmoid.configuration.popupdynamicLowcolor

                    // save my color pls
                    onColorChanged: cfg_popupdynamicLowcolor = color.toString()
                }
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
                PlasmaComponents.Label {
                    text: i18n("Change color to Midrange when below:")
                }
                SpinBox {
                    id: popupMidpercent
                    from: 0
                    to: 100
                    value: root.cfg_popupMidpercent
                }
            }

            RowLayout {
                PlasmaComponents.Label {
                    text: i18n("Change color to Low when below:")
                }
                SpinBox {
                    id: popupLowpercent
                    from: 0
                    to: 100
                    value: root.cfg_popupLowpercent
                }
            }
        }
    }
}
