import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support

Item {
    id: sleepBlockerRoot
    property bool blockSleep: true
    property string blockinglist: ""
    property bool hasBlocker: false
    property string pcName: "BetterBatteryWidget_plasmoid"
    property alias sharedList: appListModel

    ListModel {
        id: appListModel
    }

    Plasma5Support.DataSource {
        id: exec
        engine: "executable"
        interval: 2000
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

            // Stop immediately.. or don't, it's not gonna self update
            // disconnectSource(sourceName)
        }

        // just for running cmds below
        function runCMD(cmd) {
            if (connectedSources.indexOf(cmd) === -1) {
                connectSource(cmd);
            }
        }
    }

    // this one just for on/off caffeine
    Plasma5Support.DataSource {
        id: execdisconn
        engine: "executable"
        connectedSources: []
        interval: 2000
        onNewData: {
            disconnectSource(sourceName);
        }

        function runCMD(cmd) {
            connectSource(cmd);
        }
    }


    Plasma5Support.DataSource {
        id: sleepchk
        engine: "executable"
        interval: 2000
        connectedSources: []
        onNewData: {
            sleepBlockerRoot.blockinglist = data["stdout"] || "";
            updateBlockerList(sleepBlockerRoot.blockinglist);
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

    function getBlockerList() {
        // dbus is finally the wayyyyyy
        sleepchk.runCMD("dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager.ListInhibitors");
    }

    function runCafe() {
        // Change the state first
        chgCafeStat()
        // Only then do we switch the Caffeine feature on/off
        if (sleepBlockerRoot.blockSleep) {
            execdisconn.runCMD('systemd-inhibit --what=idle:sleep --who="' + pcName + '" --why="Blocking sleep because you want to" sleep infinity &');
        } else {
            execdisconn.runCMD('pkill -f "' + pcName + '"');
        }
    }

    function updateBlockerList(unparsedshit) {
        try {
            let parsedshit = unparsedshit.split('\n').map(line => line.trim());
            let newApps = [];

            for (let i = 0; i < parsedshit.length; i++) {
                if (parsedshit[i] === "struct {") { // first we find the 1st struct

                    let blockwhatLine = parsedshit[i + 1] || ""; // string "sleep:idle"
                    let nameLine      = parsedshit[i + 2] || ""; // string "BetterBatteryWidget_plasmoid"
                    let uidLine       = parsedshit[i + 5] || ""; // uint32 1000

                    //substring the reasons and appname out
                    let blockwhat = blockwhatLine.substring(blockwhatLine.indexOf('"') + 1, blockwhatLine.lastIndexOf('"'));
                    let name      = nameLine.substring(nameLine.indexOf('"') + 1, nameLine.lastIndexOf('"'));

                    //find the uid
                    let uid = 0;
                    if (uidLine.includes("uint32")) {
                        uid = parseInt(uidLine.replace("uint32", "").trim(), 10);
                    }

                    console.log(blockwhat, name, uid)

                    // now we check the conditions
                    if ((blockwhat.includes("sleep") || blockwhat.includes("idle")) && uid >= 1000) {
                        if (name !== "Screen Locker" && name !== "PowerDevil" && name !== pcName) {
                            newApps.push(name);
                        }
                    }

                    i += 7; // jump to the next app
                }
            }

            // if no more then remove
            for (let j = appListModel.count - 1; j >= 0; j--) {
                let currentApp = appListModel.get(j).appName;
                if (newApps.indexOf(currentApp) === -1) {
                    appListModel.remove(j);
                }
            }

            // we add new apps
            for (let k = 0; k < newApps.length; k++) {
                let isExist = false;
                for (let m = 0; m < appListModel.count; m++) {
                    if (appListModel.get(m).appName === newApps[k]) {
                        isExist = true;
                        break;
                    }
                }
                if (!isExist) {
                    appListModel.append({ "appName": newApps[k] });
                }
            }
            sleepBlockerRoot.hasBlocker = (newApps.length > 0);

        } catch(e) {
            console.log("Shit, I can't parse the JSON: " + e);
        }
    }
}
