import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Qt5Compat.GraphicalEffects
// import QtQuick.Effects
import "root:/Data" as Data
import "root:/Core" as Core

// Clock with border integration
Item {
    id: clockRoot
    width: clockBackground.width
    height: clockBackground.height

    Column {
        id: clockBackground
        // width: 20 // clockText.implicitWidth
        // height: 44 // clockText.implicitHeight
        // anchors.left: parent.left
        
        // color: Data.ThemeManager.bgColor
        // opacity: .5
        // color: "transparent"
        spacing: -11

        Text {
            id: clockTextHours
            // anchors.centerIn: parent
            // anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            // anchors.top: anchors.top
            // anchors.left: parent.left
            font.family: "Roboto"
            font.pixelSize: 16
            font.bold: true
            color: Data.ThemeManager.accentColor//Qt.lighter(Data.ThemeManager.accentColor, .75)
            // horizontalAlignment: Text.AlignHCenter
            // verticalAlignment: Text.AlignVCenter
            text: Qt.formatTime(new Date(), "HH")
            //z: 10

            /* layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 0
                verticalOffset: 0
                radius: 1
                samples: 10
                color: "black"
                cached: true
                spread: 1
            } */
        }
        
        Text {
            id: clockTextMins
            anchors.horizontalCenter: parent.horizontalCenter
            // anchors.bottom: parent.bottom
            // anchors.centerIn: parent
            // anchors.verticalCenter: parent.verticalCenter
            // anchors.left: parent.horizontalCenter
            // anchors.right: parent.right
            // anchors.rightMargin: -8
            font.family: "Roboto"
            font.pixelSize: 16
            font.bold: true
            color: Qt.darker(Data.ThemeManager.accentColor, .75)
            // horizontalAlignment: Text.AlignHCenter
            // verticalAlignment: Text.AlignVCenter
            text: Qt.formatTime(new Date(), "mm")

            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 0
                verticalOffset: 0
                radius: 1
                samples: 10
                color: "black"
                cached: true
                spread: 1
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
}