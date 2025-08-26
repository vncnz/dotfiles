import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import Quickshell.Io
import "root:/Data" as Data
import "root:/Core" as Core

import Quickshell

// Niri workspace indicator
Rectangle {
    id: root

    property bool isDestroying: false
    property var currentScreen: null
    
    // Signal for workspace change bursts
    signal workspaceChanged(int workspaceId, color accentColor)
    
    // MASTER ANIMATION CONTROLLER - drives Desktop overlay burst effect
    property real masterProgress: 0.0
    property bool effectsActive: false
    property color effectColor: Data.ThemeManager.accent

    Connections {
        target: niriService
        /* function onWorkspacesChanged() {
            console.log('WORKSPACES CHANGED', currentScreen.name, JSON.stringify(niriService.workspaces))
        } */
        function onFocusedWorkspaceIndexChanged() {
            // console.log("FOCUSED WORKSPACE CHANGED")
            triggerUnifiedWave()
        }
    }
    
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

    // Vertical workspace indicator pills
    Column {
        id: workspaceColumn
        anchors.centerIn: parent
        spacing: 6

        function getAppIcon(toplevel: Toplevel): string {
                    if (!toplevel) return "";
                    let icon = Quickshell.iconPath(toplevel.appId?.toLowerCase(), true);
                    if (!icon) icon = Quickshell.iconPath(toplevel.appId, true);
                    if (!icon) icon = Quickshell.iconPath(toplevel.title?.toLowerCase(), true);
                    if (!icon) icon = Quickshell.iconPath(toplevel.title, true);
                    return icon || Quickshell.iconPath("application-x-executable", true);
                }
        
        Repeater {
            model: niriService.workspaces.filter(w => w.output == currentScreen.name)
            
            Rectangle {
                id: workspacePill
                
                // Dynamic sizing based on focus state
                width: modelData.isFocused ? 14 : 10
                height: modelData.isFocused ? 36 : 22
                // radius: width / 2
                // scale: model.isFocused ? 1.0 : 0.9
                topRightRadius: width / 2
                bottomRightRadius: width / 2
                topLeftRadius: 0
                bottomLeftRadius: 0

                // visible: model.output == currentScreen.name

                property real workspace_id: modelData.id
                
                // Material Design 3 inspired colors
                color: {
                    if (modelData.isFocused) {
                        return Data.ThemeManager.accent;
                    }
                    if (modelData.isActive) {
                        return Qt.rgba(Data.ThemeManager.accent.r, Data.ThemeManager.accent.g, Data.ThemeManager.accent.b, 0.5);
                    }
                    if (modelData.isUrgent) {
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
                        if (modelData.isFocused || !root.effectsActive) return 0
                        
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
                    text: modelData.idx.toString() // `${JSON.stringify(modelData)}`
                    // text: model.output
                    // text: currentScreen.name == model.output
                    color: modelData.isFocused ? Data.ThemeManager.background : Data.ThemeManager.primaryText
                    font.pixelSize: modelData.isFocused ? 10 : 8
                    font.bold: modelData.isFocused
                    font.family: "Roboto, sans-serif"
                    visible: modelData.isFocused || modelData.isActive
                    
                    Behavior on font.pixelSize { NumberAnimation { duration: 200 } }
                    Behavior on color { ColorAnimation { duration: 200 } }
                }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        // Switch workspace via Niri command
                        switchProcess.command = ["niri", "msg", "action", "focus-workspace", modelData.idx.toString()];
                        switchProcess.running = true;
                    }
                    
                    // Hover feedback
                    onEntered: {
                        if (!modelData.isFocused) {
                            workspacePill.color = Qt.rgba(Data.ThemeManager.primaryText.r, Data.ThemeManager.primaryText.g, Data.ThemeManager.primaryText.b, 0.6);
                        }
                    }
                    
                    onExited: {
                        // Reset to normal color
                        if (!modelData.isFocused) {
                            if (modelData.isActive) {
                                workspacePill.color = Qt.rgba(Data.ThemeManager.accent.r, Data.ThemeManager.accent.g, Data.ThemeManager.accent.b, 0.5);
                            } else if (modelData.isUrgent) {
                                workspacePill.color = Data.ThemeManager.error;
                            } else {
                                workspacePill.color = Qt.rgba(Data.ThemeManager.primaryText.r, Data.ThemeManager.primaryText.g, Data.ThemeManager.primaryText.b, 0.4);
                            }
                        }
                    }
                }
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
    
    // Clean up processes on destruction
    Component.onDestruction: {
        root.isDestroying = true
        
        /* if (niriProcess.running) {
            niriProcess.running = false
        } */
        if (switchProcess.running) {
            switchProcess.running = false
        }
    }
} 