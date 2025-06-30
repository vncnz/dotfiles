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

    Rectangle {
        id: resourcesBackground
        width: resourcesText.implicitWidth + 10
        height: resourcesText.implicitHeight + 10
        
        // color: Data.ThemeManager.bgColor
        color: "transparent"
        
        // Rounded corner for border integration
        topLeftRadius: height / 2

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
                text: "󰬢"
                font.family: "Symbols Nerd Font"
                color: RatatorkrLoader.sysData?.loadavg.color
                z: 15
                width: 10
                font.pixelSize: 14
            }
            Text {
                text: RatatorkrLoader.sysData?.ram.mem_percent > 80 ? ` ${RatatorkrLoader.sysData?.ram.mem_percent}%` : ""
                font.family: "Symbols Nerd Font"
                color: RatatorkrLoader.sysData?.ram.mem_color
                z: 15
                width: 10
                font.pixelSize: 14
            }
            Text {
                text: RatatorkrLoader.sysData?.disk.used_percent > 80 ? `󰋊 ${RatatorkrLoader.sysData?.disk.used_percent}%` : "󰋊"
                font.family: "Symbols Nerd Font"
                color: RatatorkrLoader.sysData?.disk.color
                z: 15
                width: 10
            }
            Text {
                text: RatatorkrLoader.sysData?.temperature?.icon || "󱔱"
                font.family: "Symbols Nerd Font"
                color: RatatorkrLoader.sysData?.temperature.color
                z: 15
                width: 10
                visible: !!RatatorkrLoader.sysData?.temperature?.value
            }
            Text {
                text: RatatorkrLoader.sysData?.battery?.icon + (RatatorkrLoader.sysData?.battery?.percentage && RatatorkrLoader.sysData?.battery?.percentage < 95 ? ` ${RatatorkrLoader.sysData?.battery?.percentage}%` : '')
                font.family: "Symbols Nerd Font"
                color: RatatorkrLoader.sysData?.battery?.state === "Discharging" ? RatatorkrLoader.sysData?.battery?.color : Data.ThemeManager.accentColor
                z: 15
                width: 10
                visible: !!RatatorkrLoader.sysData?.battery?.percentage
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