import QtQuick 2.15

Rectangle {
    id: appRoot
    anchors.fill: parent
    visible: true

    Rectangle {
        anchors.fill: parent
        color: "#222"

        Text {
            text: "Settings App"
        }

        //Component.onCompleted: console.log("Settings App loaded");
    }
}
