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
        /* function onWindowsChanged() {
            console.log('WINDOWS CHANGED', currentScreen.name, JSON.stringify(niriService.windows))
        } */
        /* function onFocusedWindowTitleChanged() {
            // console.log("FOCUSED WINDOW CHANGED")
            // triggerUnifiedWave()
        } */
    }

    color: "transparent" // Data.ThemeManager.bgColor
    // opacity: .5
    width: 14
    height: windowsColumn.implicitHeight + 24
    
    // Smooth height animation
    Behavior on height {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    // Vertical workspace indicator pills
    Column {
        id: windowsColumn
        anchors.centerIn: parent
        spacing: 16

        function getAppIcon(toplevel: Toplevel): string {
                    if (!toplevel) return "";
                    let icon = Quickshell.iconPath(toplevel.appId?.toLowerCase(), true);
                    if (!icon) icon = Quickshell.iconPath(toplevel.appId, true);
                    if (!icon) icon = Quickshell.iconPath(toplevel.title?.toLowerCase(), true);
                    if (!icon) icon = Quickshell.iconPath(toplevel.title, true);
                    return icon || Quickshell.iconPath("application-x-executable", true);
                }
        
        Repeater {
            model: niriService.workspaces // .filter(w => w.output == currentScreen.name)
            
            Rectangle {
                id: workspacePill
                
                // Dynamic sizing based on focus state
                width: workwindows.implicitWidth
                height: workwindows.implicitHeight

                // visible: model.output == currentScreen.name

                property real workspace_id: modelData.id
                
                // Material Design 3 inspired colors
                color: "transparent"

                Column {
                    id: workwindows
                    spacing: 6

                    Repeater {
                        model: niriService.windows // .filter(win => win.workspaceId == workspace_id) // .filter(w => w.output == currentScreen.name)
                        
                        delegate: Rectangle {
                            visible: modelData.workspaceId === workspace_id && w.output == currentScreen.name
                            width: 16
                            height: 16
                            color: "transparent"

                            property var iconPath: windowsColumn.getAppIcon(modelData)

                            Rectangle {
                                width: 16
                                height: 16
                                color: "transparent"
                                visible: iconPath === ''

                                Text {
                                    color: "white"
                                    anchors.centerIn: parent
                                    text: modelData && modelData.appId && modelData.appId.length > 0 ? modelData.appId[0].toUpperCase() : 'N'
                                    // text: "R"
                                    font.pixelSize: 16
                                    font.bold: true

                                    /* layer.enabled: true
                                    layer.effect: DropShadow {
                                        transparentBorder: true
                                        horizontalOffset: 0
                                        verticalOffset: 0
                                        radius: 1
                                        samples: 1
                                        color: "white"
                                        cached: true
                                        spread: 1
                                    } */
                                }
                            }

                            Image {
                                width: 16
                                height: 16
                                // source: Qt.resolvedUrl("file://" + Data.RatatoskrLoader.winData?.icons[modelData.appId]) // || "/usr/share/icons/hicolor/22x22/apps/firefox.png"))
                                visible: modelData.workspaceId == workspace_id && Data.RatatoskrLoader.winData?.icons[modelData.appId]
                                source: iconPath
                            }
                        }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
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