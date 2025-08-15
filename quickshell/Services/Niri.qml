// pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var shell

    property var workspaces: []
    property var windows: []
    property int focusedWindowIndex: -1
    property int focusedWorkspaceIndex: -1
    property bool inOverview: false
    property string focusedWindowTitle: "(No active window)"
    property bool loadingIcons: false

    function updateFocusedWindowTitle() {
        if (focusedWindowIndex >= 0 && focusedWindowIndex < windows.length) {
            focusedWindowTitle = windows[focusedWindowIndex].title || "(Unnamed window)";
        } else {
            focusedWindowTitle = "(No active window)";
        }
        console.log("Changed focused window")
    }

    function reloadIcons () {
        if (!iconsProcess.running) {
            console.log("Loading icons")
            iconsProcess.command = ["/home/vncnz/Repositories/dotfiles/quickshell/align_appicons.py"].concat(root.windows.map(w => w.appId))
            loadingIcons = true
            iconsProcess.running = true
        } else {
            console.log("Already running")
        }
    }
    
    onWindowsChanged: updateFocusedWindowTitle()
    onFocusedWindowIndexChanged: updateFocusedWindowTitle()
    
    Component.onCompleted: {
        eventStream.running = true;
    }

    Process {
        id: workspaceProcess
        running: false
        command: ["niri", "msg", "--json", "workspaces"]
        
        stdout: SplitParser {
            onRead: function(line) {
                try {
                    const workspacesData = JSON.parse(line);
                    const workspacesList = [];
                    
                    for (const ws of workspacesData) {
                        workspacesList.push({
                            id: ws.id,
                            idx: ws.idx,
                            name: ws.name || "",
                            output: ws.output || "",
                            isFocused: ws.is_focused === true,
                            isActive: ws.is_active === true,
                            isUrgent: ws.is_urgent === true,
                            isOccupied: ws.active_window_id ? true : false
                        });
                    }

                    workspacesList.sort((a, b) => {
                        if (a.output !== b.output) {
                            return a.output.localeCompare(b.output);
                        }
                        return a.id - b.id;
                    });
                    
                    root.workspaces = workspacesList;

                    let focusedOutput = workspacesList.find(w => w.isFocused).output
                    let idx = 0
                    for (let i = 0; i < workspacesList.length; i++) {
                        if (workspacesList[i].isFocused) {
                            root.focusedWorkspaceIndex = idx;
                            break;
                        }
                        if (workspacesList[i].output == focusedOutput) {
                            idx += 1
                        }
                    }
                    console.log("Niri - Workspaces changed")
                } catch (e) {
                    console.error("Failed to parse workspaces:", e, line);
                }
            }
        }
    }

    Process {
        id: iconsProcess
        command: ["/home/vncnz/Repositories/dotfiles/quickshell/align_appicons.py", "code"]
        running: false
        onExited: function(exitCode) {
            loadingIcons = false
            console.log("align_icons process completed with exit code:", exitCode)
        }
    }
    
    Process {
        id: eventStream        
        running: false
        command: ["niri", "msg", "--json", "event-stream"]

        stdout: SplitParser {
            onRead: data => {
                try {
                    const event = JSON.parse(data.trim());
                    console.log("niri event", JSON.stringify(event))

                    if (event.WorkspacesChanged) {
                        workspaceProcess.running = true;
                    } else if (event.WindowOpenedOrChanged) {
                        let win = event.WindowOpenedOrChanged.window
                        let id = win.id
                        let windows = root.windows
                        let found = windows.findIndex(win => win.id === id)
                        let updatedWin = {
                            id: win.id,
                            title: win.title || "",
                            appId: win.app_id || "",
                            workspaceId: win.workspace_id || null,
                            isFocused: win.is_focused === true
                        }
                        if (found > -1) {
                            windows[found] = updatedWin
                        } else {
                            windows.push(updatedWin)
                        }
                        root.windows = windows
                    } else if (event.WindowClosed) {
                        let id = event.WindowClosed.id
                        root.windows = root.windows.filter(el => el.id !== id)
                    } else if (event.WindowsChanged) {
                        try {
                            const windowsData = event.WindowsChanged.windows;
                            const windowsList = [];
                            for (const win of windowsData) {
                                windowsList.push({
                                    id: win.id,
                                    title: win.title || "",
                                    appId: win.app_id || "",
                                    workspaceId: win.workspace_id || null,
                                    isFocused: win.is_focused === true
                                });
                            }
                            
                            windowsList.sort((a, b) => a.id - b.id);
                            root.windows = windowsList;
                            console.log("Niri - Windows changed")
                            for (let i = 0; i < windowsList.length; i++) {
                                if (windowsList[i].isFocused) {
                                    root.focusedWindowIndex = i;
                                    break;
                                }
                            }
                            // reloadIcons()
                        } catch (e) {
                            console.error("Error parsing windows event:", e);
                        }
                    } else if (event.WorkspaceActivated) {
                        workspaceProcess.running = true;
                    } else if (event.WindowFocusChanged) {
                        try {
                            const focusedId = event.WindowFocusChanged.id;
                            if (focusedId) {
                                root.focusedWindowIndex = root.windows.findIndex(w => w.id === focusedId);
                                if (root.focusedWindowIndex < 0) {
                                    root.focusedWindowIndex = 0;
                                }
                            } else {
                                root.focusedWindowIndex = -1;
                            }
                        } catch (e) {
                            console.error("Error parsing window focus event:", e);
                        }
                    } else if (event.OverviewOpenedOrClosed) {
                        try {
                            root.inOverview = event.OverviewOpenedOrClosed.is_open === true;
                        } catch (e) {
                            console.error("Error parsing overview state:", e);
                        }
                    }
                } catch (e) {
                    console.error("Error parsing event stream:", e, data);
                }
            }
        }
    }
}
