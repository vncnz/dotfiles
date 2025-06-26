// Bar.qml
import Quickshell
import QtQuick.Layouts

Scope {
  // no more time object

  Variants {
    model: Quickshell.screens

    PanelWindow {
      property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 30

      RowLayout {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        // Layout.fillWidth: true
        // Layout.fillHeight: true

        ClockWidget {
            // anchors.centerIn: parent
        }

        InfoWidget {
            // anchors.centerIn: parent
        }
      }
    }
  }
}