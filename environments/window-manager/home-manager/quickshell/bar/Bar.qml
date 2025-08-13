// qmllint disable

import QtQuick
import Quickshell
import Quickshell.Io

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
                right: true
                bottom: true
            }

            implicitWidth: 50
            color: "#80191724"  // Semi-transparent rose-pine base

            BarLayout {
                id: barLayout
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
