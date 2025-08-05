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
    property var warn
    height: 24

    Rectangle {
        id: itemBar
        
        // Dynamic sizing based on warn level
        width: 10 + (warn * 20)
        height: parent.height
        // radius: width / 2
        // scale: model.isFocused ? 1.0 : 0.9
        topRightRadius: width / 2
        bottomRightRadius: width / 2
        topLeftRadius: 0
        bottomLeftRadius: 0
        color: vcolor
        
        // Subtle pulse for inactive pills during changes
        Rectangle {
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
        }

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
        
        // Symbol text
        Text {
            // anchors.centerIn: parent
            anchors.verticalCenter: parent.verticalCenter
            // anchors.right: parent.right
            text: icon
            // text: model.output
            // text: currentScreen.name == model.output
            color: "black" // model.isFocused ? Data.ThemeManager.background : Data.ThemeManager.primaryText
            font.pixelSize: 10
            font.bold: false
            font.family: "Symbols Nerd Font" // "Roboto, sans-serif"
            
            Behavior on font.pixelSize { NumberAnimation { duration: 200 } }
            Behavior on color { ColorAnimation { duration: 200 } }
        }
        
        /*MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                // Switch workspace via Niri command
                switchProcess.command = ["niri", "msg", "action", "focus-workspace", model.idx.toString()];
                switchProcess.running = true;
            }
            
            // Hover feedback
            onEntered: {
                if (!model.isFocused) {
                    itemBar.color = Qt.rgba(Data.ThemeManager.primaryText.r, Data.ThemeManager.primaryText.g, Data.ThemeManager.primaryText.b, 0.6);
                }
            }
            
            onExited: {
                // Reset to normal color
                if (!model.isFocused) {
                    if (model.isActive) {
                        itemBar.color = Qt.rgba(Data.ThemeManager.accent.r, Data.ThemeManager.accent.g, Data.ThemeManager.accent.b, 0.5);
                    } else if (model.isUrgent) {
                        itemBar.color = Data.ThemeManager.error;
                    } else {
                        itemBar.color = Qt.rgba(Data.ThemeManager.primaryText.r, Data.ThemeManager.primaryText.g, Data.ThemeManager.primaryText.b, 0.4);
                    }
                }
            }
        }*/
    }
}
