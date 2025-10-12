import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    anchors.fill: parent
    color: themeManager.colors.background.main

    property int currentIndex: 0
    property var pages: [] // list of page URLs

    Component.onCompleted: {
        // Example: populate dynamically
        pages = [
            "./Pages/Software.qml"
        ]
    }

    Row {
        anchors.fill: parent

        // Sidebar
        Column {
            id: sidebar
            width: 200
            spacing: 10
            Repeater {
                model: pages
                delegate: Button {
                    text: modelData.split("/").pop().replace(".qml", "")
                    font.pixelSize: 18
                    background: Rectangle {
                        color: index === root.currentIndex ? themeManager.colors.accent.primary : "transparent"
                        radius: 6
                    }
                    onClicked: root.currentIndex = index
                }
            }
        }

        // Create a spacer
        Rectangle {
            width: 2
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: sidebar.right
            color: themeManager.colors.accent.primary
        }

        // Page container
        Loader {
            id: pageLoader
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 200
            anchors.right: parent.right
            source: pages.length > 0 ? pages[root.currentIndex] : ""
        }
    }
}
