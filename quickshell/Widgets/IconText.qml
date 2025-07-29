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
    
    // Size and visibility
    // width: itBackground.width
    width: ico.implicitWidth - 10
    height: iconText.implicitHeight
    anchors.horizontalCenter: parent.horizontalCenter
    
    Rectangle {
        id: itBackground
        width: iconText.implicitWidth + 10
        height: iconText.implicitHeight
        anchors.horizontalCenter: parent.horizontalCenter

        color: "transparent"
        // color: "yellow"

        ColumnLayout {
            id: iconText
            anchors.fill: parent
            // anchors.left: parent.left
            // anchors.right: parent.right
            anchors.centerIn: parent
            spacing: -16

            Text {
                id: ico
                anchors.centerIn: parent
                // anchors.verticalCenter: parent.verticalCenter
                // anchors.left: parent.left
                font.family: "Symbols Nerd Font"
                font.pixelSize: 24
                font.bold: true
                color: Qt.lighter(Data.ThemeManager.accentColor, .75)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: it.icon
            }

            Text {
                id: tex
                // anchors.centerIn: parent
                // anchors.verticalCenter: parent.verticalCenter
                // anchors.left: parent.horizontalCenter
                anchors.right: parent.right
                anchors.verticalCenter: parent.bottom
                font.family: "Roboto"
                font.pixelSize: 10
                font.bold: true
                color: it.vcolor || Qt.darker(Data.ThemeManager.accentColor, .75)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: it.text

                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: -1
                    verticalOffset: -1
                    radius: 2
                    samples: 25
                    color: Qt.rgba(0, 0, 0, 1)
                    cached: true
                    spread: 0.2
                }
            }
        }
    }
}
