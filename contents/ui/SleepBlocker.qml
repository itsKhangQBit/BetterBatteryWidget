import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support

Item {
    id: sleepBlockerRoot
    property bool blockSleep: true
    property string blockinglist: ""
    property int uid: 0
    property bool hasBlocker: false
    property string pcName: "BetterBatteryWidget_plasmoid"
    property alias sharedList: appListModel
    property var appList: []

    ListModel {
        id: appListModel
    }

    Plasma5Support.DataSource {
        id: exec
        engine: "executable"
        interval: 2000
        connectedSources: []
        onNewData: (sourceName, data) => {
            var output = data["stdout"] || "";

            if (sourceName.includes("systemd-inhibit --list --no-legend")) {
                // Check if output has our process
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
        onNewData: (sourceName, data) => {
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
        onNewData: (sourceName, data) => {
            if (sourceName.includes("dbus-send")) {
                sleepBlockerRoot.blockinglist = data["stdout"] || "";
                updateBlockerList(sleepBlockerRoot.blockinglist);
            } else if (sourceName.includes("id -u")) {
                sleepBlockerRoot.uid = parseInt(data["stdout"], 10) || "";
                disconnectSource(sourceName);
            }
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
        sleepchk.runCMD("id -u");
    }

    function runCafe() {
        // Change the state first
        chgCafeStat()
        // Only then do we switch the Caffeine feature on/off, cause it would do the opposite if we don't switch the states
        if (sleepBlockerRoot.blockSleep) {
            execdisconn.runCMD('systemd-inhibit --what=idle:sleep --who="' + pcName + '" --why="Blocking sleep because you want to" sleep infinity &');
        } else {
            execdisconn.runCMD('pkill -f "' + pcName + '"');
        }
    }

    // here's the function to remove the app
    function remove(app) {
        for (let i = 0; i < appListModel.count; i++) {
            if (appListModel.get(i).appName === app) {
                appListModel.remove(i);
                // update the variable ourselves
                sleepBlockerRoot.hasBlocker = (sleepBlockerRoot.appList.length > 0);
                break;
            }
        }
    }

    function updateBlockerList(unparsedshit) { // basically the unparsed dbus structure
        try {
            let parsedshit = unparsedshit.split('\n').map(line => line.trim());
            let rawApps = [];

            for (let i = 0; i < parsedshit.length; i++) {
                if (parsedshit[i] === "struct {") { // first we find the 1st struct

                    let blockwhatLine = parsedshit[i + 1] || ""; // string "sleep:idle"
                    let nameLine = parsedshit[i + 2] || ""; // string "BetterBatteryWidget_plasmoid"
                    let dbusuidLine = parsedshit[i + 5] || ""; // uint32 1000 / 2763 (gotcha BFDI!)

                    // substring the reasons and appname out
                    let blockwhat = blockwhatLine.substring(blockwhatLine.indexOf('"') + 1, blockwhatLine.lastIndexOf('"'));
                    let name = nameLine.substring(nameLine.indexOf('"') + 1, nameLine.lastIndexOf('"'));

                    // find the uid so we can check if it's our process
                    let dbusuid = 0;
                    if (dbusuidLine.includes("uint32")) {
                        dbusuid = parseInt(dbusuidLine.replace("uint32", "").trim(), 10);
                    }

                    //console.log(blockwhat, name, dbusuid) debugging

                    // now we check the conditions, see if it shall be display
                    if (dbusuid === sleepBlockerRoot.uid && (blockwhat.includes("sleep") || blockwhat.includes("idle"))) {
                        if (name !== "Screen Locker" && name !== "PowerDevil" && name !== pcName) {
                            rawApps.push(name);
                        }
                    }

                    i += 7; // jump to the next app, the infos we got above is enough for us
                }
            }

            // there might be duplicate processes?!
            let nameCount = {};
            let newApps = [];
            for (let rawele = 0; rawele < rawApps.length; rawele++) {
                let appName = rawApps[rawele];
                if (!nameCount[appName]) {
                    nameCount[appName] = 1;
                    newApps.push(appName); // push if no duplicate
                } else {
                    nameCount[appName]++;
                    newApps.push(appName + " [" + nameCount[appName] + "]"); // add numberings
                }
            }
            sleepBlockerRoot.appList = newApps; //push the list

            // if no more then remove
            for (let appchoose = appListModel.count - 1; appchoose >= 0; appchoose--) {
                let currentApp = appListModel.get(appchoose).appName;
                if (newApps.indexOf(currentApp) === -1) {
                    appListModel.setProperty(appchoose, "removing", true);

                    // so here's how the fix works:
                    // instead of deleting, we change the properties of it
                    // FullPopup catches it, plays the animation, then calls the function remove()
                }
            }

            // we add new apps
            for (let appchoose = 0; appchoose < newApps.length; appchoose++) {
                let isExist = false;
                for (let appname = 0; appname < appListModel.count; appname++) {
                    if (appListModel.get(appname).appName === newApps[appchoose]) {
                        isExist = true;
                        break;
                    }
                }
                if (!isExist) {
                    appListModel.append({
                        "appName": newApps[appchoose],
                        "removing": false // add the properties so we can change it
                    });
                }
            }
            sleepBlockerRoot.hasBlocker = (newApps.length > 0);

        } catch(e) {
            console.log("Oops, I can't parse the JSON! [" + e + "]");
        }
    }
}
