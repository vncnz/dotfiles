import QtQuick
import QtQuick.Shapes
import Quickshell
import QtQuick.Layouts
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects
import "root:/Data" as Data
import "root:/Widgets/System" as System
import "root:/Core" as Core
import "root:/Widgets" as Widgets
import "root:/Widgets/Notifications" as Notifications
import "root:/Widgets/ControlPanel" as ControlPanel

// import "root:/Widgets/Panel/modules" as Tr
import "root:/Widgets/ControlPanel/components/system" as Tr

// import "root:/RatatoskrLoader" as RatatoskrLoader

// Desktop with borders and UI widgets
Scope {
    id: desktop
    
    property var shell
    property var notificationService
    
    // Wallpaper layer - one per screen
    Variants {
        model: Quickshell.screens
        Core.Wallpaper {
            required property var modelData
            screen: modelData
        }
    }

    // Desktop UI layer per screen
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: mainContainer
            required property var modelData
            screen: modelData
            
            implicitWidth: Screen.width
            implicitHeight: Screen.height
            color: "transparent"
            exclusiveZone: 0
            
            WlrLayershell.namespace: "quickshell-desktop"

            // Interactive mask for workspace indicator only
            mask: Region {
                Region {
                    item: workspaceIndicator
                }
                Region {
                    item: topBarSection
                }
                Region {
                    item: mediaWidget
                }
            }

            anchors {
                top: true
                left: true
                bottom: true
                right: true
            }

            Column {
                id: topBarSection
                anchors {
                    left: parent.left
                    top: parent.top
                    // verticalCenter: parent.verticalCenter
                    // leftMargin: Data.Settings.borderWidth
                }

                System.SystemTray {
                    id: systemTrayModuleSecond
                    // anchors.centerIn: parent
                    shell: root.shell
                    bar: parent
                    trayMenu: inlineTrayMenuSecond
                }

                Tr.TrayMenu {
                    id: inlineTrayMenuSecond
                    parent: mainContainer
                    // width: mainContainer.width - 100
                    menu: null
                    systemTrayY: systemTraySection.y
                    systemTrayHeight: systemTraySection.height
                    onHideRequested: trayBackground.isActive = false
                }

                // Windows indicator at left border
                System.NiriWindows {
                    id: windowsIndicator
                    z: 10
                    // width: 12
                    currentScreen: modelData
                }
            }
            
            // Workspace indicator at left border
            System.NiriWorkspaces {
                id: workspaceIndicator
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    // leftMargin: Data.Settings.borderWidth
                }
                z: 10
                // width: 12
                currentScreen: modelData
            }

            // Volume OSD at right border (primary screen only)
            System.VolumeOSD {
                id: volumeOsd
                shell: desktop.shell
                visible: modelData === Quickshell.primaryScreen
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    rightMargin: Data.Settings.borderWidth
                }
                z: 10
            }

            System.BrightnessOSD {
                id: brightnessOsd
                shell: desktop.shell
                visible: modelData === Quickshell.primaryScreen
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    rightMargin: Data.Settings.borderWidth
                }
                z: 10
            }
            System.BatteryOSD {
                id: batteryOsd
                shell: desktop.shell
                visible: modelData === Quickshell.primaryScreen
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    rightMargin: screenBorder.rightBorderWidth
                }
                z: 10
            }

            // Border background with shadow
            Border {
                id: screenBorder
                anchors.fill: parent
                workspaceIndicator: workspaceIndicator
                volumeOSD: volumeOsd
                brightnessOSD: brightnessOsd
                batteryOSD: batteryOsd
                // clockWidget: clockWidget
                mediaWidget: mediaWidget
                // resourcesWidget: resourcesWidget
                z: -5  // Behind UI elements to prevent shadow from covering control panel
            }

            // Unified Wave Overlay - simple burst effect
            Item {
                id: waveOverlay
                anchors.fill: parent
                visible: workspaceIndicator.effectsActive && Data.Settings.workspaceBurstEnabled
                z: 15

                property real progress: workspaceIndicator.masterProgress
                property color waveColor: workspaceIndicator.effectColor

                // Workspace indicator burst effects
                Item {
                    x: workspaceIndicator.x
                    y: workspaceIndicator.y
                    width: workspaceIndicator.width
                    height: workspaceIndicator.height

                    // Expanding pill burst - positioned at current workspace index (mimics pill shape)
                    Rectangle {
                        x: parent.width / 2 - width / 2
                        y: {
                            
                            // Calculate position accounting for Column centering and pill sizes
                            let cumulativeHeight = 0
                            for (let i = 0; i < niriService.focusedWorkspaceIndex; i++) {
                                const ws = niriService.workspaces[i]
                                cumulativeHeight += (ws && ws.isFocused ? 36 : 22) + 6  // pill height + spacing
                            }
                            
                            // Current pill height
                            const currentWs = niriService.workspaces[niriService.focusedWorkspaceIndex]
                            const currentPillHeight = (currentWs && currentWs.isFocused ? 36 : 22)
                            
                            // Column is centered, so start from center and calculate offset
                            const columnHeight = parent.height - 24  // Total available height minus padding
                            const columnTop = 12  // Top padding
                            
                            return columnTop + cumulativeHeight + currentPillHeight / 2 - height / 2
                        }
                        width: 20 + waveOverlay.progress * 30
                        height: 36 + waveOverlay.progress * 20  // Pill-like height
                        radius: width / 2  // Pill-like rounded shape
                        color: "transparent"
                        border.width: 2
                        border.color: Qt.rgba(waveOverlay.waveColor.r, waveOverlay.waveColor.g, waveOverlay.waveColor.b, 1.0 - waveOverlay.progress)
                        opacity: Math.max(0, 1.0 - waveOverlay.progress)
                    }
                }
            }

            ColumnLayout {
                id: clockWidget
                spacing: 0
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    bottomMargin: screenBorder.borderWidth
                    // leftMargin: Data.Settings.borderWidth
                }
                width: 20 // resourcesRoot.implicitWidth
                z: 10

                Widgets.Resources {}
                Widgets.Clock {}

                
            }

            Widgets.Media {
                id: mediaWidget
                anchors {
                    bottom: parent.bottom
                    // left: parent.left
                    horizontalCenter: parent.horizontalCenter
                    // bottomMargin: Data.Settings.borderWidth
                    // leftMargin: Data.Settings.borderWidth
                }
            }

            /* Rectangle {
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                    rightMargin: Data.Settings.borderWidth + 10
                    bottomMargin: Data.Settings.borderWidth + 10
                }
                z: 10
                width: 50
                height: 50
                color: Qt.rgba(Data.ThemeManager.bgColor.r, Data.ThemeManager.bgColor.g, Data.ThemeManager.bgColor.b, 0.5)
                radius: Data.Settings.cornerRadius / 2

                border {
                    color: Data.ThemeManager.accentColor
                    width: 1
                }

                opacity: 0.9

                Widgets.Clock {
                    anchors.centerIn: parent
                }
            } */

            /* Rectangle {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                    // rightMargin: Data.Settings.borderWidth + 10
                    // bottomMargin: Data.Settings.borderWidth + 10
                }
                z: 10
                width: 5 // Data.Settings.borderWidth
                color: "transparent" // Qt.rgba(Data.ThemeManager.bgColor.r, Data.ThemeManager.bgColor.g, Data.ThemeManager.bgColor.b, 0.5)
                // radius: Data.Settings.cornerRadius / 2

                opacity: 0.9

                Widgets.ClockMeter {
                    anchors.centerIn: parent
                }
            } */

            // Resources at bottom-right corner
            /* Widgets.Resources {
                id: resourcesWidget
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                    bottomMargin: Data.Settings.borderWidth
                    rightMargin: Data.Settings.borderWidth
                }
                z: 10
            } */

            // Notification popups (primary screen only)
            Notifications.Notification {
                id: notificationPopup
                visible: (modelData === (Quickshell.primaryScreen || Quickshell.screens[0])) && calculatedHeight > 20
                anchors {
                    top: parent.top
                    right: parent.right
                    rightMargin: Data.Settings.borderWidth + 20
                    topMargin: 0
                }
                width: 420
                height: calculatedHeight
                shell: desktop.shell
                notificationServer: desktop.notificationService ? desktop.notificationService.notificationServer : null
                z: 15
                
                Component.onCompleted: {
                    let targetScreen = Quickshell.primaryScreen || Quickshell.screens[0]
                    if (modelData === targetScreen) {
                        desktop.shell.notificationWindow = notificationPopup
                    }
                }
            }

            // UI overlay layer for modal components
            Item {
                id: uiLayer
                anchors.fill: parent
                z: 20

                Core.Version {
                    visible: modelData === Quickshell.primaryScreen
                }

                ControlPanel.ControlPanel {
                    id: controlPanelComponent
                    shell: desktop.shell
                }
            }
        }
    }

    // Handle dynamic screen configuration changes
    Connections {
        target: Quickshell
        function onScreensChanged() {
            // Screen changes handled by Variants automatically
        }
    }
} 