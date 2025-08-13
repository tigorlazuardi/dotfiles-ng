// qmllint disable

// ClockWidget.qml
import QtQuick

Text {
    id: root
    // A property the creator of this type is required to set.
    // Note that we could just set `text` instead, but don't because your
    // clock probably will not be this simple.
    required property string time

    text: time

    transform: Rotation {
        origin.x: root.width / 2 // Rotate around the center horizontally
        origin.y: root.height / 2 // Rotate around the center vertically
        angle: 90 // Rotate by 45 degrees clockwise
    }
}
