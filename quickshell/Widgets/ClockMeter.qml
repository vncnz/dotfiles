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
    id: clockMeter
    width: parent.width
    height: parent.height

    /* Rectangle {
        id: clockBackground
        width: parent.width
        height: parent.height
        
        // color: Data.ThemeManager.bgColor
        // opacity: .5
        color: "yellow"

        Text {
            id: clockTextHours
            anchors.centerIn: parent
            // anchors.verticalCenter: parent.verticalCenter
            // anchors.left: parent.left
            font.family: "Roboto"
            font.pixelSize: 24
            font.bold: true
            color: Qt.lighter(Data.ThemeManager.accentColor, .75)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: Qt.formatTime(new Date(), "HH")

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
        
        Text {
            id: clockTextMins
            // anchors.centerIn: parent
            // anchors.verticalCenter: parent.verticalCenter
            // anchors.left: parent.horizontalCenter
            // anchors.right: parent.right
            // anchors.rightMargin: -8
            font.family: "Roboto"
            font.pixelSize: 18
            font.bold: false
            color: Qt.darker(Data.ThemeManager.accentColor, .75)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: Qt.formatTime(new Date(), "mm")
        }
    } */

    Repeater {
        model: [3, 6, 9, 12, 15, 18, 19, 20, 21, 22, 23]

        Rectangle {
            width: parent.width
            height: 2

            x: 0
            y: parent.height * (1 - modelData / 24) - 1
            
            // color: Data.ThemeManager.bgColor
            // opacity: .5
            color: modelData % 3 === 0 ? "white" : "gray"
        }
    }
    
    Rectangle {
        id: clockLevel
        width: parent.width
        height: 4

        x: 0
        y: parent.height * (1 - (parseInt(Qt.formatTime(new Date(), "HH")) * 60 + parseInt(Qt.formatTime(new Date(), "mm"))) / 1440) - 1
        
        // color: Data.ThemeManager.bgColor
        // opacity: .5
        color: "red"
    }

    // Update every minute
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            // clockTextMins.text = Qt.formatTime(new Date(), "mm")
            // clockTextHours.text = Qt.formatTime(new Date(), "HH")
            clockLevel.y = parent.height * (1 - (parseInt(Qt.formatTime(new Date(), "HH")) * 60 + parseInt(Qt.formatTime(new Date(), "mm"))) / 1440) - 1
        }
    }
}