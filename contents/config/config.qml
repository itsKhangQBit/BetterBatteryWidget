import QtQuick 2.15

import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
        name: i18n("Appearance")
        icon: "preferences-desktop-color"
        source: "config/ConfigAppearance.qml"
    }

    ConfigCategory {
        name: i18n("Features")
        icon: "preferences-desktop-box-custom"
        source: "config/ConfigFeatures.qml"
    }
}
