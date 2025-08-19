import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import QtQuick.Effects
// import qs.Settings
// import qs.Services
import "root:/Data" as Data
// import qs.Components

Item {
    id: mediaControl
    width: mediaRow.implicitWidth + 20
    height: mediaText.implicitHeight
    visible: false // Settings.settings.showMediaInBar && musicManager.currentPlayer

    property real slideOffset: -mediaControl.height
    // anchors.bottomMargin: slideOffset

    Behavior on slideOffset {
        NumberAnimation {
            duration: 250
            easing.type: Easing.InCubic
        }
    }

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

    // Show OSD
    function showOsd() {
        if (!mediaControl.visible) {
            mediaControl.visible = true
            slideOffset = 0
            // slideInAnimation.start()
        }
        hideTimer.restart()
    }
    
    // Start slide-out animation to hide OSD
    function hideOsd() {
        mediaControl.slideOffset = -mediaControl.height
        hiddenTimer.restart()
    }

    function hiddenOsd() {
        mediaControl.visible = false
    }

    /* Rectangle {
        width: mediaRow.implicitWidth
        height: parent.height
        color: "gray"
        opacity: .5
        y: -slideOffset
    } */

    RowLayout {
        id: mediaRow
        height: parent.height
        spacing: 8
        y: -slideOffset
        anchors.horizontalCenter: parent.horizontalCenter

        Item {
            id: albumArtContainer
            width: 34 // * Theme.scale(Screen)
            height: 34 // * Theme.scale(Screen)
            // Layout.alignment: Qt.AlignVCenter
            anchors.bottom: parent.bottom

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
            id: mediaText
            text: `${musicManager.trackTitle} - ${musicManager.trackArtist} (${parseInt(musicManager.currentPosition / musicManager.trackLength * 100)}%)`
            color: Data.ThemeManager.accentColor
            font.family: Theme.fontFamily
            font.pixelSize: 16
            elide: Text.ElideRight
            Layout.maximumWidth: 300
            // Layout.alignment: Qt.AlignVCenter
            anchors.bottom: parent.bottom
            padding: 3
        }
    }

    Connections {
        target: musicManager
        function onTrackTitleChanged() {
            showOsd()
        }
        function onIsPlayingChanged() {
            if (musicManager.isPlaying) showOsd()
        }
    }
}
