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

    //yep that's true - itsKhangQBit
    property bool cfg_pinned
    property bool cfg_pinnedDefault

    property bool cfg_padMinDefault
    property bool cfg_padHrDefault
    property bool cfg_simpleTimeDefault
    property bool cfg_timeLeftDefault
    property bool cfg_healthLeftDefault
    property bool cfg_showPeripheralsDefault

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

    property string cfg_healthGreatColorDefault
    property string cfg_healthGoodColorDefault
    property string cfg_healthOkColorDefault
    property string cfg_healthBadColorDefault
    property int cfg_healthGreatPercentDefault
    property int cfg_healthGoodPercentDefault
    property int cfg_healthOkPercentDefault

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

    property int cfg_popupfontSize
    property bool cfg_popupfontBold
    property string cfg_popuppercentColor
    property bool cfg_popupfontItalic
    property bool cfg_popupfontUnderline
    property string cfg_popupfontFamily
    property int cfg_popuppercentPos
    property bool cfg_popupcustomcolor
    property string cfg_popupdynamicLowcolor
    property string cfg_popupdynamicMidcolor
    property string cfg_popupdynamicHighcolor
    property int cfg_popupMidpercent
    property int cfg_popupLowpercent

    property string cfg_healthGreatColor
    property string cfg_healthGoodColor
    property string cfg_healthOkColor
    property string cfg_healthBadColor
    property int cfg_healthGreatPercent
    property int cfg_healthGoodPercent
    property int cfg_healthOkPercent

    property int cfg_nosleepTitleFontsize
    property int cfg_nosleepAppFontsize
    property string title: "" // shut up QML

    Kirigami.FormLayout {
        id: formLayout
        anchors.fill: parent
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
            Kirigami.FormData.label: i18n("Peripherals")
        }

        CheckBox {
            id: showPeripherals
            Kirigami.FormData.label: i18n("Peripheral batteries:")
            text: i18n("Show battery level of connected Bluetooth devices (mouse, keyboards,...)")
        }
    }
}
