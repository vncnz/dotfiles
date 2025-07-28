import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "root:/Data" as Data
import "root:/Core" as Core

// Clock with border integration
Item {
    id: clockRoot
    width: clockBackground.width
    height: clockBackground.height

    Rectangle {
        id: clockBackground
        width: clockText.implicitWidth + 10
        height: clockText.implicitHeight + 10
        
        // color: Data.ThemeManager.bgColor
        // opacity: .5
        color: "transparent"
        
        // Rounded corner for border integration
        topRightRadius: height / 2

        ColumnLayout {
            id: clockText
            spacing: -16

            Text {
                id: clockTextHours
                // anchors.centerIn: parent
                // anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                font.family: "Roboto"
                font.pixelSize: 24
                font.bold: true
                color: Qt.lighter(Data.ThemeManager.accentColor, .75)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: Qt.formatTime(new Date(), "HH")
            }

            Text {
                id: clockTextMins
                // anchors.centerIn: parent
                // anchors.verticalCenter: parent.verticalCenter
                // anchors.left: parent.horizontalCenter
                anchors.right: parent.right
                font.family: "Roboto"
                font.pixelSize: 18
                font.bold: false
                color: Qt.darker(Data.ThemeManager.accentColor, .75)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: Qt.formatTime(new Date(), "mm")
            }
        }
    }

    // Update every minute
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            clockTextMins.text = Qt.formatTime(new Date(), "mm")
            clockTextHours.text = Qt.formatTime(new Date(), "HH")
        }
    }

    // Border integration corner pieces
    /* Core.Corners {
        id: topLeftCorner
        position: "topleft"
        size: 1.3
        fillColor: Data.ThemeManager.bgColor
        offsetX: -39
        offsetY: -26
        z: 0  // Same z-level as clock background
    } */
    
    /* Core.Corners {
        id: topLeftCorner2
        position: "topleft"
        size: 1.3
        fillColor: Data.ThemeManager.bgColor
        offsetX: 20
        offsetY: 6
        z: 0  // Same z-level as clock background
    } */
}