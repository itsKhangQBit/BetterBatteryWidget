import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

// fact: this is also the sleep blocker checker

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

    PlasmaCore.DataSource {
        id: exec
        engine: "executable"
        connectedSources: []
        onNewData: {
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

    PlasmaCore.DataSource {
        id: sleepchk
        engine: "executable"
        interval: 2000
        connectedSources: []
        onNewData: {
            if (sourceName.includes("dbus-send")) {
                sleepBlockerRoot.blockinglist = data["stdout"] || "";
                updateBlockerList(sleepBlockerRoot.blockinglist);
            }
        }

        // just for running cmds below
        function runCMD(cmd) {
            if (connectedSources.indexOf(cmd) === -1) {
                connectSource(cmd);
            }
        }
    }

    // this one just for on/off caffeine
    PlasmaCore.DataSource {
        id: execdisconn
        engine: "executable"
        connectedSources: []

        property var result: ({}) // for saving the result

        onNewData: (sourceName, data) => {
            disconnectSource(sourceName);
        }

        function runCMD(cmd, getresult) {
            result[cmd] = getresult;
            connectSource(cmd);
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
        sleepchk.runCMD("dbus-send --print-reply --dest=org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/PolicyAgent org.kde.Solid.PowerManagement.PolicyAgent.ListInhibitions | sed -n '/string/p' | sed 's/string//g; s/^[ \t]*//'");
        // how does it work?
        // we find "string" by sed and print it out (-n to be silent, we only want those lines)
        // then we replace "string" with nuthing :), and clear blank lines
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
    function removeapp(app) {
        for (let i = 0; i < appListModel.count; i++) {
            if (appListModel.get(i).appName === app) {
                appListModel.remove(i);
                // update the variable ourselves
                sleepBlockerRoot.hasBlocker = (sleepBlockerRoot.appList.length > 0);

                break;
            }
        }
    }

    // make a signal so we know when to process the data
    signal goProcess(var apps, var reasons)

    function updateBlockerList(unparsedshit) { // lets just say that I parsed it myself..
        try {
            let parsedshit = unparsedshit.split('\n').map(line => line.trim()).filter(line => line !== "");
            let rawApps = [];
            let reasons = [];
            // count till enough then signal
            let count = 0;
            let total = parsedshit.length / 2;

            if (total === 0) {
                goProcess([], []); //brotha can you update for the final time?
                return;
            }

            for (let i = 0; i < parsedshit.length; i+=2) { // jump 2 lines after we done
                let rawName = parsedshit[i] || ""; // string "zen"
                let rawWhy = parsedshit[i + 1] || ""; // string "Playing video: "BFDI:TPOT 22: Suite Escape"
                // string zen
                let name = rawName.substring(rawName.indexOf('"') + 1, rawName.lastIndexOf('"'));
                // string Playing video: "Cách làm Phở gà chuẩn vị Hà Nội"
                let why = rawWhy.substring(rawWhy.indexOf('"') + 1, rawWhy.lastIndexOf('"'));
                //console.log(name)

                if (total === 0) {
                    goProcess([], []); // just to make sure
                    return;
                }

                if (name !== pcName && name !== "") {
                    rawApps.push(name);
                    reasons.push(why);
                }
            }
        } catch(e) {
            console.log("Oops, I can't parse the JSON! [" + e + "]");
        }
    }

    Connections {
        target: sleepBlockerRoot
        function onGoProcess(apps, reasonlist) {
            // there might be duplicate processes?!
            let nameCount = {};
            let newApps = [];
            for (let rawele = 0; rawele < apps.length; rawele++) {
                let appName = apps[rawele];
                let appReason = reasonlist[rawele];
                let combined = appName+ ": " + appReason
                if (!nameCount[combined]) {
                    nameCount[combined] = 1;
                    newApps.push(appName+ ": " + appReason); // push if no duplicate
                } else {
                    nameCount[combined]++;
                    newApps.push(appName + " [" + nameCount[combined] + "]: " + appReason); // add numberings
                }
            }
            sleepBlockerRoot.appList = newApps; // push the list

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
        }
    }
}
