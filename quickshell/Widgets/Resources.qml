import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
// import Quickshell.Services.UPower
import "root:/Data" as Data
import "root:/Core" as Core
import "root:/Widgets" as Widgets

// Resources with border integration
Item {
    id: resourcesRoot
    // width: resourcesBackground.width
    width: 20
    height: resourcesBackground.height
    

    property bool showWatts: false
    
    /*required property var triggerMouseArea

    // Hover detection for auto-hide
    property bool isHovered: {
        const mouseStates = {
            triggerHovered: triggerMouseArea.containsMouse,
            backgroundHovered: backgroundMouseArea.containsMouse,
            tabSidebarHovered: tabNavigation.containsMouse,
            tabContainerHovered: tabContainer.isHovered,
            tabContentActive: currentTab !== 0, // Non-main tabs stay open
            tabNavigationActive: tabNavigation.containsMouse
        }
        return Object.values(mouseStates).some(state => state)
    }*/

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            showWatts = !showWatts && Data.RatatoskrLoader.sysData?.battery?.watt
        }
    }

    Rectangle {
        id: resourcesBackground
        width: resourcesText.implicitWidth + 10
        height: resourcesText.implicitHeight + 30
        
        // color: Data.ThemeManager.bgColor
        color: "transparent"
        // color: "red"
        
        // Rounded corner for border integration
        // topLeftRadius: height / 2

        anchors {
            // bottom: parent.bottom
            left: parent.left
            right: parent.right
            // bottomMargin: Data.Settings.borderWidth
            // leftMargin: Data.Settings.borderWidth
        }

        /* HoverHandler {
            id: mouse
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            // cursorShape: Qt.PointingHandCursor
            cursorShape: Qt.CrossCursor
        } */

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
            // property alias containsMouse: backgroundMouseArea.containsMouse

            onEntered: { console.log('entered') }
            onClicked: { console.log('clicked') }
            onExited: { console.log('exited') }
        }

        /* Text {
            id: resourcesText
            anchors.centerIn: parent
            font.family: "Roboto"
            font.pixelSize: 14
            font.bold: true
            color: Data.ThemeManager.accentColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: Qt.formatTime(new Date(), "HH:mm")
        } */
        ColumnLayout {
            id: resourcesText
            // anchors.centerIn: parent
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 10
            // anchors.bottomMargin: 10
            spacing: 10

            Widgets.ResRect {
                icon: Data.RatatoskrLoader.sysData?.weather?.icon
                text: `${Data.RatatoskrLoader.sysData?.weather?.text} / ${Data.RatatoskrLoader.sysData?.weather?.temp_real}${Data.RatatoskrLoader.sysData?.weather?.temp_unit}`
                vcolor: Data.RatatoskrLoader.sysData?.weather?.temp_real > 30 ? "#FF0000" : "#55FF00" // Data.ThemeManager.fgColor
                warn: Math.max(0, Math.min(1, 0.5 - ((35 - Data.RatatoskrLoader.sysData?.weather?.temp_real) / 70)))
                expanded: niriService.inOverview
            }
            
            Widgets.ResRect {
                icon: "󰬢"
                text: `${Data.RatatoskrLoader.sysData?.loadavg.m1} ${Data.RatatoskrLoader.sysData?.loadavg.m5} ${Data.RatatoskrLoader.sysData?.loadavg.m15}`
                vcolor: Data.RatatoskrLoader.sysData?.loadavg.color
                warn: Data.RatatoskrLoader.sysData?.loadavg.warn
                expanded: niriService.inOverview
            }

            Widgets.ResRect {
                icon: ""
                text: `${Data.RatatoskrLoader.sysData?.ram.mem_percent}%`
                vcolor: Data.RatatoskrLoader.sysData?.ram.mem_color
                warn: Data.RatatoskrLoader.sysData?.ram.mem_warn
                expanded: niriService.inOverview
            }
            Widgets.ResRect {
                icon: "󰿤"
                text: `${Data.RatatoskrLoader.sysData?.ram.swap_percent}%`
                vcolor: Data.RatatoskrLoader.sysData?.ram.swap_color
                warn: Data.RatatoskrLoader.sysData?.ram.swap_warn
                expanded: niriService.inOverview
            }

            Widgets.ResRect {
                icon: "󰋊"
                text: `${Data.RatatoskrLoader.sysData?.disk.used_percent}%`
                vcolor: Data.RatatoskrLoader.sysData?.disk.color
                warn: Data.RatatoskrLoader.sysData?.disk.warn
                expanded: niriService.inOverview
            }

            Widgets.ResRect {
                icon: Data.RatatoskrLoader.sysData?.temperature?.icon || "󱔱"
                text: Data.RatatoskrLoader.sysData?.temperature.value ? `${parseInt(Data.RatatoskrLoader.sysData?.temperature.value)}°C` : 'N/A'
                vcolor: Data.RatatoskrLoader.sysData?.temperature.color || Data.ThemeManager.highlightBg
                warn: Data.RatatoskrLoader.sysData?.temperature.warn
                expanded: niriService.inOverview
            }

            Widgets.ResRect {
                icon: {
                    return Data.RatatoskrLoader.sysData?.network?.icon || "󰞃"
                }
                text: {
                    if (Data.RatatoskrLoader.sysData?.network) {
                        if (Data.RatatoskrLoader.sysData.network.signal)
                            return `${Data.RatatoskrLoader.sysData.network.signal}% on ${Data.RatatoskrLoader.sysData.network.ssid}`
                        if (Data.RatatoskrLoader.sysData.network.conn_type[0] === 'e')
                            return 'ETH'
                    }
                    return 'N/A'
                }
                vcolor: {
                    if (Data.RatatoskrLoader.sysData?.network?.signal) return Data.RatatoskrLoader.sysData?.network?.color
                    if (Data.RatatoskrLoader.sysData?.network?.conn_type[0] === 'e') return 'gray'
                    return 'red'
                }
                warn: Data.RatatoskrLoader.sysData?.network?.warn || .5
                expanded: niriService.inOverview
            }

            /* Widgets.ResRect {
                icon: Data.RatatoskrLoader.sysData?.battery?.icon
                text: {
                    if (Data.RatatoskrLoader.sysData?.battery?.percentage) {
                        if (!showWatts) { return `${Data.RatatoskrLoader.sysData?.battery?.percentage}%`}
                        else { return `${parseInt(Data.RatatoskrLoader.sysData?.battery?.watt)}W`}
                    } else {
                        return 'PWR'
                    }
                }
                vcolor: Data.RatatoskrLoader.sysData?.battery?.state === "Discharging" ? Data.RatatoskrLoader.sysData?.battery?.color : "white"
                warn: 1 - (100 / Data.RatatoskrLoader.sysData?.battery?.percentage)
                expanded: niriService.inOverview
            } */

            /* Widgets.IconText {
                icon: "󰬢"
                text: `${Data.RatatoskrLoader.sysData?.loadavg.m1}`
                vcolor: Data.RatatoskrLoader.sysData?.loadavg.color
            } */

            /* Widgets.IconText {
                icon: ""
                text: `${Data.RatatoskrLoader.sysData?.ram.mem_percent}%`
                vcolor: Data.RatatoskrLoader.sysData?.ram.mem_color
            } */
            /* Widgets.IconText {
                icon: "󰿤"
                text: `${Data.RatatoskrLoader.sysData?.ram.swap_percent}%`
                vcolor: Data.RatatoskrLoader.sysData?.ram.swap_color
            } */

            /* Widgets.IconText {
                icon: "󰋊"
                text: `${Data.RatatoskrLoader.sysData?.disk.used_percent}%`
                vcolor: Data.RatatoskrLoader.sysData?.disk.color
            } */

            /* Widgets.IconText {
                icon: Data.RatatoskrLoader.sysData?.temperature?.icon || "󱔱"
                text: Data.RatatoskrLoader.sysData?.temperature.value ? `${parseInt(Data.RatatoskrLoader.sysData?.temperature.value)}°C` : 'N/A'
                vcolor: Data.RatatoskrLoader.sysData?.temperature.color || "red"
            } */

            /* Widgets.IconText {
                icon: {
                    if (!Data.RatatoskrLoader.sysData?.network) return "󰞃"
                    return Data.RatatoskrLoader.sysData?.network.icon

                }
                text: {
                    if (Data.RatatoskrLoader.sysData?.network?.signal) return `${Data.RatatoskrLoader.sysData?.network?.signal}%`
                    if (Data.RatatoskrLoader.sysData?.network?.conn_type[0] === 'e') return 'ETH'
                    return 'N/A'
                }
                vcolor: {
                    if (Data.RatatoskrLoader.sysData?.network?.signal) return Data.RatatoskrLoader.sysData?.network?.color
                    if (Data.RatatoskrLoader.sysData?.network?.conn_type[0] === 'e') return "white"
                    return 'red'
                }
            } */

            /* Widgets.IconText {
                icon: Data.RatatoskrLoader.sysData?.battery?.icon
                text: {
                    if (Data.RatatoskrLoader.sysData?.battery?.percentage) {
                        if (!showWatts) { return `${Data.RatatoskrLoader.sysData?.battery?.percentage}%`}
                        else { return `${parseInt(Data.RatatoskrLoader.sysData?.battery?.watt)}W`}
                    } else {
                        return 'PWR'
                    }
                }
                vcolor: Data.RatatoskrLoader.sysData?.battery?.state === "Discharging" ? Data.RatatoskrLoader.sysData?.battery?.color : "white"
            } */

            /* Text {
                text: show_loadavg ? `󰬢 ${Data.RatatoskrLoader.sysData?.loadavg.m1} ${Data.RatatoskrLoader.sysData?.loadavg.m5} ${Data.RatatoskrLoader.sysData?.loadavg.m15}` : "󰬢"
                font.family: "Symbols Nerd Font"
                color: Data.RatatoskrLoader.sysData?.loadavg.color
                z: 15
                width: 10
                font.pixelSize: 14
            } */
            /* Text {
                text: show_fullram ? ` ${Data.RatatoskrLoader.sysData?.ram.mem_percent}%` : ""
                font.family: "Symbols Nerd Font"
                color: Data.RatatoskrLoader.sysData?.ram.mem_color
                z: 15
                width: 10
                font.pixelSize: 14
            } */
            /* Text {
                text: show_fullswap ? `󰿤 ${Data.RatatoskrLoader.sysData?.ram.swap_percent}%` : "󰿤"
                font.family: "Symbols Nerd Font"
                color: Data.RatatoskrLoader.sysData?.ram.swap_color
                z: 15
                width: 10
                font.pixelSize: 14
            } */
            /* Text {
                text: show_fulldisk ? `󰋊 ${Data.RatatoskrLoader.sysData?.disk.used_percent}%` : "󰋊"
                font.family: "Symbols Nerd Font"
                color: Data.RatatoskrLoader.sysData?.disk.color
                z: 15
                width: 10
            } */
            /* Text {
                text: {
                    // if (!Data.RatatoskrLoader.sysData?.temperature?.icon) return "󱔱"
                    if (show_fulltemp) return `${Data.RatatoskrLoader.sysData?.temperature?.icon} ${parseInt(Data.RatatoskrLoader.sysData?.temperature.value)}°C`
                    return Data.RatatoskrLoader.sysData?.temperature?.icon || "󱔱"
                }
                font.family: "Symbols Nerd Font"
                color: Data.RatatoskrLoader.sysData?.temperature.color
                z: 15
                width: 10
                visible: !!Data.RatatoskrLoader.sysData?.temperature?.value
            } */
            /* Text {
                text: {
                    if (!Data.RatatoskrLoader.sysData?.network) return "󰞃"
                    if (Data.RatatoskrLoader.sysData?.network.conn_type == "ethernet") return Data.RatatoskrLoader.sysData?.network?.icon + (show_fullnet ? ` ETH` : "")
                    return Data.RatatoskrLoader.sysData?.network?.icon + (show_fullnet ? ` ${Data.RatatoskrLoader.sysData?.network?.signal}% ${Data.RatatoskrLoader.sysData?.network?.ssid}` : "")
                }
                font.family: "Symbols Nerd Font"
                color: Data.RatatoskrLoader.sysData?.network?.color || Qt.darker(Data.ThemeManager.accentColor, .75)
                z: 15
                width: 10
                visible: !!Data.RatatoskrLoader.sysData?.network
            } */
            /* Text {
                text: {
                    if (Data.RatatoskrLoader.sysData?.battery?.percentage) {
                        if (!showWatts) { return `${Data.RatatoskrLoader.sysData?.battery?.icon} ${Data.RatatoskrLoader.sysData?.battery?.percentage}%`}
                        else { return `${Data.RatatoskrLoader.sysData?.battery?.icon} ${parseInt(Data.RatatoskrLoader.sysData?.battery?.watt)}W`}
                    } else {
                        return Data.RatatoskrLoader.sysData?.battery?.icon
                    }
                }
                font.family: "Symbols Nerd Font"
                color: Data.RatatoskrLoader.sysData?.battery?.state === "Discharging" ? Data.RatatoskrLoader.sysData?.battery?.color : Qt.darker(Data.ThemeManager.accentColor, .75)
                z: 15
                width: 10
                visible: !!Data.RatatoskrLoader.sysData?.battery?.percentage
            } */

            /* Repeater {
                model: Quickshell.screens
                delegate: Text {
                    text: modelData.name
                    color: Data.ThemeManager.fgColor
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    width: parent.width / 7
                    font.pixelSize: 14
                }
            } */
        }
    }
}