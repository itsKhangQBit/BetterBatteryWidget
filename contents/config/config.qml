import QtQuick

import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("Panel appearance")
        icon: "preferences-desktop-color"
        source: "config/ConfigPanel.qml"
    }

    ConfigCategory {
        name: i18n("Popup appearance")
        icon: "preferences-desktop-display"
        source: "config/ConfigPopup.qml"
    }

    ConfigCategory {
        name: i18n("Applet behavior")
        icon: "preferences-desktop-box-custom"
        source: "config/ConfigBehavior.qml"
    }
}
