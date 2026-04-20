import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: sleepBlockerRoot
    property bool blockSleep: true
    property string pcName: "BetterBatteryWidget"

    PlasmaCore.DataSource {
        id: exec
        engine: "executable"
        connectedSources: []
        onNewData: {
            var output = data["stdout"] || "";

            if (sourceName.includes("systemd-inhibit --list --no-legend")) {
                // Check if output has the process
                if (output.includes(pcName)) {
                    // console.log("Found caffeine running! (exec)")
                    sleepBlockerRoot.blockSleep = true;
                } else {
                    // console.log("Caffeine not running...(exec)");
                    sleepBlockerRoot.blockSleep = false;
                }
            }

            // Stop immediately
            disconnectSource(sourceName)
        }

        // just for running cmds below
        function runCMD(cmd) {
            if (connectedSources.indexOf(cmd) === -1) {
                connectSource(cmd);
            }
        }
    }

    function chkCafeStat() {
        exec.runCMD('systemd-inhibit --list --no-legend')
    }

    function chgCafeStat() {
        // just switch the state, don't touch anything else, that's how I got it to work
        sleepBlockerRoot.blockSleep = !sleepBlockerRoot.blockSleep
    }

    function runCafe() {
        // Change the state first
        chgCafeStat()
        // Only then do we switch the Caffeine feature on/off
        if (sleepBlockerRoot.blockSleep) {
            exec.runCMD('systemd-inhibit --what=idle:sleep --who="BetterBatteryWidget" --why="Blocking sleep..." sleep infinity &');
        } else {
            exec.runCMD('pkill -f "BetterBatteryWidget"');
        }
    }
}
