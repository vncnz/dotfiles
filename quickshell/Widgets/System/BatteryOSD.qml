import QtQuick
import Quickshell
import Quickshell.Wayland
import QtQuick.Layouts
import QtQuick.Shapes
import "root:/Data/" as Data
import "root:/Core" as Core

// Battery OSD with slide animation
Item {
    id: batteryOsd
    property var shell
    
    // Size and visibility
    width: osdBackground.width
    height: osdBackground.height
    visible: false

    property real slideOffset: 0
    
    // Auto-hide timer (2.5 seconds of inactivity)
    Timer {
        id: hideTimer
        interval: 2500
        onTriggered: hideOsd()
    }
    Timer {
        id: hiddenTimer
        interval: 200
        onTriggered: hiddenOsd()
    }
    
    
    // Monitor battery changes from shell and trigger OSD
    /* property int lastBattery: -1
    Connections {
        target: shell
        function onBatteryChanged() {
            if (shell.battery !== lastBattery && lastBattery !== -1) {
                showOsd()
            }
            lastBattery = shell.battery
        }
    }
    
    Component.onCompleted: {
        // Initialize lastBattery on startup
        if (shell && shell.battery !== undefined) {
            lastBattery = shell.battery
        }
    } */

    property bool lastShowBattery: false
    Connections {
        target: shell
        function onShowBatteryChanged() {
            if (shell.showBattery !== lastShowBattery) {
                shell.showBattery ? showOsd() : hideOsd()
            }
            lastShowBattery = shell.battery
        }
    }
    
    Component.onCompleted: {
        // Initialize lastShowBattery on startup
        if (shell && shell.showBattery !== undefined) {
            lastShowBattery = shell.showBattery
        }
    }
    
    // Show OSD
    function showOsd() {
        if (!batteryOsd.visible) {
            batteryOsd.visible = true
            slideOffset = -17
            // slideInAnimation.start()
        }
        // hideTimer.restart()
    }
    
    // Start slide-out animation to hide OSD
    function hideOsd() {
        // slideOutAnimation.start()
        batteryOsd.slideOffset = 0 // ! De-comment me
        // hiddenTimer.restart()
    }

    function hiddenOsd() {
        // slideOutAnimation.start()
        batteryOsd.visible = false
    }

    Behavior on slideOffset {
        NumberAnimation {
            duration: 250
            easing.type: Easing.InCubic
        }
    }
    
    Rectangle {
        id: osdBackground
        width: 17
        height: 250
        // color: Data.ThemeManager.bgColor
        color: "transparent"
        topLeftRadius: 20
        bottomLeftRadius: 20
        x: slideOffset + 17
        
        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            
            // Dynamic battery icon
            Text {
                id: batteryIcon
                font.family: "Symbols Nerd Font"
                font.pixelSize: 16
                color: Data.ThemeManager.fgColor
                text: Data.RatatoskrLoader.sysData?.battery?.icon
                anchors.horizontalCenter: parent.horizontalCenter
                
                // Scale animation on battery change
                Behavior on text {
                    SequentialAnimation {
                        PropertyAnimation { target: batteryIcon; property: "scale"; to: 1.2; duration: 100 }
                        PropertyAnimation { target: batteryIcon; property: "scale"; to: 1.0; duration: 100 }
                    }
                }
            }
            
            // Vertical battery bar
            Rectangle {
                opacity: 1
                width: 10
                height: parent.height - batteryIcon.height - batteryLabel.height - 36
                topLeftRadius: 5
                bottomLeftRadius: 5
                color: Qt.darker(Data.ThemeManager.accentColor, 1.5)
                border.color: Qt.darker(Data.ThemeManager.accentColor, 2.0)
                border.width: 1
                anchors.horizontalCenter: parent.horizontalCenter

                Behavior on opacity {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }
                
                // Animated battery fill indicator
                Rectangle {
                    id: batteryFill
                    width: parent.width - 2
                    radius: parent.radius - 1
                    x: 1
                    // color: Data.ThemeManager.accentColor
                    color: Data.RatatoskrLoader.sysData?.battery?.state === "Discharging" ? Data.RatatoskrLoader.sysData?.battery?.color : Data.ThemeManager.accentColor
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 1
                    topLeftRadius: 5
                    bottomLeftRadius: 5

                    height: {
                        if (!shell || shell.battery === undefined) return 0
                        var maxHeight = parent.height - 2
                        return maxHeight * Math.max(0, Math.min(1, shell.battery / 100))
                    }
                    Behavior on height {
                        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                    }
                }
            }
            
            // Battery percentage text
            Text {
                id: batteryLabel
                text: shell.battery + "%"
                font.pixelSize: 14
                font.weight: Font.Bold
                color: Data.ThemeManager.fgColor
                anchors.horizontalCenter: parent.horizontalCenter
                transform: Rotation {
                    origin.x: batteryLabel.implicitWidth / 2
                    origin.y: batteryLabel.implicitHeight / 2
                    angle: 90
                }
                
                // Fade animation on battery change
                Behavior on text {
                    PropertyAnimation { target: batteryLabel; property: "opacity"; from: 0.7; to: 1.0; duration: 150 }
                }
            }
        }
    }
}
