// InfoWidget.qml
import QtQuick

Rectangle {
  // color: "yellow"
  // anchors.fill: parent
  // width: 20

  Text {
    /* anchors {
      // right: parent.right
      top: parent.top
      bottom: parent.bottom
    } */
    width: 5
    text: ConfigLoader.sysData.loadavg.m1
    color: "red"
  }
  Text {
    /* anchors {
      // right: parent.right
      top: parent.top
      bottom: parent.bottom
    } */

    text: ConfigLoader.sysData.metronome ? "" : ""
    color: "red"
  }
}