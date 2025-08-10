// qmllint disable

import Quickshell // for PanelWindow
import QtQuick // for Text
import Quickshell.Io // for Process

Scope {
    id: root

    property string time

    Variants {
        model: Quickshell.screens
        delegate: Component {
            PanelWindow {
                required property var modelData
                screen: modelData

                anchors {
                    top: true
                    left: true
                    bottom: true
                }

                implicitWidth: 50

                Text {
                    id: clock_text
                    // center the bar in its parent component (the window)
                    anchors.centerIn: parent

                    text: root.time

                    transform: Rotation {
                        origin.x: clock_text.width / 2 // Rotate around the center horizontally
                        origin.y: clock_text.height / 2 // Rotate around the center vertically
                        angle: 90 // Rotate by 45 degrees clockwise
                    }
                }
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
