import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kquickcontrols as KQuickControls
import QtQuick.Dialogs // for the color dialog

ScrollView {
    anchors.fill: root
    Layout.fillHeight: true
    Layout.fillWidth: true
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical.policy: ScrollBar.AsNeeded
    clip: true
    id: root

    // this is just for QT engine to not throw any warnings
    property int cfg_panelfontSize
    property bool cfg_panelfontBold
    property string cfg_panelpercentColor
    property bool cfg_panelfontItalic
    property bool cfg_panelfontUnderline
    property int cfg_paneliconSize
    property int cfg_panelfontPad
    property bool cfg_panelfontPosR
    property bool cfg_panelfontFamily
    property bool cfg_panelcustomcolor
    property bool cfg_paneliconRotate
    property bool cfg_panelshowPercent
    property bool cfg_panelshowIcon

    property int cfg_popupfontSize
    property bool cfg_popupfontBold
    property string cfg_popuppercentColor
    property bool cfg_popupfontItalic
    property bool cfg_popupfontUnderline
    property int cfg_popuppercentPos
    property bool cfg_popupfontFamily
    property bool cfg_popupcustomcolor

    property int cfg_nosleepTitleFontsize
    property int cfg_nosleepAppFontsize

    // this is what we need
    property alias cfg_padMin: padMin.checked
    property alias cfg_padHr: padHr.checked
    property alias cfg_simpleTime: simpleTime.checked
    property alias cfg_timeLeft: timeLeft.checked
    property alias cfg_healthLeft: healthLeft.checked
    property bool cfg_pinned

    // YOU SHADAP! - Bung Moktar at Malaysia Parliament
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

    property int cfg_nosleepTitleFontsizeDefault
    property int cfg_nosleepAppFontsizeDefault

    Kirigami.FormLayout {
        id: formLayout
        anchors.fill: parent
        property string title: "" // shut up QML
        anchors.margins: Kirigami.Units.smallSpacing

        PlasmaComponents.Label {
            text: i18n("Features")
            font.pixelSize: 18
            topPadding: Kirigami.Units.largeSpacing
            font.bold: true
        }

        CheckBox {
            id: padHr
            Kirigami.FormData.label: i18n("Add leading zero before:")
            text: i18n("Hours")
        }

        CheckBox {
            id: padMin
            text: i18n("Minutes")
        }

        CheckBox {
            id: simpleTime
            Kirigami.FormData.label: i18n("Simplified time")
        }


        CheckBox {
            id: timeLeft
            Kirigami.FormData.label: i18n("Enable time remaining")
        }

        CheckBox {
            id: healthLeft
            Kirigami.FormData.label: i18n("Enable battery health")
        }
    }
}
