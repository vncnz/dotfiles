import QtQuick
import Quickshell
import Quickshell.Wayland
import QtQuick.Layouts
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import QtQuick.Effects
import "root:/Data/" as Data
import "root:/Core" as Core

Rectangle {
    property var text
    property var rotation: 90
    property var textBold: false
    id: root

    width: hint.implicitHeight
    height: hint.implicitWidth
    color: "transparent"
    visible: true

    Text {
        id: hint
        color: Data.ThemeManager.fgColor
        text: root.text
        font.weight: textBold ? Font.Bold : Font.normal
        anchors.centerIn: parent
        transform: Rotation {
            origin.x: hint.implicitWidth / 2
            origin.y: hint.implicitHeight / 2
            angle: root.rotation
        }
    }
}
