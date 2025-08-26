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
    id: root

    width: hint.implicitHeight
    height: hint.implicitWidth
    color: "transparent"

    Text {
        id: hint
        color: Data.ThemeManager.accentColor
        visible: systemTray.items.values.length > 0
        text: root.text
        anchors.centerIn: parent
        transform: Rotation {
            origin.x: hint.implicitWidth / 2
            origin.y: hint.implicitHeight / 2
            angle: root.rotation
        }
    }
}
