import QtQuick
import Quickshell
import Quickshell.Wayland
import QtQuick.Layouts
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import QtQuick.Effects
import "root:/Data/" as Data
import "root:/Core" as Core

// Brightness OSD with slide animation
Item {
    id: it
    property var icon
    property var text
    property var vcolor
    property var warn: 1
    property var expanded: false
    width: 40
    height: 24

    Rectangle {
        id: itemBar
        
        // Dynamic sizing based on warn level
        width: 5 + (warn * 20)
        height: parent.height
        // radius: width / 2
        // scale: model.isFocused ? 1.0 : 0.9
        topRightRadius: 5
        bottomRightRadius: 5
        topLeftRadius: 0
        bottomLeftRadius: 0
        color: { warn > 0.5 || expanded ? vcolor : "transparent" }

        anchors.left: parent.left
        anchors.leftMargin: -1
        
        border {
            color: vcolor
            width: 1
        }

        /* layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 0
            radius: 1
            samples: 10
            color: vcolor
            cached: true
            spread: 0.5
        } */
        
        // Subtle pulse for inactive pills during changes
        /* Rectangle {
            id: inactivePillPulse
            anchors.fill: parent
            height: parent.height
            radius: parent.radius
            color: "red" // Data.ThemeManager.accent
            opacity: {
                return 1
                // Only pulse inactive pills during effects
                // if (model.isFocused || !root.effectsActive) return 0
                
                // More subtle pulse that peaks mid-animation
                if (root.masterProgress < 0.3) {
                    return (root.masterProgress / 0.3) * 0.15
                } else if (root.masterProgress < 0.7) {
                    return 0.15
                } else {
                    return 0.15 * (1.0 - (root.masterProgress - 0.7) / 0.3)
                }
            }
            visible: false
            z: -0.5  // Behind the pill content but visible
        } */

        // Smooth Material Design transitions
        Behavior on width { 
            NumberAnimation { 
                duration: 300
                easing.type: Easing.OutCubic 
            } 
        }
        Behavior on height { 
            NumberAnimation { 
                duration: 300
                easing.type: Easing.OutCubic 
            } 
        }
        Behavior on scale {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }
        Behavior on color { 
            ColorAnimation { 
                duration: 200 
            } 
        }
        
        /* MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                // Switch workspace via Niri command
                // switchProcess.command = ["niri", "msg", "action", "focus-workspace", model.idx.toString()];
                // switchProcess.running = true;
            }
            
            // Hover feedback
            onEntered: {
                textEl.opacity = 1
            }
            
            onExited: {
                // Reset to normal opacity
                // itemBar.color = Qt.rgba(Data.ThemeManager.primaryText.r, Data.ThemeManager.primaryText.g, Data.ThemeManager.primaryText.b, 0.4);
                textEl.opacity = 1
            }
        } */
    }

    // Symbol text
    Text {
        id: textEl
        // anchors.centerIn: parent
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 27
        width: 20
        text: icon
        // text: model.output
        // text: currentScreen.name == model.output
        color: { (warn > 0 || expanded) ? vcolor : "white" }
        font.pixelSize: 20
        font.bold: false
        font.family: "Symbols Nerd Font" // "Roboto, sans-serif"
        
        Behavior on font.pixelSize { NumberAnimation { duration: 200 } }
        Behavior on color { ColorAnimation { duration: 200 } }

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 0
            radius: 1
            samples: 10
            color: black
            cached: true
            spread: 1
        }

        opacity: expanded ? 1 : (0.3 + warn * 0.4)
    }

    // Value text
    Text {
        id: valueEl
        // anchors.centerIn: parent
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 50
        // width: 20
        text: it.text
        // text: model.output
        // text: currentScreen.name == model.output
        color: vcolor
        font.pixelSize: 16
        font.bold: false
        font.family: "Roboto, sans-serif"

        visible: expanded
        
        Behavior on font.pixelSize { NumberAnimation { duration: 200 } }
        Behavior on color { ColorAnimation { duration: 200 } }

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 0
            radius: 1
            samples: 10
            color: black
            cached: true
            spread: 1
        }

        // opacity: 0.3
    }
}
