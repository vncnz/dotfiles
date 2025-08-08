import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import Quickshell.Io
import "root:/Data" as Data
import "root:/Core" as Core

// Niri workspace indicator
Rectangle {
    id: root
    
    property ListModel workspaces: ListModel {}
    property ListModel windows: ListModel {}
    property int currentWorkspace: -1
    property bool isDestroying: false
    property var currentScreen: null
    
    // Signal for workspace change bursts
    signal workspaceChanged(int workspaceId, color accentColor)
    
    // MASTER ANIMATION CONTROLLER - drives Desktop overlay burst effect
    property real masterProgress: 0.0
    property bool effectsActive: false
    property color effectColor: Data.ThemeManager.accent
    
    // Single master animation that controls Desktop overlay burst
    function triggerUnifiedWave() {
        effectColor = Data.ThemeManager.accent
        masterAnimation.restart()
    }

    // property bool overviewOpen: false
    
    SequentialAnimation {
        id: masterAnimation
        
        PropertyAction {
            target: root
            property: "effectsActive"
            value: true
        }
        
        NumberAnimation {
            target: root
            property: "masterProgress"
            from: 0.0
            to: 1.0
            duration: 1000
            easing.type: Easing.OutQuint
        }
        
        PropertyAction {
            target: root
            property: "effectsActive"
            value: false
        }
        
        PropertyAction {
            target: root
            property: "masterProgress"
            value: 0.0
        }
    }
    
    color: "transparent" // Data.ThemeManager.bgColor
    // opacity: .5
    width: 14
    height: workspaceColumn.implicitHeight + 24
    
    // Smooth height animation
    Behavior on height {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }
    
    // Right-side rounded corners
    topRightRadius: width / 2
    bottomRightRadius: width / 2
    topLeftRadius: 0
    bottomLeftRadius: 0
    
    // Wave effects overlay - unified animation system (DISABLED - using Desktop overlay)
    Item {
        id: waveEffects
        anchors.fill: parent
        visible: false  // Disabled in favor of unified overlay
        z: 2
    }
    
    // Niri event stream listener
    Process {
        id: niriProcess
        command: ["niri", "msg", "event-stream"]
        running: true
        
        stdout: SplitParser {
            onRead: data => {
                const lines = data.split('\n');
                for (const line of lines) {
                    if (line.trim()) {
                        parseNiriEvent(line.trim());
                    }
                }
            }
        }
        
        onExited: {
            // Auto-restart on failure to maintain workspace sync (but not during destruction)
            if (exitCode !== 0 && !root.isDestroying) {
                Qt.callLater(() => running = true);
            }
        }
    }
    
    // Parse Niri event stream messages
    function parseNiriEvent(line) {
        // console.log(line)
        try {
            // Handle workspace focus changes
            if (line.startsWith("Workspace focused: ")) {
                const workspaceId = parseInt(line.replace("Workspace focused: ", ""));
                if (!isNaN(workspaceId)) {
                    const previousWorkspace = root.currentWorkspace;
                    root.currentWorkspace = workspaceId;
                    updateWorkspaceFocus(workspaceId);
                    
                    // Trigger burst effect if workspace actually changed
                    if (previousWorkspace !== workspaceId && previousWorkspace !== -1) {
                        root.triggerUnifiedWave();
                        root.workspaceChanged(workspaceId, Data.ThemeManager.accent);
                    }
                }
            }
            // Handle workspace list updates
            else if (line.startsWith("Workspaces changed: ")) {
                const workspaceData = line.replace("Workspaces changed: ", "");
                parseWorkspaceList(workspaceData);
            } else if (line.startsWith("Windows changed: ")) {
                const windowsData = line.replace("Windows changed: ", "");
                parseWindowsList(windowsData);
            } else if (line.startsWith("Window focus changed: ")) {
                // const windowsData = line.replace("Window focus changed: ", "");
                // parseWindowsList(windowsData);
            } else if (line.startsWith("Overview toggled: ")) {
                const overviewData = line.replace("Overview toggled: ", "");
                console.log("overview changed", overviewData)
                // root.overviewOpen = overviewData === "true"
                Data.RatatoskrLoader.overviewOpen = overviewData === "true"
            } else {
                // console.log(line)
            }
            console.log("windows parsed")
        } catch (e) {
            console.log("Error parsing niri event:", e);
        }
    }
    
    // Update workspace focus states
    function updateWorkspaceFocus(focusedWorkspaceId) {
        for (let i = 0; i < root.workspaces.count; i++) {
            const workspace = root.workspaces.get(i);
            const wasFocused = workspace.isFocused;
            const isFocused = workspace.id === focusedWorkspaceId;
            const isActive = workspace.id === focusedWorkspaceId;
            
            // Only update changed properties to trigger animations
            if (wasFocused !== isFocused) {
                root.workspaces.setProperty(i, "isFocused", isFocused);
                root.workspaces.setProperty(i, "isActive", isActive);
            }
        }
    }
    
    // Parse workspace data from Niri's Rust-style output format
    function parseWorkspaceList(data) {
        try {
            const workspaceMatches = data.match(/Workspace \{[^}]+\}/g);
            if (!workspaceMatches) {
                return;
            }
            
            const newWorkspaces = [];
            
            for (const match of workspaceMatches) {
                const idMatch = match.match(/id: (\d+)/);
                const idxMatch = match.match(/idx: (\d+)/);
                const nameMatch = match.match(/name: Some\("([^"]+)"\)|name: None/);
                const outputMatch = match.match(/output: Some\("([^"]+)"\)/);
                const isActiveMatch = match.match(/is_active: (true|false)/);
                const isFocusedMatch = match.match(/is_focused: (true|false)/);
                const isUrgentMatch = match.match(/is_urgent: (true|false)/);
                
                if (idMatch && idxMatch && outputMatch) {
                    const workspace = {
                        id: parseInt(idMatch[1]),
                        idx: parseInt(idxMatch[1]),
                        name: nameMatch && nameMatch[1] ? nameMatch[1] : "",
                        output: outputMatch[1],
                        isActive: isActiveMatch ? isActiveMatch[1] === "true" : false,
                        isFocused: isFocusedMatch ? isFocusedMatch[1] === "true" : false,
                        isUrgent: isUrgentMatch ? isUrgentMatch[1] === "true" : false
                    };
                    
                    newWorkspaces.push(workspace);
                    
                    if (workspace.isFocused) {
                        root.currentWorkspace = workspace.id;
                    }
                }
            }
            
            // Sort by index and update model
            newWorkspaces.sort((a, b) => a.idx - b.idx);
            root.workspaces.clear();
            root.workspaces.append(newWorkspaces);
        } catch (e) {
            console.log("Error parsing workspace list:", e);
        }
    }

    // Parse workspace data from Niri's Rust-style output format
    function parseWindowsList(data) {
        console.log('Starting windows data parsing', data)
        try {
            const windowsMatches = data.match(/Window \{[^}]+\}/g);
            if (!windowsMatches) {
                return;
            }
            
            const newWindows = [];
            // { id: 41, title: Some("vncnz@Darlene:~"), app_id: Some("Alacritty"), pid: Some(221045), workspace_id: Some(24), is_focused: false, is_floating: false, is_urgent: false }

            for (const match of windowsMatches) {
                const idMatch = match.match(/id: (\d+)/);
                //const idxMatch = match.match(/idx: (\d+)/);
                const titleMatch = match.match(/title: Some\("([^"]+)"\)|name: None/);
                const appIdMatch = match.match(/app_id: Some\("([^"]+)"\)/);
                const pidMatch = match.match(/pid: Some\("([^"]+)"\)/);
                const workspaceIdMatch = match.match(/workspace_id: Some\((\d+)\)/);
                const isFloatingMatch = match.match(/is_floating: (true|false)/);
                const isFocusedMatch = match.match(/is_focused: (true|false)/);
                const isUrgentMatch = match.match(/is_urgent: (true|false)/);
                
                if (idMatch && appIdMatch && workspaceIdMatch) {
                    const window = {
                        id: parseInt(idMatch[1]),
                        appId: appIdMatch[1],
                        title: titleMatch && titleMatch[1] ? titleMatch[1] : "",
                        pidMatch: pidMatch ? parseInt(pidMatch[1]) : pidMatch,
                        workspaceId: parseInt(workspaceIdMatch[1]),
                        isFloating: isFloatingMatch ? isFloatingMatch[1] === "true" : false,
                        isFocused: isFocusedMatch ? isFocusedMatch[1] === "true" : false,
                        isUrgent: isUrgentMatch ? isUrgentMatch[1] === "true" : false
                    };
                    
                    newWindows.push(window);
                    
                    /* if (window.isFocused) {
                        root.currentWindow = window.id;
                    } */
                }
            }
            
            // Sort by index and update model
            // newWindows.sort((a, b) => a.id - b.id);
            root.windows.clear();
            root.windows.append(newWindows);
            console.log('parsed', JSON.stringify(root.windows))
        } catch (e) {
            console.log("Error parsing windows list:", e);
        }
    }
    
    // Vertical workspace indicator pills
    Column {
        id: workspaceColumn
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: root.workspaces // .filter(w => w.output == currentScreen.name)
            
            Rectangle {
                id: workspacePill
                
                // Dynamic sizing based on focus state
                width: model.isFocused ? 14 : 10
                height: model.isFocused ? 36 : 22
                // radius: width / 2
                // scale: model.isFocused ? 1.0 : 0.9
                topRightRadius: width / 2
                bottomRightRadius: width / 2
                topLeftRadius: 0
                bottomLeftRadius: 0

                visible: model.output == currentScreen.name

                property real workspace_id: model.id
                
                // Material Design 3 inspired colors
                color: {
                    if (model.isFocused) {
                        return Data.ThemeManager.accent;
                    }
                    if (model.isActive) {
                        return Qt.rgba(Data.ThemeManager.accent.r, Data.ThemeManager.accent.g, Data.ThemeManager.accent.b, 0.5);
                    }
                    if (model.isUrgent) {
                        return Data.ThemeManager.error;
                    }
                    return Qt.rgba(Data.ThemeManager.primaryText.r, Data.ThemeManager.primaryText.g, Data.ThemeManager.primaryText.b, 0.4);
                }
                
                // Workspace pill burst overlay (DISABLED - using unified overlay)
                /* Rectangle {
                    id: pillBurst
                    anchors.centerIn: parent
                    width: parent.width + 8
                    height: parent.height + 8
                    radius: width / 2
                    color: Data.ThemeManager.accent
                    opacity: 0  // Disabled in favor of unified overlay
                    visible: false
                    z: -1
                } */
                
                // Subtle pulse for inactive pills during workspace changes
                Rectangle {
                    id: inactivePillPulse
                    anchors.fill: parent
                    radius: parent.radius
                    color: "red" // Data.ThemeManager.accent
                    opacity: {
                        // Only pulse inactive pills during effects
                        if (model.isFocused || !root.effectsActive) return 0
                        
                        // More subtle pulse that peaks mid-animation
                        if (root.masterProgress < 0.3) {
                            return (root.masterProgress / 0.3) * 0.15
                        } else if (root.masterProgress < 0.7) {
                            return 0.15
                        } else {
                            return 0.15 * (1.0 - (root.masterProgress - 0.7) / 0.3)
                        }
                    }
                    z: -0.5  // Behind the pill content but visible
                }
                
                // Enhanced corner shadows for burst effect (DISABLED - using unified overlay)
                /* Rectangle {
                    id: cornerBurst
                    anchors.centerIn: parent
                    width: parent.width + 4
                    height: parent.height + 4
                    radius: width / 2
                    color: "transparent"
                    border.color: Data.ThemeManager.accent
                    border.width: 0  // Disabled
                    opacity: 0  // Disabled in favor of unified overlay
                    visible: false
                    z: 1
                } */
                
                // Elevation shadow
                /* Rectangle {
                    anchors.fill: parent
                    anchors.topMargin: model.isFocused ? 1 : 0
                    anchors.leftMargin: model.isFocused ? 0.5 : 0
                    anchors.rightMargin: model.isFocused ? -0.5 : 0
                    anchors.bottomMargin: model.isFocused ? -1 : 0
                    radius: parent.radius
                    color: Qt.rgba(0, 0, 0, model.isFocused ? 0.15 : 0)
                    z: -1
                    visible: model.isFocused
                    
                    Behavior on color { ColorAnimation { duration: 200 } }
                } */
                
                // Smooth Material Design transitions
                Behavior on width { 
                    NumberAnimation { 
                        duration: 300
                        easing.type: Easing.OutCubic 
                    } 
                }
                Behavior on height { 
                    NumberAnimation { 
                        duration: 300
                        easing.type: Easing.OutCubic 
                    } 
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on color { 
                    ColorAnimation { 
                        duration: 200 
                    } 
                }
                
                // Workspace number text
                Text {
                    anchors.centerIn: parent
                    text: model.idx.toString()
                    // text: model.output
                    // text: currentScreen.name == model.output
                    color: model.isFocused ? Data.ThemeManager.background : Data.ThemeManager.primaryText
                    font.pixelSize: model.isFocused ? 10 : 8
                    font.bold: model.isFocused
                    font.family: "Roboto, sans-serif"
                    visible: model.isFocused || model.isActive
                    
                    Behavior on font.pixelSize { NumberAnimation { duration: 200 } }
                    Behavior on color { ColorAnimation { duration: 200 } }
                }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        // Switch workspace via Niri command
                        switchProcess.command = ["niri", "msg", "action", "focus-workspace", model.idx.toString()];
                        switchProcess.running = true;
                    }
                    
                    // Hover feedback
                    onEntered: {
                        if (!model.isFocused) {
                            workspacePill.color = Qt.rgba(Data.ThemeManager.primaryText.r, Data.ThemeManager.primaryText.g, Data.ThemeManager.primaryText.b, 0.6);
                        }
                    }
                    
                    onExited: {
                        // Reset to normal color
                        if (!model.isFocused) {
                            if (model.isActive) {
                                workspacePill.color = Qt.rgba(Data.ThemeManager.accent.r, Data.ThemeManager.accent.g, Data.ThemeManager.accent.b, 0.5);
                            } else if (model.isUrgent) {
                                workspacePill.color = Data.ThemeManager.error;
                            } else {
                                workspacePill.color = Qt.rgba(Data.ThemeManager.primaryText.r, Data.ThemeManager.primaryText.g, Data.ThemeManager.primaryText.b, 0.4);
                            }
                        }
                    }
                }
                /* Windows list for each workspace (bugged)
                Row {
                    visible: Data.RatatoskrLoader.overviewOpen
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.right
                    anchors.leftMargin: 10

                    Repeater {
                        model: root.windows // .filter(win => win.workspaceId == workspace_id) // .filter(w => w.output == currentScreen.name)
                        
                        delegate: Rectangle {
                            visible: model.workspaceId === workspace_id
                            width: 20
                            height: 20
                            color: "transparent"

                            Rectangle {
                                width: 20
                                height: 20
                                color: "transparent"
                                // scale: model.isFocused ? 1.5 : 0.9
                                Text {
                                    color: "black"
                                    anchors.centerIn: parent
                                    text: model && model.appId && model.appId.length > 0 ? model.appId[0].toUpperCase() : 'N'
                                    // text: "R"
                                    font.pixelSize: 16
                                    font.bold: true

                                    layer.enabled: true
                                    layer.effect: DropShadow {
                                        transparentBorder: true
                                        horizontalOffset: 0
                                        verticalOffset: 0
                                        radius: 1
                                        samples: 3
                                        color: "white"
                                        cached: true
                                        spread: 1
                                    }
                                }
                            }

                            Image {
                                width: 20
                                height: 20
                                source: Qt.resolvedUrl("file://" + Data.RatatoskrLoader.winData?.icons[model.appId]) // || "/usr/share/icons/hicolor/22x22/apps/firefox.png"))
                                visible: modelData.workspaceId == workspace_id && Data.RatatoskrLoader.winData?.icons[modelData.appId]
                            }
                        }
                    }
                } */
            }
        }
    }
    
    // Workspace switching command process
    Process {
        id: switchProcess
        running: false
        onExited: {
            running = false
            if (exitCode !== 0) {
                console.log("Failed to switch workspace:", exitCode);
            }
        }
    }
    
    // Border integration corners
    /*Core.Corners {
        id: topLeftCorner
        position: "topleft"
        size: 1.3
        fillColor: Data.ThemeManager.bgColor 
        offsetX: -41
        offsetY: -25
    }*/

    // Top-left corner wave overlay (DISABLED - using unified overlay)
    /* Shape {
        id: topLeftWave
        width: topLeftCorner.width
        height: topLeftCorner.height
        x: topLeftCorner.x
        y: topLeftCorner.y
        visible: false  // Disabled in favor of unified overlay
        preferredRendererType: Shape.CurveRenderer
        layer.enabled: true
        layer.samples: 4
    } */

    /* Core.Corners {
        id: bottomLeftCorner
        position: "bottomleft"
        size: 1.3
        fillColor: Data.ThemeManager.bgColor
        offsetX: -41
        offsetY: 78
    } */

    // Bottom-left corner wave overlay (DISABLED - using unified overlay)
    /* Shape {
        id: bottomLeftWave
        width: bottomLeftCorner.width
        height: bottomLeftCorner.height
        x: bottomLeftCorner.x
        y: bottomLeftCorner.y
        visible: false  // Disabled in favor of unified overlay
        preferredRendererType: Shape.CurveRenderer
        layer.enabled: true
        layer.samples: 4
    } */
    
    // Clean up processes on destruction
    Component.onDestruction: {
        root.isDestroying = true
        
        if (niriProcess.running) {
            niriProcess.running = false
        }
        if (switchProcess.running) {
            switchProcess.running = false
        }
    }
} 