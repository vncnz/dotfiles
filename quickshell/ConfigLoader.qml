// ConfigLoader.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    // id: loader
    property string jsonPath: "/tmp/ratatoskr.json"
    property var sysData: {}  // result

    Process {
        id: fileReader
        command: ['cat', jsonPath]

        /* onReady: {
            try {
                sysData = JSON.parse(output);
                console.log("JSON aggiornato:", JSON.stringify(sysData));
            } catch (e) {
                console.error("Errore parsing JSON:", e);
            }
        } */
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    sysData = JSON.parse(this.text);
                    // console.log("JSON aggiornato:", JSON.stringify(sysData));
                } catch (e) {
                    console.error("Errore parsing JSON:", e);
                }
            }// root.time = this.text
        }

        // onError: console.error("Errore lettura file JSON:", error)
    }

    Timer {
        interval: 490
        running: true
        repeat: true
        triggeredOnStart: true

        /* onTriggered: {
            fileReader.command = "cat";
            fileReader.arguments = [jsonPath];
            fileReader.start();
        } */
        onTriggered: fileReader.running = true
    }
}
