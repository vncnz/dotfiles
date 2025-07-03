import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
// import Quickshell.Services.UPower
import "root:/Data" as Data
import "root:/Core" as Core

// Resources with border integration
Item {
    id: resourcesRoot
    width: resourcesBackground.width
    height: resourcesBackground.height

    property bool showWatts: false

    property bool show_loadavg: Data.RatatoskrLoader.overviewOpen
    property bool show_fullram: Data.RatatoskrLoader.overviewOpen || Data.RatatoskrLoader.sysData?.ram.mem_percent > 80
    property bool show_fulldisk: Data.RatatoskrLoader.overviewOpen || Data.RatatoskrLoader.sysData?.disk.used_percent > 80
    property bool show_fullnet: Data.RatatoskrLoader.overviewOpen || Data.RatatoskrLoader.sysData?.network.signal < 50

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
            showWatts = !showWatts
        }
    }

    Rectangle {
        id: resourcesBackground
        width: resourcesText.implicitWidth + 10
        height: resourcesText.implicitHeight + 10
        
        // color: Data.ThemeManager.bgColor
        color: "transparent"
        
        // Rounded corner for border integration
        topLeftRadius: height / 2

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
        RowLayout {
            id: resourcesText
            // anchors.centerIn: parent
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            Text {
                text: show_loadavg ? `󰬢 ${Data.RatatoskrLoader.sysData?.loadavg.m1} ${Data.RatatoskrLoader.sysData?.loadavg.m5} ${Data.RatatoskrLoader.sysData?.loadavg.m15}` : "󰬢"
                font.family: "Symbols Nerd Font"
                color: Data.RatatoskrLoader.sysData?.loadavg.color
                z: 15
                width: 10
                font.pixelSize: 14
            }
            Text {
                text: show_fullram ? ` ${Data.RatatoskrLoader.sysData?.ram.mem_percent}%` : ""
                font.family: "Symbols Nerd Font"
                color: Data.RatatoskrLoader.sysData?.ram.mem_color
                z: 15
                width: 10
                font.pixelSize: 14
            }
            Text {
                text: show_fulldisk ? `󰋊 ${Data.RatatoskrLoader.sysData?.disk.used_percent}%` : "󰋊"
                font.family: "Symbols Nerd Font"
                color: Data.RatatoskrLoader.sysData?.disk.color
                z: 15
                width: 10
            }
            Text {
                text: Data.RatatoskrLoader.sysData?.temperature?.icon || "󱔱"
                font.family: "Symbols Nerd Font"
                color: Data.RatatoskrLoader.sysData?.temperature.color
                z: 15
                width: 10
                visible: !!Data.RatatoskrLoader.sysData?.temperature?.value
            }
            Text {
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
            }
            Text {
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
            }

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

    // Update every minute
    /* Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: resourcesText.text = Qt.formatTime(new Date(), "HH:mm")
    } */

    // Border integration corner pieces
    /* Core.Corners {
        id: topRightCorner
        position: "topright"
        size: 1.3
        fillColor: Data.ThemeManager.bgColor
        offsetX: 39
        offsetY: -26
        z: 0  // Same z-level as resources background
    }
    
    Core.Corners {
        id: topRightCorner2
        position: "topright"
        size: 1.3
        fillColor: Data.ThemeManager.bgColor
        offsetX: -resourcesText.implicitWidth + 16
        offsetY: 6
        z: 0  // Same z-level as resources background
    } */
}