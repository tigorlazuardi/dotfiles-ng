// qmllint disable

import Quickshell // for PanelWindow
import QtQuick // for Text
import Quickshell.Io // for Process

Scope {
    id: root

    property string time

    Variants {
        model: Quickshell.screens
        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                bottom: true
            }

            implicitWidth: 50

            ClockWidget {
                anchors.centerIn: parent
                time: root.time
            }
        }
    }

    Process {
        id: dateProc
        command: ["date"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.time = this.text
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: dateProc.running = true
    }
}
