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

    Repeater {
        model: Array.from({length: 24}, (e, i) => i)

        Rectangle {
            width: parent.width
            height: modelData % 6 === 0 ? 4 : 2

            x: 0
            y: parent.height * (1 - modelData / 24) - 1
            
            // color: Data.ThemeManager.bgColor
            // opacity: .5
            color: modelData % 3 === 0 ? "white" : "gray"
            radius: 10


            Text {
                text: modelData % 10
                // x: 0
                // y: 0 // parent.height * (1 - modelData / 24) - 1
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 3
                color: "gray"
                font.pixelSize: 11
                visible: modelData % 3 == 0
            }
        }
    }
    
    Rectangle {
        id: clockLevel
        width: parent.width
        height: 4

        x: 0
        y: parent.height * (1 - (parseInt(Qt.formatTime(new Date(), "HH")) * 60 + parseInt(Qt.formatTime(new Date(), "mm"))) / 1440) - 1

        color: "red"
        radius: 10
        // color: Qt.lighter(Data.ThemeManager.accentColor, 1.25)
    }

    // Update every minute
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            clockLevel.y = parent.height * (1 - (parseInt(Qt.formatTime(new Date(), "HH")) * 60 + parseInt(Qt.formatTime(new Date(), "mm"))) / 1440) - 1
        }
    }
}