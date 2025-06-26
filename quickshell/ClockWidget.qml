// ClockWidget.qml
import QtQuick
import QtQuick.Layouts

RowLayout {
  Text {
    // we no longer need time as an input

    // directly access the time property from the Time singleton
    text: Time.time
  }

  Text {
    text: Time.hours
    color: "green"
  }
  Text {
    text: Time.minutes
    color: "red"
  }
}