import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "root:/Data" as Data

Rectangle {
    id: root
    property var shell: null
    color: Qt.darker(Data.ThemeManager.bgColor, 1.15)
    radius: 20

    property bool containsMouse: themeMouseArea.containsMouse
    property bool menuJustOpened: false

    signal entered()
    signal exited()

    onContainsMouseChanged: {
        if (containsMouse) {
            entered()
        } else if (!menuJustOpened) {
            exited()
        }
    }

    MouseArea {
        id: themeMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            Data.ThemeManager.toggleTheme()
        }
    }

    Label {
        anchors.centerIn: parent
        text: "contrast"
        font.pixelSize: 24
        font.family: "Symbols Nerd Font"
        color: containsMouse ? Data.ThemeManager.accentColor : Data.ThemeManager.fgColor
    }
} 