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
        function onWindowsChanged() {
            // console.log('WINDOWS CHANGED', currentScreen.name, JSON.stringify(niriService.windows))
        }
        function onLoadingIconsChanged() {
            // console.log('ICONS LOADED')
        }
        /* function onFocusedWindowTitleChanged() {
            // console.log("FOCUSED WINDOW CHANGED")
            // triggerUnifiedWave()
        } */
    }

    color: "transparent" // Data.ThemeManager.bgColor
    // opacity: .5
    width: 20
    height: windowsColumn.implicitHeight + 24
    
    // Smooth height animation
    Behavior on height {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    // Vertical workspace boxes
    Column {
        id: windowsColumn
        anchors.centerIn: parent
        spacing: 20

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
                width: workwindows.implicitWidth
                height: workwindows.implicitHeight

                // visible: model.output == currentScreen.name

                property real workspace_id: modelData.id
                // property var workspace_output: modelData.output
                
                // Material Design 3 inspired colors
                color: "transparent"

                Column {
                    id: workwindows
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 6
                    // visible: workspace_output == currentScreen.name

                    /* Text {
                        text: workspace_id
                        color: "white"
                    } */

                    Repeater {
                        model: niriService.windows.filter(win => win.workspaceId == workspace_id) // .filter(w => w.output == currentScreen.name)
                        
                        delegate: Rectangle {
                            // visible: modelData.workspaceId === workspace_id
                            width: 16
                            height: 16
                            color: "transparent"

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onEntered: {
                                    /* var text = appTitle || appId;
                                    styledTooltip.text = text.length > 60 ? text.substring(0, 60) + "..." : text;
                                    styledTooltip.targetItem = appButton;
                                    styledTooltip.tooltipVisible = true; */
                                    console.log("onEntered")
                                }

                                onExited: {
                                    // styledTooltip.tooltipVisible = false;
                                    console.log("onExited")
                                }

                                onClicked: function(mouse) {
                                    /* if (mouse.button === Qt.MiddleButton) {
                                        if (modelData && modelData.close) {
                                            modelData.close();
                                        }
                                    }

                                    if (mouse.button === Qt.LeftButton) {
                                        if (modelData && modelData.activate) {
                                            modelData.activate();
                                        }
                                    } */
                                    console.log("onClicked", modelData.id)
                                    switchProcess.command = ["niri", "msg", "action", "focus-window", "--id", modelData.id.toString()];
                                    switchProcess.running = true;
                                }

                                onPressed: mouse => {
                                    /* if (mouse.button === Qt.RightButton) {
                                        // context menu logic (optional)
                                    } */
                                    console.log("onPressed")
                                }
                            }

                            // property var iconPath: windowsColumn.getAppIcon(modelData)

                            Rectangle {
                                width: 16
                                height: 16
                                color: "transparent"

                                /* Text {
                                    color: "white"
                                    anchors.centerIn: parent
                                    // anchors.left: parent.left
                                    text: modelData && modelData.appId && modelData.appId.length > 0 ? modelData.appId[0].toUpperCase() : 'N'
                                    // text: "R"
                                    font.pixelSize: 16
                                    font.bold: true
                                } */

                                Text {
                                    color: "white"
                                    anchors.left: parent.left
                                    anchors.leftMargin: 30
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData && modelData.appId && modelData.appId.length > 0 ? `${modelData.appId}` : 'N'
                                    // text: "R"
                                    font.pixelSize: 16
                                    font.bold: true
                                    visible: niriService.inOverview

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
                                source: "/tmp/app_icons/ico_" + modelData.appId + (niriService.loadingIcons ? '_' : '') // iconPath
                                onStatusChanged: if (status === Image.Error) { niriService.reloadIcons() }
                            }
                        }
                    }
                }
                
                /* MouseArea {
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
            /* if (exitCode !== 0) {
                console.log("Failed to switch workspace:", exitCode);
            } */
        }
    }
    
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