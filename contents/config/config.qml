import QtQuick

import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("Panel")
        icon: "preferences-desktop-color"
        source: "config/ConfigPanel.qml"
    }

    ConfigCategory {
        name: i18n("Popup")
        icon: "preferences-desktop-display"
        source: "config/ConfigPopup.qml"
    }

    ConfigCategory {
        name: i18n("Behavior")
        icon: "preferences-desktop-box-custom"
        source: "config/ConfigBehavior.qml"
    }
}
