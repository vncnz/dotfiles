import QtQuick
import Quickshell
import Quickshell.Wayland
import QtQuick.Layouts
import QtQuick.Shapes
import "root:/Data/" as Data
import "root:/Core" as Core

// Brightness OSD with slide animation
Item {
    id: brightnessOsd
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
    
    property int lastBrightness: -1
    
    // Monitor brightness changes from shell and trigger OSD
    Connections {
        target: shell
        function onBrightnessChanged() {
            if (shell.brightness !== lastBrightness && lastBrightness !== -1) {
                showOsd()
            }
            lastBrightness = shell.brightness
        }
    }
    
    Component.onCompleted: {
        // Initialize lastBrightness on startup
        if (shell && shell.brightness !== undefined) {
            lastBrightness = shell.brightness
        }
    }
    
    // Show OSD
    function showOsd() {
        if (!brightnessOsd.visible) {
            brightnessOsd.visible = true
            slideOffset = -45
            // slideInAnimation.start()
        }
        hideTimer.restart()
    }
    
    // Start slide-out animation to hide OSD
    function hideOsd() {
        // slideOutAnimation.start()
        brightnessOsd.slideOffset = 0
        hiddenTimer.restart()
    }

    function hiddenOsd() {
        // slideOutAnimation.start()
        brightnessOsd.visible = false
    }

    Behavior on slideOffset {
        NumberAnimation {
            duration: 250
            easing.type: Easing.InCubic
        }
    }

    
    // Slide in from right edge
    /*NumberAnimation {
        id: slideInAnimation
        target: osdBackground
        property: "x"
        from: brightnessOsd.width
        to: 0
        duration: 300
        easing.type: Easing.OutCubic
    }
    
    // Slide out to right edge
    NumberAnimation {
        id: slideOutAnimation
        target: osdBackground
        property: "x"
        from: 0
        to: brightnessOsd.width
        duration: 250
        easing.type: Easing.InCubic
        onFinished: {
            brightnessOsd.visible = false
            osdBackground.x = 0  // Reset position
        }
    } */
    
    Rectangle {
        id: osdBackground
        width: 45
        height: 250
        // color: Data.ThemeManager.bgColor
        color: "transparent"
        topLeftRadius: 20
        bottomLeftRadius: 20
        x: slideOffset + 45
        
        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            
            // Dynamic brightness icon
            Text {
                id: brightnessIcon
                font.family: "Roboto"
                font.pixelSize: 16
                color: Data.ThemeManager.fgColor
                text: Data.RatatoskrLoader.sysData?.display?.icon
                anchors.horizontalCenter: parent.horizontalCenter
                
                // Scale animation on brightness change
                Behavior on text {
                    SequentialAnimation {
                        PropertyAnimation { target: brightnessIcon; property: "scale"; to: 1.2; duration: 100 }
                        PropertyAnimation { target: brightnessIcon; property: "scale"; to: 1.0; duration: 100 }
                    }
                }
            }
            
            // Vertical brightness bar
            Rectangle {
                opacity: 1
                width: 10
                height: parent.height - brightnessIcon.height - brightnessLabel.height - 36
                radius: 5
                color: Qt.darker(Data.ThemeManager.accentColor, 1.5)
                border.color: Qt.darker(Data.ThemeManager.accentColor, 2.0)
                border.width: 1
                anchors.horizontalCenter: parent.horizontalCenter

                Behavior on opacity {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }
                
                // Animated brightness fill indicator
                Rectangle {
                    id: brightnessFill
                    width: parent.width - 2
                    radius: parent.radius - 1
                    x: 1
                    color: Data.ThemeManager.accentColor
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 1
                    height: {
                        if (!shell || shell.brightness === undefined) return 0
                        var maxHeight = parent.height - 2
                        return maxHeight * Math.max(0, Math.min(1, shell.brightness / 100))
                    }
                    Behavior on height {
                        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                    }
                }
            }
            
            // Brightness percentage text
            Text {
                id: brightnessLabel
                text: shell.brightness + "%"
                font.pixelSize: 10
                font.weight: Font.Bold
                color: Data.ThemeManager.fgColor
                anchors.horizontalCenter: parent.horizontalCenter
                
                // Fade animation on brightness change
                Behavior on text {
                    PropertyAnimation { target: brightnessLabel; property: "opacity"; from: 0.7; to: 1.0; duration: 150 }
                }
            }
        }
    }
}
