import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import QtQuick.Effects
// import qs.Settings
import qs.Services
import "root:/Data" as Data
// import qs.Components

Item {
    id: mediaControl
    width: mediaRow.implicitWidth
    height: mediaRow.implicitHeight
    visible: true // Settings.settings.showMediaInBar && musicManager.currentPlayer

    property var yPos: 0
    anchors.bottomMargin: yPos

    Rectangle {
        width: mediaRow.implicitWidth
        height: mediaRow.implicitHeight
        color: "black"
    }

    RowLayout {
        id: mediaRow
        height: parent.height
        spacing: 8

        Item {
            id: albumArtContainer
            width: 34 // * Theme.scale(Screen)
            height: 34 // * Theme.scale(Screen)
            Layout.alignment: Qt.AlignVCenter

            // Circular spectrum visualizer
            /*CircularSpectrum {
                id: spectrum
                values: musicManager.cavaValues
                anchors.centerIn: parent
                innerRadius: 10 * Theme.scale(Screen)
                outerRadius: 18 * Theme.scale(Screen)
                fillColor: Theme.accentPrimary
                strokeColor: Theme.accentPrimary
                strokeWidth: 0
                z: 0
            }*/

            // Album art image
            ClippingRectangle {
                id: albumArtwork
                width: 30 // * Theme.scale(Screen)
                height: 30 // * Theme.scale(Screen)
                anchors.centerIn: parent
                radius: 12 // circle
                color: "white" // Qt.darker(Theme.surface, 1.1)
                border.color: Data.ThemeManager.accentColor // Qt.rgba(Theme.accentPrimary.r, Theme.accentPrimary.g, Theme.accentPrimary.b, 0.3)
                border.width: 1
                z: 1

                Image {
                    id: albumArt
                    anchors.fill: parent
                    anchors.margins: 0
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    mipmap: true
                    cache: false
                    asynchronous: true
                    source: musicManager.trackArtUrl
                    visible: source.toString() !== ""
                }

                // Fallback icon
                Text {
                    anchors.centerIn: parent
                    text: "󰎆"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 14 * Theme.scale(Screen)
                    color: Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.4)
                    visible: !albumArt.visible
                }

                // Play/Pause overlay (only visible on hover)
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: Qt.rgba(0, 0, 0, 0.5)
                    visible: playButton.containsMouse
                    z: 2

                    Text {
                        anchors.centerIn: parent
                        text: musicManager.isPlaying ? "󰏤" : "󰐊"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 14 * Theme.scale(Screen)
                        color: "white"
                    }
                }

                MouseArea {
                    id: playButton
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    enabled: musicManager.canPlay || musicManager.canPause
                    onClicked: musicManager.playPause()
                }
            }
        }

        // Track info
        Text {
            text: musicManager.trackTitle + " - " + musicManager.trackArtist
            color: Data.ThemeManager.accentColor
            font.family: Theme.fontFamily
            font.pixelSize: 12 * Theme.scale(Screen)
            elide: Text.ElideRight
            Layout.maximumWidth: 300
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
