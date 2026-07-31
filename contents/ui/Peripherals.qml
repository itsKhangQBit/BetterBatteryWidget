import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support
// battery level of connected Bluetooth peripherals (mouse, headphones, etc.), sourced from upower

Item {
    id: peripheralsRoot
    property alias devices: deviceListModel

    ListModel {
        id: deviceListModel
    }

    Plasma5Support.DataSource {
        id: exec
        engine: "executable"
        interval: 10000
        connectedSources: Plasmoid.configuration.showPeripherals ? ["upower -d"] : []
        onNewData: (sourceName, data) => {
            if (sourceName.includes("upower -d")) {
                peripheralsRoot.updateDevices(data["stdout"] || "");
            }
        }
    }

    // maps upower's device "kind" to an icon that identifies the peripheral type
    function iconForKind(kind) {
        switch (kind) {
            case "mouse": return "input-mouse-symbolic";
            case "keyboard": return "input-keyboard-symbolic";
            case "touchpad": return "input-touchpad-symbolic";
            case "tablet": return "input-tablet-symbolic";
            case "pen": return "input-tablet-symbolic";
            case "gaming-input": return "input-gamepad-symbolic";
            case "headset": return "audio-headset-symbolic";
            case "headphones": return "audio-headphones-symbolic";
            case "speakers": return "audio-speakers-symbolic";
            case "phone": return "smartphone-symbolic";
            case "pda": return "smartphone-symbolic";
            case "media-player": return "multimedia-player-symbolic";
            case "camera": return "camera-photo-symbolic";
            case "printer": return "printer-symbolic";
            case "scanner": return "preferences-devices-scanner-symbolic";
            case "bluetooth-generic": return "preferences-system-bluetooth-symbolic";
            default: return "battery-good-symbolic";
        }
    }

    function batteryIcon(percent, charging) {
        let tier = (Math.floor(Math.min(99, Math.max(0, percent)) / 10) * 10).toString().padStart(3, '0');
        return "battery-" + tier + (charging ? "-charging" : "");
    }

    function updateDevices(output) {
        try {
            // "upower -d" dumps every power device separated by "Device: <path>"
            let blocks = output.split("Device: ").slice(1);
            let parsed = [];

            for (const block of blocks) {
                // only devices that don't power the system itself are peripherals
                if (!/power supply:\s*no/.test(block)) continue;

                let percentMatch = block.match(/percentage:\s*(\d+)%/);
                if (!percentMatch) continue; // nothing worth showing without a battery level

                // the device "kind" is a bare word line, e.g. "  mouse", right before its indented properties
                let kindMatch = block.match(/^  ([a-z][a-z-]*)$/m);
                let modelMatch = block.match(/model:\s*(.+)/);
                let stateMatch = block.match(/state:\s*(\S+)/);

                let kind = kindMatch ? kindMatch[1] : "other";
                let percent = parseInt(percentMatch[1], 10);
                let state = stateMatch ? stateMatch[1].trim() : "unknown";
                let charging = (state === "charging" || state === "pending-charge");
                let name = modelMatch ? modelMatch[1].trim() : (kind.charAt(0).toUpperCase() + kind.slice(1));

                parsed.push({
                    name: name,
                    percent: percent,
                    charging: charging,
                    typeIcon: iconForKind(kind),
                    levelIcon: batteryIcon(percent, charging)
                });
            }

            // update in place so unchanged rows don't flicker/re-animate every refresh
            for (let i = 0; i < parsed.length; i++) {
                if (i < deviceListModel.count) {
                    deviceListModel.set(i, parsed[i]);
                } else {
                    deviceListModel.append(parsed[i]);
                }
            }
            while (deviceListModel.count > parsed.length) {
                deviceListModel.remove(deviceListModel.count - 1);
            }
        } catch (e) {
            console.log("Oops, I can't parse peripheral battery data! [" + e + "]");
        }
    }
}
