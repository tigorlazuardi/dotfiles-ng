// qmllint disable

import QtQuick
import Quickshell.Hyprland

Rectangle {
    width: 52
    // This has issue:
    // TODO: fix this binding loop
    // qs:@/qs/bar/WorkspaceWidget.qml:11:5: QML WorkspaceWidget: Binding loop detected for property "height"
    height: childrenRect.height + 16
    radius: width / 2
    color: "#1f1d2e"  // rose-pine surface (opaque)
    border.color: "#403d52"  // rose-pine overlay
    border.width: 1

    Column {
        anchors.centerIn: parent
        spacing: 2

        Repeater {
            model: Hyprland.workspaces
            delegate: Rectangle {
                required property var modelData

                property bool hovered: false

                width: 40
                implicitHeight: hovered ? 36 : 18
                radius: 4

                color: {
                    if (modelData.active)
                        return "#e0def4";  // rose-pine text
                    if (hovered)
                        return "#c4a7e7";  // rose-pine iris
                    return "#26233a";    // rose-pine surface
                }
                border.color: {
                    if (modelData.active)
                        return "#ebbcba";  // rose-pine rose
                    if (hovered)
                        return "#f6c177";  // rose-pine gold
                    return "#6e6a86";    // rose-pine muted
                }
                border.width: 1

                Behavior on height {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutQuad
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: modelData.id
                    color: {
                        if (modelData.active)
                            return "#191724";  // rose-pine base
                        if (hovered)
                            return "#191724";  // rose-pine base
                        return "#e0def4";    // rose-pine text
                    }
                    font.pixelSize: hovered ? 12 : 10
                    font.bold: modelData.active

                    Behavior on font.pixelSize {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutQuad
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: parent.hovered = true
                    onExited: parent.hovered = false
                    onClicked: Hyprland.dispatch("workspace " + modelData.id)
                }
            }
        }
    }
}
