// qmllint disable

import QtQuick
import QtQuick.Layouts

ColumnLayout {
    anchors.fill: parent
    spacing: 0

    // Top section - Workspaces
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: parent.height / 3
        color: "transparent"
        
        WorkspaceWidget {
            anchors.centerIn: parent
        }
    }

    // Middle section - Clock
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "transparent"
        
        ClockWidget {
            anchors.centerIn: parent
            time: root.time
        }
    }

    // Bottom section - Available for future widgets
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: parent.height / 3
        color: "transparent"
        
        // Add bottom section widgets here
    }
}